Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA187C4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 04:47:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8ADA82084B
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 04:47:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="NRCuIUie"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8ADA82084B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 081866B0003; Tue,  2 Apr 2019 00:47:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 031096B0005; Tue,  2 Apr 2019 00:47:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E646B6B000A; Tue,  2 Apr 2019 00:47:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id ADA2B6B0003
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 00:47:15 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id c64so5947241pfb.6
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 21:47:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=aMPPfj5JnNOQrKOZmzKYJq4pNGTHYuLUKAkg9cwvBis=;
        b=bykFm+Jx/5tVpO2cCYihUu9tqviL7M/xH04E8qOhAEl+r5YQv5nB/NJg+M+V3WtGu4
         L7PthuM7OlS+NqkEwHqRgScwJzPipXW2W2Lyy67FdhQHeo4PP1k5FyTD1RhHadN4ZKA1
         11sOP9pTAQ8l4FLf5J0hgcufy8LTGyZUjyFQRP4jFVh/AvpUR74F5Rzl0x09JEPEWX85
         ZGRE6nfE68XG46X2Oo1mz50hr/9BA60amQraVv5cuMNgJzEdRvBlBlEEcEwKCMx1QBho
         8vR5Eegwsen8VodwX3uCb+5UHaMpZMxVRqo/m5GXA/kyOrnjSXMDYVtECpcf+14DOHMs
         U9Hw==
X-Gm-Message-State: APjAAAUeoY5C/Prdy26PZ4zdH2gsyUv5FrlAO/xBmYb5UDizordFLmbT
	KKDLY3UZjm53H+l41VThLWBUDsZ+2moWCwQq04Xseys0UWcb7OdUytXtyWTqkflikPmkVf4CW41
	PpAnd9XL0fjpH2Gw4anlmBa/gSjnypPi75VhfpLH4H9DfTUSZHuuEGzeBZ28hcxgYtQ==
X-Received: by 2002:a17:902:d24:: with SMTP id 33mr68001163plu.246.1554180435166;
        Mon, 01 Apr 2019 21:47:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxHNJkqEE+Klmxmv6G92s3IaqWoMoWuhnR+GT8meFL2MpZ9LrMG/sL/R7orWXCO5nhmP+Bn
X-Received: by 2002:a17:902:d24:: with SMTP id 33mr68001121plu.246.1554180434504;
        Mon, 01 Apr 2019 21:47:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554180434; cv=none;
        d=google.com; s=arc-20160816;
        b=RueNC1gfzm6qUOyRjZpwUcBiB2b45nZwFqh1pLx/xPzWHq54vH5sKQsQCucuyFWY/M
         rlm1nIrf3TVuoMS84V/Oztz7HJ4s91Kzz0S/2ITFOoqHLDB7uIk4M5la1UcMCQn0yP9M
         Do1Lx3TWoZ7kXjihv85XNqBHbHY+Ze1MQZDoDgAWQRDk5LYSooatm5h8aKIFOPc6t+Tk
         vahCxYr/9pgHlh3pA/cyLuer7SGptmLvSNuY0aDQK/MxZTcBz1874ZSnO3v6cOB2fw5f
         xJcf67aerlb8Fy/n4HFwSEUoUKDgpw7lPEMfMi4BkwNQannvsDFbUpj9/qewPytXB/qe
         zjPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=aMPPfj5JnNOQrKOZmzKYJq4pNGTHYuLUKAkg9cwvBis=;
        b=Zz83Hv5XNpPGRp2/ZBBdaS1fKs2s7lZR8LCCKXiG+UbFfy4iCq1xWxJVZzzr5jE8as
         3giEkeWozJchxdMFZJL9K8XYA4XFaKgmYS9+0trHOO7oorvPjpPSshzBkHmcsPhzHMu5
         FHxLdOaXNSj7wAUDRx4eDULGMcBzF7eUSxJk1sjFI/wQ/qKNMLISfw2tmMAfmj540edu
         3eA9E4QRE5qHYHkgB6vwKgLaZjAO+3cD36Yfd7MIm1N7jjb4DC+gE69EkwAeZlR+sCKr
         J+9pawoi+rTpsZkpAaRtQEU+Meb8dmhE4AL1+Qk+qqzzlwPT9kvtePDgktWf8z1kv5sb
         yvYg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=NRCuIUie;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k7si10569739pfb.69.2019.04.01.21.47.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 01 Apr 2019 21:47:14 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=NRCuIUie;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:In-Reply-To:MIME-Version:Date:Message-ID:From:References:Cc:To:
	Subject:Sender:Reply-To:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=aMPPfj5JnNOQrKOZmzKYJq4pNGTHYuLUKAkg9cwvBis=; b=NRCuIUie73WIwB+IKHA2kfPsR
	1eEMLtiJ3mtAnHhDZQsGtDIBPSMouSt0UyL1OroZVOZAIqEfcyfcEZPzolQxhgwsNoYw0ww6HPC5+
	DwIVi5CXoyDsMzHcqwvY2isfTCbbTLyCMVCItkXkL+IGN3IqN3e6o19k5PMYkji4x//9XR8dlnqoz
	As9BU9+ORPZkUFrxRbkIFXqAYL2y1/279CRlF+O73Ub7YK4mfvfs086c6ZEOlGeBtikouVur8eF6k
	7CNBabBO54kv6KMQFeBLDg/4djZb+HQYLBdr1oJjYMuN7nfb0L1AdxMPBy7sXemTqF6rNjvqrj3Ez
	NXTBQRcxg==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=midway.dunlab)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hBBKJ-00007H-9Z; Tue, 02 Apr 2019 04:47:11 +0000
Subject: Re: [PATCH v3] gcov: fix when CONFIG_MODULES is not set
To: trong@android.com, oberpar@linux.ibm.com, akpm@linux-foundation.org
Cc: ndesaulniers@google.com, ghackmann@android.com, linux-mm@kvack.org,
 kbuild-all@01.org, lkp@intel.com, linux-kernel@vger.kernel.org
References: <20190402030956.48166-1-trong@android.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <ef2492c2-2b30-b431-3aaa-33b619a2e1d3@infradead.org>
Date: Mon, 1 Apr 2019 21:47:09 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190402030956.48166-1-trong@android.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/1/19 8:09 PM, trong@android.com wrote:
> From: Tri Vo <trong@android.com>
> 
> Fixes: 8c3d220cb6b5 ("gcov: clang support")
> 
> Cc: Greg Hackmann <ghackmann@android.com>
> Cc: Peter Oberparleiter <oberpar@linux.ibm.com>
> Cc: linux-mm@kvack.org
> Cc: kbuild-all@01.org
> Reported-by: Randy Dunlap <rdunlap@infradead.org>
> Reported-by: kbuild test robot <lkp@intel.com>
> Link: https://marc.info/?l=linux-mm&m=155384681109231&w=2
> Signed-off-by: Nick Desaulniers <ndesaulniers@google.com>
> Signed-off-by: Tri Vo <trong@android.com>

Acked-by: Randy Dunlap <rdunlap@infradead.org> # build-tested

Thanks.

> ---
>  kernel/gcov/clang.c   | 4 ++++
>  kernel/gcov/gcc_3_4.c | 4 ++++
>  kernel/gcov/gcc_4_7.c | 4 ++++
>  3 files changed, 12 insertions(+)
> 
> diff --git a/kernel/gcov/clang.c b/kernel/gcov/clang.c
> index 125c50397ba2..cfb9ce5e0fed 100644
> --- a/kernel/gcov/clang.c
> +++ b/kernel/gcov/clang.c
> @@ -223,7 +223,11 @@ void gcov_info_unlink(struct gcov_info *prev, struct gcov_info *info)
>   */
>  bool gcov_info_within_module(struct gcov_info *info, struct module *mod)
>  {
> +#ifdef CONFIG_MODULES
>  	return within_module((unsigned long)info->filename, mod);
> +#else
> +	return false;
> +#endif
>  }
>  
>  /* Symbolic links to be created for each profiling data file. */
> diff --git a/kernel/gcov/gcc_3_4.c b/kernel/gcov/gcc_3_4.c
> index 801ee4b0b969..8fc30f178351 100644
> --- a/kernel/gcov/gcc_3_4.c
> +++ b/kernel/gcov/gcc_3_4.c
> @@ -146,7 +146,11 @@ void gcov_info_unlink(struct gcov_info *prev, struct gcov_info *info)
>   */
>  bool gcov_info_within_module(struct gcov_info *info, struct module *mod)
>  {
> +#ifdef CONFIG_MODULES
>  	return within_module((unsigned long)info, mod);
> +#else
> +	return false;
> +#endif
>  }
>  
>  /* Symbolic links to be created for each profiling data file. */
> diff --git a/kernel/gcov/gcc_4_7.c b/kernel/gcov/gcc_4_7.c
> index ec37563674d6..0b6886d4a4dd 100644
> --- a/kernel/gcov/gcc_4_7.c
> +++ b/kernel/gcov/gcc_4_7.c
> @@ -159,7 +159,11 @@ void gcov_info_unlink(struct gcov_info *prev, struct gcov_info *info)
>   */
>  bool gcov_info_within_module(struct gcov_info *info, struct module *mod)
>  {
> +#ifdef CONFIG_MODULES
>  	return within_module((unsigned long)info, mod);
> +#else
> +	return false;
> +#endif
>  }
>  
>  /* Symbolic links to be created for each profiling data file. */
> 


-- 
~Randy

