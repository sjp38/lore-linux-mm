Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C89E26B0085
	for <linux-mm@kvack.org>; Fri,  9 Jan 2009 14:01:04 -0500 (EST)
Date: Fri, 9 Jan 2009 11:00:25 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Increase dirty_ratio and dirty_background_ratio?
Message-Id: <20090109110025.213bd8bb.akpm@linux-foundation.org>
In-Reply-To: <20090109180241.GA15023@duck.suse.cz>
References: <alpine.LFD.2.00.0901070833430.3057@localhost.localdomain>
	<20090107.125133.214628094.davem@davemloft.net>
	<20090108030245.e7c8ceaf.akpm@linux-foundation.org>
	<20090108.082413.156881254.davem@davemloft.net>
	<alpine.LFD.2.00.0901080842180.3283@localhost.localdomain>
	<1231433701.14304.24.camel@think.oraclecorp.com>
	<alpine.LFD.2.00.0901080858500.3283@localhost.localdomain>
	<20090108195728.GC14560@duck.suse.cz>
	<20090109180241.GA15023@duck.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Chris Mason <chris.mason@oracle.com>, David Miller <davem@davemloft.net>, peterz@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Fri, 9 Jan 2009 19:02:41 +0100 Jan Kara <jack@suse.cz> wrote:

> On Thu 08-01-09 20:57:28, Jan Kara wrote:
> > On Thu 08-01-09 09:05:01, Linus Torvalds wrote:
> > > On Thu, 8 Jan 2009, Chris Mason wrote:
> > > > 
> > > > Does it make sense to hook into kupdate?  If kupdate finds it can't meet
> > > > the no-data-older-than 30 seconds target, it lowers the sync/async combo
> > > > down to some reasonable bottom.  
> > > > 
> > > > If it finds it is going to sleep without missing the target, raise the
> > > > combo up to some reasonable top.
> > > 
> > > I like autotuning, so that sounds like an intriguing approach. It's worked 
> > > for us before (ie VM).
> > > 
> > > That said, 30 seconds sounds like a _loong_ time for something like this. 
> > > I'd use the normal 5-second dirty_writeback_interval for this: if we can't 
> > > clean the whole queue in that normal background writeback interval, then 
> > > we try to lower the tagets. We already have that "congestion_wait()" thing 
> > > there, that would be a logical place, methinks.
> >   But I think there are workloads for which this is suboptimal to say the
> > least. Imagine you do some crazy LDAP database crunching or other similar load
> > which randomly writes to a big file (big means it's size is rougly
> > comparable to your available memory). Kernel finds pdflush isn't able to
> > flush the data fast enough so we decrease dirty limits. This results in
> > even more agressive flushing but that makes things even worse (in a sence
> > that your application runs slower and the disk is busy all the time anyway).
> > This is the kind of load where we observe problems currently.
> >   Ideally we could observe that we write out the same pages again and again
> > (or even pages close to them) and in that case be less agressive about
> > writeback on the file. But it feels a bit overcomplicated...
>   And there's actually one more thing that probably needs some improvement
> in the writeback algorithms:
>   What we observe in the seekwatcher graphs is, that there are three
> processes writing back the single database file in parallel (2 pdflush
> threads because the machine has 2 CPUs, and the database process itself
> because of dirty throttling). Each of the processes is writing back the
> file at a different offset and so they together create even more random IO
> (I'm attaching the graph and can provide blocktrace data if someone is
> interested). If there was just one process doing the writeback, we'd be
> writing back those data considerably faster...

A database application really should be taking care of the writeback
scheduling itself, rather than hoping that the kernel behaves optimally.

yeah, it'd be nice if the kernel was perfect.  But in the real world,
there will always be gains available by smart use of (say)
sync_file_range().  Because the application knows more about its writeout
behaviour (especialy _future_ behaviour) than the kernel ever will.

>   This problem could have reasonably easy solution. IMHO if there is one
> process doing writeback on a block device, there's no point for another
> process to do any writeback on that device. Block device congestion
> detection is supposed to avoid this I think but it does not work quite well
> in this case. The result is (I guess) that all the three threads are calling
> write_cache_pages() on that single DB file, eventually the congested flag
> is cleared from the block device, now all three threads hugrily jump on 
> the file and start writing which quickly congests the device again...
>   My proposed solution would be that we'll have two flags per BDI -
> PDFLUSH_IS_WRITING_BACK and THROTTLING_IS_WRITING_BACK. They are set /
> cleared as their names suggest. When pdflush sees THROTTLING took place,
> it relaxes and let throttled process to do the work. Also pdflush would
> not try writeback on devices that have PDFLUSH_IS_WRITING_BACK flag set
> (OK, we should know that *this* pdflush thread set this flag for the device
> and do writeback then, but I think you get the idea). This could improve
> the situation at least for smaller machines, what do you think? I
> understand that there might be problem on machines with a lot of CPUs where
> one thread might not be fast enough to send out all the dirty data created
> by other CPUs. But as long as there is just one backing device, does it
> really help to have more threads doing writeback even on a big machine?

Yes, the XFS guys have said that some machines run out of puff when
only one CPU is doing writeback.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
