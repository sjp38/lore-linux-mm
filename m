Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id BF2406B0005
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 00:29:09 -0500 (EST)
Received: by mail-ig0-f182.google.com with SMTP id hb3so65849738igb.0
        for <linux-mm@kvack.org>; Mon, 15 Feb 2016 21:29:09 -0800 (PST)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id e14si36074563iod.133.2016.02.15.21.29.07
        for <linux-mm@kvack.org>;
        Mon, 15 Feb 2016 21:29:08 -0800 (PST)
Date: Tue, 16 Feb 2016 16:28:52 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] kernel: fs: drop_caches: add dds drop_caches_count
Message-ID: <20160216052852.GW19486@dastard>
References: <1455308080-27238-1-git-send-email-danielwa@cisco.com>
 <20160214211856.GT19486@dastard>
 <56C216CA.7000703@cisco.com>
 <20160215230511.GU19486@dastard>
 <56C264BF.3090100@cisco.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <56C264BF.3090100@cisco.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Walker <danielwa@cisco.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Khalid Mughal <khalidm@cisco.com>, xe-kernel@external.cisco.com, dave.hansen@intel.com, hannes@cmpxchg.org, riel@redhat.com, Jonathan Corbet <corbet@lwn.net>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, "Nag Avadhanam (nag)" <nag@cisco.com>

On Mon, Feb 15, 2016 at 03:52:31PM -0800, Daniel Walker wrote:
> On 02/15/2016 03:05 PM, Dave Chinner wrote:
> >What you are proposing isn't accurate, either, because it will be
> >stale by the time the inode cache traversal is completed and the
> >count returned to userspace. e.g. pages that have already been
> >accounted as droppable can be reclaimed or marked dirty and hence
> >"unreclaimable".
> >
> >IOWs, the best you are going to get is an approximate point-in-time
> >indication of how much memory is available for immediate reclaim.
> >We're never going to get an accurate measure in userspace unless we
> >accurately account for it in the kernel itself. Which, I think it
> >has already been pointed out, is prohibitively expensive so isn't
> >done.
> >
> >As for a replacement, looking at what pages you consider "droppable"
> >is really only file pages that are not under dirty or under
> >writeback. i.e. from /proc/meminfo:
> >
> >Active(file):     220128 kB
> >Inactive(file):    60232 kB
> >Dirty:                 0 kB
> >Writeback:             0 kB
> >
> >i.e. reclaimable file cache = Active + inactive - dirty - writeback.
.....

> Approximate point-in-time indication is an accurate
> characterization of what we are doing. This is good enough for us.
> NO matter what we do, we are never going to be able to address the
> "time of check to time of usea?? window.  But, this
> approximation works reasonably well for our use case.
> 
> As to his other suggestion of estimating the droppable cache, I
> have considered it but found it unusable. The problem is the
> inactive file pages count a whole lot pages more than the
> droppable pages.

inactive file pages are supposed to be exactly that - inactive. i.e.
the have not been referenced recently, and are unlikely to be dirty.
They should be immediately reclaimable.

> See the value of these, before and [after] dropping reclaimable
> pages.
> 
> Before:
> 
> Active(file):     183488 kB
> Inactive(file):   180504 kB
> 
> After (the drop caches):
>
> Active(file):      89468 kB
> Inactive(file):    32016 kB
>
> The dirty and the write back are mostly 0KB under our workload as
> we are mostly dealing with the readonly file pages of binaries
> (programs/libraries)..  "

if the pages are read-only, then they are clean. If they are on the
LRUs, then they should be immediately reclaimable.

Let's go back to your counting criteria of all those file pages:

+static int is_page_droppable(struct page *page)
+{
+       struct address_space *mapping = page_mapping(page);
+
+       if (!mapping)
+               return 0;

invalidated page, should be none.

+       if (PageDirty(page))
+               return 0;

Dirty get ignored, in /proc/meminfo.

+       if (PageWriteback(page))
+               return 0;

Writeback ignored, in /proc/meminfo.

+       if (page_mapped(page))
+               return 0;

Clean page, mapped into userspace get ignored, in /proc/meminfo.

+       if (page->mapping != mapping)
+               return 0;

Invalidation race, should be none.

+       if (page_has_private(page))
+               return 0;

That's simply wrong. For XFs inodes, that will skip *every page on
every inode* because it attachs bufferheads to every page, even on
read. ext4 behaviour will depend on mount options and whether the
page has been dirtied or not. IOWs, this turns the number of
reclaimable pages in the inode cache into garbage because it counts
clean, reclaimable pages with attached bufferheads as non-reclaimable.

But let's ignore that by assuming you have read-only pages without
bufferheads (e.g. ext4, blocksize = pagesize, nobh mode on read-only
pages). That means the only thing that makes a difference to the
count returned is mapped pages, a count of which is also in
/proc/meminfo.

So, to pick a random active server here:

		before		after
Active(file):   12103200 kB	24060 kB
Inactive(file):  5976676 kB	 1380 kB
Mapped:            31308 kB	31308 kB

How much was not reclaimed? Roughly the same number of pages as the
Mapped count, and that's exactly what we'd expect to see from the
above page walk counting code. Hence a slightly better approximation
of the pages that dropping caches will reclaim is:

reclaimable pages = active + inactive - dirty - writeback - mapped

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
