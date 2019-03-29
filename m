Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8CE1CC43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 18:01:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D920206B7
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 18:01:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="djw4196f"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D920206B7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9BBA86B000D; Fri, 29 Mar 2019 14:01:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 96B946B000E; Fri, 29 Mar 2019 14:01:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 80E366B0010; Fri, 29 Mar 2019 14:01:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 450B56B000D
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 14:01:30 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id g1so1997462pfo.2
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 11:01:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=dd5MRiFBsN+AsSinzvLVsYwYGLT+K1KoqVgd4aICLWI=;
        b=F2eZ6Z5bWFcsT0xug+rpQiRoYWMafhULE52R/L962rMh6M7ozMOMUEjbdJUZJ4uG9T
         YIIffEfE3ZV1gbjR6LpMEwh9cOI1e1//Jng0vbX67ZrYXogiIqeYUxlhYXAUef4kd1Ao
         OI/HPzSce4PzrJTsUFu4S80H9FFp4lIZTZ+klHs1HjOSuSk+8sUBZiIpNlbNfoZw+0BN
         yJjG10xESd+W89q6BjDYAmCnyOUmAaGjq7Ob+lQjiEb1ztEDhQcgn4UkLwq+J7Czo7p/
         GYy0XU0ck0Dje7YLCScLeaqBWz/AxRWpYtVlONE38oyP61Ent23Tk12R3iOY6/jYHRRC
         CRQw==
X-Gm-Message-State: APjAAAViy8P/GS/VaMux5fQsjOevNScHF5KWbj4OS45S1PAZN2k7Rhx1
	qBF2NByXJiPk4yfGYbkzN0i5FszAG6GSA1h8L7/yvnQZ4gwDOjqmQPDTbJzGdRvQ5gT9BMGF2Rb
	rcKZK8BFBh3mpJ/tKcxTeqnnR5ZwkqGZGwR0vgXidrn76nyt6xcVEcWS5fGxWvpHFKw==
X-Received: by 2002:a17:902:a612:: with SMTP id u18mr49551921plq.145.1553882489861;
        Fri, 29 Mar 2019 11:01:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxdcamqxcpB+dRdbOHOfju4UXp/BimT4bVX5zEoCWeUetItNPu8tgUtM2d/xSLrFl/z1lZY
X-Received: by 2002:a17:902:a612:: with SMTP id u18mr49551845plq.145.1553882489079;
        Fri, 29 Mar 2019 11:01:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553882489; cv=none;
        d=google.com; s=arc-20160816;
        b=awPPOApd0sK8490cW+rRIRwuilXPsoYAnD9EE7XYAj/mJuGKyDTR9cRiJlqa7hkRqk
         1BZEC4qunNESr6dEtv3qDyYUFG0qo7BEvKdw7nvkSj8kqMu7r8RYcvIVhiGrulr37A6D
         lL3SxuMBUEYcZHAjczH2sQ/zqa1AOVwGxeCDcqcoiZ+EjMVwfcbvjwATGs1nPm5HaWjU
         cOhv5/McejZorwhiEstvIN6HPSsy85kHaPF0bTGrLG1witHeM/gsleEx5Y3rywpU9pGF
         iZPUubfYSAdYejF0xKgmA+qssT9pt9kFsnb7sE1/UvSFvUbGh+AR+Fp/TXJOtPtxfE93
         mkzQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=dd5MRiFBsN+AsSinzvLVsYwYGLT+K1KoqVgd4aICLWI=;
        b=OE3mrOHHwrct0BGY3FWYgayLtTxLayW7LfHnSLHagTFnWtiPN7ox83FbvKo7pehYHp
         HEUpH7p9M4vykPuiq1kubJtRqVAQjh2+kWB2Yfuw/YBNv4Z8TYw+viMSHUl/uV1D/MQ7
         WW5SxB10AWMozrmfQwIMTeC42QYKQ3kj0cnA3ClkgbIKu1wMzvKeYA1U3jsSRTZUz3KI
         Z2pfl7quVN3jf/1ypfmH37s9qDc0E6hV/RYgv2A3dQzQ5jTo8CFxA5gCnjB5JnpvQWyl
         EBcG0r/MICfz0BBBrhyV2PciaD6Izvx2HgZSDvkfhxq1JRhGrqIJpkaSjUGw9St7ROll
         ioJg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=djw4196f;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q29si2385441pfi.98.2019.03.29.11.01.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 29 Mar 2019 11:01:25 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=djw4196f;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:In-Reply-To:MIME-Version:Date:Message-ID:From:References:Cc:To:
	Subject:Sender:Reply-To:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=dd5MRiFBsN+AsSinzvLVsYwYGLT+K1KoqVgd4aICLWI=; b=djw4196fs7me/2RwMmGT2/Hbm
	gPLkrFCdsSxgDNZ9TtT2SJuF7swl5kDNMYn97QPHtcC/PP0/5yCjIuzi4b92h3fi48pXcKVmVzhKW
	N/D9RlOik/hcGz836JhB7hx8EC26CNlp2t5ygx+6SuwxOl8/F4uH4Y5Vbw3h0oqbwQJasqznuthAQ
	Khg9Rhk6iUo+O8kLjaMuxeQa17ulfsa25amkAUdrpllUhJGNzHPsQ4kZQAnPJDrhe8fsx3WCg6L3r
	ilO/DhaA44rqrOC+cVIKMnlHMym7e5k7LRdY3r6B6vH+D5xafK6QT9UGKZrSsMieeUIPs8lUwtVgw
	UqUMs0QQw==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=midway.dunlab)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h9voa-0008Jr-T2; Fri, 29 Mar 2019 18:01:21 +0000
Subject: Re: [PATCH] gcov: include linux/module.h for within_module
To: Nick Desaulniers <ndesaulniers@google.com>, oberpar@linux.ibm.com,
 akpm@linux-foundation.org
Cc: Greg Hackmann <ghackmann@android.com>, Tri Vo <trong@android.com>,
 linux-mm@kvack.org, kbuild-all@01.org, kbuild test robot <lkp@intel.com>,
 linux-kernel@vger.kernel.org
References: <201903291603.7podsjD7%lkp@intel.com>
 <20190329174541.79972-1-ndesaulniers@google.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <9f1ad3e1-fad7-2fb4-31c0-d31832468143@infradead.org>
Date: Fri, 29 Mar 2019 11:01:15 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190329174541.79972-1-ndesaulniers@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/29/19 10:45 AM, Nick Desaulniers wrote:
> Fixes commit 8c3d220cb6b5 ("gcov: clang support")
> 
> Cc: Greg Hackmann <ghackmann@android.com>
> Cc: Tri Vo <trong@android.com>
> Cc: Peter Oberparleiter <oberpar@linux.ibm.com>
> Cc: linux-mm@kvack.org
> Cc: kbuild-all@01.org
> Reported-by: kbuild test robot <lkp@intel.com>
> Link: https://marc.info/?l=linux-mm&m=155384681109231&w=2
> Signed-off-by: Nick Desaulniers <ndesaulniers@google.com>

Reported-by: Randy Dunlap <rdunlap@infradead.org>
see https://lore.kernel.org/linux-mm/20190328225107.ULwYw%25akpm@linux-foundation.org/T/#mee26c00158574326e807480fc39dfcbd7bebd5fd

Did you test this?  kernel/gcov/gcc_4_7.c includes local "gcov.h",
which includes <linux/module.h>, so why didn't that work or why
does this patch work?

thanks.

> ---
>  kernel/gcov/gcc_3_4.c | 1 +
>  kernel/gcov/gcc_4_7.c | 1 +
>  2 files changed, 2 insertions(+)
> 
> diff --git a/kernel/gcov/gcc_3_4.c b/kernel/gcov/gcc_3_4.c
> index 801ee4b0b969..0eda59ef57df 100644
> --- a/kernel/gcov/gcc_3_4.c
> +++ b/kernel/gcov/gcc_3_4.c
> @@ -16,6 +16,7 @@
>   */
>  
>  #include <linux/errno.h>
> +#include <linux/module.h>
>  #include <linux/slab.h>
>  #include <linux/string.h>
>  #include <linux/seq_file.h>
> diff --git a/kernel/gcov/gcc_4_7.c b/kernel/gcov/gcc_4_7.c
> index ec37563674d6..677851284fe2 100644
> --- a/kernel/gcov/gcc_4_7.c
> +++ b/kernel/gcov/gcc_4_7.c
> @@ -13,6 +13,7 @@
>   */
>  
>  #include <linux/errno.h>
> +#include <linux/module.h>
>  #include <linux/slab.h>
>  #include <linux/string.h>
>  #include <linux/seq_file.h>
> 


-- 
~Randy

