Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id D3B716B0034
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 17:10:11 -0400 (EDT)
Received: by mail-vb0-f46.google.com with SMTP id p13so1010735vbe.19
        for <linux-mm@kvack.org>; Tue, 06 Aug 2013 14:10:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CACz4_2f2frTktfUusWGcaqZtTmQS8FSY0HqwXCas44EW7Q5Xsw@mail.gmail.com>
References: <1375582645-29274-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1375582645-29274-21-git-send-email-kirill.shutemov@linux.intel.com> <CACz4_2f2frTktfUusWGcaqZtTmQS8FSY0HqwXCas44EW7Q5Xsw@mail.gmail.com>
From: Ning Qu <quning@google.com>
Date: Tue, 6 Aug 2013 14:09:49 -0700
Message-ID: <CACz4_2de=zm2-VtE=dFTfYjrdma4QFX1S-ukQ_7J4DZ32q1JQQ@mail.gmail.com>
Subject: Re: [PATCH 20/23] thp: handle file pages in split_huge_page()
Content-Type: multipart/alternative; boundary=001a11c3df4ea9a75604e34dd9a8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

--001a11c3df4ea9a75604e34dd9a8
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Is this safe to move the vma_adjust_trans_huge before the line 772? Seems
for anonymous memory, we only take the lock after vma_adjust_trans_huge,
maybe we should do the same for file?

Best wishes,
--=20
Ning Qu (=E6=9B=B2=E5=AE=81) | Software Engineer | quning@google.com | +1-4=
08-418-6066


On Tue, Aug 6, 2013 at 12:09 PM, Ning Qu <quning@google.com> wrote:

> I am probably running into a deadlock case for this patch.
>
> When splitting the file huge page, we hold the i_mmap_mutex.
>
> However, when coming from the call path in vma_adjust as following, we
> will grab the i_mmap_mutex already before doing vma_adjust_trans_huge,
> which will eventually calls the split_huge_page then split_file_huge_page
> ....
>
>
> https://git.kernel.org/cgit/linux/kernel/git/kas/linux.git/tree/mm/mmap.c=
?h=3Dthp/pagecache#n753
>
>
>
>
> Best wishes,
> --
> Ning Qu (=E6=9B=B2=E5=AE=81) | Software Engineer | quning@google.com | +1=
-408-418-6066
>
>
> On Sat, Aug 3, 2013 at 7:17 PM, Kirill A. Shutemov <
> kirill.shutemov@linux.intel.com> wrote:
>
>> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>>
>> The base scheme is the same as for anonymous pages, but we walk by
>> mapping->i_mmap rather then anon_vma->rb_root.
>>
>> When we add a huge page to page cache we take only reference to head
>> page, but on split we need to take addition reference to all tail pages
>> since they are still in page cache after splitting.
>>
>> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> ---
>>  mm/huge_memory.c | 89
>> +++++++++++++++++++++++++++++++++++++++++++++++---------
>>  1 file changed, 76 insertions(+), 13 deletions(-)
>>
>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>> index 523946c..d7c6830 100644
>> --- a/mm/huge_memory.c
>> +++ b/mm/huge_memory.c
>> @@ -1580,6 +1580,7 @@ static void __split_huge_page_refcount(struct page
>> *page,
>>         struct zone *zone =3D page_zone(page);
>>         struct lruvec *lruvec;
>>         int tail_count =3D 0;
>> +       int initial_tail_refcount;
>>
>>         /* prevent PageLRU to go away from under us, and freeze lru stat=
s
>> */
>>         spin_lock_irq(&zone->lru_lock);
>> @@ -1589,6 +1590,13 @@ static void __split_huge_page_refcount(struct pag=
e
>> *page,
>>         /* complete memcg works before add pages to LRU */
>>         mem_cgroup_split_huge_fixup(page);
>>
>> +       /*
>> +        * When we add a huge page to page cache we take only reference
>> to head
>> +        * page, but on split we need to take addition reference to all
>> tail
>> +        * pages since they are still in page cache after splitting.
>> +        */
>> +       initial_tail_refcount =3D PageAnon(page) ? 0 : 1;
>> +
>>         for (i =3D HPAGE_PMD_NR - 1; i >=3D 1; i--) {
>>                 struct page *page_tail =3D page + i;
>>
>> @@ -1611,8 +1619,9 @@ static void __split_huge_page_refcount(struct page
>> *page,
>>                  * atomic_set() here would be safe on all archs (and
>>                  * not only on x86), it's safer to use atomic_add().
>>                  */
>> -               atomic_add(page_mapcount(page) + page_mapcount(page_tail=
)
>> + 1,
>> -                          &page_tail->_count);
>> +               atomic_add(initial_tail_refcount + page_mapcount(page) +
>> +                               page_mapcount(page_tail) + 1,
>> +                               &page_tail->_count);
>>
>>                 /* after clearing PageTail the gup refcount can be
>> released */
>>                 smp_mb();
>> @@ -1651,23 +1660,23 @@ static void __split_huge_page_refcount(struct
>> page *page,
>>                 */
>>                 page_tail->_mapcount =3D page->_mapcount;
>>
>> -               BUG_ON(page_tail->mapping);
>>                 page_tail->mapping =3D page->mapping;
>>
>>                 page_tail->index =3D page->index + i;
>>                 page_nid_xchg_last(page_tail, page_nid_last(page));
>>
>> -               BUG_ON(!PageAnon(page_tail));
>>                 BUG_ON(!PageUptodate(page_tail));
>>                 BUG_ON(!PageDirty(page_tail));
>> -               BUG_ON(!PageSwapBacked(page_tail));
>>
>>                 lru_add_page_tail(page, page_tail, lruvec, list);
>>         }
>>         atomic_sub(tail_count, &page->_count);
>>         BUG_ON(atomic_read(&page->_count) <=3D 0);
>>
>> -       __mod_zone_page_state(zone, NR_ANON_TRANSPARENT_HUGEPAGES, -1);
>> +       if (PageAnon(page))
>> +               __mod_zone_page_state(zone,
>> NR_ANON_TRANSPARENT_HUGEPAGES, -1);
>> +       else
>> +               __mod_zone_page_state(zone,
>> NR_FILE_TRANSPARENT_HUGEPAGES, -1);
>>
>>         ClearPageCompound(page);
>>         compound_unlock(page);
>> @@ -1767,7 +1776,7 @@ static int __split_huge_page_map(struct page *page=
,
>>  }
>>
>>  /* must be called with anon_vma->root->rwsem held */
>> -static void __split_huge_page(struct page *page,
>> +static void __split_anon_huge_page(struct page *page,
>>                               struct anon_vma *anon_vma,
>>                               struct list_head *list)
>>  {
>> @@ -1791,7 +1800,7 @@ static void __split_huge_page(struct page *page,
>>          * and establishes a child pmd before
>>          * __split_huge_page_splitting() freezes the parent pmd (so if
>>          * we fail to prevent copy_huge_pmd() from running until the
>> -        * whole __split_huge_page() is complete), we will still see
>> +        * whole __split_anon_huge_page() is complete), we will still se=
e
>>          * the newly established pmd of the child later during the
>>          * walk, to be able to set it as pmd_trans_splitting too.
>>          */
>> @@ -1822,14 +1831,11 @@ static void __split_huge_page(struct page *page,
>>   * from the hugepage.
>>   * Return 0 if the hugepage is split successfully otherwise return 1.
>>   */
>> -int split_huge_page_to_list(struct page *page, struct list_head *list)
>> +static int split_anon_huge_page(struct page *page, struct list_head
>> *list)
>>  {
>>         struct anon_vma *anon_vma;
>>         int ret =3D 1;
>>
>> -       BUG_ON(is_huge_zero_page(page));
>> -       BUG_ON(!PageAnon(page));
>> -
>>         /*
>>          * The caller does not necessarily hold an mmap_sem that would
>> prevent
>>          * the anon_vma disappearing so we first we take a reference to =
it
>> @@ -1847,7 +1853,7 @@ int split_huge_page_to_list(struct page *page,
>> struct list_head *list)
>>                 goto out_unlock;
>>
>>         BUG_ON(!PageSwapBacked(page));
>> -       __split_huge_page(page, anon_vma, list);
>> +       __split_anon_huge_page(page, anon_vma, list);
>>         count_vm_event(THP_SPLIT);
>>
>>         BUG_ON(PageCompound(page));
>> @@ -1858,6 +1864,63 @@ out:
>>         return ret;
>>  }
>>
>> +static int split_file_huge_page(struct page *page, struct list_head
>> *list)
>> +{
>> +       struct address_space *mapping =3D page->mapping;
>> +       pgoff_t pgoff =3D page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT)=
;
>> +       struct vm_area_struct *vma;
>> +       int mapcount, mapcount2;
>> +
>> +       BUG_ON(!PageHead(page));
>> +       BUG_ON(PageTail(page));
>> +
>> +       mutex_lock(&mapping->i_mmap_mutex);
>> +       mapcount =3D 0;
>> +       vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
>> +               unsigned long addr =3D vma_address(page, vma);
>> +               mapcount +=3D __split_huge_page_splitting(page, vma, add=
r);
>> +       }
>> +
>> +       if (mapcount !=3D page_mapcount(page))
>> +               printk(KERN_ERR "mapcount %d page_mapcount %d\n",
>> +                      mapcount, page_mapcount(page));
>> +       BUG_ON(mapcount !=3D page_mapcount(page));
>> +
>> +       __split_huge_page_refcount(page, list);
>> +
>> +       mapcount2 =3D 0;
>> +       vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
>> +               unsigned long addr =3D vma_address(page, vma);
>> +               mapcount2 +=3D __split_huge_page_map(page, vma, addr);
>> +       }
>> +
>> +       if (mapcount !=3D mapcount2)
>> +               printk(KERN_ERR "mapcount %d mapcount2 %d page_mapcount
>> %d\n",
>> +                      mapcount, mapcount2, page_mapcount(page));
>> +       BUG_ON(mapcount !=3D mapcount2);
>> +       count_vm_event(THP_SPLIT);
>> +       mutex_unlock(&mapping->i_mmap_mutex);
>> +
>> +       /*
>> +        * Drop small pages beyond i_size if any.
>> +        *
>> +        * XXX: do we need to serialize over i_mutex here?
>> +        * If yes, how to get mmap_sem vs. i_mutex ordering fixed?
>> +        */
>> +       truncate_inode_pages(mapping, i_size_read(mapping->host));
>> +       return 0;
>> +}
>> +
>> +int split_huge_page_to_list(struct page *page, struct list_head *list)
>> +{
>> +       BUG_ON(is_huge_zero_page(page));
>> +
>> +       if (PageAnon(page))
>> +               return split_anon_huge_page(page, list);
>> +       else
>> +               return split_file_huge_page(page, list);
>> +}
>> +
>>  #define VM_NO_THP
>> (VM_SPECIAL|VM_MIXEDMAP|VM_HUGETLB|VM_SHARED|VM_MAYSHARE)
>>
>>  int hugepage_madvise(struct vm_area_struct *vma,
>> --
>> 1.8.3.2
>>
>>
>

--001a11c3df4ea9a75604e34dd9a8
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Is this safe to move the=C2=A0vma_adjust_trans_huge before=
 the line 772? Seems for anonymous memory, we only take the lock after=C2=
=A0vma_adjust_trans_huge, maybe we should do the same for file?</div><div c=
lass=3D"gmail_extra">

<br clear=3D"all"><div><div><div>Best wishes,<br></div><div><span style=3D"=
border-collapse:collapse;font-family:arial,sans-serif;font-size:13px">--=C2=
=A0<br><span style=3D"border-collapse:collapse;font-family:sans-serif;line-=
height:19px"><span style=3D"border-top-width:2px;border-right-width:0px;bor=
der-bottom-width:0px;border-left-width:0px;border-top-style:solid;border-ri=
ght-style:solid;border-bottom-style:solid;border-left-style:solid;border-to=
p-color:rgb(213,15,37);border-right-color:rgb(213,15,37);border-bottom-colo=
r:rgb(213,15,37);border-left-color:rgb(213,15,37);padding-top:2px;margin-to=
p:2px">Ning Qu (=E6=9B=B2=E5=AE=81)<font color=3D"#555555">=C2=A0|</font></=
span><span style=3D"color:rgb(85,85,85);border-top-width:2px;border-right-w=
idth:0px;border-bottom-width:0px;border-left-width:0px;border-top-style:sol=
id;border-right-style:solid;border-bottom-style:solid;border-left-style:sol=
id;border-top-color:rgb(51,105,232);border-right-color:rgb(51,105,232);bord=
er-bottom-color:rgb(51,105,232);border-left-color:rgb(51,105,232);padding-t=
op:2px;margin-top:2px">=C2=A0Software Engineer |</span><span style=3D"color=
:rgb(85,85,85);border-top-width:2px;border-right-width:0px;border-bottom-wi=
dth:0px;border-left-width:0px;border-top-style:solid;border-right-style:sol=
id;border-bottom-style:solid;border-left-style:solid;border-top-color:rgb(0=
,153,57);border-right-color:rgb(0,153,57);border-bottom-color:rgb(0,153,57)=
;border-left-color:rgb(0,153,57);padding-top:2px;margin-top:2px">=C2=A0<a h=
ref=3D"mailto:quning@google.com" style=3D"color:rgb(0,0,204)" target=3D"_bl=
ank">quning@google.com</a>=C2=A0|</span><span style=3D"color:rgb(85,85,85);=
border-top-width:2px;border-right-width:0px;border-bottom-width:0px;border-=
left-width:0px;border-top-style:solid;border-right-style:solid;border-botto=
m-style:solid;border-left-style:solid;border-top-color:rgb(238,178,17);bord=
er-right-color:rgb(238,178,17);border-bottom-color:rgb(238,178,17);border-l=
eft-color:rgb(238,178,17);padding-top:2px;margin-top:2px">=C2=A0<a value=3D=
"+16502143877" style=3D"color:rgb(0,0,204)">+1-408-418-6066</a></span></spa=
n></span></div>

</div></div>
<br><br><div class=3D"gmail_quote">On Tue, Aug 6, 2013 at 12:09 PM, Ning Qu=
 <span dir=3D"ltr">&lt;<a href=3D"mailto:quning@google.com" target=3D"_blan=
k">quning@google.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_qu=
ote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex=
">

<div dir=3D"ltr">I am probably running into a deadlock case for this patch.=
<div><br></div><div>When splitting the file huge page, we hold the=C2=A0i_m=
map_mutex.</div><div><br></div><div>However, when coming from the call path=
 in vma_adjust as following, we will grab the=C2=A0<span style=3D"font-size=
:13px">i_mmap_mutex already before doing=C2=A0</span><span style=3D"color:r=
gb(1,1,129);font-size:13px">vma_adjust_trans_huge, which will eventually ca=
lls the split_huge_page then split_file_huge_page ....</span></div>


<div><br></div><div><a href=3D"https://git.kernel.org/cgit/linux/kernel/git=
/kas/linux.git/tree/mm/mmap.c?h=3Dthp/pagecache#n753" target=3D"_blank">htt=
ps://git.kernel.org/cgit/linux/kernel/git/kas/linux.git/tree/mm/mmap.c?h=3D=
thp/pagecache#n753</a><br>


</div><div><br></div><div><br></div><div><br></div></div><div class=3D"gmai=
l_extra"><br clear=3D"all"><div><div><div>Best wishes,<span class=3D"HOEnZb=
"><font color=3D"#888888"><br></font></span></div><span class=3D"HOEnZb"><f=
ont color=3D"#888888"><div>

<span style=3D"border-collapse:collapse;font-family:arial,sans-serif;font-s=
ize:13px">--=C2=A0<br>
<span style=3D"border-collapse:collapse;font-family:sans-serif;line-height:=
19px"><span style=3D"border-top-width:2px;border-right-width:0px;border-bot=
tom-width:0px;border-left-width:0px;border-top-style:solid;border-right-sty=
le:solid;border-bottom-style:solid;border-left-style:solid;border-top-color=
:rgb(213,15,37);border-right-color:rgb(213,15,37);border-bottom-color:rgb(2=
13,15,37);border-left-color:rgb(213,15,37);padding-top:2px;margin-top:2px">=
Ning Qu (=E6=9B=B2=E5=AE=81)<font color=3D"#555555">=C2=A0|</font></span><s=
pan style=3D"color:rgb(85,85,85);border-top-width:2px;border-right-width:0p=
x;border-bottom-width:0px;border-left-width:0px;border-top-style:solid;bord=
er-right-style:solid;border-bottom-style:solid;border-left-style:solid;bord=
er-top-color:rgb(51,105,232);border-right-color:rgb(51,105,232);border-bott=
om-color:rgb(51,105,232);border-left-color:rgb(51,105,232);padding-top:2px;=
margin-top:2px">=C2=A0Software Engineer |</span><span style=3D"color:rgb(85=
,85,85);border-top-width:2px;border-right-width:0px;border-bottom-width:0px=
;border-left-width:0px;border-top-style:solid;border-right-style:solid;bord=
er-bottom-style:solid;border-left-style:solid;border-top-color:rgb(0,153,57=
);border-right-color:rgb(0,153,57);border-bottom-color:rgb(0,153,57);border=
-left-color:rgb(0,153,57);padding-top:2px;margin-top:2px">=C2=A0<a href=3D"=
mailto:quning@google.com" style=3D"color:rgb(0,0,204)" target=3D"_blank">qu=
ning@google.com</a>=C2=A0|</span><span style=3D"color:rgb(85,85,85);border-=
top-width:2px;border-right-width:0px;border-bottom-width:0px;border-left-wi=
dth:0px;border-top-style:solid;border-right-style:solid;border-bottom-style=
:solid;border-left-style:solid;border-top-color:rgb(238,178,17);border-righ=
t-color:rgb(238,178,17);border-bottom-color:rgb(238,178,17);border-left-col=
or:rgb(238,178,17);padding-top:2px;margin-top:2px">=C2=A0<a value=3D"+16502=
143877" style=3D"color:rgb(0,0,204)">+1-408-418-6066</a></span></span></spa=
n></div>


</font></span></div></div><div><div class=3D"h5">
<br><br><div class=3D"gmail_quote">On Sat, Aug 3, 2013 at 7:17 PM, Kirill A=
. Shutemov <span dir=3D"ltr">&lt;<a href=3D"mailto:kirill.shutemov@linux.in=
tel.com" target=3D"_blank">kirill.shutemov@linux.intel.com</a>&gt;</span> w=
rote:<br>


<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">From: &quot;Kirill A. Shutemov&quot; &lt;<a =
href=3D"mailto:kirill.shutemov@linux.intel.com" target=3D"_blank">kirill.sh=
utemov@linux.intel.com</a>&gt;<br>



<br>
The base scheme is the same as for anonymous pages, but we walk by<br>
mapping-&gt;i_mmap rather then anon_vma-&gt;rb_root.<br>
<br>
When we add a huge page to page cache we take only reference to head<br>
page, but on split we need to take addition reference to all tail pages<br>
since they are still in page cache after splitting.<br>
<br>
Signed-off-by: Kirill A. Shutemov &lt;<a href=3D"mailto:kirill.shutemov@lin=
ux.intel.com" target=3D"_blank">kirill.shutemov@linux.intel.com</a>&gt;<br>
---<br>
=C2=A0mm/huge_memory.c | 89 +++++++++++++++++++++++++++++++++++++++++++++++=
---------<br>
=C2=A01 file changed, 76 insertions(+), 13 deletions(-)<br>
<br>
diff --git a/mm/huge_memory.c b/mm/huge_memory.c<br>
index 523946c..d7c6830 100644<br>
--- a/mm/huge_memory.c<br>
+++ b/mm/huge_memory.c<br>
@@ -1580,6 +1580,7 @@ static void __split_huge_page_refcount(struct page *p=
age,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 struct zone *zone =3D page_zone(page);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 struct lruvec *lruvec;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 int tail_count =3D 0;<br>
+ =C2=A0 =C2=A0 =C2=A0 int initial_tail_refcount;<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 /* prevent PageLRU to go away from under us, an=
d freeze lru stats */<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_lock_irq(&amp;zone-&gt;lru_lock);<br>
@@ -1589,6 +1590,13 @@ static void __split_huge_page_refcount(struct page *=
page,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 /* complete memcg works before add pages to LRU=
 */<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 mem_cgroup_split_huge_fixup(page);<br>
<br>
+ =C2=A0 =C2=A0 =C2=A0 /*<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0* When we add a huge page to page cache we tak=
e only reference to head<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0* page, but on split we need to take addition =
reference to all tail<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0* pages since they are still in page cache aft=
er splitting.<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0*/<br>
+ =C2=A0 =C2=A0 =C2=A0 initial_tail_refcount =3D PageAnon(page) ? 0 : 1;<br=
>
+<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 for (i =3D HPAGE_PMD_NR - 1; i &gt;=3D 1; i--) =
{<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct page *page_t=
ail =3D page + i;<br>
<br>
@@ -1611,8 +1619,9 @@ static void __split_huge_page_refcount(struct page *p=
age,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* atomic_set(=
) here would be safe on all archs (and<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* not only on=
 x86), it&#39;s safer to use atomic_add().<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/<br>
- =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 atomic_add(page_mapcount=
(page) + page_mapcount(page_tail) + 1,<br>
- =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0&amp;page_tail-&gt;_count);<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 atomic_add(initial_tail_=
refcount + page_mapcount(page) +<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 page_mapcount(page_tail) + 1,<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 &amp;page_tail-&gt;_count);<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* after clearing P=
ageTail the gup refcount can be released */<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 smp_mb();<br>
@@ -1651,23 +1660,23 @@ static void __split_huge_page_refcount(struct page =
*page,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 */<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 page_tail-&gt;_mapc=
ount =3D page-&gt;_mapcount;<br>
<br>
- =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 BUG_ON(page_tail-&gt;map=
ping);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 page_tail-&gt;mappi=
ng =3D page-&gt;mapping;<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 page_tail-&gt;index=
 =3D page-&gt;index + i;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 page_nid_xchg_last(=
page_tail, page_nid_last(page));<br>
<br>
- =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 BUG_ON(!PageAnon(page_ta=
il));<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 BUG_ON(!PageUptodat=
e(page_tail));<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 BUG_ON(!PageDirty(p=
age_tail));<br>
- =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 BUG_ON(!PageSwapBacked(p=
age_tail));<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 lru_add_page_tail(p=
age, page_tail, lruvec, list);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 atomic_sub(tail_count, &amp;page-&gt;_count);<b=
r>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 BUG_ON(atomic_read(&amp;page-&gt;_count) &lt;=
=3D 0);<br>
<br>
- =C2=A0 =C2=A0 =C2=A0 __mod_zone_page_state(zone, NR_ANON_TRANSPARENT_HUGE=
PAGES, -1);<br>
+ =C2=A0 =C2=A0 =C2=A0 if (PageAnon(page))<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __mod_zone_page_state(zo=
ne, NR_ANON_TRANSPARENT_HUGEPAGES, -1);<br>
+ =C2=A0 =C2=A0 =C2=A0 else<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __mod_zone_page_state(zo=
ne, NR_FILE_TRANSPARENT_HUGEPAGES, -1);<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 ClearPageCompound(page);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 compound_unlock(page);<br>
@@ -1767,7 +1776,7 @@ static int __split_huge_page_map(struct page *page,<b=
r>
=C2=A0}<br>
<br>
=C2=A0/* must be called with anon_vma-&gt;root-&gt;rwsem held */<br>
-static void __split_huge_page(struct page *page,<br>
+static void __split_anon_huge_page(struct page *page,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct anon_vma *anon_vma,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct list_head *list)<br>
=C2=A0{<br>
@@ -1791,7 +1800,7 @@ static void __split_huge_page(struct page *page,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* and establishes a child pmd before<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* __split_huge_page_splitting() freezes t=
he parent pmd (so if<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* we fail to prevent copy_huge_pmd() from=
 running until the<br>
- =C2=A0 =C2=A0 =C2=A0 =C2=A0* whole __split_huge_page() is complete), we w=
ill still see<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0* whole __split_anon_huge_page() is complete),=
 we will still see<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* the newly established pmd of the child =
later during the<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* walk, to be able to set it as pmd_trans=
_splitting too.<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/<br>
@@ -1822,14 +1831,11 @@ static void __split_huge_page(struct page *page,<br=
>
=C2=A0 * from the hugepage.<br>
=C2=A0 * Return 0 if the hugepage is split successfully otherwise return 1.=
<br>
=C2=A0 */<br>
-int split_huge_page_to_list(struct page *page, struct list_head *list)<br>
+static int split_anon_huge_page(struct page *page, struct list_head *list)=
<br>
=C2=A0{<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 struct anon_vma *anon_vma;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 int ret =3D 1;<br>
<br>
- =C2=A0 =C2=A0 =C2=A0 BUG_ON(is_huge_zero_page(page));<br>
- =C2=A0 =C2=A0 =C2=A0 BUG_ON(!PageAnon(page));<br>
-<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 /*<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* The caller does not necessarily hold an=
 mmap_sem that would prevent<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* the anon_vma disappearing so we first w=
e take a reference to it<br>
@@ -1847,7 +1853,7 @@ int split_huge_page_to_list(struct page *page, struct=
 list_head *list)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out_unlock;<br=
>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 BUG_ON(!PageSwapBacked(page));<br>
- =C2=A0 =C2=A0 =C2=A0 __split_huge_page(page, anon_vma, list);<br>
+ =C2=A0 =C2=A0 =C2=A0 __split_anon_huge_page(page, anon_vma, list);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 count_vm_event(THP_SPLIT);<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 BUG_ON(PageCompound(page));<br>
@@ -1858,6 +1864,63 @@ out:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 return ret;<br>
=C2=A0}<br>
<br>
+static int split_file_huge_page(struct page *page, struct list_head *list)=
<br>
+{<br>
+ =C2=A0 =C2=A0 =C2=A0 struct address_space *mapping =3D page-&gt;mapping;<=
br>
+ =C2=A0 =C2=A0 =C2=A0 pgoff_t pgoff =3D page-&gt;index &lt;&lt; (PAGE_CACH=
E_SHIFT - PAGE_SHIFT);<br>
+ =C2=A0 =C2=A0 =C2=A0 struct vm_area_struct *vma;<br>
+ =C2=A0 =C2=A0 =C2=A0 int mapcount, mapcount2;<br>
+<br>
+ =C2=A0 =C2=A0 =C2=A0 BUG_ON(!PageHead(page));<br>
+ =C2=A0 =C2=A0 =C2=A0 BUG_ON(PageTail(page));<br>
+<br>
+ =C2=A0 =C2=A0 =C2=A0 mutex_lock(&amp;mapping-&gt;i_mmap_mutex);<br>
+ =C2=A0 =C2=A0 =C2=A0 mapcount =3D 0;<br>
+ =C2=A0 =C2=A0 =C2=A0 vma_interval_tree_foreach(vma, &amp;mapping-&gt;i_mm=
ap, pgoff, pgoff) {<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long addr =3D v=
ma_address(page, vma);<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mapcount +=3D __split_hu=
ge_page_splitting(page, vma, addr);<br>
+ =C2=A0 =C2=A0 =C2=A0 }<br>
+<br>
+ =C2=A0 =C2=A0 =C2=A0 if (mapcount !=3D page_mapcount(page))<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 printk(KERN_ERR &quot;ma=
pcount %d page_mapcount %d\n&quot;,<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0mapcount, page_mapcount(page));<br>
+ =C2=A0 =C2=A0 =C2=A0 BUG_ON(mapcount !=3D page_mapcount(page));<br>
+<br>
+ =C2=A0 =C2=A0 =C2=A0 __split_huge_page_refcount(page, list);<br>
+<br>
+ =C2=A0 =C2=A0 =C2=A0 mapcount2 =3D 0;<br>
+ =C2=A0 =C2=A0 =C2=A0 vma_interval_tree_foreach(vma, &amp;mapping-&gt;i_mm=
ap, pgoff, pgoff) {<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long addr =3D v=
ma_address(page, vma);<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mapcount2 +=3D __split_h=
uge_page_map(page, vma, addr);<br>
+ =C2=A0 =C2=A0 =C2=A0 }<br>
+<br>
+ =C2=A0 =C2=A0 =C2=A0 if (mapcount !=3D mapcount2)<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 printk(KERN_ERR &quot;ma=
pcount %d mapcount2 %d page_mapcount %d\n&quot;,<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0mapcount, mapcount2, page_mapcount(page));<br>
+ =C2=A0 =C2=A0 =C2=A0 BUG_ON(mapcount !=3D mapcount2);<br>
+ =C2=A0 =C2=A0 =C2=A0 count_vm_event(THP_SPLIT);<br>
+ =C2=A0 =C2=A0 =C2=A0 mutex_unlock(&amp;mapping-&gt;i_mmap_mutex);<br>
+<br>
+ =C2=A0 =C2=A0 =C2=A0 /*<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0* Drop small pages beyond i_size if any.<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0*<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0* XXX: do we need to serialize over i_mutex he=
re?<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0* If yes, how to get mmap_sem vs. i_mutex orde=
ring fixed?<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0*/<br>
+ =C2=A0 =C2=A0 =C2=A0 truncate_inode_pages(mapping, i_size_read(mapping-&g=
t;host));<br>
+ =C2=A0 =C2=A0 =C2=A0 return 0;<br>
+}<br>
+<br>
+int split_huge_page_to_list(struct page *page, struct list_head *list)<br>
+{<br>
+ =C2=A0 =C2=A0 =C2=A0 BUG_ON(is_huge_zero_page(page));<br>
+<br>
+ =C2=A0 =C2=A0 =C2=A0 if (PageAnon(page))<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return split_anon_huge_p=
age(page, list);<br>
+ =C2=A0 =C2=A0 =C2=A0 else<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return split_file_huge_p=
age(page, list);<br>
+}<br>
+<br>
=C2=A0#define VM_NO_THP (VM_SPECIAL|VM_MIXEDMAP|VM_HUGETLB|VM_SHARED|VM_MAY=
SHARE)<br>
<br>
=C2=A0int hugepage_madvise(struct vm_area_struct *vma,<br>
<span><font color=3D"#888888">--<br>
1.8.3.2<br>
<br>
</font></span></blockquote></div><br></div></div></div>
</blockquote></div><br></div>

--001a11c3df4ea9a75604e34dd9a8--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
