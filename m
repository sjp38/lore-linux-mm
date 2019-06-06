Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02A78C04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:27:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A71BA214C6
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:27:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Ci44e+1H"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A71BA214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3AD686B02E2; Thu,  6 Jun 2019 16:27:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 35CD36B02E4; Thu,  6 Jun 2019 16:27:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 24C226B02E5; Thu,  6 Jun 2019 16:27:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id DE7A46B02E2
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 16:27:57 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id i26so2603450pfo.22
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 13:27:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=0DYMguRNb0DXh2PZ+B5ve/T0J1sOvSO1bJ8hlceCD9w=;
        b=JyMw2mIjcrNhfu8mrC2gslOwkF7HD7IIk9myyOMFShu6ead4b43H3EoBZL32NgBo6G
         D7UR56fa64309a1Jrc4bT/PU75i3BpK8Q0pAj7Ijvtav7QjTCNjtKcx3KwCkdcEu9evm
         0b9EYgMeoF4Zjt+5BGtRXUPplpEq0vt2BL7OiQEqgFj0Ya7VU51Z+9yCaSPN5gEv0wbz
         kbIzV/x6J4QL04i9KTAjjrD7bMTeeFk6aNk+0sp5YTTyjPDvRtz2bnvacbTeG5pB7oGh
         4AY1NWT6pkv15liGVm0xtD2egQmFyY/w0mYCpXDzlx8ak2FcYhej69UJVm+uG6TAj3HU
         MHZw==
X-Gm-Message-State: APjAAAUVIiX7yP64E2BtRLM2BWn0KpTArQF99zcFVZjtNxVBH8jXtbr2
	e4rZ2ZByzHQ4otFL5k7dnLwpAsAdQdg9xV9AnDuIaUMe8gTSc5qEuDXsYAgqzr8u8HHsrD54yNK
	vzt39h7TVU2xpUuEzmKM3WIjO6TFx7qwet3OA267X6RTQz5giz8zPY1ecFgt8vHUuUw==
X-Received: by 2002:a17:902:ba82:: with SMTP id k2mr43372963pls.323.1559852877587;
        Thu, 06 Jun 2019 13:27:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzyPRd291oDVb4L0b5QgNc7jAK+FmY7gdvk3gc/fhEu7b/A9e9j3gtqWiFCnMjnAiOJs17K
X-Received: by 2002:a17:902:ba82:: with SMTP id k2mr43372923pls.323.1559852876979;
        Thu, 06 Jun 2019 13:27:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559852876; cv=none;
        d=google.com; s=arc-20160816;
        b=hD8uLv26j+EgtRci/etxXrs+8W8BvpE45xGjuY9F4sfLxxU3tn+Pfc6sx4pJBaQ/yX
         LDmlGYEFmcxLWXE3xcrow0XVuHUc4eBopvoonkSGgA5D9MAim5LHEnW41biNyB50ljD/
         RX3cy9ulMTTa44Aja/xPw1IH3YWAO7Wrz9Rk54wPZ6kTgsuqprnBoTqlZtq8ZkBCkVu1
         HBQ+6o1SNV46oKZfcZ+jgyzbE5t0L9aGwyjEJn6CYuNMPAEHWtpaufCDClkNo1J7E5p1
         IM3GmtAz8sYg7QBeP+7bUy4fIzLP7JD6f8xbrdFRBVppYZUXSK2qGyvS6HDY2DEcBrsu
         ZsMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=0DYMguRNb0DXh2PZ+B5ve/T0J1sOvSO1bJ8hlceCD9w=;
        b=zopzdVVUV1HYWNG1xksFzDiYG9m3xM5/kMplvXV0RCinbobI0ZvBDHI56ofNXMYfM1
         lKAf6ZYFaqT3UNK+Qx6MDYoRWM8cY8GXsUPaeMed9zhrYpCPoMKtz8FS1q+uUiJqGaL/
         rosjN3PweB+D2hS68zt/9WyN1oJ8IPYQuQJi1p8Z7hyvgdtGUnSPRaojIa4jMf0TH14c
         BxzTCu858bm3RMdazvasHaddI/Bo18wNr8BCY28qKyGwitgEr1VP1ZGFYksiiAGXB1vP
         f2MOs3j2EMzgd7l5hWM1hMMB7Gvh7oo3nidhCWEymM0qSY07Chwu/1sVUjKwAsOqPkPV
         ooRg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Ci44e+1H;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id u2si36793pjn.13.2019.06.06.13.27.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 13:27:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Ci44e+1H;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wm1-f43.google.com (mail-wm1-f43.google.com [209.85.128.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 5EA1320B1F
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 20:27:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559852876;
	bh=V7Uq2AYQOlpquEHSKTkBWDviou8MRCFEnqb/lAamoAk=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=Ci44e+1HjYkBXHk1NXaSKaCK1CuA9I7JHv13wyv1lEnO/sidJI4tB6xS6yrL8RyS4
	 u1c38WXLlfjZOrTvgSqTEJ1fe0gBzGjB9GSQBqk9RYWMj7SGnOV8OTBZSJy9XfJr6z
	 mc+nJ+Htrap+uCUHep75lsy4tzge8nmCXsv3MFek=
Received: by mail-wm1-f43.google.com with SMTP id g135so1191144wme.4
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 13:27:56 -0700 (PDT)
X-Received: by 2002:a7b:cd84:: with SMTP id y4mr1192848wmj.79.1559852874993;
 Thu, 06 Jun 2019 13:27:54 -0700 (PDT)
MIME-Version: 1.0
References: <20190606200926.4029-1-yu-cheng.yu@intel.com> <20190606200926.4029-13-yu-cheng.yu@intel.com>
In-Reply-To: <20190606200926.4029-13-yu-cheng.yu@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 6 Jun 2019 13:27:43 -0700
X-Gmail-Original-Message-ID: <CALCETrXfBCFKB2SwhEngABPCkAfgmb+YkRL3Xx3-=haN9H+V_g@mail.gmail.com>
Message-ID: <CALCETrXfBCFKB2SwhEngABPCkAfgmb+YkRL3Xx3-=haN9H+V_g@mail.gmail.com>
Subject: Re: [PATCH v7 12/14] x86/vsyscall/64: Fixup shadow stack and branch
 tracking for vsyscall
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, 
	Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, 
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, 
	Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Borislav Petkov <bp@alien8.de>, 
	Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, 
	Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, 
	Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, 
	Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, 
	Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, 
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, Dave Martin <Dave.Martin@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 6, 2019 at 1:17 PM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>
> When emulating a RET, also unwind the task's shadow stack and cancel
> the current branch tracking status.
>
> Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> ---
>  arch/x86/entry/vsyscall/vsyscall_64.c | 28 +++++++++++++++++++++++++++
>  1 file changed, 28 insertions(+)
>
> diff --git a/arch/x86/entry/vsyscall/vsyscall_64.c b/arch/x86/entry/vsyscall/vsyscall_64.c
> index d9d81ad7a400..6869ef9d1e8b 100644
> --- a/arch/x86/entry/vsyscall/vsyscall_64.c
> +++ b/arch/x86/entry/vsyscall/vsyscall_64.c
> @@ -38,6 +38,8 @@
>  #include <asm/fixmap.h>
>  #include <asm/traps.h>
>  #include <asm/paravirt.h>
> +#include <asm/fpu/xstate.h>
> +#include <asm/fpu/types.h>
>
>  #define CREATE_TRACE_POINTS
>  #include "vsyscall_trace.h"
> @@ -92,6 +94,30 @@ static int addr_to_vsyscall_nr(unsigned long addr)
>         return nr;
>  }
>
> +void fixup_shstk(void)
> +{
> +#ifdef CONFIG_X86_INTEL_SHADOW_STACK_USER
> +       u64 r;
> +
> +       if (current->thread.cet.shstk_enabled) {
> +               rdmsrl(MSR_IA32_PL3_SSP, r);
> +               wrmsrl(MSR_IA32_PL3_SSP, r + 8);
> +       }
> +#endif
> +}
> +
> +void fixup_ibt(void)
> +{
> +#ifdef CONFIG_X86_INTEL_BRANCH_TRACKING_USER
> +       u64 r;
> +
> +       if (current->thread.cet.ibt_enabled) {
> +               rdmsrl(MSR_IA32_U_CET, r);
> +               wrmsrl(MSR_IA32_U_CET, r & ~MSR_IA32_CET_WAIT_ENDBR);
> +       }
> +#endif
> +}

These should be static.

But please just inline them directly in their one call site.  The code
will be a lot easier to understand.

--Andy

