Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 834D1C0650E
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 17:10:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D55A21734
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 17:10:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="RKRjOQ/C"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D55A21734
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A03B46B000A; Tue, 11 Jun 2019 13:10:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 98EE36B000C; Tue, 11 Jun 2019 13:10:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 82F706B000D; Tue, 11 Jun 2019 13:10:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 48AE56B000A
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 13:10:00 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 5so10027026pff.11
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 10:10:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=4tN45q0D9pHywLWcDSI0MGipDR9BHLbNW3AKgfWrPoY=;
        b=rxvYN8cbMS8UwWLNuBRoewyKg6t4l8XIi7iJifhBJa/SN8AB9OOyJs2jeqd1Eyv6FR
         8pRc94HOtDSkc2NtsNemVK7TeEs72pRJWAe+weiw2fRiBhUkGEZcEB6kr7utMiQXsr5I
         tyRucF9CNjwlycsMw3RPXCxo8sPH7lwv4I9t8MXtFRM2mGRWu5Z9+vgBdTBQ+HsidZ4v
         6c52mphAjZkYNM1MvTpwqnHgJWpMF8m4jgj7e1gw2MHd0BKmEX1QC8nw5V9DNHUgvJn+
         R8UhKcP/YTZ+2a6PMP+90CtjfQ3iNQCzcO/3Ac90thXul8+JupROgMWT28NfLQ6b7VX0
         PVEg==
X-Gm-Message-State: APjAAAVvyYbA0o6wFuz1ha6EYYZPMUINjeFNm8uRieDLJA5NM/VDihDK
	xKsENcdLACE+nDXG26Q24r8gC/BpTz1cdHU/ii28ULXur2gNlelTasbFTiwZ/BKLbWKdrJmCejn
	tDXI2o5+aHdEeK8Qiu88vTcLVrA9ZaLqqyJdLyG/iikeAiFTW/aOIBzLb/qj5rC01qQ==
X-Received: by 2002:a17:902:29a7:: with SMTP id h36mr24956049plb.158.1560272999713;
        Tue, 11 Jun 2019 10:09:59 -0700 (PDT)
X-Received: by 2002:a17:902:29a7:: with SMTP id h36mr24955983plb.158.1560272998714;
        Tue, 11 Jun 2019 10:09:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560272998; cv=none;
        d=google.com; s=arc-20160816;
        b=RJfnOGtOYHPGgVHUgM+ftIpAx2dMFxIsDVQjR/kTDNxQIhYqcyC+jgBvlzw+9f+L9i
         btvVSFNbfCP03mIyLmra7Ur17q4zLg0L+pclt9vwD0V+fBfYoD0WvBULd6msEwTs3Hjq
         XvPfN/+7SP+mrpvoSderiTgVqtmuLLh8ctehG9QjyN9nKGl2TxhzEiIyCdqpYV/LANR4
         P0tGq5KllxaEY+UjsV2RK+T2dteeoDpGjjktHLmD4zfXZlo8TtMBzVHfgDYX9DusTGjj
         TIxs72as+28FeJM4r6t3odKGzYiK0IGQU6vYIZeUv3cFVKS7OT+nhw2obEVNtyjfw7s3
         dPDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=4tN45q0D9pHywLWcDSI0MGipDR9BHLbNW3AKgfWrPoY=;
        b=yqNE5/JXSpQzSt+0/GD1jFUQ1vRQIXTMZQy73fqnpOAlj87+ygTFhhy+i4RCxMvgxB
         JoIy5fsfe0j5reGaRgexb4lm9dtYhl1WEcJbxwD+ZPTaMRtfXHW/TDJsybHproBAyI1Q
         sRoTy4cv0Np0uW5LY8b3BqRJQSzCKdf5BMjCGSxN0e5n65IvCQfTXXxW4ZSODCk4tb5J
         kXJ3Z3MZMFFbycOgcn3CgSTGg5QBR4QH8qSJH0gjfpVBBm7/FWkomCDuS2z1KAPKU8aW
         +1NTZOKZS09O69r3kcJVkEJdZ3/2+3109BMG+DPn4LUM4I27JdB7JwYnsaE0G0CbvryI
         zPeg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="RKRjOQ/C";
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b8sor3650979pjo.18.2019.06.11.10.09.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Jun 2019 10:09:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="RKRjOQ/C";
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=4tN45q0D9pHywLWcDSI0MGipDR9BHLbNW3AKgfWrPoY=;
        b=RKRjOQ/CcWw8O0pNRp5OfIZbx3+kMO5Xos7WsX4RmawieoUisEZltkTlmO51etoV48
         IKQaXtgrrrpEX7AXiIp879yyFgZd7pb7jIil+r9xZmqJGjAnG6Bb//EZXFWhJHvT4gsi
         3h4TFpp7Q+OTbLfc69buJi7XbrHFI0uxOrBYItoZ06uu2zgpfg1jM9bCrvRMKW/Wt6z3
         o1WtPvtYPsD19PmHm9OLVZzgEUqysbbsmOYlRhPAXPpzcGCQn1e2t5tHXL5o4WnkjQur
         EZbXvxSdfxQ7VdBDDkMlYbEl4LmlEwuUK1oo/7WMSanbfmlIn6yCHNnKZLq2vpaNkIyW
         tDhQ==
X-Google-Smtp-Source: APXvYqxPNPG6zLFHjtM4dyk5+IsHprzo7Fpe7E2iITNY3Nfswb5d8bihSgIplM2GAJmG6XzIvzsXZh61I4tZiVJEP80=
X-Received: by 2002:a17:90a:25c8:: with SMTP id k66mr6845324pje.129.1560272997822;
 Tue, 11 Jun 2019 10:09:57 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1559580831.git.andreyknvl@google.com> <4327b260fb17c4776a1e3c844f388e4948cfb747.1559580831.git.andreyknvl@google.com>
 <20190610175326.GC25803@arrakis.emea.arm.com> <20190611145720.GA63588@arrakis.emea.arm.com>
In-Reply-To: <20190611145720.GA63588@arrakis.emea.arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 11 Jun 2019 19:09:46 +0200
Message-ID: <CAAeHK+z5nSOOaGfehETzznNcMq5E5U+Eb1rZE16UVsT8FWT0Vg@mail.gmail.com>
Subject: Re: [PATCH v16 02/16] arm64: untag user pointers in access_ok and __uaccess_mask_ptr
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Mark Rutland <mark.rutland@arm.com>, kvm@vger.kernel.org, 
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>, Will Deacon <will.deacon@arm.com>, 
	dri-devel@lists.freedesktop.org, 
	Linux Memory Management List <linux-mm@kvack.org>, Khalid Aziz <khalid.aziz@oracle.com>, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, Felix Kuehling <Felix.Kuehling@amd.com>, 
	Vincenzo Frascino <vincenzo.frascino@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Leon Romanovsky <leon@kernel.org>, linux-rdma@vger.kernel.org, amd-gfx@lists.freedesktop.org, 
	Christoph Hellwig <hch@infradead.org>, Jason Gunthorpe <jgg@ziepe.ca>, Dmitry Vyukov <dvyukov@google.com>, 
	Dave Martin <Dave.Martin@arm.com>, Evgeniy Stepanov <eugenis@google.com>, linux-media@vger.kernel.org, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Kees Cook <keescook@chromium.org>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Alex Williamson <alex.williamson@redhat.com>, 
	Mauro Carvalho Chehab <mchehab@kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Kostya Serebryany <kcc@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Yishai Hadas <yishaih@mellanox.com>, LKML <linux-kernel@vger.kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Lee Smith <Lee.Smith@arm.com>, 
	Alexander Deucher <Alexander.Deucher@amd.com>, Andrew Morton <akpm@linux-foundation.org>, 
	enh <enh@google.com>, Robin Murphy <robin.murphy@arm.com>, 
	Christian Koenig <Christian.Koenig@amd.com>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 4:57 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
>
> On Mon, Jun 10, 2019 at 06:53:27PM +0100, Catalin Marinas wrote:
> > On Mon, Jun 03, 2019 at 06:55:04PM +0200, Andrey Konovalov wrote:
> > > diff --git a/arch/arm64/include/asm/uaccess.h b/arch/arm64/include/asm/uaccess.h
> > > index e5d5f31c6d36..9164ecb5feca 100644
> > > --- a/arch/arm64/include/asm/uaccess.h
> > > +++ b/arch/arm64/include/asm/uaccess.h
> > > @@ -94,7 +94,7 @@ static inline unsigned long __range_ok(const void __user *addr, unsigned long si
> > >     return ret;
> > >  }
> > >
> > > -#define access_ok(addr, size)      __range_ok(addr, size)
> > > +#define access_ok(addr, size)      __range_ok(untagged_addr(addr), size)
> >
> > I'm going to propose an opt-in method here (RFC for now). We can't have
> > a check in untagged_addr() since this is already used throughout the
> > kernel for both user and kernel addresses (khwasan) but we can add one
> > in __range_ok(). The same prctl() option will be used for controlling
> > the precise/imprecise mode of MTE later on. We can use a TIF_ flag here
> > assuming that this will be called early on and any cloned thread will
> > inherit this.
>
> Updated patch, inlining it below. Once we agreed on the approach, I
> think Andrey can insert in in this series, probably after patch 2. The
> differences from the one I posted yesterday:
>
> - renamed PR_* macros together with get/set variants and the possibility
>   to disable the relaxed ABI
>
> - sysctl option - /proc/sys/abi/tagged_addr to disable the ABI globally
>   (just the prctl() opt-in, tasks already using it won't be affected)
>
> And, of course, it needs more testing.

Sure, I'll add it to the series.

Should I drop access_ok() change from my patch, since yours just reverts it?

Thanks!

>
> ---------8<----------------
> From 7c624777a4e545522dec1b34e60f0229cb2bd59f Mon Sep 17 00:00:00 2001
> From: Catalin Marinas <catalin.marinas@arm.com>
> Date: Tue, 11 Jun 2019 13:03:38 +0100
> Subject: [PATCH] arm64: Introduce prctl() options to control the tagged user
>  addresses ABI
>
> It is not desirable to relax the ABI to allow tagged user addresses into
> the kernel indiscriminately. This patch introduces a prctl() interface
> for enabling or disabling the tagged ABI with a global sysctl control
> for preventing applications from enabling the relaxed ABI (meant for
> testing user-space prctl() return error checking without reconfiguring
> the kernel). The ABI properties are inherited by threads of the same
> application and fork()'ed children but cleared on execve().
>
> The PR_SET_TAGGED_ADDR_CTRL will be expanded in the future to handle
> MTE-specific settings like imprecise vs precise exceptions.
>
> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
> ---
>  arch/arm64/include/asm/processor.h   |  6 +++
>  arch/arm64/include/asm/thread_info.h |  1 +
>  arch/arm64/include/asm/uaccess.h     |  5 ++-
>  arch/arm64/kernel/process.c          | 67 ++++++++++++++++++++++++++++
>  include/uapi/linux/prctl.h           |  5 +++
>  kernel/sys.c                         | 16 +++++++
>  6 files changed, 99 insertions(+), 1 deletion(-)
>
> diff --git a/arch/arm64/include/asm/processor.h b/arch/arm64/include/asm/processor.h
> index fcd0e691b1ea..fee457456aa8 100644
> --- a/arch/arm64/include/asm/processor.h
> +++ b/arch/arm64/include/asm/processor.h
> @@ -307,6 +307,12 @@ extern void __init minsigstksz_setup(void);
>  /* PR_PAC_RESET_KEYS prctl */
>  #define PAC_RESET_KEYS(tsk, arg)       ptrauth_prctl_reset_keys(tsk, arg)
>
> +/* PR_TAGGED_ADDR prctl */
> +long set_tagged_addr_ctrl(unsigned long arg);
> +long get_tagged_addr_ctrl(void);
> +#define SET_TAGGED_ADDR_CTRL(arg)      set_tagged_addr_ctrl(arg)
> +#define GET_TAGGED_ADDR_CTRL()         get_tagged_addr_ctrl()
> +
>  /*
>   * For CONFIG_GCC_PLUGIN_STACKLEAK
>   *
> diff --git a/arch/arm64/include/asm/thread_info.h b/arch/arm64/include/asm/thread_info.h
> index c285d1ce7186..7263d4c973ce 100644
> --- a/arch/arm64/include/asm/thread_info.h
> +++ b/arch/arm64/include/asm/thread_info.h
> @@ -101,6 +101,7 @@ void arch_release_task_struct(struct task_struct *tsk);
>  #define TIF_SVE                        23      /* Scalable Vector Extension in use */
>  #define TIF_SVE_VL_INHERIT     24      /* Inherit sve_vl_onexec across exec */
>  #define TIF_SSBD               25      /* Wants SSB mitigation */
> +#define TIF_TAGGED_ADDR                26
>
>  #define _TIF_SIGPENDING                (1 << TIF_SIGPENDING)
>  #define _TIF_NEED_RESCHED      (1 << TIF_NEED_RESCHED)
> diff --git a/arch/arm64/include/asm/uaccess.h b/arch/arm64/include/asm/uaccess.h
> index 9164ecb5feca..995b9ea11a89 100644
> --- a/arch/arm64/include/asm/uaccess.h
> +++ b/arch/arm64/include/asm/uaccess.h
> @@ -73,6 +73,9 @@ static inline unsigned long __range_ok(const void __user *addr, unsigned long si
>  {
>         unsigned long ret, limit = current_thread_info()->addr_limit;
>
> +       if (test_thread_flag(TIF_TAGGED_ADDR))
> +               addr = untagged_addr(addr);
> +
>         __chk_user_ptr(addr);
>         asm volatile(
>         // A + B <= C + 1 for all A,B,C, in four easy steps:
> @@ -94,7 +97,7 @@ static inline unsigned long __range_ok(const void __user *addr, unsigned long si
>         return ret;
>  }
>
> -#define access_ok(addr, size)  __range_ok(untagged_addr(addr), size)
> +#define access_ok(addr, size)  __range_ok(addr, size)
>  #define user_addr_max                  get_fs
>
>  #define _ASM_EXTABLE(from, to)                                         \
> diff --git a/arch/arm64/kernel/process.c b/arch/arm64/kernel/process.c
> index 3767fb21a5b8..69d0be1fc708 100644
> --- a/arch/arm64/kernel/process.c
> +++ b/arch/arm64/kernel/process.c
> @@ -30,6 +30,7 @@
>  #include <linux/kernel.h>
>  #include <linux/mm.h>
>  #include <linux/stddef.h>
> +#include <linux/sysctl.h>
>  #include <linux/unistd.h>
>  #include <linux/user.h>
>  #include <linux/delay.h>
> @@ -323,6 +324,7 @@ void flush_thread(void)
>         fpsimd_flush_thread();
>         tls_thread_flush();
>         flush_ptrace_hw_breakpoint(current);
> +       clear_thread_flag(TIF_TAGGED_ADDR);
>  }
>
>  void release_thread(struct task_struct *dead_task)
> @@ -552,3 +554,68 @@ void arch_setup_new_exec(void)
>
>         ptrauth_thread_init_user(current);
>  }
> +
> +/*
> + * Control the relaxed ABI allowing tagged user addresses into the kernel.
> + */
> +static unsigned int tagged_addr_prctl_allowed = 1;
> +
> +long set_tagged_addr_ctrl(unsigned long arg)
> +{
> +       if (!tagged_addr_prctl_allowed)
> +               return -EINVAL;
> +       if (is_compat_task())
> +               return -EINVAL;
> +       if (arg & ~PR_TAGGED_ADDR_ENABLE)
> +               return -EINVAL;
> +
> +       if (arg & PR_TAGGED_ADDR_ENABLE)
> +               set_thread_flag(TIF_TAGGED_ADDR);
> +       else
> +               clear_thread_flag(TIF_TAGGED_ADDR);
> +
> +       return 0;
> +}
> +
> +long get_tagged_addr_ctrl(void)
> +{
> +       if (!tagged_addr_prctl_allowed)
> +               return -EINVAL;
> +       if (is_compat_task())
> +               return -EINVAL;
> +
> +       if (test_thread_flag(TIF_TAGGED_ADDR))
> +               return PR_TAGGED_ADDR_ENABLE;
> +
> +       return 0;
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
> +       {
> +               .procname       = "tagged_addr",
> +               .mode           = 0644,
> +               .data           = &tagged_addr_prctl_allowed,
> +               .maxlen         = sizeof(int),
> +               .proc_handler   = proc_dointvec_minmax,
> +               .extra1         = &zero,
> +               .extra2         = &one,
> +       },
> +       { }
> +};
> +
> +static int __init tagged_addr_init(void)
> +{
> +       if (!register_sysctl("abi", tagged_addr_sysctl_table))
> +               return -EINVAL;
> +       return 0;
> +}
> +
> +core_initcall(tagged_addr_init);
> diff --git a/include/uapi/linux/prctl.h b/include/uapi/linux/prctl.h
> index 094bb03b9cc2..2e927b3e9d6c 100644
> --- a/include/uapi/linux/prctl.h
> +++ b/include/uapi/linux/prctl.h
> @@ -229,4 +229,9 @@ struct prctl_mm_map {
>  # define PR_PAC_APDBKEY                        (1UL << 3)
>  # define PR_PAC_APGAKEY                        (1UL << 4)
>
> +/* Tagged user address controls for arm64 */
> +#define PR_SET_TAGGED_ADDR_CTRL                55
> +#define PR_GET_TAGGED_ADDR_CTRL                56
> +# define PR_TAGGED_ADDR_ENABLE         (1UL << 0)
> +
>  #endif /* _LINUX_PRCTL_H */
> diff --git a/kernel/sys.c b/kernel/sys.c
> index 2969304c29fe..ec48396b4943 100644
> --- a/kernel/sys.c
> +++ b/kernel/sys.c
> @@ -124,6 +124,12 @@
>  #ifndef PAC_RESET_KEYS
>  # define PAC_RESET_KEYS(a, b)  (-EINVAL)
>  #endif
> +#ifndef SET_TAGGED_ADDR_CTRL
> +# define SET_TAGGED_ADDR_CTRL(a)       (-EINVAL)
> +#endif
> +#ifndef GET_TAGGED_ADDR_CTRL
> +# define GET_TAGGED_ADDR_CTRL()                (-EINVAL)
> +#endif
>
>  /*
>   * this is where the system-wide overflow UID and GID are defined, for
> @@ -2492,6 +2498,16 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
>                         return -EINVAL;
>                 error = PAC_RESET_KEYS(me, arg2);
>                 break;
> +       case PR_SET_TAGGED_ADDR_CTRL:
> +               if (arg3 || arg4 || arg5)
> +                       return -EINVAL;
> +               error = SET_TAGGED_ADDR_CTRL(arg2);
> +               break;
> +       case PR_GET_TAGGED_ADDR_CTRL:
> +               if (arg2 || arg3 || arg4 || arg5)
> +                       return -EINVAL;
> +               error = GET_TAGGED_ADDR_CTRL();
> +               break;
>         default:
>                 error = -EINVAL;
>                 break;

