Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0B8C26B0038
	for <linux-mm@kvack.org>; Sat, 17 Dec 2016 22:07:04 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id b1so112380937pgc.5
        for <linux-mm@kvack.org>; Sat, 17 Dec 2016 19:07:04 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [184.105.139.130])
        by mx.google.com with ESMTP id w15si14014595pgm.99.2016.12.17.19.07.02
        for <linux-mm@kvack.org>;
        Sat, 17 Dec 2016 19:07:03 -0800 (PST)
Date: Sat, 17 Dec 2016 22:07:00 -0500 (EST)
Message-Id: <20161217.220700.50846773009762926.davem@davemloft.net>
Subject: Re: [RFC PATCH 03/14] sparc64: routines for basic mmu shared
 context structure management
From: David Miller <davem@davemloft.net>
In-Reply-To: <1481913337-9331-4-git-send-email-mike.kravetz@oracle.com>
References: <1481913337-9331-1-git-send-email-mike.kravetz@oracle.com>
	<1481913337-9331-4-git-send-email-mike.kravetz@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mike.kravetz@oracle.com
Cc: sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bob.picco@oracle.com, nitin.m.gupta@oracle.com, vijay.ac.kumar@oracle.com, julian.calaby@gmail.com, adam.buchbinder@gmail.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, akpm@linux-foundation.org

From: Mike Kravetz <mike.kravetz@oracle.com>
Date: Fri, 16 Dec 2016 10:35:26 -0800

> +void smp_flush_shared_tlb_mm(struct mm_struct *mm)
> +{
> +	u32 ctx = SHARED_CTX_HWBITS(mm->context);
> +
> +	(void)get_cpu();		/* prevent preemption */

preempt_disable();

> +
> +	smp_cross_call(&xcall_flush_tlb_mm, ctx, 0, 0);
> +	__flush_tlb_mm(ctx, SECONDARY_CONTEXT);
> +
> +	put_cpu();

preempt_enable();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
