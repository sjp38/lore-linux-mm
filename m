Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id DA5616B0373
	for <linux-mm@kvack.org>; Mon, 29 Oct 2018 07:45:24 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id l7-v6so9496976qkd.5
        for <linux-mm@kvack.org>; Mon, 29 Oct 2018 04:45:24 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o45-v6si1762762qto.166.2018.10.29.04.45.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Oct 2018 04:45:23 -0700 (PDT)
Reply-To: crecklin@redhat.com
Subject: Re: [PATCH 09/17] prmem: hardened usercopy
References: <20181023213504.28905-1-igor.stoppa@huawei.com>
 <20181023213504.28905-10-igor.stoppa@huawei.com>
From: Chris von Recklinghausen <crecklin@redhat.com>
Message-ID: <cd768a99-5afa-999c-989a-efee66fa0ddb@redhat.com>
Date: Mon, 29 Oct 2018 07:45:14 -0400
MIME-Version: 1.0
In-Reply-To: <20181023213504.28905-10-igor.stoppa@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@gmail.com>, Mimi Zohar <zohar@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, James Morris <jmorris@namei.org>, Michal Hocko <mhocko@kernel.org>, kernel-hardening@lists.openwall.com, linux-integrity@vger.kernel.org, linux-security-module@vger.kernel.org
Cc: igor.stoppa@huawei.com, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Laura Abbott <labbott@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 10/23/2018 05:34 PM, Igor Stoppa wrote:
> Prevent leaks of protected memory to userspace.
> The protection from overwrited from userspace is already available, once
> the memory is write protected.
>
> Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
> CC: Kees Cook <keescook@chromium.org>
> CC: Chris von Recklinghausen <crecklin@redhat.com>
> CC: linux-mm@kvack.org
> CC: linux-kernel@vger.kernel.org
> ---
>  include/linux/prmem.h | 24 ++++++++++++++++++++++++
>  mm/usercopy.c         |  5 +++++
>  2 files changed, 29 insertions(+)
>
> diff --git a/include/linux/prmem.h b/include/linux/prmem.h
> index cf713fc1c8bb..919d853ddc15 100644
> --- a/include/linux/prmem.h
> +++ b/include/linux/prmem.h
> @@ -273,6 +273,30 @@ struct pmalloc_pool {
>  	uint8_t mode;
>  };
>  
> +void __noreturn usercopy_abort(const char *name, const char *detail,
> +			       bool to_user, unsigned long offset,
> +			       unsigned long len);
> +
> +/**
> + * check_pmalloc_object() - helper for hardened usercopy
> + * @ptr: the beginning of the memory to check
> + * @n: the size of the memory to check
> + * @to_user: copy to userspace or from userspace
> + *
> + * If the check is ok, it will fall-through, otherwise it will abort.
> + * The function is inlined, to minimize the performance impact of the
> + * extra check that can end up on a hot path.
> + * Non-exhaustive micro benchmarking with QEMU x86_64 shows a reduction of
> + * the time spent in this fragment by 60%, when inlined.
> + */
> +static inline
> +void check_pmalloc_object(const void *ptr, unsigned long n, bool to_user)
> +{
> +	if (unlikely(__is_wr_after_init(ptr, n) || __is_wr_pool(ptr, n)))
> +		usercopy_abort("pmalloc", "accessing pmalloc obj", to_user,
> +			       (const unsigned long)ptr, n);
> +}
> +
>  /*
>   * The write rare functionality is fully implemented as __always_inline,
>   * to prevent having an internal function call that is capable of modifying
> diff --git a/mm/usercopy.c b/mm/usercopy.c
> index 852eb4e53f06..a080dd37b684 100644
> --- a/mm/usercopy.c
> +++ b/mm/usercopy.c
> @@ -22,8 +22,10 @@
>  #include <linux/thread_info.h>
>  #include <linux/atomic.h>
>  #include <linux/jump_label.h>
> +#include <linux/prmem.h>
>  #include <asm/sections.h>
>  
> +
>  /*
>   * Checks if a given pointer and length is contained by the current
>   * stack frame (if possible).
> @@ -284,6 +286,9 @@ void __check_object_size(const void *ptr, unsigned long n, bool to_user)
>  
>  	/* Check for object in kernel to avoid text exposure. */
>  	check_kernel_text_object((const unsigned long)ptr, n, to_user);
> +
> +	/* Check if object is from a pmalloc chunk. */
> +	check_pmalloc_object(ptr, n, to_user);
>  }
>  EXPORT_SYMBOL(__check_object_size);
>  

Could you add code somewhere (lkdtm driver if possible) to demonstrate
the issue and verify the code change?

Thanks,

Chris
