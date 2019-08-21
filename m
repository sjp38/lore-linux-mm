Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 605E0C3A5A0
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 14:45:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0274F20679
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 14:45:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=alien8.de header.i=@alien8.de header.b="UkT303Q6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0274F20679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=alien8.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3E20C6B0271; Wed, 21 Aug 2019 10:45:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 36AA16B02C2; Wed, 21 Aug 2019 10:45:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 232176B02C3; Wed, 21 Aug 2019 10:45:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0116.hostedemail.com [216.40.44.116])
	by kanga.kvack.org (Postfix) with ESMTP id EF6F76B0271
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 10:45:46 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 8807CA2D4
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 14:45:46 +0000 (UTC)
X-FDA: 75846709092.05.stamp78_6c86f42e42b42
X-HE-Tag: stamp78_6c86f42e42b42
X-Filterd-Recvd-Size: 4340
Received: from mail.skyhub.de (mail.skyhub.de [5.9.137.197])
	by imf14.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 14:45:45 +0000 (UTC)
Received: from zn.tnic (p200300EC2F0A6300AD34BF75F4F01B21.dip0.t-ipconnect.de [IPv6:2003:ec:2f0a:6300:ad34:bf75:f4f0:1b21])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.skyhub.de (SuperMail on ZX Spectrum 128k) with ESMTPSA id 640051EC02FE;
	Wed, 21 Aug 2019 16:45:43 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=alien8.de; s=dkim;
	t=1566398743;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:in-reply-to:in-reply-to:  references:references;
	bh=lTbUTRWT7/yDYikPZXnxrPfidgHBKAk129d3QMAlBN8=;
	b=UkT303Q6PQdQLRjF8bKFTVDYvf4/veO5tJOiyCziZe8EFQW68CVP7lBVMYQ6nGizmgFJKg
	FXELQvYm+ouBqgeO8bgrwK4zZB6waqhJ19Svr+ncvTHiXIWFyPkdLQkYqVzmPMYB1QhKcy
	UQ+ZL3nw4KcOvt+o5NmnqkpKAJ1PVOU=
Date: Wed, 21 Aug 2019 16:45:37 +0200
From: Borislav Petkov <bp@alien8.de>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-mm@kvack.org,
	linux-arch@vger.kernel.org, linux-api@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Andy Lutomirski <luto@amacapital.net>,
	Balbir Singh <bsingharora@gmail.com>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Eugene Syromiatnikov <esyr@redhat.com>,
	Florian Weimer <fweimer@redhat.com>,
	"H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>,
	Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>,
	Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	"Ravi V. Shankar" <ravi.v.shankar@intel.com>,
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,
	Dave Martin <Dave.Martin@arm.com>
Subject: Re: [PATCH v8 03/27] x86/fpu/xstate: Change names to separate XSAVES
 system and user states
Message-ID: <20190821144537.GE6752@zn.tnic>
References: <20190813205225.12032-1-yu-cheng.yu@intel.com>
 <20190813205225.12032-4-yu-cheng.yu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190813205225.12032-4-yu-cheng.yu@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 13, 2019 at 01:52:01PM -0700, Yu-cheng Yu wrote:
> Control-flow Enforcement (CET) MSR contents are XSAVES system states.
> To support CET, introduce XSAVES system states first.
> 
> XSAVES is a "supervisor" instruction and, comparing to XSAVE, saves
> additional "supervisor" states that can be modified only from CPL 0.
> However, these states are per-task and not kernel's own.  Rename
> "supervisor" states to "system" states to clearly separate them from
> "user" states.
> 
> Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> ---
>  arch/x86/include/asm/fpu/internal.h |  4 +-
>  arch/x86/include/asm/fpu/xstate.h   | 20 +++----
>  arch/x86/kernel/fpu/init.c          |  2 +-
>  arch/x86/kernel/fpu/signal.c        | 10 ++--
>  arch/x86/kernel/fpu/xstate.c        | 86 ++++++++++++++---------------
>  5 files changed, 60 insertions(+), 62 deletions(-)

...

> diff --git a/arch/x86/kernel/fpu/xstate.c b/arch/x86/kernel/fpu/xstate.c
> index e5cb67d67c03..d560e8861a3c 100644
> --- a/arch/x86/kernel/fpu/xstate.c
> +++ b/arch/x86/kernel/fpu/xstate.c
> @@ -54,13 +54,16 @@ static short xsave_cpuid_features[] __initdata = {
>  };
>  
>  /*
> - * Mask of xstate features supported by the CPU and the kernel:
> + * XSAVES system states can only be modified from CPL 0 and saved by
> + * XSAVES.  The rest are user states.  The following is a mask of
> + * supported user state features derived from boot_cpu_has() and

...derived from detected CPUID feature flags and
SUPPORTED_XFEATURES_MASK.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

