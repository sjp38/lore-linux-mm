Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id CA5CF6B004D
	for <linux-mm@kvack.org>; Sun, 22 Jan 2012 10:49:56 -0500 (EST)
Message-ID: <1327247393.2834.15.camel@dabdike.int.hansenpartnership.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] [ATTEND] Future writeback topics
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Sun, 22 Jan 2012 09:49:53 -0600
In-Reply-To: <4F1C2D45.4090208@panasas.com>
References: <4F1C141C.2050704@panasas.com>
	 <1327243783.2834.6.camel@dabdike.int.hansenpartnership.com>
	 <4F1C2D45.4090208@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, "Martin K. Petersen" <martin.petersen@oracle.com>, linux-scsi <linux-scsi@vger.kernel.org>, Dave Chinner <david@fromorbit.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

[corrected linux-mm address I mistyped initially]
On Sun, 2012-01-22 at 17:37 +0200, Boaz Harrosh wrote:
> On 01/22/2012 04:49 PM, James Bottomley wrote:
> > Since a lot of these are mm related; added linux-mm to cc list
> > 
> 
> Hi James.
> 
> Thanks for reading, and sorry I missed linux-mm
> 
> > On Sun, 2012-01-22 at 15:50 +0200, Boaz Harrosh wrote:
> >> Hi
> >>
> >> Now that we have the "IO-less dirty throttling" in and kicking (ass I might say)
> >> Are there plans for second stage? I can see few areas that need some love.
> >>
> >> [IO Fairness, time sorted writeback, properly delayed writeback]
> >>
> >>   As we started to talk about in another thread: "[LSF/MM TOPIC] a few storage topics"
> >>   I would like to propose the following topics:
> >>
> >> * Do we have enough information for the time of dirty of pages, such as the
> >>   IO-elevators information, readily available to be used at the VFS layer.
> >> * BDI writeout should be smarter then a round robin cycle of SBs per BDI /
> >>   inodes. It should be time based, writing the oldest data first.
> >>   (Take the lowest indexed page of an inode as the dirty time of the inode.
> >>    maybe also keep an oldest modified inode per-SB of a BDI)
> >>
> >>   This can solve the IO fairness and latency bound (interactivness) of small
> >>   IOs.
> >>   There might be other solutions to this problem, any Ideas?
> >>
> >> * Introduce an "aging time" factor of an inode which will postpone the writeout
> >>   of an inode to the next writeback timer if the inode has "just changed".
> >>
> >>   This can solve the problem of an application doing heavy modification of some
> >>   area of a file and the writeback timer sampling that change too soon and forcing
> >>   pages to change during IO, as well as having split IO where waiting for the next
> >>   cycle could have the complete modification in a singe submit.
> >>
> >>
> >> [Targeted writeback (IO-less page-reclaim)]
> >>   Sometimes we would need to write a certain page or group of pages. It could be
> >>   nice to prioritize/start the writeback on these pages, through the regular writeback
> >>   mechanism instead of doing direct IO like today.
> >>
> >>   This is actually related to above where we can have a "write_now" time constant that
> >>   makes the priority of that inode to be written first. Then we also need the page-info
> >>   that we want to write as part of that inode's IO. Usually today we start at the lowest
> >>   indexed page of the inode, right? In targeted writeback we should make sure the writeout
> >>   is the longest contiguous (aligned) dirty region containing the targeted page.
> >>
> >>   With this in place we can also move to an IO-less page-reclaim. that is done entirely by
> >>   the BDI thread writeback. (Need I say more)
> > 
> > All of the above are complex.  The only reason for adding complexity in
> > our writeback path should be because we can demonstrate that it's
> > actually needed.  In order to demonstrate this, you'd need performance
> > measurements ... is there a plan to get these before the summit?
> > 
> 
> Some measurements have already been done and complained about. There were even attempts
> at IO-less page-reclaim by Dave Chinner if I recall correctly. Mainly the complains I'm
> addressing here are:
>  1. Very bad IO patterns of page-reclaim and it's avoidance.
>  2. The issue raised in that other thread about pages changing during IO penalty.
>  3. Oblivious-ness of the VFS writeback to fairness and the starvation of small IOs
>    in filesystems that are not block based.
> 
> But I agree much more testing is needed specially for 3. I can't promise I'll be up to it
> for LSF.

As long as someone does them, I don't really care who.

> Even more blasphemous of me is that I'm not the one that could code such changes,
> I'm not familiar and capable with the VFS code to do such a task. I only know that as a
> filesystem these are areas that are missed.

Well, OK, we'll treat this as a Call for a Topic rather than a topic
(depending on whether someone is willing to do the work and talk about
it) ... or we can just fold it into the general writeback discussion ...
I'm sure there'll be one of those.

> >> [Aligned IO]
> >>
> >>   Each BDI should have a way to specify it's Alignment preferences and optimum IO sizes
> >>   and the VFS writeout can take that into consideration when submitting IO.
> >>
> >>   This can both reduce lots of work done at individual filesystems, as well as benefit
> >>   lots of other filesystems that did not take care of this. It can also make the life of
> >>   some of the FSs that do care, a lot easier. Producing IO patterns that are much better
> >>   then what can be achieved today with the FS trying to second guess the VFS.
> > 
> > Since a bdi is coupled to a gendisk and a queue, why isn't
> > optimal_io_size what you want?
> > 
> 
> Exactly for block-based devices these are intended here. The "register block BDI" will
> fill these in from there. It must be at the BDI level for these FSs that are not block
> based but have similar alignment needs. And/or also filesystems that are multidevice
> like BTRFS and ZFS(Fuse) which have conglomerated alignment needs.

But this topic then becomes adding alignment for non block backed
filesystems?  I take it you're thinking NFS rather than MTD or MMC?

For multiple devices, you do a simple cascade ... a bit like dm does
today ... but unless all the devices are aligned to optimal I/O it never
really works (and it's not necessarily worth solving ... the idea that
if you want performance from an array of devices, you match
characteristics isn't a hugely hard one to get the industry to swallow).

> >> [IO less sync]
> >>
> >>   This topic is actually related to the above Aligned IO. 
> >>
> >>   In today's code, in a regular write pattern, when an application is writing a long
> >>   enough file, we have two sources of threads for the .write_pages vector. One is the
> >>   BDI write_back thread, the other is the sync operation. This produces nightmarish IO
> >>   patterns when the write_cache_pages() is re-entrant and each instance is fighting the
> >>   other in garbing random pages, this is bad because of two reasons:
> >>    1. makes each instance grab a none contiguous set of pages which causes the IO
> >>       to split and be none-aligned.
> >>    2. Causes Seeky IO where otherwise the application just wrote linear IO of
> >>       a large file and then sync.
> >>
> >>   The IO pattern is so bad that in some cases it is better to serialize the call to
> >>   write_cache_pages() to avoid it. Even with the cost of a Mutex at every call
> >>
> >>   Would it be hard to have "sync" set some info, raise a flag, fire up the writeback
> >>   and wait for it to finish? writeback in it's turn should switch to a sync mode on that
> >>   inode. (The sync operation need not change the writeback priority in my opinion like
> >>   today)
> > 
> > This is essentially what we've been discussing in "Fixing Writeback" for
> > the last two years, isn't it (the fact that we have multiple sources of
> > writeback and they don't co-ordinate properly).  I thought our solution
> > was to prefer linear over seeky ... 
> 
> Yes. Lots of work has been done, and as part of that a tremendous clean up
> has also been submitted and the code is kind of ready for the next round.
> 
> Some of these things we've been talking about for years as you said but are
> not yet done. For example my problem of seeky IO when the application
> just gave us perfectly linear writeout. This is why I said:
>  Are we ready for the second round?

OK, will defer to mm guys.

> > adding a mutex makes that more
> > absolute than a preference, but are you sure it helps (especially as it
> > adds a lock to the writeout path).
> 
> No, I'm not sure at all. I just gave an example at some example filesystem
> (exofs that I work on) where the penalty for non aligned IO is so bad (Raid 5)
> that a Mutex at every IO gave better performance then the above problem. I have
> not submitted this lock at the end because it is only for the large-file
> IO case, so in the General workloads I could not prove if it's better or
> not.

Global mutexes add a latency to the fast path ... this latency rises
with the NUMA ness or number of cores on the system ... that's why it
hit my "are you really sure" detector.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
