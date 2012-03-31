Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 775B86B007E
	for <linux-mm@kvack.org>; Sat, 31 Mar 2012 16:29:36 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so3637018pbc.14
        for <linux-mm@kvack.org>; Sat, 31 Mar 2012 13:29:35 -0700 (PDT)
Date: Sat, 31 Mar 2012 13:29:04 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: swap on eMMC and other flash
In-Reply-To: <201203301850.22784.arnd@arndb.de>
Message-ID: <alpine.LSU.2.00.1203311230490.10965@eggly.anvils>
References: <201203301744.16762.arnd@arndb.de> <201203301850.22784.arnd@arndb.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Rik van Riel <riel@redhat.com>, linaro-kernel@lists.linaro.org, linux-mm@kvack.org, "Luca Porzio (lporzio)" <lporzio@micron.com>, Alex Lemberg <alex.lemberg@sandisk.com>, linux-kernel@vger.kernel.org, Saugata Das <saugata.das@linaro.org>, Venkatraman S <venkat@linaro.org>, Yejin Moon <yejin.moon@samsung.com>, Hyojin Jeong <syr.jeong@samsung.com>, "linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>, kernel-team@android.com

On Fri, 30 Mar 2012, Arnd Bergmann wrote:
> On Friday 30 March 2012, Arnd Bergmann wrote:
> 
>  We've had a discussion in the Linaro storage team (Saugata, Venkat and me,
>  with Luca joining in on the discussion) about swapping to flash based media
>  such as eMMC. This is a summary of what we found and what we think should
>  be done. If people agree that this is a good idea, we can start working
>  on it.
>  
>  The basic problem is that Linux without swap is sort of crippled and some
>  things either don't work at all (hibernate) or not as efficient as they
>  should (e.g. tmpfs). At the same time, the swap code seems to be rather
>  inappropriate for the algorithms used in most flash media today, causing
>  system performance to suffer drastically, and wearing out the flash hardware
>  much faster than necessary. In order to change that, we would be
>  implementing the following changes:
>  
>  1) Try to swap out multiple pages at once, in a single write request. My
>  reading of the current code is that we always send pages one by one to
>  the swap device, while most flash devices have an optimum write size of
>  32 or 64 kb and some require an alignment of more than a page. Ideally
>  we would try to write an aligned 64 kb block all the time. Writing aligned
>  64 kb chunks often gives us ten times the throughput of linear 4kb writes,
>  and going beyond 64 kb usually does not give any better performance.

My suspicion is that we suffer a lot from the "distance" between when
we allocate swap space (add_to_swap getting the swp_entry_t to replace
ptes by) and when we finally decide to write out a page (swap_writepage):
intervening decisions can jumble the sequence badly.

I've not investigated to confirm that, but certainly it was the case two
or three years ago, that we got much better behaviour in swapping shmem
to flash, when we stopped giving it a second pass round the lru, which
used to come in between the allocation and the writeout.

I believe that you'll want to start by implementing something like what
Rik set out a year ago in the mail appended below.  Adding another layer
of indirection isn't always a pure win, and I think none of us have taken
it any further since then; but sooner or later we shall need to, and your
flash case might be just the prod needed.

With that change made (so swap ptes are just pointers into an intervening
structure, where we record disk blocks allocated at the time of writeout),
some improvement should come just from traditional merging by the I/O
scheduler (deadline seems both better for flash and better for swap: one
day it would be nice to work out how cfq can be tweaked better for swap).

Some improvement, but probably not enough, and you'd want to do something
more proactive, like the mblk_io_submit stuff ext4 does these days.

Though they might prove to give the greatest benefit on flash,
these kind of changes should be good for conventional disk too.

>  
>  2) Make variable sized swap clusters. Right now, the swap space is
>  organized in clusters of 256 pages (1MB), which is less than the typical
>  erase block size of 4 or 8 MB. We should try to make the swap cluster
>  aligned to erase blocks and have the size match to avoid garbage collection
>  in the drive. The cluster size would typically be set by mkswap as a new
>  option and interpreted at swapon time.

That gets to sound more flash-specific, and I feel less enthusiastic
about doing things in bigger and bigger lumps.  But if it really proves
to be of benefit, it's easy enough to let you.

Decide the cluster size at mkswap time, or at swapon time, or by
/sys/block/sda/queue parameters?  Perhaps a /sys parameter should give
the size, but a swapon flag decide whether to participate or not.  Perhaps.

>  
>  3) As Luca points out, some eMMC media would benefit significantly from
>  having discard requests issued for every page that gets freed from
>  the swap cache, rather than at the time just before we reuse a swap
>  cluster. This would probably have to become a configurable option
>  as well, to avoid the overhead of sending the discard requests on
>  media that don't benefit from this.

I'm surprised, I wouldn't have contemplated a discard per page;
but if you have cases where it can be proved of benefit, fine.
I know nothing at all of eMMC.

Though as things stand, that swap_lock spinlock makes it difficult
to find a good safe moment to issue a discard (you want the spinlock
to keep it safe, but you don't want to issue "I/O" while holding a
spinlock).  Perhaps that difficulty can be overcome in a satisfactory
way, in the course of restructuring swap allocation as Rik set out
(Rik suggests freeing on swapin, that should make it very easy).

Hugh

>  
>  Does this all sound appropriate for the Linux memory management people?
>  
>  Also, does this sound useful to the Android developers? Would you
>  start using swap if we make it perform well and not destroy the drives?
>  
>  Finally, does this plan match up with the capabilities of the
>  various eMMC devices? I know more about SD and USB devices and
>  I'm quite convinced that it would help there, but eMMC can be
>  more like an SSD in some ways, and the current code should be fine
>  for real SSDs.
>  
>  	Arnd
