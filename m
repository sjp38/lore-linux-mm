Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 8ECCF6B0178
	for <linux-mm@kvack.org>; Fri, 18 Oct 2013 14:16:27 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id g10so4043168pdj.6
        for <linux-mm@kvack.org>; Fri, 18 Oct 2013 11:16:27 -0700 (PDT)
Received: from psmtp.com ([74.125.245.149])
        by mx.google.com with SMTP id ds3si1478064pbb.259.2013.10.18.11.16.25
        for <linux-mm@kvack.org>;
        Fri, 18 Oct 2013 11:16:26 -0700 (PDT)
Received: by mail-pa0-f46.google.com with SMTP id fa1so4902457pad.5
        for <linux-mm@kvack.org>; Fri, 18 Oct 2013 11:16:24 -0700 (PDT)
Date: Fri, 18 Oct 2013 11:16:20 -0700
From: Ning Qu <quning@google.com>
Subject: Re: [PATCH 04/12] mm, thp, tmpfs: split huge page when moving from
 page cache to swap
Message-ID: <20131018181620.GA6970@hippobay.mtv.corp.google.com>
References: <20131015001228.GE3432@hippobay.mtv.corp.google.com>
 <20131015103334.E3877E0090@blue.fi.intel.com>
 <CACz4_2eoRoyUU1G3veS=veWTi1HtPrgLQK0tyXONXcQj1Xi4EQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="gBBFr7Ir9EOA20Yy"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CACz4_2eoRoyUU1G3veS=veWTi1HtPrgLQK0tyXONXcQj1Xi4EQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Al Viro <viro@zeniv.linux.org.uk>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org


--gBBFr7Ir9EOA20Yy
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

New patch below with handle all the pages after splitted.

---
 include/linux/huge_mm.h |  2 ++
 mm/shmem.c              | 79 ++++++++++++++++++++++++++++++++++++-------------
 2 files changed, 61 insertions(+), 20 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 65f90db..58b0208 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -64,6 +64,7 @@ extern pmd_t *page_check_address_pmd(struct page *page,
 #define HPAGE_PMD_SHIFT PMD_SHIFT
 #define HPAGE_PMD_SIZE ((1UL) << HPAGE_PMD_SHIFT)
 #define HPAGE_PMD_MASK (~(HPAGE_PMD_SIZE - 1))
+#define HPAGE_NR_PAGES HPAGE_PMD_NR

 extern bool is_vma_temporary_stack(struct vm_area_struct *vma);

@@ -207,6 +208,7 @@ extern int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vm
 #define THP_READ_ALLOC_FAILED  ({ BUILD_BUG(); 0; })

 #define hpage_nr_pages(x) 1
+#define HPAGE_NR_PAGES 1

 #define transparent_hugepage_enabled(__vma) 0
 #define transparent_hugepage_defrag(__vma) 0
diff --git a/mm/shmem.c b/mm/shmem.c
index 5bde8d0..b80ace7 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -862,14 +862,16 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
        struct shmem_inode_info *info;
        struct address_space *mapping;
        struct inode *inode;
-       swp_entry_t swap;
+       swp_entry_t swap[HPAGE_NR_PAGES];
        pgoff_t index;
+       int nr = 1;
+       int i;

        BUG_ON(!PageLocked(page));
        mapping = page->mapping;
-       index = page->index;
        inode = mapping->host;
        info = SHMEM_I(inode);
+
        if (info->flags & VM_LOCKED)
                goto redirty;
        if (!total_swap_pages)
@@ -887,6 +889,7 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
                goto redirty;
        }

+       index = page->index;
        /*
         * This is somewhat ridiculous, but without plumbing a SWAP_MAP_FALLOC
         * value into swapfile.c, the only way we can correctly account for a
@@ -906,21 +909,35 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
                        if (shmem_falloc &&
                            index >= shmem_falloc->start &&
                            index < shmem_falloc->next)
-                               shmem_falloc->nr_unswapped++;
+                               shmem_falloc->nr_unswapped +=
+                                       hpagecache_nr_pages(page);
                        else
                                shmem_falloc = NULL;
                        spin_unlock(&inode->i_lock);
                        if (shmem_falloc)
                                goto redirty;
                }
-               clear_highpage(page);
+               clear_pagecache_page(page);
                flush_dcache_page(page);
                SetPageUptodate(page);
        }

-       swap = get_swap_page();
-       if (!swap.val)
-               goto redirty;
+       /* We can only have nr correct after huge page splitted,
+        * otherwise, it will fail the redirty logic
+        */
+       nr = hpagecache_nr_pages(page);
+       /* We have to break the huge page at this point,
+        * since we have no idea how to swap a huge page.
+        */
+       if (PageTransHugeCache(page))
+               split_huge_page(compound_trans_head(page));
+
+       /* Pre-allocate all the swap pages */
+       for (i = 0; i < nr; i++) {
+               swap[i] = get_swap_page();
+               if (!swap[i].val)
+                       goto undo_alloc_swap;
+       }

        /*
         * Add inode to shmem_unuse()'s list of swapped-out inodes,
@@ -934,25 +951,47 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
        if (list_empty(&info->swaplist))
                list_add_tail(&info->swaplist, &shmem_swaplist);

-       if (add_to_swap_cache(page, swap, GFP_ATOMIC) == 0) {
-               swap_shmem_alloc(swap);
-               shmem_delete_from_page_cache(page, swp_to_radix_entry(swap));
+       for (i = 0; i < nr; i++) {
+               if (add_to_swap_cache(page + i, swap[i], GFP_ATOMIC))
+                       goto undo_add_to_swap_cache;
+       }

-               spin_lock(&info->lock);
-               info->swapped++;
-               shmem_recalc_inode(inode);
-               spin_unlock(&info->lock);
+       /* We make sure everything is correct before moving further */
+       for (i = 0; i < nr; i++) {
+               swap_shmem_alloc(swap[i]);
+               shmem_delete_from_page_cache(page + i,
+                       swp_to_radix_entry(swap[i]));
+       }

-               mutex_unlock(&shmem_swaplist_mutex);
-               BUG_ON(page_mapped(page));
-               swap_writepage(page, wbc);
-               return 0;
+       spin_lock(&info->lock);
+       info->swapped += nr;
+       shmem_recalc_inode(inode);
+       spin_unlock(&info->lock);
+
+       mutex_unlock(&shmem_swaplist_mutex);
+
+       for (i = 0; i < nr; i++) {
+               BUG_ON(page_mapped(page + i));
+               swap_writepage(page + i, wbc);
        }

+       return 0;
+
+undo_add_to_swap_cache:
+       while (i) {
+               i--;
+               __delete_from_swap_cache(page + i);
+       }
        mutex_unlock(&shmem_swaplist_mutex);
-       swapcache_free(swap, NULL);
+       i = nr;
+undo_alloc_swap:
+       while (i) {
+               i--;
+               swapcache_free(swap[i], NULL);
+       }
 redirty:
-       set_page_dirty(page);
+       for (i = 0; i < nr; i++)
+               set_page_dirty(page + i);
        if (wbc->for_reclaim)
                return AOP_WRITEPAGE_ACTIVATE;  /* Return with page locked */
        unlock_page(page);
-- 

Best wishes,
-- 
Ning Qu (ae?2a(R)?) | Software Engineer | quning@google.com | +1-408-418-6066


On Tue, Oct 15, 2013 at 12:00 PM, Ning Qu <quning@google.com> wrote:

> Let me take another look at that logic. Thanks!
> Best wishes,
> --
> Ning Qu (ae?2a(R)?) | Software Engineer | quning@google.com | +1-408-418-6066
>
>
> On Tue, Oct 15, 2013 at 3:33 AM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
> > Ning Qu wrote:
> >> in shmem_writepage, we have to split the huge page when moving pages
> >> from page cache to swap because we don't support huge page in swap
> >> yet.
> >>
> >> Signed-off-by: Ning Qu <quning@gmail.com>
> >> ---
> >>  mm/shmem.c | 9 ++++++++-
> >>  1 file changed, 8 insertions(+), 1 deletion(-)
> >>
> >> diff --git a/mm/shmem.c b/mm/shmem.c
> >> index 8fe17dd..68a0e1d 100644
> >> --- a/mm/shmem.c
> >> +++ b/mm/shmem.c
> >> @@ -898,6 +898,13 @@ static int shmem_writepage(struct page *page, 
> struct writeback_control *wbc)
> >>       swp_entry_t swap;
> >>       pgoff_t index;
> >>
> >> +     /* TODO: we have to break the huge page at this point,
> >> +      * since we have no idea how to recover a huge page from
> >> +      * swap.
> >> +      */
> >> +     if (PageTransCompound(page))
> >> +             split_huge_page(compound_trans_head(page));
> >> +
> >
> > After the split you handle here only first small page of the huge page.
> > Is it what we want to do? Should we swap out all small pages of the huge
> > page?
> >
> > --
> >  Kirill A. Shutemov
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a hrefmailto:"dont@kvack.org"> email@kvack.org </a>
>


--gBBFr7Ir9EOA20Yy
Content-Type: text/html; charset=UTF-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">New patch below with handle all the pages after splitted.<=
/div><div class=3D"gmail_extra"><br clear=3D"all"><div><div>Best wishes,</d=
iv><div><span style=3D"border-collapse:collapse;font-family:arial,sans-seri=
f;font-size:13px">--=C2=A0<br>
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
</div>
<br><br><div class=3D"gmail_quote">On Tue, Oct 15, 2013 at 12:00 PM, Ning Q=
u <span dir=3D"ltr">&lt;<a href=3D"mailto:quning@google.com" target=3D"_bla=
nk">quning@google.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_q=
uote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1e=
x">
Let me take another look at that logic. Thanks!<br>
Best wishes,<br>
--<br>
Ning Qu (=E6=9B=B2=E5=AE=81) | Software Engineer | <a href=3D"mailto:quning=
@google.com">quning@google.com</a> | <a href=3D"tel:%2B1-408-418-6066" valu=
e=3D"+14084186066">+1-408-418-6066</a><br>
<div><div class=3D"h5"><br>
<br>
On Tue, Oct 15, 2013 at 3:33 AM, Kirill A. Shutemov<br>
&lt;<a href=3D"mailto:kirill.shutemov@linux.intel.com">kirill.shutemov@linu=
x.intel.com</a>&gt; wrote:<br>
&gt; Ning Qu wrote:<br>
&gt;&gt; in shmem_writepage, we have to split the huge page when moving pag=
es<br>
&gt;&gt; from page cache to swap because we don&#39;t support huge page in =
swap<br>
&gt;&gt; yet.<br>
&gt;&gt;<br>
&gt;&gt; Signed-off-by: Ning Qu &lt;<a href=3D"mailto:quning@gmail.com">qun=
ing@gmail.com</a>&gt;<br>
&gt;&gt; ---<br>
&gt;&gt; =C2=A0mm/shmem.c | 9 ++++++++-<br>
&gt;&gt; =C2=A01 file changed, 8 insertions(+), 1 deletion(-)<br>
&gt;&gt;<br>
&gt;&gt; diff --git a/mm/shmem.c b/mm/shmem.c<br>
&gt;&gt; index 8fe17dd..68a0e1d 100644<br>
&gt;&gt; --- a/mm/shmem.c<br>
&gt;&gt; +++ b/mm/shmem.c<br>
&gt;&gt; @@ -898,6 +898,13 @@ static int shmem_writepage(struct page *page,=
 struct writeback_control *wbc)<br>
&gt;&gt; =C2=A0 =C2=A0 =C2=A0 swp_entry_t swap;<br>
&gt;&gt; =C2=A0 =C2=A0 =C2=A0 pgoff_t index;<br>
&gt;&gt;<br>
&gt;&gt; + =C2=A0 =C2=A0 /* TODO: we have to break the huge page at this po=
int,<br>
&gt;&gt; + =C2=A0 =C2=A0 =C2=A0* since we have no idea how to recover a hug=
e page from<br>
&gt;&gt; + =C2=A0 =C2=A0 =C2=A0* swap.<br>
&gt;&gt; + =C2=A0 =C2=A0 =C2=A0*/<br>
&gt;&gt; + =C2=A0 =C2=A0 if (PageTransCompound(page))<br>
&gt;&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 split_huge_page(compou=
nd_trans_head(page));<br>
&gt;&gt; +<br>
&gt;<br>
&gt; After the split you handle here only first small page of the huge page=
=2E<br>
&gt; Is it what we want to do? Should we swap out all small pages of the hu=
ge<br>
&gt; page?<br>
&gt;<br>
&gt; --<br>
&gt; =C2=A0Kirill A. Shutemov<br>
<br>
--<br>
To unsubscribe, send a message with &#39;unsubscribe linux-mm&#39; in<br>
the body to <a href=3D"mailto:majordomo@kvack.org">majordomo@kvack.org</a>.=
 =C2=A0For more info on Linux MM,<br>
see: <a href=3D"http://www.linux-mm.org/" target=3D"_blank">http://www.linu=
x-mm.org/</a> .<br>
</div></div>Don&#39;t email: &lt;a hrefmailto:&quot;<a href=3D"mailto:dont@=
kvack.org">dont@kvack.org</a>&quot;&gt; <a href=3D"mailto:email@kvack.org">=
email@kvack.org</a> &lt;/a&gt;<br>
</blockquote></div><br></div>

--gBBFr7Ir9EOA20Yy--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
