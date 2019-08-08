Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2FB1BC41514
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 10:26:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F08562187F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 10:26:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F08562187F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 80EC76B0007; Thu,  8 Aug 2019 06:26:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 799756B0008; Thu,  8 Aug 2019 06:26:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 660FC6B000A; Thu,  8 Aug 2019 06:26:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2CB5C6B0007
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 06:26:00 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id y127so400583wmd.0
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 03:26:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=l2WBiCb5duYJRA9nKpihqrJOH1Qjg6utSrFiu8qAdtc=;
        b=gHSPRBk2JAvsfJ4Kg9mFfUfo2BG5CNC3S1w0/7Z5ywT4fjvPG7ZGI6jXC5X6MUgPya
         PtszLTA7p7MyxqZ5Jbx/f2KSZUvhv36MtTP264f2fhCkwGA2FKo6CrnSDMSHW5BA8d0a
         cgYR2TFFWZuFozN8zEoQKgh4ltESIlwuxOwyLXeRyuptkjUELYVy1ZVBjv0iekP169gh
         B5x4Bn4JTO1CcwqiHkckS1ohZOddGFRAyr9e5Y/ahk/2I7ScoYuhL4k/A+p/y1Ei+HTe
         f5qpvd2sxiBuN2rrrc+YdBDJR4TPLD/lEZtSnYNzLrZhNDgWFfOQDacmpICxEWRSIQzg
         lMhg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAX7bMK1htLs7eEOHlMY27nUxNC6q+bVxTCirSFG9jNNMs1+cgQW
	/VAeTXioUVRy/kvhG1X6osjUf3juM3VjEsxMHch4/gAeRd0iiBfOjCOUDkjJsJ3NzeprSSZp/Mh
	CEIvYktkBKw8bJ9/MbOcYtGQtPs/tQYZ2sjFZ1zgOdXz94JUrAtgfoYkA7REg6gUESQ==
X-Received: by 2002:a05:600c:23cd:: with SMTP id p13mr3279100wmb.86.1565259959759;
        Thu, 08 Aug 2019 03:25:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw4OADohHbLcRsGveWWmxKQa2fyh8x2dcy720LA/D6DZ490q/OmDSoi2zPjjry9p9ypHlJl
X-Received: by 2002:a05:600c:23cd:: with SMTP id p13mr3279040wmb.86.1565259959105;
        Thu, 08 Aug 2019 03:25:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565259959; cv=none;
        d=google.com; s=arc-20160816;
        b=wVDe0CNy8sT+FoaGZHahZJTC40TBWyhF6eyFN1Et4F0kyJf8FHxrCBumeRWiMVUt7V
         5PZkLXaj19Qh0+WrlkoMGTWSqOqNq9VAdxn7A4khhy6B17RXqnYIpPxNWo8DiPieMKvC
         bfqGkdWtxA50X4IGiEPW1W17NMojOCKiS0QqBBiTKDjmns+Q8X8ZbTSMzuJT0gjkWwdM
         gSzYbwN6UPvO8nIoFPSx3+SNZreiSnMeh+1GoxODqAKFqJXqBYjwNZhvdCS03CefnIUe
         IjgZIgUro/T3ef0/A4FkONodR9gGYYfMwHsR7w8ziAewEYRygMIW+32+gkS/m/O3wntv
         jvSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=l2WBiCb5duYJRA9nKpihqrJOH1Qjg6utSrFiu8qAdtc=;
        b=WR7yOkuFhEGYxZ0F2Nq3CBkAO7Wktw9kG8/9AxuQL/jqe3C7YARmWd0HTGNVA+S35i
         unAi60dom1rCvpMY6Qqgg3Llv/q5Ute8O5twZfqUBph5//S6RH6To+6+4pA0204xgCIs
         2EKGEDFutIeLPb5zyjt0DeH6bcr/dxWmPtbzvkGf4FF3P3hcYhEdrv+dlaPWTHF3XMlo
         wvW0lnnyaUIP+IQE1IJ0AKSyLqkiMSrw1YH/zKVsqHZsKXbBZKDpV6Lk9/UNQ+2rQmrb
         WtCfJMspfQatbc7tTrcSRHcEgAcFH6B/G+1NUzzJCqYaOGGV7jG/ik55WtModtkAWOUe
         ItGw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id d8si79257961wrr.138.2019.08.08.03.25.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 03:25:59 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 05011227A81; Thu,  8 Aug 2019 12:25:57 +0200 (CEST)
Date: Thu, 8 Aug 2019 12:25:56 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>,
	Christoph Hellwig <hch@lst.de>, John Hubbard <jhubbard@nvidia.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	"Kuehling, Felix" <Felix.Kuehling@amd.com>,
	Alex Deucher <alexander.deucher@amd.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	"David (ChunMing) Zhou" <David1.Zhou@amd.com>,
	Dimitri Sivanich <sivanich@sgi.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org,
	linux-kernel@vger.kernel.org, linux-rdma@vger.kernel.org,
	iommu@lists.linux-foundation.org, intel-gfx@lists.freedesktop.org,
	Gavin Shan <shangw@linux.vnet.ibm.com>,
	Andrea Righi <andrea@betterlinux.com>,
	Jason Gunthorpe <jgg@mellanox.com>
Subject: Re: [PATCH v3 hmm 04/11] misc/sgi-gru: use mmu_notifier_get/put
 for struct gru_mm_struct
Message-ID: <20190808102556.GB648@lst.de>
References: <20190806231548.25242-1-jgg@ziepe.ca> <20190806231548.25242-5-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806231548.25242-5-jgg@ziepe.ca>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>

