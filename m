Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id AB8466B0070
	for <linux-mm@kvack.org>; Thu,  7 May 2015 07:40:41 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so40612640wgy.2
        for <linux-mm@kvack.org>; Thu, 07 May 2015 04:40:41 -0700 (PDT)
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com. [195.75.94.108])
        by mx.google.com with ESMTPS id p17si7092254wiv.0.2015.05.07.04.40.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Thu, 07 May 2015 04:40:40 -0700 (PDT)
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dahi@linux.vnet.ibm.com>;
	Thu, 7 May 2015 12:40:38 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id B78A617D805D
	for <linux-mm@kvack.org>; Thu,  7 May 2015 12:41:20 +0100 (BST)
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t47BeZFf65732652
	for <linux-mm@kvack.org>; Thu, 7 May 2015 11:40:35 GMT
Received: from d06av04.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t47BeWKW017833
	for <linux-mm@kvack.org>; Thu, 7 May 2015 05:40:34 -0600
Date: Thu, 7 May 2015 13:40:30 +0200
From: David Hildenbrand <dahi@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC 01/15] uaccess: count pagefault_disable() levels in
 pagefault_disabled
Message-ID: <20150507134030.137deeb2@thinkpad-w530>
In-Reply-To: <20150507111231.GF23123@twins.programming.kicks-ass.net>
References: <1430934639-2131-1-git-send-email-dahi@linux.vnet.ibm.com>
	<1430934639-2131-2-git-send-email-dahi@linux.vnet.ibm.com>
	<20150507102254.GE23123@twins.programming.kicks-ass.net>
	<20150507125053.5d2e8f0a@thinkpad-w530>
	<20150507111231.GF23123@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel@vger.kernel.org, mingo@redhat.com, yang.shi@windriver.com, bigeasy@linutronix.de, benh@kernel.crashing.org, paulus@samba.org, akpm@linux-foundation.org, heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com, borntraeger@de.ibm.com, mst@redhat.com, tglx@linutronix.de, David.Laight@ACULAB.COM, hughd@google.com, hocko@suse.cz, ralf@linux-mips.org, herbert@gondor.apana.org.au, linux@arm.linux.org.uk, airlied@linux.ie, daniel.vetter@intel.com, linux-mm@kvack.org, linux-arch@vger.kernel.org

> On Thu, May 07, 2015 at 12:50:53PM +0200, David Hildenbrand wrote:
> > Just to make sure we have a common understanding (as written in my cover
> > letter):
> > 
> > Your suggestion won't work with !CONFIG_PREEMPT (!CONFIG_PREEMPT_COUNT). If
> > there is no preempt counter, in_atomic() won't work. 
> 
> But there is, we _always_ have a preempt_count, and irq_enter() et al.
> _always_ increment the relevant bits.
> 
> The thread_info::preempt_count field it never under PREEMPT_COUNT
> include/asm-generic/preempt.h provides stuff regardless of
> PREEMPT_COUNT.
> 
> See how __irq_enter() -> preempt_count_add(HARDIRQ_OFFSET) ->
> __preempt_count_add() _always_ just works.


Okay thinking about this further, I think I got your point. That basically means
that the in_atomic() check makes sense for irqs.

But in my opinion, it does not help do replace

preempt_disable()
pagefault_disable()

by

preempt_disable()


(as discussed because of the PREEMPT_COUNT stuff)

So I agree that we should better add it to not mess with hard/soft irq.

> 
> Its only things like preempt_disable() / preempt_enable() that get
> munged depending on PREEMPT_COUNT/PREEMPT.
> 

But anyhow, opinions seem to differ how to best handle that whole stuff.

I think a separate counter just makes sense, as we are dealing with two
different concepts and we don't want to lose the preempt_disable =^ NOP
for !CONFIG_PREEMPT.

I also think that

pagefault_disable()
rt = copy_from_user()
pagefault_enable()

is a valid use case.

So any suggestions how to continue?

Thanks!

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
