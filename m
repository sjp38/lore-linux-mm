Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E53CC7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 06:24:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 46C34217D4
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 06:24:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 46C34217D4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB7D76B0006; Fri, 26 Jul 2019 02:24:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D40536B0008; Fri, 26 Jul 2019 02:24:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C09108E0002; Fri, 26 Jul 2019 02:24:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8C2436B0006
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 02:24:40 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id h8so25085968wrb.11
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 23:24:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=I3OpueK2zeUR3koT1HF3cu4uN3hkZegZDgBRgjyi2mU=;
        b=b1AlzBDYU9pPJ6X+DddIgMtACwU5Bmf7fBndPGZ3GlZu+oFm3JDu3xrGJ/pxyowi+I
         VfPW3flPke5m34GejeXdNDjao57eGRbMs/pv0BvNJKBvtjyvz/SQ2+JOsy/azJIaTW1R
         Wt/AMApD+m1L83zgKUwQAqoLW7dgIikKmKG78KyVX7Vcc3OSjjfhufGBc4TxkTTCxHIT
         xxKSlHfc0NIr6qJcU1J0RwPTm38nNzkUeS81qA/8vwxFHm9vi/4BehcSrvv0eQtShvjw
         NZSRRPk6PIoRidI8T3fL4BwQIffCLZ1wrBPYUm+WL7hXSrS6DDcGCkqK0sWm+4ZchdgT
         wAow==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAWeuO4XUmU6wJwMmkZ7TaaNFqdQA2GGgA5jDln7aITM/daF6BS5
	OQf32dqVBSbSN1cyP9nwgznWCSj6ezBoUGx+LVA4xh1zXfWS7X+V5t6jSkTSIevJUAEDA2V4eT3
	Ad1LikQb9IvA2/tpmP9kHs9m+zW70vOz9lQvUNhVF6jmn1lFoJZzGfz+tanYgjEd5vg==
X-Received: by 2002:a05:600c:2243:: with SMTP id a3mr79913501wmm.83.1564122280148;
        Thu, 25 Jul 2019 23:24:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy0bvdxVDo7ZcpUPh5DCk1YfFbmR5diNnNSs/3ezxXky7LFXTY33rZMbWcXfVSjrFCSokXH
X-Received: by 2002:a05:600c:2243:: with SMTP id a3mr79913448wmm.83.1564122279396;
        Thu, 25 Jul 2019 23:24:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564122279; cv=none;
        d=google.com; s=arc-20160816;
        b=ai8LCiayVS/xGbF6uc8F4bZ8sWMG9cGDcdY7JS0Qavi1VEW/L6nVZj8B4+z97VVaKn
         1UAxGy4Upe+Cqowmx7oRHOBd/+cPPkOhBatTqFcU2QZwPh3GvVKR6kFrwlcM4F5KfQFW
         Tyabdlr/AY803GFD3qfCN8m5MyfomBL6pGIXU9Ctzdw8RqNnCcJxe16PtOzAUwinHthl
         QjQz9DSRpomv2XQ1T954B4Ve/KkzLmzXfdWjcNNtdQpgXQKJ28a6HRCmS22BoIcGueyb
         I9j6Y6VaVkMH/ieecsSUPdeGXlr2pNQFICeSIWwprWZ83xyJLwJ86Gc42uG4c4D4zIk1
         YB5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=I3OpueK2zeUR3koT1HF3cu4uN3hkZegZDgBRgjyi2mU=;
        b=Gc1MGdzFVUOEhJeH40uiA+BydKjJnG3HgYK/+ADRIc/tUya1T+Xj+J6FeIRAipJOWR
         w0spGiDn6jwbfVqV9HcnlXYiFXrj6LeMkm7LY6de4qPUG756swGUAht6DjIfJ99T0Y9G
         VhBGD31DNWTPvwhuYzXErRlEcNfvsXBskJZeGKTp9gbgjNemDR4oy8/rCpvb4tRdlj1Q
         M5RLlmuQ4L8vNsAYzX27nvlE0rNmECJOlVbbmNN839rLS+RCn2WzvVfmeBCTUESjcx3v
         EdOLaazYrxUlp5vUPNle3xJzzfxSoqoCkB4pmveQRLrGDBhiAorVblT01FcWk9JHH+Ck
         gCjQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id b12si52683542wrn.423.2019.07.25.23.24.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 23:24:39 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 75E5C68BFE; Fri, 26 Jul 2019 08:24:37 +0200 (CEST)
Date: Fri, 26 Jul 2019 08:24:37 +0200
From: Christoph Hellwig <hch@lst.de>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	nouveau@lists.freedesktop.org,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v2 6/7] mm/hmm: remove hugetlbfs check in
 hmm_vma_walk_pmd
Message-ID: <20190726062437.GC22881@lst.de>
References: <20190726005650.2566-1-rcampbell@nvidia.com> <20190726005650.2566-7-rcampbell@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190726005650.2566-7-rcampbell@nvidia.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 25, 2019 at 05:56:49PM -0700, Ralph Campbell wrote:
> walk_page_range() will only call hmm_vma_walk_hugetlb_entry() for
> hugetlbfs pages and doesn't call hmm_vma_walk_pmd() in this case.
> Therefore, it is safe to remove the check for vma->vm_flags & VM_HUGETLB
> in hmm_vma_walk_pmd().
> 
> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>

