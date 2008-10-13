Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.8/8.13.8) with ESMTP id m9D8DCtb407240
	for <linux-mm@kvack.org>; Mon, 13 Oct 2008 08:13:13 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9D8DCIU1884340
	for <linux-mm@kvack.org>; Mon, 13 Oct 2008 10:13:12 +0200
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9D8DBfS002664
	for <linux-mm@kvack.org>; Mon, 13 Oct 2008 10:13:12 +0200
Message-ID: <48F30315.1070909@fr.ibm.com>
Date: Mon, 13 Oct 2008 10:13:09 +0200
From: Cedric Le Goater <clg@fr.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC v6][PATCH 0/9] Kernel based checkpoint/restart
References: <1223461197-11513-1-git-send-email-orenl@cs.columbia.edu>	<20081009124658.GE2952@elte.hu> <1223557122.11830.14.camel@nimitz>	<20081009131701.GA21112@elte.hu> <1223559246.11830.23.camel@nimitz>	<20081009134415.GA12135@elte.hu> <1223571036.11830.32.camel@nimitz> <20081010153951.GD28977@elte.hu>
In-Reply-To: <20081010153951.GD28977@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, jeremy@goop.org, arnd@arndb.de, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Oren Laadan <orenl@cs.columbia.edu>, Andrey Mirkin <major@openvz.org>
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> * Dave Hansen <dave@linux.vnet.ibm.com> wrote:
> 
>> On Thu, 2008-10-09 at 15:44 +0200, Ingo Molnar wrote:
>>> there might be races as well, especially with proxy state - and 
>>> current->flags updates are not serialized.
>>>
>>> So maybe it should be a completely separate flag after all? Stick it 
>>> into the end of task_struct perhaps.
>> What do you mean by proxy state?  nsproxy?
> 
> it's a concept: one task installing some state into another task (which 
> state must be restored after a checkpoint event), while that other task 
> is running. Such as a pi-futex state for example.
> 
> So a task can acquire state not just by its own doing, but via some 
> other task too.

thinking aloud,

hmm, that's rather complex, because we have to take into account the 
kernel stack, no ? This is what Andrey was trying to solve in his patchset 
back in September :

	http://lkml.org/lkml/2008/9/3/96

the restart phase simulates a clone and switch_to to (not) restore the kernel 
stack. right ? 

the self checkpoint and self restore syscalls, like Oren is proposing, are 
simpler but they require the process cooperation to be triggered. we could
image doing that in a special signal handler which would allow us to jump
in the right task context. 

I don't have any preference but looking at the code of the different patchsets
there are some tricky areas and I'm wondering which path is easier, safer, 
and portable. 

C.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
