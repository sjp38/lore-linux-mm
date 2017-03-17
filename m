Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4B25D6B0038
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 10:41:51 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id u108so14114431wrb.3
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 07:41:51 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id g80si11416352wrd.149.2017.03.17.07.41.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 17 Mar 2017 07:41:49 -0700 (PDT)
Date: Fri, 17 Mar 2017 15:41:41 +0100
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [locking/lockdep] 383776fa75:  INFO: trying to register
 non-static key.
Message-ID: <20170317144140.cpsdlpairb2falsv@linutronix.de>
References: <58cad449.RTO+aYLdogbZs5Le%fengguang.wu@intel.com>
 <20170317134109.e7qmjwpryelpbgz2@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20170317134109.e7qmjwpryelpbgz2@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: kernel test robot <fengguang.wu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, LKP <lkp@01.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, wfg@linux.intel.com

On 2017-03-17 14:41:09 [+0100], Peter Zijlstra wrote:
> On Fri, Mar 17, 2017 at 02:07:05AM +0800, kernel test robot wrote:
> 
> >     locking/lockdep: Handle statically initialized PER_CPU locks properly
> 
> > [   11.712266] INFO: trying to register non-static key.
> 
> Blergh; so the problem is that when we assign can_addr to lock->key, we
> can, upon using a different subclass, reach static_obj(lock->key), which
> will fail on the can_addr.
> 
> One way to fix this would be to redefine the canonical address as the
> per-cpu address for a specific cpu; the below hard codes cpu0, but I'm
> not sure we want to rely on cpu0 being a valid cpu.

This solves two problems: The one reported by the bot. The other thing,
that is fixed by the patch, is that the first PER-CPU variable built-in
will return 0 for can_addr and so will the first variable in every
module. As far as I understand it, this should be unique and having the
same value for multiple different variables does not look too good :)
So adding the offset from CPU0 sounds good.

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
