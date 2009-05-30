Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9BC166B00F2
	for <linux-mm@kvack.org>; Sat, 30 May 2009 15:08:34 -0400 (EDT)
Date: Sat, 30 May 2009 21:08:28 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page
	allocator
Message-ID: <20090530190828.GA31199@elte.hu>
References: <20090528090836.GB6715@elte.hu> <20090528125042.28c2676f@lxorguk.ukuu.org.uk> <84144f020905300035g1d5461f9n9863d4dcdb6adac0@mail.gmail.com> <20090530075033.GL29711@oblivion.subreption.com> <4A20E601.9070405@cs.helsinki.fi> <20090530082048.GM29711@oblivion.subreption.com> <20090530173428.GA20013@elte.hu> <20090530180333.GH6535@oblivion.subreption.com> <20090530182113.GA25237@elte.hu> <20090530184534.GJ6535@oblivion.subreption.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090530184534.GJ6535@oblivion.subreption.com>
Sender: owner-linux-mm@kvack.org
To: "Larry H." <research@subreption.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


* Larry H. <research@subreption.com> wrote:

> On 20:21 Sat 30 May     , Ingo Molnar wrote:
> > SLOB is a rarely used (and high overhead) allocator. But the right 
> > answer there: fix kzalloc().
> 
> If it's rarely used and nobody cares, why nobody has removed it yet?
> Sames like the very same argument Peter and you used at some point
> against these patches. Later in your response here you state the same
> for kzfree. Interesting.
> 
> > if kzfree() is broken then a number of places in the kernel that 
> > currently rely on it are potentially broken as well.
> 
> Indeed, but it was sitting there unused up to 2.6.29.4. Apparently only
> -30-rc2 introduces users of the patch. Someone didn't do his homework
> signing off the patch without testing it properly.
> 
> > So as far as i'm concerned, your patchset is best expressed in the 
> > following form: Cryto, WEP and other sensitive places should be 
> > updated to use kzfree() to free keys.
> > 
> > This can be done unconditionally (without any Kconfig flag), as it's 
> > all in slow-paths - and because there's a real security value in 
> > sanitizing buffers that held sensitive keys, when they are freed.
> 
> And the tty buffers, and the audit buffers, and the crypto block 
> alg contexts, and the generic algorithm contexts, and the input 
> buffers contexts, and ... alright, I get the picture!

Correct. Those are all either slowpaths or low-bandwidth paths. 

It's much better to help security in general for the cases where it 
can be done unconditionally - than to provide an option (that 
everyone really disables because it just tries to do too much) and 
_claim_ that we are more secure.

> > Regarding a whole-sale 'clear everything on free' approach - 
> > that's both pointless security wise (sensitive information can 
> > still leak indefinitely [if you disagree i can provide an 
> > example]) and has a very high cost so it's not acceptable to 
> > normal Linux distros.
> 
> Go ahead, I want to see your example.

Long-lived tasks that touched any crypto path (or other sensitive 
data in the kernel) and leaked it to the kernel stack can possibly 
keep sensitive information there indefinitely (especially if that 
information got there in an accidentally deep stack context) - up 
until the task exits. That information will outlive the freeing and 
sanitizing of the original sensitive data.

I gave a real example of how sensitive information (traces of 
previous execution) can survive on the kernel stack, via a real 
stack dump, in the previous mail i wrote.

> I don't even know why I'm still wasting my time replying to you, 
> it's clearly hopeless to try to get you off your egotistical, red 
> herring argument fueled attitude, which is likely a burden beyond 
> this list for you and everyone around, sadly.

Huh?

> > > Honestly your proposed approach seems a little weak.
> > 
> > Unconditional honesty is definitely welcome ;-)
> 
> When it's people's security at stake, if your reasoning and logic 
> is flawed, I have the moral obligation to tell you.
> 
> I'm here to make the kernel more secure, not to deal with your 
> inability to work with others without continuous conflicts and 
> attempts to fall into ridicule, that backfire at you in the end.
> 
> > Freeing keys is an utter slow-path (if not then the clearing is 
> > the least of our performance worries), so any clearing cost is 
> > in the noise. Furthermore, kzfree() is an existing facility 
> > already in use. If it's reused by your patches that brings 
> > further advantages: kzfree(), if it has any bugs, will be fixed. 
> > While if you add a parallel facility kzfree() stays broken.
> 
> Have you benchmarked the addition of these changes? I would like 
> to see benchmarks done for these (crypto api included), since you 
> are proposing them.

You have it the wrong way around. _You_ have the burden of proof 
here really, you are trying to get patches into the upstream kernel. 
I'm not obliged to do your homework for you. I might be wrong, and 
you can prove me wrong.

> > So your examples about real or suspected kzfree() breakages only 
> > strengthen the point that your patches should be using it. 
> > Keeping a rarely used kernel facility (like kzfree) correct is 
> > hard - splintering it by creating a parallel facility is 
> > actively harmful for that reason.
> 
> Fallacy ad hitlerum delivered. Impressive.

In what way is it a fallacy? It is a valid technical argument: more 
use of an existing facility is better than an overlapping parallel 
facility. It is a pretty much axiomatic argument.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
