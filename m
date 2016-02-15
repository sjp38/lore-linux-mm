Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id D61F7828E2
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 09:14:29 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id fl4so74716058pad.0
        for <linux-mm@kvack.org>; Mon, 15 Feb 2016 06:14:29 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id y1si15796210pfi.229.2016.02.15.06.14.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Feb 2016 06:14:28 -0800 (PST)
Date: Mon, 15 Feb 2016 15:14:07 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH RFC] Introduce atomic and per-cpu add-max and sub-min
 operations
Message-ID: <20160215141407.GE6357@twins.programming.kicks-ass.net>
References: <145544094056.28219.12239469516497703482.stgit@zurg>
 <20160215105028.GB1748@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160215105028.GB1748@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, linux-arch@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, paulmck@linux.vnet.ibm.com

On Mon, Feb 15, 2016 at 10:50:29AM +0000, Will Deacon wrote:
> Adding Peter and Paul,
> 
> On Sun, Feb 14, 2016 at 12:09:00PM +0300, Konstantin Khlebnikov wrote:
> > bool atomic_add_max(atomic_t *var, int add, int max);
> > bool atomic_sub_min(atomic_t *var, int sub, int min);
> 
> What are the memory-ordering requirements for these? Do you also want
> relaxed/acquire/release versions for the use-cases you outline?
> 
> One observation is that you provide no ordering guarantees if the
> comparison fails, which is fine if that's what you want, but we should
> probably write that down like we do for cmpxchg.
> 
> > bool this_cpu_add_max(var, add, max);
> > bool this_cpu_sub_min(var, sub, min);
> > 
> > They add/subtract only if result will be not bigger than max/lower that min.
> > Returns true if operation was done and false otherwise.
> > 
> > Inside they check that (add <= max - var) and (sub <= var - min). Signed
> > operations work if all possible values fits into range which length fits
> > into non-negative range of that type: 0..INT_MAX, INT_MIN+1..0, -1000..1000.
> > Unsigned operations work if value always in valid range: min <= var <= max.
> > Char and short automatically casts to int, they never overflows.
> > 
> > Patch adds the same for atomic_long_t, atomic64_t, local_t, local64_t.
> > And unsigned variants: atomic_u32_add_max atomic_u32_sub_min for atomic_t,
> > atomic_u64_add_max atomic_u64_sub_min for atomic64_t.
> > 
> > Patch comes with test which hopefully covers all possible cornercases,
> > see CONFIG_ATOMIC64_SELFTEST and CONFIG_PERCPU_TEST.
> > 
> > All this allows to build any kind of counter in several lines:
> 
> Do you have another patch converting people over to these new atomics?

The Changelog completely lacks a why. Why do we want this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
