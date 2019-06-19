Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B3AAC31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 08:19:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0EFEC2080C
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 08:19:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="F790Naad"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0EFEC2080C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A2CE26B0007; Wed, 19 Jun 2019 04:19:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9DCB88E0002; Wed, 19 Jun 2019 04:19:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8CCE58E0001; Wed, 19 Jun 2019 04:19:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5486E6B0007
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 04:19:02 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id b10so11763737pgb.22
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 01:19:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=gJX7HuiaCgGHU1tdXgWOcBNZy61GCc1VlLrp6/M8Mfw=;
        b=o9RpzSZOEzVqzMKWDkTB81YBrr4/LYoIb1fPPhd5TSa1zyI03VeI9GeH13fDvuJn0y
         //mvNu2CLofHaMHiyjdOL0RhiIMZZBoIOmzIe+JWc3ufygsCZQuqRPGXbzNSvFBTgzEQ
         WY0R4CC3WBVvSw7eTLwJ7Ys4pus/rFLugeZBTO59Y/p1QIG97ZsFR/pK67erSLyHR8a2
         Rc8VbfazuUWvjOR1GoQ3ykZ+zx6drg0Yl1shBvboVLknh25dyN9CKBe6ym4vjQBWRa67
         oVTEsLcZgdzK8p3BLFMRRlJmGruE6AdHAeJf5hHU5KfTL1MoOfDdTqJXUKNfOdUh9vm5
         YQhw==
X-Gm-Message-State: APjAAAX48Zu/uo2by9nViNZjUdkfYgaSZo1k9yX+vnrzqsPXRRQYwz7d
	K/TiWLs7P0v0d0UVTCxe74un7BY9MQ88IlDHrOhZnFxH8RC4gv7rNAj/xxH0JNpvilrJ+1dpNfR
	hIxHaz/y8NruHnhJjNAegYTJOCL+WrQmzXDxuP9VQOWbgca9Kpa6O0cI8rlZif6hEeQ==
X-Received: by 2002:a17:902:d70a:: with SMTP id w10mr106075374ply.251.1560932342059;
        Wed, 19 Jun 2019 01:19:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqypPvy8/1BlonsLIL+f2u5z17dX7Ghyq9vTpbgUskLyYOFG4KFvq2BHpFSs/4TOhL1C3s+t
X-Received: by 2002:a17:902:d70a:: with SMTP id w10mr106075335ply.251.1560932341539;
        Wed, 19 Jun 2019 01:19:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560932341; cv=none;
        d=google.com; s=arc-20160816;
        b=H3c1hZgmFN+Z/3WFiP+3KMQChl9er98VB2IOHRq3rkusJ4FemRbLfJoDZJFpwM2hcV
         cv/ns7HJBVFuI7/it3LxXeoObOPKBmqCcp58LycrE7jSMnVte1rH0MBnu16L1onRmEOg
         V6mdBIdRAOKp/l6QtOZQrQ3gRHGrF/fIH1uQMZusYLDuIEuPqvoMDNionU5PZffCAsLZ
         yKMP4/8s0kWTr0tnnXrpOFqT67NaLynLuV/kaccPwaUnNV9BF+gt4igaBLoNUOgEVD7m
         vawrfdfw/aC+Mqnug1jINtW5fCtVEcq2FY5W5UQSm1x3/PsfgOhKU2o9UfJ603VpFx2B
         FYjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=gJX7HuiaCgGHU1tdXgWOcBNZy61GCc1VlLrp6/M8Mfw=;
        b=Yn/SzlqzPREW00gIh1W0pVriN1Qq/9jXWPU787ExchJnESzOkCnf4D4Qv/L30xRTIC
         PJs/eYMjqObQ+eepSt9gTNAgrVX8eu0FDV+xd5Hw/do1P4t08e3zJeWuPMxtxoWtGU4n
         NZXzJ29VScr+syeHYl/j56sYDxHvKIxfSCgvz3P33WdUnsIqY97/h8Yse0W3fcZa+Ey5
         PumcqpKS2Rq/ZO9qsmWeZrzApJqr90Dyt0GSdO0MimlWTALEXqcq54g0vRe85yl+6WuO
         UjaCHVSUwgD/ZWLp5Yehatp0FUQKY4dWFYjg+6EU9htPE8GXEWdgAsvkJQSDxSzQODbF
         4JBQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=F790Naad;
       spf=pass (google.com: best guess record for domain of batv+77cd4ac56e5e79ab4dbe+5778+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+77cd4ac56e5e79ab4dbe+5778+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e19si763009pjp.49.2019.06.19.01.19.01
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 19 Jun 2019 01:19:01 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+77cd4ac56e5e79ab4dbe+5778+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=F790Naad;
       spf=pass (google.com: best guess record for domain of batv+77cd4ac56e5e79ab4dbe+5778+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+77cd4ac56e5e79ab4dbe+5778+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Transfer-Encoding
	:Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=gJX7HuiaCgGHU1tdXgWOcBNZy61GCc1VlLrp6/M8Mfw=; b=F790NaadzLyX7kysrjoApfm8RL
	4B1qNTBJfA0dl3N2JFg7SkdFf/LV7qaQII9PBdIa20bkjqtxcmGUwf+IuWcV2ibWAgsqDFtgZ10h3
	RmDk6y3Jz8+Gq/K8bwcRJ82kfshQD98z9+21iRI1lhYdvFPXMWHI2KrNHEW9Zp4fz+eddphLaeKmK
	7YKDKbdhA2jVqdoHJ2IwfWMe8r3oyhcU8AeQcHnGgGUETxIzdZ41ILhG+33dgEOu49ViOMsWHeo8G
	IUy9pHZKLxnzdOSeyWXtSPzsK7Po1H4f4mu7rgQNltggATnslxmZYgJ4TgX6agsLnNAyjvYsFfIno
	WBSAPrTg==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hdVo2-0000Z1-N3; Wed, 19 Jun 2019 08:18:58 +0000
Date: Wed, 19 Jun 2019 01:18:58 -0700
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
Subject: Re: [PATCH v3 hmm 06/12] mm/hmm: Hold on to the mmget for the
 lifetime of the range
Message-ID: <20190619081858.GB24900@infradead.org>
References: <20190614004450.20252-1-jgg@ziepe.ca>
 <20190614004450.20252-7-jgg@ziepe.ca>
 <20190615141435.GF17724@infradead.org>
 <20190618151100.GI6961@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190618151100.GI6961@ziepe.ca>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

>  	mutex_lock(&hmm->lock);
> -	list_del(&range->list);
> +	list_del_init(&range->list);
>  	mutex_unlock(&hmm->lock);

I don't see the point why this is a list_del_init - that just
reinitializeѕ range->list, but doesn't change anything for the list
head it was removed from.  (and if the list_del_init was intended
a later patch in your branch reverts it to plain list_del..)

