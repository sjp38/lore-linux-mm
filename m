Return-Path: <SRS0=cZWw=UO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6CDAC31E50
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 14:12:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A6442080A
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 14:12:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="GaJFRSfZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A6442080A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 36D036B0007; Sat, 15 Jun 2019 10:12:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 31D728E0002; Sat, 15 Jun 2019 10:12:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 20E218E0001; Sat, 15 Jun 2019 10:12:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id E20C26B0007
	for <linux-mm@kvack.org>; Sat, 15 Jun 2019 10:12:37 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id c18so4037001pgk.2
        for <linux-mm@kvack.org>; Sat, 15 Jun 2019 07:12:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=l2WBiCb5duYJRA9nKpihqrJOH1Qjg6utSrFiu8qAdtc=;
        b=iGV+cF593dLfWkeCxvD6eTB5d0HncztWe+fmLBB8M7CjAo0UBBjm/NaBQMudZYzuKd
         PlZLhCtwOE5RMp9kLl+WzSZApqt7hz2MPJ9R5XxmVfI2XrBf90aI39YVP0VkiUKHsn7J
         PMpl4PLyo1pqQBgVOIrIY4dir4OU1Gq2yNMbL8IIPOX80NhAhT9AGr1rVZG7fUmGKK/A
         YaFx9CuDR5/n5ampTdNZwA82QRwJMMr3/F0Xe4IfWAJ9awL5JSvCthL4wT+5R0h97uDY
         0S37kFnvp2btvHOc74DDHAerA3L7S5YxZ+8Ex3KMzpdc7GAWDylkKA3lF4HM78XRBVH9
         AmhA==
X-Gm-Message-State: APjAAAU4CZUre3n5Uw1eluTC7bvMVANwzy6gvh8cNag6cwIzaSQPl+El
	Cpv4sYzhKby57V+iiwUqWVgn8qGev/IGCvMROa6D1n5oGlmsFpth2vKPYxgEhlv50fbgBLzEdoy
	sGTqsDWd8C4VmjZ7hPyNOvBpzCHtw9BPq6o0/6yKA3LgyKp1rtoLmo9x6L3rO2xTkUA==
X-Received: by 2002:a63:6a47:: with SMTP id f68mr22192098pgc.230.1560607957511;
        Sat, 15 Jun 2019 07:12:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxWyebS+/w3uP7Dd6H8KuP3255hSUYGoE1OSAt0dpsyJDzk4LQeectp+yNd+SehmVaY5Ojq
X-Received: by 2002:a63:6a47:: with SMTP id f68mr22192061pgc.230.1560607956924;
        Sat, 15 Jun 2019 07:12:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560607956; cv=none;
        d=google.com; s=arc-20160816;
        b=GoPxMopjCJf/soK4uG1jXoDp+o+5uLqgorsyj4jwnICfVMbsk6ZdvesL7XupQQY2LI
         H69tWw3QMe6bunt/aSeixXG561NZIRIt4yNmGpwyYU6Uv9INgEcPWbdkb+ZJt7QGTFsh
         Cij9x+Y67ERpNTjU+1RVbYM1wLY+V0++hQFeaIizJDyN1bjmfyYvOFqyT31Hq24dj6ln
         395Ha2Woc9JLddGChyJhfxmOuny54OhqpXPKjEM66/5Bq8na6RWHxNUl9YGemjE86QQv
         bBCK38eNvtMokMPpfN5oAU2rWNuclk7yOoGnFzJWRoMO3zKPtI7RMGciO5mRlj0wojaC
         K2ew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=l2WBiCb5duYJRA9nKpihqrJOH1Qjg6utSrFiu8qAdtc=;
        b=KrmD9d78ujT/+jzKvzxzjIjPu9bfdbrI/hS6hB6cs70bf8WvDzdGVjfk/E+Duk4nH1
         5/Nk8WtGAQHUmytYHIGV7M0TI18XmaFBjewB8ttjtqz+AKGphd8Z6qk26zG/cRrJndKC
         BTYDP/R4PK91URHsP3Dg8XCI9tiOP6xPdXyoLo2xs7gq2k79cfTRcDxQ3UoH217f1NiL
         PyuZSWCAptcAeJf2aNsNdSJrHZd+pmVdfgQvIwDEVClS0PrCI4tIh6rgt/JShzxNzy2P
         Ekror6kuaYThJwmdLaabAoAQsPKwj+ssU4jcKh4chS4B9BOh3gKHQRZQSLO1fBTtFiQ/
         MVPA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=GaJFRSfZ;
       spf=pass (google.com: best guess record for domain of batv+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g10si5058684plo.112.2019.06.15.07.12.36
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sat, 15 Jun 2019 07:12:36 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=GaJFRSfZ;
       spf=pass (google.com: best guess record for domain of batv+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=l2WBiCb5duYJRA9nKpihqrJOH1Qjg6utSrFiu8qAdtc=; b=GaJFRSfZZjYbqIx3dgqPvvREB
	6fLE5YkNCKrzqw+cQQ64cWG6QbD2IBNGmspcW15uAAy2iV7xNTKrKNi1wmcbFlP+HDvQTILVkuzRa
	jA7B8413GRbrbgRebPSHwaDVCSZGLyjsqXpoK/WW+a/2Y6DTV18Bpwzvemm12UAi2kXIGxTE55vSF
	kIUffaq7Sibx2QSV8C2h0KIKdHxgjbGUp2DZ9DFk/q/7Qj0Qo6YUHMwN8xE5hOd8DmOirR+6XB/pS
	HywPOffiHmu0zoeMb1DpdiuZHAPH4Q+X/n3QlQ57rOhIJiGDvkeuuP2F5ISFZ/iqmyDBSsUjqDP/w
	K3u9PJXyA==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hc9Q3-00029L-Dd; Sat, 15 Jun 2019 14:12:35 +0000
Date: Sat, 15 Jun 2019 07:12:35 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, Felix.Kuehling@amd.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org,
	Ben Skeggs <bskeggs@redhat.com>, Jason Gunthorpe <jgg@mellanox.com>,
	Ira Weiny <ira.weiny@intel.com>, Philip Yang <Philip.Yang@amd.com>
Subject: Re: [PATCH v3 hmm 05/12] mm/hmm: Remove duplicate condition test
 before wait_event_timeout
Message-ID: <20190615141235.GE17724@infradead.org>
References: <20190614004450.20252-1-jgg@ziepe.ca>
 <20190614004450.20252-6-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190614004450.20252-6-jgg@ziepe.ca>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>

