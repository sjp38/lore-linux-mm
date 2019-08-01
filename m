Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D887C19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 16:00:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 02D8E206B8
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 16:00:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="bt6gngaa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 02D8E206B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 860698E002E; Thu,  1 Aug 2019 12:00:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7EA848E0001; Thu,  1 Aug 2019 12:00:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D88B8E002E; Thu,  1 Aug 2019 12:00:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2DF278E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 12:00:22 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id g21so46005939pfb.13
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 09:00:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=V+mqoypCyVp89zi7d87lU2RRcj8SerxFad94nqYfDDE=;
        b=QK/dTHGBk4OvDc9IYR7gEUSCtDtcs3u0vmGrcW1kjrS/s9elzEaNxV4/Hs282Dqw17
         +a7WnlK1NJq7HFVbPzRg8uSoAqmLMs1kLT8h6a1cu0C6JTrd7s6u9pdp7QHgEi7FSpPd
         Zsc5TljYlsWm51d6/KjtJ+XM6HD/skV4QVbOGDoWlCUHiISzCzkTqKzu80Gz1g94GjRp
         OcTd0xeeVvO+CWQJtN1rizP6by77WrpNhqly3mxDcCXwGegpfe/MrtZp5JsnAe2FwfES
         H5Yh9xNwyDwRI4uEXC6B+eJU81+CiQ6Iz26+XsRkWq+3WGVXQ365Oxpyd2P+yD1lg4uK
         Zw6A==
X-Gm-Message-State: APjAAAXCInDdLhaaT7Tri/AjfWYIZnbrZOBR2H2BRiXpTON+P86JHmAQ
	5b9Qh7NV6yls0+9V0aiss5AeFBNtl53kFVLfp7xdo55wg+JovpK+YeNujYFURviJqN7j7R74Hys
	G1K/82l6xaKqv6ApwN0E2dVbvSySayfjAGSnMWsz0lM0laM1X9ejYbuyjkS85oE61zQ==
X-Received: by 2002:a63:6c46:: with SMTP id h67mr112139865pgc.248.1564675221742;
        Thu, 01 Aug 2019 09:00:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzcaMm5KpkonepvkfZEw2TpUt2/iV3e5G7y1HWC5YuCGZjYj5qXRGZCr9vw4l4+qMOkka8m
X-Received: by 2002:a63:6c46:: with SMTP id h67mr112139720pgc.248.1564675220033;
        Thu, 01 Aug 2019 09:00:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564675220; cv=none;
        d=google.com; s=arc-20160816;
        b=V8RAAhw941caEKw3OXV47qh5MBo3Qi3BDvWNiWO59IRK4PaDnQrYblL/uySdMD0I9j
         EWUVD1aSGk5mDOanJDnBA4W8zKUmCfLXckH100TAPt+yIzOA3kGC3/srcuHnVUr/qpzG
         o7Jh0m+KIiSe+ZGeceqSrmNB/eUez1+q+7/LRxTqPn7SQcqFIdUKaXlq/uNMyfq+nT9Z
         s1OCShzH9UOLnhv7PW6K4JeLG9HejkboPwdHMj6VwcafZHCinNSf+goJLXohrTGuP/yw
         2bLFzEN8+laQYXqcV3Sa08p6mK12Ur/KGcv+pAsawZUQbwMWw9WXncLncJ1Yq8iGCefm
         H8rg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=V+mqoypCyVp89zi7d87lU2RRcj8SerxFad94nqYfDDE=;
        b=irgiPoq1dhGWjU6zLZ8/W4oeRBoEotCdxIMLPy6Pb+A5gXnP07cs6tuV6MIVoU6ckL
         Gpd/aiZk3LOdzt77K9xBkwu72elV5o2pCQeMSGTvDE4RJtP1FYl/izc/wxllXbaM8cNs
         1alrFpQFivmsLAigk3Z28bPHTMkI73IqUKHBKjJNDIhhJwcfxTFv0ycHGgSo3Y4LIryK
         ZTVwe7rbvwGJUTjtw+INajTDhYWWnNnEE9EgrTXwwr6Wkqm7KyleyVNgiDHdwC02mfqC
         d52GZNq1TgUHFEpvY0RAzs2TOlmavy0O1qYj5C6CzJsS3eYGtl7BGeixJFYkyChqBT28
         SFCA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=bt6gngaa;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n124si30659605pga.214.2019.08.01.09.00.19
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 09:00:20 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=bt6gngaa;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=V+mqoypCyVp89zi7d87lU2RRcj8SerxFad94nqYfDDE=; b=bt6gngaaXNa1IgChUaFBMxOpq
	K1NbxFgScMZWeTQ73hgbZzAx4ufmsIUGLnz6lvvQJ6x5x9kT/i9sPC5jWyLi95xJWvW/47+MXAtDF
	rIxaoHaEtcFSyXxXF43v5KfgS3OyU+4BBTPDlndKEqrlEelpyXpfgbdl/mRkRLZAk+Y2fHVQc94UV
	tkOs/n9yRp+Ps6geOWY44SabkW5UBW5WXk+7k+AnO/GP2Wm1vCshU0UK/vFtMMGX9QwUueUrIm3Zn
	t0n2fDCZJ7ATyuYUOHF42+YhnnsUNO6xeZyKRmo1uYSWE+FaIzApgbGwXzYKGGlgHQJHoe84ILoOy
	DDx8UpF5Q==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1htDUz-00024S-4b; Thu, 01 Aug 2019 16:00:13 +0000
Date: Thu, 1 Aug 2019 09:00:13 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Qian Cai <cai@lca.pw>
Cc: catalin.marinas@arm.com, will@kernel.org, andreyknvl@google.com,
	aryabinin@virtuozzo.com, glider@google.com, dvyukov@google.com,
	linux-arm-kernel@lists.infradead.org, kasan-dev@googlegroups.com,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] arm64/mm: fix variable 'tag' set but not used
Message-ID: <20190801160013.GK4700@bombadil.infradead.org>
References: <1564670825-4050-1-git-send-email-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1564670825-4050-1-git-send-email-cai@lca.pw>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 01, 2019 at 10:47:05AM -0400, Qian Cai wrote:

Given this:

> -#define __tag_set(addr, tag)	(addr)
> +static inline const void *__tag_set(const void *addr, u8 tag)
> +{
> +	return addr;
> +}
> +
>  #define __tag_reset(addr)	(addr)
>  #define __tag_get(addr)		0
>  #endif
> @@ -301,8 +305,8 @@ static inline void *phys_to_virt(phys_addr_t x)
>  #define page_to_virt(page)	({					\
>  	unsigned long __addr =						\
>  		((__page_to_voff(page)) | PAGE_OFFSET);			\
> -	unsigned long __addr_tag =					\
> -		 __tag_set(__addr, page_kasan_tag(page));		\
> +	const void *__addr_tag =					\
> +		__tag_set((void *)__addr, page_kasan_tag(page));	\
>  	((void *)__addr_tag);						\
>  })

Can't you simplify that macro to:

 #define page_to_virt(page)	({					\
 	unsigned long __addr =						\
 		((__page_to_voff(page)) | PAGE_OFFSET);			\
-	unsigned long __addr_tag =					\
-		 __tag_set(__addr, page_kasan_tag(page));		\
-	((void *)__addr_tag);						\
+	__tag_set((void *)__addr, page_kasan_tag(page));		\
 })

