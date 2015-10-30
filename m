Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id BD2AB82F64
	for <linux-mm@kvack.org>; Fri, 30 Oct 2015 16:18:06 -0400 (EDT)
Received: by igbhv6 with SMTP id hv6so18979762igb.0
        for <linux-mm@kvack.org>; Fri, 30 Oct 2015 13:18:06 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id vk8si3985819igb.53.2015.10.30.13.18.05
        for <linux-mm@kvack.org>;
        Fri, 30 Oct 2015 13:18:06 -0700 (PDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC] mm: add a new vector based madvise syscall
References: <20151029215516.GA3864685@devbig084.prn1.facebook.com>
Date: Fri, 30 Oct 2015 13:17:54 -0700
In-Reply-To: <20151029215516.GA3864685@devbig084.prn1.facebook.com> (Shaohua
	Li's message of "Thu, 29 Oct 2015 14:55:16 -0700")
Message-ID: <871tccaz65.fsf@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, hughd@google.com, hannes@cmpxchg.org, aarcange@redhat.com, je@fb.com, Kernel-team@fb.com

Shaohua Li <shli@fb.com> writes:
> +		vmas[i] = find_vma(current->mm, start);
> +		/*
> +		 * don't allow range cross vma, it doesn't make sense for
> +		 * DONTNEED
> +		 */
> +		if (!vmas[i] || start < vmas[i]->vm_start ||
> +		    start + len > vmas[i]->vm_end) {
> +			error = -ENOMEM;
> +			goto up_out;
> +		}
> +		if (vmas[i]->vm_flags & (VM_LOCKED|VM_HUGETLB|VM_PFNMAP)) {
> +			error = -EINVAL;
> +			goto up_out;
> +		}
> +	}

Needs a cond_resched() somewhere in case the list is very long?

BTW one trick that may be interesting here is to add a new mode
that skips the TLB flush completely, but instead waits with
the freeing until enough context switches to non kernel tasks occurred
(and flushed the TLB this way). This could be done as part of RCU.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
