Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id 355FB6B003A
	for <linux-mm@kvack.org>; Tue, 25 Mar 2014 12:52:04 -0400 (EDT)
Received: by mail-ob0-f178.google.com with SMTP id wp18so878923obc.37
        for <linux-mm@kvack.org>; Tue, 25 Mar 2014 09:52:03 -0700 (PDT)
Received: from qmta15.emeryville.ca.mail.comcast.net (qmta15.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:228])
        by mx.google.com with ESMTP id z8si22809166oex.128.2014.03.25.09.52.01
        for <linux-mm@kvack.org>;
        Tue, 25 Mar 2014 09:52:02 -0700 (PDT)
Date: Tue, 25 Mar 2014 11:51:59 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: mm: slub: gpf in deactivate_slab
In-Reply-To: <5331A6C3.2000303@oracle.com>
Message-ID: <alpine.DEB.2.10.1403251150330.16870@nuc>
References: <53208A87.2040907@oracle.com> <5331A6C3.2000303@oracle.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 25 Mar 2014, Sasha Levin wrote:

> I have a lead on this. Consider the following:
>
>   kmem_cache_alloc
> 	__slab_alloc
> 		local_irq_save()
> 		deactivate_slab
> 			__cmpxchg_double_slab
> 				slab_unlock
> 					__bit_spin_unlock
> 						preempt_enable
> 		[ Page Fault ]
>
> With this trace, it manifests as a "BUG: sleeping function called from invalid
> context at arch/x86/mm/fault.c" on a might_sleep() in the page fault handler
> (which is an issue on it's own), but I suspect it's also the cause of the
> trace
> above - preemption enabled and a race that removed the page.
>
> Could someone confirm please?

The preempt count is incremented earlier in bit_spin_lock so the
preempt_enable() should not do anything.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
