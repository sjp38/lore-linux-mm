Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3FABAC4321A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 14:57:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DDB182080A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 14:57:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DDB182080A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 474166B0007; Tue, 11 Jun 2019 10:57:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 424736B0266; Tue, 11 Jun 2019 10:57:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 314A56B0270; Tue, 11 Jun 2019 10:57:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D549C6B0007
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 10:57:29 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id k15so21127973eda.6
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 07:57:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=mc8sVIFZR78L5U07A63jJjrxHEPH7rmqpd+ygU9H19g=;
        b=FaaZfFNJQprD8g9MDfayAR9y8iZU2azb9iJdAvmOkN+m/cf37j+Be0/G8ZrDHfGDdx
         FR1jKDqFJIZJAKIH0YZTvFz4oFjm14+KZ+v+gVz4o6fMScXJya64Q7gmFJ1TmTBRNUKk
         0bPjdD6RlC/TOWHkzN7Eymdx/x2UIJrh90ymjIK2nLGqLDB/qnYugJSPWUUOxX1/dyiq
         //QjjXtVO009u9jBR9yQ04gKjmDhuDa/rDGWhu+E9FIoQ5eKdQyKwoVFiWjHUlI7wxUe
         ldm5PS9xGj2TMTaJNHSSNCwfqFm1OeV63K6fj7Hkt9T/T1KStCAd5FfF3tmhB/ee8MdC
         /Eww==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAUmT0qv/VSVuA3Ihp/C0MS9OfZh1DMFuJTHUGS1LdP3DUIqw8xC
	ocFKNQgmUpJ5Zu48N+i03tfw4spq5PQAI49iTAWxKfGPpBY0mg+uJ/ZPFGjJAUdw0DxitYi0Bth
	H8oMBAH0Xl9S0AiSj6Omfd6H2ogkHtmy+Gs3bjvRiJ2EkA05cyebKeufLhBcVakFq2g==
X-Received: by 2002:a50:c9c2:: with SMTP id c2mr41670695edi.183.1560265049375;
        Tue, 11 Jun 2019 07:57:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxJMyFOMBMp1fqrxSkLVZVwy6X/E6PsgO0a2YBeJjEspc1h8JKeATZJx4S7bYPcWspns+qU
X-Received: by 2002:a50:c9c2:: with SMTP id c2mr41670617edi.183.1560265048550;
        Tue, 11 Jun 2019 07:57:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560265048; cv=none;
        d=google.com; s=arc-20160816;
        b=iTbrJVCF7orDOpIhabNdgEYTOI9HW0NEk7v9c1jL+gr8NFf3xQOF2/451tC2FmlHWo
         Q1FMBXxMcK8d1+wJhbiAmgMUIIbbAgWryXfYHn8FOz1CejUdjLpNweF7spv/cunWwuCi
         YKa7oBhgsKe3lhtVnMlCPICJrO7FdK2vf8RcrT1ZMlc4ILgMM1GHXm7PFH4s+rU+suTi
         S/xkz2mGLqlb6GdmK8Ol4FtBrDUYkzCtcZzrsOVg29KqhFbamFU8cepdC+CP7wDFP+ly
         mxx8ubGwvScDIXcDlHU9PmXxdmOxWXKYAqGfWbWoSNALeKF6s1RnqazbiTKjyK17FVB+
         Faxw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=mc8sVIFZR78L5U07A63jJjrxHEPH7rmqpd+ygU9H19g=;
        b=DKejTqfXD/apKyTcJTJ/4PlWUofWKQ6k3N+JjFxvvgkDjs/P4ZHqrvh1dh+5AKADWG
         Bc1Mkxh8NR2dd5f6S46xu6WX20zchu9nYElTPhlOsX1MwhrxVrHfB8iGKOJ2FHzxXyGl
         pu7xWjN3jGZfnnv3y5FGRdXhILE8DUNw/tFDyyfPIkT/F4qZAFtIBEIyUWpV3cqmbqUp
         VdujUUO9boKZYKKBLnJWXjJRYA10ToPpQZ/LRc4RDRemXyzshq7R7KJuP2sJ++LKaGSA
         webvlG67+c8qDE6wIeIWBbF6P9dpacKQYx661k2KF9EzWKrerAeuiwzuX0OT5c6955vJ
         CsAw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id z48si61862edc.301.2019.06.11.07.57.28
        for <linux-mm@kvack.org>;
        Tue, 11 Jun 2019 07:57:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 89C0E346;
	Tue, 11 Jun 2019 07:57:27 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id DD04E3F246;
	Tue, 11 Jun 2019 07:57:22 -0700 (PDT)
Date: Tue, 11 Jun 2019 15:57:20 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Mark Rutland <mark.rutland@arm.com>, kvm@vger.kernel.org,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Will Deacon <will.deacon@arm.com>, dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org, Khalid Aziz <khalid.aziz@oracle.com>,
	linux-kselftest@vger.kernel.org,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Leon Romanovsky <leon@kernel.org>, linux-rdma@vger.kernel.org,
	amd-gfx@lists.freedesktop.org,
	Christoph Hellwig <hch@infradead.org>,
	Jason Gunthorpe <jgg@ziepe.ca>, Dmitry Vyukov <dvyukov@google.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Evgeniy Stepanov <eugenis@google.com>, linux-media@vger.kernel.org,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Kees Cook <keescook@chromium.org>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Alex Williamson <alex.williamson@redhat.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	linux-arm-kernel@lists.infradead.org,
	Kostya Serebryany <kcc@google.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Yishai Hadas <yishaih@mellanox.com>, linux-kernel@vger.kernel.org,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Lee Smith <Lee.Smith@arm.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Andrew Morton <akpm@linux-foundation.org>, enh <enh@google.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [PATCH v16 02/16] arm64: untag user pointers in access_ok and
 __uaccess_mask_ptr
Message-ID: <20190611145720.GA63588@arrakis.emea.arm.com>
References: <cover.1559580831.git.andreyknvl@google.com>
 <4327b260fb17c4776a1e3c844f388e4948cfb747.1559580831.git.andreyknvl@google.com>
 <20190610175326.GC25803@arrakis.emea.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190610175326.GC25803@arrakis.emea.arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 10, 2019 at 06:53:27PM +0100, Catalin Marinas wrote:
> On Mon, Jun 03, 2019 at 06:55:04PM +0200, Andrey Konovalov wrote:
> > diff --git a/arch/arm64/include/asm/uaccess.h b/arch/arm64/include/asm/uaccess.h
> > index e5d5f31c6d36..9164ecb5feca 100644
> > --- a/arch/arm64/include/asm/uaccess.h
> > +++ b/arch/arm64/include/asm/uaccess.h
> > @@ -94,7 +94,7 @@ static inline unsigned long __range_ok(const void __user *addr, unsigned long si
> >  	return ret;
> >  }
> >  
> > -#define access_ok(addr, size)	__range_ok(addr, size)
> > +#define access_ok(addr, size)	__range_ok(untagged_addr(addr), size)
> 
> I'm going to propose an opt-in method here (RFC for now). We can't have
> a check in untagged_addr() since this is already used throughout the
> kernel for both user and kernel addresses (khwasan) but we can add one
> in __range_ok(). The same prctl() option will be used for controlling
> the precise/imprecise mode of MTE later on. We can use a TIF_ flag here
> assuming that this will be called early on and any cloned thread will
> inherit this.

Updated patch, inlining it below. Once we agreed on the approach, I
think Andrey can insert in in this series, probably after patch 2. The
differences from the one I posted yesterday:

- renamed PR_* macros together with get/set variants and the possibility
  to disable the relaxed ABI

- sysctl option - /proc/sys/abi/tagged_addr to disable the ABI globally
  (just the prctl() opt-in, tasks already using it won't be affected)

And, of course, it needs more testing.

---------8<----------------
From 7c624777a4e545522dec1b34e60f0229cb2bd59f Mon Sep 17 00:00:00 2001
From: Catalin Marinas <catalin.marinas@arm.com>
Date: Tue, 11 Jun 2019 13:03:38 +0100
Subject: [PATCH] arm64: Introduce prctl() options to control the tagged user
 addresses ABI

It is not desirable to relax the ABI to allow tagged user addresses into
the kernel indiscriminately. This patch introduces a prctl() interface
for enabling or disabling the tagged ABI with a global sysctl control
for preventing applications from enabling the relaxed ABI (meant for
testing user-space prctl() return error checking without reconfiguring
the kernel). The ABI properties are inherited by threads of the same
application and fork()'ed children but cleared on execve().

The PR_SET_TAGGED_ADDR_CTRL will be expanded in the future to handle
MTE-specific settings like imprecise vs precise exceptions.

Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
---
 arch/arm64/include/asm/processor.h   |  6 +++
 arch/arm64/include/asm/thread_info.h |  1 +
 arch/arm64/include/asm/uaccess.h     |  5 ++-
 arch/arm64/kernel/process.c          | 67 ++++++++++++++++++++++++++++
 include/uapi/linux/prctl.h           |  5 +++
 kernel/sys.c                         | 16 +++++++
 6 files changed, 99 insertions(+), 1 deletion(-)

diff --git a/arch/arm64/include/asm/processor.h b/arch/arm64/include/asm/processor.h
index fcd0e691b1ea..fee457456aa8 100644
--- a/arch/arm64/include/asm/processor.h
+++ b/arch/arm64/include/asm/processor.h
@@ -307,6 +307,12 @@ extern void __init minsigstksz_setup(void);
 /* PR_PAC_RESET_KEYS prctl */
 #define PAC_RESET_KEYS(tsk, arg)	ptrauth_prctl_reset_keys(tsk, arg)
 
+/* PR_TAGGED_ADDR prctl */
+long set_tagged_addr_ctrl(unsigned long arg);
+long get_tagged_addr_ctrl(void);
+#define SET_TAGGED_ADDR_CTRL(arg)	set_tagged_addr_ctrl(arg)
+#define GET_TAGGED_ADDR_CTRL()		get_tagged_addr_ctrl()
+
 /*
  * For CONFIG_GCC_PLUGIN_STACKLEAK
  *
diff --git a/arch/arm64/include/asm/thread_info.h b/arch/arm64/include/asm/thread_info.h
index c285d1ce7186..7263d4c973ce 100644
--- a/arch/arm64/include/asm/thread_info.h
+++ b/arch/arm64/include/asm/thread_info.h
@@ -101,6 +101,7 @@ void arch_release_task_struct(struct task_struct *tsk);
 #define TIF_SVE			23	/* Scalable Vector Extension in use */
 #define TIF_SVE_VL_INHERIT	24	/* Inherit sve_vl_onexec across exec */
 #define TIF_SSBD		25	/* Wants SSB mitigation */
+#define TIF_TAGGED_ADDR		26
 
 #define _TIF_SIGPENDING		(1 << TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1 << TIF_NEED_RESCHED)
diff --git a/arch/arm64/include/asm/uaccess.h b/arch/arm64/include/asm/uaccess.h
index 9164ecb5feca..995b9ea11a89 100644
--- a/arch/arm64/include/asm/uaccess.h
+++ b/arch/arm64/include/asm/uaccess.h
@@ -73,6 +73,9 @@ static inline unsigned long __range_ok(const void __user *addr, unsigned long si
 {
 	unsigned long ret, limit = current_thread_info()->addr_limit;
 
+	if (test_thread_flag(TIF_TAGGED_ADDR))
+		addr = untagged_addr(addr);
+
 	__chk_user_ptr(addr);
 	asm volatile(
 	// A + B <= C + 1 for all A,B,C, in four easy steps:
@@ -94,7 +97,7 @@ static inline unsigned long __range_ok(const void __user *addr, unsigned long si
 	return ret;
 }
 
-#define access_ok(addr, size)	__range_ok(untagged_addr(addr), size)
+#define access_ok(addr, size)	__range_ok(addr, size)
 #define user_addr_max			get_fs
 
 #define _ASM_EXTABLE(from, to)						\
diff --git a/arch/arm64/kernel/process.c b/arch/arm64/kernel/process.c
index 3767fb21a5b8..69d0be1fc708 100644
--- a/arch/arm64/kernel/process.c
+++ b/arch/arm64/kernel/process.c
@@ -30,6 +30,7 @@
 #include <linux/kernel.h>
 #include <linux/mm.h>
 #include <linux/stddef.h>
+#include <linux/sysctl.h>
 #include <linux/unistd.h>
 #include <linux/user.h>
 #include <linux/delay.h>
@@ -323,6 +324,7 @@ void flush_thread(void)
 	fpsimd_flush_thread();
 	tls_thread_flush();
 	flush_ptrace_hw_breakpoint(current);
+	clear_thread_flag(TIF_TAGGED_ADDR);
 }
 
 void release_thread(struct task_struct *dead_task)
@@ -552,3 +554,68 @@ void arch_setup_new_exec(void)
 
 	ptrauth_thread_init_user(current);
 }
+
+/*
+ * Control the relaxed ABI allowing tagged user addresses into the kernel.
+ */
+static unsigned int tagged_addr_prctl_allowed = 1;
+
+long set_tagged_addr_ctrl(unsigned long arg)
+{
+	if (!tagged_addr_prctl_allowed)
+		return -EINVAL;
+	if (is_compat_task())
+		return -EINVAL;
+	if (arg & ~PR_TAGGED_ADDR_ENABLE)
+		return -EINVAL;
+
+	if (arg & PR_TAGGED_ADDR_ENABLE)
+		set_thread_flag(TIF_TAGGED_ADDR);
+	else
+		clear_thread_flag(TIF_TAGGED_ADDR);
+
+	return 0;
+}
+
+long get_tagged_addr_ctrl(void)
+{
+	if (!tagged_addr_prctl_allowed)
+		return -EINVAL;
+	if (is_compat_task())
+		return -EINVAL;
+
+	if (test_thread_flag(TIF_TAGGED_ADDR))
+		return PR_TAGGED_ADDR_ENABLE;
+
+	return 0;
+}
+
+/*
+ * Global sysctl to disable the tagged user addresses support. This control
+ * only prevents the tagged address ABI enabling via prctl() and does not
+ * disable it for tasks that already opted in to the relaxed ABI.
+ */
+static int zero;
+static int one = 1;
+
+static struct ctl_table tagged_addr_sysctl_table[] = {
+	{
+		.procname	= "tagged_addr",
+		.mode		= 0644,
+		.data		= &tagged_addr_prctl_allowed,
+		.maxlen		= sizeof(int),
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &one,
+	},
+	{ }
+};
+
+static int __init tagged_addr_init(void)
+{
+	if (!register_sysctl("abi", tagged_addr_sysctl_table))
+		return -EINVAL;
+	return 0;
+}
+
+core_initcall(tagged_addr_init);
diff --git a/include/uapi/linux/prctl.h b/include/uapi/linux/prctl.h
index 094bb03b9cc2..2e927b3e9d6c 100644
--- a/include/uapi/linux/prctl.h
+++ b/include/uapi/linux/prctl.h
@@ -229,4 +229,9 @@ struct prctl_mm_map {
 # define PR_PAC_APDBKEY			(1UL << 3)
 # define PR_PAC_APGAKEY			(1UL << 4)
 
+/* Tagged user address controls for arm64 */
+#define PR_SET_TAGGED_ADDR_CTRL		55
+#define PR_GET_TAGGED_ADDR_CTRL		56
+# define PR_TAGGED_ADDR_ENABLE		(1UL << 0)
+
 #endif /* _LINUX_PRCTL_H */
diff --git a/kernel/sys.c b/kernel/sys.c
index 2969304c29fe..ec48396b4943 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -124,6 +124,12 @@
 #ifndef PAC_RESET_KEYS
 # define PAC_RESET_KEYS(a, b)	(-EINVAL)
 #endif
+#ifndef SET_TAGGED_ADDR_CTRL
+# define SET_TAGGED_ADDR_CTRL(a)	(-EINVAL)
+#endif
+#ifndef GET_TAGGED_ADDR_CTRL
+# define GET_TAGGED_ADDR_CTRL()		(-EINVAL)
+#endif
 
 /*
  * this is where the system-wide overflow UID and GID are defined, for
@@ -2492,6 +2498,16 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
 			return -EINVAL;
 		error = PAC_RESET_KEYS(me, arg2);
 		break;
+	case PR_SET_TAGGED_ADDR_CTRL:
+		if (arg3 || arg4 || arg5)
+			return -EINVAL;
+		error = SET_TAGGED_ADDR_CTRL(arg2);
+		break;
+	case PR_GET_TAGGED_ADDR_CTRL:
+		if (arg2 || arg3 || arg4 || arg5)
+			return -EINVAL;
+		error = GET_TAGGED_ADDR_CTRL();
+		break;
 	default:
 		error = -EINVAL;
 		break;

