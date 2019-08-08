Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7738FC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 09:20:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D2A921881
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 09:20:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cogentembedded-com.20150623.gappssmtp.com header.i=@cogentembedded-com.20150623.gappssmtp.com header.b="eGiX9Khh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D2A921881
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=cogentembedded.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 388086B0003; Thu,  8 Aug 2019 05:20:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 35DE06B0006; Thu,  8 Aug 2019 05:20:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 24CD46B0007; Thu,  8 Aug 2019 05:20:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id B391A6B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 05:20:11 -0400 (EDT)
Received: by mail-lf1-f72.google.com with SMTP id y24so3526160lfh.5
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 02:20:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=OCitiiIQARt2srQdTEp8HHKk2MswJS9hy+qm/HN3L5Q=;
        b=uWZm4qWqF+lOLThfof72VCJbs/bOWO0nLBC/+ooI+Esug1pscgu5olUQYyajallEvA
         1s0QxnYdLmav0s6GDzohoSc8gHihSBFTJzM/LsDb4J6B/pKp1xw2t+GgAUVScujFtdFS
         ef1rzx9xvRhx21mLOI3T3TdL6SemlVkNePgTOqxn4cXFUKTV1v+h+8cGH7F2aeC5qp0V
         yQZRCYG+q+A7BocxVMG1XSo0q+VvzRRTeMQwv5Lmc6T2Oj5vQyLbRxC3lVOOhh7yfrsX
         6hf9OO8OArbCIxxf0nGPdcdfTmbAdRez7dks98sWlEYp5jfjIiO1US1luR0un7T4y5D0
         bXBw==
X-Gm-Message-State: APjAAAVO+t2P6wnX5FWc+RfPYvU7mDuiQNaDzW3z8zlF99WO1JJ2O5nN
	sVahePGcrcr4U3DT2LqVZCQ1+72JPoOpPUtWdG8GHd99VAvG7dUDFTgKQg1pBwE6KeddstIEEUz
	QPJsVpB7gw3ZviUY/w/HE2XOe8q7xbvd4TuJsSSn0y8lGKllvsaJZG+lgOzhGY6fwJQ==
X-Received: by 2002:a2e:7c15:: with SMTP id x21mr7594278ljc.55.1565256011033;
        Thu, 08 Aug 2019 02:20:11 -0700 (PDT)
X-Received: by 2002:a2e:7c15:: with SMTP id x21mr7594243ljc.55.1565256010254;
        Thu, 08 Aug 2019 02:20:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565256010; cv=none;
        d=google.com; s=arc-20160816;
        b=ZiEmNANRdPBJgxFFPTezScV+qiv6ZbVQKkYKDsEhNi01f0RD+KvM1LW0fuRd3sXDgB
         GqPdjelNRvKI6nZbWFvom17+vKXZUdQodfQWC4edWRpM4k4meBWnMd6FerKRkhosszNF
         LdDWuDmFVLR3p2n+fAoJUnRcPYhMciXWivBpsXcbxKxWINHDf40gMGpyxCd24Bsm7VJj
         2XxKB76RscWvl0jiRk/zEwzBJ4xTzqeyEkScrGgdIfFAoLyuQtGgyvkDX28VW4piN6Ip
         wZsxE64BJxKX/KoZZhj1HO5Ua3jbbRgMHJMXM9ff+h02EbBxGZMWOK9pmRNPB5jLbt73
         6Q5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=OCitiiIQARt2srQdTEp8HHKk2MswJS9hy+qm/HN3L5Q=;
        b=nDG5agvpjdGX6OCpErTi1cxLbDnQ0IjphWnytMmUpCw82yHlknja2zhko0jKmq/fdn
         vKz874U/BvNe+HDLhzG1AuR5kLx9Pvohf1lRJpIW4Aa8IjwN77tfJyqIRdVNiWXX3LPx
         ygNP2fa21WTKito1wv8eiHDA981crgVf08nAqwdUxBZXFBh6W9Gyz8crKm/p8zcYnkSn
         gTg+KdchHnFL3IG3WG2mvIp471FltL5uVIwGnbNqX783Ty1gnaAmY12ElnWzalk8TZAd
         Air3hTHPeN+ymFI09X+eSvgxvrh2R/Cm0iUMWb3YHPcVFP5JgMjS+xohkwxV25BNwybD
         f/0g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cogentembedded-com.20150623.gappssmtp.com header.s=20150623 header.b=eGiX9Khh;
       spf=pass (google.com: domain of sergei.shtylyov@cogentembedded.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sergei.shtylyov@cogentembedded.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e81sor49145584ljf.42.2019.08.08.02.20.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Aug 2019 02:20:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of sergei.shtylyov@cogentembedded.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cogentembedded-com.20150623.gappssmtp.com header.s=20150623 header.b=eGiX9Khh;
       spf=pass (google.com: domain of sergei.shtylyov@cogentembedded.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sergei.shtylyov@cogentembedded.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cogentembedded-com.20150623.gappssmtp.com; s=20150623;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=OCitiiIQARt2srQdTEp8HHKk2MswJS9hy+qm/HN3L5Q=;
        b=eGiX9Khh6PGwyt3vEDZS5i+7Ttn3dev6cKijGsAKu98PEo2SOHWYpChGzAR8G6rqiH
         jzgQRh6WatLMuo4AbNf4LAJr20oUT+cZdU/1CJnSqTguKc+Ybw4jmkdw0OadBReXodeF
         ebkbMHm8MDy0PwD/pEvqEAPbq07rO3qstGtOj2YxInvoyEp2nXA39FzVCr7+4l19jsYI
         3s9hm6A/4KWKEqwiGw05Tvffpb0A0mj+ayAeSD24M3N45J6I7gHbT2TjJqBsaCxM8sqn
         rQPLBU1qx5jTkktaKHQLtADroikDfkHoEs6q4//nMMWQlm8Px3F2v3VdsnP0ZIgPpvGb
         4l2A==
X-Google-Smtp-Source: APXvYqwAgmAyvFxsvAFzBlQwmsh/xeHT2UOBWqRNNJ6VrtKLtOr+7Myij8Z/3eE0oJPU4/4mQFntnQ==
X-Received: by 2002:a2e:9685:: with SMTP id q5mr6063276lji.227.1565256009622;
        Thu, 08 Aug 2019 02:20:09 -0700 (PDT)
Received: from ?IPv6:2a00:1fa0:8c7:ada9:25b2:24d8:3973:eb87? ([2a00:1fa0:8c7:ada9:25b2:24d8:3973:eb87])
        by smtp.gmail.com with ESMTPSA id u27sm17024138lfn.87.2019.08.08.02.20.07
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 02:20:08 -0700 (PDT)
Subject: Re: [PATCH v6 11/14] mips: Adjust brk randomization offset to fit
 generic version
To: Alexandre Ghiti <alex@ghiti.fr>, Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Walmsley <paul.walmsley@sifive.com>,
 Luis Chamberlain <mcgrof@kernel.org>, Christoph Hellwig <hch@lst.de>,
 Russell King <linux@armlinux.org.uk>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Ralf Baechle <ralf@linux-mips.org>,
 Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
 Palmer Dabbelt <palmer@sifive.com>, Albert Ou <aou@eecs.berkeley.edu>,
 Alexander Viro <viro@zeniv.linux.org.uk>, Kees Cook <keescook@chromium.org>,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-mips@vger.kernel.org, linux-riscv@lists.infradead.org,
 linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
References: <20190808061756.19712-1-alex@ghiti.fr>
 <20190808061756.19712-12-alex@ghiti.fr>
From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Message-ID: <68ec5cf6-6ba3-68ab-aa01-668b701c642f@cogentembedded.com>
Date: Thu, 8 Aug 2019 12:19:56 +0300
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190808061756.19712-12-alex@ghiti.fr>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello!

On 08.08.2019 9:17, Alexandre Ghiti wrote:

> This commit simply bumps up to 32MB and 1GB the random offset
> of brk, compared to 8MB and 256MB, for 32bit and 64bit respectively.
> 
> Suggested-by: Kees Cook <keescook@chromium.org>
> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
> Acked-by: Paul Burton <paul.burton@mips.com>
> Reviewed-by: Kees Cook <keescook@chromium.org>
> Reviewed-by: Luis Chamberlain <mcgrof@kernel.org>
> ---
>   arch/mips/mm/mmap.c | 7 ++++---
>   1 file changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/arch/mips/mm/mmap.c b/arch/mips/mm/mmap.c
> index a7e84b2e71d7..ff6ab87e9c56 100644
> --- a/arch/mips/mm/mmap.c
> +++ b/arch/mips/mm/mmap.c
[...]
> @@ -189,11 +190,11 @@ static inline unsigned long brk_rnd(void)
>   	unsigned long rnd = get_random_long();
>   
>   	rnd = rnd << PAGE_SHIFT;
> -	/* 8MB for 32bit, 256MB for 64bit */
> +	/* 32MB for 32bit, 1GB for 64bit */
>   	if (TASK_IS_32BIT_ADDR)
> -		rnd = rnd & 0x7ffffful;
> +		rnd = rnd & (SZ_32M - 1);
>   	else
> -		rnd = rnd & 0xffffffful;
> +		rnd = rnd & (SZ_1G - 1);

    Why not make these 'rnd &= SZ_* - 1', while at it anyways?

[...]

MBR, Sergei

