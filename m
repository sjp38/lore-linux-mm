Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 289D56B0006
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 11:51:25 -0400 (EDT)
Received: by mail-yb0-f198.google.com with SMTP id h190-v6so10016639yba.5
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 08:51:25 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 30si3695646qtw.445.2018.04.04.08.51.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 08:51:24 -0700 (PDT)
Date: Wed, 4 Apr 2018 11:51:20 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH] mm/hmm: fix header file if/else/endif maze, again
Message-ID: <20180404155120.GA3331@redhat.com>
References: <20180404110236.804484-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180404110236.804484-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, John Hubbard <jhubbard@nvidia.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Apr 04, 2018 at 01:02:15PM +0200, Arnd Bergmann wrote:
> The last fix was still wrong, as we need the inline dummy functions
> also for the case that CONFIG_HMM is enabled but CONFIG_HMM_MIRROR
> is not:
> 
> kernel/fork.o: In function `__mmdrop':
> fork.c:(.text+0x14f6): undefined reference to `hmm_mm_destroy'
> 
> This adds back the second copy of the dummy functions, hopefully
> this time in the right place.
> 
> Fixes: 8900d06a277a ("mm/hmm: fix header file if/else/endif maze")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Reviewed-by: Jerome Glisse <jglisse@redhat.com>

Hopefuly this is the last config combinatorial issue...

> ---
>  include/linux/hmm.h | 21 ++++++++++++---------
>  1 file changed, 12 insertions(+), 9 deletions(-)
> 
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 5d26e0a223d9..39988924de3a 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -376,8 +376,18 @@ bool hmm_vma_range_done(struct hmm_range *range);
>   * See the function description in mm/hmm.c for further documentation.
>   */
>  int hmm_vma_fault(struct hmm_range *range, bool block);
> -#endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
>  
> +/* Below are for HMM internal use only! Not to be used by device driver! */
> +void hmm_mm_destroy(struct mm_struct *mm);
> +
> +static inline void hmm_mm_init(struct mm_struct *mm)
> +{
> +	mm->hmm = NULL;
> +}
> +#else /* IS_ENABLED(CONFIG_HMM_MIRROR) */
> +static inline void hmm_mm_destroy(struct mm_struct *mm) {}
> +static inline void hmm_mm_init(struct mm_struct *mm) {}
> +#endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
>  
>  #if IS_ENABLED(CONFIG_DEVICE_PRIVATE) ||  IS_ENABLED(CONFIG_DEVICE_PUBLIC)
>  struct hmm_devmem;
> @@ -550,16 +560,9 @@ struct hmm_device {
>  struct hmm_device *hmm_device_new(void *drvdata);
>  void hmm_device_put(struct hmm_device *hmm_device);
>  #endif /* CONFIG_DEVICE_PRIVATE || CONFIG_DEVICE_PUBLIC */
> -
> -/* Below are for HMM internal use only! Not to be used by device driver! */
> -void hmm_mm_destroy(struct mm_struct *mm);
> -
> -static inline void hmm_mm_init(struct mm_struct *mm)
> -{
> -	mm->hmm = NULL;
> -}
>  #else /* IS_ENABLED(CONFIG_HMM) */
>  static inline void hmm_mm_destroy(struct mm_struct *mm) {}
>  static inline void hmm_mm_init(struct mm_struct *mm) {}
>  #endif /* IS_ENABLED(CONFIG_HMM) */
> +
>  #endif /* LINUX_HMM_H */
> -- 
> 2.9.0
> 
