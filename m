Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D41EBC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 20:14:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D403218A1
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 20:14:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D403218A1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=goodmis.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A4886B02C4; Fri, 15 Mar 2019 16:14:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 229346B02C6; Fri, 15 Mar 2019 16:14:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0CC726B02C7; Fri, 15 Mar 2019 16:14:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id B97706B02C4
	for <linux-mm@kvack.org>; Fri, 15 Mar 2019 16:14:20 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id v2so11489641pfn.14
        for <linux-mm@kvack.org>; Fri, 15 Mar 2019 13:14:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=gGMx3B7Iz27z3iGL7B+okEFSLxvTVbfS91a/K9thdOI=;
        b=StvVB1m04GYBnhCsvN38ioRaA8nFe0AUpqVY1s+sx8XN0+jJZ3usLKlAwIkDI5lbL/
         yWoeZ4LqdFiEb6Ym+hElWkwvhItayWbimG8nk6UQwPeLqoB8CuCrNCxoXiW2vK1U4HdZ
         6WvCPpTM4p2pF1Jzx825zcVLE8eQc+701MwBY689Lm+b1NG7lhCShYDUBmkxNcarhboT
         baEAgNaF4HPoCVFAdvsRGphyOIX1h9Gt+PO6ueZHr3flM2hnocRHN6m8/y/NvHwq9I2+
         c1LtFKHHuXdGmtX/dodBAdPHqm5nxdYNUneawrxa6zqBxevZnVf/WDBDj3ZyHOioi7Qf
         9jkg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of srs0=vfcv=rs=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=VfCv=RS=goodmis.org=rostedt@kernel.org"
X-Gm-Message-State: APjAAAWEoIe0IsyPfEBPXyZSpE0RbXrYbDwygiMKKmv1lc5pDPoRW/Q3
	NAQqbDpKNHbOqc8FViqVzZ76ETLJcMDdEazTf9UFKqE+2QlXohS7a0oNQEfrRm2X3p53cEddBhj
	KJLR4iqVVDwUsSP6ISdpDXztiACo9nzCv5HNzAHBtcJTYYkA/jpm1sm+hU6mgQ78=
X-Received: by 2002:a17:902:24:: with SMTP id 33mr6156413pla.259.1552680860327;
        Fri, 15 Mar 2019 13:14:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqycfslCOdxRW2VVGYFnKHTsMw3jbnD76wsMUY7EmlMZBGsRTBhrcgRMcNAi5/QSLhEGRCk6
X-Received: by 2002:a17:902:24:: with SMTP id 33mr6156350pla.259.1552680859313;
        Fri, 15 Mar 2019 13:14:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552680859; cv=none;
        d=google.com; s=arc-20160816;
        b=eIn9NmYtbByEs4fNAmSO1Fk+obikItODJ7t5yUKpvjsdEwlq6ap0lW+UxjKmTdnvNA
         divREkcpNEIfNBMN+TJFyKe5IiCwSKGybqSPMJa110uAi5yHomWlqRvqTxh2OAlzxNjz
         N91bMAir/FaBfedje+o6kUUxRD3E2JwZEP3p03H5sv3sP5Gg03fBxIz36tFzD/6JjHz3
         VeEkkeoORMilwfdLRBwgx/pzHoiQY4pjSJTrXTrudjMLH/qGskmsidaAxZ37TbHJhTdn
         ifOFHyjIw0SnoHW1tvL7Os3oiyY6BPop/FosOO0fabIfp0bH0I3+dKFFJe79f44ZkwmU
         /J1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=gGMx3B7Iz27z3iGL7B+okEFSLxvTVbfS91a/K9thdOI=;
        b=Hroz63gWUwVVvofyPsFkZWpwwcZE2her4MglINsa/+xKqMkKGYxgSrHgnHwz7namha
         9EDARfjhPN5ODsA64y0OnC1N8EMJQ4NbJ5vtYDzNZKl+alV/B5UPUvgU2eCsJyUytZS2
         y6/iySvTBgRXTDLt2kBcAF4B8VxTmz6fkVGxEImJSinU4ZRZnAaMF9xarKravx2pJXRk
         5BoBgyrKFbSrxlur3sF9OY0N5W3QAo/moKAkJeAFllfte4bEeBtmcnESVuwfZba357d6
         BKwbneFVaM8btFNeG6QkEp7RzSYI/MZ0avmknte1BYAwLeiLPGqngN8JaVQeB4DRDJkW
         Loag==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of srs0=vfcv=rs=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=VfCv=RS=goodmis.org=rostedt@kernel.org"
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f20si2603533pgk.454.2019.03.15.13.14.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Mar 2019 13:14:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of srs0=vfcv=rs=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of srs0=vfcv=rs=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=VfCv=RS=goodmis.org=rostedt@kernel.org"
Received: from gandalf.local.home (cpe-66-24-58-225.stny.res.rr.com [66.24.58.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id BC34021871;
	Fri, 15 Mar 2019 20:14:15 +0000 (UTC)
Date: Fri, 15 Mar 2019 16:14:14 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Robin Murphy
 <robin.murphy@arm.com>, Kees Cook <keescook@chromium.org>, Kate Stewart
 <kstewart@linuxfoundation.org>, Greg Kroah-Hartman
 <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>,
 Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov"
 <kirill.shutemov@linux.intel.com>, Shuah Khan <shuah@kernel.org>, Vincenzo
 Frascino <vincenzo.frascino@arm.com>, Eric Dumazet <edumazet@google.com>,
 "David S. Miller" <davem@davemloft.net>, Alexei Starovoitov
 <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Ingo Molnar
 <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho
 de Melo <acme@kernel.org>, linux-arm-kernel@lists.infradead.org,
 linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org,
 netdev@vger.kernel.org, bpf@vger.kernel.org,
 linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org, Dmitry
 Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, Evgeniy
 Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana
 Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley
 <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
 Chintan Pandya <cpandya@codeaurora.org>, Luc Van Oostenryck
 <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, Kevin
 Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v11 10/14] tracing, arm64: untag user pointers in
 seq_print_user_ip
Message-ID: <20190315161414.4b31fb03@gandalf.local.home>
In-Reply-To: <355e7c0dadaa2bb79d22e0b7aac7e4efc1114d49.1552679409.git.andreyknvl@google.com>
References: <cover.1552679409.git.andreyknvl@google.com>
	<355e7c0dadaa2bb79d22e0b7aac7e4efc1114d49.1552679409.git.andreyknvl@google.com>
X-Mailer: Claws Mail 3.16.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 15 Mar 2019 20:51:34 +0100
Andrey Konovalov <andreyknvl@google.com> wrote:

> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
> 
> seq_print_user_ip() uses provided user pointers for vma lookups, which
> can only by done with untagged pointers.
> 
> Untag user pointers in this function.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  kernel/trace/trace_output.c |  5 +++--
>  p                           | 45 +++++++++++++++++++++++++++++++++++++
>  2 files changed, 48 insertions(+), 2 deletions(-)
>  create mode 100644 p
> 
> diff --git a/kernel/trace/trace_output.c b/kernel/trace/trace_output.c
> index 54373d93e251..6376bee93c84 100644
> --- a/kernel/trace/trace_output.c
> +++ b/kernel/trace/trace_output.c
> @@ -370,6 +370,7 @@ static int seq_print_user_ip(struct trace_seq *s, struct mm_struct *mm,
>  {
>  	struct file *file = NULL;
>  	unsigned long vmstart = 0;
> +	unsigned long untagged_ip = untagged_addr(ip);
>  	int ret = 1;
>  
>  	if (s->full)
> @@ -379,7 +380,7 @@ static int seq_print_user_ip(struct trace_seq *s, struct mm_struct *mm,
>  		const struct vm_area_struct *vma;
>  
>  		down_read(&mm->mmap_sem);
> -		vma = find_vma(mm, ip);
> +		vma = find_vma(mm, untagged_ip);
>  		if (vma) {
>  			file = vma->vm_file;
>  			vmstart = vma->vm_start;
> @@ -388,7 +389,7 @@ static int seq_print_user_ip(struct trace_seq *s, struct mm_struct *mm,
>  			ret = trace_seq_path(s, &file->f_path);
>  			if (ret)
>  				trace_seq_printf(s, "[+0x%lx]",
> -						 ip - vmstart);
> +						 untagged_ip - vmstart);
>  		}
>  		up_read(&mm->mmap_sem);
>  	}
> diff --git a/p b/p
> new file mode 100644
> index 000000000000..9d6fa5386e55
> --- /dev/null
> +++ b/p
> @@ -0,0 +1,45 @@
> +commit 1fa6fadf644859e8a6a8ecce258444b49be8c7ee
> +Author: Andrey Konovalov <andreyknvl@google.com>
> +Date:   Mon Mar 4 17:20:32 2019 +0100
> +
> +    kasan: fix coccinelle warnings in kasan_p*_table
> +    
> +    kasan_p4d_table, kasan_pmd_table and kasan_pud_table are declared as
> +    returning bool, but return 0 instead of false, which produces a coccinelle
> +    warning. Fix it.
> +    
> +    Fixes: 0207df4fa1a8 ("kernel/memremap, kasan: make ZONE_DEVICE with work with KASAN")
> +    Reported-by: kbuild test robot <lkp@intel.com>
> +    Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

Did you mean to append this commit to this patch?

-- Steve

> +
> +diff --git a/mm/kasan/init.c b/mm/kasan/init.c
> +index 45a1b5e38e1e..fcaa1ca03175 100644
> +--- a/mm/kasan/init.c
> ++++ b/mm/kasan/init.c
> +@@ -42,7 +42,7 @@ static inline bool kasan_p4d_table(pgd_t pgd)
> + #else
> + static inline bool kasan_p4d_table(pgd_t pgd)
> + {
> +-	return 0;
> ++	return false;
> + }
> + #endif
> + #if CONFIG_PGTABLE_LEVELS > 3
> +@@ -54,7 +54,7 @@ static inline bool kasan_pud_table(p4d_t p4d)
> + #else
> + static inline bool kasan_pud_table(p4d_t p4d)
> + {
> +-	return 0;
> ++	return false;
> + }
> + #endif
> + #if CONFIG_PGTABLE_LEVELS > 2
> +@@ -66,7 +66,7 @@ static inline bool kasan_pmd_table(pud_t pud)
> + #else
> + static inline bool kasan_pmd_table(pud_t pud)
> + {
> +-	return 0;
> ++	return false;
> + }
> + #endif
> + pte_t kasan_early_shadow_pte[PTRS_PER_PTE] __page_aligned_bss;

