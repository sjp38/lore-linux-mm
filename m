Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4C4806B025F
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 04:27:10 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 83so22313459pgb.1
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 01:27:10 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id v6si9389630pfi.382.2017.08.28.01.27.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 28 Aug 2017 01:27:09 -0700 (PDT)
Date: Mon, 28 Aug 2017 18:27:05 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: mmotm 2017-08-25-15-50 uploaded
Message-ID: <20170828182705.150afe66@canb.auug.org.au>
In-Reply-To: <20170828075931.GC17097@dhcp22.suse.cz>
References: <59a0a9d1.jzOblYrHfdIDuDZw%akpm@linux-foundation.org>
	<3c9df006-0cc5-3a32-b715-1fbb43cb9ea8@infradead.org>
	<20170828075931.GC17097@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Randy Dunlap <rdunlap@infradead.org>, akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, broonie@kernel.org, =?UTF-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>

Hi Michal,

On Mon, 28 Aug 2017 09:59:31 +0200 Michal Hocko <mhocko@kernel.org> wrote:
>
> From 31d551dbcb1b7987a4cd07767c1e2805849b7a26 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Mon, 28 Aug 2017 09:41:39 +0200
> Subject: [PATCH] 
>  mm-hmm-struct-hmm-is-only-use-by-hmm-mirror-functionality-v2-fix
> 
> Compiler is complaining for allnoconfig
> 
> kernel/fork.c: In function 'mm_init':
> kernel/fork.c:814:2: error: implicit declaration of function 'hmm_mm_init' [-Werror=implicit-function-declaration]
>   hmm_mm_init(mm);
>   ^
> kernel/fork.c: In function '__mmdrop':
> kernel/fork.c:893:2: error: implicit declaration of function 'hmm_mm_destroy' [-Werror=implicit-function-declaration]
>   hmm_mm_destroy(mm);
> 
> Make sure that hmm_mm_init/hmm_mm_destroy empty stups are defined when
> CONFIG_HMM is disabled.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  include/linux/hmm.h | 7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 9583d9a15f9c..aeb94e682dda 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -508,11 +508,10 @@ static inline void hmm_mm_init(struct mm_struct *mm)
>  {
>  	mm->hmm = NULL;
>  }
> -#else /* IS_ENABLED(CONFIG_HMM_MIRROR) */
> +#endif
> +
> +#else /* IS_ENABLED(CONFIG_HMM) */
>  static inline void hmm_mm_destroy(struct mm_struct *mm) {}
>  static inline void hmm_mm_init(struct mm_struct *mm) {}
> -#endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
> -
> -
>  #endif /* IS_ENABLED(CONFIG_HMM) */
>  #endif /* LINUX_HMM_H */

What happens when CONFIG_HMM is defined but CONFIG_HMM_MIRROR is not?
Or is that not possible (in which case why would we have
CONFIG_HMM_MIRROR)? 
-- 
Cheers,
Stephen Rothwell

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
