Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 5E0F76B003D
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 11:58:31 -0400 (EDT)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.1/8.13.1) with ESMTP id n2CFwSra019354
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 15:58:28 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2CFwRTc1335416
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 16:58:27 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2CFwRBv024532
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 16:58:27 +0100
Date: Thu, 12 Mar 2009 16:54:51 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH] acquire mmap semaphore in pagemap_read.
Message-ID: <20090312165451.1a7ef22f@skybase>
In-Reply-To: <1236871414.3213.50.camel@calx>
References: <20090312113308.6fe18a93@skybase>
	<20090312114533.GA2407@x200.localdomain>
	<20090312125410.25400d18@skybase>
	<1236871414.3213.50.camel@calx>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Matt Mackall <mpm@selenic.com>
Cc: Alexey Dobriyan <adobriyan@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gerald Schaefer <gerald.schaefer@de.ibm.com>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, 12 Mar 2009 10:23:34 -0500
Matt Mackall <mpm@selenic.com> wrote:

> Well it means we may have to reintroduce the very annoying double
> buffering from various earlier implementations. But let's leave this
> discussion until after we've figured out what to do about the walker
> code.

About the walker code. I've realized that there is another way to fix
this. The TASK_SIZE definition is currently used for two things: 1) as
a maximum mappable address, 2) the size of the address space for a
process. And there lies a problem: while a process is using a reduced
page table 1) and 2) differ. If I make TASK_SIZE give you the current
size of the address space then it is not possible to mmap an object
beyond 4TB and the page table upgrade never happens. If I make
TASK_SIZE return the maximum mappable address the page table walker
breaks. The solution could be to introduce MAX_TASK_SIZE and use that
in the mmap code to find out what can be mapped.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
