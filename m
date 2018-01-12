Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 19F266B0069
	for <linux-mm@kvack.org>; Fri, 12 Jan 2018 13:48:42 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id p17so5677635pfh.18
        for <linux-mm@kvack.org>; Fri, 12 Jan 2018 10:48:42 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id y10si6406578pgp.405.2018.01.12.10.48.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 12 Jan 2018 10:48:40 -0800 (PST)
Date: Fri, 12 Jan 2018 10:48:21 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v6 16/24] mm: Protect mm_rb tree with a rwlock
Message-ID: <20180112184821.GB7590@bombadil.infradead.org>
References: <1515777968-867-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1515777968-867-17-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1515777968-867-17-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On Fri, Jan 12, 2018 at 06:26:00PM +0100, Laurent Dufour wrote:
> -static void __vma_rb_erase(struct vm_area_struct *vma, struct rb_root *root)
> +static void __vma_rb_erase(struct vm_area_struct *vma, struct mm_struct *mm)
>  {
> +	struct rb_root *root = &mm->mm_rb;
>  	/*
>  	 * Note rb_erase_augmented is a fairly large inline function,
>  	 * so make sure we instantiate it only once with our desired
>  	 * augmented rbtree callbacks.
>  	 */
> +#ifdef CONFIG_SPF
> +	write_lock(&mm->mm_rb_lock);
> +#endif
>  	rb_erase_augmented(&vma->vm_rb, root, &vma_gap_callbacks);
> +#ifdef CONFIG_SPF
> +	write_unlock(&mm->mm_rb_lock); /* wmb */
> +#endif

I can't say I love this.  Have you considered:

#ifdef CONFIG_SPF
#define vma_rb_write_lock(mm)	write_lock(&mm->mm_rb_lock)
#define vma_rb_write_unlock(mm)	write_unlock(&mm->mm_rb_lock)
#else
#define vma_rb_write_lock(mm)	do { } while (0)
#define vma_rb_write_unlock(mm)	do { } while (0)
#endif

Also, SPF is kind of uninformative.  CONFIG_MM_SPF might be better?
Or perhaps even CONFIG_SPECULATIVE_PAGE_FAULT, just to make it really
painful to do these one-liner ifdefs that make the code so hard to read.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
