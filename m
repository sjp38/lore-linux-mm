Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 921B9C31E51
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 05:37:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4CC9920679
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 05:37:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="VFk5UR+X"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4CC9920679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CBB288E0005; Tue, 18 Jun 2019 01:37:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C6ABC8E0001; Tue, 18 Jun 2019 01:37:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B593D8E0005; Tue, 18 Jun 2019 01:37:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7E6888E0001
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 01:37:40 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id u21so8543735pfn.15
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 22:37:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=tV99K2d8GVHSoZ145rfgnhmZCC9mL4mRsMkgqsk8d2s=;
        b=OQ7WRAv9UHcwDNEuZH1KhlkMe4KUlz18mMBlodhnfpt9dxYELQd6jiHtWwiz3Z6UbG
         8lsc/sqAgwF4G9SvGFOOf6jVTxtad6949qGW0Qi2Yii7E8mspWsUZiMFIqXKd+PMVMOS
         I95XNiQvsGvVsGAI5+qpIuYPHNdcRh/IB0VsOZB4lUoW5nsYPq9mjzGjzpHBebY0W0Y3
         hi70qwUmixK9Cq0nnSDPRAfyCZ2uCW2mx6MsUkUfg8famoRkq8zpCshETPUFQoVTqhEF
         s8piaxHoNFzjpkdNjJO/X+UpNFuXtXbNNLEIkZPHGQrAk3gHAJsZQpTeMUSd3SbkHEfz
         PTzA==
X-Gm-Message-State: APjAAAXSyZLNS63tmbsRl3yjsSUAgpgRU7wpTr/NOV1hik6lAQorBoj2
	ryP8IzQc+tEv+XBygkSAdt5Cm7oYqwz6Qlb3m7SoTvEeTEEFSewQpTHK0ANzwu3KnwyUnIIqWSy
	qylrRcr2ErdA4lkpCI9WwocnC5ZOsLiTbUccAqBQiBclanrozYkvzqKKVQ/x9rjhVDA==
X-Received: by 2002:a63:a34c:: with SMTP id v12mr949385pgn.198.1560836259978;
        Mon, 17 Jun 2019 22:37:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwczOuRhXbSVzKZuuZorHgifPAXcPSrvZCAEwedJmhdNxzKIqShridJquDKSKQ1i49MWWNR
X-Received: by 2002:a63:a34c:: with SMTP id v12mr949341pgn.198.1560836259208;
        Mon, 17 Jun 2019 22:37:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560836259; cv=none;
        d=google.com; s=arc-20160816;
        b=Erfhn73VNV0EBbekNTneS0MVCcIn1BsnTjs6/jyd0Li72BYPtpN8lDyn3Ql6WqoT4L
         xC7JlIzL8nV6s32vPAA4I7wFNPMwHqnTAuEXhNjjJUj4NSEtYZIu6vDnpl3aZzOSCsmJ
         MPlrAdrRu4BRCvrDPNGnV5LM8XA6xWaQ9dBILSe5SPVvUJ/hCDo6Zk8dd/mNvlB97USc
         FFHn62sxBEA1BWkPxdzBADZAynKzjPGJStHIKsGhAoU6S6VCIskHAifVFn2q6JkhkQyI
         TziCWhc31aetNfNHWVXfyWQRjJDp4APGTfVdK2VzUq6cd9QqAARVgQEzMEsC4FurhUvF
         Gktw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=tV99K2d8GVHSoZ145rfgnhmZCC9mL4mRsMkgqsk8d2s=;
        b=gDHfFmeSTcX2CG6eWewHFuAXq9GfrJkmoqhXqnCMDC3UcAYbYlrlQ+ANXWBnwP5P3J
         zF6yPAt+Nu3NkEdzT77d05fCTTetCb06RoNOWI2XzLksbr+Fn0C3dld+rfaitxyVkdAM
         ruV6+2m1mY35Hb7at20JSNtCiHDe7Mq6umz6pAhSEZmFLnFh4hvZghF/mJB57+3/cejs
         C0IXy3guhsgtThcKwDa0GMuQA0BpTNPWj9d4re6/eqx7RFPsxaK6zkE/jVarHzG9E6wu
         3l72WsErVnjroJO/ARLouyo5wVRnqw3Fv+59iLe7A+KBybCDlHBliTCcH22mIp7SINrL
         BHrA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=VFk5UR+X;
       spf=pass (google.com: best guess record for domain of batv+aaa270176d60fe65a2bf+5777+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aaa270176d60fe65a2bf+5777+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f9si6368865pgc.1.2019.06.17.22.37.38
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 17 Jun 2019 22:37:38 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+aaa270176d60fe65a2bf+5777+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=VFk5UR+X;
       spf=pass (google.com: best guess record for domain of batv+aaa270176d60fe65a2bf+5777+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+aaa270176d60fe65a2bf+5777+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=tV99K2d8GVHSoZ145rfgnhmZCC9mL4mRsMkgqsk8d2s=; b=VFk5UR+XIAvFhHNbE76I35I6f
	5p7lqPrAl/jivCCXN+p+cSFmOz9NxFW3q/GzZH2CfzqBSKFufzN+JFGSDjo/dIxQTZiEPsvYYqzWD
	YSzYy9RDgwu/UB1ROaPz1ZEl9EY5pV5O4miFLk1fx7AzfoNx82bqK+GrG6yR/3easJuI6lhk+jWT/
	4WTD218PsDq6oZi0gydoz2rOi9QRbKG9GNJbOSSjtoKSEBW0xsg2awCi5ClkXapFLSGwx0lQwo/Em
	qEOwti0M9nkgYlIwbAtaNtKKmOJzFmEocKqjXkQXMo5T/sbmnRuCRzbmL40TF3q9QQ/oln7clT4Xf
	d4ZT4nuhg==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hd6oH-000393-RU; Tue, 18 Jun 2019 05:37:33 +0000
Date: Mon, 17 Jun 2019 22:37:33 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Christoph Hellwig <hch@infradead.org>,
	Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, Felix.Kuehling@amd.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org,
	Ben Skeggs <bskeggs@redhat.com>, Philip Yang <Philip.Yang@amd.com>
Subject: Re: [PATCH v3 hmm 11/12] mm/hmm: Remove confusing comment and logic
 from hmm_release
Message-ID: <20190618053733.GA25048@infradead.org>
References: <20190614004450.20252-1-jgg@ziepe.ca>
 <20190614004450.20252-12-jgg@ziepe.ca>
 <20190615142106.GK17724@infradead.org>
 <20190618004509.GE30762@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190618004509.GE30762@ziepe.ca>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 09:45:09PM -0300, Jason Gunthorpe wrote:
> Am I looking at the wrong thing? Looks like it calls it through a work
> queue should should be OK..

Yes, it calls it through a work queue.  I guess that is fine because
it needs to take the lock again.

> Though very strange that amdgpu only destroys the mirror via release,
> that cannot be right.

As said the whole things looks rather odd to me.

