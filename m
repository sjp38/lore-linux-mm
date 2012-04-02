Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id EF3366B0044
	for <linux-mm@kvack.org>; Mon,  2 Apr 2012 07:46:01 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: swap on eMMC and other flash
Date: Mon, 2 Apr 2012 11:45:42 +0000
References: <201203301744.16762.arnd@arndb.de> <201203301850.22784.arnd@arndb.de> <alpine.LSU.2.00.1203311230490.10965@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1203311230490.10965@eggly.anvils>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201204021145.43222.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linaro-kernel@lists.linaro.org
Cc: Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, "linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>, Alex Lemberg <alex.lemberg@sandisk.com>, linux-kernel@vger.kernel.org, "Luca Porzio (lporzio)" <lporzio@micron.com>, linux-mm@kvack.org, Hyojin Jeong <syr.jeong@samsung.com>, kernel-team@android.com, Yejin Moon <yejin.moon@samsung.com>

On Saturday 31 March 2012, Hugh Dickins wrote:
> On Fri, 30 Mar 2012, Arnd Bergmann wrote:
> > On Friday 30 March 2012, Arnd Bergmann wrote:

> My suspicion is that we suffer a lot from the "distance" between when
> we allocate swap space (add_to_swap getting the swp_entry_t to replace
> ptes by) and when we finally decide to write out a page (swap_writepage):
> intervening decisions can jumble the sequence badly.
> 
> I've not investigated to confirm that, but certainly it was the case two
> or three years ago, that we got much better behaviour in swapping shmem
> to flash, when we stopped giving it a second pass round the lru, which
> used to come in between the allocation and the writeout.
> 
> I believe that you'll want to start by implementing something like what
> Rik set out a year ago in the mail appended below.  Adding another layer
> of indirection isn't always a pure win, and I think none of us have taken
> it any further since then; but sooner or later we shall need to, and your
> flash case might be just the prod needed.

Thanks a lot for that pointer, that certainly sounds interesting. I guess
we should first do some investigations into in what order the pages normally
get writting out to flash. If they are not strictly in sequence order, the
other improvements I suggested would be less effective as well.

Note that I'm not at all worried about reading pages back in from flash
out of order, that tends to be harmless because reads are much rarer than
writes on swap, and because only random writes require garbage collection
inside of the flash (forcing up to 500ms delays on a single write
occasionally), while reads are always uniformly fast.

> >  2) Make variable sized swap clusters. Right now, the swap space is
> >  organized in clusters of 256 pages (1MB), which is less than the typical
> >  erase block size of 4 or 8 MB. We should try to make the swap cluster
> >  aligned to erase blocks and have the size match to avoid garbage collection
> >  in the drive. The cluster size would typically be set by mkswap as a new
> >  option and interpreted at swapon time.
> 
> That gets to sound more flash-specific, and I feel less enthusiastic
> about doing things in bigger and bigger lumps.  But if it really proves
> to be of benefit, it's easy enough to let you.
> 
> Decide the cluster size at mkswap time, or at swapon time, or by
> /sys/block/sda/queue parameters?  Perhaps a /sys parameter should give
> the size, but a swapon flag decide whether to participate or not.  Perhaps.

I was think of mkswap time, because the erase block size is specific to
the storage hardware and there is no reason to ever change it run time,
and we cannot always easily probe the value from looking at hardware
registers (USB doesn't have the data, in SD cards it's usually wrong,
and in eMMC it's sometimes wrong). I should also mention that it's not
always power-of-two, some drives that use TLC flash have three times
the erase block size of the equivalent SLC flash, e.g. 3 MB or 6 MB.

I don't think that's a problem, but I might be missing something here.
I have also encoutered a few older drives that use some completely
random erase block size, but they are very rare.

Also, I'm unsure what the largest cluster size would be that we can
realistically support. 8 MB sounds fairly large already, especially
on systems that have less than 1 GB of RAM, as most of the ARM machines
today do. For shingle based hard drives, we would get a very similar
behavior as for flash media, but the chunks would be even larger,
on the order of 64 MB. If we can make those work, it would no longer
be specific to flash, but also a lot harder to do.

> >  3) As Luca points out, some eMMC media would benefit significantly from
> >  having discard requests issued for every page that gets freed from
> >  the swap cache, rather than at the time just before we reuse a swap
> >  cluster. This would probably have to become a configurable option
> >  as well, to avoid the overhead of sending the discard requests on
> >  media that don't benefit from this.
> 
> I'm surprised, I wouldn't have contemplated a discard per page;
> but if you have cases where it can be proved of benefit, fine.
> I know nothing at all of eMMC.

My understanding is that some devices can arbitrarily map between
physical flash pages (typically 4, 8, or 16kb) and logical sector
numbers, instead of remapping on the much larger erase block
granularity. In those cases, it makes sense to free up as many
pages as possible on the drive, in order to give the hardware more
room for reorganizing itself and doing background defragmentation
of its free space.

> Though as things stand, that swap_lock spinlock makes it difficult
> to find a good safe moment to issue a discard (you want the spinlock
> to keep it safe, but you don't want to issue "I/O" while holding a
> spinlock).  Perhaps that difficulty can be overcome in a satisfactory
> way, in the course of restructuring swap allocation as Rik set out
> (Rik suggests freeing on swapin, that should make it very easy).

Luca was suggesting to use the disk->fops->swap_slot_free_notify
callback from  swap_entry_free(), which is currently only used
in zram, but you're right, that would not work.

Another option would be batched discard as we do it for file systems:
occasionally stop writing to swap space and scanning for areas that
have become available since the last discard, then send discard
commands for those.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
