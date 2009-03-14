Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 166AB6B003D
	for <linux-mm@kvack.org>; Sat, 14 Mar 2009 04:25:46 -0400 (EDT)
Date: Sat, 14 Mar 2009 09:25:32 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: How much of a mess does OpenVZ make? ;) Was: What can OpenVZ
	do?
Message-ID: <20090314082532.GB16436@elte.hu>
References: <49B775B4.1040800@free.fr> <20090312145311.GC12390@us.ibm.com> <1236891719.32630.14.camel@bahia> <20090312212124.GA25019@us.ibm.com> <604427e00903122129y37ad791aq5fe7ef2552415da9@mail.gmail.com> <20090313053458.GA28833@us.ibm.com> <alpine.LFD.2.00.0903131018390.3940@localhost.localdomain> <20090313193500.GA2285@x200.localdomain> <alpine.LFD.2.00.0903131401070.3940@localhost.localdomain> <20090314002059.GA4167@x200.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090314002059.GA4167@x200.localdomain>
Sender: owner-linux-mm@kvack.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, "Serge E. Hallyn" <serue@us.ibm.com>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, hpa@zytor.com, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, viro@zeniv.linux.org.uk, mpm@selenic.com, Andrew Morton <akpm@linux-foundation.org>, xemul@openvz.org, tglx@linutronix.de
List-ID: <linux-mm.kvack.org>


* Alexey Dobriyan <adobriyan@gmail.com> wrote:

> On Fri, Mar 13, 2009 at 02:01:50PM -0700, Linus Torvalds wrote:
> > 
> > 
> > On Fri, 13 Mar 2009, Alexey Dobriyan wrote:
> > > > 
> > > > Let's face it, we're not going to _ever_ checkpoint any 
> > > > kind of general case process. Just TCP makes that 
> > > > fundamentally impossible in the general case, and there 
> > > > are lots and lots of other cases too (just something as 
> > > > totally _trivial_ as all the files in the filesystem 
> > > > that don't get rolled back).
> > > 
> > > What do you mean here? Unlinked files?
> > 
> > Or modified files, or anything else. "External state" is a 
> > pretty damn wide net. It's not just TCP sequence numbers and 
> > another machine.
> 
> I think (I think) you're seriously underestimating what's 
> doable with kernel C/R and what's already done.
> 
> I was told (haven't seen it myself) that Oracle installations 
> and Counter Strike servers were moved between boxes just fine.
> 
> They were run in specially prepared environment of course, but 
> still.

That's the kind of stuff i'd like to see happen.

Right now the main 'enterprise' approach to do 
migration/consolidation of server contexts is based on hardware 
virtualization - but that pushes runtime overhead to the native 
kernel and slows down the guest context as well - massively so.

Before we've blinked twice it will be a 'required' enterprise 
feature and enterprise people will measure/benchmark Linux 
server performance in guest context primarily and we'll have a 
deep performance pit to dig ourselves out of.

We can ignore that trend as uninteresting (it is uninteresting 
in a number of ways because it is partly driven by stupidity), 
or we can do something about it while still advancing the 
kernel.

With containers+checkpointing the code is a lot scarier (we 
basically do system call virtualization), the environment 
interactions are a lot wider and thus they are a lot more 
difficult to handle - but it's all a lot faster as well, and 
conceptually so. All the runtime overhead is pushed to the 
checkpointing step - (with some minimal amount of data structure 
isolation overhead).

I see three conceptual levels of virtualization:

 - hardware based virtualization, for 'unaware OSs'

 - system call based virtualization, for 'unaware software'

 - no virtualization kernel help is needed _at all_ to 
   checkpoint 'aware' software. We have libraries to checkpoint 
   'aware' user-space just fine - and had them for a decade.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
