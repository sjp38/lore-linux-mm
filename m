Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78ACCC282CE
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 18:22:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 36732218A4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 18:22:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=alien8.de header.i=@alien8.de header.b="S1eK1s2W"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 36732218A4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=alien8.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BCD0A8E0124; Mon, 11 Feb 2019 13:22:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA3C08E0115; Mon, 11 Feb 2019 13:22:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ABA0B8E0124; Mon, 11 Feb 2019 13:22:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 584E98E0115
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 13:22:30 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id e2so1934470wrv.16
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 10:22:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=mBrHsqt4hUkstq7VFx24ziqfy/NU+TGvc1tFvnBJ8PA=;
        b=Td7iQv83tZbV170EYcI4NM/B80ODAcWKvWvNmlLoNLEzwHo2F3DRC8DEJODy/6D0h4
         IwQxg54LhfVl/dya82s6ZdaxgLxcN3FFTdWZa695pJzBqU3wl+S83+0RBjT/S1YdAzd0
         xzoPf878wT/3nDLJMog94V3T8XkxMTkNn1LPRlXLQQH3n8SN6lPV/MQemmME/fUqpIJQ
         D4Hc48JRN0rDjdB/7vuNwzWNCMv2VaXpg6Ox+cYq+rGXqrVl/L17HoWGhJf3hVvBeYAf
         N0IG7ip1YAiIZ+vXQi6e5qoX84Xb5IMNUUgej9ujv4axk/n2Hx2vKlzXjZaZZhEmhHoI
         RD9Q==
X-Gm-Message-State: AHQUAubysMeBNr9frOics+n7YNJwb8KRyPhYjjcwK1WlYddHs2nZVD7P
	MvgqVuPQe5L4fiFjOcPBwCheexNFc2lAbi03PukoSE2pSLrCp6eOgIl7Gq0yBCItzXvekLf8V6N
	7S/Vm3h+Xu0xk3Zldzc/ZN4GPBJPaEuOI3OxFe2vTIOCWN/B1bCjMRwFCV4/XePrk7w==
X-Received: by 2002:a1c:740d:: with SMTP id p13mr676656wmc.46.1549909349861;
        Mon, 11 Feb 2019 10:22:29 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZI3DMpxoIwokMUsR7h2tmYeC9ONWYCmaa7x/ZSF8dBCGnrCdX1gXM9cXWDnAEl/81NtQrA
X-Received: by 2002:a1c:740d:: with SMTP id p13mr676602wmc.46.1549909348992;
        Mon, 11 Feb 2019 10:22:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549909348; cv=none;
        d=google.com; s=arc-20160816;
        b=YOVAJuzJ0H8+EpyZbueYwaalCHS1MOlwWWGg305kWDjFcKHBBmxkTsaAvEPI9u96iW
         ELEoFpN2Q7RqoH8B8kdndvxaH2XrO4+5qyAoqG1pbXnYCaX3VAomVAUhUWPHIncxRQqd
         73zDhC9HiisWu5fZexI+Mhlt8iDK5l6AFWNSVPw+3ATDoPIPufx0jNJ5whMgjcjdwcCm
         IHJ0OybREv6FuvHzaJ0LX93e+BIwpM+TEHMErni6bhhnVw0nUzvRnzD8B2X2U8JQEn14
         NGaTq6qdp/3+zvUNTAp7I3VrhoNp//XWdnMjeQe7Ul/Eqs4e0n3w6ShjjdKtbLJQiSWy
         YiNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=mBrHsqt4hUkstq7VFx24ziqfy/NU+TGvc1tFvnBJ8PA=;
        b=irHb+FMGMQchIm6klGyhIVLdjZ1P1gpPWmUs1NFnA9wczV1xOJhPRwN9AFxqloPYMQ
         GMJ0cXcns4W2o43n9Mk4DfDJoy1sBSv52O0cazxwkG4YJG9SB1RYS67hlECVMFKyeRa8
         pYSXVB3S4oY69FKMoMtE+Ws72lgT6moiXU0l6a4rpEezWBhcGsDKEeCEtx4tP8MGDQ9w
         zHc9HuSu+YnFtqbLKf8ZynjzFfH2jTrlh6VCU562+I6mjg/Gra5o6CkUto4WPQvHu73L
         MAsVmqEIVRM5AKaLEBpzKZZq34ODiv7Z/xzOMffxWvvi/ImutJc0LU6fp3wCu6ew2U4r
         r6UQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=S1eK1s2W;
       spf=pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id o12si4066587wrm.393.2019.02.11.10.22.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 10:22:28 -0800 (PST)
Received-SPF: pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) client-ip=2a01:4f8:190:11c2::b:1457;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=S1eK1s2W;
       spf=pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from zn.tnic (p200300EC2BC7A10074DEFDFE3AD6CF32.dip0.t-ipconnect.de [IPv6:2003:ec:2bc7:a100:74de:fdfe:3ad6:cf32])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.skyhub.de (SuperMail on ZX Spectrum 128k) with ESMTPSA id D5B721EC01B6;
	Mon, 11 Feb 2019 19:22:27 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=alien8.de; s=dkim;
	t=1549909348;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:in-reply-to:in-reply-to:  references:references;
	bh=mBrHsqt4hUkstq7VFx24ziqfy/NU+TGvc1tFvnBJ8PA=;
	b=S1eK1s2WDNc/02K3VAa86oPXXo4XoDwFmtP0wbeZYty5vAp9mprYozKcOct+xRxW15U4++
	c3/M3JS0QgDRn5peV2kEMuTIRbxVT2WR5+ldKaRyWQt5dV1T85uygPXDKqWdlXpoIgzsRL
	kYmIwrctHP4YCZkqztXDQC87SbD3/S8=
Date: Mon, 11 Feb 2019 19:22:21 +0100
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
	Nadav Amit <namit@vmware.com>
Subject: Re: [PATCH v2 09/20] x86/kprobes: instruction pages initialization
 enhancements
Message-ID: <20190211182221.GM19618@zn.tnic>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
 <20190129003422.9328-10-rick.p.edgecombe@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190129003422.9328-10-rick.p.edgecombe@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Only nitpicks:

> Subject: Re: [PATCH v2 09/20] x86/kprobes: instruction pages initialization enhancements

Subject needs a verb.

On Mon, Jan 28, 2019 at 04:34:11PM -0800, Rick Edgecombe wrote:
> From: Nadav Amit <namit@vmware.com>
> 
> Make kprobes instruction pages read-only (and executable) after they are
> set to prevent them from mistaken or malicious modifications.
> 
> This is a preparatory patch for a following patch that makes module
> allocated pages non-executable and sets the page as executable after
> allocation.
> 
> While at it, do some small cleanup of what appears to be unnecessary
> masking.
> 
> Acked-by: Masami Hiramatsu <mhiramat@kernel.org>
> Signed-off-by: Nadav Amit <namit@vmware.com>
> Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
> ---
>  arch/x86/kernel/kprobes/core.c | 24 ++++++++++++++++++++----
>  1 file changed, 20 insertions(+), 4 deletions(-)
> 
> diff --git a/arch/x86/kernel/kprobes/core.c b/arch/x86/kernel/kprobes/core.c
> index 4ba75afba527..fac692e36833 100644
> --- a/arch/x86/kernel/kprobes/core.c
> +++ b/arch/x86/kernel/kprobes/core.c
> @@ -431,8 +431,20 @@ void *alloc_insn_page(void)
>  	void *page;
>  
>  	page = module_alloc(PAGE_SIZE);
> -	if (page)
> -		set_memory_ro((unsigned long)page & PAGE_MASK, 1);
> +	if (page == NULL)
> +		return NULL;

Null tests we generally do like this:

	if (! ...


like in the rest of this file.

> +
> +	/*
> +	 * First make the page read-only, and then only then make it executable

 s/then only then/only then/

ditto below.

> +	 * to prevent it from being W+X in between.
> +	 */
> +	set_memory_ro((unsigned long)page, 1);
> +
> +	/*
> +	 * TODO: Once additional kernel code protection mechanisms are set, ensure
> +	 * that the page was not maliciously altered and it is still zeroed.
> +	 */
> +	set_memory_x((unsigned long)page, 1);
>  
>  	return page;
>  }
> @@ -440,8 +452,12 @@ void *alloc_insn_page(void)
>  /* Recover page to RW mode before releasing it */
>  void free_insn_page(void *page)
>  {
> -	set_memory_nx((unsigned long)page & PAGE_MASK, 1);
> -	set_memory_rw((unsigned long)page & PAGE_MASK, 1);
> +	/*
> +	 * First make the page non-executable, and then only then make it
> +	 * writable to prevent it from being W+X in between.
> +	 */
> +	set_memory_nx((unsigned long)page, 1);
> +	set_memory_rw((unsigned long)page, 1);
>  	module_memfree(page);
>  }
>  
> -- 

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

