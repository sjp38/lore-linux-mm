Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 61EF45F0001
	for <linux-mm@kvack.org>; Mon,  2 Feb 2009 06:56:40 -0500 (EST)
Received: by ti-out-0910.google.com with SMTP id j3so768050tid.8
        for <linux-mm@kvack.org>; Mon, 02 Feb 2009 03:56:37 -0800 (PST)
Date: Mon, 2 Feb 2009 20:56:27 +0900
From: MinChan Kim <minchan.kim@gmail.com>
Subject: Re: [BUG??] Deadlock between kswapd and
	sys_inotify_add_watch(lockdep  report)
Message-ID: <20090202115627.GB13532@barrios-desktop>
References: <20090202101735.GA12757@barrios-desktop> <28c262360902020225w6419089ft2dda30da9dfb32a9@mail.gmail.com> <1233571202.4787.124.camel@laptop> <20090202112721.GA13532@barrios-desktop> <1233575085.4787.140.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1233575085.4787.140.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Nick Piggin <npiggin@suse.de>, linux kernel <linux-kernel@vger.kernel.org>, linux mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Thanks for kind explanation. :)
Unfortunately, I still have a question. :(

On Mon, Feb 02, 2009 at 12:44:45PM +0100, Peter Zijlstra wrote:
> On Mon, 2009-02-02 at 20:27 +0900, MinChan Kim wrote:
> > On Mon, Feb 02, 2009 at 11:40:02AM +0100, Peter Zijlstra wrote:
> > > On Mon, 2009-02-02 at 19:25 +0900, MinChan Kim wrote:
> > > > But, I am not sure whether it's real bug or not.
> > > 
> > > Me neither, inode life-times are tricky, but on first sight it looks
> > > real enough.
> > > 
> > > > I always suffer from reading lockdep report's result. :(
> > > > It would be better to have a document about lockdep report analysis.
> > > 
> > > I've never found them hard to read, so I'm afraid you'll have to be more
> > > explicit about what is unclear to you.
> > 
> > It's becuase not lockdep humble report but my poor knowledge. :(
> > Could you elaborate please ?
> > 
> > >[  331.718120] [ INFO: inconsistent lock state ]
> > >[  331.718124] 2.6.28-rc2-mm1-lockdep #6
> > >[  331.718126] ---------------------------------
> > >[  331.718129] inconsistent {ov-reclaim-W} -> {in-reclaim-W} usage.
> >                                          ^                 ^ 
> >                                         write ?           write ?
> 
> Correct, we track states for read and write, for single state locks we
> map everything on the exclusive state (write).
> 
> > >
> > >[  331.718133] kswapd0/218 [HC0[0]:SC0[0]:HE0:SE1] takes:
> >                             ^^^^^^^^^^^^^^^^^^^^^^
> >                             what means ? HC,SC,HE,SE
> 
> Ah, yes, that's a bit obscure, but usually not needed.
> 
> Hardirq Context -- irq state tracking [preempt_count tracking]
> Softirq Context -- idem
> 
> Hardirq Enabled
> Softirq Enabled
> 
> It allows you to see if the irq state tracking matches up, and what the
> call context is.
> 
> > >
> > >[  331.718136]  (&inode->inotify_mutex){--..+.}, at: [<c01dba70>] inotify_inode_is_dead+0x20/0x90
> > >             
> > 
> > Is it related to recursive lock of inotify_mutex ?
> 
> Yes.
> 
> > but, Subject means 'inconsistent {ov-reclaim-W} -> {in-reclaim-W}', 
> > IOW, it's related to reclaim of GFP_FS. 
> > What's relation inotify_mutex and reclaim of GFP_FS?
> 
> The lockdep report states the following:
> 
> While holding inotify_mutex, we do a __GFP_FS allocation.
> But __GFP_FS allocations can end up locking inotify_mutex.
> 
> > I think if reclaim context which have GFP_FS already have lock A and then 
> > do pageout, if writepage need the lock A, we have to catch such a case. 
> > I thought Nick's patch's goal catchs such a case. 
> 
> Correct, it exactly does that.

But, I think such a case can be caught by lockdep of recursive detection 
which is existed long time ago by making you.
what's difference Nick's patch and recursive lockdep ?

-- 
Kinds Regards
MinChan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
