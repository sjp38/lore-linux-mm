Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7AC43C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 15:04:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 25D38205C9
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 15:04:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="Unq9Tc/t"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 25D38205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C74618E0006; Mon, 24 Jun 2019 11:04:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C24ED8E0002; Mon, 24 Jun 2019 11:04:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AECBD8E0006; Mon, 24 Jun 2019 11:04:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 77F618E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 11:04:14 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id q14so8061924pff.8
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 08:04:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=4fUtk2X/B8EA5bC3OoTiCOMWUPKtO10Ph33S+4u9cmM=;
        b=chtClj4KnBfF9HLxLe3nhEG6Ww2tDNd3/oBdYfEa341ixBMyDuoN/XfCImM4sys+wq
         Tj1ywaPSc3Bifofp3jNoXDFdNWykUSgTiq8ELe6KNJsxXllnw2bMUk6pJXAMyZHjsFUM
         0TULU+xGYCp0fVxEAouivDW0HxRxKkOx09b6QfAbnealArFx3IIUEHMZfbBlq82+gYDS
         S28jKV3G/73igoB+dXzd7IeuDPDUR8z3D9SfZJyKgSDNaMwYVwqu2TMSESnmAR28jmqD
         7//FcUHvwb6y2qSKShiRUu7bJrD21/+b27FGD7uRW/id77KEWHdyJtifKaX9Z7Q0NBwO
         893g==
X-Gm-Message-State: APjAAAVspspelhzbtzrsorBuCsV1WnuucP4eOMYSuSRXxTPxD7aPzNug
	ksFy2/ySeiH8hupYkP95BkkMzriUNZz/mM5T1pn/+XTavMKCKVLRws3F2d/SgdKlNYdx57+hszV
	vCPbfk2P/vPQyBTOJIqW0jJA02Fi0bXFnFA04w2VKUrabzew/TMhFsJ2/NSBcSfoNLQ==
X-Received: by 2002:a17:902:29a7:: with SMTP id h36mr98379844plb.158.1561388654124;
        Mon, 24 Jun 2019 08:04:14 -0700 (PDT)
X-Received: by 2002:a17:902:29a7:: with SMTP id h36mr98379746plb.158.1561388653147;
        Mon, 24 Jun 2019 08:04:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561388653; cv=none;
        d=google.com; s=arc-20160816;
        b=qi5/BhXm48+25byYye+bs1F0l0dpIrnIFflf03mNDzlRtJIhMFOvGwxL9fTfbmlRv1
         cI604vQPEjLB3K8kUTojF4kO6LRx+socc0vku0OpykXSmfY9N9ugpC4DA2E8AliZg97u
         KdiZmAas5P6Kg79gylhYqS++dppvEllnTqo6++PiHTv1WaevYGcD3sP4qciI2ZoRjqe3
         DiDR425kkZMJkoHY7SVlghl5AqMDDfPL3+vDPzoaeElyIm65q3azoHxx4NEBJ7neKVHm
         qLF8Bu/KH+hfWCqfz2AsAkVX9EvjilOfhzBXis7jtawT5cLc0Gc9a6UMtPTOVV3t80d5
         /q1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=4fUtk2X/B8EA5bC3OoTiCOMWUPKtO10Ph33S+4u9cmM=;
        b=bv3bjfKAioFbGkfjggCD7dCzYfSdCimnBvBtFzRQAx2VIw5tx634MV47mngfK7g6um
         Va225H0Dl9goe49uGJxBp2i7Zz1kXhn9b0usQKZTRko3xkPdtkijAPJ/0KCAn/U7Bcl0
         ZRA1XU68zvQpeQWqLCcR28iGsiLdRGXPzqKCQs4sPxhKniw7kyL1yACX00MB09o7M35i
         hho3h1reVzVSt73QoJIefMMxZxs2OS6+e9rKSFz4+qnymFxemrip77qn+bII+tOQuLUE
         1zQRPvjb2xsQk76LptIlxFCHmdw4eF9faPkwPOloi0CyL50TW5buc0TA0iUVTkaZTHsR
         7GQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b="Unq9Tc/t";
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y131sor7264625pfb.27.2019.06.24.08.04.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 08:04:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b="Unq9Tc/t";
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=4fUtk2X/B8EA5bC3OoTiCOMWUPKtO10Ph33S+4u9cmM=;
        b=Unq9Tc/tyYLcrlDiUHjqb3TVsHvcrSGxzFku5zQQaJFanNh7cZPh8q46hVjZps1z81
         uDB0Xtq6gfRGjJJixib0RhA2G8JO+YeJ0PEaotZK6musiMYDSPvWh+qB6jxY0/COcLnq
         l3/ss6tf0ZUQLieVDIxu7IvLQn6FFv2JGvXLY=
X-Google-Smtp-Source: APXvYqwuadhAXWHIlg6sacPEdNNPqhO7/afynu04PvpO/WXneR7cKybll9iRuNlplQEsgibh+dZilg==
X-Received: by 2002:a63:d415:: with SMTP id a21mr32379347pgh.229.1561388652708;
        Mon, 24 Jun 2019 08:04:12 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id r4sm10229549pjd.28.2019.06.24.08.04.11
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 24 Jun 2019 08:04:11 -0700 (PDT)
Date: Mon, 24 Jun 2019 08:04:10 -0700
From: Kees Cook <keescook@chromium.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	Catalin Marinas <catalin.marinas@arm.com>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Leon Romanovsky <leon@kernel.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Christoph Hellwig <hch@infradead.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v18 02/15] arm64: Introduce prctl() options to control
 the tagged user addresses ABI
Message-ID: <201906240804.899CE7BE3@keescook>
References: <cover.1561386715.git.andreyknvl@google.com>
 <653598b3cfcd80f0cc69f72a214e156bb1afde68.1561386715.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <653598b3cfcd80f0cc69f72a214e156bb1afde68.1561386715.git.andreyknvl@google.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 04:32:47PM +0200, Andrey Konovalov wrote:
> From: Catalin Marinas <catalin.marinas@arm.com>
> 
> It is not desirable to relax the ABI to allow tagged user addresses into
> the kernel indiscriminately. This patch introduces a prctl() interface
> for enabling or disabling the tagged ABI with a global sysctl control
> for preventing applications from enabling the relaxed ABI (meant for
> testing user-space prctl() return error checking without reconfiguring
> the kernel). The ABI properties are inherited by threads of the same
> application and fork()'ed children but cleared on execve(). A Kconfig
> option allows the overall disabling of the relaxed ABI.
> 
> The PR_SET_TAGGED_ADDR_CTRL will be expanded in the future to handle
> MTE-specific settings like imprecise vs precise exceptions.
> 
> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>

Reviewed-by: Kees Cook <keescook@chromium.org>

-Kees

> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  arch/arm64/Kconfig                   |  9 ++++
>  arch/arm64/include/asm/processor.h   |  8 ++++
>  arch/arm64/include/asm/thread_info.h |  1 +
>  arch/arm64/include/asm/uaccess.h     |  4 +-
>  arch/arm64/kernel/process.c          | 72 ++++++++++++++++++++++++++++
>  include/uapi/linux/prctl.h           |  5 ++
>  kernel/sys.c                         | 12 +++++
>  7 files changed, 110 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index 697ea0510729..55fbaf20af2d 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -1107,6 +1107,15 @@ config ARM64_SW_TTBR0_PAN
>  	  zeroed area and reserved ASID. The user access routines
>  	  restore the valid TTBR0_EL1 temporarily.
>  
> +config ARM64_TAGGED_ADDR_ABI
> +	bool "Enable the tagged user addresses syscall ABI"
> +	default y
> +	help
> +	  When this option is enabled, user applications can opt in to a
> +	  relaxed ABI via prctl() allowing tagged addresses to be passed
> +	  to system calls as pointer arguments. For details, see
> +	  Documentation/arm64/tagged-address-abi.txt.
> +
>  menuconfig COMPAT
>  	bool "Kernel support for 32-bit EL0"
>  	depends on ARM64_4K_PAGES || EXPERT
> diff --git a/arch/arm64/include/asm/processor.h b/arch/arm64/include/asm/processor.h
> index fd5b1a4efc70..ee86070a28d4 100644
> --- a/arch/arm64/include/asm/processor.h
> +++ b/arch/arm64/include/asm/processor.h
> @@ -296,6 +296,14 @@ extern void __init minsigstksz_setup(void);
>  /* PR_PAC_RESET_KEYS prctl */
>  #define PAC_RESET_KEYS(tsk, arg)	ptrauth_prctl_reset_keys(tsk, arg)
>  
> +#ifdef CONFIG_ARM64_TAGGED_ADDR_ABI
> +/* PR_{SET,GET}_TAGGED_ADDR_CTRL prctl */
> +long set_tagged_addr_ctrl(unsigned long arg);
> +long get_tagged_addr_ctrl(void);
> +#define SET_TAGGED_ADDR_CTRL(arg)	set_tagged_addr_ctrl(arg)
> +#define GET_TAGGED_ADDR_CTRL()		get_tagged_addr_ctrl()
> +#endif
> +
>  /*
>   * For CONFIG_GCC_PLUGIN_STACKLEAK
>   *
> diff --git a/arch/arm64/include/asm/thread_info.h b/arch/arm64/include/asm/thread_info.h
> index 2372e97db29c..4f81c4f15404 100644
> --- a/arch/arm64/include/asm/thread_info.h
> +++ b/arch/arm64/include/asm/thread_info.h
> @@ -88,6 +88,7 @@ void arch_release_task_struct(struct task_struct *tsk);
>  #define TIF_SVE			23	/* Scalable Vector Extension in use */
>  #define TIF_SVE_VL_INHERIT	24	/* Inherit sve_vl_onexec across exec */
>  #define TIF_SSBD		25	/* Wants SSB mitigation */
> +#define TIF_TAGGED_ADDR		26	/* Allow tagged user addresses */
>  
>  #define _TIF_SIGPENDING		(1 << TIF_SIGPENDING)
>  #define _TIF_NEED_RESCHED	(1 << TIF_NEED_RESCHED)
> diff --git a/arch/arm64/include/asm/uaccess.h b/arch/arm64/include/asm/uaccess.h
> index a138e3b4f717..097d6bfac0b7 100644
> --- a/arch/arm64/include/asm/uaccess.h
> +++ b/arch/arm64/include/asm/uaccess.h
> @@ -62,7 +62,9 @@ static inline unsigned long __range_ok(const void __user *addr, unsigned long si
>  {
>  	unsigned long ret, limit = current_thread_info()->addr_limit;
>  
> -	addr = untagged_addr(addr);
> +	if (IS_ENABLED(CONFIG_ARM64_TAGGED_ADDR_ABI) &&
> +	    test_thread_flag(TIF_TAGGED_ADDR))
> +		addr = untagged_addr(addr);
>  
>  	__chk_user_ptr(addr);
>  	asm volatile(
> diff --git a/arch/arm64/kernel/process.c b/arch/arm64/kernel/process.c
> index 9856395ccdb7..60e70158a4a1 100644
> --- a/arch/arm64/kernel/process.c
> +++ b/arch/arm64/kernel/process.c
> @@ -19,6 +19,7 @@
>  #include <linux/kernel.h>
>  #include <linux/mm.h>
>  #include <linux/stddef.h>
> +#include <linux/sysctl.h>
>  #include <linux/unistd.h>
>  #include <linux/user.h>
>  #include <linux/delay.h>
> @@ -307,11 +308,18 @@ static void tls_thread_flush(void)
>  	}
>  }
>  
> +static void flush_tagged_addr_state(void)
> +{
> +	if (IS_ENABLED(CONFIG_ARM64_TAGGED_ADDR_ABI))
> +		clear_thread_flag(TIF_TAGGED_ADDR);
> +}
> +
>  void flush_thread(void)
>  {
>  	fpsimd_flush_thread();
>  	tls_thread_flush();
>  	flush_ptrace_hw_breakpoint(current);
> +	flush_tagged_addr_state();
>  }
>  
>  void release_thread(struct task_struct *dead_task)
> @@ -541,3 +549,67 @@ void arch_setup_new_exec(void)
>  
>  	ptrauth_thread_init_user(current);
>  }
> +
> +#ifdef CONFIG_ARM64_TAGGED_ADDR_ABI
> +/*
> + * Control the relaxed ABI allowing tagged user addresses into the kernel.
> + */
> +static unsigned int tagged_addr_prctl_allowed = 1;
> +
> +long set_tagged_addr_ctrl(unsigned long arg)
> +{
> +	if (!tagged_addr_prctl_allowed)
> +		return -EINVAL;
> +	if (is_compat_task())
> +		return -EINVAL;
> +	if (arg & ~PR_TAGGED_ADDR_ENABLE)
> +		return -EINVAL;
> +
> +	update_thread_flag(TIF_TAGGED_ADDR, arg & PR_TAGGED_ADDR_ENABLE);
> +
> +	return 0;
> +}
> +
> +long get_tagged_addr_ctrl(void)
> +{
> +	if (!tagged_addr_prctl_allowed)
> +		return -EINVAL;
> +	if (is_compat_task())
> +		return -EINVAL;
> +
> +	if (test_thread_flag(TIF_TAGGED_ADDR))
> +		return PR_TAGGED_ADDR_ENABLE;
> +
> +	return 0;
> +}
> +
> +/*
> + * Global sysctl to disable the tagged user addresses support. This control
> + * only prevents the tagged address ABI enabling via prctl() and does not
> + * disable it for tasks that already opted in to the relaxed ABI.
> + */
> +static int zero;
> +static int one = 1;
> +
> +static struct ctl_table tagged_addr_sysctl_table[] = {
> +	{
> +		.procname	= "tagged_addr",
> +		.mode		= 0644,
> +		.data		= &tagged_addr_prctl_allowed,
> +		.maxlen		= sizeof(int),
> +		.proc_handler	= proc_dointvec_minmax,
> +		.extra1		= &zero,
> +		.extra2		= &one,
> +	},
> +	{ }
> +};
> +
> +static int __init tagged_addr_init(void)
> +{
> +	if (!register_sysctl("abi", tagged_addr_sysctl_table))
> +		return -EINVAL;
> +	return 0;
> +}
> +
> +core_initcall(tagged_addr_init);
> +#endif	/* CONFIG_ARM64_TAGGED_ADDR_ABI */
> diff --git a/include/uapi/linux/prctl.h b/include/uapi/linux/prctl.h
> index 094bb03b9cc2..2e927b3e9d6c 100644
> --- a/include/uapi/linux/prctl.h
> +++ b/include/uapi/linux/prctl.h
> @@ -229,4 +229,9 @@ struct prctl_mm_map {
>  # define PR_PAC_APDBKEY			(1UL << 3)
>  # define PR_PAC_APGAKEY			(1UL << 4)
>  
> +/* Tagged user address controls for arm64 */
> +#define PR_SET_TAGGED_ADDR_CTRL		55
> +#define PR_GET_TAGGED_ADDR_CTRL		56
> +# define PR_TAGGED_ADDR_ENABLE		(1UL << 0)
> +
>  #endif /* _LINUX_PRCTL_H */
> diff --git a/kernel/sys.c b/kernel/sys.c
> index 2969304c29fe..c6c4d5358bd3 100644
> --- a/kernel/sys.c
> +++ b/kernel/sys.c
> @@ -124,6 +124,12 @@
>  #ifndef PAC_RESET_KEYS
>  # define PAC_RESET_KEYS(a, b)	(-EINVAL)
>  #endif
> +#ifndef SET_TAGGED_ADDR_CTRL
> +# define SET_TAGGED_ADDR_CTRL(a)	(-EINVAL)
> +#endif
> +#ifndef GET_TAGGED_ADDR_CTRL
> +# define GET_TAGGED_ADDR_CTRL()		(-EINVAL)
> +#endif
>  
>  /*
>   * this is where the system-wide overflow UID and GID are defined, for
> @@ -2492,6 +2498,12 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
>  			return -EINVAL;
>  		error = PAC_RESET_KEYS(me, arg2);
>  		break;
> +	case PR_SET_TAGGED_ADDR_CTRL:
> +		error = SET_TAGGED_ADDR_CTRL(arg2);
> +		break;
> +	case PR_GET_TAGGED_ADDR_CTRL:
> +		error = GET_TAGGED_ADDR_CTRL();
> +		break;
>  	default:
>  		error = -EINVAL;
>  		break;
> -- 
> 2.22.0.410.gd8fdbe21b5-goog
> 

-- 
Kees Cook

