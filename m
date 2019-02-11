Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AF389C282CE
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 18:30:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6E16621B25
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 18:30:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=alien8.de header.i=@alien8.de header.b="dj10XbPz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6E16621B25
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=alien8.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0077A8E0128; Mon, 11 Feb 2019 13:30:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EF9548E0126; Mon, 11 Feb 2019 13:30:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE8A58E0128; Mon, 11 Feb 2019 13:30:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 859788E0126
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 13:30:00 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id q18so2005455wrx.0
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 10:30:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Yw+RK9f/S+johjl1gYKTeZptuEY0P9nfhJd0XlVQGCo=;
        b=ugKuFNzZy6tHUF7p4AQVUK2kbd7TsjInqOCys3Zly/Dfj873aNS91hIzSLK9Y0F9EU
         UVRVfhMt8bC6bjTCkdWnvcbrhbPqLhEaJvebHlA2m+hMM1EHjFDaMMgZwdkvnSGksT0x
         joWqZWmXAjVo3iwFSP+nIqrb23p4bhDapAYq3tHvnjoA78qgCDGbwmEhkTenT/KzW9ZF
         x6pSEJWl4JWIyZ+XVtCDUzB6Dhm6eaBX6cfORSnu7MLoWUsfFcv5ZB7NZf7dBKZu6KrE
         /B21DwvP/Wj4YDGVnoNW7rm3NcmhwWSzSNNQss0RZeLXL7fz/6J9qftkBUDu5dGRtaYv
         GCYQ==
X-Gm-Message-State: AHQUAua9lCeY/g+yw6v8b0iYWXfTb570v9qTOxqBWUjmxZTFtT/sGoGe
	g/8YSuQH6TZ8fSx/+2V7aOthTDfODvIoIthFRFWEsXkqzZ+kzVByV5bO7siPQvKnJhB7uxHrYTb
	LdhPHOOTn2nFucWO46OXFPdAGm7+uYxyk2gKOuD7BY1yDFBGv/nRTuwr8FwBsjPYaNQ==
X-Received: by 2002:adf:efc8:: with SMTP id i8mr8949566wrp.164.1549909800010;
        Mon, 11 Feb 2019 10:30:00 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZUNAmGiy/j9LJRONXEZ1ki309eZUW5Kl0rJMXltmCosggx8P6UU6i6cnD9Dk9cgS8jL82T
X-Received: by 2002:adf:efc8:: with SMTP id i8mr8949515wrp.164.1549909799086;
        Mon, 11 Feb 2019 10:29:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549909799; cv=none;
        d=google.com; s=arc-20160816;
        b=rq6qqnbYAGAIvczdpHK5Y643CFhXupbIP2hVFAYcnW6fxbdgQqJAnvGOxMrgUnvfOe
         xv2Zz/kXNgcfkkka0Qm3ZujHJQkVwwZ7bFHubH7fFQQGywcw7CggW10PvaQYQHAztZtq
         dj4hUoMzKlqEtm1e+F64Gx9tGpTERK75ZZYmVDHenCSyFHlDI3iXHZD3nR7SIAxGP2tA
         6Sc0DDvdCImlg6RL8c1MhuZFP5x18FEHXkXK2w3DITKMRcBHB8+yxkViSqsDmEmBaWh4
         aN7xgGjl++chg7dw9OUeUyIFicykE6XqLl/LjZPbPQcdpr9qR7dQtDbXQqMat2qnQyw0
         Vdkw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Yw+RK9f/S+johjl1gYKTeZptuEY0P9nfhJd0XlVQGCo=;
        b=1FpTAsbiQ4HCeHGpkD2JWWL6KKTCz5QP5gFWLuAhAI8fEEDb0vTg4eXLIeZIP+t5c+
         GxdTQBwMv7B7RQAlQJ8dd4nbmndEeQ2IG1FjeEPHTodQ7t65B3dDk5f1nxUPZSmFldp6
         820DKK/gWvkC2STVryLTVxqgC+FXw0CFEz/gOv9dsx9SCePboQBxsVzTOyDZSXX1GlzV
         GT/IWlSQ0+Unt4oKHOKFj04NwXD8Maz7rqqwdags0VOfaPenkEysAMzDZwKtZPwzTHpK
         SfHOUiqeXkGCHc3hLM/USB8G5HUivZgHex8GSi2vtT77v0ZjUJ4BtHBpwTNqDhajeIM7
         v9Pw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=dj10XbPz;
       spf=pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id x1si7579989wru.294.2019.02.11.10.29.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 10:29:59 -0800 (PST)
Received-SPF: pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) client-ip=2a01:4f8:190:11c2::b:1457;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=dj10XbPz;
       spf=pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from zn.tnic (p200300EC2BC7A10074DEFDFE3AD6CF32.dip0.t-ipconnect.de [IPv6:2003:ec:2bc7:a100:74de:fdfe:3ad6:cf32])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.skyhub.de (SuperMail on ZX Spectrum 128k) with ESMTPSA id 1C0D71EC037B;
	Mon, 11 Feb 2019 19:29:58 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=alien8.de; s=dkim;
	t=1549909798;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:in-reply-to:in-reply-to:  references:references;
	bh=Yw+RK9f/S+johjl1gYKTeZptuEY0P9nfhJd0XlVQGCo=;
	b=dj10XbPzFbFnu9Nya4W5OkkNbXxJnnkj4Hr1SOpZ2asDUWMbDzAbKRWRj/tjz/qk4tl7WJ
	0em21jvddg2A3nLTY/GpXAXUxfmJCaIUKjSFW1JC6HHKlJLE1/k9VIlZrqJLUkJ0JPA/M4
	LmZjPdIjqu1x0Cyl6ehJazATSPz8JTc=
Date: Mon, 11 Feb 2019 19:29:56 +0100
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
	Nadav Amit <namit@vmware.com>, Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Masami Hiramatsu <mhiramat@kernel.org>
Subject: Re: [PATCH v2 10/20] x86: avoid W^X being broken during modules
 loading
Message-ID: <20190211182956.GN19618@zn.tnic>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
 <20190129003422.9328-11-rick.p.edgecombe@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190129003422.9328-11-rick.p.edgecombe@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> Subject: Re: [PATCH v2 10/20] x86: avoid W^X being broken during modules loading

For your next submission, please fix all your subjects:

The tip tree preferred format for patch subject prefixes is
'subsys/component:', e.g. 'x86/apic:', 'x86/mm/fault:', 'sched/fair:',
'genirq/core:'. Please do not use file names or complete file paths as
prefix. 'git log path/to/file' should give you a reasonable hint in most
cases.

The condensed patch description in the subject line should start with a
uppercase letter and should be written in imperative tone.


On Mon, Jan 28, 2019 at 04:34:12PM -0800, Rick Edgecombe wrote:
> From: Nadav Amit <namit@vmware.com>
> 
> When modules and BPF filters are loaded, there is a time window in
> which some memory is both writable and executable. An attacker that has
> already found another vulnerability (e.g., a dangling pointer) might be
> able to exploit this behavior to overwrite kernel code.
> 
> Prevent having writable executable PTEs in this stage. In addition,
> avoiding having W+X mappings can also slightly simplify the patching of
> modules code on initialization (e.g., by alternatives and static-key),
> as would be done in the next patch.
> 
> To avoid having W+X mappings, set them initially as RW (NX) and after
> they are set as RO set them as X as well. Setting them as executable is
> done as a separate step to avoid one core in which the old PTE is cached
> (hence writable), and another which sees the updated PTE (executable),
> which would break the W^X protection.
> 
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Masami Hiramatsu <mhiramat@kernel.org>
> Suggested-by: Thomas Gleixner <tglx@linutronix.de>
> Suggested-by: Andy Lutomirski <luto@amacapital.net>
> Signed-off-by: Nadav Amit <namit@vmware.com>
> Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
> ---
>  arch/x86/kernel/alternative.c | 28 +++++++++++++++++++++-------
>  arch/x86/kernel/module.c      |  2 +-
>  include/linux/filter.h        |  2 +-
>  kernel/module.c               |  5 +++++
>  4 files changed, 28 insertions(+), 9 deletions(-)
> 
> diff --git a/arch/x86/kernel/alternative.c b/arch/x86/kernel/alternative.c
> index 76d482a2b716..69f3e650ada8 100644
> --- a/arch/x86/kernel/alternative.c
> +++ b/arch/x86/kernel/alternative.c
> @@ -667,15 +667,29 @@ void __init alternative_instructions(void)
>   * handlers seeing an inconsistent instruction while you patch.
>   */
>  void *__init_or_module text_poke_early(void *addr, const void *opcode,
> -					      size_t len)
> +				       size_t len)
>  {
>  	unsigned long flags;
> -	local_irq_save(flags);
> -	memcpy(addr, opcode, len);
> -	local_irq_restore(flags);
> -	sync_core();
> -	/* Could also do a CLFLUSH here to speed up CPU recovery; but
> -	   that causes hangs on some VIA CPUs. */
> +
> +	if (static_cpu_has(X86_FEATURE_NX) &&

Not a fast path - boot_cpu_has() is fine here.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

