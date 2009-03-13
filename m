Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D9A786B004D
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 13:37:39 -0400 (EDT)
Date: Fri, 13 Mar 2009 10:27:54 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: How much of a mess does OpenVZ make? ;) Was: What can OpenVZ
 do?
In-Reply-To: <20090313053458.GA28833@us.ibm.com>
Message-ID: <alpine.LFD.2.00.0903131018390.3940@localhost.localdomain>
References: <1234475483.30155.194.camel@nimitz> <20090212141014.2cd3d54d.akpm@linux-foundation.org> <1234479845.30155.220.camel@nimitz> <20090226155755.GA1456@x200.localdomain> <20090310215305.GA2078@x200.localdomain> <49B775B4.1040800@free.fr>
 <20090312145311.GC12390@us.ibm.com> <1236891719.32630.14.camel@bahia> <20090312212124.GA25019@us.ibm.com> <604427e00903122129y37ad791aq5fe7ef2552415da9@mail.gmail.com> <20090313053458.GA28833@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Cc: Ying Han <yinghan@google.com>, "Serge E. Hallyn" <serue@us.ibm.com>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, hpa@zytor.com, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, viro@zeniv.linux.org.uk, mingo@elte.hu, mpm@selenic.com, Andrew Morton <akpm@linux-foundation.org>, xemul@openvz.org, tglx@linutronix.de, Alexey Dobriyan <adobriyan@gmail.com>
List-ID: <linux-mm.kvack.org>



On Thu, 12 Mar 2009, Sukadev Bhattiprolu wrote:

> Ying Han [yinghan@google.com] wrote:
> | Hi Serge:
> | I made a patch based on Oren's tree recently which implement a new
> | syscall clone_with_pid. I tested with checkpoint/restart process tree
> | and it works as expected.
> 
> Yes, I think we had a version of clone() with pid a while ago.

Are people _at_all_ thinking about security?

Obviously not.

There's no way we can do anything like this. Sure, it's trivial to do 
inside the kernel. But it also sounds like a _wonderful_ attack vector 
against badly written user-land software that sends signals and has small 
races.

Quite frankly, from having followed the discussion(s) over the last few 
weeks about checkpoint/restart in various forms, my reaction to just about 
_all_ of this is that people pushing this are pretty damn borderline. 

I think you guys are working on all the wrong problems. 

Let's face it, we're not going to _ever_ checkpoint any kind of general 
case process. Just TCP makes that fundamentally impossible in the general 
case, and there are lots and lots of other cases too (just something as 
totally _trivial_ as all the files in the filesystem that don't get rolled 
back).

So unless people start realizing that
 (a) processes that want to be checkpointed had better be ready and aware 
     of it, and help out
 (b) there's no way in hell that we're going to add these kinds of 
     interfaces that have dubious upsides (just teach the damn program 
     you're checkpointing that pids will change, and admit to everybody 
     that people who want to be checkpointed need to do work) and are 
     potential security holes.
 (c) if you are going to play any deeper games, you need to have 
     privileges. IOW, "clone_with_pid()" is ok for _root_, but not for 
     some random user. And you'd better keep that in mind EVERY SINGLE 
     STEP OF THE WAY.

I'm really fed up with these discussions. I have seen almost _zero_ 
critical thinking at all. Probably because anybody who is in the least 
doubtful about it simply has tuned out the discussion. So here's my input: 
start small, start over, and start thinking about other issues than just 
checkpointing.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
