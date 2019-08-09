Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6B78C32756
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:08:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 625C921773
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:08:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 625C921773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D84586B0313; Fri,  9 Aug 2019 12:08:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D358D6B0316; Fri,  9 Aug 2019 12:08:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BFDC36B0318; Fri,  9 Aug 2019 12:08:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 733156B0313
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:08:09 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id s19so1068778wmc.7
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:08:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=rW/mY6HbNe5w0UG/H1LkubWd3sNo3D/Y0dAJgfY4nhE=;
        b=IyoPOSxJHpg4oOX2sac/7vEhRD2aT7pBQCC0JUPtUsylgh7/1mjBRK70Qa+NwAoeUp
         jp8j7l2fJuijP6OFyFpKJjtyYwF6YebiJJ6o93dJdUBGS6TOqVdPSR9J5dnKMp30Y1jW
         /ELsP+HzMMR9gEmBSGDT2jwms/F71C/zqDuZPMxpahe2CYCkFZt2H9OHgQSIH+x+3ka1
         PSg1z3u3nrxaFD5BhWVr7mJE9gcRe0THFDTRxvhoaXlFoAbpwcMO2W/DiDf18ybwLSqV
         GVzR3HyP8HJI4pOrXOLYQzpoCTSJTG69HqAgr8ZWhICcE0+7nTSVjW4h1cdDPO5AcZTj
         ESJw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAVJvuWrpjv9c917EZ2lDjVFAGwEtOE7Y7T+/saDdj2nK/FCeE9R
	infVqETpWznFGhhXKi7Y7Ko3Vj95klAMF3GVF8ofT/06gQgtO0Go2uukOnGZzcxKhhq8D4QOh5i
	gwHnr04RV2rtaQXoKVVQaLiO9zbTiEHL9F4vhJBdmWkOz4/Ot70NriM8Hik8FA4AXfA==
X-Received: by 2002:a1c:f115:: with SMTP id p21mr10950632wmh.134.1565366888972;
        Fri, 09 Aug 2019 09:08:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy0Lg1dEldppAJ5sW+Lde68M0+fepYbwsHAOwUEpKC1OZZSAj8bjDneGUHKq9kCekzf85fG
X-Received: by 2002:a1c:f115:: with SMTP id p21mr10950568wmh.134.1565366888190;
        Fri, 09 Aug 2019 09:08:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366888; cv=none;
        d=google.com; s=arc-20160816;
        b=FTo8J+BvOqaGMcy8U3AlK4y2b75syfmsHMjAgrxLWm7sZ7XQS39WRrSPF+tdbkTft5
         gTfuW4+Be7n2QlN9YfvD/0ZNWiLRUY8S6DXjJG49VpNjoLMNFilWN7nlOY3N0tMkHkXt
         XP1zKZPWLl+WmFVaU6C0QBA0H0cAy+/fLPvi3kQd/Uw1JyFQpKjT+Ca6CbuAuOswAeCh
         O3d59Y6It/mcK7HSuplPxZU1ezpcrxl5gP0JE/ZW4x4vItpO/CxBhFFJLBxBgGtHCOxI
         kdMD5KP1CUbuBcjkplO17NQHXmf1v1K/LYx4opMHRqCtHcgZwh4scB9hpM9Fw43MkeSV
         J9/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=rW/mY6HbNe5w0UG/H1LkubWd3sNo3D/Y0dAJgfY4nhE=;
        b=BjD5q64tz99pJSj6vs/5SC2PCWJyo/UjbrTPFUXGSv+QaI3PVK42o/GnNsk6Oj1Bo3
         zfw1B0e1/SSJH+3OIw18i+RBm4C8kgohR0kqnwGL8ZU2gPC/T10Vp45RIR7yJoclDJWW
         QBPQAoqd2/vZ5lmT2b1aEzHvGogzpQJKtTGfyBqjHhedy/vDy+wgcKqysSiU8V624lWf
         JmZFvhdj3KF+2Fsu/UjxPidcPnv9CPX88kEpeElQn1wWo1xbeIswC2ygAGn+Tc+pcy4r
         nMlNTEzH34n+pQUH5eSDoqA0HLz2hjMkt7YCKbmXrkVQ97uJZWKss5IVvkCxy1FjNpaL
         mBrA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id p5si3446712eda.113.2019.08.09.09.08.07
        for <linux-mm@kvack.org>;
        Fri, 09 Aug 2019 09:08:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 37BC415AB;
	Fri,  9 Aug 2019 09:08:07 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 6D88D3F575;
	Fri,  9 Aug 2019 09:08:02 -0700 (PDT)
Date: Fri, 9 Aug 2019 17:08:00 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Andrey Konovalov <andreyknvl@google.com>,
	Will Deacon <will.deacon@arm.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Kees Cook <keescook@chromium.org>,
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
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Dave Hansen <dave.hansen@intel.com>
Subject: Re: [PATCH v19 02/15] arm64: Introduce prctl() options to control
 the tagged user addresses ABI
Message-ID: <20190809160800.GC23083@arrakis.emea.arm.com>
References: <cover.1563904656.git.andreyknvl@google.com>
 <1c05651c53f90d07e98ee4973c2786ccf315db12.1563904656.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1c05651c53f90d07e98ee4973c2786ccf315db12.1563904656.git.andreyknvl@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 07:58:39PM +0200, Andrey Konovalov wrote:
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
> Reviewed-by: Kees Cook <keescook@chromium.org>
> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

Following several discussions on the list and in private, I'm proposing
the update below. I can send it as a patch on top of the current series
since Will has already queued this.

---------------8<-------------------------------------
From 1b3f57ab0c2c51f8b31c19fb34d270e1f3ee57fe Mon Sep 17 00:00:00 2001
From: Catalin Marinas <catalin.marinas@arm.com>
Date: Fri, 9 Aug 2019 15:09:15 +0100
Subject: [PATCH] fixup! arm64: Introduce prctl() options to control the
 tagged user addresses ABI

Rename abi.tagged_addr sysctl control to abi.tagged_addr_disabled,
defaulting to 0. Only prevent prctl(PR_TAGGED_ADDR_ENABLE)from being
called when abi.tagged_addr_disabled==1.

Force unused arg* of the new prctl() to 0.

Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
---
 arch/arm64/kernel/process.c | 17 ++++++++++-------
 kernel/sys.c                |  4 ++++
 2 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/arch/arm64/kernel/process.c b/arch/arm64/kernel/process.c
index 76b7c55026aa..03689c0beb34 100644
--- a/arch/arm64/kernel/process.c
+++ b/arch/arm64/kernel/process.c
@@ -579,17 +579,22 @@ void arch_setup_new_exec(void)
 /*
  * Control the relaxed ABI allowing tagged user addresses into the kernel.
  */
-static unsigned int tagged_addr_prctl_allowed = 1;
+static unsigned int tagged_addr_disabled;
 
 long set_tagged_addr_ctrl(unsigned long arg)
 {
-	if (!tagged_addr_prctl_allowed)
-		return -EINVAL;
 	if (is_compat_task())
 		return -EINVAL;
 	if (arg & ~PR_TAGGED_ADDR_ENABLE)
 		return -EINVAL;
 
+	/*
+	 * Do not allow the enabling of the tagged address ABI if globally
+	 * disabled via sysctl abi.tagged_addr_disabled.
+	 */
+	if (arg & PR_TAGGED_ADDR_ENABLE && tagged_addr_disabled)
+		return -EINVAL;
+
 	update_thread_flag(TIF_TAGGED_ADDR, arg & PR_TAGGED_ADDR_ENABLE);
 
 	return 0;
@@ -597,8 +602,6 @@ long set_tagged_addr_ctrl(unsigned long arg)
 
 long get_tagged_addr_ctrl(void)
 {
-	if (!tagged_addr_prctl_allowed)
-		return -EINVAL;
 	if (is_compat_task())
 		return -EINVAL;
 
@@ -618,9 +621,9 @@ static int one = 1;
 
 static struct ctl_table tagged_addr_sysctl_table[] = {
 	{
-		.procname	= "tagged_addr",
+		.procname	= "tagged_addr_disabled",
 		.mode		= 0644,
-		.data		= &tagged_addr_prctl_allowed,
+		.data		= &tagged_addr_disabled,
 		.maxlen		= sizeof(int),
 		.proc_handler	= proc_dointvec_minmax,
 		.extra1		= &zero,
diff --git a/kernel/sys.c b/kernel/sys.c
index c6c4d5358bd3..ec48396b4943 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -2499,9 +2499,13 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
 		error = PAC_RESET_KEYS(me, arg2);
 		break;
 	case PR_SET_TAGGED_ADDR_CTRL:
+		if (arg3 || arg4 || arg5)
+			return -EINVAL;
 		error = SET_TAGGED_ADDR_CTRL(arg2);
 		break;
 	case PR_GET_TAGGED_ADDR_CTRL:
+		if (arg2 || arg3 || arg4 || arg5)
+			return -EINVAL;
 		error = GET_TAGGED_ADDR_CTRL();
 		break;
 	default:

