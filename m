Return-Path: <SRS0=B01V=PM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA57DC43612
	for <linux-mm@archiver.kernel.org>; Fri,  4 Jan 2019 02:25:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7857B2184B
	for <linux-mm@archiver.kernel.org>; Fri,  4 Jan 2019 02:25:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7857B2184B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D02B28E00BA; Thu,  3 Jan 2019 21:25:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB1A58E00AE; Thu,  3 Jan 2019 21:25:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B52EC8E00BA; Thu,  3 Jan 2019 21:25:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 716A58E00AE
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 21:25:19 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id g188so29752463pgc.22
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 18:25:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=iXqEfgiy0lcxvKFkB+e4+vrC8OARd2EmrSyw1ABQUuI=;
        b=iHdtMLyh0mHTna4OvSFZQ1egSo4lXGM96xWldsT9krh3wSvDLP1Mnp3m187aqqRomK
         RelVmh5jmXLUwoGzcEZiFsyb8eKaQcxx9a7fS04W3HmsUJ5sNMFzzXEse7PtelAF5Ed7
         m+Tc42itn8WGzljDmZtlc7tbFvC6dxfT2LhkWWVsiNbnGso/YJQQulttjuF8lNXAXA8i
         v2mQrYbJBPKmRR+OPPI1ED9k3lfyONwz9irhrtO1xfWPmcLaDw4e7cpdyIInNvdhDlkL
         PewS8NJlQKGWl3Wa16yGAzOp+iwNfdAAGV2ZhiQG46D9ijqesweO+F3lGMuE1U03r/Yn
         /s8A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukcLZVB/WEM88knrYCjSiSw2mGu0l9hSSNNUcFK7SvSsl3/67mRh
	KVPmcRqf4lJ4xhcxuX308FCxp/lmdhCRKij22UA09P+ZaPyIR0ojcaU90zmLmxr0nL81zPUq94X
	4A0tQjrTgpDQNpGhjj2Uu9L7omNLUjoRP2WhNYC4mGclBUz20G9hbY4DW6THfcDFxzg==
X-Received: by 2002:aa7:8542:: with SMTP id y2mr51376186pfn.83.1546568719043;
        Thu, 03 Jan 2019 18:25:19 -0800 (PST)
X-Google-Smtp-Source: AFSGD/XHXJsQgzrLy/uGXefKQmxpj8FtOnFKfqwR/E+s8iXapnLrFS+u1QTqN46wnu8ZLzRrl0eo
X-Received: by 2002:aa7:8542:: with SMTP id y2mr51376159pfn.83.1546568718127;
        Thu, 03 Jan 2019 18:25:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546568718; cv=none;
        d=google.com; s=arc-20160816;
        b=GzCzcuXar2E1mSZ0tVSXl6h7rxUZk+e49/YDfb+TnRYKcMSZNc0BovKYZQHv3yM7H7
         VKgS81Q2r++WXxDZ10KKqkee1/YYp9CvnFi62kij51QV+OIexdvO/k4+YNsYsITf1Fql
         iwTR2MjUNXB0yqFNSjkr1kySZwexTbC1CyOVGY7Y7K/GeblGOCkU2sYh/SOuYmz1Sp2Q
         ai9dSbQnMQC9TRCdm56zm9FDGQ7doWeoLIjUP7v969yTuj2ywBfQOIHBra9EXT6aDqAy
         TFx1L+GpNPhaUDYJUzabivkphiaYtxDZO5YksPbv3PnZCwLLSDs/Eap06C3KwQ1PdNXg
         AyaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=iXqEfgiy0lcxvKFkB+e4+vrC8OARd2EmrSyw1ABQUuI=;
        b=P/pplvXtFDvaMsDXHVbEWJaPdohxJNDfdPb0ToxC/wIWcRhCEIa4Lu8nm5aMa9RZoP
         3n+llgu89X5ig4BO90bDFBQljRwtCrtASOhef7FUuWApo6UmXuW28bo5pLD23g3mXiP4
         /Nbyy/wUUNR2GGuBskJYJfoOhvUMOHVvJWLPNGZ9HjBg7MmIKcGjSoTfgHMEvIVK3fim
         QZ3487RjTQrURBH6hyDUVJCggJRygN8nsBK8tz/OyiVSmji5/zkHBDv6As+D3uDYuu64
         NkIg2F2RbEGQtrQ4w5WhpWqOTpnTXyepxuFRMqoj6T5XseqaKM66v4wY5QauBiiWGY/N
         4QuA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id v6si11846640pfb.178.2019.01.03.18.25.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 18:25:18 -0800 (PST)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 03 Jan 2019 18:25:17 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,437,1539673200"; 
   d="scan'208";a="135191315"
Received: from yhuang-dev.sh.intel.com (HELO yhuang-dev) ([10.239.13.10])
  by fmsmga001.fm.intel.com with ESMTP; 03 Jan 2019 18:25:15 -0800
From: "Huang\, Ying" <ying.huang@intel.com>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: <tim.c.chen@intel.com>,  <minchan@kernel.org>,  <daniel.m.jordan@oracle.com>,  <akpm@linux-foundation.org>,  <linux-mm@kvack.org>,  <linux-kernel@vger.kernel.org>
Subject: Re: [v5 PATCH 2/2] mm: swap: add comment for swap_vma_readahead
References: <1546543673-108536-1-git-send-email-yang.shi@linux.alibaba.com>
	<1546543673-108536-2-git-send-email-yang.shi@linux.alibaba.com>
Date: Fri, 04 Jan 2019 10:25:15 +0800
In-Reply-To: <1546543673-108536-2-git-send-email-yang.shi@linux.alibaba.com>
	(Yang Shi's message of "Fri, 4 Jan 2019 03:27:53 +0800")
Message-ID: <87imz5tb04.fsf@yhuang-dev.intel.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/25.2 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190104022515.9-IiDvz0YJFoaZdFYPKPzEoZzqFy_8gbDsiUngBY9kM@z>

Yang Shi <yang.shi@linux.alibaba.com> writes:

> swap_vma_readahead()'s comment is missed, just add it.
>
> Cc: Huang Ying <ying.huang@intel.com>
> Cc: Tim Chen <tim.c.chen@intel.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>

Thank!

Reviewed-by: "Huang, Ying" <ying.huang@intel.com>

Best Regards,
Huang, Ying

> ---
> v5: Fixed the comments per Ying Huang
>
>  mm/swap_state.c | 16 +++++++++++++++-
>  1 file changed, 15 insertions(+), 1 deletion(-)
>
> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index 78d500e..c8730d7 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -523,7 +523,7 @@ static unsigned long swapin_nr_pages(unsigned long offset)
>   * This has been extended to use the NUMA policies from the mm triggering
>   * the readahead.
>   *
> - * Caller must hold down_read on the vma->vm_mm if vmf->vma is not NULL.
> + * Caller must hold read mmap_sem if vmf->vma is not NULL.
>   */
>  struct page *swap_cluster_readahead(swp_entry_t entry, gfp_t gfp_mask,
>  				struct vm_fault *vmf)
> @@ -698,6 +698,20 @@ static void swap_ra_info(struct vm_fault *vmf,
>  	pte_unmap(orig_pte);
>  }
>  
> +/**
> + * swap_vma_readahead - swap in pages in hope we need them soon
> + * @entry: swap entry of this memory
> + * @gfp_mask: memory allocation flags
> + * @vmf: fault information
> + *
> + * Returns the struct page for entry and addr, after queueing swapin.
> + *
> + * Primitive swap readahead code. We simply read in a few pages whoes
> + * virtual addresses are around the fault address in the same vma.
> + *
> + * Caller must hold read mmap_sem if vmf->vma is not NULL.
> + *
> + */
>  static struct page *swap_vma_readahead(swp_entry_t fentry, gfp_t gfp_mask,
>  				       struct vm_fault *vmf)
>  {

