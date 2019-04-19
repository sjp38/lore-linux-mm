Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8AA53C282DA
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 13:28:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 37B3F222AB
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 13:28:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 37B3F222AB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=goodmis.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9CF886B0003; Fri, 19 Apr 2019 09:28:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 97E3A6B0006; Fri, 19 Apr 2019 09:28:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 875996B0007; Fri, 19 Apr 2019 09:28:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4E0A16B0003
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 09:28:30 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i14so3505588pfd.10
        for <linux-mm@kvack.org>; Fri, 19 Apr 2019 06:28:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=DSINax2VH53gTG05uINPkEOC6Go/Wig4jq5raCdlUE0=;
        b=m30PeAWvL+XEx+B0t2LVzlH/6zwK+wkYcrc+flnZryDgNF4BQ2/dqw29UBT7mrBvsl
         jX/Yqpu/WKfRCqu7GFfpZ4vzePSwJ67nBjGlTfXjYacIJmn4+K9TBfYuvmtCK7cB+995
         VNB8FGugVUJwqRv5aBNyBkckbBm4c4J2bobA0EF578cy05nIhZMqPK59kc2aTaLXgwJO
         AkeA2rplIUbyfqfGKk4D4ZOliFM3N/X+g3Ja2YSO81rYFjURco4UYNLbNJeJnh6dD1OM
         taYW664vI2jp0LclDLZN3jUhwINjSkBk2/qrpiR5rXCnBNkGQJipc0b65cffGphnMi1p
         9J0A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of srs0=q68w=sv=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=Q68w=SV=goodmis.org=rostedt@kernel.org"
X-Gm-Message-State: APjAAAULyj0Hq2WfN8mr8MdF727CE5yiSoPa3Mdd6/aAa1NtdjjCNgKm
	B+wHpZsvLFsyNYMznEtCYMwzFCAmFRUC96N9IwrBmY3p5SAkMIGjECzcsRB/xsr+529lD6IH9ed
	MiS59yI8Oygfjw2W/rSdTIueQejRCTyte9htUN+9fyJsnVB+JFPG7vz71uz7pi6g=
X-Received: by 2002:a17:902:7883:: with SMTP id q3mr3834708pll.60.1555680509955;
        Fri, 19 Apr 2019 06:28:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyKdTk4JDFl4zHhj1wPk/Nawl0bnh28Aecn0n5q8EdCXGPnVMMfqH71FDX+xhtkxpzBly6n
X-Received: by 2002:a17:902:7883:: with SMTP id q3mr3834645pll.60.1555680509076;
        Fri, 19 Apr 2019 06:28:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555680509; cv=none;
        d=google.com; s=arc-20160816;
        b=fg4dDKHbf+zSswBNsfiEMLlegC8YG4vAAfHJyEoJ4tRg2hqLKp7PIU1BHp+EYf6nLS
         OFrh05xtbgxz9zeercdbF2NdTfW60Zl+FDfFgbSZDe/7kmTTeKVDlX7L908VcagtB5Aj
         wcbfIl2Yr7h6ylacCMrgWsIBn/jQrVkA3SXiq70u/6ZnuDLlALhqhYAXeh8WUtedBF4o
         MknrkS449hTzGuI7ZPQntXAZd5PmiufnQytUtqRTgxip2KugtlKgtjsIXjGRssdTU+Ht
         tWYy2r4GlyAJyAca9OezBhXaEiS/BtP7Kdc/cWgqmt2IH6gjZ5D9V0sWVZ7aYsJ0nc8n
         MpVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=DSINax2VH53gTG05uINPkEOC6Go/Wig4jq5raCdlUE0=;
        b=GAGsEKNGCln4477RKhcLqkjQTrSIya7SvA/CIrxzJ3I21HBKQTZeP/8vVf+28xqgtg
         QCMriHpcCQoFrSyJP3Wsk6YIGjrLavkrvnFc3L1tjfVtHwJyHat8RWi2BNcqiaLMJQBF
         Wv/BE4li7HLpnNhQpAqyJKTxb1qvuXgWJ+QmfNVHRkUfkhJ2qkWxE4m6BtmXs7GOqz8f
         7c6A+CVta34d4Y7n2znKKWZpF5k9xQZm9Hol3RPTrA/Lad9/8IHGsqG92s6ofJv+o6K1
         5kGHW1OdnIUV2HvthOaxHyFKkS/SMgKPcUqwSGhY2fth7qHsg+lM4KhylHYLUhyf9XYz
         fxZw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of srs0=q68w=sv=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=Q68w=SV=goodmis.org=rostedt@kernel.org"
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 14si5141022ple.218.2019.04.19.06.28.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Apr 2019 06:28:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of srs0=q68w=sv=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of srs0=q68w=sv=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=Q68w=SV=goodmis.org=rostedt@kernel.org"
Received: from gandalf.local.home (cpe-66-24-58-225.stny.res.rr.com [66.24.58.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 262412229E;
	Fri, 19 Apr 2019 13:28:25 +0000 (UTC)
Date: Fri, 19 Apr 2019 09:28:23 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, Josh Poimboeuf
 <jpoimboe@redhat.com>, x86@kernel.org, Andy Lutomirski <luto@kernel.org>,
 Alexander Potapenko <glider@google.com>, Alexey Dobriyan
 <adobriyan@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Pekka
 Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes
 <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Catalin Marinas
 <catalin.marinas@arm.com>, Dmitry Vyukov <dvyukov@google.com>, Andrey
 Ryabinin <aryabinin@virtuozzo.com>, kasan-dev@googlegroups.com, Mike
 Rapoport <rppt@linux.vnet.ibm.com>, Akinobu Mita <akinobu.mita@gmail.com>,
 iommu@lists.linux-foundation.org, Robin Murphy <robin.murphy@arm.com>,
 Christoph Hellwig <hch@lst.de>, Marek Szyprowski
 <m.szyprowski@samsung.com>, Johannes Thumshirn <jthumshirn@suse.de>, David
 Sterba <dsterba@suse.com>, Chris Mason <clm@fb.com>, Josef Bacik
 <josef@toxicpanda.com>, linux-btrfs@vger.kernel.org, dm-devel@redhat.com,
 Mike Snitzer <snitzer@redhat.com>, Alasdair Kergon <agk@redhat.com>,
 intel-gfx@lists.freedesktop.org, Joonas Lahtinen
 <joonas.lahtinen@linux.intel.com>, Maarten Lankhorst
 <maarten.lankhorst@linux.intel.com>, dri-devel@lists.freedesktop.org, David
 Airlie <airlied@linux.ie>, Jani Nikula <jani.nikula@linux.intel.com>,
 Daniel Vetter <daniel@ffwll.ch>, Rodrigo Vivi <rodrigo.vivi@intel.com>,
 linux-arch@vger.kernel.org
Subject: Re: [patch V2 22/29] tracing: Make ftrace_trace_userstack() static
 and conditional
Message-ID: <20190419092823.094a6061@gandalf.local.home>
In-Reply-To: <20190418084255.088813838@linutronix.de>
References: <20190418084119.056416939@linutronix.de>
	<20190418084255.088813838@linutronix.de>
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Apr 2019 10:41:41 +0200
Thomas Gleixner <tglx@linutronix.de> wrote:

> It's only used in trace.c and there is absolutely no point in compiling it
> in when user space stack traces are not supported.
> 
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> Cc: Steven Rostedt <rostedt@goodmis.org>

Funny, these were moved out to global functions along with the
ftrace_trace_stack() but I guess they were never used.

This basically just does a partial revert of:

 c0a0d0d3f6528 ("tracing/core: Make the stack entry helpers global")


> ---
>  kernel/trace/trace.c |   14 ++++++++------
>  kernel/trace/trace.h |    8 --------
>  2 files changed, 8 insertions(+), 14 deletions(-)
> 
> --- a/kernel/trace/trace.c
> +++ b/kernel/trace/trace.c
> @@ -159,6 +159,8 @@ static union trace_eval_map_item *trace_
>  #endif /* CONFIG_TRACE_EVAL_MAP_FILE */
>  
>  static int tracing_set_tracer(struct trace_array *tr, const char *buf);
> +static void ftrace_trace_userstack(struct ring_buffer *buffer,
> +				   unsigned long flags, int pc);
>  
>  #define MAX_TRACER_SIZE		100
>  static char bootup_tracer_buf[MAX_TRACER_SIZE] __initdata;
> @@ -2905,9 +2907,10 @@ void trace_dump_stack(int skip)
>  }
>  EXPORT_SYMBOL_GPL(trace_dump_stack);
>  
> +#ifdef CONFIG_USER_STACKTRACE_SUPPORT
>  static DEFINE_PER_CPU(int, user_stack_count);
>  
> -void
> +static void
>  ftrace_trace_userstack(struct ring_buffer *buffer, unsigned long flags, int pc)
>  {
>  	struct trace_event_call *call = &event_user_stack;
> @@ -2958,13 +2961,12 @@ ftrace_trace_userstack(struct ring_buffe
>   out:
>  	preempt_enable();
>  }
> -
> -#ifdef UNUSED

Strange, I never knew about this ifdef. I would have nuked it when I
saw it.

Anyway,

Reviewed-by: Steven Rostedt (VMware) <rostedt@goodmis.org>

-- Steve


> -static void __trace_userstack(struct trace_array *tr, unsigned long flags)
> +#else /* CONFIG_USER_STACKTRACE_SUPPORT */
> +static void ftrace_trace_userstack(struct ring_buffer *buffer,
> +				   unsigned long flags, int pc)
>  {
> -	ftrace_trace_userstack(tr, flags, preempt_count());
>  }
> -#endif /* UNUSED */
> +#endif /* !CONFIG_USER_STACKTRACE_SUPPORT */
>  
>  #endif /* CONFIG_STACKTRACE */
>  
> --- a/kernel/trace/trace.h
> +++ b/kernel/trace/trace.h
> @@ -782,17 +782,9 @@ void update_max_tr_single(struct trace_a
>  #endif /* CONFIG_TRACER_MAX_TRACE */
>  
>  #ifdef CONFIG_STACKTRACE
> -void ftrace_trace_userstack(struct ring_buffer *buffer, unsigned long flags,
> -			    int pc);
> -
>  void __trace_stack(struct trace_array *tr, unsigned long flags, int skip,
>  		   int pc);
>  #else
> -static inline void ftrace_trace_userstack(struct ring_buffer *buffer,
> -					  unsigned long flags, int pc)
> -{
> -}
> -
>  static inline void __trace_stack(struct trace_array *tr, unsigned long flags,
>  				 int skip, int pc)
>  {
> 

