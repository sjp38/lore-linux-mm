Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 2D3416B002B
	for <linux-mm@kvack.org>; Fri,  9 Nov 2012 01:01:28 -0500 (EST)
Received: by mail-wi0-f179.google.com with SMTP id hm6so161006wib.8
        for <linux-mm@kvack.org>; Thu, 08 Nov 2012 22:01:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121106195342.6941.94892.stgit@srivatsabhat.in.ibm.com>
References: <20121106195026.6941.24662.stgit@srivatsabhat.in.ibm.com> <20121106195342.6941.94892.stgit@srivatsabhat.in.ibm.com>
From: Ankita Garg <gargankita@gmail.com>
Date: Fri, 9 Nov 2012 00:01:06 -0600
Message-ID: <CAKD8Uxd=BguLj=4VvRRfKBDdqrz+p_6Sj6JF2UNEjLd-HNmHMw@mail.gmail.com>
Subject: Re: [RFC PATCH 6/8] mm: Demarcate and maintain pageblocks in
 region-order in the zones' freelists
Content-Type: multipart/alternative; boundary=14dae9cc92a49e788d04ce09ae57
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, mjg59@srcf.ucam.org, paulmck@linux.vnet.ibm.com, dave@linux.vnet.ibm.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, arjan@linux.intel.com, kmpark@infradead.org, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--14dae9cc92a49e788d04ce09ae57
Content-Type: text/plain; charset=ISO-8859-1

Hi Srivatsa,

I understand that you are maintaining the page blocks in region sorted
order. So that way, when the memory requests come in, you can hand out
memory from the regions in that order. However, do you take this scenario
into account - in some bucket of the buddy allocator, there might not be
any pages belonging to, lets say, region 0, while the next higher bucket
has them. So, instead of handing out memory from whichever region thats
present there, to probably go to the next bucket and split that region 0
pageblock there and allocate from it ? (Here, region 0 is just an example).
Been a while since I looked at kernel code, so I might be missing something!

Regards,
Ankita


On Tue, Nov 6, 2012 at 1:53 PM, Srivatsa S. Bhat <
srivatsa.bhat@linux.vnet.ibm.com> wrote:

> The zones' freelists need to be made region-aware, in order to influence
> page allocation and freeing algorithms. So in every free list in the zone,
> we
> would like to demarcate the pageblocks belonging to different memory
> regions
> (we can do this using a set of pointers, and thus avoid splitting up the
> freelists).
>
> Also, we would like to keep the pageblocks in the freelists sorted in
> region-order. That is, pageblocks belonging to region-0 would come first,
> followed by pageblocks belonging to region-1 and so on, within a given
> freelist. Of course, a set of pageblocks belonging to the same region need
> not be sorted; it is sufficient if we maintain the pageblocks in
> region-sorted-order, rather than a full address-sorted-order.
>
> For each freelist within the zone, we maintain a set of pointers to
> pageblocks belonging to the various memory regions in that zone.
>
> Eg:
>
>     |<---Region0--->|   |<---Region1--->|   |<-------Region2--------->|
>      ____      ____      ____      ____      ____      ____      ____
> --> |____|--> |____|--> |____|--> |____|--> |____|--> |____|--> |____|-->
>
>                  ^                  ^                              ^
>                  |                  |                              |
>                 Reg0               Reg1                          Reg2
>
>
> Page allocation will proceed as usual - pick the first item on the free
> list.
> But we don't want to keep updating these region pointers every time we
> allocate
> a pageblock from the freelist. So, instead of pointing to the *first*
> pageblock
> of that region, we maintain the region pointers such that they point to the
> *last* pageblock in that region, as shown in the figure above. That way, as
> long as there are > 1 pageblocks in that region in that freelist, that
> region
> pointer doesn't need to be updated.
>
>
> Page allocation algorithm:
> -------------------------
>
> The heart of the page allocation algorithm remains it is - pick the first
> item on the appropriate freelist and return it.
>
>
> Pageblock order in the zone freelists:
> -------------------------------------
>
> This is the main change - we keep the pageblocks in region-sorted order,
> where pageblocks belonging to region-0 come first, followed by those
> belonging
> to region-1 and so on. But the pageblocks within a given region need *not*
> be
> sorted, since we need them to be only region-sorted and not fully
> address-sorted.
>
> This sorting is performed when adding pages back to the freelists, thus
> avoiding any region-related overhead in the critical page allocation
> paths.
>
> Page reclaim [Todo]:
> --------------------
>
> Page allocation happens in the order of increasing region number. We would
> like to do page reclaim in the reverse order, to keep allocated pages
> within
> a minimal number of regions (approximately).
>
> ---------------------------- Increasing region
> number---------------------->
>
> Direction of allocation--->                         <---Direction of
> reclaim
>
> Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
> ---
>
>  mm/page_alloc.c |  128
> +++++++++++++++++++++++++++++++++++++++++++++++++------
>  1 file changed, 113 insertions(+), 15 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 62d0a9a..52ff914 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -502,6 +502,79 @@ static inline int page_is_buddy(struct page *page,
> struct page *buddy,
>         return 0;
>  }
>
> +static void add_to_freelist(struct page *page, struct list_head *lru,
> +                           struct free_list *free_list)
> +{
> +       struct mem_region_list *region;
> +       struct list_head *prev_region_list;
> +       int region_id, i;
> +
> +       region_id = page_zone_region_id(page);
> +
> +       region = &free_list->mr_list[region_id];
> +       region->nr_free++;
> +
> +       if (region->page_block) {
> +               list_add_tail(lru, region->page_block);
> +               return;
> +       }
> +
> +       if (!list_empty(&free_list->list)) {
> +               for (i = region_id - 1; i >= 0; i--) {
> +                       if (free_list->mr_list[i].page_block) {
> +                               prev_region_list =
> +                                       free_list->mr_list[i].page_block;
> +                               goto out;
> +                       }
> +               }
> +       }
> +
> +       /* This is the first region, so add to the head of the list */
> +       prev_region_list = &free_list->list;
> +
> +out:
> +       list_add(lru, prev_region_list);
> +
> +       /* Save pointer to page block of this region */
> +       region->page_block = lru;
> +}
> +
> +static void del_from_freelist(struct page *page, struct list_head *lru,
> +                             struct free_list *free_list)
> +{
> +       struct mem_region_list *region;
> +       struct list_head *prev_page_lru;
> +       int region_id;
> +
> +       region_id = page_zone_region_id(page);
> +       region = &free_list->mr_list[region_id];
> +       region->nr_free--;
> +
> +       if (lru != region->page_block) {
> +               list_del(lru);
> +               return;
> +       }
> +
> +       prev_page_lru = lru->prev;
> +       list_del(lru);
> +
> +       if (region->nr_free == 0)
> +               region->page_block = NULL;
> +       else
> +               region->page_block = prev_page_lru;
> +}
> +
> +/**
> + * Move pages of a given order from freelist of one migrate-type to
> another.
> + */
> +static void move_pages_freelist(struct page *page, struct list_head *lru,
> +                               struct free_list *old_list,
> +                               struct free_list *new_list)
> +{
> +       del_from_freelist(page, lru, old_list);
> +       add_to_freelist(page, lru, new_list);
> +}
> +
>  /*
>   * Freeing function for a buddy system allocator.
>   *
> @@ -534,6 +607,7 @@ static inline void __free_one_page(struct page *page,
>         unsigned long combined_idx;
>         unsigned long uninitialized_var(buddy_idx);
>         struct page *buddy;
> +       struct free_area *area;
>
>         if (unlikely(PageCompound(page)))
>                 if (unlikely(destroy_compound_page(page, order)))
> @@ -561,8 +635,10 @@ static inline void __free_one_page(struct page *page,
>                         __mod_zone_freepage_state(zone, 1 << order,
>                                                   migratetype);
>                 } else {
> -                       list_del(&buddy->lru);
> -                       zone->free_area[order].nr_free--;
> +                       area = &zone->free_area[order];
> +                       del_from_freelist(buddy, &buddy->lru,
> +                                         &area->free_list[migratetype]);
> +                       area->nr_free--;
>                         rmv_page_order(buddy);
>                 }
>                 combined_idx = buddy_idx & page_idx;
> @@ -587,14 +663,23 @@ static inline void __free_one_page(struct page *page,
>                 buddy_idx = __find_buddy_index(combined_idx, order + 1);
>                 higher_buddy = higher_page + (buddy_idx - combined_idx);
>                 if (page_is_buddy(higher_page, higher_buddy, order + 1)) {
> -                       list_add_tail(&page->lru,
> -
> &zone->free_area[order].free_list[migratetype].list);
> +
> +                       /*
> +                        * Implementing an add_to_freelist_tail() won't be
> +                        * very useful because both of them (almost) add to
> +                        * the tail within the region. So we could
> potentially
> +                        * switch off this entire "is next-higher buddy
> free?"
> +                        * logic when memory regions are used.
> +                        */
> +                       area = &zone->free_area[order];
> +                       add_to_freelist(page, &page->lru,
> +                                       &area->free_list[migratetype]);
>                         goto out;
>                 }
>         }
>
> -       list_add(&page->lru,
> -               &zone->free_area[order].free_list[migratetype].list);
> +       add_to_freelist(page, &page->lru,
> +                       &zone->free_area[order].free_list[migratetype]);
>  out:
>         zone->free_area[order].nr_free++;
>  }
> @@ -812,7 +897,8 @@ static inline void expand(struct zone *zone, struct
> page *page,
>                         continue;
>                 }
>  #endif
> -               list_add(&page[size].lru,
> &area->free_list[migratetype].list);
> +               add_to_freelist(&page[size], &page[size].lru,
> +                                       &area->free_list[migratetype]);
>                 area->nr_free++;
>                 set_page_order(&page[size], high);
>         }
> @@ -879,7 +965,8 @@ struct page *__rmqueue_smallest(struct zone *zone,
> unsigned int order,
>
>                 page = list_entry(area->free_list[migratetype].list.next,
>                                                         struct page, lru);
> -               list_del(&page->lru);
> +               del_from_freelist(page, &page->lru,
> +                                 &area->free_list[migratetype]);
>                 rmv_page_order(page);
>                 area->nr_free--;
>                 expand(zone, page, order, current_order, area,
> migratetype);
> @@ -918,7 +1005,8 @@ int move_freepages(struct zone *zone,
>  {
>         struct page *page;
>         unsigned long order;
> -       int pages_moved = 0;
> +       struct free_area *area;
> +       int pages_moved = 0, old_mt;
>
>  #ifndef CONFIG_HOLES_IN_ZONE
>         /*
> @@ -946,8 +1034,11 @@ int move_freepages(struct zone *zone,
>                 }
>
>                 order = page_order(page);
> -               list_move(&page->lru,
> -
> &zone->free_area[order].free_list[migratetype].list);
> +               old_mt = get_freepage_migratetype(page);
> +               area = &zone->free_area[order];
> +               move_pages_freelist(page, &page->lru,
> +                                   &area->free_list[old_mt],
> +                                   &area->free_list[migratetype]);
>                 set_freepage_migratetype(page, migratetype);
>                 page += 1 << order;
>                 pages_moved += 1 << order;
> @@ -1045,7 +1136,8 @@ __rmqueue_fallback(struct zone *zone, int order, int
> start_migratetype)
>                         }
>
>                         /* Remove the page from the freelists */
> -                       list_del(&page->lru);
> +                       del_from_freelist(page, &page->lru,
> +                                         &area->free_list[migratetype]);
>                         rmv_page_order(page);
>
>                         /* Take ownership for orders >= pageblock_order */
> @@ -1399,12 +1491,14 @@ int capture_free_page(struct page *page, int
> alloc_order, int migratetype)
>         if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
>                 return 0;
>
> +       mt = get_pageblock_migratetype(page);
> +
>         /* Remove page from free list */
> -       list_del(&page->lru);
> +       del_from_freelist(page, &page->lru,
> +                         &zone->free_area[order].free_list[mt]);
>         zone->free_area[order].nr_free--;
>         rmv_page_order(page);
>
> -       mt = get_pageblock_migratetype(page);
>         if (unlikely(mt != MIGRATE_ISOLATE))
>                 __mod_zone_freepage_state(zone, -(1UL << order), mt);
>
> @@ -6040,6 +6134,8 @@ __offline_isolated_pages(unsigned long start_pfn,
> unsigned long end_pfn)
>         int order, i;
>         unsigned long pfn;
>         unsigned long flags;
> +       int mt;
> +
>         /* find the first valid pfn */
>         for (pfn = start_pfn; pfn < end_pfn; pfn++)
>                 if (pfn_valid(pfn))
> @@ -6062,7 +6158,9 @@ __offline_isolated_pages(unsigned long start_pfn,
> unsigned long end_pfn)
>                 printk(KERN_INFO "remove from free list %lx %d %lx\n",
>                        pfn, 1 << order, end_pfn);
>  #endif
> -               list_del(&page->lru);
> +               mt = get_freepage_migratetype(page);
> +               del_from_freelist(page, &page->lru,
> +                                 &zone->free_area[order].free_list[mt]);
>                 rmv_page_order(page);
>                 zone->free_area[order].nr_free--;
>                 __mod_zone_page_state(zone, NR_FREE_PAGES,
>
>


-- 
Regards,
Ankita
Graduate Student
Department of Computer Science
University of Texas at Austin

--14dae9cc92a49e788d04ce09ae57
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hi Srivatsa,<div><br></div><div>I understand that you are maintaining the p=
age blocks in region sorted order. So that way, when the memory requests co=
me in, you can hand out memory from the regions in that order. However, do =
you take this scenario into account - in some bucket of the buddy allocator=
, there might not be any pages belonging to, lets say, region 0, while the =
next higher bucket has them. So, instead of handing out memory from whichev=
er region thats present there, to probably go to the next bucket and split =
that region 0 pageblock there and allocate from it ? (Here, region 0 is jus=
t an example). Been a while since I looked at kernel code, so I might be mi=
ssing something!</div>

<div><br></div><div>Regards,</div><div>Ankita</div><div class=3D"gmail_extr=
a"><br><br><div class=3D"gmail_quote">On Tue, Nov 6, 2012 at 1:53 PM, Sriva=
tsa S. Bhat <span dir=3D"ltr">&lt;<a href=3D"mailto:srivatsa.bhat@linux.vne=
t.ibm.com" target=3D"_blank">srivatsa.bhat@linux.vnet.ibm.com</a>&gt;</span=
> wrote:<br>

<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">The zones&#39; freelists need to be made reg=
ion-aware, in order to influence<br>
page allocation and freeing algorithms. So in every free list in the zone, =
we<br>
would like to demarcate the pageblocks belonging to different memory region=
s<br>
(we can do this using a set of pointers, and thus avoid splitting up the<br=
>
freelists).<br>
<br>
Also, we would like to keep the pageblocks in the freelists sorted in<br>
region-order. That is, pageblocks belonging to region-0 would come first,<b=
r>
followed by pageblocks belonging to region-1 and so on, within a given<br>
freelist. Of course, a set of pageblocks belonging to the same region need<=
br>
not be sorted; it is sufficient if we maintain the pageblocks in<br>
region-sorted-order, rather than a full address-sorted-order.<br>
<br>
For each freelist within the zone, we maintain a set of pointers to<br>
pageblocks belonging to the various memory regions in that zone.<br>
<br>
Eg:<br>
<br>
=A0 =A0 |&lt;---Region0---&gt;| =A0 |&lt;---Region1---&gt;| =A0 |&lt;------=
-Region2---------&gt;|<br>
=A0 =A0 =A0____ =A0 =A0 =A0____ =A0 =A0 =A0____ =A0 =A0 =A0____ =A0 =A0 =A0=
____ =A0 =A0 =A0____ =A0 =A0 =A0____<br>
--&gt; |____|--&gt; |____|--&gt; |____|--&gt; |____|--&gt; |____|--&gt; |__=
__|--&gt; |____|--&gt;<br>
<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0^ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0^ =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0^<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0|<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 Reg0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 Reg1 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Reg2<br>
<br>
<br>
Page allocation will proceed as usual - pick the first item on the free lis=
t.<br>
But we don&#39;t want to keep updating these region pointers every time we =
allocate<br>
a pageblock from the freelist. So, instead of pointing to the *first* pageb=
lock<br>
of that region, we maintain the region pointers such that they point to the=
<br>
*last* pageblock in that region, as shown in the figure above. That way, as=
<br>
long as there are &gt; 1 pageblocks in that region in that freelist, that r=
egion<br>
pointer doesn&#39;t need to be updated.<br>
<br>
<br>
Page allocation algorithm:<br>
-------------------------<br>
<br>
The heart of the page allocation algorithm remains it is - pick the first<b=
r>
item on the appropriate freelist and return it.<br>
<br>
<br>
Pageblock order in the zone freelists:<br>
-------------------------------------<br>
<br>
This is the main change - we keep the pageblocks in region-sorted order,<br=
>
where pageblocks belonging to region-0 come first, followed by those belong=
ing<br>
to region-1 and so on. But the pageblocks within a given region need *not* =
be<br>
sorted, since we need them to be only region-sorted and not fully<br>
address-sorted.<br>
<br>
This sorting is performed when adding pages back to the freelists, thus<br>
avoiding any region-related overhead in the critical page allocation<br>
paths.<br>
<br>
Page reclaim [Todo]:<br>
--------------------<br>
<br>
Page allocation happens in the order of increasing region number. We would<=
br>
like to do page reclaim in the reverse order, to keep allocated pages withi=
n<br>
a minimal number of regions (approximately).<br>
<br>
---------------------------- Increasing region number----------------------=
&gt;<br>
<br>
Direction of allocation---&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 &lt;---Direction of reclaim<br>
<br>
Signed-off-by: Srivatsa S. Bhat &lt;<a href=3D"mailto:srivatsa.bhat@linux.v=
net.ibm.com">srivatsa.bhat@linux.vnet.ibm.com</a>&gt;<br>
---<br>
<br>
=A0mm/page_alloc.c | =A0128 +++++++++++++++++++++++++++++++++++++++++++++++=
++------<br>
=A01 file changed, 113 insertions(+), 15 deletions(-)<br>
<br>
diff --git a/mm/page_alloc.c b/mm/page_alloc.c<br>
index 62d0a9a..52ff914 100644<br>
--- a/mm/page_alloc.c<br>
+++ b/mm/page_alloc.c<br>
@@ -502,6 +502,79 @@ static inline int page_is_buddy(struct page *page, str=
uct page *buddy,<br>
=A0 =A0 =A0 =A0 return 0;<br>
=A0}<br>
<br>
+static void add_to_freelist(struct page *page, struct list_head *lru,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct free_list *fre=
e_list)<br>
+{<br>
+ =A0 =A0 =A0 struct mem_region_list *region;<br>
+ =A0 =A0 =A0 struct list_head *prev_region_list;<br>
+ =A0 =A0 =A0 int region_id, i;<br>
+<br>
+ =A0 =A0 =A0 region_id =3D page_zone_region_id(page);<br>
+<br>
+ =A0 =A0 =A0 region =3D &amp;free_list-&gt;mr_list[region_id];<br>
+ =A0 =A0 =A0 region-&gt;nr_free++;<br>
+<br>
+ =A0 =A0 =A0 if (region-&gt;page_block) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_add_tail(lru, region-&gt;page_block);<br=
>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
+ =A0 =A0 =A0 }<br>
+<br>
+ =A0 =A0 =A0 if (!list_empty(&amp;free_list-&gt;list)) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (i =3D region_id - 1; i &gt;=3D 0; i--) {=
<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (free_list-&gt;mr_list[i].=
page_block) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 prev_region_l=
ist =3D<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 free_list-&gt;mr_list[i].page_block;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
+ =A0 =A0 =A0 }<br>
+<br>
+ =A0 =A0 =A0 /* This is the first region, so add to the head of the list *=
/<br>
+ =A0 =A0 =A0 prev_region_list =3D &amp;free_list-&gt;list;<br>
+<br>
+out:<br>
+ =A0 =A0 =A0 list_add(lru, prev_region_list);<br>
+<br>
+ =A0 =A0 =A0 /* Save pointer to page block of this region */<br>
+ =A0 =A0 =A0 region-&gt;page_block =3D lru;<br>
+}<br>
+<br>
+static void del_from_freelist(struct page *page, struct list_head *lru,<br=
>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct free_list =
*free_list)<br>
+{<br>
+ =A0 =A0 =A0 struct mem_region_list *region;<br>
+ =A0 =A0 =A0 struct list_head *prev_page_lru;<br>
+ =A0 =A0 =A0 int region_id;<br>
+<br>
+ =A0 =A0 =A0 region_id =3D page_zone_region_id(page);<br>
+ =A0 =A0 =A0 region =3D &amp;free_list-&gt;mr_list[region_id];<br>
+ =A0 =A0 =A0 region-&gt;nr_free--;<br>
+<br>
+ =A0 =A0 =A0 if (lru !=3D region-&gt;page_block) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del(lru);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
+ =A0 =A0 =A0 }<br>
+<br>
+ =A0 =A0 =A0 prev_page_lru =3D lru-&gt;prev;<br>
+ =A0 =A0 =A0 list_del(lru);<br>
+<br>
+ =A0 =A0 =A0 if (region-&gt;nr_free =3D=3D 0)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 region-&gt;page_block =3D NULL;<br>
+ =A0 =A0 =A0 else<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 region-&gt;page_block =3D prev_page_lru;<br>
+}<br>
+<br>
+/**<br>
+ * Move pages of a given order from freelist of one migrate-type to anothe=
r.<br>
+ */<br>
+static void move_pages_freelist(struct page *page, struct list_head *lru,<=
br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct free_l=
ist *old_list,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct free_l=
ist *new_list)<br>
+{<br>
+ =A0 =A0 =A0 del_from_freelist(page, lru, old_list);<br>
+ =A0 =A0 =A0 add_to_freelist(page, lru, new_list);<br>
+}<br>
+<br>
=A0/*<br>
=A0 * Freeing function for a buddy system allocator.<br>
=A0 *<br>
@@ -534,6 +607,7 @@ static inline void __free_one_page(struct page *page,<b=
r>
=A0 =A0 =A0 =A0 unsigned long combined_idx;<br>
=A0 =A0 =A0 =A0 unsigned long uninitialized_var(buddy_idx);<br>
=A0 =A0 =A0 =A0 struct page *buddy;<br>
+ =A0 =A0 =A0 struct free_area *area;<br>
<br>
=A0 =A0 =A0 =A0 if (unlikely(PageCompound(page)))<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(destroy_compound_page(page, or=
der)))<br>
@@ -561,8 +635,10 @@ static inline void __free_one_page(struct page *page,<=
br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __mod_zone_freepage_state(z=
one, 1 &lt;&lt; order,<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 migratetype);<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del(&amp;buddy-&gt;lru);=
<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone-&gt;free_area[order].nr_=
free--;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 area =3D &amp;zone-&gt;free_a=
rea[order];<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 del_from_freelist(buddy, &amp=
;buddy-&gt;lru,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 &amp;area-&gt;free_list[migratetype]);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 area-&gt;nr_free--;<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rmv_page_order(buddy);<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 combined_idx =3D buddy_idx &amp; page_idx;<=
br>
@@ -587,14 +663,23 @@ static inline void __free_one_page(struct page *page,=
<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 buddy_idx =3D __find_buddy_index(combined_i=
dx, order + 1);<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 higher_buddy =3D higher_page + (buddy_idx -=
 combined_idx);<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (page_is_buddy(higher_page, higher_buddy=
, order + 1)) {<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_add_tail(&amp;page-&gt;l=
ru,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &amp;zone-&gt=
;free_area[order].free_list[migratetype].list);<br>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Implementing an add_to_f=
reelist_tail() won&#39;t be<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* very useful because both=
 of them (almost) add to<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* the tail within the regi=
on. So we could potentially<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* switch off this entire &=
quot;is next-higher buddy free?&quot;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* logic when memory region=
s are used.<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 area =3D &amp;zone-&gt;free_a=
rea[order];<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 add_to_freelist(page, &amp;pa=
ge-&gt;lru,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 &amp;area-&gt;free_list[migratetype]);<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
=A0 =A0 =A0 =A0 }<br>
<br>
- =A0 =A0 =A0 list_add(&amp;page-&gt;lru,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 &amp;zone-&gt;free_area[order].free_list[migr=
atetype].list);<br>
+ =A0 =A0 =A0 add_to_freelist(page, &amp;page-&gt;lru,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &amp;zone-&gt;free_area[order=
].free_list[migratetype]);<br>
=A0out:<br>
=A0 =A0 =A0 =A0 zone-&gt;free_area[order].nr_free++;<br>
=A0}<br>
@@ -812,7 +897,8 @@ static inline void expand(struct zone *zone, struct pag=
e *page,<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
=A0#endif<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_add(&amp;page[size].lru, &amp;area-&gt;f=
ree_list[migratetype].list);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 add_to_freelist(&amp;page[size], &amp;page[si=
ze].lru,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 &amp;area-&gt;free_list[migratetype]);<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 area-&gt;nr_free++;<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_page_order(&amp;page[size], high);<br>
=A0 =A0 =A0 =A0 }<br>
@@ -879,7 +965,8 @@ struct page *__rmqueue_smallest(struct zone *zone, unsi=
gned int order,<br>
<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 page =3D list_entry(area-&gt;free_list[migr=
atetype].list.next,<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct page, lru);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del(&amp;page-&gt;lru);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 del_from_freelist(page, &amp;page-&gt;lru,<br=
>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &amp;area=
-&gt;free_list[migratetype]);<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rmv_page_order(page);<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 area-&gt;nr_free--;<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 expand(zone, page, order, current_order, ar=
ea, migratetype);<br>
@@ -918,7 +1005,8 @@ int move_freepages(struct zone *zone,<br>
=A0{<br>
=A0 =A0 =A0 =A0 struct page *page;<br>
=A0 =A0 =A0 =A0 unsigned long order;<br>
- =A0 =A0 =A0 int pages_moved =3D 0;<br>
+ =A0 =A0 =A0 struct free_area *area;<br>
+ =A0 =A0 =A0 int pages_moved =3D 0, old_mt;<br>
<br>
=A0#ifndef CONFIG_HOLES_IN_ZONE<br>
=A0 =A0 =A0 =A0 /*<br>
@@ -946,8 +1034,11 @@ int move_freepages(struct zone *zone,<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 order =3D page_order(page);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move(&amp;page-&gt;lru,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &amp;zone-&gt;free_area[o=
rder].free_list[migratetype].list);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 old_mt =3D get_freepage_migratetype(page);<br=
>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 area =3D &amp;zone-&gt;free_area[order];<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 move_pages_freelist(page, &amp;page-&gt;lru,<=
br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &amp;=
area-&gt;free_list[old_mt],<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &amp;=
area-&gt;free_list[migratetype]);<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_freepage_migratetype(page, migratetype)=
;<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 page +=3D 1 &lt;&lt; order;<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pages_moved +=3D 1 &lt;&lt; order;<br>
@@ -1045,7 +1136,8 @@ __rmqueue_fallback(struct zone *zone, int order, int =
start_migratetype)<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Remove the page from the=
 freelists */<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del(&amp;page-&gt;lru);<=
br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 del_from_freelist(page, &amp;=
page-&gt;lru,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 &amp;area-&gt;free_list[migratetype]);<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rmv_page_order(page);<br>
<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Take ownership for order=
s &gt;=3D pageblock_order */<br>
@@ -1399,12 +1491,14 @@ int capture_free_page(struct page *page, int alloc_=
order, int migratetype)<br>
=A0 =A0 =A0 =A0 if (!zone_watermark_ok(zone, 0, watermark, 0, 0))<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;<br>
<br>
+ =A0 =A0 =A0 mt =3D get_pageblock_migratetype(page);<br>
+<br>
=A0 =A0 =A0 =A0 /* Remove page from free list */<br>
- =A0 =A0 =A0 list_del(&amp;page-&gt;lru);<br>
+ =A0 =A0 =A0 del_from_freelist(page, &amp;page-&gt;lru,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &amp;zone-&gt;free_area[o=
rder].free_list[mt]);<br>
=A0 =A0 =A0 =A0 zone-&gt;free_area[order].nr_free--;<br>
=A0 =A0 =A0 =A0 rmv_page_order(page);<br>
<br>
- =A0 =A0 =A0 mt =3D get_pageblock_migratetype(page);<br>
=A0 =A0 =A0 =A0 if (unlikely(mt !=3D MIGRATE_ISOLATE))<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __mod_zone_freepage_state(zone, -(1UL &lt;&=
lt; order), mt);<br>
<br>
@@ -6040,6 +6134,8 @@ __offline_isolated_pages(unsigned long start_pfn, uns=
igned long end_pfn)<br>
=A0 =A0 =A0 =A0 int order, i;<br>
=A0 =A0 =A0 =A0 unsigned long pfn;<br>
=A0 =A0 =A0 =A0 unsigned long flags;<br>
+ =A0 =A0 =A0 int mt;<br>
+<br>
=A0 =A0 =A0 =A0 /* find the first valid pfn */<br>
=A0 =A0 =A0 =A0 for (pfn =3D start_pfn; pfn &lt; end_pfn; pfn++)<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pfn_valid(pfn))<br>
@@ -6062,7 +6158,9 @@ __offline_isolated_pages(unsigned long start_pfn, uns=
igned long end_pfn)<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_INFO &quot;remove from free lis=
t %lx %d %lx\n&quot;,<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pfn, 1 &lt;&lt; order, end_p=
fn);<br>
=A0#endif<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del(&amp;page-&gt;lru);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 mt =3D get_freepage_migratetype(page);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 del_from_freelist(page, &amp;page-&gt;lru,<br=
>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &amp;zone=
-&gt;free_area[order].free_list[mt]);<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rmv_page_order(page);<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone-&gt;free_area[order].nr_free--;<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __mod_zone_page_state(zone, NR_FREE_PAGES,<=
br>
<br>
</blockquote></div><br><br clear=3D"all"><div><br></div>-- <br>Regards,<br>=
Ankita<div>Graduate Student</div><div>Department of Computer Science</div><=
div>University of Texas at Austin<br><br></div><br>
</div>

--14dae9cc92a49e788d04ce09ae57--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
