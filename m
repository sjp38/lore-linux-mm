Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 560086B0047
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 11:47:38 -0400 (EDT)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.1/8.13.1) with ESMTP id n2DFlaDq003286
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 15:47:36 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2DFlaUA3571788
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 16:47:36 +0100
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2DFlZ7U022159
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 16:47:35 +0100
Message-ID: <49BA8013.3030103@free.fr>
Date: Fri, 13 Mar 2009 16:47:31 +0100
From: Cedric Le Goater <legoater@free.fr>
MIME-Version: 1.0
Subject: Re: How much of a mess does OpenVZ make? ;) Was: What can OpenVZ
 do?
References: <20090211141434.dfa1d079.akpm@linux-foundation.org> <1234462282.30155.171.camel@nimitz> <1234467035.3243.538.camel@calx> <20090212114207.e1c2de82.akpm@linux-foundation.org> <1234475483.30155.194.camel@nimitz> <20090212141014.2cd3d54d.akpm@linux-foundation.org> <1234479845.30155.220.camel@nimitz> <20090226155755.GA1456@x200.localdomain> <20090310215305.GA2078@x200.localdomain> <49B775B4.1040800@free.fr> <20090312145311.GC12390@us.ibm.com>
In-Reply-To: <20090312145311.GC12390@us.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Alexey Dobriyan <adobriyan@gmail.com>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, hpa@zytor.com, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, viro@zeniv.linux.org.uk, mingo@elte.hu, mpm@selenic.com, tglx@linutronix.de, torvalds@linux-foundation.org, Andrew Morton <akpm@linux-foundation.org>, xemul@openvz.org
List-ID: <linux-mm.kvack.org>


> No, what you're suggesting does not suffice.

probably. I'm still trying to understand what you mean below :)

Man, I hate these hierarchicals pid_ns. one level would have been enough, 
just one vpid attribute in 'struct pid*'
 
> Call
> (5591,3,1) the task knows as 5591 in the init_pid_ns, 3 in a child pid
> ns, and 1 in grandchild pid_ns created from there.  Now assume we are
> checkpointing tasks T1=(5592,1), and T2=(5594,3,1).
> 
> We don't care about the first number in the tuples, so they will be
> random numbers after the recreate. 

yes.

> But we do care about the second numbers.  

yes very much and we need a way set these numbers in alloc_pid()

> But specifying CLONE_NEWPID while recreating the process tree
> in userspace does not allow you to specify the 3 in (5594,3,1).

I haven't looked closely at hierarchical pid namespaces but as we're
using a an array of pid indexed but the pidns level, i don't see why 
it shouldn't be possible. you might be right.

anyway, I think that some CLONE_NEW* should be forbidden. Daniel should
send soon a little patch for the ns_cgroup restricting the clone flags
being used in a container.

Cheers,

C.

> Or are you suggesting that you'll do a dummy clone of (5594,2) so that
> the next clone(CLONE_NEWPID) will be expected to be (5594,3,1)?
> 
> -serge

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
