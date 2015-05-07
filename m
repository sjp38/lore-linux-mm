Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 55CF66B0032
	for <linux-mm@kvack.org>; Thu,  7 May 2015 07:30:34 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so40360609wgy.2
        for <linux-mm@kvack.org>; Thu, 07 May 2015 04:30:33 -0700 (PDT)
Received: from e06smtp17.uk.ibm.com (e06smtp17.uk.ibm.com. [195.75.94.113])
        by mx.google.com with ESMTPS id d5si2760654wjb.200.2015.05.07.04.30.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Thu, 07 May 2015 04:30:33 -0700 (PDT)
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dahi@linux.vnet.ibm.com>;
	Thu, 7 May 2015 12:30:31 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id C5BE02190066
	for <linux-mm@kvack.org>; Thu,  7 May 2015 12:30:11 +0100 (BST)
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t47BUTIQ6291738
	for <linux-mm@kvack.org>; Thu, 7 May 2015 11:30:29 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t47BUOI2027768
	for <linux-mm@kvack.org>; Thu, 7 May 2015 05:30:29 -0600
Date: Thu, 7 May 2015 13:30:22 +0200
From: David Hildenbrand <dahi@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC 01/15] uaccess: count pagefault_disable() levels in
 pagefault_disabled
Message-ID: <20150507133022.7da17fbb@thinkpad-w530>
In-Reply-To: <20150507112501.GA15439@gmail.com>
References: <1430934639-2131-1-git-send-email-dahi@linux.vnet.ibm.com>
	<1430934639-2131-2-git-send-email-dahi@linux.vnet.ibm.com>
	<20150507102254.GE23123@twins.programming.kicks-ass.net>
	<20150507125053.5d2e8f0a@thinkpad-w530>
	<20150507111231.GF23123@twins.programming.kicks-ass.net>
	<20150507132335.51016fe4@thinkpad-w530>
	<20150507112501.GA15439@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, mingo@redhat.com, yang.shi@windriver.com, bigeasy@linutronix.de, benh@kernel.crashing.org, paulus@samba.org, akpm@linux-foundation.org, heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com, borntraeger@de.ibm.com, mst@redhat.com, tglx@linutronix.de, David.Laight@ACULAB.COM, hughd@google.com, hocko@suse.cz, ralf@linux-mips.org, herbert@gondor.apana.org.au, linux@arm.linux.org.uk, airlied@linux.ie, daniel.vetter@intel.com, linux-mm@kvack.org, linux-arch@vger.kernel.org

> 
> * David Hildenbrand <dahi@linux.vnet.ibm.com> wrote:
> 
> > > On Thu, May 07, 2015 at 12:50:53PM +0200, David Hildenbrand wrote:
> > > > Just to make sure we have a common understanding (as written in my cover
> > > > letter):
> > > > 
> > > > Your suggestion won't work with !CONFIG_PREEMPT (!CONFIG_PREEMPT_COUNT). If
> > > > there is no preempt counter, in_atomic() won't work. 
> > > 
> > > But there is, we _always_ have a preempt_count, and irq_enter() et al.
> > > _always_ increment the relevant bits.
> > > 
> > > The thread_info::preempt_count field it never under PREEMPT_COUNT
> > > include/asm-generic/preempt.h provides stuff regardless of
> > > PREEMPT_COUNT.
> > > 
> > > See how __irq_enter() -> preempt_count_add(HARDIRQ_OFFSET) ->
> > > __preempt_count_add() _always_ just works.
> > > 
> > > Its only things like preempt_disable() / preempt_enable() that get
> > > munged depending on PREEMPT_COUNT/PREEMPT.
> > > 
> > 
> > Sorry for the confusion. Sure, there is always the count.
> > 
> > My point is that preempt_disable() won't result in an in_atomic() == true
> > with !PREEMPT_COUNT, so I don't see any point in adding in to the pagefault
> > handlers. It is not reliable.
> 
> That's why we have the preempt_count_inc()/dec() methods that are 
> always available.
> 
> So where's the problem?


My point:

Getting rid of PREEMPT_COUNT (and therefore always doing
preempt_count_inc()/dec()) will make preempt_disable() __never__ be a NOP.

So with !CONFIG_PREEMPT we will do preemption stuff that is simply not needed.

Two concepts that share one mechanism. I think this is broken.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
