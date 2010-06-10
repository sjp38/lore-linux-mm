Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id D5B116B0071
	for <linux-mm@kvack.org>; Thu, 10 Jun 2010 16:32:35 -0400 (EDT)
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id o5AKWVsl006073
	for <linux-mm@kvack.org>; Thu, 10 Jun 2010 13:32:31 -0700
Received: from pwi7 (pwi7.prod.google.com [10.241.219.7])
	by hpaq13.eem.corp.google.com with ESMTP id o5AKWT9v000823
	for <linux-mm@kvack.org>; Thu, 10 Jun 2010 13:32:29 -0700
Received: by pwi7 with SMTP id 7so323696pwi.0
        for <linux-mm@kvack.org>; Thu, 10 Jun 2010 13:32:28 -0700 (PDT)
Date: Thu, 10 Jun 2010 13:32:25 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: oom killer and long-waiting processes
In-Reply-To: <AANLkTik6xP9vVEyW4QG-4RfZu-iEuHcl2pBV_-mfHP4y@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1006101326440.20197@chino.kir.corp.google.com>
References: <AANLkTik6xP9vVEyW4QG-4RfZu-iEuHcl2pBV_-mfHP4y@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Ryan Wang <openspace.wang@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernelnewbies@nl.linux.org
List-ID: <linux-mm.kvack.org>

On Thu, 10 Jun 2010, Ryan Wang wrote:

> Hi all,
> 
>         I have one question about oom killer:
> If many processes dealing with network communications,
> but due to bad network traffic, the processes have to wait
> for a very long time. And meanwhile they may consume
> some memeory separately for computation. The number
> of such processes may be large.
> 
>         I wonder whether oom killer will kill these processes
> when the system is under high pressure?
> 

The kernel can deal with "high pressure" quite well, but in some cases 
such as when all of your RAM or your memory controller is filled with 
anonymous memory and cannot be reclaimed, the oom killer may be called to 
kill "something".  It prefers to kill something that will free a large 
amount of memory to avoid having to subsequently kill additional tasks 
when it kills something small first.

If there are tasks that you'd either like to protect from the oom killer 
or always prefer in oom conditions, you can influence its decision-making 
from userspace by tuning /proc/<pid>/oom_adj of the task in question.  
Users typically set an oom_adj value of "-17" to completely disable oom 
killing of pid (the kernel will even panic if it can't find anything 
killable as a result of this!), a value of "-16" to prefer that pid gets 
killed last, and a value of "15" to always prefer pid gets killed first.

Lowering a /proc/<pid>/oom_adj value for a pid from its current value (it 
inherits its value from the parent, which is usually 0) is only allowed by 
root, more specifically, it may only be done by the CAP_SYS_RESOURCE 
capability.

You can refer to Documentation/filesystems/proc.txt for information on 
oom_adj.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
