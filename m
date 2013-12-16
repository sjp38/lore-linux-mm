Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 5B3506B0035
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 03:26:41 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id z10so5028393pdj.30
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 00:26:41 -0800 (PST)
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
        by mx.google.com with ESMTPS id ye6si8222022pbc.80.2013.12.16.00.26.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 16 Dec 2013 00:26:39 -0800 (PST)
Received: by mail-pa0-f45.google.com with SMTP id fb1so2633581pad.4
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 00:26:38 -0800 (PST)
Message-ID: <52AEB937.6050704@linaro.org>
Date: Mon, 16 Dec 2013 16:26:31 +0800
From: Alex Shi <alex.shi@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] x86: mm: Change tlb_flushall_shift for IvyBridge
References: <1386849309-22584-1-git-send-email-mgorman@suse.de> <1386849309-22584-3-git-send-email-mgorman@suse.de> <20131212131309.GD5806@gmail.com> <52A9BC3A.7010602@linaro.org> <20131212141147.GB17059@gmail.com> <52AA5C92.7030207@linaro.org> <52AA6CB9.60302@linaro.org> <20131214141902.GA16438@laptop.programming.kicks-ass.net>
In-Reply-To: <20131214141902.GA16438@laptop.programming.kicks-ass.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@kernel.org>, Mel Gorman <mgorman@suse.de>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Fengguang Wu <fengguang.wu@intel.com>

On 12/14/2013 10:19 PM, Peter Zijlstra wrote:
> On Fri, Dec 13, 2013 at 10:11:05AM +0800, Alex Shi wrote:
>> BTW,
>> A bewitching idea is till attracting me.
>> https://lkml.org/lkml/2012/5/23/148
>> Even it was sentenced to death by HPA.
>> https://lkml.org/lkml/2012/5/24/143
>>
>> That is that just flush one of thread TLB is enough for SMT/HT, seems
>> TLB is still shared in core on Intel CPU. This benefit is unconditional,
>> and if my memory right, Kbuild testing can improve about 1~2% in average
>> level.
>>
>> So could you like to accept some ugly quirks to do this lazy TLB flush
>> on known working CPU?
>> Forgive me if it's stupid.
> 
> I think there's a further problem with that patch -- aside of it being
> right from a hardware point of view.
> 
> We currently rely on the tlb flush IPI to synchronize with lockless page
> table walkers like gup_fast().

I am sorry if I miss sth. :)

But if my understand correct, in the example of gup_fast, wait_split_huge_page
will never goes to BUG_ON(). Since the flush TLB IPI still be sent out to clear
each of _PAGE_SPLITTING on each CPU core. This patch just stop repeat TLB flush
in another SMT on same core. If there only noe SMT affected, the flush still be 
executed on it.

#define wait_split_huge_page(__anon_vma, __pmd)                         \
        do {                                                            \
                pmd_t *____pmd = (__pmd);                               \
                anon_vma_lock_write(__anon_vma);                        \
                anon_vma_unlock_write(__anon_vma);                      \
                BUG_ON(pmd_trans_splitting(*____pmd) ||                 \
                       pmd_trans_huge(*____pmd));                       \
        } while (0)

> 
> By not sending an IPI to all CPUs you can get into trouble and crash the
> kernel.
> 
> We absolutely must keep sending the IPI to all relevant CPUs, we can
> choose not to actually do the flush on some CPUs, but we must keep
> sending the IPI.
> 


-- 
Thanks
    Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
