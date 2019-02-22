Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 354CEC00319
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 00:07:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EFAE920836
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 00:07:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EFAE920836
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 842CD8E00DA; Thu, 21 Feb 2019 19:07:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7F10F8E00B3; Thu, 21 Feb 2019 19:07:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6E0D38E00DA; Thu, 21 Feb 2019 19:07:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2C76C8E00B3
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 19:07:34 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id q20so356181pls.4
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 16:07:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=P8JsvyuTeV95oN2cdDuyxWbaN4eesR1ynRYIfHEY59g=;
        b=PhhOtSJdNB22NEQeYQnPYVhQOD+DoC8ASEoaDj2eeKvjNYRr4cRn/6VOU3+4jN+R1b
         f/bP9PuQJblf4u6ddHMTKE/w/Lw987K9vGOwWGJ8mrNAUD5o84DN9dISWRbDrtAeKa/o
         ovKEb44JVzJFEelk7Var11LnO42wLvlb2EfrI0aOs3CTjkMpkoYqYiZjLQA+R6ZDn3he
         ndCqnZ5UbhimwWFB2xkGmYCkB6OEB15DyBmlyyreMoL4ACCAeChMGgFZOFRctIXf1qKH
         /t2qs/LAw6G1yShinZyUCDw2n7kOsVq10oGSpNfCGcsQWnzfgAR3TUzdidOhtFAjpscW
         C6vg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of sean.j.christopherson@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=sean.j.christopherson@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuYa0Btty/nBKqvj5dh75x59D3Y0G+QlVFeFC251+rUhjTY3ycpA
	+5PFqkfW2/2etPhqo/0wQ/Sm47ZSJBrg85oSc2sInqS8l8dMRHo1+T1p65nuJ1mbTgCxxHn+n2Z
	gG2f14cXVa/hiGtPLufciGjW7vlCVCKhNL/rb50TgswH8NwhvtjEWNPzPDtH7Ny63+g==
X-Received: by 2002:a17:902:b20e:: with SMTP id t14mr1198442plr.97.1550794053834;
        Thu, 21 Feb 2019 16:07:33 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZFVpVDMArYb96i6WI1TTIJfLtWY8sH9FqMVDSMP0A8hL3MEQ9zUuwu2N32fwMuywNDAbAt
X-Received: by 2002:a17:902:b20e:: with SMTP id t14mr1198393plr.97.1550794053053;
        Thu, 21 Feb 2019 16:07:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550794053; cv=none;
        d=google.com; s=arc-20160816;
        b=pLAmcel7wOt4FP99bP+JBHv+JkuBUWyMkX2sDEdJTmJUAoS16iVks+a1Wrq8pgayAR
         kHXA8MSlMP8nL7lbDM3pRmQ8GNkIs5HK8bOSTXGxQ4qBEspZlYeEvlrxAxr8UvK0onEq
         518Fn6qoA4XqxO38yoA4oS9N/fQOljacrg4B1sHH0oEMYk9lUFnt6ZWOFZwNTsfY5nCS
         zgD5Z1RsQxreE2hKBmJBeQBUPtT34YNl9wfh4WurmosnZfXCPCtS3fiUuZRWzqPGYLvR
         izxP63mn5Dbc8RzYZfvRabyAqtQ5e+gPIe+qC9zrDa3lr8R64O07rKxwljq4pc8Q2+ai
         rT4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=P8JsvyuTeV95oN2cdDuyxWbaN4eesR1ynRYIfHEY59g=;
        b=ShlyoFjIDOQh87Unk1iU9H4e6IeUe2MMLDQSzLI5FcqgfXbxHOoup3t0ttLY8tRApd
         S140PgzOiEe5+oiz8rTV+nfrJTJ3SR+MpQJBP55Ad3AwaXTLQpV8jdo82K3Jt4qFr6Ig
         OZ8y/BjzM55/4lPZAKeIQAFu7n+FH4RITAX+80QjheFeu2CTSOc4OToFnTOwZXo6RpDl
         rOeeo6hpv+r3Y+7zAr0nyy+WI79Tb28k8/s4l2Y68LPa3kSi5vJG0UqkqB6xtzJAsjhH
         rO0cItYvRC1gyXtvSPB779EJyoLJ/vfkh6EWRHfJ2791R2sOTuIcVXHGEQe+4BHzPiL7
         cwTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of sean.j.christopherson@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=sean.j.christopherson@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id s2si226478pfm.289.2019.02.21.16.07.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 16:07:33 -0800 (PST)
Received-SPF: pass (google.com: domain of sean.j.christopherson@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of sean.j.christopherson@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=sean.j.christopherson@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 21 Feb 2019 16:07:32 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,397,1544515200"; 
   d="scan'208";a="145517897"
Received: from sjchrist-coffee.jf.intel.com (HELO linux.intel.com) ([10.54.74.181])
  by fmsmga002.fm.intel.com with ESMTP; 21 Feb 2019 16:07:31 -0800
Date: Thu, 21 Feb 2019 16:07:31 -0800
From: Sean Christopherson <sean.j.christopherson@intel.com>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>,
	linux-kernel@vger.kernel.org, x86@kernel.org, hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Borislav Petkov <bp@alien8.de>, Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>, linux_dti@icloud.com,
	linux-integrity@vger.kernel.org,
	linux-security-module@vger.kernel.org, akpm@linux-foundation.org,
	kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
	will.deacon@arm.com, ard.biesheuvel@linaro.org,
	kristen@linux.intel.com, deneen.t.dock@intel.com,
	Nadav Amit <namit@vmware.com>
Subject: Re: [PATCH v3 03/20] x86/mm: Save DRs when loading a temporary mm
Message-ID: <20190222000731.GE7224@linux.intel.com>
References: <20190221234451.17632-1-rick.p.edgecombe@intel.com>
 <20190221234451.17632-4-rick.p.edgecombe@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190221234451.17632-4-rick.p.edgecombe@intel.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 21, 2019 at 03:44:34PM -0800, Rick Edgecombe wrote:
> From: Nadav Amit <namit@vmware.com>
> 
> Prevent user watchpoints from mistakenly firing while the temporary mm
> is being used. As the addresses that of the temporary mm might overlap
> those of the user-process, this is necessary to prevent wrong signals
> or worse things from happening.
> 
> Cc: Andy Lutomirski <luto@kernel.org>
> Signed-off-by: Nadav Amit <namit@vmware.com>
> ---
>  arch/x86/include/asm/mmu_context.h | 25 +++++++++++++++++++++++++
>  1 file changed, 25 insertions(+)
> 
> diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
> index d684b954f3c0..0d6c72ece750 100644
> --- a/arch/x86/include/asm/mmu_context.h
> +++ b/arch/x86/include/asm/mmu_context.h
> @@ -13,6 +13,7 @@
>  #include <asm/tlbflush.h>
>  #include <asm/paravirt.h>
>  #include <asm/mpx.h>
> +#include <asm/debugreg.h>
>  
>  extern atomic64_t last_mm_ctx_id;
>  
> @@ -358,6 +359,7 @@ static inline unsigned long __get_current_cr3_fast(void)
>  
>  typedef struct {
>  	struct mm_struct *prev;
> +	unsigned short bp_enabled : 1;
>  } temp_mm_state_t;
>  
>  /*
> @@ -380,6 +382,22 @@ static inline temp_mm_state_t use_temporary_mm(struct mm_struct *mm)
>  	lockdep_assert_irqs_disabled();
>  	state.prev = this_cpu_read(cpu_tlbstate.loaded_mm);
>  	switch_mm_irqs_off(NULL, mm, current);
> +
> +	/*
> +	 * If breakpoints are enabled, disable them while the temporary mm is
> +	 * used. Userspace might set up watchpoints on addresses that are used
> +	 * in the temporary mm, which would lead to wrong signals being sent or
> +	 * crashes.
> +	 *
> +	 * Note that breakpoints are not disabled selectively, which also causes
> +	 * kernel breakpoints (e.g., perf's) to be disabled. This might be
> +	 * undesirable, but still seems reasonable as the code that runs in the
> +	 * temporary mm should be short.
> +	 */
> +	state.bp_enabled = hw_breakpoint_active();

Pretty sure caching hw_breakpoint_active() is unnecessary.  It queries a
per-cpu value, not hardware's DR7 register, and that same value is
consumed by hw_breakpoint_restore().  No idea if breakpoints can be
disabled while using a temp mm, but even if that can happen, there's no
need to restore breakpoints if they've all been disabled, i.e. if
hw_breakpoint_active() returns false in unuse_temporary_mm().

> +	if (state.bp_enabled)
> +		hw_breakpoint_disable();
> +
>  	return state;
>  }
>  
> @@ -387,6 +405,13 @@ static inline void unuse_temporary_mm(temp_mm_state_t prev)
>  {
>  	lockdep_assert_irqs_disabled();
>  	switch_mm_irqs_off(NULL, prev.prev, current);
> +
> +	/*
> +	 * Restore the breakpoints if they were disabled before the temporary mm
> +	 * was loaded.
> +	 */
> +	if (prev.bp_enabled)
> +		hw_breakpoint_restore();
>  }
>  
>  #endif /* _ASM_X86_MMU_CONTEXT_H */
> -- 
> 2.17.1
> 

