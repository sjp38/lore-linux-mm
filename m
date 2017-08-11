Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0891E6B0292
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 05:46:05 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id w187so32268392pgb.10
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 02:46:05 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id y127si261676pgb.962.2017.08.11.02.46.03
        for <linux-mm@kvack.org>;
        Fri, 11 Aug 2017 02:46:03 -0700 (PDT)
Date: Fri, 11 Aug 2017 18:44:48 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v8 06/14] lockdep: Detect and handle hist_lock ring
 buffer overwrite
Message-ID: <20170811094448.GJ20323@X58A-UD3R>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
 <1502089981-21272-7-git-send-email-byungchul.park@lge.com>
 <20170810115922.kegrfeg6xz7mgpj4@tardis>
 <016b01d311d1$d02acfa0$70806ee0$@lge.com>
 <20170810125133.2poixhni4d5aqkpy@tardis>
 <20170810131737.skdyy4qcxlikbyeh@tardis>
 <20170811034328.GH20323@X58A-UD3R>
 <20170811080329.3ehu7pp7lcm62ji6@tardis>
 <20170811085201.GI20323@X58A-UD3R>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170811085201.GI20323@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boqun Feng <boqun.feng@gmail.com>
Cc: peterz@infradead.org, mingo@kernel.org, tglx@linutronix.de, walken@google.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Fri, Aug 11, 2017 at 05:52:02PM +0900, Byungchul Park wrote:
> On Fri, Aug 11, 2017 at 04:03:29PM +0800, Boqun Feng wrote:
> > Thanks for taking a look at it ;-)
> 
> I rather appriciate it.
> 
> > > > @@ -5005,7 +5003,7 @@ static int commit_xhlock(struct cross_lock *xlock, struct hist_lock *xhlock)
> > > >  static void commit_xhlocks(struct cross_lock *xlock)
> > > >  {
> > > >  	unsigned int cur = current->xhlock_idx;
> > > > -	unsigned int prev_hist_id = xhlock(cur).hist_id;
> > > > +	unsigned int prev_hist_id = cur + 1;
> > > 
> > > I should have named it another. Could you suggest a better one?
> > > 
> > 
> > I think "prev" is fine, because I thought the "previous" means the
> > xhlock item we visit _previously_.
> > 
> > > >  	unsigned int i;
> > > >  
> > > >  	if (!graph_lock())
> > > > @@ -5030,7 +5028,7 @@ static void commit_xhlocks(struct cross_lock *xlock)
> > > >  			 * hist_id than the following one, which is impossible
> > > >  			 * otherwise.
> > > 
> > > Or we need to modify the comment so that the word 'prev' does not make
> > > readers confused. It was my mistake.
> > > 
> > 
> > I think the comment needs some help, but before you do it, could you
> > have another look at what Peter proposed previously? Note you have a
> > same_context_xhlock() check in the commit_xhlocks(), so the your
> > previous overwrite case actually could be detected, I think.
> 
> What is the previous overwrite case?
> 
> ppppppppppwwwwwwwwwwwwiiiiiiiii
> iiiiiiiiiiiiiii................
> 
> Do you mean this one? I missed the check of same_context_xhlock(). Yes,
> peterz's suggestion also seems to work.
> 
> > However, one thing may not be detected is this case:
> > 
> > 		ppppppppppppppppppppppppppppppppppwwwwwwww
> > wrapped >	wwwwwww
> 
> To be honest, I think your suggestion is more natual, with which this
> case would be also covered.
> 
> > 
> > 	where p: process and w: worker.
> > 
> > , because p and w are in the same task_irq_context(). I discussed this
> > with Peter yesterday, and he has a good idea: unconditionally do a reset
> > on the ring buffer whenever we do a crossrelease_hist_end(XHLOCK_PROC).

Ah, ok. You meant 'whenever _process_ context exit'.

I need more time to be sure, but anyway for now it seems to work with
giving up some chances for remaining xhlocks.

But, I am not sure if it's still true even in future and the code can be
maintained easily. I think your approach is natural and neat enough for
that purpose. What problem exists with yours?

> > Basically it means we empty the lock history whenever we finished a
> > worker function in a worker thread or we are about to return to
> > userspace after we finish the syscall. This could further save some
> > memory and so I think this may be better than my approach.
> 
> Do you mean reset _whenever_ hard irq exit, soft irq exit or work exit?
> Why should we give up chances to check dependencies of remaining xhlocks
> whenever each exit? Am I understanding correctly?
> 
> I am just curious. Does your approach have some problems?
> 
> Thanks,
> Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
