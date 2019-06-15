Return-Path: <SRS0=cZWw=UO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F0629C31E52
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 13:59:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AE31E21473
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 13:59:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="hk/D58ri"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AE31E21473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6356F6B0007; Sat, 15 Jun 2019 09:59:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5E5C08E0002; Sat, 15 Jun 2019 09:59:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D6DA8E0001; Sat, 15 Jun 2019 09:59:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 131E76B0007
	for <linux-mm@kvack.org>; Sat, 15 Jun 2019 09:59:47 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id c18so4016966pgk.2
        for <linux-mm@kvack.org>; Sat, 15 Jun 2019 06:59:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=l2WBiCb5duYJRA9nKpihqrJOH1Qjg6utSrFiu8qAdtc=;
        b=W0W1o7ycnbXNjbJlOFsQEW2kah2yWm14BV366BghuBKjTFZDgys/4Wt2oqWbcFN7JV
         7eGTryrTRPt/LxOhzunr8TJ7tIB83M4pYeRCPT3Y1/o8TQCXgOanBOZ/lOukIxwdmhUA
         qhld994MsjTECD5bOo7hVYDS7pI/ce95XHrykTlNZ+UxxXowBZoXT3JpFFmKIOvCWkP6
         bpUzVyZJKxrVR2Ln+37V9Jp9LuDUKmU/Fsp6jLhPFTPbj5955dUwdQVsxh5CihsgJilF
         sXVlWQYHLGct/5IPnJ8X94ZCAh6M4O7zkbYsz0Lj9JrGLe09d5qG+405a1BpdU3bhgIZ
         tN1A==
X-Gm-Message-State: APjAAAWDPPxr+iTUc9kmgzaymwJn3rDUsGo04OjPcIYXhJG+C210BOYx
	bJlHht0R36EyFzlXKIPbB8KHpdcJ5RS8P3ep5r0aHWKkXerHk75i/gtWyym7ybnUYqraMoeKfK5
	46EqduYOD0G5XC9DtHdswtEW2wdU8dnuNGVLI4LRv0e5BUw6UENnkMk6CBogVnQxyqg==
X-Received: by 2002:a63:c006:: with SMTP id h6mr33974306pgg.285.1560607186682;
        Sat, 15 Jun 2019 06:59:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzZmuHQ5B5l/JTr1tvMPsG09jAg9EKe6ttmLIBZx5Ga9KC9UdGilNBxAAiuOQNOMCfZ95b6
X-Received: by 2002:a63:c006:: with SMTP id h6mr33974273pgg.285.1560607186033;
        Sat, 15 Jun 2019 06:59:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560607186; cv=none;
        d=google.com; s=arc-20160816;
        b=cvdL2WtGbjzPidZce2zTpCEFH6/8b1BUdG43C2CYS1JyqR+3t5YNNLeDMDUOdV7iW+
         OsS40FsI6qD9CcOFiFr1N7q7l7n1aeFfP/jII1lOVwE/ipIRIN31w5dAK0NKPFdwdT+P
         2zJJ+BgSxbURvwoqk5mP8beOlbL/ng46jVcd2vWFqAz+eeJoUZe5X60TmtT9n6EY2lT6
         iZ8FKlKC3Y9JgHkIrSgZA+t9+hwRo6EtLmDj2yHolO0Ozg8ssUV0dhzeRzsHt+sl/EgQ
         xRTjW6a16o4Daae8RYzTHfMt4HKPh2cQc6VUnae6DvHRqezypfgJb1m5u1TX3mk+YtbO
         G2ZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=l2WBiCb5duYJRA9nKpihqrJOH1Qjg6utSrFiu8qAdtc=;
        b=fpJVOY/1ipIv3XpEmrymgj27ZAKSkhjLfFWL4QBh+aWVbJ2OY6xC6Xoyt/MrmZTrcH
         ccBOLNHKov76M4sO/ROe9ABnpNPMxSwPVewGR14IshPAtNfJ+aucRcfwKqMDT0rNRaxg
         ka+I07fdLcKMwojUWhtT2XqZqhSGVOxhU7wgtZH3TnniQ+u2MSde9gLXPf9usRDx5SjE
         XWPzChHXwzNiyp5yHN5Q7N8jmZ2jIQ0e9TWJOkG2fU5GXsd10BqO1EJnU9aIAkA263Yl
         +E9bayv0pvuvFqNEDZ1S+OY/r9bOk3+evTQ9IdiWiMJ60etUseFTb93TW3bxbak9ihA0
         e5AQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="hk/D58ri";
       spf=pass (google.com: best guess record for domain of batv+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b95si5093107plb.401.2019.06.15.06.59.45
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sat, 15 Jun 2019 06:59:46 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="hk/D58ri";
       spf=pass (google.com: best guess record for domain of batv+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=l2WBiCb5duYJRA9nKpihqrJOH1Qjg6utSrFiu8qAdtc=; b=hk/D58rieL8Onhwvbo3S4fbap
	Tkzm4nzftLhksrpzz8IQnXPlyA6z+c3Wygq0AZ/UWLIcS/bb+4qlDejjx9suAxW/tDYeoNA6iZxqB
	Ftj2ODL2/e+Pjz9X7xIclxGEOe6jPjHda1ywTlLZtdih9bZWH4qtC3bYcnHYqBTz2FsInoYbnS4gg
	ybmc/RCOIPHZu2EGHIKJ0pEe23W6Dsmi5fzOyOuKeTmV/ZncUMC2y5Gpu7SHsJ6Y11nxrbQO9SuNq
	KIBJ+AI6XGinNFvmvuO4d8H3HBSBau2G5mumoxNuAzXV6yuvcgppjyZQYG70JTxUJaF4FygMUx150
	R8eT43xWg==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hc9Da-0005FA-V2; Sat, 15 Jun 2019 13:59:42 +0000
Date: Sat, 15 Jun 2019 06:59:42 -0700
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
Subject: Re: [PATCH v3 hmm 03/12] mm/hmm: Hold a mmgrab from hmm to mm
Message-ID: <20190615135942.GC17724@infradead.org>
References: <20190614004450.20252-1-jgg@ziepe.ca>
 <20190614004450.20252-4-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190614004450.20252-4-jgg@ziepe.ca>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>

