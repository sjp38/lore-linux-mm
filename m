Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 326EE6B000E
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 04:49:13 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id a143so1706675qkg.4
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 01:49:13 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id 37si2178400qtu.37.2018.03.14.01.49.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Mar 2018 01:49:09 -0700 (PDT)
Date: Wed, 14 Mar 2018 09:48:44 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v9 17/24] mm: Protect mm_rb tree with a rwlock
Message-ID: <20180314084844.GP4043@hirez.programming.kicks-ass.net>
References: <1520963994-28477-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1520963994-28477-18-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1520963994-28477-18-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: paulmck@linux.vnet.ibm.com, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On Tue, Mar 13, 2018 at 06:59:47PM +0100, Laurent Dufour wrote:
> This change is inspired by the Peter's proposal patch [1] which was
> protecting the VMA using SRCU. Unfortunately, SRCU is not scaling well in
> that particular case, and it is introducing major performance degradation
> due to excessive scheduling operations.

Do you happen to have a little more detail on that?

> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 34fde7111e88..28c763ea1036 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -335,6 +335,7 @@ struct vm_area_struct {
>  	struct vm_userfaultfd_ctx vm_userfaultfd_ctx;
>  #ifdef CONFIG_SPECULATIVE_PAGE_FAULT
>  	seqcount_t vm_sequence;
> +	atomic_t vm_ref_count;		/* see vma_get(), vma_put() */
>  #endif
>  } __randomize_layout;
>  
> @@ -353,6 +354,9 @@ struct kioctx_table;
>  struct mm_struct {
>  	struct vm_area_struct *mmap;		/* list of VMAs */
>  	struct rb_root mm_rb;
> +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
> +	rwlock_t mm_rb_lock;
> +#endif
>  	u32 vmacache_seqnum;                   /* per-thread vmacache */
>  #ifdef CONFIG_MMU
>  	unsigned long (*get_unmapped_area) (struct file *filp,

When I tried this, it simply traded contention on mmap_sem for
contention on these two cachelines.

This was for the concurrent fault benchmark, where mmap_sem is only ever
acquired for reading (so no blocking ever happens) and the bottle-neck
was really pure cacheline access.

Only by using RCU can you avoid that thrashing.

Also note that if your database allocates the one giant mapping, it'll
be _one_ VMA and that vm_ref_count gets _very_ hot indeed.
