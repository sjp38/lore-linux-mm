Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate1.uk.ibm.com (8.13.1/8.13.1) with ESMTP id m9GCaSe6010429
	for <linux-mm@kvack.org>; Thu, 16 Oct 2008 12:36:30 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9GCaRTI4137020
	for <linux-mm@kvack.org>; Thu, 16 Oct 2008 13:36:27 +0100
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9GCaQwB029256
	for <linux-mm@kvack.org>; Thu, 16 Oct 2008 13:36:27 +0100
Message-ID: <48F7352F.3020700@fr.ibm.com>
Date: Thu, 16 Oct 2008 14:35:59 +0200
From: Daniel Lezcano <dlezcano@fr.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC v6][PATCH 0/9] Kernel based checkpoint/restart
References: <1223461197-11513-1-git-send-email-orenl@cs.columbia.edu>	<20081009124658.GE2952@elte.hu> <1223557122.11830.14.camel@nimitz>	<20081009131701.GA21112@elte.hu> <1223559246.11830.23.camel@nimitz>	<20081009134415.GA12135@elte.hu> <1223571036.11830.32.camel@nimitz>	<20081010153951.GD28977@elte.hu> <48F30315.1070909@fr.ibm.com>	<1223916223.29877.14.camel@nimitz> <48F6092D.6050400@fr.ibm.com> <48F685A3.1060804@cs.columbia.edu>
In-Reply-To: <48F685A3.1060804@cs.columbia.edu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Cedric Le Goater <clg@fr.ibm.com>, jeremy@goop.org, arnd@arndb.de, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Andrey Mirkin <major@openvz.org>
List-ID: <linux-mm.kvack.org>

Oren Laadan wrote:
> Cedric Le Goater wrote:
>> Dave Hansen wrote:
>>> On Mon, 2008-10-13 at 10:13 +0200, Cedric Le Goater wrote:
>>>> hmm, that's rather complex, because we have to take into account the 
>>>> kernel stack, no ? This is what Andrey was trying to solve in his patchset 
>>>> back in September :
>>>>
>>>>         http://lkml.org/lkml/2008/9/3/96
>>>>
>>>> the restart phase simulates a clone and switch_to to (not) restore the kernel 
>>>> stack. right ? 
>>> Do we ever have to worry about the kernel stack if we simply say that
>>> tasks have to be *in* userspace when we checkpoint them. 
>> at a syscall boundary for example. that would make our life easier 
>> definitely. 
>>
> 
> The ideal situation is never worry about kernel stack: either we catch
> the task in user space or at a syscall boundary. This is taken care of
> by freezing the tasks prior to checkpoint.
> 
> The one exception (and it is a tedious one !) are states in which the
> task is already frozen by definition: any ptrace blocking point where
> the tracee waits for the tracer to grant permission to proceed with
> its execution. Another example is in vfork(), waiting for completion.

I would say these are perfect places for "may be non-checkpointable" :)

> In both cases, there will be a kernel stack and we cannot avoid it.
> The bad news is that it may be a bit tedious to restart these cases.
> The good news, however, is that they are very well defined locations
> with well defined semantics. So upon restart all that is needed is
> to emulate the expected behavior had we not been checkpointed. This,
> luckily, does not require rebuilding the kernel stack, but instead
> some smart glue code for a finite set of special cases.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
