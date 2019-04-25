Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67553C4321B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 18:28:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C197320891
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 18:28:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C197320891
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=goodmis.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E72856B0003; Thu, 25 Apr 2019 14:28:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DF8E66B0005; Thu, 25 Apr 2019 14:28:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C9D336B0006; Thu, 25 Apr 2019 14:28:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8A0926B0003
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 14:28:08 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id s19so281998plp.6
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 11:28:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=XxG05rJDa5fG85rmeev2w2HQKqVZaPXeBK/QpvFWlRw=;
        b=Ndy3qHE0iQIhEn3ObxqzVivuT/L6WukaQ1nZuts1xFrScH2mtBSrFKyFnogG0SFOal
         zKc/hNqHnMly90Cf9GvSV9aDvl9BfaFemRdyrqPAUCr4qsly0UpsEOf1Y147+l2iHwvL
         faipt/qMvH0GKvG0kdExpu1jo1mK8mWE8rvFC2U7RspoHXuYldrW4JZ64QV+xVQLQhWO
         MzBOKYYMIFTw3+H4bw+9PkdGL57Bb4PcfAyp5msHg5TJMK0+FUwUHgSQh2M+HSqGkljp
         8Vqqo3Rk+OSwF4GpcboEBj+XFnwrq2eh4QvYhg7xrRJJZbT9fXE5BPk8FuInwUS9r0kO
         +ssg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of srs0=6pif=s3=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=6pIF=S3=goodmis.org=rostedt@kernel.org"
X-Gm-Message-State: APjAAAVGwrKdf/u+8PW4kAIoHac42K5mqls4Kwr7/WmzcQM8EDMIoRXP
	+rI4zWL0RVYLUAQM2/mKorbw9Z969TBs3wgx+mS+3xqJDx+HHWhB7IKWtUwGUajUzoJVwPanHsk
	A8QGVWW5sg3KfxsxkQ1XQhsGJX5gf5fQeH5OtlLKGsdEv8U+Bak8yl1ZUbwi2zGg=
X-Received: by 2002:a63:6e01:: with SMTP id j1mr39033401pgc.442.1556216888014;
        Thu, 25 Apr 2019 11:28:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwnvITcNfKbYuzHjytaSat2waLM+hJK8XswVgnThPmzXra9PIAZ+j+l6b8HhFPfHGqSp6Pk
X-Received: by 2002:a63:6e01:: with SMTP id j1mr39033328pgc.442.1556216887209;
        Thu, 25 Apr 2019 11:28:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556216887; cv=none;
        d=google.com; s=arc-20160816;
        b=fmyHwDrXPtJKxlbi1V99DxNlEyr7YvhrGzjwC/n5iVRGEUsxQ8T2puStYQ0y6sy6fR
         6BMI6XOZlSkrND9XjqQ4adfbuT9y/ptKnVHEQJeh6gIwnyWns2F+edYrg9jsbuwDTiQb
         z3Gb+1qsIxvPJEdwzvzGtrEoRx3nmj/Cbm0HZItR0S3Hs/Pdn36Ijt8+1tCM3nwOKxvU
         arqvvLPs4Q8SeCRUTfV/UddgFUHyhcSF7UNXUTaFSJG7d30ao+qxtBXDXOY0/rpYFRGH
         iCF+tR6a7Sn+QXCrKvNBsZRnls5hBYeXPgqSWTKEy9ImcxvK8d70bcOGGN7P6FlVx43U
         FuZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=XxG05rJDa5fG85rmeev2w2HQKqVZaPXeBK/QpvFWlRw=;
        b=Ye2JY9DZBw5rSZq8nUvo6IrtgqwmSXpMcsQNOsXzmlNBVCLdiOIqGnSLgUtwY6+x0T
         nQDikbhQih+MERjkKkwc+ZL+K2fh/8KOVdmflzUiutruukZMxtY9tg3R/lD6xa+VbsuQ
         fHuR7tgBaT7Djt0NjVzx0h9nU8bE7cAl+PebCf+5HwKz16nnlki5fY/cMsYVe0msfvcF
         aonCuy6mMiG2BttRs9iYPn0WgbJsESzIQfeeSJ5wYNPRiqpCmdihwRTlMqN28P/eqziu
         j/Rav5cc1as8vtXtnN3//ttoQtvN0tb+LOndvdgLUgTcAU47HmFQXHvJ38AKCYZO59l0
         BnvA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of srs0=6pif=s3=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=6pIF=S3=goodmis.org=rostedt@kernel.org"
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d37si21416083plb.401.2019.04.25.11.28.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 11:28:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of srs0=6pif=s3=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of srs0=6pif=s3=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=6pIF=S3=goodmis.org=rostedt@kernel.org"
Received: from gandalf.local.home (cpe-66-24-58-225.stny.res.rr.com [66.24.58.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id CAC8E2067C;
	Thu, 25 Apr 2019 18:28:05 +0000 (UTC)
Date: Thu, 25 Apr 2019 14:28:03 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Ingo
 Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, x86@kernel.org,
 hpa@zytor.com, Thomas Gleixner <tglx@linutronix.de>, Nadav Amit
 <nadav.amit@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Peter
 Zijlstra <peterz@infradead.org>, linux_dti@icloud.com,
 linux-integrity@vger.kernel.org, linux-security-module@vger.kernel.org,
 akpm@linux-foundation.org, kernel-hardening@lists.openwall.com,
 linux-mm@kvack.org, will.deacon@arm.com, ard.biesheuvel@linaro.org,
 kristen@linux.intel.com, deneen.t.dock@intel.com
Subject: Re: [PATCH v4 19/23] x86/ftrace: Use vmalloc special flag
Message-ID: <20190425142803.4f2e354a@gandalf.local.home>
In-Reply-To: <20190422185805.1169-20-rick.p.edgecombe@intel.com>
References: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
	<20190422185805.1169-20-rick.p.edgecombe@intel.com>
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 22 Apr 2019 11:58:01 -0700
Rick Edgecombe <rick.p.edgecombe@intel.com> wrote:

> Use new flag VM_FLUSH_RESET_PERMS for handling freeing of special
> permissioned memory in vmalloc and remove places where memory was set NX
> and RW before freeing which is no longer needed.
> 
> Cc: Steven Rostedt <rostedt@goodmis.org>
> Acked-by: Steven Rostedt (VMware) <rostedt@goodmis.org>
> Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>

Tested-by: Steven Rostedt (VMware) <rostedt@goodmis.org>
Acked-by: Steven Rostedt (VMware) <rostedt@godomis.org>

-- Steve

> ---
>  arch/x86/kernel/ftrace.c | 14 ++++++--------
>  1 file changed, 6 insertions(+), 8 deletions(-)
> 
> diff --git a/arch/x86/kernel/ftrace.c b/arch/x86/kernel/ftrace.c
> index 53ba1aa3a01f..0caf8122d680 100644
> --- a/arch/x86/kernel/ftrace.c
> +++ b/arch/x86/kernel/ftrace.c
> @@ -678,12 +678,8 @@ static inline void *alloc_tramp(unsigned long size)
>  {
>  	return module_alloc(size);
>  }
> -static inline void tramp_free(void *tramp, int size)
> +static inline void tramp_free(void *tramp)
>  {
> -	int npages = PAGE_ALIGN(size) >> PAGE_SHIFT;
> -
> -	set_memory_nx((unsigned long)tramp, npages);
> -	set_memory_rw((unsigned long)tramp, npages);
>  	module_memfree(tramp);
>  }
>  #else
> @@ -692,7 +688,7 @@ static inline void *alloc_tramp(unsigned long size)
>  {
>  	return NULL;
>  }
> -static inline void tramp_free(void *tramp, int size) { }
> +static inline void tramp_free(void *tramp) { }
>  #endif
>  
>  /* Defined as markers to the end of the ftrace default trampolines */
> @@ -808,6 +804,8 @@ create_trampoline(struct ftrace_ops *ops, unsigned int *tramp_size)
>  	/* ALLOC_TRAMP flags lets us know we created it */
>  	ops->flags |= FTRACE_OPS_FL_ALLOC_TRAMP;
>  
> +	set_vm_flush_reset_perms(trampoline);
> +
>  	/*
>  	 * Module allocation needs to be completed by making the page
>  	 * executable. The page is still writable, which is a security hazard,
> @@ -816,7 +814,7 @@ create_trampoline(struct ftrace_ops *ops, unsigned int *tramp_size)
>  	set_memory_x((unsigned long)trampoline, npages);
>  	return (unsigned long)trampoline;
>  fail:
> -	tramp_free(trampoline, *tramp_size);
> +	tramp_free(trampoline);
>  	return 0;
>  }
>  
> @@ -947,7 +945,7 @@ void arch_ftrace_trampoline_free(struct ftrace_ops *ops)
>  	if (!ops || !(ops->flags & FTRACE_OPS_FL_ALLOC_TRAMP))
>  		return;
>  
> -	tramp_free((void *)ops->trampoline, ops->trampoline_size);
> +	tramp_free((void *)ops->trampoline);
>  	ops->trampoline = 0;
>  }
>  

