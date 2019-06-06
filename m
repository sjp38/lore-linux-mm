Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C219C28EB4
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 15:57:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 12FF42083E
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 15:57:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="LUIT7ffv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 12FF42083E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 982696B027A; Thu,  6 Jun 2019 11:57:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9368B6B027D; Thu,  6 Jun 2019 11:57:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 44F9D6B027E; Thu,  6 Jun 2019 11:57:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id C18B26B027A
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 11:57:21 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id i4so2295424qkk.22
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 08:57:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=BclZtUvUWc52VCIk0ekElvDVjs6/3uKQ5inY0X8kkuI=;
        b=sGuDCb4niIAf16kQiBYKjVz9Wi8B2Fbj9ncGuokSh3bKzOKfjlXS45fW8IMD+k8rGU
         kDFLEvTCYYJwSgq3VhFAZm42Fo11ANzZv7RH1CdMdBBnzy8zw4dnrwKzqoccrjpzqH7K
         zz7Hrfp28qdqmUy1nxpwope9jDylJaUeRa/1av67t5QOemeSgjLaBfqKypioWDmoQ5yR
         NlLMOygWZ1rQKqi3gF1TT1InwL4+whIoGmW4fRj1uw8XvN2AFhQhC5wT+2cioZWx3C1P
         97qJ19RtMeaHkxL/sa1RVUOJkRvLn2AI9UjShv0DcdSbAMPy7x2RXQS9vO25jKnBPvXj
         51Nw==
X-Gm-Message-State: APjAAAVsXu4BHkZVgrULVIDXUZPUL5HLMnReBLj6UKdpa+hOAQHN9FiJ
	pLkYe+WFy65oGrcZcxE4JmxrNK74GoaFR6QxJkiDZDqupy0c4t07uQrENCx0AabquFqi1a7Akzy
	nhvXp12w6/Y67/+VTJQRGnd+I9vZ7BQUdx+mvvzHwdUTXaJ4o+nXXvdaKhTHqLWFBoQ==
X-Received: by 2002:ac8:3345:: with SMTP id u5mr42347446qta.219.1559836641143;
        Thu, 06 Jun 2019 08:57:21 -0700 (PDT)
X-Received: by 2002:ac8:3345:: with SMTP id u5mr42347407qta.219.1559836640662;
        Thu, 06 Jun 2019 08:57:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559836640; cv=none;
        d=google.com; s=arc-20160816;
        b=WIDEFVkM0bxMXKIi289WfPlP+Ji+f/c4wQa+Bneip3f50nC1PKuUteLj8v0xLT+hOW
         vddeesF3YX+VwEWlHh9SK9qipDIxK0uzvkmU0NYwxa+eVMCr02Z24FxHmczByZbxmHcf
         SGFzSLDJg6t5EhDPQfJ6hr92cAl8+mFCmcA+5IWSTer/gERs/CqjfgtuSYHIsMHqbTX/
         Jxaorpp1mLb4mhrku3eIqA97EChaOeVb8iUHOOK2keZ7rh9lhP2lPfRdPrKJ8fCYqNyI
         Vh5uyL/iI2phK0FjdT/QPvmDhJ/VRSfd0+oSSyOlOtbQwul+G8t7yP8BX6Vzt3gpMn2D
         9eXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=BclZtUvUWc52VCIk0ekElvDVjs6/3uKQ5inY0X8kkuI=;
        b=F1F1mnYW7nAccCyt04eXbRhcy9zI4WrlJp5g81NB4okubU+oFApfQpDAC6VCiEJB3T
         b6T97QRY5oWB4AEpGoQ0fgAI9VTf2NimPdbk78Xt1DLPiG6aIH2K40yP8kJxievsEYzq
         YzJKwaa6bWaypKY/avKfQOf9UszMU9hSrVXlZBmYzV9u4uyCvz74VKzsO6OWQpXnpNkR
         byWTbQTelxabJyaHuRX0qChy9eQ/0FRi6uSvR4VI2dLgTpP02+EHKqEsZyOH518zgv6C
         PrDSiPxIOZ9UotIX88Y+VvyX2fGN05Bb/W2w/QEKYKNY1yI4yEPgVr3YHKI9WVWTR4oE
         nR7g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=LUIT7ffv;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o24sor1712650qve.65.2019.06.06.08.57.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 08:57:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=LUIT7ffv;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=BclZtUvUWc52VCIk0ekElvDVjs6/3uKQ5inY0X8kkuI=;
        b=LUIT7ffv00SVUohWewknTief0H6RArfZ7fTV9DnvQHDw05QmEs31LxA7dm842AJx2R
         DOosa/xn9kqrepdggtOE/obTNjYEatLl5Lu5GDR9mapllBqtwUBDk0AfQBTvangt6Fwt
         jpN32yUGSZWUXzBDbmIG2HvyQOTHkMZ3YUlxARVqw2GoiwxJsew0qEhZqA54IhN24XWM
         7rptQCdUKPBNRmsKHqYrm4Bt4VincY9ztD0EtoAlFrwOyN78/ZayVZgZnJlGQMv3Iu/c
         InVQJilQARTgohC3huuqiOCaKFCIs0Qg05uMeFu+lDeqP8RC0cVu5roUWXb+HkI8CYiv
         w+ig==
X-Google-Smtp-Source: APXvYqxJwPKcKYHeIEBqgKbv9g2tly5rhw5pFPANBuNbuQFP+rCjnmF5gwMOQCRJtt8Y8fn+GE8eZA==
X-Received: by 2002:a0c:b159:: with SMTP id r25mr13707464qvc.219.1559836640407;
        Thu, 06 Jun 2019 08:57:20 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id v184sm1061841qkd.85.2019.06.06.08.57.19
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 06 Jun 2019 08:57:20 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hYulT-0005QQ-Ix; Thu, 06 Jun 2019 12:57:19 -0300
Date: Thu, 6 Jun 2019 12:57:19 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: rcampbell@nvidia.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>, Ira Weiny <ira.weiny@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Matthew Wilcox <willy@infradead.org>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/5] mm/hmm: Clean up some coding style and comments
Message-ID: <20190606155719.GA8896@ziepe.ca>
References: <20190506232942.12623-1-rcampbell@nvidia.com>
 <20190506232942.12623-3-rcampbell@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190506232942.12623-3-rcampbell@nvidia.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 06, 2019 at 04:29:39PM -0700, rcampbell@nvidia.com wrote:
> @@ -924,6 +922,7 @@ int hmm_range_register(struct hmm_range *range,
>  		       unsigned page_shift)
>  {
>  	unsigned long mask = ((1UL << page_shift) - 1UL);
> +	struct hmm *hmm;
>  
>  	range->valid = false;
>  	range->hmm = NULL;

I was finishing these patches off and noticed that 'hmm' above is
never initialized.

I added the below to this patch:

diff --git a/mm/hmm.c b/mm/hmm.c
index 678873eb21930a..8e7403f081f44a 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -932,19 +932,20 @@ int hmm_range_register(struct hmm_range *range,
 	range->start = start;
 	range->end = end;
 
-	range->hmm = hmm_get_or_create(mm);
-	if (!range->hmm)
+	hmm = hmm_get_or_create(mm);
+	if (!hmm)
 		return -EFAULT;
 
 	/* Check if hmm_mm_destroy() was call. */
-	if (range->hmm->mm == NULL || range->hmm->dead) {
-		hmm_put(range->hmm);
+	if (hmm->mm == NULL || hmm->dead) {
+		hmm_put(hmm);
 		return -EFAULT;
 	}
 
 	/* Initialize range to track CPU page table updates. */
-	mutex_lock(&range->hmm->lock);
+	mutex_lock(&hmm->lock);
 
+	range->hmm = hmm;
 	list_add_rcu(&range->list, &hmm->ranges);
 
 	/*

Which I think was the intent of adding the 'struct hmm *'. I prefer
this arrangement as it does not set an leave an invalid hmm pointer in
the range if there is a failure..

Most probably the later patches fixed this up?

Please confirm, thanks

Regards,
Jason

