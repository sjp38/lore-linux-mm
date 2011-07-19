Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1DF036B00F4
	for <linux-mm@kvack.org>; Tue, 19 Jul 2011 18:47:48 -0400 (EDT)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id p6JMliA9022751
	for <linux-mm@kvack.org>; Tue, 19 Jul 2011 15:47:44 -0700
Received: from qwi4 (qwi4.prod.google.com [10.241.195.4])
	by kpbe17.cbf.corp.google.com with ESMTP id p6JMlXat008565
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 19 Jul 2011 15:47:43 -0700
Received: by qwi4 with SMTP id 4so2479902qwi.15
        for <linux-mm@kvack.org>; Tue, 19 Jul 2011 15:47:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1306909519-7286-8-git-send-email-hannes@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
	<1306909519-7286-8-git-send-email-hannes@cmpxchg.org>
Date: Tue, 19 Jul 2011 15:47:43 -0700
Message-ID: <CALWz4iwDGD8xoUbzi=9Sy7C-njcYqmka_25rQL8RhkN_ArLgDw@mail.gmail.com>
Subject: Re: [patch 7/8] vmscan: memcg-aware unevictable page rescue scanner
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=0016361e81425c0d7104a873e715
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--0016361e81425c0d7104a873e715
Content-Type: text/plain; charset=ISO-8859-1

On Tue, May 31, 2011 at 11:25 PM, Johannes Weiner <hannes@cmpxchg.org>wrote:

> Once the per-memcg lru lists are exclusive, the unevictable page
> rescue scanner can no longer work on the global zone lru lists.
>
> This converts it to go through all memcgs and scan their respective
> unevictable lists instead.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  include/linux/memcontrol.h |    2 +
>  mm/memcontrol.c            |   11 +++++++++
>  mm/vmscan.c                |   53
> +++++++++++++++++++++++++++----------------
>  3 files changed, 46 insertions(+), 20 deletions(-)
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index cb02c00..56c1def 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -60,6 +60,8 @@ extern void mem_cgroup_cancel_charge_swapin(struct
> mem_cgroup *ptr);
>
>  extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct
> *mm,
>                                        gfp_t gfp_mask);
> +struct page *mem_cgroup_lru_to_page(struct zone *, struct mem_cgroup *,
> +                                   enum lru_list);
>

Did we miss a #ifdef case for this function? I got compile error by
disabling memcg.

--Ying


> extern void mem_cgroup_add_lru_list(struct page *page, enum lru_list lru);
>  extern void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru);
>  extern void mem_cgroup_rotate_reclaimable_page(struct page *page);
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 78ae4dd..d9d1a7e 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -656,6 +656,17 @@ static inline bool mem_cgroup_is_root(struct
> mem_cgroup *mem)
>  * When moving account, the page is not on LRU. It's isolated.
>  */
>
> +struct page *mem_cgroup_lru_to_page(struct zone *zone, struct mem_cgroup
> *mem,
> +                                   enum lru_list lru)
> +{
> +       struct mem_cgroup_per_zone *mz;
> +       struct page_cgroup *pc;
> +
> +       mz = mem_cgroup_zoneinfo(mem, zone_to_nid(zone), zone_idx(zone));
> +       pc = list_entry(mz->lists[lru].prev, struct page_cgroup, lru);
> +       return lookup_cgroup_page(pc);
> +}
> +
>  void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru)
>  {
>        struct page_cgroup *pc;
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 9c51ec8..23fd2b1 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -3233,6 +3233,14 @@ void scan_mapping_unevictable_pages(struct
> address_space *mapping)
>
>  }
>
> +static struct page *lru_tailpage(struct zone *zone, struct mem_cgroup
> *mem,
> +                                enum lru_list lru)
> +{
> +       if (mem)
> +               return mem_cgroup_lru_to_page(zone, mem, lru);
> +       return lru_to_page(&zone->lru[lru].list);
> +}
> +
>  /**
>  * scan_zone_unevictable_pages - check unevictable list for evictable pages
>  * @zone - zone of which to scan the unevictable list
> @@ -3246,32 +3254,37 @@ void scan_mapping_unevictable_pages(struct
> address_space *mapping)
>  #define SCAN_UNEVICTABLE_BATCH_SIZE 16UL /* arbitrary lock hold batch size
> */
>  static void scan_zone_unevictable_pages(struct zone *zone)
>  {
> -       struct list_head *l_unevictable = &zone->lru[LRU_UNEVICTABLE].list;
> -       unsigned long scan;
> -       unsigned long nr_to_scan = zone_page_state(zone, NR_UNEVICTABLE);
> +       struct mem_cgroup *first, *mem = NULL;
>
> -       while (nr_to_scan > 0) {
> -               unsigned long batch_size = min(nr_to_scan,
> -
> SCAN_UNEVICTABLE_BATCH_SIZE);
> +       first = mem = mem_cgroup_hierarchy_walk(NULL, mem);
> +       do {
> +               unsigned long nr_to_scan;
>
> -               spin_lock_irq(&zone->lru_lock);
> -               for (scan = 0;  scan < batch_size; scan++) {
> -                       struct page *page = lru_to_page(l_unevictable);
> +               nr_to_scan = zone_nr_lru_pages(zone, mem, LRU_UNEVICTABLE);
> +               while (nr_to_scan > 0) {
> +                       unsigned long batch_size;
> +                       unsigned long scan;
>
> -                       if (!trylock_page(page))
> -                               continue;
> +                       batch_size = min(nr_to_scan,
> +                                        SCAN_UNEVICTABLE_BATCH_SIZE);
>
> -                       prefetchw_prev_lru_page(page, l_unevictable,
> flags);
> -
> -                       if (likely(PageLRU(page) && PageUnevictable(page)))
> -                               check_move_unevictable_page(page, zone);
> +                       spin_lock_irq(&zone->lru_lock);
> +                       for (scan = 0; scan < batch_size; scan++) {
> +                               struct page *page;
>
> -                       unlock_page(page);
> +                               page = lru_tailpage(zone, mem,
> LRU_UNEVICTABLE);
> +                               if (!trylock_page(page))
> +                                       continue;
> +                               if (likely(PageLRU(page) &&
> +                                          PageUnevictable(page)))
> +                                       check_move_unevictable_page(page,
> zone);
> +                               unlock_page(page);
> +                       }
> +                       spin_unlock_irq(&zone->lru_lock);
> +                       nr_to_scan -= batch_size;
>                }
> -               spin_unlock_irq(&zone->lru_lock);
> -
> -               nr_to_scan -= batch_size;
> -       }
> +               mem = mem_cgroup_hierarchy_walk(NULL, mem);
> +       } while (mem != first);
>  }
>
>
> --
> 1.7.5.2
>
>

--0016361e81425c0d7104a873e715
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Tue, May 31, 2011 at 11:25 PM, Johann=
es Weiner <span dir=3D"ltr">&lt;<a href=3D"mailto:hannes@cmpxchg.org" targe=
t=3D"_blank">hannes@cmpxchg.org</a>&gt;</span> wrote:<br><blockquote class=
=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padd=
ing-left:1ex">

Once the per-memcg lru lists are exclusive, the unevictable page<br>
rescue scanner can no longer work on the global zone lru lists.<br>
<br>
This converts it to go through all memcgs and scan their respective<br>
unevictable lists instead.<br>
<br>
Signed-off-by: Johannes Weiner &lt;<a href=3D"mailto:hannes@cmpxchg.org" ta=
rget=3D"_blank">hannes@cmpxchg.org</a>&gt;<br>
---<br>
=A0include/linux/memcontrol.h | =A0 =A02 +<br>
=A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 11 +++++++++<br>
=A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 53 ++++++++++++++++++++=
+++++++----------------<br>
=A03 files changed, 46 insertions(+), 20 deletions(-)<br>
<br>
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h<br>
index cb02c00..56c1def 100644<br>
--- a/include/linux/memcontrol.h<br>
+++ b/include/linux/memcontrol.h<br>
@@ -60,6 +60,8 @@ extern void mem_cgroup_cancel_charge_swapin(struct mem_cg=
roup *ptr);<br>
<br>
=A0extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct *=
mm,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0gfp_t gfp_mask);<br>
+struct page *mem_cgroup_lru_to_page(struct zone *, struct mem_cgroup *,<br=
>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum =
lru_list);<br>
=A0</blockquote><div>Did we miss a #ifdef case for this function? I got com=
pile error by disabling memcg.</div><div><br></div><div>--Ying</div><div>=
=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;borde=
r-left:1px #ccc solid;padding-left:1ex">

extern void mem_cgroup_add_lru_list(struct page *page, enum lru_list lru);<=
br>
=A0extern void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru=
);<br>
=A0extern void mem_cgroup_rotate_reclaimable_page(struct page *page);<br>
diff --git a/mm/memcontrol.c b/mm/memcontrol.c<br>
index 78ae4dd..d9d1a7e 100644<br>
--- a/mm/memcontrol.c<br>
+++ b/mm/memcontrol.c<br>
@@ -656,6 +656,17 @@ static inline bool mem_cgroup_is_root(struct mem_cgrou=
p *mem)<br>
 =A0* When moving account, the page is not on LRU. It&#39;s isolated.<br>
 =A0*/<br>
<br>
+struct page *mem_cgroup_lru_to_page(struct zone *zone, struct mem_cgroup *=
mem,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum =
lru_list lru)<br>
+{<br>
+ =A0 =A0 =A0 struct mem_cgroup_per_zone *mz;<br>
+ =A0 =A0 =A0 struct page_cgroup *pc;<br>
+<br>
+ =A0 =A0 =A0 mz =3D mem_cgroup_zoneinfo(mem, zone_to_nid(zone), zone_idx(z=
one));<br>
+ =A0 =A0 =A0 pc =3D list_entry(mz-&gt;lists[lru].prev, struct page_cgroup,=
 lru);<br>
+ =A0 =A0 =A0 return lookup_cgroup_page(pc);<br>
+}<br>
+<br>
=A0void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru)<br>
=A0{<br>
 =A0 =A0 =A0 =A0struct page_cgroup *pc;<br>
diff --git a/mm/vmscan.c b/mm/vmscan.c<br>
index 9c51ec8..23fd2b1 100644<br>
--- a/mm/vmscan.c<br>
+++ b/mm/vmscan.c<br>
@@ -3233,6 +3233,14 @@ void scan_mapping_unevictable_pages(struct address_s=
pace *mapping)<br>
<br>
=A0}<br>
<br>
+static struct page *lru_tailpage(struct zone *zone, struct mem_cgroup *mem=
,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enum lru_l=
ist lru)<br>
+{<br>
+ =A0 =A0 =A0 if (mem)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return mem_cgroup_lru_to_page(zone, mem, lru)=
;<br>
+ =A0 =A0 =A0 return lru_to_page(&amp;zone-&gt;lru[lru].list);<br>
+}<br>
+<br>
=A0/**<br>
 =A0* scan_zone_unevictable_pages - check unevictable list for evictable pa=
ges<br>
 =A0* @zone - zone of which to scan the unevictable list<br>
@@ -3246,32 +3254,37 @@ void scan_mapping_unevictable_pages(struct address_=
space *mapping)<br>
=A0#define SCAN_UNEVICTABLE_BATCH_SIZE 16UL /* arbitrary lock hold batch si=
ze */<br>
=A0static void scan_zone_unevictable_pages(struct zone *zone)<br>
=A0{<br>
- =A0 =A0 =A0 struct list_head *l_unevictable =3D &amp;zone-&gt;lru[LRU_UNE=
VICTABLE].list;<br>
- =A0 =A0 =A0 unsigned long scan;<br>
- =A0 =A0 =A0 unsigned long nr_to_scan =3D zone_page_state(zone, NR_UNEVICT=
ABLE);<br>
+ =A0 =A0 =A0 struct mem_cgroup *first, *mem =3D NULL;<br>
<br>
- =A0 =A0 =A0 while (nr_to_scan &gt; 0) {<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long batch_size =3D min(nr_to_scan,<=
br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 SCAN_UNEVICTABLE_BATCH_SIZE);<br>
+ =A0 =A0 =A0 first =3D mem =3D mem_cgroup_hierarchy_walk(NULL, mem);<br>
+ =A0 =A0 =A0 do {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long nr_to_scan;<br>
<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_irq(&amp;zone-&gt;lru_lock);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (scan =3D 0; =A0scan &lt; batch_size; sca=
n++) {<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct page *page =3D lru_to_=
page(l_unevictable);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_to_scan =3D zone_nr_lru_pages(zone, mem, L=
RU_UNEVICTABLE);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 while (nr_to_scan &gt; 0) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long batch_size;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long scan;<br>
<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!trylock_page(page))<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 batch_size =3D min(nr_to_scan=
,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0SCAN_UNEVICTABLE_BATCH_SIZE);<br>
<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 prefetchw_prev_lru_page(page,=
 l_unevictable, flags);<br>
-<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (likely(PageLRU(page) &amp=
;&amp; PageUnevictable(page)))<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 check_move_un=
evictable_page(page, zone);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_irq(&amp;zone-&gt;l=
ru_lock);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (scan =3D 0; scan &lt; ba=
tch_size; scan++) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct page *=
page;<br>
<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unlock_page(page);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 page =3D lru_=
tailpage(zone, mem, LRU_UNEVICTABLE);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!trylock_=
page(page))<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 continue;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (likely(Pa=
geLRU(page) &amp;&amp;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0PageUnevictable(page)))<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 check_move_unevictable_page(page, zone);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unlock_page(p=
age);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irq(&amp;zone-&gt=
;lru_lock);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_to_scan -=3D batch_size;<b=
r>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irq(&amp;zone-&gt;lru_lock);<br>
-<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_to_scan -=3D batch_size;<br>
- =A0 =A0 =A0 }<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem =3D mem_cgroup_hierarchy_walk(NULL, mem);=
<br>
+ =A0 =A0 =A0 } while (mem !=3D first);<br>
=A0}<br>
<font color=3D"#888888"><br>
<br>
--<br>
1.7.5.2<br>
<br>
</font></blockquote></div><br>

--0016361e81425c0d7104a873e715--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
