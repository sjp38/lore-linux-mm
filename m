Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate8.de.ibm.com (8.13.8/8.13.8) with ESMTP id m9FFDRQx673978
	for <linux-mm@kvack.org>; Wed, 15 Oct 2008 15:13:27 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9FFDR284157528
	for <linux-mm@kvack.org>; Wed, 15 Oct 2008 17:13:27 +0200
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9FFDQvq001899
	for <linux-mm@kvack.org>; Wed, 15 Oct 2008 17:13:27 +0200
Message-ID: <48F60891.1070807@fr.ibm.com>
Date: Wed, 15 Oct 2008 17:13:21 +0200
From: Cedric Le Goater <clg@fr.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC v6][PATCH 0/9] Kernel based checkpoint/restart
References: <1223461197-11513-1-git-send-email-orenl@cs.columbia.edu>	<20081009124658.GE2952@elte.hu> <1223557122.11830.14.camel@nimitz>	<20081009131701.GA21112@elte.hu> <1223559246.11830.23.camel@nimitz>	<20081009134415.GA12135@elte.hu> <1223571036.11830.32.camel@nimitz> <20081010153951.GD28977@elte.hu> <48F30315.1070909@fr.ibm.com> <48F3737B.6070904@cs.columbia.edu>
In-Reply-To: <48F3737B.6070904@cs.columbia.edu>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Ingo Molnar <mingo@elte.hu>, Dave Hansen <dave@linux.vnet.ibm.com>, jeremy@goop.org, arnd@arndb.de, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Andrey Mirkin <major@openvz.org>
List-ID: <linux-mm.kvack.org>

>> the self checkpoint and self restore syscalls, like Oren is proposing, are 
>> simpler but they require the process cooperation to be triggered. we could
>> image doing that in a special signal handler which would allow us to jump
>> in the right task context. 
> 
> This description is not accurate:
> 
> For checkpoint, both implementations use an "external" task to read the state
> from other tasks. (In my implementation that "other" task can be self).

which is good, since some applications want to checkpoint themselves and that's
a way to provide them a generic service.
 
> For restart, both implementation expect the restarting process to restore its
> own state. They differ in that Andrew's patchset also creates that process
> while mine (at the moment) relies on the existing (self) task.

hmm, 

It seems that your patchset relies on the fact that the tasks are checkpointed 
and restarted at a syscall boundary. right ? I'm might be completely wrong
on that :)

> In other words, none of them will require any cooperation on part of the
> checkpointed tasks, and both will require cooperation on part of the restarting
> tasks (the latter is easy since we create and fully control these tasks).

yes.

>> I don't have any preference but looking at the code of the different patchsets
>> there are some tricky areas and I'm wondering which path is easier, safer, 
>> and portable. 
> 
> I am thinking which path is preferred: create the processes in kernel space
> (like Andrew's patch does) or in user space (like Zap does). In the mini-summit
> we agreed in favor of kernel space, but I can still see arguments why user space
> may be better.

I'm more familiar with the second algorithm, restarting the process tree in
user space and let each task restart itself with the sys_restart syscall. But
that's because I've been working on a C/R framework which freezes tasks on 
a syscall boundary, which makes a developer's life easy for restart. 

But as you know, a restarted process resumes its execution where it was 
checkpointed. So i'm wondering what are the hidden issues with a in-kernel 
checkpoint and in-kernel restart. To be more precise, why Andrey needs a 
i386_ret_from_resume  trampoline in : 

	http://lkml.org/lkml/2008/9/3/181

and why don't you ? 

> (note: I refer strictly to the creation of the processes during restart, not 
>  how their state is restored).

OK 

> any thoughts ?

thanks Oren,

C.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
