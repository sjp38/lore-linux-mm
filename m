Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 5DF6A6B0039
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 19:45:01 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id kp14so8480020pab.9
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 16:45:01 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id yy4si20663602pbc.99.2014.02.11.16.45.00
        for <linux-mm@kvack.org>;
        Tue, 11 Feb 2014 16:45:00 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <CA+55aFyNmux-1dT0ADr24mVwCVRxL2CNXo9HLTgTh3dLD_pAcg@mail.gmail.com>
References: <1392087957-15730-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20140211133956.ef8b9417ed09651fbcf6d3a9@linux-foundation.org>
 <CA+55aFx+-ynTnj2ycq6JFo56bo978n6ZjB6LBue-jb0ipw1tXg@mail.gmail.com>
 <20140211235816.A2B50E0090@blue.fi.intel.com>
 <CA+55aFyNmux-1dT0ADr24mVwCVRxL2CNXo9HLTgTh3dLD_pAcg@mail.gmail.com>
Subject: Re: [RFC, PATCH 0/2] mm: map few pages around fault address if they
 are in page cache
Content-Transfer-Encoding: 7bit
Message-Id: <20140212004455.DB848E0090@blue.fi.intel.com>
Date: Wed, 12 Feb 2014 02:44:55 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, linux-mm <linux-mm@kvack.org>

Linus Torvalds wrote:
> On Tue, Feb 11, 2014 at 3:58 PM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
> > Linus Torvalds wrote:
> >
> > It's on top of v3.14-rc1 + __do_fault() claen up[1].
> >
> > It's also on git:
> >
> > git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux fault_around/v1
> >
> > [1] http://thread.gmane.org/gmane.linux.kernel.mm/113364
> 
> Ok, that patch-series looks good to me too.
> 
> And I still see nothing wrong that would cause it not to boot.

It actually boot to UI and kinda work until I try to rebuild kernel.
Then all IO stops, but my window manager is still work. I can switch
between windows :-/

> I think the "do_async_mmap_readahead()" in lock_secondary_pages() is silly
> and shouldn't really be done, but I don't think it should cause any problems
> per se, it just feels very wrong to do that inside the loop.

I tried to replace do_async_mmap_readahead() locally with this:

diff --git a/mm/filemap.c b/mm/filemap.c
index 0661358db958..b28d19cafefc 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1612,8 +1612,8 @@ static struct page *lock_secondary_pages(struct vm_area_struct *vma,
 		}
 		if (pages[i]->index > vmf->max)
 			goto put;
-		do_async_mmap_readahead(vma, &file->f_ra, file,
-				pages[i], pages[i]->index);
+		if (PageReadahead(pages[i]))
+			goto put;
 		if (!trylock_page(pages[i]))
 			goto put;
 		/* Truncated? */
@@ -1625,6 +1625,8 @@ static struct page *lock_secondary_pages(struct vm_area_struct *vma,
 			>> PAGE_CACHE_SHIFT;
 		if (unlikely(pages[i]->index >= size))
 			goto unlock;
+		if (file->f_ra.mmap_miss > 0)
+			file->f_ra.mmap_miss--;
 		continue;
 unlock:
 		unlock_page(pages[i]);
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
