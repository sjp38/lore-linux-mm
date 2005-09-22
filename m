Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j8MKVNXI001009
	for <linux-mm@kvack.org>; Thu, 22 Sep 2005 16:31:23 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j8MKVNYO095280
	for <linux-mm@kvack.org>; Thu, 22 Sep 2005 16:31:23 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j8MKVMhR004756
	for <linux-mm@kvack.org>; Thu, 22 Sep 2005 16:31:23 -0400
Subject: Re: [PATCH] __kmalloc: Generate BUG if size requested is too large.
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.62.0509221232140.17975@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0509221232140.17975@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Thu, 22 Sep 2005 13:31:00 -0700
Message-Id: <1127421060.10664.76.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2005-09-22 at 12:32 -0700, Christoph Lameter wrote:
> I had an issue on ia64 where I got a bug in kernel/workqueue because kzalloc
> returned a NULL pointer due to the task structure getting too big for the slab
> allocator. Usually these cases are caught by the kmalloc macro in include/linux/slab.h.
> Compilation will fail if a too big value is passed to kmalloc.

I'd be more concerned that the workqueue code wasn't checking for NULL.
Also, the one place where I see the workqueue code using kzalloc(), it
checks for kzalloc() failure (in __create_workqueue).

> However, kzalloc uses __kmalloc which has no check for that. This
> patch makes __kmalloc bug if a too large entity is requested.

I don't see that in current -git, either.  Which version of the kernel
are you working against?

> void *kzalloc(size_t size, unsigned int __nocast flags)
> {
>         void *ret = kmalloc(size, flags);
>         if (ret)
>                 memset(ret, 0, size);
>         return ret;
> }
> EXPORT_SYMBOL(kzalloc);

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
