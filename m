Return-Path: <SRS0=cZWw=UO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84925C31E50
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 14:14:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3A3C02080A
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 14:14:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="NDaar3aY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3A3C02080A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2CF5D6B0006; Sat, 15 Jun 2019 10:14:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 257B48E0002; Sat, 15 Jun 2019 10:14:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F97C8E0001; Sat, 15 Jun 2019 10:14:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id CD4DE6B0006
	for <linux-mm@kvack.org>; Sat, 15 Jun 2019 10:14:39 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id f9so3766402pfn.6
        for <linux-mm@kvack.org>; Sat, 15 Jun 2019 07:14:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=6K3IZWimfXFDx5zlj0FydVfqj2gXTabKUZsGz9eiwgw=;
        b=sZ6jAM47Apo2BsK7midKOMO7H7fgvGs5ibnv8Zn35AIouTYZMk9t8oW9kNnU1oRgoH
         1ECCN7EvYdK3EGSd1QMtyrH36JwEhr0NisECTP8a3kbP9Kecn5eUgXeNJ9Vyw0JgViDe
         1m5xTLRWcEl0GmtbNSVUNFyiI3EhSZFbzhDAxSZKwKhotlFCLfwLzFOH+ScMVsA1U89R
         4UGLcIsZI32Fw1K/yHQ64/jcK4BRQy6xhOZxZn3/5Md4OuyptF0eAX0I2LEbjvUDMxRc
         CJFlbwUL3XPBgLiD06sGZrzSbQZct6HflrOTY3OumHQEErOjeXDabfrP+cIrYRw8eMIc
         //ug==
X-Gm-Message-State: APjAAAUvVL/lRSbkB1bC83i+H/XoxNCj/WcwoAxfWOUjW+SXE/0+AyOd
	b4rYVg7en9GxhU8PaI1xK9cAg2TQ9eh2o7gx/EFXKTFSl0917Dw744U1QlLmm3fAogeGCRSyVSf
	fBqGzLLopcMu5nkoDZo+Wf4PBtDu33+ZyofH/iqbSCtm21HUzyWzOTB4J6ytR7C+WQQ==
X-Received: by 2002:a63:6841:: with SMTP id d62mr40120287pgc.17.1560608079457;
        Sat, 15 Jun 2019 07:14:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyAxPTpVJjjflKfB5pdUuOgo09+q/NadoWUDO5isj09+QTag1m/U9mHsZOU2fY5nmB7DgSi
X-Received: by 2002:a63:6841:: with SMTP id d62mr40120254pgc.17.1560608078857;
        Sat, 15 Jun 2019 07:14:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560608078; cv=none;
        d=google.com; s=arc-20160816;
        b=JyXNqllvzo4PBntkBa/JVi/6YuQFUPJ2XzgcQCjJWJgFG5ngC1S0Ccy+LolRK8IYNR
         JzcGaGCSD0+9RknqO0OMPay7e/1t+R58nLR6vrA1Acuix6r8XlX2fhuo0qKQlDFbqkKo
         pe2TlLjk9nZCUHTX4jF6lv+wyMeyZElOuJcGe5InEtxBsDeu+3Qk5meXwmYEv5cdgfZ+
         wOYvccm0PKVjHXyh7yGrGMptK4ifmt3GiJsLB27hVnZxEsB0PAk527xVZJVFusge+5yz
         92PREsiYCAeJt7de+W7fgtupTwsOhSqW/y2/kyOkpjVYos6inpFn6cIeQ6t/EoJZVWE/
         WdEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=6K3IZWimfXFDx5zlj0FydVfqj2gXTabKUZsGz9eiwgw=;
        b=fdNGc+jhWam34lZmFH32p0rF0ZlThbqet5L5W9zQ1EkriPzcjJAakVa+kKslIXZqRk
         oi5c3kp6cv+q1a0+khuVLXiRH+NoNzZYFfTlzizQRfpkkxUqykpmxjma9fb5eWqakN6G
         ftZQbDeofPq4ivxdauOOg0odNv4vC7nBGbACmITA/4pOLLzmJ1droYtRxCu2LHIrz3wv
         NaJzAb9lsGmZiEXkE6MT6NfrNPyAT63PBdsYvzPuabvhNv3aWlrn+I7VrT3m1NkhlURy
         kV9nTR7AHoIgiJUlyzIL9MyK7rG/Q49ZTei3oHTdqRb4vRpOlmwyhEq4+x7J89hht0OL
         yBYA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=NDaar3aY;
       spf=pass (google.com: best guess record for domain of batv+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 194si5571437pga.203.2019.06.15.07.14.38
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sat, 15 Jun 2019 07:14:38 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=NDaar3aY;
       spf=pass (google.com: best guess record for domain of batv+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=6K3IZWimfXFDx5zlj0FydVfqj2gXTabKUZsGz9eiwgw=; b=NDaar3aYYUTqIadeUzt3fjl5e
	xTvini6vXAxFVVQTpQjC/ZVFmzryOfabxlaFlyZA9bhVT+06royjNgkE6cNob+/+Zo0FZs6bvV6i2
	VV99tEpby1InU8VhqJHXDCu8OrpmNPZf177PEPtOvB64PS4aPV7XjPvCz0pCp9kzA00pOYzzGBUDW
	GenFaGRR1yzUlw7nCrOkq+FP9YqBtZNwe1bMN2gEUOqCCy6Na/j6nAQDBCzPKIOyZbbXEwoKCXER8
	g8r+0iep8vK1xgNwY+knre1ESI1PCehtG9SiyEQby/7Vugv6F9vqNXIS2/CraTZJ8jq/eDJjaRazX
	3ehroctrA==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hc9Rz-0002Dl-UH; Sat, 15 Jun 2019 14:14:35 +0000
Date: Sat, 15 Jun 2019 07:14:35 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, Felix.Kuehling@amd.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org,
	Ben Skeggs <bskeggs@redhat.com>, Jason Gunthorpe <jgg@mellanox.com>,
	Philip Yang <Philip.Yang@amd.com>
Subject: Re: [PATCH v3 hmm 06/12] mm/hmm: Hold on to the mmget for the
 lifetime of the range
Message-ID: <20190615141435.GF17724@infradead.org>
References: <20190614004450.20252-1-jgg@ziepe.ca>
 <20190614004450.20252-7-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190614004450.20252-7-jgg@ziepe.ca>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

>  	mutex_lock(&hmm->lock);
> -	list_for_each_entry(range, &hmm->ranges, list)
> -		range->valid = false;
> -	wake_up_all(&hmm->wq);
> +	/*
> +	 * Since hmm_range_register() holds the mmget() lock hmm_release() is
> +	 * prevented as long as a range exists.
> +	 */
> +	WARN_ON(!list_empty(&hmm->ranges));
>  	mutex_unlock(&hmm->lock);

This can just use list_empty_careful and avoid the lock entirely.

Otherwise looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

