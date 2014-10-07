Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id ABCD06B0038
	for <linux-mm@kvack.org>; Tue,  7 Oct 2014 18:04:21 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id rd3so7902908pab.20
        for <linux-mm@kvack.org>; Tue, 07 Oct 2014 15:04:21 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id xg7si16676662pbc.90.2014.10.07.15.04.19
        for <linux-mm@kvack.org>;
        Tue, 07 Oct 2014 15:04:20 -0700 (PDT)
Message-ID: <5434630C.3070006@intel.com>
Date: Tue, 07 Oct 2014 15:02:52 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/5] mm: poison page struct
References: <1412041639-23617-1-git-send-email-sasha.levin@oracle.com> <1412041639-23617-6-git-send-email-sasha.levin@oracle.com>
In-Reply-To: <1412041639-23617-6-git-send-email-sasha.levin@oracle.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, mgorman@suse.de, Christoph Lameter <cl@linux.com>

On 09/29/2014 06:47 PM, Sasha Levin wrote:
>  struct page {
> +#ifdef CONFIG_DEBUG_VM_POISON
> +	u32 poison_start;
> +#endif
>  	/* First double word block */
>  	unsigned long flags;		/* Atomic flags, some possibly
>  					 * updated asynchronously */
> @@ -196,6 +199,9 @@ struct page {
>  #ifdef LAST_CPUPID_NOT_IN_PAGE_FLAGS
>  	int _last_cpupid;
>  #endif
> +#ifdef CONFIG_DEBUG_VM_POISON
> +	u32 poison_end;
> +#endif
>  }

Does this break slub's __cmpxchg_double_slab trick?  I thought it
required page->freelist and page->counters to be doubleword-aligned.

It's not like we really require this optimization when we're debugging,
but trying to use it will unnecessarily slow things down.

FWIW, if you're looking to trim down the number of lines of code, you
could certainly play some macro tricks and #ifdef tricks.

struct vm_poison {
#ifdef CONFIG_DEBUG_VM_POISON
	u32 val;
#endif	
};

Then, instead of #ifdefs in each structure, you do:

struct page {
	struct vm_poison poison_start;
	... other gunk
	struct vm_poison poison_end;
};

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
