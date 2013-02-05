Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 198716B002E
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 19:40:36 -0500 (EST)
Date: Tue, 5 Feb 2013 09:40:32 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: cma: fix accounting of CMA pages placed in high
 memory
Message-ID: <20130205004032.GD2610@blaptop>
References: <1359973626-3900-1-git-send-email-m.szyprowski@samsung.com>
 <20130204150657.6d05f76a.akpm@linux-foundation.org>
 <CAH9JG2Usd4HJKrBXwX3aEc3i6068zU=F=RjcoQ8E8uxYGrwXgg@mail.gmail.com>
 <20130204234358.GB2610@blaptop>
 <CAH9JG2VDOVv4-QrDs1FeyQNPzEDq+bf+qiSZ0snEqLGSed3PqA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAH9JG2VDOVv4-QrDs1FeyQNPzEDq+bf+qiSZ0snEqLGSed3PqA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kyungmin Park <kmpark@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mgorman@suse.de

On Tue, Feb 05, 2013 at 08:52:02AM +0900, Kyungmin Park wrote:
> Hi,
> 
> On Tue, Feb 5, 2013 at 8:43 AM, Minchan Kim <minchan@kernel.org> wrote:
> > Hello,
> >
> > On Tue, Feb 05, 2013 at 08:29:26AM +0900, Kyungmin Park wrote:
> >> On Tue, Feb 5, 2013 at 8:06 AM, Andrew Morton <akpm@linux-foundation.org> wrote:
> >> > On Mon, 04 Feb 2013 11:27:05 +0100
> >> > Marek Szyprowski <m.szyprowski@samsung.com> wrote:
> >> >
> >> >> The total number of low memory pages is determined as
> >> >> totalram_pages - totalhigh_pages, so without this patch all CMA
> >> >> pageblocks placed in highmem were accounted to low memory.
> >> >
> >> > What are the end-user-visible effects of this bug?
> >>
> >> Even though CMA is located at highmem. LowTotal has more than lowmem
> >> address spaces.
> >>
> >> e.g.,
> >> lowmem  : 0xc0000000 - 0xdf000000   ( 496 MB)
> >> LowTotal:         555788 kB
> >>
> >> >
> >> > (This information is needed so that others can make patch-scheduling
> >> > decisions and should be included in all bugfix changelogs unless it is
> >> > obvious).
> >>
> >> CMA Highmem support is new feature. so don't need to go stable tree.
> >
> > I would like to clarify it because I remembered alloc_migrate_target have considered
> > CMA pages could be highmem. Is it really new feature? If so, could you point out
> > enabling patches for the new feature?
> >
> Here's related patch.
> http://www.spinics.net/lists/arm-kernel/msg222369.html

Thanks.

> 
> Previous time, it's not fully tested and now we checked it with
> highmem support patches.

I get it. Sigh. then [1] inline attached below wan't good.
We have to code like this?

[1] 6a6dccba, mm: cma: don't replace lowmem pages with highmem

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b97cf12..0707e0a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5671,11 +5671,10 @@ static struct page *
 __alloc_contig_migrate_alloc(struct page *page, unsigned long private,
                             int **resultp)
 {
-       gfp_t gfp_mask = GFP_USER | __GFP_MOVABLE;
-
-       if (PageHighMem(page))
-               gfp_mask |= __GFP_HIGHMEM;
-
+       gfp_t gfp_mask = GFP_HIGHUSER_MOVABLE;
+       struct address_space *mapping = page_mapping(page);
+       if (mapping)
+               gfp_mask = mapping_gfp_mask(mapping);
        return alloc_page(gfp_mask);
 }


commit 6a6dccba2fdc2a69f1f36b8f1c0acc8598e7221b
Author: Rabin Vincent <rabin@rab.in>
Date:   Thu Jul 5 15:52:23 2012 +0530

    mm: cma: don't replace lowmem pages with highmem
    
    The filesystem layer expects pages in the block device's mapping to not
    be in highmem (the mapping's gfp mask is set in bdget()), but CMA can
    currently replace lowmem pages with highmem pages, leading to crashes in
    filesystem code such as the one below:
    
      Unable to handle kernel NULL pointer dereference at virtual address 00000400
      pgd = c0c98000
      [00000400] *pgd=00c91831, *pte=00000000, *ppte=00000000
      Internal error: Oops: 817 [#1] PREEMPT SMP ARM
      CPU: 0    Not tainted  (3.5.0-rc5+ #80)
      PC is at __memzero+0x24/0x80
      ...
      Process fsstress (pid: 323, stack limit = 0xc0cbc2f0)
      Backtrace:
      [<c010e3f0>] (ext4_getblk+0x0/0x180) from [<c010e58c>] (ext4_bread+0x1c/0x98)
      [<c010e570>] (ext4_bread+0x0/0x98) from [<c0117944>] (ext4_mkdir+0x160/0x3bc)
       r4:c15337f0
      [<c01177e4>] (ext4_mkdir+0x0/0x3bc) from [<c00c29e0>] (vfs_mkdir+0x8c/0x98)
      [<c00c2954>] (vfs_mkdir+0x0/0x98) from [<c00c2a60>] (sys_mkdirat+0x74/0xac)
       r6:00000000 r5:c152eb40 r4:000001ff r3:c14b43f0
      [<c00c29ec>] (sys_mkdirat+0x0/0xac) from [<c00c2ab8>] (sys_mkdir+0x20/0x24)
       r6:beccdcf0 r5:00074000 r4:beccdbbc
      [<c00c2a98>] (sys_mkdir+0x0/0x24) from [<c000e3c0>] (ret_fast_syscall+0x0/0x30)
    
    Fix this by replacing only highmem pages with highmem.
    
    Reported-by: Laura Abbott <lauraa@codeaurora.org>
    Signed-off-by: Rabin Vincent <rabin@rab.in>
    Acked-by: Michal Nazarewicz <mina86@mina86.com>
    Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4403009..4a4f921 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5635,7 +5635,12 @@ static struct page *
 __alloc_contig_migrate_alloc(struct page *page, unsigned long private,
                             int **resultp)
 {
-       return alloc_page(GFP_HIGHUSER_MOVABLE);
+       gfp_t gfp_mask = GFP_USER | __GFP_MOVABLE;
+
+       if (PageHighMem(page))
+               gfp_mask |= __GFP_HIGHMEM;
+
+       return alloc_page(gfp_mask);
 }

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
