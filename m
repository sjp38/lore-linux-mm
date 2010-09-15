Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DEFEA6B004A
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 09:20:32 -0400 (EDT)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp02.au.ibm.com (8.14.4/8.13.1) with ESMTP id o8FDGBE5025184
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 23:16:11 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o8FDKTqM1032330
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 23:20:29 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o8FDKS0q010015
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 23:20:29 +1000
Date: Wed, 15 Sep 2010 22:50:19 +0930
From: Christopher Yeoh <cyeoh@au1.ibm.com>
Subject: Re: [RFC][PATCH] Cross Memory Attach
Message-ID: <20100915225019.4ca665fc@lilo>
In-Reply-To: <20100915080235.GA13152@elte.hu>
References: <20100915104855.41de3ebf@lilo>
	<20100915080235.GA13152@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 15 Sep 2010 10:02:35 +0200
Ingo Molnar <mingo@elte.hu> wrote:
> 
> What did those OpenMPI facilities use before your patch - shared
> memory or sockets?

This comparison is against OpenMPI using the shared memory btl.

> I have an observation about the interface:
> 
> A small detail: 'int flags' should probably be 'unsigned long flags'
> - it leaves more space.

ok.

> Also, note that there is a further performance optimization possible 
> here: if the other task's ->mm is the same as this task's (they share 
> the MM), then the copy can be done straight in this process context, 
> without GUP. User-space might not necessarily be aware of this so it 
> might make sense to express this special case in the kernel too.

ok.

> More fundamentally, wouldnt it make sense to create an iovec
> interface here? If the Gather(v) / Scatter(v) / AlltoAll(v) workloads
> have any fragmentation on the user-space buffer side then the copy of
> multiple areas could be done in a single syscall. (the MM lock has to
> be touched only once, target task only be looked up only once, etc.)

yes, I think so. Currently where I'm using the interface in OpenMPI I
can't take advantage of this, but it could be changed in the future- and
its likely other MPI's could take advantage of it already.

> Plus, a small naming detail, shouldnt the naming be more IO like:
> 
>   sys_process_vm_read()
>   sys_process_vm_write()

Yes, that looks better to me. I really wasn't sure how to name them.

Regards,

Chris
-- 
cyeoh@au.ibm.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
