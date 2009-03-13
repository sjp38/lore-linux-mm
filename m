Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5539A6B003D
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 12:36:05 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n2DGYgMI005427
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 10:34:42 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2DGZnfU095200
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 10:35:51 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2DGZbjW014266
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 10:35:49 -0600
Date: Fri, 13 Mar 2009 11:35:31 -0500
From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: How much of a mess does OpenVZ make? ;) Was: What can OpenVZ
	do?
Message-ID: <20090313163531.GA10685@us.ibm.com>
References: <1234467035.3243.538.camel@calx> <20090212114207.e1c2de82.akpm@linux-foundation.org> <1234475483.30155.194.camel@nimitz> <20090212141014.2cd3d54d.akpm@linux-foundation.org> <1234479845.30155.220.camel@nimitz> <20090226155755.GA1456@x200.localdomain> <20090310215305.GA2078@x200.localdomain> <49B775B4.1040800@free.fr> <20090312145311.GC12390@us.ibm.com> <49BA8013.3030103@free.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <49BA8013.3030103@free.fr>
Sender: owner-linux-mm@kvack.org
To: Cedric Le Goater <legoater@free.fr>
Cc: Alexey Dobriyan <adobriyan@gmail.com>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, hpa@zytor.com, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, viro@zeniv.linux.org.uk, mingo@elte.hu, mpm@selenic.com, tglx@linutronix.de, torvalds@linux-foundation.org, Andrew Morton <akpm@linux-foundation.org>, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

Quoting Cedric Le Goater (legoater@free.fr):
> 
> > No, what you're suggesting does not suffice.
> 
> probably. I'm still trying to understand what you mean below :)
> 
> Man, I hate these hierarchicals pid_ns. one level would have been enough, 
> just one vpid attribute in 'struct pid*'

Well I don't mind - temporarily - saying that nested pid namespaces
are not checkpointable.  It's just that if we're going to need a new
syscall anyway, then why not go ahead and address the whole problem?
It's not hugely more complicated, and seems worth it.

> > Call
> > (5591,3,1) the task knows as 5591 in the init_pid_ns, 3 in a child pid
> > ns, and 1 in grandchild pid_ns created from there.  Now assume we are
> > checkpointing tasks T1=(5592,1), and T2=(5594,3,1).
> > 
> > We don't care about the first number in the tuples, so they will be
> > random numbers after the recreate. 
> 
> yes.
> 
> > But we do care about the second numbers.  
> 
> yes very much and we need a way set these numbers in alloc_pid()
> 
> > But specifying CLONE_NEWPID while recreating the process tree
> > in userspace does not allow you to specify the 3 in (5594,3,1).
> 
> I haven't looked closely at hierarchical pid namespaces but as we're
> using a an array of pid indexed but the pidns level, i don't see why 
> it shouldn't be possible. you might be right.
> 
> anyway, I think that some CLONE_NEW* should be forbidden. Daniel should
> send soon a little patch for the ns_cgroup restricting the clone flags
> being used in a container.

Uh, that feels a bit over the top.  We want to make this
uncheckpointable (if it remains so), not prevent the whole action.
After all I may be running a container which I don't plan on ever
checkpointing, and inside that container running a job which i do
want to migrate.

So depending on if we're doing the Dave or the rest-of-the-world
way :), we either clear_bit(pidns->may_checkpoint) on the parent
pid_ns when a child is created, or we walk every task being
checkpointed and make sure they each are in the same pid_ns.  Doesn't
that suffice?

-serge

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
