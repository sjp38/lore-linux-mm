Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5A20B6B0099
	for <linux-mm@kvack.org>; Wed, 18 Feb 2009 13:16:55 -0500 (EST)
Date: Wed, 18 Feb 2009 19:16:44 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: What can OpenVZ do?
Message-ID: <20090218181644.GD19995@elte.hu>
References: <20090212114207.e1c2de82.akpm@linux-foundation.org> <1234475483.30155.194.camel@nimitz> <20090212141014.2cd3d54d.akpm@linux-foundation.org> <20090213105302.GC4608@elte.hu> <1234817490.30155.287.camel@nimitz> <20090217222319.GA10546@elte.hu> <1234909849.4816.9.camel@nimitz> <20090218003217.GB25856@elte.hu> <1234917639.4816.12.camel@nimitz> <20090218051123.GA9367@x200.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090218051123.GA9367@x200.localdomain>
Sender: owner-linux-mm@kvack.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, hpa@zytor.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@zeniv.linux.org.uk, mpm@selenic.com, tglx@linutronix.de, torvalds@linux-foundation.org, xemul@openvz.org, Nathan Lynch <nathanl@austin.ibm.com>
List-ID: <linux-mm.kvack.org>


* Alexey Dobriyan <adobriyan@gmail.com> wrote:

> On Tue, Feb 17, 2009 at 04:40:39PM -0800, Dave Hansen wrote:
> > On Wed, 2009-02-18 at 01:32 +0100, Ingo Molnar wrote:
> > > > > Uncheckpointable should be a one-way flag anyway. We want this 
> > > > > to become usable, so uncheckpointable functionality should be as 
> > > > > painful as possible, to make sure it's getting fixed ...
> > > > 
> > > > Again, as these patches stand, we don't support checkpointing 
> > > > when non-simple files are opened.  Basically, if a 
> > > > open()/lseek() pair won't get you back where you were, we 
> > > > don't deal with them.
> > > > 
> > > > init does non-checkpointable things.  If the flag is a one-way 
> > > > trip, we'll never be able to checkpoint because we'll always 
> > > > inherit init's ! checkpointable flag.
> > > > 
> > > > To fix this, we could start working on making sure we can 
> > > > checkpoint init, but that's practically worthless.
> > > 
> > > i mean, it should be per process (per app) one-way flag of 
> > > course. If the app does something unsupported, it gets 
> > > non-checkpointable and that's it.
> > 
> > OK, we can definitely do that.  Do you think it is OK to run through a
> > set of checks at exec() time to check if the app currently has any
> > unsupported things going on?  If we don't directly inherit the parent's
> > status, then we need to have *some* time when we check it.
> 
> Uncheckpointable is not one-way.
> 
> Imagine remap_file_pages(2) is unsupported. Now app uses 
> remap_file_pages(2), then unmaps interesting VMA. Now app is 
> checkpointable again.

But that's precisely the kind of over-design that defeats the 
common purpose: which would be to make everything 
checkpointable. (including weirdo APIs like fremap())

Nothing motivates more than app designers complaining about the 
one-way flag.

Furthermore, it's _far_ easier to make a one-way flag SMP-safe. 
We just set it and that's it. When we unset it, what do we about 
SMP races with other threads in the same MM installing another 
non-linear vma, etc.

> As for overloading LSM, I think, it would be horrible. Most 
> hooks are useless, there are config options expanding LSM 
> hooks, and CPT and LSM are just totally orthogonal.

Sure it would have to be adopted to the needs of CPT, but i can 
tell you one thing for sure: there's only one thing that is 
worse than every syscall annotated with an LSM hook (which is 
the current status quo): every syscall annotated with an LSM 
hook _and_ a separate CPT hook.

It's just bad design. CPT might be orthogonal, but it wants to 
hook into syscalls at roughly the same places where LSM hooks 
into, which pretty much settles the question.

If there's places that need new hooks then we can add them not 
as CPT hooks, but as security hooks. That way there's synergy: 
both LSM and CPT advances, on the shoulders of each other.

> Instead, just (no offence) get big enough coverage -- run 
> modern and past distros, run servers packaged with them, and 
> if you can checkpoint all of this, you're mostly fine.

That's definitely a good advice, just it doesnt give the kind of 
minimal environment from where productization efforts can be 
seeded from.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
