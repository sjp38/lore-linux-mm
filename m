Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 8CDDD6B0083
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 04:33:05 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: swap on eMMC and other flash
Date: Tue, 10 Apr 2012 08:32:51 +0000
References: <201203301744.16762.arnd@arndb.de> <201204091235.48750.arnd@arndb.de> <4F838584.1020002@kernel.org>
In-Reply-To: <4F838584.1020002@kernel.org>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 8bit
Message-Id: <201204100832.52093.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linaro-kernel@lists.linaro.org, android-kernel@googlegroups.com, linux-mm@kvack.org, "Luca Porzio (lporzio)" <lporzio@micron.com>, Alex Lemberg <alex.lemberg@sandisk.com>, linux-kernel@vger.kernel.org, Saugata Das <saugata.das@linaro.org>, Venkatraman S <venkat@linaro.org>, Yejin Moon <yejin.moon@samsung.com>, Hyojin Jeong <syr.jeong@samsung.com>, "linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>

On Tuesday 10 April 2012, Minchan Kim wrote:
> 2012-04-09 i??i?? 9:35, Arnd Bergmann i?' e,?:

> >>
> >> I understand it's best for writing 64K in your statement.
> >> What the 8K, 16K? Could you elaborate relation between 8K, 16K and 64K?
> > 
> > From my measurements, there are three sizes that are relevant here:
> > 
> > 1. The underlying page size of the flash: This used to be less than 4kb,
> > which is fine when paging out 4kb mmu pages, as long as the partition is
> > aligned. Today, most devices use 8kb pages and the number is increasing
> > over time, meaning we will see more 16kb page devices in the future and
> > presumably larger sizes after that. Writes that are not naturally aligned
> > multiples of the page size tend to be a significant problem for the
> > controller to deal with: in order to guarantee that a 4kb write makes it
> > into permanent storage, the device has to write 8kb and the next 4kb
> > write has to go into another 8kb page because each page can only be
> > written once before the block is erased. At a later point, all the partial
> > pages get rewritten into a new erase block, a process that can take
> > hundreds of miliseconds and that we absolutely want to prevent from
> > happening, as it can block all other I/O to the device. Writing all
> > (flash) pages in an erase block sequentially usually avoids this, as
> > long as you don't write to many different erase blocks at the same time.
> > Note that the page size depends on how the controller combines different
> > planes and channels.
> > 
> > 2. The super-page size of the flash: When you have multiple channels
> > between the controller and the individual flash chips, you can write
> > multiple pages simultaneously, which means that e.g. sending 32kb of
> > data to the device takes roughly the same amount of time as writing a
> > single 8kb page. Writing less than the super-page size when there is
> > more data waiting to get written out is a waste of time, although the
> > effects are much less drastic as writing data that is not aligned to
> > pages because it does not require garbage collection.
> > 
> > 3. optimum write size: While writing larger amounts of data in a single
> > request is usually faster than writing less, almost all devices
> > I've seen have a sharp cut-off where increasing the size of the write
> > does not actually help any more because of a bottleneck somewhere
> > in the stack. Writing more than 64kb almost never improves performance
> > and sometimes reduces performance.
> 
> 
> For our understanding, you mean we have to do aligned-write as follows
> if possible?
> 
> "Nand internal page size write(8K, 16K)" < "Super-page size write(32K)
> which considers parallel working with number of channel and plane" <
> some sequential big write (64K)

In the definition I gave above, page size (8k, 16k) would be the only
one that requires alignment. Writing 64k at an arbitrary 16k alignment
should still give us the best performance in almost all cases and
introduce no extra write amplification, while writing with less than
page alignment causes significant write amplification and long latencies.

> 
> > 
> > Note that eMMC-4.5 provides a high-priority interrupt mechamism that
> > lets us interrupt the a write that has hit the garbage collection
> > path, so we can send a more important read request to the device.
> > This will not work on other devices though and the patches for this
> > are still under discussion.
> 
> 
> Nice feature but I think swap system doesn't need to consider such
> feature. I should be handled by I/O subsystem like I/O scheduler.

Right, this is completely independent of swap. The current implementation
of the patch set favours only reads that are done for page-in operations
by interrupting any long-running writes when a more important read comes
in. IMHO we should do the same for any synchronous read, but that discussion
is completely orthogonal to having the swap device on emmc.

> >>>>> 2) Make variable sized swap clusters. Right now, the swap space is
> >>>>> organized in clusters of 256 pages (1MB), which is less than the typical
> >>>>> erase block size of 4 or 8 MB. We should try to make the swap cluster
> >>>>> aligned to erase blocks and have the size match to avoid garbage collection
> >>>>> in the drive. The cluster size would typically be set by mkswap as a new
> >>>>> option and interpreted at swapon time.
> >>>>>
> >>>>
> >>>> If we can find such big contiguous swap slots easily, it would be good.
> >>>> But I am not sure how often we can get such big slots. And maybe we have to
> >>>> improve search method for getting such big empty cluster.
> >>>
> >>> As long as there are clusters available, we should try to find them. When
> >>> free space is too fragmented to find any unused cluster, we can pick one
> >>> that has very little data in it, so that we reduce the time it takes to
> >>> GC that erase block in the drive. While we could theoretically do active
> >>> garbage collection of swap data in the kernel, it won't get more efficient
> >>> than the GC inside of the drive. If we do this, it unfortunately means that
> >>> we can't just send a discard for the entire erase block.
> >>
> >>
> >> Might need some compaction during idle time but WAP concern raises again. :(
> > 
> > Sorry for my ignorance, but what does WAP stand for?
> 
> 
> I should have written more general term. I means write amplication but
> WAF(Write Amplication Factor) is more popular. :(

D'oh. Thanks for the clarification. Note that the entire idea of increasing the
swap cluster size to the erase block size is to *reduce* write amplification:

If we pick arbitrary swap clusters that are part of an erase block (or worse,
span two partial erase blocks), sending a discard for one cluster does not
allow the device to actually discard an entire erase block. Consider the best
possible scenario where we have a 1MB cluster and 2MB erase blocks, all
naturally aligned. After we have written the entire swap device once, all
blocks are marked as used in the device, but some are available for reuse
in the kernel. The swap code picks a cluster that is currently unused and 
sends a discard to the device, then fills the cluster with new pages.
After that, we pick another swap cluster elsewhere. The erase block now
contains 50% new and 50% old data and has to be garbage collected, so the
device writes 2MB of data  to anther erase block. So, in order to write 1MB,
the device has written 3MB and the write amplification factor is 3. Using
8MB erase blocks, it would be 9.

If we do the active compaction and increase the cluster size to the erase
block size, there is no write amplification inside of the device (and no
stalls from the garbage collection, which are the other concern), and
we only need to write a few blocks again that are still valid in a cluster
at the time we want to reuse it. On an ideal device, the write amplification
for active compaction should be exactly the same as what we get when we
write a cluster while some of the data in it is still valid and we skip
those pages, while some devices might now like having to gc themselves.
Doing the compaction in software means we have to spend CPU cycles on it,
but we get to choose when it happens and don't have to block on the device
during GC.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
