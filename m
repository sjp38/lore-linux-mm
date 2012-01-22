Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 0B7F26B004D
	for <linux-mm@kvack.org>; Sun, 22 Jan 2012 10:27:17 -0500 (EST)
Message-ID: <1327246034.2834.7.camel@dabdike.int.hansenpartnership.com>
Subject: Re: [LSF/MM TOPIC] [ATTEND] Future writeback topics
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Sun, 22 Jan 2012 09:27:14 -0600
In-Reply-To: <4F1C141C.2050704@panasas.com>
References: <4F1C141C.2050704@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-scsi <linux-scsi@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, "Martin K.
 Petersen" <martin.petersen@oracle.com>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org

Since a lot of these are mm related; added linux-mm to cc list

On Sun, 2012-01-22 at 15:50 +0200, Boaz Harrosh wrote:
> Hi
> 
> Now that we have the "IO-less dirty throttling" in and kicking (ass I might say)
> Are there plans for second stage? I can see few areas that need some love.
> 
> [IO Fairness, time sorted writeback, properly delayed writeback]
> 
>   As we started to talk about in another thread: "[LSF/MM TOPIC] a few storage topics"
>   I would like to propose the following topics:
> 
> * Do we have enough information for the time of dirty of pages, such as the
>   IO-elevators information, readily available to be used at the VFS layer.
> * BDI writeout should be smarter then a round robin cycle of SBs per BDI /
>   inodes. It should be time based, writing the oldest data first.
>   (Take the lowest indexed page of an inode as the dirty time of the inode.
>    maybe also keep an oldest modified inode per-SB of a BDI)
> 
>   This can solve the IO fairness and latency bound (interactivness) of small
>   IOs.
>   There might be other solutions to this problem, any Ideas?
> 
> * Introduce an "aging time" factor of an inode which will postpone the writeout
>   of an inode to the next writeback timer if the inode has "just changed".
> 
>   This can solve the problem of an application doing heavy modification of some
>   area of a file and the writeback timer sampling that change too soon and forcing
>   pages to change during IO, as well as having split IO where waiting for the next
>   cycle could have the complete modification in a singe submit.
> 
> 
> [Targeted writeback (IO-less page-reclaim)]
>   Sometimes we would need to write a certain page or group of pages. It could be
>   nice to prioritize/start the writeback on these pages, through the regular writeback
>   mechanism instead of doing direct IO like today.
> 
>   This is actually related to above where we can have a "write_now" time constant that
>   makes the priority of that inode to be written first. Then we also need the page-info
>   that we want to write as part of that inode's IO. Usually today we start at the lowest
>   indexed page of the inode, right? In targeted writeback we should make sure the writeout
>   is the longest contiguous (aligned) dirty region containing the targeted page.
> 
>   With this in place we can also move to an IO-less page-reclaim. that is done entirely by
>   the BDI thread writeback. (Need I say more)

All of the above are complex.  The only reason for adding complexity in
our writeback path should be because we can demonstrate that it's
actually needed.  In order to demonstrate this, you'd need performance
measurements ... is there a plan to get these before the summit?

> [Aligned IO]
> 
>   Each BDI should have a way to specify it's Alignment preferences and optimum IO sizes
>   and the VFS writeout can take that into consideration when submitting IO.
> 
>   This can both reduce lots of work done at individual filesystems, as well as benefit
>   lots of other filesystems that did not take care of this. It can also make the life of
>   some of the FSs that do care, a lot easier. Producing IO patterns that are much better
>   then what can be achieved today with the FS trying to second guess the VFS.

Since a bdi is coupled to a gendisk and a queue, why isn't
optimal_io_size what you want?

> [IO less sync]
> 
>   This topic is actually related to the above Aligned IO. 
> 
>   In today's code, in a regular write pattern, when an application is writing a long
>   enough file, we have two sources of threads for the .write_pages vector. One is the
>   BDI write_back thread, the other is the sync operation. This produces nightmarish IO
>   patterns when the write_cache_pages() is re-entrant and each instance is fighting the
>   other in garbing random pages, this is bad because of two reasons:
>    1. makes each instance grab a none contiguous set of pages which causes the IO
>       to split and be none-aligned.
>    2. Causes Seeky IO where otherwise the application just wrote linear IO of
>       a large file and then sync.
> 
>   The IO pattern is so bad that in some cases it is better to serialize the call to
>   write_cache_pages() to avoid it. Even with the cost of a Mutex at every call
> 
>   Would it be hard to have "sync" set some info, raise a flag, fire up the writeback
>   and wait for it to finish? writeback in it's turn should switch to a sync mode on that
>   inode. (The sync operation need not change the writeback priority in my opinion like
>   today)

This is essentially what we've been discussing in "Fixing Writeback" for
the last two years, isn't it (the fact that we have multiple sources of
writeback and they don't co-ordinate properly).  I thought our solution
was to prefer linear over seeky ... adding a mutex makes that more
absolute than a preference, but are you sure it helps (especially as it
adds a lock to the writeout path).

James


--
To unsubscribe from this list: send the line "unsubscribe linux-scsi" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
