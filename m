Return-Path: <SRS0=cZWw=UO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1B53C31E50
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 14:21:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A76821873
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 14:21:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="LeqG71y6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A76821873
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 032566B0003; Sat, 15 Jun 2019 10:21:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F24336B0005; Sat, 15 Jun 2019 10:21:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E3C128E0001; Sat, 15 Jun 2019 10:21:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id B17CA6B0003
	for <linux-mm@kvack.org>; Sat, 15 Jun 2019 10:21:09 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id x3so4035131pgp.8
        for <linux-mm@kvack.org>; Sat, 15 Jun 2019 07:21:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=sEhX+5INXIgfDveglz8gCZJwRNPPLquY/78YPpDhP50=;
        b=rECOfHnLsF6CC3RiyEcckkMFT1uVMzzZohX1FzTu9atlu/E7xDGOu6m1/DP+Jx/sKa
         qATP31N9k4GKADLi1AhiddUKyCjkzKVVF6sHIMkBax50YffgqjjU0NJJ4h1tQwi8sFHB
         HqEuEaPBdRqIerSi7XUkvoUfujfV6ArC8PRKXFnTXR76aZdmJnQVSFrnlDOGwrU52Qo5
         +oCf6IxemMF8xSDIbhE1GTL0tBAwmaZnV/qbwpb08/jQwdNK0lge+XnmYiNE1VrBqBi4
         DD+JGaDIlNiGOaH8rD8iNpG5id36qNyJY57ua/vIyUF5T8Kcw/0vHg/eyEEoTHq84k8T
         j+EQ==
X-Gm-Message-State: APjAAAX21bnLmbbEnrN9k0sTKFt8XA9kddKMgm5geCJTghp6l/djdyc+
	Am1qPMzvYKGZ5powWmlWJO10W03V+vg6oPPkgK36B8Nd0NwXIhlvTiUvuFlBK87Pckhtv6Jv90S
	thx4DIrnsSbMudeThPFpuNTphqDHujNkKEfIQmRb+3u52C8gxbbAPrkMLjcHWHIoO+g==
X-Received: by 2002:a17:90a:2641:: with SMTP id l59mr15594479pje.55.1560608469421;
        Sat, 15 Jun 2019 07:21:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwsfL8scf2gbPipO3JfEPBvyY7e0HJ6Dd9pCoMGZAcOlDcxLr0Px66cAyUnaaBQQb91SWxg
X-Received: by 2002:a17:90a:2641:: with SMTP id l59mr15594443pje.55.1560608468860;
        Sat, 15 Jun 2019 07:21:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560608468; cv=none;
        d=google.com; s=arc-20160816;
        b=GsA6L8Splllls9edqmjzCovunFjqWyQX8hloxWGGKIBfmYpl4ApkG3uZslYNgMCYF7
         bYLkeU0OgUbDMjsfPkzOtxLHw2R8D45Ag6pio/+nyktwnW33gQ5udFzevj8O1uWSmB9e
         dRZOIlLQyeXcQR4ZNKdPRQmTHeEoW6O3h/CqYcktx/tvoPAg22+iZpYnhblZdMqKP0YU
         3YsaZS3oSYvli7HRfBtwXppyaiG8DioiWE8MWrDuRn1ZSrh5bWgp6P2VA9+9TVVcJKQo
         Q2KB28gE4irXjzrXffQXfuCehNajPAPRxd+PXf8HZ/3jaAH6GyD1SuF2OyFv1DqFEbE/
         Q3wQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=sEhX+5INXIgfDveglz8gCZJwRNPPLquY/78YPpDhP50=;
        b=anzKs+w03LytQtDoGUICs3GLxX9lAnwbunEyMVnNEiSDFBL22MfMvybICvbrKATAN+
         PgTUCRPuTgAPMGf9rlicrAulGKRrWrjxiZbIPljA8lQ/pDebcptOLu3Gq1jfvZKgj3le
         C8JyUauqrpCFP6COVB2XMFVyxNcGQyGDoszu1Jnpn4EkLn2wNojETTinijGUeOCtxIv+
         eGiV7feI8z07sjN1NbOdwglIlXFyD4DubaxATcHau1Em34+BkkcmjlKy6Gl/4BiPPs9N
         EkfPaH5JZUmgzPfBeUYubd8cRGIykNDK/B5fDyvbvS7PprJ3+LcQ0Lz1fE7buWVcjrcE
         NVBA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=LeqG71y6;
       spf=pass (google.com: best guess record for domain of batv+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q85si5647064pfc.85.2019.06.15.07.21.08
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sat, 15 Jun 2019 07:21:08 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=LeqG71y6;
       spf=pass (google.com: best guess record for domain of batv+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+78a6abdb7ec5759febfc+5774+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=sEhX+5INXIgfDveglz8gCZJwRNPPLquY/78YPpDhP50=; b=LeqG71y6vq8cRRf0pGteG7bcH
	HvoPvv9qFjmSsTBZ9o0j+/SJhwGrrOJkbpoG+GwXablTi80OMbKwnEw7mTByKiIBk489iaKOVoA+D
	/OiesUxDChOxPgq/dSVYfc5Hdkd7XstEEuVVfytRleA6Jllqcy3xuLWIVdHLMYeYiMqgMMpHNHa7i
	xFl/EEzXp/7foQuyKq+ZHcAO773G0dER0i17hYTQ9Z9HMFVxIbRP0LdNLpEFnnqw3bQ20PvXCKXNV
	MQ2L6Y6gwRipK4Onamw/OH/772GYRdkgi/R+hfrOssVzYum29EhgKmkU2oAYA+Ad1rlB+AO6Aq/hm
	ZjNsVwdSQ==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hc9YI-0006ZY-6Y; Sat, 15 Jun 2019 14:21:06 +0000
Date: Sat, 15 Jun 2019 07:21:06 -0700
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
Subject: Re: [PATCH v3 hmm 11/12] mm/hmm: Remove confusing comment and logic
 from hmm_release
Message-ID: <20190615142106.GK17724@infradead.org>
References: <20190614004450.20252-1-jgg@ziepe.ca>
 <20190614004450.20252-12-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190614004450.20252-12-jgg@ziepe.ca>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 09:44:49PM -0300, Jason Gunthorpe wrote:
> From: Jason Gunthorpe <jgg@mellanox.com>
> 
> hmm_release() is called exactly once per hmm. ops->release() cannot
> accidentally trigger any action that would recurse back onto
> hmm->mirrors_sem.

In linux-next amdgpu actually calls hmm_mirror_unregister from its
release function.  That whole release function looks rather sketchy,
but we probably need to sort that out first.

