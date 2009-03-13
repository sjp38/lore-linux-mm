Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1AC216B003D
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 15:03:10 -0400 (EDT)
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e6.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n2DJ4Mwp006576
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 15:04:22 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2DJ34G23571762
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 15:03:04 -0400
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2DJ2r25031970
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 13:02:54 -0600
Date: Fri, 13 Mar 2009 14:02:53 -0500
From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: How much of a mess does OpenVZ make? ;) Was: What can OpenVZ
	do?
Message-ID: <20090313190253.GA16683@us.ibm.com>
References: <1234479845.30155.220.camel@nimitz> <20090226155755.GA1456@x200.localdomain> <20090310215305.GA2078@x200.localdomain> <49B775B4.1040800@free.fr> <20090312145311.GC12390@us.ibm.com> <1236891719.32630.14.camel@bahia> <20090312212124.GA25019@us.ibm.com> <604427e00903122129y37ad791aq5fe7ef2552415da9@mail.gmail.com> <20090313053458.GA28833@us.ibm.com> <alpine.LFD.2.00.0903131018390.3940@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.0903131018390.3940@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, hpa@zytor.com, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, viro@zeniv.linux.org.uk, mingo@elte.hu, mpm@selenic.com, Andrew Morton <akpm@linux-foundation.org>, xemul@openvz.org, tglx@linutronix.de, Alexey Dobriyan <adobriyan@gmail.com>
List-ID: <linux-mm.kvack.org>

Quoting Linus Torvalds (torvalds@linux-foundation.org):
> 
> 
> On Thu, 12 Mar 2009, Sukadev Bhattiprolu wrote:
> 
> > Ying Han [yinghan@google.com] wrote:
> > | Hi Serge:
> > | I made a patch based on Oren's tree recently which implement a new
> > | syscall clone_with_pid. I tested with checkpoint/restart process tree
> > | and it works as expected.
> > 
> > Yes, I think we had a version of clone() with pid a while ago.
> 
> Are people _at_all_ thinking about security?
> 
> Obviously not.
> 
> There's no way we can do anything like this. Sure, it's trivial to do 
> inside the kernel. But it also sounds like a _wonderful_ attack vector 
> against badly written user-land software that sends signals and has small 
> races.

If we're worried about that, one way we could address it is to tag a
pid_ns with the userid of whoever created it, and enforce that you
can only specify a pid in a pid_ns which you own.

What openvz does is have sys_restart create the whole process tree,
including custom pids (only in the new private namespaces), from inside
the kernel.  That has the same effect of only allowing specification of
pids in your own private pid namespaces.

> Quite frankly, from having followed the discussion(s) over the last few 
> weeks about checkpoint/restart in various forms, my reaction to just about 
> _all_ of this is that people pushing this are pretty damn borderline. 
> 
> I think you guys are working on all the wrong problems. 
> 
> Let's face it, we're not going to _ever_ checkpoint any kind of general 
> case process. Just TCP makes that fundamentally impossible in the general 
> case, and there are lots and lots of other cases too (just something as 
> totally _trivial_ as all the files in the filesystem that don't get rolled 
> back).

I'm pretty sure that each of Openvz, Metacluster, and Zap are able to
checkpoint, restart, and migrate tasks which are actively using TCP.
Of course doing rollback of one endpoint of an ongoing communication
would be silly, but migration is possible.

> So unless people start realizing that
>  (a) processes that want to be checkpointed had better be ready and aware 
>      of it, and help out
>  (b) there's no way in hell that we're going to add these kinds of 
>      interfaces that have dubious upsides (just teach the damn program 
>      you're checkpointing that pids will change, and admit to everybody 
>      that people who want to be checkpointed need to do work) and are 
>      potential security holes.
>  (c) if you are going to play any deeper games, you need to have 
>      privileges. IOW, "clone_with_pid()" is ok for _root_, but not for 
>      some random user. And you'd better keep that in mind EVERY SINGLE 
>      STEP OF THE WAY.

Yes, that is why we're keeping from requiring privilege so far - to make
sure that at each step we have to consider security requirements.

> I'm really fed up with these discussions. I have seen almost _zero_ 
> critical thinking at all. Probably because anybody who is in the least 
> doubtful about it simply has tuned out the discussion. So here's my input: 
> start small, start over, and start thinking about other issues than just 
> checkpointing.

The first set of patches from Oren is intended to do just that.  It
certainly did not have any sort of clone_with_pid() equivalent.

-serge

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
