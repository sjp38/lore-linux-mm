Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.1/8.13.1) with ESMTP id m9MBpXoQ023511
	for <linux-mm@kvack.org>; Wed, 22 Oct 2008 11:51:33 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9MBpXrg3621110
	for <linux-mm@kvack.org>; Wed, 22 Oct 2008 13:51:33 +0200
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9MBpWVv015201
	for <linux-mm@kvack.org>; Wed, 22 Oct 2008 13:51:32 +0200
Message-ID: <48FF13C0.6000805@fr.ibm.com>
Date: Wed, 22 Oct 2008 13:51:28 +0200
From: Daniel Lezcano <dlezcano@fr.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC v7][PATCH 0/9] Kernel based checkpoint/restart
References: <1224481237-4892-1-git-send-email-orenl@cs.columbia.edu>	<20081021122135.4bce362c.akpm@linux-foundation.org>	<1224621667.1848.228.camel@nimitz> <20081022092024.GC12453@elte.hu>
In-Reply-To: <20081022092024.GC12453@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, containers@lists.linux-foundation.org, hpa@zytor.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@zeniv.linux.org.uk, linux-api@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, tglx@linutronix.de
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> * Dave Hansen <dave@linux.vnet.ibm.com> wrote:
> 
>> On Tue, 2008-10-21 at 12:21 -0700, Andrew Morton wrote:
>>> On Mon, 20 Oct 2008 01:40:28 -0400
>>> Oren Laadan <orenl@cs.columbia.edu> wrote:
>>>> These patches implement basic checkpoint-restart [CR]. This version
>>>> (v7) supports basic tasks with simple private memory, and open files
>>>> (regular files and directories only).
>>> - how useful is this code as it stands in real-world usage?
>> Right now, an application must be specifically written to use these 
>> mew system calls.  It must be a single process and not share any 
>> resources with other processes.  The only file descriptors that may be 
>> open are simple files and may not include sockets or pipes.
>>
>> What this means in practice is that it is useful for a simple app 
>> doing computational work.
> 
> say a chemistry application doing calculations. Or a raytracer with a 
> large job. Both can take many hours (days!) even on very fast machine 
> and the restrictions on rebootability can hurt in such cases.
> 
> You should reach a minimal level of initial practical utility: say some 
> helper tool that allows testers to checkpoint and restore a real PovRay 
> session - without any modification to a stock distro PovRay.

There are the liblxc userspace tools doing that.

http://sourceforge.net/projects/lxc/

There are the lxc-checkpoint and lxc-restart commands to test the Oren's 
patches with the external checkpoint Cedric did. These commands are 
experimental and under development so a hack may be necessary for 
checkpoint/restart.

I didn't tried with Oren's external checkpoint yet, but I think the 
commands should work. Actually these commands relies on the freezer, so 
the checkpoint command does freeze, checkpoint, unfreeze. (and kill if 
specified).

	lxc-create -n foo

	lxc-start -n foo mypovray

	lxc-checkpoint -s -n foo > myckptfile

	lxc-restart -n foo < myckptfile

Thanks
   -- Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
