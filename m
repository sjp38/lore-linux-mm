Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E63676B0260
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 20:34:35 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a7so65556699pfj.3
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 17:34:35 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id v7si7578327plp.471.2017.10.09.17.34.33
        for <linux-mm@kvack.org>;
        Mon, 09 Oct 2017 17:34:34 -0700 (PDT)
Date: Tue, 10 Oct 2017 09:34:32 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2 4/4] mm:swap: skip swapcache for swapin of synchronous
 device
Message-ID: <20171010003432.GA23073@bbox>
References: <1505886205-9671-1-git-send-email-minchan@kernel.org>
 <1505886205-9671-5-git-send-email-minchan@kernel.org>
 <CAC=cRTMm41DpnSdv0BvBDLcdfgyssD2u5xqUmGUgZ5RdGroWhQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAC=cRTMm41DpnSdv0BvBDLcdfgyssD2u5xqUmGUgZ5RdGroWhQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: huang ying <huang.ying.caritas@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, kernel-team <kernel-team@lge.com>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Hugh Dickins <hughd@google.com>, Huang Ying <ying.huang@intel.com>

Hi Huang,

Sorry for the late response. It was long national holiday.

On Fri, Sep 29, 2017 at 04:51:17PM +0800, huang ying wrote:
> On Wed, Sep 20, 2017 at 1:43 PM, Minchan Kim <minchan@kernel.org> wrote:
> > With fast swap storage, platform want to use swap more aggressively
> > and swap-in is crucial to application latency.
> >
> > The rw_page based synchronous devices like zram, pmem and btt are such
> > fast storage. When I profile swapin performance with zram lz4 decompress
> > test, S/W overhead is more than 70%. Maybe, it would be bigger in nvdimm.
> >
> > This patch aims for reducing swap-in latency via skipping swapcache
> > if swap device is synchronous device like rw_page based device.
> > It enhances 45% my swapin test(5G sequential swapin, no readahead,
> > from 2.41sec to 1.64sec).
> >
> > Cc: Dan Williams <dan.j.williams@intel.com>
> > Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> > Cc: Hugh Dickins <hughd@google.com>
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  include/linux/swap.h | 11 +++++++++++
> >  mm/memory.c          | 52 ++++++++++++++++++++++++++++++++++++----------------
> >  mm/page_io.c         |  6 +++---
> >  mm/swapfile.c        | 11 +++++++----
> >  4 files changed, 57 insertions(+), 23 deletions(-)
> >
> > diff --git a/include/linux/swap.h b/include/linux/swap.h
> > index fbb33919d1c6..cd2f66fdfc2d 100644
> > --- a/include/linux/swap.h
> > +++ b/include/linux/swap.h
> > @@ -461,6 +461,7 @@ extern int page_swapcount(struct page *);
> >  extern int __swp_swapcount(swp_entry_t entry);
> >  extern int swp_swapcount(swp_entry_t entry);
> >  extern struct swap_info_struct *page_swap_info(struct page *);
> > +extern struct swap_info_struct *swp_swap_info(swp_entry_t entry);
> >  extern bool reuse_swap_page(struct page *, int *);
> >  extern int try_to_free_swap(struct page *);
> >  struct backing_dev_info;
> > @@ -469,6 +470,16 @@ extern void exit_swap_address_space(unsigned int type);
> >
> >  #else /* CONFIG_SWAP */
> >
> > +static inline int swap_readpage(struct page *page, bool do_poll)
> > +{
> > +       return 0;
> > +}
> > +
> > +static inline struct swap_info_struct *swp_swap_info(swp_entry_t entry)
> > +{
> > +       return NULL;
> > +}
> > +
> >  #define swap_address_space(entry)              (NULL)
> >  #define get_nr_swap_pages()                    0L
> >  #define total_swap_pages                       0L
> > diff --git a/mm/memory.c b/mm/memory.c
> > index ec4e15494901..163ab2062385 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -2842,7 +2842,7 @@ EXPORT_SYMBOL(unmap_mapping_range);
> >  int do_swap_page(struct vm_fault *vmf)
> >  {
> >         struct vm_area_struct *vma = vmf->vma;
> > -       struct page *page = NULL, *swapcache;
> > +       struct page *page = NULL, *swapcache = NULL;
> >         struct mem_cgroup *memcg;
> >         struct vma_swap_readahead swap_ra;
> >         swp_entry_t entry;
> > @@ -2881,17 +2881,35 @@ int do_swap_page(struct vm_fault *vmf)
> >                 }
> >                 goto out;
> >         }
> > +
> > +
> >         delayacct_set_flag(DELAYACCT_PF_SWAPIN);
> >         if (!page)
> >                 page = lookup_swap_cache(entry, vma_readahead ? vma : NULL,
> >                                          vmf->address);
> >         if (!page) {
> > -               if (vma_readahead)
> > -                       page = do_swap_page_readahead(entry,
> > -                               GFP_HIGHUSER_MOVABLE, vmf, &swap_ra);
> > -               else
> > -                       page = swapin_readahead(entry,
> > -                               GFP_HIGHUSER_MOVABLE, vma, vmf->address);
> > +               struct swap_info_struct *si = swp_swap_info(entry);
> > +
> > +               if (!(si->flags & SWP_SYNCHRONOUS_IO)) {
> > +                       if (vma_readahead)
> > +                               page = do_swap_page_readahead(entry,
> > +                                       GFP_HIGHUSER_MOVABLE, vmf, &swap_ra);
> > +                       else
> > +                               page = swapin_readahead(entry,
> > +                                       GFP_HIGHUSER_MOVABLE, vma, vmf->address);
> > +                       swapcache = page;
> > +               } else {
> > +                       /* skip swapcache */
> > +                       page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, vmf->address);
> > +                       if (page) {
> > +                               __SetPageLocked(page);
> > +                               __SetPageSwapBacked(page);
> > +                               set_page_private(page, entry.val);
> > +                               lru_cache_add_anon(page);
> > +                               swap_readpage(page, true);
> > +                       }
> > +               }
> 
> I have a question for this.  If a page is mapped in multiple processes
> (for example, because of fork).  With swap cache, after swapping out
> and swapping in, the page will be still shared by these processes.
> But with your changes, it appears that there will be multiple pages
> with same contents mapped in multiple processes, even if the page
> isn't written in these processes.  So this may waste some memory in
> some situation?  And copying from device is even faster than looking
> up swap cache in your system?

I expected a page shared by several processes has low possibility to swap out
compared to a single mapped page. Nonetheless, once it is swapped out, it also
has low chance to swap in so I didn't cover the case intentionally until we
get any regression report.

However, a fix would be simple so I don't care to add up it.
Any thoughts?

diff --git a/include/linux/swap.h b/include/linux/swap.h
index cd2f66fdfc2d..23f19ffa5cc3 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -458,6 +458,7 @@ extern unsigned int count_swap_pages(int, int);
 extern sector_t map_swap_page(struct page *, struct block_device **);
 extern sector_t swapdev_block(int, pgoff_t);
 extern int page_swapcount(struct page *);
+extern int __swap_count(struct swap_info_struct *si, swp_entry_t entry);
 extern int __swp_swapcount(swp_entry_t entry);
 extern int swp_swapcount(swp_entry_t entry);
 extern struct swap_info_struct *page_swap_info(struct page *);
@@ -584,6 +585,11 @@ static inline int page_swapcount(struct page *page)
 	return 0;
 }
 
+static inline int __swap_count(structd swap_info_struct *si, swp_entry_t entry)
+{
+	return 0;
+}
+
 static inline int __swp_swapcount(swp_entry_t entry)
 {
 	return 0;
diff --git a/include/linux/swapfile.h b/include/linux/swapfile.h
index 388293a91e8c..49f8e19dd506 100644
--- a/include/linux/swapfile.h
+++ b/include/linux/swapfile.h
@@ -9,5 +9,4 @@ extern spinlock_t swap_lock;
 extern struct plist_head swap_active_head;
 extern struct swap_info_struct *swap_info[];
 extern int try_to_unuse(unsigned int, bool, unsigned long);
-
 #endif /* _LINUX_SWAPFILE_H */
diff --git a/mm/memory.c b/mm/memory.c
index 163ab2062385..c6f0abe8b39b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2890,15 +2890,8 @@ int do_swap_page(struct vm_fault *vmf)
 	if (!page) {
 		struct swap_info_struct *si = swp_swap_info(entry);
 
-		if (!(si->flags & SWP_SYNCHRONOUS_IO)) {
-			if (vma_readahead)
-				page = do_swap_page_readahead(entry,
-					GFP_HIGHUSER_MOVABLE, vmf, &swap_ra);
-			else
-				page = swapin_readahead(entry,
-					GFP_HIGHUSER_MOVABLE, vma, vmf->address);
-			swapcache = page;
-		} else {
+		if ((si->flags & SWP_SYNCHRONOUS_IO) && (vmf->flags & FAULT_FLAG_WRITE ||
+							__swap_count(si, entry) == 1)) {
 			/* skip swapcache */
 			page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, vmf->address);
 			if (page) {
@@ -2908,6 +2901,14 @@ int do_swap_page(struct vm_fault *vmf)
 				lru_cache_add_anon(page);
 				swap_readpage(page, true);
 			}
+		} else {
+			if (vma_readahead)
+				page = do_swap_page_readahead(entry,
+					GFP_HIGHUSER_MOVABLE, vmf, &swap_ra);
+			else
+				page = swapin_readahead(entry,
+					GFP_HIGHUSER_MOVABLE, vma, vmf->address);
+			swapcache = page;
 		}
 
 		if (!page) {
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 64a3d85226ba..37d7ba71a2ca 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1328,7 +1328,13 @@ int page_swapcount(struct page *page)
 	return count;
 }
 
-static int swap_swapcount(struct swap_info_struct *si, swp_entry_t entry)
+int __swap_count(struct swap_info_struct *si, swp_entry_t entry)
+{
+	pgoff_t offset = swp_offset(entry);
+	return swap_count(si->swap_map[offset]);
+}
+
+int swap_swapcount(struct swap_info_struct *si, swp_entry_t entry)
 {
 	int count = 0;
 	pgoff_t offset = swp_offset(entry);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
