Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2A74C43218
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 21:17:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B5BFF20675
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 21:17:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ZlYs5ibW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B5BFF20675
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 16EF36B0003; Thu, 25 Apr 2019 17:17:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 11E9F6B0005; Thu, 25 Apr 2019 17:17:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F02B56B0006; Thu, 25 Apr 2019 17:17:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id B75546B0003
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 17:17:43 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id b8so506936pls.22
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 14:17:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=T8Ig2ZFPcz4x6x7b/gKayN8ay4uFZ6L4KXn32goDycE=;
        b=fJ+DuBkZv/y5mq6MIQSAASFl2Ff7WufsmYJVygzzDlgY3gUUiAjjBll+kDiYj+GcVB
         /OgcirIHGBM0IARAWua3oNF4xDwHt7WYhVlrMbpmPSWcR6OQorHaXKERNIb6z4vzKinn
         BM1TtFopIAOML0LvajoTLZsnw77y2H04XXE9aUBCmRHR6dhQeWGOOCZ3SxBtPhFFfr/X
         4kRRUKpcJxOtlURi0n1ZNPyqzb0WvVN2sB01a0rlxt4o/CaPmhAi8m034TB0Y1asp9qd
         uTxpLvBa9j8L38Mimjf03Zo+QrsfjLQOccQFjdPWbsBaiZ8ytTswaKzFLV7cwcqobgOl
         wOHQ==
X-Gm-Message-State: APjAAAVvV0x14Eh3YZ5pAQWHHJt6a72A8tuTAgom5biIeZ2BTr+JcW4z
	qFr59fDmgNwpRs9vdi/yoOOHHNIMOFNebbbHUw30aRRDqaImjjLEl9XbtYQNCn8u+zV/u5Xu5Fv
	GA+YjB+jRdvCIidLxCpLqL+Jduo/c1Kj2Zd6bv+0j00PMXQqaS6Iq4VAtaMFK78iv0g==
X-Received: by 2002:a17:902:e490:: with SMTP id cj16mr42002044plb.156.1556227063448;
        Thu, 25 Apr 2019 14:17:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwLGEVih067HQZY7lqptscKrwwo8K1dbKd17GJXgHIaW8iEOelZWaCwlDyPjerl1ukVJ7rP
X-Received: by 2002:a17:902:e490:: with SMTP id cj16mr42001992plb.156.1556227062724;
        Thu, 25 Apr 2019 14:17:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556227062; cv=none;
        d=google.com; s=arc-20160816;
        b=txf0azdHDLxH6Fg/nvh0bAlItehsTucWhKmlHe97MV97deQuEi+1kyp0ulWYiE4loJ
         5P0+Nad/BqGPTx425Ev0XrHWZ4CU3kBGicOHxW7PE5Hri2VWt6XiqpSAHZJTm7hlWiOL
         /ZNX4l7+88R9BIxjvj72Rz+Tt3YEdJ9SLeFRKvYxZ6cD57f+4h+ITkutcTU35F09usU5
         AdHfODZjUbI1AXHEreClqmZJjtGVrKQStYE2WhtuDsQJLfWd0qCRCzS5lOpqKp3ku0AY
         AtK/9KC7fvcyj9nw7SC40vQUfYBN0vF1leb2PGHFE6rpAc4xNq2u+6ns9ZyrQraDqYWT
         ynbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=T8Ig2ZFPcz4x6x7b/gKayN8ay4uFZ6L4KXn32goDycE=;
        b=letcsWHojj7ImIlO+xcFuNQJuhBPdgcx+NpPaXAGwltlGenEUzlDMuN5EV4THs+uK+
         dI6T0nipAcxxPJCr7WcFqIvennGbg+aS/sQdJWDA8UWNHg33tYx1E+c0omwQkiXGQv4a
         kraCX4rI8ZoBhDXnsSssdGBpwFwD26wZ6zSkVdpop8rMY0ahcNgN3gszR5a9P8GQ2IE1
         bteBpXaHxS0M2WHMR2HPYTCTGe9/0t1cvvG0YxxE5Uei+siInzrKeOzMNm05hnyipOQM
         2mPUzJlzT9cpcfQFxU2LTphaiSssHQwdS4sLtVcNMr7g1PQgMvV8RzTS20BHYu2zPQyU
         dYoA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ZlYs5ibW;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id ce8si782170plb.149.2019.04.25.14.17.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 25 Apr 2019 14:17:42 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ZlYs5ibW;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:In-Reply-To:MIME-Version:Date:Message-ID:From:References:Cc:To:
	Subject:Sender:Reply-To:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=T8Ig2ZFPcz4x6x7b/gKayN8ay4uFZ6L4KXn32goDycE=; b=ZlYs5ibWcxk6J0BEhck7ND3su
	7JyGwvZrP26ZX55YcsSKvI2Z7qAambt3ZQAD7ueg5KIDQSoN0iXZFEY/dWPCKl/2BJQOQsNOIOiu5
	qch74kq3Z/4QCSvOyWyiUNmJqYlMNLzdythhF9aUUF8ZC0AcnkNaQtkXrHh0WEg27JFJa1B83y4m1
	rIVbw9aWPU2PucvNsGa4p2oyEP6vYysOxHyFtQEWWrXv5VxfwzC2WxUc8oYb+lzEXj683LJTOh2eW
	3lu/km/bGOJq3qHAwJ5KldkibjIhg+WgZqmAxcKNx9qC8uaTdbWlTcY6J0uIDY9BaJ23bWQRkBX3P
	czut3LJ4A==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=midway.dunlab)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hJlkQ-0003FQ-Rf; Thu, 25 Apr 2019 21:17:38 +0000
Subject: Re: [PATCH] docs/vm: Minor editorial changes in the THP and hugetlbfs
 documentation.
To: rcampbell@nvidia.com, linux-mm@kvack.org
Cc: linux-doc@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>,
 Mike Rapoport <rppt@linux.vnet.ibm.com>,
 Mike Kravetz <mike.kravetz@oracle.com>
References: <20190425190426.10051-1-rcampbell@nvidia.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <f31fcabc-3942-4359-1da8-1349350e692f@infradead.org>
Date: Thu, 25 Apr 2019 14:17:37 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190425190426.10051-1-rcampbell@nvidia.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/25/19 12:04 PM, rcampbell@nvidia.com wrote:
> From: Ralph Campbell <rcampbell@nvidia.com>
> 
> Some minor wording changes and typo corrections.
> 
> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
> Cc: Jonathan Corbet <corbet@lwn.net>
> Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Cc: Mike Kravetz <mike.kravetz@oracle.com>
> ---
>  Documentation/vm/hugetlbfs_reserv.rst | 17 +++---
>  Documentation/vm/transhuge.rst        | 77 ++++++++++++++-------------
>  2 files changed, 48 insertions(+), 46 deletions(-)
> 

Acked-by: Randy Dunlap <rdunlap@infradead.org>

Thanks.

-- 
~Randy

