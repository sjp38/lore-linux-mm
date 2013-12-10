Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id EB0B76B0035
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 09:26:07 -0500 (EST)
Received: by mail-ee0-f43.google.com with SMTP id c13so2246929eek.16
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 06:26:07 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id i1si14508524eev.173.2013.12.10.06.26.06
        for <linux-mm@kvack.org>;
        Tue, 10 Dec 2013 06:26:06 -0800 (PST)
Message-ID: <52A72463.9080108@redhat.com>
Date: Tue, 10 Dec 2013 09:25:39 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 11/18] mm: fix TLB flush race between migration, and change_protection_range
References: <1386572952-1191-1-git-send-email-mgorman@suse.de> <1386572952-1191-12-git-send-email-mgorman@suse.de>
In-Reply-To: <1386572952-1191-12-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alex Thorlton <athorlton@sgi.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>

On 12/09/2013 02:09 AM, Mel Gorman wrote:

After reading the locking thread that Paul McKenney started,
I wonder if I got the barriers wrong in these functions...

> +#if defined(CONFIG_NUMA_BALANCING) || defined(CONFIG_COMPACTION)
> +/*
> + * Memory barriers to keep this state in sync are graciously provided by
> + * the page table locks, outside of which no page table modifications happen.
> + * The barriers below prevent the compiler from re-ordering the instructions
> + * around the memory barriers that are already present in the code.
> + */
> +static inline bool tlb_flush_pending(struct mm_struct *mm)
> +{
> +	barrier();

Should this be smp_mb__after_unlock_lock(); ?

> +	return mm->tlb_flush_pending;
> +}
> +static inline void set_tlb_flush_pending(struct mm_struct *mm)
> +{
> +	mm->tlb_flush_pending = true;
> +	barrier();
> +}
> +/* Clearing is done after a TLB flush, which also provides a barrier. */
> +static inline void clear_tlb_flush_pending(struct mm_struct *mm)
> +{
> +	barrier();
> +	mm->tlb_flush_pending = false;
> +}

And these smp_mb__before_spinlock() ?

Paul? Peter?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
