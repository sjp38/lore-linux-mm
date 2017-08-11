Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 12F006B0292
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 08:53:31 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id g28so4904631wrg.3
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 05:53:31 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s45si624537wrc.511.2017.08.11.05.53.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 11 Aug 2017 05:53:29 -0700 (PDT)
Date: Fri, 11 Aug 2017 14:53:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v6 09/15] sparc64: optimized struct page zeroing
Message-ID: <20170811125326.GK30811@dhcp22.suse.cz>
References: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
 <1502138329-123460-10-git-send-email-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1502138329-123460-10-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org

On Mon 07-08-17 16:38:43, Pavel Tatashin wrote:
> Add an optimized mm_zero_struct_page(), so struct page's are zeroed without
> calling memset(). We do eight to tent regular stores based on the size of
> struct page. Compiler optimizes out the conditions of switch() statement.

Again, this doesn't explain why we need this. You have mentioned those
reasons in some previous emails but be explicit here please.

> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> Reviewed-by: Steven Sistare <steven.sistare@oracle.com>
> Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
> Reviewed-by: Bob Picco <bob.picco@oracle.com>
> ---
>  arch/sparc/include/asm/pgtable_64.h | 30 ++++++++++++++++++++++++++++++
>  1 file changed, 30 insertions(+)
> 
> diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
> index 6fbd931f0570..cee5cc7ccc51 100644
> --- a/arch/sparc/include/asm/pgtable_64.h
> +++ b/arch/sparc/include/asm/pgtable_64.h
> @@ -230,6 +230,36 @@ extern unsigned long _PAGE_ALL_SZ_BITS;
>  extern struct page *mem_map_zero;
>  #define ZERO_PAGE(vaddr)	(mem_map_zero)
>  
> +/* This macro must be updated when the size of struct page grows above 80
> + * or reduces below 64.
> + * The idea that compiler optimizes out switch() statement, and only
> + * leaves clrx instructions
> + */
> +#define	mm_zero_struct_page(pp) do {					\
> +	unsigned long *_pp = (void *)(pp);				\
> +									\
> +	 /* Check that struct page is either 64, 72, or 80 bytes */	\
> +	BUILD_BUG_ON(sizeof(struct page) & 7);				\
> +	BUILD_BUG_ON(sizeof(struct page) < 64);				\
> +	BUILD_BUG_ON(sizeof(struct page) > 80);				\
> +									\
> +	switch (sizeof(struct page)) {					\
> +	case 80:							\
> +		_pp[9] = 0;	/* fallthrough */			\
> +	case 72:							\
> +		_pp[8] = 0;	/* fallthrough */			\
> +	default:							\
> +		_pp[7] = 0;						\
> +		_pp[6] = 0;						\
> +		_pp[5] = 0;						\
> +		_pp[4] = 0;						\
> +		_pp[3] = 0;						\
> +		_pp[2] = 0;						\
> +		_pp[1] = 0;						\
> +		_pp[0] = 0;						\
> +	}								\
> +} while (0)
> +
>  /* PFNs are real physical page numbers.  However, mem_map only begins to record
>   * per-page information starting at pfn_base.  This is to handle systems where
>   * the first physical page in the machine is at some huge physical address,
> -- 
> 2.14.0

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
