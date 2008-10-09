Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate4.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m99LxkOu309812
	for <linux-mm@kvack.org>; Thu, 9 Oct 2008 21:59:46 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m99LxcT72838596
	for <linux-mm@kvack.org>; Thu, 9 Oct 2008 22:59:46 +0100
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m99LxbFI013117
	for <linux-mm@kvack.org>; Thu, 9 Oct 2008 22:59:38 +0100
Subject: Re: [RFC v6][PATCH 0/9] Kernel based checkpoint/restart
From: Greg Kurz <gkurz@fr.ibm.com>
In-Reply-To: <20081009131701.GA21112@elte.hu>
References: <1223461197-11513-1-git-send-email-orenl@cs.columbia.edu>
	 <20081009124658.GE2952@elte.hu> <1223557122.11830.14.camel@nimitz>
	 <20081009131701.GA21112@elte.hu>
Content-Type: text/plain
Date: Thu, 09 Oct 2008 23:59:33 +0200
Message-Id: <1223589573.6117.66.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, jeremy@goop.org, arnd@arndb.de, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2008-10-09 at 15:17 +0200, Ingo Molnar wrote:
> yeah, something like that. A key aspect of it is that is has to be very 
> low-key on the source code level - we dont want to sprinkle the kernel 
> with anything ugly. Perhaps something pretty explicit:
> 
>   current->flags |= PF_NOCR;
> 
> as we do the same thing today for certain facilities:
> 
>   current->flags |= PF_NOFREEZE;
> 
> you probably want to hide it behind:
> 
>   set_current_nocr();
> 

Being uncheckpointable is a transient and hopefully reversible state.
A set_current_cr() function is also needed and should be called at some
time to avoid abusive denials of checkpoint (DoC ?).

With the sys_remap_file_pages() example, set_current_cr() should be
called somewhere in sys_munmap() or even sys_remap_file_pages(). Some
code should be added to detect the mapping that lead the nocr state is
removed (a flag on the affected vma?) or fixed (checking the linearity
of mapping?). Would this code be low-key enough ?

> and have a set_task_nocr() as well, in case there's some proxy state 
> installed by another task.
> 
> Via such wrappers there's no overhead at all in the 
> !CONFIG_CHECKPOINT_RESTART case.
> 
> Plus you could drive the debug mechanism via it as well, by using a 
> trivial extension of the facility:
> 
>   set_current_nocr("CR: sys_remap_file_pages not supported yet.");
>   ...
>   set_task_nocr(t, "CR: PI futexes not supported yet.");
> 
> 	Ingo
> _______________________________________________
> Containers mailing list
> Containers@lists.linux-foundation.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
-- 
Gregory Kurz                                     gkurz@fr.ibm.com
Software Engineer @ IBM/Meiosys                  http://www.ibm.com
Tel +33 (0)534 638 479                           Fax +33 (0)561 400 420

"Anarchy is about taking complete responsibility for yourself."
        Alan Moore.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
