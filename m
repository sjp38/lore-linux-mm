Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F2ABC76186
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 01:14:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3CDBF21855
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 01:14:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="CLuwqZyx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3CDBF21855
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD0EA8E001F; Wed, 24 Jul 2019 21:14:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B80B38E001C; Wed, 24 Jul 2019 21:14:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A46F48E001F; Wed, 24 Jul 2019 21:14:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 83D518E001C
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 21:14:27 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id x1so40946630qkn.6
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 18:14:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=2QscBl/3tbBrXReK2tsv96us6PdZtQnqjBeeXbxeJtw=;
        b=gf4JBe5+Nyp9PqoMTeLRRQIxRd+k8tKBhdpzHshy205MkmxVpr1qr8eDp+WbKJVjim
         P/rOk/IxBhTAFP5qLM42+L5wjHpeLgis+Hlok2MMFUMayAXcA2/sPHneJJVpBUP38siT
         PthfXeAzw8HHClyy40srpFPW9Yc9nO8VKeK3FQ3XVEVVuXBMaZhFtnELLJESLeMaIP7C
         xwJfna8urFXhkO1bBjbwzNYkgkNxsvYZBSBJ4pbE3rn84TZSJKkHr/aPGUCoiK+MhKYp
         mdvA/arH8x0USVr4DhuoUSUeq8iEEUYWRs7n+idQXk9JWVsuG9XKSNWgWXbRRN773UuJ
         3uYQ==
X-Gm-Message-State: APjAAAVznpYQIvTOJVe3AbmED7T/d8c/BEw9SB74CnViJ+rEUzH/GbQs
	mpq6lcbU+gVUQ7FdthekA/vfXxHQeZpte3jZnHqGRgwEH3ozas+EiYAvVhgwDc9OXE3CvnPha3V
	bJpueJw1siEetG21jbBiBknHr1lw2b9+BEtP2zRVdSAa5VCJS/SReE4eH36ZNoYICYw==
X-Received: by 2002:ac8:32c8:: with SMTP id a8mr58104386qtb.47.1564017267246;
        Wed, 24 Jul 2019 18:14:27 -0700 (PDT)
X-Received: by 2002:ac8:32c8:: with SMTP id a8mr58104365qtb.47.1564017266667;
        Wed, 24 Jul 2019 18:14:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564017266; cv=none;
        d=google.com; s=arc-20160816;
        b=P/GIXCEn5bZpnmjnZjGtrp3gJa3OhCKU9AvNLj+qqNMht6Rs8YzJKnVqqmwPwS1tD1
         dPk2umv3vyWMP6B4Re89U8PnRABXGq/gnOJeiun97ojArNrszm2Oq+n6dPUYFZoJRNsR
         DOfjrtSXBmlNCCjk8X4dZAwKpm4uipJ6mAGMvR61idy7drPjp1HPD7f4sUtPALoUNUHQ
         APX4aAsw+4vCFISUnWO9l7F2BxD03eHhCfP6NG8VrAIpkowWGt/p9oYxiUg2piKn3fhO
         GbC/TbSP3hTZDfeDD6UposjCjGoxxNT45UyzCpHXqgu6h2snnzH18/cj7AQYDutxIJGh
         bZXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=2QscBl/3tbBrXReK2tsv96us6PdZtQnqjBeeXbxeJtw=;
        b=YNplooLFBrQ9VTW7/HDz3hvCrKe8vUixMTTtr/Yc6abrd/W6lg5gohFCgMAQWkb+Uv
         LQlbggkpui7CSpe7sHwVTVLH7z1MdWy8+NQMimA9JalYBcROOhsQLqdRDUgsAOxzh+Wr
         nsg2H9o3kN0p7RiaNfuk/HK0fAA7JfP5Kq0RNzzU4R46CLW3ztqSBjCznMJ3shIqeDay
         HBD8uTY7Ba+0pzU/7/Aih1ByRqS0BaRyzoT+PE2jY96LxAkhMXxHeQ0Eg48Ex52LOmmF
         5gxYVMS8mCpj7aJXgLGJ0Kb7ebDl3deUWaVFlvRPESuj72Bfa5YpAZTDSoIHdVf1IdaL
         2Byw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=CLuwqZyx;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m14sor27085607qka.115.2019.07.24.18.14.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 18:14:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=CLuwqZyx;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=2QscBl/3tbBrXReK2tsv96us6PdZtQnqjBeeXbxeJtw=;
        b=CLuwqZyxlnhSQLNy2YRvagdU0Et/zZ17Ms4ehbdSvHLmk/gxwl3Wy/TTFegvnq+Et5
         4OpzVJv31gfdKu+/y13I9cSc1xlCIrpNLtabHb96qgORKl53PzbY30X66v61S563aYvw
         Z37UCLu003OZv8+NzTJzDSWyvzaPJpCNXSGq9hTC782PqR5qb6OfdY663YIxKKz6zIal
         IUoHez0chz3E2syIDBmGa7w0i9EJIB2xJ/Oxn1p3vnYmrNLjnuIVSG83ByHoyfGxuzLd
         v/OfQGlL/BCupE+LUBwfJE+qrXBuBE9jk/6+jF2E0ImNgnz9zBrdwCRnFkuXmowLxdCC
         tjIQ==
X-Google-Smtp-Source: APXvYqx9ciisQdvPSwTvcdjpywJ+TPlixY+OV7qviQmXLqIq62Jmz3/cvYtUMzroSQEs8t3xbOZYHw==
X-Received: by 2002:a05:620a:1ea:: with SMTP id x10mr54556510qkn.484.1564017266127;
        Wed, 24 Jul 2019 18:14:26 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id k7sm20307997qth.88.2019.07.24.18.14.25
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 24 Jul 2019 18:14:25 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hqSKu-00006q-Vv; Wed, 24 Jul 2019 22:14:24 -0300
Date: Wed, 24 Jul 2019 22:14:24 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	nouveau@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Christoph Hellwig <hch@lst.de>, Ben Skeggs <bskeggs@redhat.com>
Subject: Re: [PATCH] mm/hmm: replace hmm_update with mmu_notifier_range
Message-ID: <20190725011424.GA377@ziepe.ca>
References: <20190723210506.25127-1-rcampbell@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190723210506.25127-1-rcampbell@nvidia.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 02:05:06PM -0700, Ralph Campbell wrote:
> The hmm_mirror_ops callback function sync_cpu_device_pagetables() passes
> a struct hmm_update which is a simplified version of struct
> mmu_notifier_range. This is unnecessary so replace hmm_update with
> mmu_notifier_range directly.
> 
> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
> Cc: "Jérôme Glisse" <jglisse@redhat.com>
> Cc: Jason Gunthorpe <jgg@mellanox.com>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: Ben Skeggs <bskeggs@redhat.com>
> 
> This is based on 5.3.0-rc1 plus Christoph Hellwig's 6 patches
> ("hmm_range_fault related fixes and legacy API removal v2").
> Jason, I believe this is the patch you were requesting.

Doesn't this need revision to include amgpu?

drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c:         .sync_cpu_device_pagetables = amdgpu_mn_sync_pagetables_gfx,
drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c:         .sync_cpu_device_pagetables = amdgpu_mn_sync_pagetables_hsa,

Thanks,
Jason

