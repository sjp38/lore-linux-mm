Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 8746A6B0033
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 16:28:14 -0400 (EDT)
Date: Wed, 7 Aug 2013 13:28:12 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 2/2] [PATCH] mm: Save soft-dirty bits on file pages
Message-Id: <20130807132812.60ad4bfe85127794094d385e@linux-foundation.org>
In-Reply-To: <20130730204654.966378702@gmail.com>
References: <20130730204154.407090410@gmail.com>
	<20130730204654.966378702@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, luto@amacapital.net, gorcunov@openvz.org, xemul@parallels.com, mpm@selenic.com, xiaoguangrong@linux.vnet.ibm.com, mtosatti@redhat.com, kosaki.motohiro@gmail.com, sfr@canb.auug.org.au, peterz@infradead.org, aneesh.kumar@linux.vnet.ibm.com

On Wed, 31 Jul 2013 00:41:56 +0400 Cyrill Gorcunov <gorcunov@gmail.com> wrote:

> +#define pte_to_pgoff(pte)						\
> +	((((pte).pte_low >> (PTE_FILE_SHIFT1))				\
> +	  & ((1U << PTE_FILE_BITS1) - 1)))				\
> +	+ ((((pte).pte_low >> (PTE_FILE_SHIFT2))			\
> +	    & ((1U << PTE_FILE_BITS2) - 1))				\
> +	   << (PTE_FILE_BITS1))						\
> +	+ ((((pte).pte_low >> (PTE_FILE_SHIFT3))			\
> +	    & ((1U << PTE_FILE_BITS3) - 1))				\
> +	   << (PTE_FILE_BITS1 + PTE_FILE_BITS2))			\
> +	+ ((((pte).pte_low >> (PTE_FILE_SHIFT4)))			\
> +	    << (PTE_FILE_BITS1 + PTE_FILE_BITS2 + PTE_FILE_BITS3))
> +
> +#define pgoff_to_pte(off)						\
> +	((pte_t) { .pte_low =						\
> +	 ((((off)) & ((1U << PTE_FILE_BITS1) - 1)) << PTE_FILE_SHIFT1)	\
> +	 + ((((off) >> PTE_FILE_BITS1)					\
> +	     & ((1U << PTE_FILE_BITS2) - 1))				\
> +	    << PTE_FILE_SHIFT2)						\
> +	 + ((((off) >> (PTE_FILE_BITS1 + PTE_FILE_BITS2))		\
> +	     & ((1U << PTE_FILE_BITS3) - 1))				\
> +	    << PTE_FILE_SHIFT3)						\
> +	 + ((((off) >>							\
> +	      (PTE_FILE_BITS1 + PTE_FILE_BITS2 + PTE_FILE_BITS3)))	\
> +	    << PTE_FILE_SHIFT4)						\
> +	 + _PAGE_FILE })

Good god.

I wonder if these can be turned into out-of-line functions in some form
which humans can understand.

or

#define pte_to_pgoff(pte)
	frob(pte, PTE_FILE_SHIFT1, PTE_FILE_BITS1) +
	frob(PTE_FILE_SHIFT2, PTE_FILE_BITS2) +
	frob(PTE_FILE_SHIFT3, PTE_FILE_BITS3) +
	frob(PTE_FILE_SHIFT4, PTE_FILE_BITS1 + PTE_FILE_BITS2 + PTE_FILE_BITS3)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
