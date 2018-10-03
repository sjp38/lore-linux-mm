Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 955286B000A
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 15:56:51 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id f20-v6so6140858qta.16
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 12:56:51 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f2-v6si627327qtd.77.2018.10.03.12.56.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Oct 2018 12:56:50 -0700 (PDT)
Date: Wed, 3 Oct 2018 21:57:06 +0200
From: Eugene Syromiatnikov <esyr@redhat.com>
Subject: Re: [RFC PATCH v4 3/9] x86/cet/ibt: Add IBT legacy code bitmap
 allocation function
Message-ID: <20181003195702.GF32759@asgard.redhat.com>
References: <20180921150553.21016-1-yu-cheng.yu@intel.com>
 <20180921150553.21016-4-yu-cheng.yu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180921150553.21016-4-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Fri, Sep 21, 2018 at 08:05:47AM -0700, Yu-cheng Yu wrote:
> Indirect branch tracking provides an optional legacy code bitmap
> that indicates locations of non-IBT compatible code.  When set,
> each bit in the bitmap represents a page in the linear address is
> legacy code.
> 
> We allocate the bitmap only when the application requests it.
> Most applications do not need the bitmap.
> 
> Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> ---
>  arch/x86/kernel/cet.c | 45 +++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 45 insertions(+)
> 
> diff --git a/arch/x86/kernel/cet.c b/arch/x86/kernel/cet.c
> index 6adfe795d692..a65d9745af08 100644
> --- a/arch/x86/kernel/cet.c
> +++ b/arch/x86/kernel/cet.c
> @@ -314,3 +314,48 @@ void cet_disable_ibt(void)
>  	wrmsrl(MSR_IA32_U_CET, r);
>  	current->thread.cet.ibt_enabled = 0;
>  }
> +
> +int cet_setup_ibt_bitmap(void)
> +{
> +	u64 r;
> +	unsigned long bitmap;
> +	unsigned long size;
> +
> +	if (!cpu_feature_enabled(X86_FEATURE_IBT))
> +		return -EOPNOTSUPP;
> +
> +	if (!current->thread.cet.ibt_bitmap_addr) {
> +		/*
> +		 * Calculate size and put in thread header.
> +		 * may_expand_vm() needs this information.
> +		 */
> +		size = TASK_SIZE / PAGE_SIZE / BITS_PER_BYTE;

TASK_SIZE_MAX is likely needed here, as an application can easily switch
between long an 32-bit protected mode.  And then the case of a CPU that
doesn't support 5LPT.

> +		current->thread.cet.ibt_bitmap_size = size;
> +		bitmap = do_mmap_locked(0, size, PROT_READ | PROT_WRITE,
> +					MAP_ANONYMOUS | MAP_PRIVATE,
> +					VM_DONTDUMP);
> +
> +		if (bitmap >= TASK_SIZE) {

Shouldn't bitmap be unmapped here?

> +			current->thread.cet.ibt_bitmap_size = 0;
> +			return -ENOMEM;
> +		}
> +
> +		current->thread.cet.ibt_bitmap_addr = bitmap;
> +	}
> +
> +	/*
> +	 * Lower bits of MSR_IA32_CET_LEG_IW_EN are for IBT
> +	 * settings.  Clear lower bits even bitmap is already
> +	 * page-aligned.
> +	 */
> +	bitmap = current->thread.cet.ibt_bitmap_addr;
> +	bitmap &= PAGE_MASK;

In a hypothetical situation of bitmap & PAGE_MASK < bitmap that would lead
to bitmap pointing to unmapped memory. A check that bitmap is sane would
probably be better.

> +
> +	/*
> +	 * Turn on IBT legacy bitmap.
> +	 */
> +	rdmsrl(MSR_IA32_U_CET, r);
> +	r |= (MSR_IA32_CET_LEG_IW_EN | bitmap);
> +	wrmsrl(MSR_IA32_U_CET, r);
> +	return 0;
> +}
> -- 
> 2.17.1
> 
