Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B9B826B005C
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 06:07:50 -0400 (EDT)
Date: Fri, 12 Jun 2009 12:07:56 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH v2] slab,slub: ignore __GFP_WAIT if we're booting or
	suspending
Message-ID: <20090612100756.GA25185@elte.hu>
References: <Pine.LNX.4.64.0906121113210.29129@melkki.cs.Helsinki.FI> <Pine.LNX.4.64.0906121201490.30049@melkki.cs.Helsinki.FI> <20090612091002.GA32052@elte.hu> <84144f020906120249y20c32d47y5615a32b3c9950df@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <84144f020906120249y20c32d47y5615a32b3c9950df@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, npiggin@suse.de, benh@kernel.crashing.org, akpm@linux-foundation.org, cl@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>


* Pekka Enberg <penberg@cs.helsinki.fi> wrote:

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
> OK, lets not use system_state then and go with Ben's approach 
> then. Again, neither of the patches are about "hiding buggy 
> callers" but changing allocation policy wrt. gfp flags during boot 
> (and later on during suspend).

IMHO such invisible side-channels modifying the semantics of GFP 
flags is a bit dubious.

We could do GFP_INIT or GFP_BOOT. These can imply other useful 
modifiers as well: panic-on-failure for example. (this would clean 
up a fair amount of init code that currently checks for an panics on 
allocation failure.)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
