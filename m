Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 70CD96B005C
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 07:55:04 -0400 (EDT)
Date: Wed, 17 Jun 2009 19:56:34 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH] HWPOISON: only early kill processes who installed
	SIGBUS handler
Message-ID: <20090617115634.GA5924@localhost>
References: <20090615064447.GA18390@wotan.suse.de> <20090615070914.GC31969@one.firstfloor.org> <20090615071907.GA8665@wotan.suse.de> <20090615121001.GA10944@localhost> <20090615122528.GA13256@wotan.suse.de> <20090615142225.GA11167@localhost> <20090617063702.GA20922@localhost> <20090617080404.GB31192@wotan.suse.de> <20090617095532.GA25001@localhost> <20090617100006.GC14915@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090617100006.GC14915@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 17, 2009 at 06:00:06PM +0800, Nick Piggin wrote:
> On Wed, Jun 17, 2009 at 05:55:32PM +0800, Wu Fengguang wrote:
> > On Wed, Jun 17, 2009 at 04:04:04PM +0800, Nick Piggin wrote:
> > > Well then you can still early-kill random apps that did not
> > > want it, and you may still cause problems if its sigbus
> > > handler does something nontrivial.
> > > 
> > > Can you use a prctl or something so it can expclitly
> > > register interest in this?
> > 
> > No I don't think prctl would be much better.
> > 
> > - if an application want early/late kill, it can do so with a proper
> >   written SIGBUS handler: the prctl call is redundant.
> 
> s/proper written/is switched to new semantics based on the existance
> of a/

Not necessarily so. If an application
- did not has a SIGBUS handler, and want to be
  - early killed: must install a handler, this is not a big problem
    because it may well want to rescue something on the event.
  - late killed: just do nothing.
(here kill = 'notification')
- had a SIGBUS hander, and want to
  - early die: call exit(0) in the handler.
  - late die: intercept and ignore the signal.
So if source code modification is viable, prctl is not necessary at all.

> > - if an admin want to control early/late kill for an unmodified app,
> >   prctl is as unhelpful as this patch(*).
> 
> Clearly you can execute a process with a given prctl.

OK, right.

> > - prctl does can help legacy apps whose SIGBUS handler has trouble
> >   with the new SIGBUS codes, however such application should be rare
> >   and the application should be fixed(why shall it do something wrong
> >   on newly introduced code at all? Shall we stop introducing new codes
> >   just because some random buggy app cannot handle new codes?)
> 
> Backwards compatibility? Kind of important.

Maybe.

> > So I still prefer this patch, until we come up with some solution that
> > allows both app and admin to change the setting.
> 
> Not only does it allow that, but it also provides backwards
> compatibility. Your patch does not allow admin to change
> anything nor does it guarantee 100% back compat so I can't
> see how you think it is better.

I didn't say it is better, but clearly mean that prctl is not better
enough to warrant a new user interface, if(!adm_friendly). Now it's
obvious that adm_friendly=1, so I agree prctl is a good interface :)

> Also it does not allow for an app with a SIGBUS handler to
> use late kill. If late kill is useful to anyone, why would
> it not be useful to some app with a SIGBUS handler (that is
> not KVM)?

Late kill will always be sent. Ignore the early kill signal in the
SIGBUS handler does the trick (see above analyzes).

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
