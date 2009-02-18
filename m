Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A47176B003D
	for <linux-mm@kvack.org>; Wed, 18 Feb 2009 00:05:01 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id 19so607325fgg.4
        for <linux-mm@kvack.org>; Tue, 17 Feb 2009 21:04:58 -0800 (PST)
Date: Wed, 18 Feb 2009 08:11:23 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: What can OpenVZ do?
Message-ID: <20090218051123.GA9367@x200.localdomain>
References: <1234467035.3243.538.camel@calx> <20090212114207.e1c2de82.akpm@linux-foundation.org> <1234475483.30155.194.camel@nimitz> <20090212141014.2cd3d54d.akpm@linux-foundation.org> <20090213105302.GC4608@elte.hu> <1234817490.30155.287.camel@nimitz> <20090217222319.GA10546@elte.hu> <1234909849.4816.9.camel@nimitz> <20090218003217.GB25856@elte.hu> <1234917639.4816.12.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1234917639.4816.12.camel@nimitz>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, hpa@zytor.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@zeniv.linux.org.uk, mpm@selenic.com, tglx@linutronix.de, torvalds@linux-foundation.org, xemul@openvz.org, Nathan Lynch <nathanl@austin.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, Feb 17, 2009 at 04:40:39PM -0800, Dave Hansen wrote:
> On Wed, 2009-02-18 at 01:32 +0100, Ingo Molnar wrote:
> > > > Uncheckpointable should be a one-way flag anyway. We want this 
> > > > to become usable, so uncheckpointable functionality should be as 
> > > > painful as possible, to make sure it's getting fixed ...
> > > 
> > > Again, as these patches stand, we don't support checkpointing 
> > > when non-simple files are opened.  Basically, if a 
> > > open()/lseek() pair won't get you back where you were, we 
> > > don't deal with them.
> > > 
> > > init does non-checkpointable things.  If the flag is a one-way 
> > > trip, we'll never be able to checkpoint because we'll always 
> > > inherit init's ! checkpointable flag.
> > > 
> > > To fix this, we could start working on making sure we can 
> > > checkpoint init, but that's practically worthless.
> > 
> > i mean, it should be per process (per app) one-way flag of 
> > course. If the app does something unsupported, it gets 
> > non-checkpointable and that's it.
> 
> OK, we can definitely do that.  Do you think it is OK to run through a
> set of checks at exec() time to check if the app currently has any
> unsupported things going on?  If we don't directly inherit the parent's
> status, then we need to have *some* time when we check it.

Uncheckpointable is not one-way.

Imagine remap_file_pages(2) is unsupported. Now app uses
remap_file_pages(2), then unmaps interesting VMA. Now app is
checkpointable again.

As for overloading LSM, I think, it would be horrible.
Most hooks are useless, there are config options expanding LSM hooks,
and CPT and LSM are just totally orthogonal.

Instead, just (no offence) get big enough coverage -- run modern and
past distros, run servers packaged with them, and if you can checkpoint
all of this, you're mostly fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
