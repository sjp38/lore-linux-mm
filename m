Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 874D7C43218
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 10:15:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5534F2089E
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 10:15:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5534F2089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E48986B0005; Tue, 11 Jun 2019 06:15:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DF9A46B0006; Tue, 11 Jun 2019 06:15:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE9576B0007; Tue, 11 Jun 2019 06:15:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 828406B0005
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 06:15:48 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f19so15009476edv.16
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 03:15:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=iOF1SAPRBnEPEbZ+SxJke6JWECYMQk69+WplrF3r10Q=;
        b=gLnne1hc1m4iJ1SnVNLisircsU8rnkfzsa+nxVaAalHTKoqgE0kGjHniH9FQXGRqlb
         pkBorbVk04Zygokjg2Tg43awLrFgmtdDii/8OZbIsRxTERdMjkw88nQ6Ql2PrXhJnn79
         7mkozmMHFDOJVqT2460W+O4DXcTx5nglttfVB4RJc9ZH92hVKcUE2q3Dehp54Ck8pXJ/
         VTQHFZXz1eF3SqtTZOHLQ7XucvI12jOJkrd5RWN0bYKQNP0A1yh/Hbjm/BLUIVqU9pdj
         hoAP3ibG9X9jlSul89QVYRocfIgW9AV45Nymk3IguA0H/8U6p/KiAEOE0J7nMKGWVKL9
         nzmg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vladimir.murzin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vladimir.murzin@arm.com
X-Gm-Message-State: APjAAAUh31OZ/a11QH1zp42LgH/iEgJ0uy+YEypv3eryLpa3X7CDl7pQ
	jPo4Q4M8kwXRoUlMOf1ziCm238notxKEyG/kXeAQQYTbG4FNLnrA929It21kcynCpqkQkE4+Eoa
	7hBdJ/osBDXmlvFflCytiRKSiudm30gNaTn/ihOMoRm8EtqqHC4CCy87OYzKW6VwiAg==
X-Received: by 2002:a17:906:c404:: with SMTP id u4mr18910963ejz.123.1560248148095;
        Tue, 11 Jun 2019 03:15:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzNW7QyHJ32C1xxPhgMqiQ+sQEvXu+dyHhSeC5nd/RXWpKva+UhgFIlQYHL4SH8/6jS5Pz6
X-Received: by 2002:a17:906:c404:: with SMTP id u4mr18910896ejz.123.1560248147269;
        Tue, 11 Jun 2019 03:15:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560248147; cv=none;
        d=google.com; s=arc-20160816;
        b=nIrlU8sdmBjal1eOOpGxXnP3OcCGx5FXMA0lffa6u6aIKlZSsHLb80tdOvu45rTY0h
         M3QLoj7CBbkz1CSCXTlswIOYZT3K6xedSVsr4ZIQ06jF+Pw4we/b0Q0RYoRM678HX1f3
         E+jO1rtvIYwrFdDwb62NmBStkFZW6BWE1vOQDJE1wxo1ipczHV89CwjUbmOmNu3vjKVI
         xX+uFpQXKdIYj9hbZeF2gUwHXiaFuM8JZyJbqDjsstwHnn+yssB8WMm5StjV7+WVAA+6
         77yAV+VSI0jVDTNxFoX0ErT2/VgBLzZq8S5KWraSJhMbNLo6bHu9Ynus4oyqR41E7czv
         iJ7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=iOF1SAPRBnEPEbZ+SxJke6JWECYMQk69+WplrF3r10Q=;
        b=r6qxmsBU+PeJjP8Etk5mn2YaJhdzmZgPbl/yujE1XfzKnuhKYcF8lBYjqI00p2awpK
         m/0hEhDIo+okctJUsugddgVKKMjPUHcRCdI4ettq0tPIZc4dml/ZpyZ+4ei1O4zo6TLE
         hXEQO2ahBnYG2sCH053WrC5GX63EEBgKMgvS9rQ0keIXxbwk6yeGxDP7qQGaykfWnfxa
         FbOSqAAnx0O93Jf+B+Sp0gnTc7/7EhmR5VUIV1uvuDbfCD+09kPKirU4NdEWtVXc+Uzs
         TkTAFg/qybZ5pCYat7283OTw7ma6KCnYLXxXM9TEHWh8ZHOPYzqgFq2h5vBQh0Kinnwy
         lNpg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vladimir.murzin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vladimir.murzin@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id h24si1237234ejp.115.2019.06.11.03.15.47
        for <linux-mm@kvack.org>;
        Tue, 11 Jun 2019 03:15:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of vladimir.murzin@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vladimir.murzin@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vladimir.murzin@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 6714B337;
	Tue, 11 Jun 2019 03:15:46 -0700 (PDT)
Received: from [10.1.29.141] (e121487-lin.cambridge.arm.com [10.1.29.141])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id C8DCD3F557;
	Tue, 11 Jun 2019 03:17:27 -0700 (PDT)
Subject: Re: [PATCH 02/17] mm: stub out all of swapops.h for !CONFIG_MMU
To: Christoph Hellwig <hch@lst.de>, Palmer Dabbelt <palmer@sifive.com>
Cc: Damien Le Moal <damien.lemoal@wdc.com>, linux-riscv@lists.infradead.org,
 uclinux-dev@uclinux.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190610221621.10938-1-hch@lst.de>
 <20190610221621.10938-3-hch@lst.de>
From: Vladimir Murzin <vladimir.murzin@arm.com>
Message-ID: <516c8def-22db-027c-873d-a943454e33af@arm.com>
Date: Tue, 11 Jun 2019 11:15:44 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190610221621.10938-3-hch@lst.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/10/19 11:16 PM, Christoph Hellwig wrote:
> The whole header file deals with swap entries and PTEs, none of which
> can exist for nommu builds.

Although I agree with the patch, I'm wondering how you get into it?

Cheers
Vladimir

> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  include/linux/swapops.h | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/swapops.h b/include/linux/swapops.h
> index 4d961668e5fc..b02922556846 100644
> --- a/include/linux/swapops.h
> +++ b/include/linux/swapops.h
> @@ -6,6 +6,8 @@
>  #include <linux/bug.h>
>  #include <linux/mm_types.h>
>  
> +#ifdef CONFIG_MMU
> +
>  /*
>   * swapcache pages are stored in the swapper_space radix tree.  We want to
>   * get good packing density in that tree, so the index should be dense in
> @@ -50,13 +52,11 @@ static inline pgoff_t swp_offset(swp_entry_t entry)
>  	return entry.val & SWP_OFFSET_MASK;
>  }
>  
> -#ifdef CONFIG_MMU
>  /* check whether a pte points to a swap entry */
>  static inline int is_swap_pte(pte_t pte)
>  {
>  	return !pte_none(pte) && !pte_present(pte);
>  }
> -#endif
>  
>  /*
>   * Convert the arch-dependent pte representation of a swp_entry_t into an
> @@ -375,4 +375,5 @@ static inline int non_swap_entry(swp_entry_t entry)
>  }
>  #endif
>  
> +#endif /* CONFIG_MMU */
>  #endif /* _LINUX_SWAPOPS_H */
> 

