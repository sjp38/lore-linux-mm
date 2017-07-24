Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4F6C36B0292
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 19:54:53 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id q50so26372804wrb.14
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 16:54:53 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b50si10317248wrb.438.2017.07.24.16.54.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 16:54:51 -0700 (PDT)
Date: Mon, 24 Jul 2017 16:54:49 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Prevent racy access to tlb_flush_pending
Message-Id: <20170724165449.1a51b34d22ee4a9b54ce2652@linux-foundation.org>
In-Reply-To: <20170717180246.62277-1-namit@vmware.com>
References: <20170717180246.62277-1-namit@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <namit@vmware.com>
Cc: linux-mm@kvack.org, nadav.amit@gmail.com, mgorman@suse.de, riel@redhat.com, luto@kernel.org

On Mon, 17 Jul 2017 11:02:46 -0700 Nadav Amit <namit@vmware.com> wrote:

> Setting and clearing mm->tlb_flush_pending can be performed by multiple
> threads, since mmap_sem may only be acquired for read in task_numa_work.
> If this happens, tlb_flush_pending may be cleared while one of the
> threads still changes PTEs and batches TLB flushes.
> 
> As a result, TLB flushes can be skipped because the indication of
> pending TLB flushes is lost, for instance due to race between
> migration and change_protection_range (just as in the scenario that
> caused the introduction of tlb_flush_pending).
> 
> The feasibility of such a scenario was confirmed by adding assertion to
> check tlb_flush_pending is not set by two threads, adding artificial
> latency in change_protection_range() and using sysctl to reduce
> kernel.numa_balancing_scan_delay_ms.
> 
> Fixes: 20841405940e ("mm: fix TLB flush race between migration, and
> change_protection_range")
> 

The changelog doesn't describe the user-visible effects of the bug (it
should always do so, please).  But it is presumably a data-corruption
bug so I suggest that a -stable backport is warranted?

It has been there for 4 years so I'm thinking we can hold off a
mainline (and hence -stable) merge until 4.13-rc1, yes?


One thought:

> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
>
> ...
>
> @@ -528,11 +528,11 @@ static inline cpumask_t *mm_cpumask(struct mm_struct *mm)
>  static inline bool mm_tlb_flush_pending(struct mm_struct *mm)
>  {
>  	barrier();
> -	return mm->tlb_flush_pending;
> +	return atomic_read(&mm->tlb_flush_pending) > 0;
>  }
>  static inline void set_tlb_flush_pending(struct mm_struct *mm)
>  {
> -	mm->tlb_flush_pending = true;
> +	atomic_inc(&mm->tlb_flush_pending);
>  
>  	/*
>  	 * Guarantee that the tlb_flush_pending store does not leak into the
> @@ -544,7 +544,7 @@ static inline void set_tlb_flush_pending(struct mm_struct *mm)
>  static inline void clear_tlb_flush_pending(struct mm_struct *mm)
>  {
>  	barrier();
> -	mm->tlb_flush_pending = false;
> +	atomic_dec(&mm->tlb_flush_pending);
>  }
>  #else

Do we still need the barrier()s or is it OK to let the atomic op do
that for us (with a suitable code comment).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
