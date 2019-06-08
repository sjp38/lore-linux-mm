Return-Path: <SRS0=+Baj=UH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4EA0AC28CC5
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 08:49:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0681E212F5
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 08:49:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="iUebSp4g"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0681E212F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7A9A06B0273; Sat,  8 Jun 2019 04:49:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 759C36B0275; Sat,  8 Jun 2019 04:49:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6488B6B0276; Sat,  8 Jun 2019 04:49:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2FFA76B0273
	for <linux-mm@kvack.org>; Sat,  8 Jun 2019 04:49:55 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id v62so2997281pgb.0
        for <linux-mm@kvack.org>; Sat, 08 Jun 2019 01:49:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Pc64FXF/YPlBK6WpAw3gK4j6mLFmyQzV+riQYtwKZZ8=;
        b=V//YntcOzEHK8VmiFgeqU+pVJgNxlOcFLjU++OkdSmpPKIyCb3c/ur4AQqnIsrNcU6
         Ne3JMlFDKjYfyYsOjF1wok3M1eACb8UrBWKWbV6GWE+O2NWJy5PomTqJimEj2nch2/iu
         oV6JzA9wtT6LoRpHRPcZS0k1Ey0fctbR8Un492ujcRByw9q52AErcviMpihMxnUyS4Hx
         RBsUc3+KRgRSvINom3H94Jv5rmpVm2LulOYoh6kYoYS1Mi1leTEg/4d/hb6ka/qe9FfR
         JH6V3kS28Q3z9OP2l4uoJMAKnu4ie8hw9JGDLzdILvnEVy/xqwgkmQFt9vSPSM7NEdGb
         osFQ==
X-Gm-Message-State: APjAAAXj0u864lQ6v4uUVQ4nnylKRXvPEW1Xf/Sz7JiKvEmdCN01C1b5
	dFmZb4Rbrs5vK6ErQh+Ue3xoEsw1hGXwEcm3d7wJzDyh5ca2NK38e/TRZ6Ts86wRee5CNdWEVQ8
	JhvdnMYo68307MtpZduVma5jPG6x1uCriKnvFwYk0Qf7VWxxdH/Tcy/DFPLrpMZYPVw==
X-Received: by 2002:a63:1854:: with SMTP id 20mr6524294pgy.366.1559983794678;
        Sat, 08 Jun 2019 01:49:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw06wsX72j7k8U4bEx+Ap4axZAA/v3uWH7DgqHaAeWDF4F1RIghRJnIYgz9eBO/UjfS82Xu
X-Received: by 2002:a63:1854:: with SMTP id 20mr6524251pgy.366.1559983793867;
        Sat, 08 Jun 2019 01:49:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559983793; cv=none;
        d=google.com; s=arc-20160816;
        b=0sYCQNaIG9I9bOffn/VLkcaxAkEjazH0mMnm2YwsxwjGlYP1ccOb2uXsddung+hCcx
         74gAD5mWGRV/OfK4+mfVhOmg6r8ZVUmgaoLEpuF+8B88uawmz+PYzwUR1RyiDFMA+Awx
         mGUCmhlL+BJRIcOUeSJaOrTq9oNra6OcBNjGuj+VazcgUHReOtiwoiM0vEZxFgjf4O8t
         NLmq/f84uwrgF5ckeVnQXN2kap9vYaz5rd2hHxNqYb8paK292qCD9CoUc18izoMpZxGa
         JEe9PMgnVSfI9edn+QH5A+81R4BYXf/tIt7voWv940Ler93Kqp41QLG66o9Hxuzggoj9
         Vjng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Pc64FXF/YPlBK6WpAw3gK4j6mLFmyQzV+riQYtwKZZ8=;
        b=C0xpC8DErZ9msLlfRecpA58HSJGwyo7BvPu5pF45lebvlklNTH6XUgCq9zP20HuRMF
         Sqag2vmRH4/eGYFfTRsIicI+qmmw+HKek7JAvBtHUyDA2khA7ypONp8gzvsxZ2eTHdWq
         RNEE3ZY5Tkqxfma7UqQ/X0lG7lnjqT1qjOZBTZJdvDWo1DMoH7ONMNvgIprQ2L2riXBs
         3O9mWbM8Dvq2chEyulSHUltduqtNz1Nc9XuPq0dpfNu1HO2M8b5PF/A9oNvM7P7nplpQ
         GB2w0HnYs1z/V02QKIgr+x/QhbT2xXKZxYYHCdx9knb7CJMUmTtaMaCBakaLItFbUANP
         LJxA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=iUebSp4g;
       spf=pass (google.com: best guess record for domain of batv+ea1dbe8c224dc30aa319+5767+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ea1dbe8c224dc30aa319+5767+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id ch15si4293016plb.316.2019.06.08.01.49.53
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sat, 08 Jun 2019 01:49:53 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ea1dbe8c224dc30aa319+5767+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=iUebSp4g;
       spf=pass (google.com: best guess record for domain of batv+ea1dbe8c224dc30aa319+5767+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ea1dbe8c224dc30aa319+5767+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=Pc64FXF/YPlBK6WpAw3gK4j6mLFmyQzV+riQYtwKZZ8=; b=iUebSp4gV11prU3sOG7JF9FrI
	2JuHQ5xbLQgcMlsbPMssFX2B3mrdBqWjQjCtT5FVX6Ts2YmlNuv9z2IDexlxenS8UA0Th1fTEIKmm
	CR0M0LG9PqU4UitFs5Sf48yXHiKoecKfHQkryI2EyS8Di/+NNBxfM/MsV6R4pkffLD/8OpwqoSUgx
	7ctwS1whpMBBN/zH2e/X3zeALM4+4BZ6DOka1TloBghQ+uhU+mwfmzEWeCbmLn1wvvbnTBurEPqSd
	NnK+dH3j9gpXegzaYCHj783Wr+QDG4YBKckxG3fdF295yQrVSwBEjg5MN1S+JmRQY9LJDYC1jHhr+
	AUJjRe9kg==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hZX2q-0001tl-4j; Sat, 08 Jun 2019 08:49:48 +0000
Date: Sat, 8 Jun 2019 01:49:48 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, Felix.Kuehling@amd.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org,
	Jason Gunthorpe <jgg@mellanox.com>
Subject: Re: [PATCH v2 hmm 01/11] mm/hmm: fix use after free with struct hmm
 in the mmu notifiers
Message-ID: <20190608084948.GA32185@infradead.org>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-2-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190606184438.31646-2-jgg@ziepe.ca>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I still think sruct hmm should die.  We already have a structure used
for additional information for drivers having crazly tight integration
into the VM, and it is called struct mmu_notifier_mm.  We really need
to reuse that intead of duplicating it badly.

