Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0369EC282CE
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 18:08:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A1C632084C
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 18:08:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="HRZYZDKD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A1C632084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0A0496B0269; Mon,  8 Apr 2019 14:08:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 04EE26B026A; Mon,  8 Apr 2019 14:08:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA5AD6B026B; Mon,  8 Apr 2019 14:08:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id AE1C46B0269
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 14:08:29 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id v9so10683382pgg.8
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 11:08:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=6rooXMDx733C5jOZV0HDJGU0vPGbQdWxeSk9HuXBbx4=;
        b=YypJpAvlQ2IaKDbKsaec81Fc2tRqkBAxoEDh+GBu0U566vVwd/TFrjLSRXWh4eTwQc
         gOspZtykYjq3MpuPVCV/FlWOENyvbeh/US37laRHv6xF+omjMYbqfD0BdcdmyrQKTJLq
         a0fEY8Z6mp5L0YymEc83tLgbp7TdvD0NvUhnRMmnPcVhJCNd2keaFP7kjIcmmeEd3jj2
         51wz9/RYE0Wagk2jGYa8WvdBF8bAfGdX8kAgqnH6EHGTKgQMDRUVXRBbyElmnZs7djn/
         J7brj/t94vKKHwGJTyqXO6a/T+Zu5WqUlvklhBom2aPaSpN14fiReZKpG5GcCVCLUP9P
         J5ew==
X-Gm-Message-State: APjAAAVEbL2hWDQcQ7dMS1KFKDUqSGBNU/CBYA1hd5++fS77sNPsaADD
	08JV9XtDQDqCsKe6MYBeGjYeR8eiBxvl0pEuuNgKaBdI4EFpYo7ABQJPks+2ZjwMJc71p8onVne
	7sK2VX4N8DkDQ6D/P/dbFvjx/+VF3JrSTWSNuS2hTIL/cFR//QyL1gkrZ+VZWQVY0TQ==
X-Received: by 2002:a17:902:8a4:: with SMTP id 33mr32089012pll.7.1554746909195;
        Mon, 08 Apr 2019 11:08:29 -0700 (PDT)
X-Received: by 2002:a17:902:8a4:: with SMTP id 33mr32088924pll.7.1554746908374;
        Mon, 08 Apr 2019 11:08:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554746908; cv=none;
        d=google.com; s=arc-20160816;
        b=Dd6RXjSNoBetsxfB5zcAfjxP3A9ZirUSQglkpUjOamojqH0RwaOYlX18kQ8SF66sJ0
         TBZVSz1w0VesXkYulTuJ+jfIWms14hsTzU2gNIAvU0jW0D/EmAH8Ik0G+Yc3z0bI00jg
         zdvwOGof8pt73oo8bllTAZc68WQUzXJ1WEwEj2RntbzVHeDvBf9FdnwHhwzsz1ayGHkK
         aEumfSFtDXdfpM+UF/FXA/Ap5O+tv0QlvmxS3Y6NEHlBnhh/nek9J6KQjulbwbNrZfdr
         FOMhBGPjhQVcH+NjKboqU8+x5/KvD48RtdCmo9Z8CR4uHVyMZ4+lt8u0AhI8Hfmq8KnO
         iqBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=6rooXMDx733C5jOZV0HDJGU0vPGbQdWxeSk9HuXBbx4=;
        b=nppOa1NFsfZioaSVMhtP91uaA5d1N43TBYa0YHbSoMHqjTpmiZcSM5OWTpVnaZg+DF
         AhwQObURqv5405vByfzpmD3P8TT9UmqUuEcp98qNtpkICleXk2Yit5+cVYOHkz4JcEne
         7r+sjTE+sSBxmFBreRc8YiuplcuWvOz0Gv6SksmLWcmSVpqHvyjk5HBOVVw2ObdBpoaj
         q5nd2Q57WPrdGpJ4wmwxly2AvtXS4ESrLVw4G0tGooliZ8OYA1A3LjJ8U9Z9zJbhFcP7
         fuvMl4UXYHVRKe7vKKAzHpo9Ji0OkhTSuiby1Nzc8wGQHtHjsuzixbuUSwCOyANo5FmS
         VAtQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=HRZYZDKD;
       spf=pass (google.com: domain of ndesaulniers@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=ndesaulniers@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e69sor38074636plb.67.2019.04.08.11.08.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Apr 2019 11:08:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of ndesaulniers@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=HRZYZDKD;
       spf=pass (google.com: domain of ndesaulniers@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=ndesaulniers@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=6rooXMDx733C5jOZV0HDJGU0vPGbQdWxeSk9HuXBbx4=;
        b=HRZYZDKDfXK5tUiWAX/wWOVIZxw1yj3uaOhsMKPNlAYpnNEsZF0Ig+kBhxnHzgSOW8
         vrsb8nkhq7HOd9Af/7DgR0F6e+Hlvq/qpLyNpLoG5PRnCLMpJyvG8SOHMrGzO8ozTSfz
         sbVSsk6WaoDPdf8Svi0kFukrWICk6bTEfKGjAvmlol//D3EuYmJ8UjSOakz2WDpHtsDw
         avxV0aAbT6s+9VvWICs3H4S7QEf9Xv36+d8Paa0Eo3rCOZ9pzZw6bbUQvuhloAFIs+uc
         ippaOtK9gz33mFuyz+xayvv91ZFzY5B+ct3UjuOXERl7LgCVp8SM75PAL174g08XGn0w
         Kn+A==
X-Google-Smtp-Source: APXvYqzH9ZLofJ/eiR/IarF6xRJ0GP/OSTVeaGgW0jclwehLUjzUharpyVUQYnQwNuod71QbuTS1RXQZ8cpWoLj0s+c=
X-Received: by 2002:a17:902:7044:: with SMTP id h4mr31818040plt.274.1554746907239;
 Mon, 08 Apr 2019 11:08:27 -0700 (PDT)
MIME-Version: 1.0
References: <20190407022558.65489-1-trong@android.com>
In-Reply-To: <20190407022558.65489-1-trong@android.com>
From: Nick Desaulniers <ndesaulniers@google.com>
Date: Mon, 8 Apr 2019 11:08:16 -0700
Message-ID: <CAKwvOdmBa-Ckk4wnp4OEPNdxeYSxEhzddykuWWGG1Wi6JEGDwA@mail.gmail.com>
Subject: Re: [PATCH] module: add stub for within_module
To: Tri Vo <trong@android.com>, Jessica Yu <jeyu@kernel.org>, 
	Matthew Wilcox <willy@infradead.org>, Randy Dunlap <rdunlap@infradead.org>
Cc: Peter Oberparleiter <oberpar@linux.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Greg Hackmann <ghackmann@android.com>, Linux Memory Management List <linux-mm@kvack.org>, kbuild-all@01.org, 
	kbuild test robot <lkp@intel.com>, LKML <linux-kernel@vger.kernel.org>, 
	Petri Gynther <pgynther@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Apr 6, 2019 at 7:26 PM Tri Vo <trong@android.com> wrote:
>
> Provide a stub for within_module() when CONFIG_MODULES is not set. This
> is needed to build CONFIG_GCOV_KERNEL.
>
> Fixes: 8c3d220cb6b5 ("gcov: clang support")

The above commit got backed out of the -mm tree, due to the issue this
patch addresses, so not sure it provides the correct context for the
patch.  Maybe that line in the commit message should be dropped?

> Suggested-by: Matthew Wilcox <willy@infradead.org>
> Reported-by: Randy Dunlap <rdunlap@infradead.org>
> Reported-by: kbuild test robot <lkp@intel.com>
> Link: https://marc.info/?l=linux-mm&m=155384681109231&w=2
> Signed-off-by: Tri Vo <trong@android.com>
> ---
>  include/linux/module.h | 5 +++++
>  1 file changed, 5 insertions(+)
>
> diff --git a/include/linux/module.h b/include/linux/module.h
> index 5bf5dcd91009..47190ebb70bf 100644
> --- a/include/linux/module.h
> +++ b/include/linux/module.h
> @@ -709,6 +709,11 @@ static inline bool is_module_text_address(unsigned long addr)
>         return false;
>  }
>
> +static inline bool within_module(unsigned long addr, const struct module *mod)
> +{
> +       return false;
> +}
> +

Do folks think that similar stubs for within_module_core and
within_module_init should be added, while we're here?

It looks like kernel/trace/ftrace.c uses them, but has proper
CONFIG_MODULE guards.

>  /* Get/put a kernel symbol (calls should be symmetric) */
>  #define symbol_get(x) ({ extern typeof(x) x __attribute__((weak)); &(x); })
>  #define symbol_put(x) do { } while (0)
> --
> 2.21.0.392.gf8f6787159e-goog
>


-- 
Thanks,
~Nick Desaulniers

