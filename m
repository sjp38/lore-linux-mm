Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 5C04B6B004D
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 05:50:33 -0400 (EDT)
Date: Fri, 12 Jun 2009 11:52:06 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH v2] slab,slub: ignore __GFP_WAIT if we're booting or suspending
Message-ID: <20090612095206.GA13607@wotan.suse.de>
References: <Pine.LNX.4.64.0906121113210.29129@melkki.cs.Helsinki.FI> <Pine.LNX.4.64.0906121201490.30049@melkki.cs.Helsinki.FI> <20090612091002.GA32052@elte.hu> <84144f020906120249y20c32d47y5615a32b3c9950df@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <84144f020906120249y20c32d47y5615a32b3c9950df@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, akpm@linux-foundation.org, cl@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 12, 2009 at 12:49:17PM +0300, Pekka Enberg wrote:
> On Fri, Jun 12, 2009 at 12:10 PM, Ingo Molnar<mingo@elte.hu> wrote:
> >> @@ -1548,6 +1548,20 @@ new_slab:
> >>               goto load_freelist;
> >>       }
> >>
> >> +     /*
> >> +      * Lets not wait if we're booting up or suspending even if the user
> >> +      * asks for it.
> >> +      */
> >> +     if (system_state != SYSTEM_RUNNING)
> >> +             gfpflags &= ~__GFP_WAIT;
> >
> > Hiding that bug like that is not particularly clean IMO. We should
> > not let system_state hacks spread like that.
> >
> > We emit a debug warning but dont crash, so all should be fine and
> > the culprits can then be fixed, right?
> 
> OK, lets not use system_state then and go with Ben's approach then.
> Again, neither of the patches are about "hiding buggy callers" but
> changing allocation policy wrt. gfp flags during boot (and later on
> during suspend).

Maybe if we just not make it a general "tweak gfpflag" bit (at
least not until a bit more discussion), but a specific workaround
for the local_irq_enable in early boot problem.

Seems like it would not be hard to track things down if we add
a warning if we have GFP_WAIT and interrupts are not enabled...


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
