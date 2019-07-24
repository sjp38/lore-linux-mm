Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BEF01C76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 18:00:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8CCE421852
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 18:00:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8CCE421852
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E0D58E000E; Wed, 24 Jul 2019 14:00:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 290308E0005; Wed, 24 Jul 2019 14:00:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1CDCA8E000E; Wed, 24 Jul 2019 14:00:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D89F98E0005
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 14:00:24 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id e9so19526283edv.18
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 11:00:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=aYqFuVbIceuvB8Jx4tRdiElbYRSPZWx1ZRUhiY/KmWc=;
        b=Atq0tusK3OqChXkKJLc2DKYSSCNhqoS3o1eWGK168VTQqmuQUdX9ahdN9+S2w0+2pc
         3QfnU8KV0f/ywvKhtBYquf0sf4L7hZgtxMeNsuiWbQd2lwlDuR2NJI8mP9PzSvry5RQO
         /rbGuNE/Cm3derhjGuqNiNk3ynU60EV+iTn3L90jmdSP/+D3GD5uVb+MAZSQQ08C1asm
         AyCFUxW7K0bN0tve0ZNTx4Rq03Ll3rHes7nqgGp1ybUgw17EvHRBchwp5IGH6n52K3PL
         bDxwqV46tFIOUX3h0yp+6qiZykkUHj5wHYTzPfiNXxV30fuKdBKbqyBK3q75eGh+Xc9w
         he+g==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWloNjnPJaSEfhv1ctXmgP/B9TMoUxD49ZmHsyaAUjdGDBVaV1k
	9ahGkbEFLpFDoX6pw/ejLorQHzJYONeFu0rAmyQCqzL3nDRrdH3lxlBWheaVqvfTSL6byvWrsXN
	7DtFI2qpZdOSFdU2nkllF1wfEAyZmORQGX2HBGfg1LWRYPER5QjOJuH3rnicEyrQ=
X-Received: by 2002:a17:906:e11a:: with SMTP id gj26mr64554730ejb.95.1563991224481;
        Wed, 24 Jul 2019 11:00:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzcPDee3CC5sz0VaqoOBHtYg5FIPsw2MB5b0Z+wVlnP8VSAOPZaO5unJPUOhyEuQV3Ds/rU
X-Received: by 2002:a17:906:e11a:: with SMTP id gj26mr64554624ejb.95.1563991223465;
        Wed, 24 Jul 2019 11:00:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563991223; cv=none;
        d=google.com; s=arc-20160816;
        b=sDYYFXFJ3NkaAdqfGsXUzzGaWgLgFXaMxLGPhFQ+l6yj30NZCGYXtrOGhumQAUlRgO
         wC/pL/MQeOWXRvsj3oDqG9FSQELGvLEiKijrZUVR7QUmdSYFff5TstqFEvy3H4aj6qjj
         CQlfuRdGYrWecnFca7t0a7GzVAWoYDG7jZ6RW8aI8EkSceW5nFhsfSiZaEcPYqtOarNV
         mVE5qX4UkrcUR7iBCnWCwtGsGiKJ6TpKElIqcxwfk4zh1ZUUklnc+oNlIF73TrlXsN45
         ckkxZ9NQGHe0uSId7A6hcp4I0M1gIpN4Lf+dIrfFyMj8apeJd3F1bbMx/9lRqj4qwYEY
         aTaQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=aYqFuVbIceuvB8Jx4tRdiElbYRSPZWx1ZRUhiY/KmWc=;
        b=SNTCX/1qmfP7F9/1lYZDsOTEb7S9JX3VeBqxl853z1SILrcotRpYi4tdCO2O5Yv+Di
         1W0beKB2NzENUiBw9DBRidVSkSoYZ/o7IVj1+FvvNB5I/yR4STR13X2vxhEKtfXbTb8q
         gdKGBnm+H02qGm7ySlQ25Z1w09eCdX3HzO8sk27JI41/wA27QsC0F8+c2RQe7JBUcKjl
         aikv6m6qVs7/OOOxtLg0HaV0q8s+OhK2SmDCpIoYDw8Hz1zaXu8fLbqp+B2MpHs/XSgy
         5y9p9+dBhT626/xLqfl0gkwWaluYbgvwkTjpzT7jUcVkN7CTtCunN6+jXw5Q8MauugcF
         0/+w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s11si7782396ejo.354.2019.07.24.11.00.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 11:00:23 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 167CFADA2;
	Wed, 24 Jul 2019 18:00:23 +0000 (UTC)
Date: Wed, 24 Jul 2019 20:00:22 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, Ralph Campbell <rcampbell@nvidia.com>,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	nouveau@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>
Subject: Re: [PATCH] mm/hmm: replace hmm_update with mmu_notifier_range
Message-ID: <20190724180022.GD6410@dhcp22.suse.cz>
References: <20190723210506.25127-1-rcampbell@nvidia.com>
 <20190724070553.GA2523@lst.de>
 <20190724152858.GB28493@ziepe.ca>
 <20190724153305.GA10681@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190724153305.GA10681@lst.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 24-07-19 17:33:05, Christoph Hellwig wrote:
> On Wed, Jul 24, 2019 at 12:28:58PM -0300, Jason Gunthorpe wrote:
> > Humm. Actually having looked this some more, I wonder if this is a
> > problem:
> 
> What a mess.
> 
> Question: do we even care for the non-blocking events?  The only place
> where mmu_notifier_invalidate_range_start_nonblock is called is the oom
> killer, which means the process is about to die and the pagetable will
> get torn down ASAP.  Should we just skip them unconditionally?

How do you tell whether they are going to block or not without trying?
-- 
Michal Hocko
SUSE Labs

