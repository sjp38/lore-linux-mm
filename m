Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37ABDC4360F
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 00:22:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E7AE62083E
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 00:22:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E7AE62083E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=goodmis.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 79A088E00DB; Thu, 21 Feb 2019 19:22:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7229B8E00D4; Thu, 21 Feb 2019 19:22:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C4628E00DB; Thu, 21 Feb 2019 19:22:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 18D6E8E00D4
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 19:22:15 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id s22so376823plq.7
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 16:22:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=n1prsKbkoxxdtD4zxhDoVWYDC3zm+GcNPoq5ImzQ2UA=;
        b=DEywY08N84mEcqQ0hu+tQEJed79fj9wyphUOMjOgnftsgF2tIWvtygyH4IXyc/QHdy
         7S6OPLi8+aHmZsTh+9O3RFSSGn7SKkg6HbOpgE5aIG00O7yJ4QizNNSQtEQTqIAelX2n
         29zBgOnZ4wvMWPupCeyN3NaZ1tU0W5GrkFxeld4tyckXeOVblP76d4cp9fi2qEaiE8uk
         qzxteoAaRw/FZqkph4KDIqAxDNGk8tsihuBEdeH40qB81zRiccpRKUBHdJALCWZ/+ShH
         umL9eXVyJO57RGL/2Z2fAG8HK3g/r1WVPwFYm3KxBrntP6yjAPVNR/L1yFiVJqYW/NsN
         hTNQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of srs0=9cm4=q5=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=9Cm4=Q5=goodmis.org=rostedt@kernel.org"
X-Gm-Message-State: AHQUAua+UlereUC0jghpt9XQrtcAjPqzFSCvrE+P2dyEEFoYoOj5S0xw
	lUEs+hyIlM/yihtBZnX2u5OtuQZDLcxYlKf7fu+kpuPY4PjHQtKRM9OzhCnnU5GCEFxPvk5SEZ6
	vgn45JVIrakrMBBAfjvslH4oiMx0lCIEuKKxR6CESrAuYRqadZ8i4HC9UWli2f+4=
X-Received: by 2002:a17:902:758f:: with SMTP id j15mr1348318pll.66.1550794934751;
        Thu, 21 Feb 2019 16:22:14 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYGxvJXtmHkJUg2+m780Yd42L5R9C6mlziokINvVLRJCZEc1bjHkdtpFPNGfEo6qGzV6i3y
X-Received: by 2002:a17:902:758f:: with SMTP id j15mr1348278pll.66.1550794933975;
        Thu, 21 Feb 2019 16:22:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550794933; cv=none;
        d=google.com; s=arc-20160816;
        b=eujnC0TuR9nOFlJdzQEiJU+WGwCAxv33Kj+EoG1cRlvEvj/JM5fnAfoT2YvtUdV3fX
         IsuUqGf3edMwH7gGEzbI0xxNQ8idxef3EvBiH2y/Hligttx9nWYiEuBpD1Vt/WIZL2YO
         qDPkFaTo2OZWH8le2hca4JnLVc520dQsdaELm9B/6EzFwZHka3V3kNHKxdnzEcM6hIkF
         n0djuvkAyh5M4BShhdBntUpLUt2zu9ZIPbmlzLAi/LWWv2YTpcd4UA7TRfYaa9KXoqLe
         gzA07KTgCteHSZ4fxz0UegK7qsT1c5Ja8WnpakpB26+T3l8Bml06ZXgRChE36RqtgTZS
         VUlg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=n1prsKbkoxxdtD4zxhDoVWYDC3zm+GcNPoq5ImzQ2UA=;
        b=PaeYfkvqqPgbw0HgSCMYEl2wbbDijhqeuoP2AL/EVcto0/geomcEH5dpR2TItowbJZ
         R6QZq+Po2h+w10qS6oL5eP54V2xIqNV5m9mfnPXrmvMqUyxrG6AG07QxlNa8NU70C7on
         kthzjByhj4wzXfIC09kBDObvp4GUcPDhFNcmuasO5N+OzLxWuDNl0KaezMgz3DbDibjc
         DYvVYckcco+jleqKdofS46AkoMuSSb9yzytWwZs7GyA6+hl1p2qZHnHmTAo6y/aGBJyj
         +KcnB0KqhKlgS5X1GyFSOBHeRdOJJRfLgdgVxbW9V9GtP7q/Y2i6Kw30wtJ+ydvqRXMH
         hNZw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of srs0=9cm4=q5=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=9Cm4=Q5=goodmis.org=rostedt@kernel.org"
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id r73si293633pfb.221.2019.02.21.16.22.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 16:22:13 -0800 (PST)
Received-SPF: pass (google.com: domain of srs0=9cm4=q5=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of srs0=9cm4=q5=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=9Cm4=Q5=goodmis.org=rostedt@kernel.org"
Received: from gandalf.local.home (cpe-66-24-58-225.stny.res.rr.com [66.24.58.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id BF0422080F;
	Fri, 22 Feb 2019 00:22:11 +0000 (UTC)
Date: Thu, 21 Feb 2019 19:22:10 -0500
From: Steven Rostedt <rostedt@goodmis.org>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>,
 linux-kernel@vger.kernel.org, x86@kernel.org, hpa@zytor.com, Thomas
 Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Nadav Amit
 <nadav.amit@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Peter
 Zijlstra <peterz@infradead.org>, linux_dti@icloud.com,
 linux-integrity@vger.kernel.org, linux-security-module@vger.kernel.org,
 akpm@linux-foundation.org, kernel-hardening@lists.openwall.com,
 linux-mm@kvack.org, will.deacon@arm.com, ard.biesheuvel@linaro.org,
 kristen@linux.intel.com, deneen.t.dock@intel.com
Subject: Re: [PATCH v3 18/20] x86/ftrace: Use vmalloc special flag
Message-ID: <20190221192210.3e038fc3@gandalf.local.home>
In-Reply-To: <20190221234451.17632-19-rick.p.edgecombe@intel.com>
References: <20190221234451.17632-1-rick.p.edgecombe@intel.com>
	<20190221234451.17632-19-rick.p.edgecombe@intel.com>
X-Mailer: Claws Mail 3.16.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 21 Feb 2019 15:44:49 -0800
Rick Edgecombe <rick.p.edgecombe@intel.com> wrote:

> Use new flag VM_FLUSH_RESET_PERMS for handling freeing of special
> permissioned memory in vmalloc and remove places where memory was set NX
> and RW before freeing which is no longer needed.
> 
> Cc: Steven Rostedt <rostedt@goodmis.org>
> Acked-by: Steven Rostedt (VMware) <rostedt@goodmis.org>
> Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
> ---
>  arch/x86/kernel/ftrace.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/arch/x86/kernel/ftrace.c b/arch/x86/kernel/ftrace.c
> index 13c8249b197f..93efe3955333 100644
> --- a/arch/x86/kernel/ftrace.c
> +++ b/arch/x86/kernel/ftrace.c
> @@ -692,10 +692,6 @@ static inline void *alloc_tramp(unsigned long size)
>  }
>  static inline void tramp_free(void *tramp, int size)

As size is no longer used within the function, can you remove that too.

Thanks,

-- Steve

>  {
> -	int npages = PAGE_ALIGN(size) >> PAGE_SHIFT;
> -
> -	set_memory_nx((unsigned long)tramp, npages);
> -	set_memory_rw((unsigned long)tramp, npages);
>  	module_memfree(tramp);
>  }
>  #else
> @@ -820,6 +816,8 @@ create_trampoline(struct ftrace_ops *ops, unsigned int *tramp_size)
>  	/* ALLOC_TRAMP flags lets us know we created it */
>  	ops->flags |= FTRACE_OPS_FL_ALLOC_TRAMP;
>  
> +	set_vm_flush_reset_perms(trampoline);
> +
>  	/*
>  	 * Module allocation needs to be completed by making the page
>  	 * executable. The page is still writable, which is a security hazard,

