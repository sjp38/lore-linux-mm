Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA6C1C282DA
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 11:30:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 79B5D218EA
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 11:30:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=alien8.de header.i=@alien8.de header.b="NHfrC9Gx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 79B5D218EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=alien8.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC2CA8E0002; Thu, 31 Jan 2019 06:30:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D4AD88E0001; Thu, 31 Jan 2019 06:30:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BE8BF8E0002; Thu, 31 Jan 2019 06:30:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 653B38E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 06:30:01 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id l1so956350wrn.3
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 03:30:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=pvDZBEHQP9vEk/hY31YWkOL84S0x4lR9x18fyrSrNy8=;
        b=DYTDlVQus8UjqyEJK3VC5kDARp1qVsFHY/y103B+Ce90pzlSwuFm2LttHYSeu7mQIN
         RFxmCFI+3IQA158YlgqxaUSmlLoG1eC+OGU+GcuUi+v9lQ0uRfXjxuQF80sTS/SxGisf
         etTAMDnkrIwB/ncj7hoWO71SjxPDC8OJSltSuypT9IxUEwkMEiieqHesq+/x0WKbeeVc
         vyvuS1DMG48FUNyrZWvIE9/PtP1tGuUT9URr8rgZMmRBqPuOcG6/GrzL+RoTBp+DasOQ
         rxHuAM7vaH/X+KE2XVQsKP8OoyHlycFisScCjpua2U9eIQrbPxYes0d3EZWriCmJ+jWd
         rWcA==
X-Gm-Message-State: AJcUukeK9fW8O7erJyseMD+D54feIboHMebJpgP2pxyV4V/ND0FuFAON
	9we3dam96FPLO6lDltqofFDwgDO+DdGjrNbjrM9BNvRVeqmzG4LR2rgOAkjj33Adc589/hmg8CV
	CZbNrg0xeB0ItIvhSiKX2DukoU5e6RLGuNuAldvBmoGuQc2B30louVeLOFV5EUgQsew==
X-Received: by 2002:a1c:13d1:: with SMTP id 200mr28596798wmt.4.1548934200916;
        Thu, 31 Jan 2019 03:30:00 -0800 (PST)
X-Google-Smtp-Source: ALg8bN47jlGbimXDm/0a1wHmJ7akbtBhlPq3w/B6a4bYN4BZoWtdytwE7KSK1cKjoOhFsuFKOIog
X-Received: by 2002:a1c:13d1:: with SMTP id 200mr28596687wmt.4.1548934198849;
        Thu, 31 Jan 2019 03:29:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548934198; cv=none;
        d=google.com; s=arc-20160816;
        b=rdPTsLS4oOuFu2IsQ8nTAw6ofATsd/i4ycVOrUEDfjZBmIZ0ZrUwypC5U6gzdiu6pk
         BXfU9GvbVYUvnaOcK6bCjEm5gdQtsP0RazAl0bRDVlK7TrkTD0ufJOu7NwZuYxbzByZu
         WWniJ08YTJgEicemsK8Ciu2DsHIiXfbNyodWzT6eerprkG5dD3DZqn0jxGlSl+t6IjhN
         aNEXYbiVi4NHHf2jlm35BxR43uUXarJ5/cxYuf/RL0JmoFbAY69K/FL6HXWmrRsHNfxK
         3MZaloafyU4kV7PLuXptxlcs0U809mw+JaNttSsYExBV7KokHgJtogeYUtzGu70IETxG
         UZ6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=pvDZBEHQP9vEk/hY31YWkOL84S0x4lR9x18fyrSrNy8=;
        b=axxxvmg+L14+937XyAOk64WSHhs2xpnvSyfM1x3zSRWl6f7NYngb+TE/3puUK8VcDL
         6UAiH5/oPx+6PXKK/g5rHCww+1g7WXcqDmbq8J7RNblxO/vrRk1sPURmlkh7/1Z1hg5f
         NPqBDT4J9gKGSvNum5inb9ZCBT8hkJX1E64rSP7OGW7gkaSbCS480JYAmWPiyJr0rlJ7
         Mgsdqp7WSPVfy5CgTMxKzOB4pA9f+jAasNwZTB+87Is1LHAQR+vszX5TVI8IKnTAjCTl
         1ywIXFaVnERZj9g/CeFz29w172FQFTNviHVD6IpmU/Wdk5rNHEBQEcchLprx/YLctpvI
         aA/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=NHfrC9Gx;
       spf=pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id e6si3103308wrq.242.2019.01.31.03.29.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 03:29:58 -0800 (PST)
Received-SPF: pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) client-ip=2a01:4f8:190:11c2::b:1457;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=NHfrC9Gx;
       spf=pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from zn.tnic (p200300EC2BCC59000D578CD19F54A2D7.dip0.t-ipconnect.de [IPv6:2003:ec:2bcc:5900:d57:8cd1:9f54:a2d7])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.skyhub.de (SuperMail on ZX Spectrum 128k) with ESMTPSA id D60D21EC027A;
	Thu, 31 Jan 2019 12:29:57 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=alien8.de; s=dkim;
	t=1548934198;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:in-reply-to:in-reply-to:  references:references;
	bh=pvDZBEHQP9vEk/hY31YWkOL84S0x4lR9x18fyrSrNy8=;
	b=NHfrC9Gx67nJi72GBFrjjsajVk7iywdi9/1xXraMGshYnbZwj/M+fXSJuZxh3AnaO9YLSJ
	PmdofcbVTIUGyqKBzoG590SOH3jmmyXkVl6AmHHrBD/62Ycau58bTvK1OAIXACqc1j0u1c
	urCYlYRfeLIgCEq6K6EWd3pXc+F34vs=
Date: Thu, 31 Jan 2019 12:29:48 +0100
From: Borislav Petkov <bp@alien8.de>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>,
	linux-kernel@vger.kernel.org, x86@kernel.org, hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>, linux_dti@icloud.com,
	linux-integrity@vger.kernel.org,
	linux-security-module@vger.kernel.org, akpm@linux-foundation.org,
	kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
	will.deacon@arm.com, ard.biesheuvel@linaro.org,
	kristen@linux.intel.com, deneen.t.dock@intel.com,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>, Nadav Amit <namit@vmware.com>
Subject: Re: [PATCH v2 03/20] x86/mm: temporary mm struct
Message-ID: <20190131112948.GE6749@zn.tnic>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
 <20190129003422.9328-4-rick.p.edgecombe@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190129003422.9328-4-rick.p.edgecombe@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> Subject: Re: [PATCH v2 03/20] x86/mm: temporary mm struct

Subject needs a verb: "Add a temporary... "

On Mon, Jan 28, 2019 at 04:34:05PM -0800, Rick Edgecombe wrote:
> From: Andy Lutomirski <luto@kernel.org>
> 
> Sometimes we want to set a temporary page-table entries (PTEs) in one of

s/a //

Also, drop the "we" and make it impartial and passive:

 "Describe your changes in imperative mood, e.g. "make xyzzy do frotz"
  instead of "[This patch] makes xyzzy do frotz" or "[I] changed xyzzy
  to do frotz", as if you are giving orders to the codebase to change
  its behaviour."

> the cores, without allowing other cores to use - even speculatively -
> these mappings. There are two benefits for doing so:
> 
> (1) Security: if sensitive PTEs are set, temporary mm prevents their use
> in other cores. This hardens the security as it prevents exploding a

exploding or exploiting? Or exposing? :)

> dangling pointer to overwrite sensitive data using the sensitive PTE.
> 
> (2) Avoiding TLB shootdowns: the PTEs do not need to be flushed in
> remote page-tables.

Those belong in the code comments below, explaining what it is going to
be used for.

> To do so a temporary mm_struct can be used. Mappings which are private
> for this mm can be set in the userspace part of the address-space.
> During the whole time in which the temporary mm is loaded, interrupts
> must be disabled.
> 
> The first use-case for temporary PTEs, which will follow, is for poking
> the kernel text.
> 
> [ Commit message was written by Nadav ]
> 
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
> Reviewed-by: Masami Hiramatsu <mhiramat@kernel.org>
> Tested-by: Masami Hiramatsu <mhiramat@kernel.org>
> Signed-off-by: Andy Lutomirski <luto@kernel.org>
> Signed-off-by: Nadav Amit <namit@vmware.com>
> Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
> ---
>  arch/x86/include/asm/mmu_context.h | 32 ++++++++++++++++++++++++++++++
>  1 file changed, 32 insertions(+)
> 
> diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
> index 19d18fae6ec6..cd0c29e494a6 100644
> --- a/arch/x86/include/asm/mmu_context.h
> +++ b/arch/x86/include/asm/mmu_context.h
> @@ -356,4 +356,36 @@ static inline unsigned long __get_current_cr3_fast(void)
>  	return cr3;
>  }
>  
> +typedef struct {

Why does it have to be a typedef?

That prev.prev below looks unnecessary, instead of just using prev.

> +	struct mm_struct *prev;

Why "prev"?

> +} temporary_mm_state_t;

That's kinda long - it is longer than the function name below.
temp_mm_state_t not enough?

> +
> +/*
> + * Using a temporary mm allows to set temporary mappings that are not accessible
> + * by other cores. Such mappings are needed to perform sensitive memory writes
> + * that override the kernel memory protections (e.g., W^X), without exposing the
> + * temporary page-table mappings that are required for these write operations to
> + * other cores.
> + *
> + * Context: The temporary mm needs to be used exclusively by a single core. To
> + *          harden security IRQs must be disabled while the temporary mm is
			      ^
			      ,

> + *          loaded, thereby preventing interrupt handler bugs from override the

s/override/overriding/

> + *          kernel memory protection.
> + */
> +static inline temporary_mm_state_t use_temporary_mm(struct mm_struct *mm)
> +{
> +	temporary_mm_state_t state;
> +
> +	lockdep_assert_irqs_disabled();
> +	state.prev = this_cpu_read(cpu_tlbstate.loaded_mm);
> +	switch_mm_irqs_off(NULL, mm, current);
> +	return state;
> +}
> +
> +static inline void unuse_temporary_mm(temporary_mm_state_t prev)
> +{
> +	lockdep_assert_irqs_disabled();
> +	switch_mm_irqs_off(NULL, prev.prev, current);
> +}
> +
>  #endif /* _ASM_X86_MMU_CONTEXT_H */
> -- 
> 2.17.1
> 

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

