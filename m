Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 7BD606B0032
	for <linux-mm@kvack.org>; Thu,  7 May 2015 07:25:08 -0400 (EDT)
Received: by wizk4 with SMTP id k4so238403673wiz.1
        for <linux-mm@kvack.org>; Thu, 07 May 2015 04:25:08 -0700 (PDT)
Received: from mail-wi0-x22d.google.com (mail-wi0-x22d.google.com. [2a00:1450:400c:c05::22d])
        by mx.google.com with ESMTPS id j18si2757333wjr.158.2015.05.07.04.25.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 May 2015 04:25:06 -0700 (PDT)
Received: by wiun10 with SMTP id n10so55858472wiu.1
        for <linux-mm@kvack.org>; Thu, 07 May 2015 04:25:05 -0700 (PDT)
Date: Thu, 7 May 2015 13:25:01 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH RFC 01/15] uaccess: count pagefault_disable() levels in
 pagefault_disabled
Message-ID: <20150507112501.GA15439@gmail.com>
References: <1430934639-2131-1-git-send-email-dahi@linux.vnet.ibm.com>
 <1430934639-2131-2-git-send-email-dahi@linux.vnet.ibm.com>
 <20150507102254.GE23123@twins.programming.kicks-ass.net>
 <20150507125053.5d2e8f0a@thinkpad-w530>
 <20150507111231.GF23123@twins.programming.kicks-ass.net>
 <20150507132335.51016fe4@thinkpad-w530>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150507132335.51016fe4@thinkpad-w530>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <dahi@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, mingo@redhat.com, yang.shi@windriver.com, bigeasy@linutronix.de, benh@kernel.crashing.org, paulus@samba.org, akpm@linux-foundation.org, heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com, borntraeger@de.ibm.com, mst@redhat.com, tglx@linutronix.de, David.Laight@ACULAB.COM, hughd@google.com, hocko@suse.cz, ralf@linux-mips.org, herbert@gondor.apana.org.au, linux@arm.linux.org.uk, airlied@linux.ie, daniel.vetter@intel.com, linux-mm@kvack.org, linux-arch@vger.kernel.org


* David Hildenbrand <dahi@linux.vnet.ibm.com> wrote:

> > On Thu, May 07, 2015 at 12:50:53PM +0200, David Hildenbrand wrote:
> > > Just to make sure we have a common understanding (as written in my cover
> > > letter):
> > > 
> > > Your suggestion won't work with !CONFIG_PREEMPT (!CONFIG_PREEMPT_COUNT). If
> > > there is no preempt counter, in_atomic() won't work. 
> > 
> > But there is, we _always_ have a preempt_count, and irq_enter() et al.
> > _always_ increment the relevant bits.
> > 
> > The thread_info::preempt_count field it never under PREEMPT_COUNT
> > include/asm-generic/preempt.h provides stuff regardless of
> > PREEMPT_COUNT.
> > 
> > See how __irq_enter() -> preempt_count_add(HARDIRQ_OFFSET) ->
> > __preempt_count_add() _always_ just works.
> > 
> > Its only things like preempt_disable() / preempt_enable() that get
> > munged depending on PREEMPT_COUNT/PREEMPT.
> > 
> 
> Sorry for the confusion. Sure, there is always the count.
> 
> My point is that preempt_disable() won't result in an in_atomic() == true
> with !PREEMPT_COUNT, so I don't see any point in adding in to the pagefault
> handlers. It is not reliable.

That's why we have the preempt_count_inc()/dec() methods that are 
always available.

So where's the problem?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
