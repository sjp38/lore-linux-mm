Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 896796B0038
	for <linux-mm@kvack.org>; Wed, 13 May 2015 03:38:26 -0400 (EDT)
Received: by wicmc15 with SMTP id mc15so71595753wic.1
        for <linux-mm@kvack.org>; Wed, 13 May 2015 00:38:25 -0700 (PDT)
Received: from e06smtp17.uk.ibm.com (e06smtp17.uk.ibm.com. [195.75.94.113])
        by mx.google.com with ESMTPS id t5si7058669wiz.99.2015.05.13.00.38.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Wed, 13 May 2015 00:38:24 -0700 (PDT)
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dahi@linux.vnet.ibm.com>;
	Wed, 13 May 2015 08:38:22 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 3468717D805D
	for <linux-mm@kvack.org>; Wed, 13 May 2015 08:39:07 +0100 (BST)
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t4D7cI8r48300094
	for <linux-mm@kvack.org>; Wed, 13 May 2015 07:38:18 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t4D7cEFI005084
	for <linux-mm@kvack.org>; Wed, 13 May 2015 01:38:18 -0600
Date: Wed, 13 May 2015 09:38:12 +0200
From: David Hildenbrand <dahi@linux.vnet.ibm.com>
Subject: Re: [PATCH v1 11/15] arm/futex: UP futex_atomic_op_inuser() relies
 on disabled preemption
Message-ID: <20150513093812.65fdac96@thinkpad-w530>
In-Reply-To: <20150512190014.GD25464@linutronix.de>
References: <1431359540-32227-1-git-send-email-dahi@linux.vnet.ibm.com>
	<1431359540-32227-12-git-send-email-dahi@linux.vnet.ibm.com>
	<20150512190014.GD25464@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: linux-kernel@vger.kernel.org, mingo@redhat.com, yang.shi@windriver.com, benh@kernel.crashing.org, paulus@samba.org, akpm@linux-foundation.org, heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com, borntraeger@de.ibm.com, mst@redhat.com, tglx@linutronix.de, David.Laight@ACULAB.COM, hughd@google.com, hocko@suse.cz, ralf@linux-mips.org, herbert@gondor.apana.org.au, linux@arm.linux.org.uk, airlied@linux.ie, daniel.vetter@intel.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, peterz@infradead.org

> * David Hildenbrand | 2015-05-11 17:52:16 [+0200]:
> 
> >The !CONFIG_SMP implementation of futex_atomic_op_inuser() seems to rely
> >on disabled preemption to guarantee mutual exclusion.
> 
> Yes, this is what the code looks like. It is more the requirement for
> ldrex/strex opcodes which are ARMv6+ and so is SMP support (here).
> Documentation wise you could replace CONFIG_SMP by 
>      __LINUX_ARM_ARCH__ >= 6
> in a later patch if you like. This would be more in-sync with
> arch/arm/include/asm/cmpxchg.h :)
> 
> Sebastian

Thanks, I'll include it in the next version.

So I assume the cleanest thing to do would be:

#if __LINUX_ARM_ARCH__ < 6
	preempt_disable();
#endif


David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
