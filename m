Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5400FC3A59D
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 13:31:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A35B214DA
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 13:31:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="mas8Y/k2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A35B214DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B0D906B026F; Tue, 20 Aug 2019 09:31:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ABEC06B0270; Tue, 20 Aug 2019 09:31:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9856D6B0271; Tue, 20 Aug 2019 09:31:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0102.hostedemail.com [216.40.44.102])
	by kanga.kvack.org (Postfix) with ESMTP id 75E1D6B026F
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 09:31:38 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id E7DAB8780
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 13:31:37 +0000 (UTC)
X-FDA: 75842893434.24.wire63_828a64dc84c46
X-HE-Tag: wire63_828a64dc84c46
X-Filterd-Recvd-Size: 5590
Received: from mail-qt1-f194.google.com (mail-qt1-f194.google.com [209.85.160.194])
	by imf31.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 13:31:36 +0000 (UTC)
Received: by mail-qt1-f194.google.com with SMTP id b11so5962207qtp.10
        for <linux-mm@kvack.org>; Tue, 20 Aug 2019 06:31:36 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=Rau8DTLhA75HN92GYpCRUTjDJzQh4QiLbDwyZ3veNCQ=;
        b=mas8Y/k2E852sfqmdBjki4+0c1zN+LWS95nZTvMODhRIXI5GRMbl9nccZ2+Vn6Woih
         Dah3xe19RUlkaa8o8IAFI40KKcQCWwBByL9kruX7QZlYKSD28X9fpbFwjPAZ86Dg/P1C
         cKFVKPhsro3UuqpcILFlAdo2eCq4NfBBI4O2+cQgL0Xjq3KsNiSUtC0PZMujNQLZkADv
         fE85d5hTmL1EJlG7jN+QczJ//3IFTSDXBw2EaAQXElYg13df3UJWU12j4jOOVPidGmhH
         GHXHFT/eIhecUzAgfQQFMqL1Ja9lCaB7rVn8U6eyVc5ng2FRVHBhvw37gsGE18A95KXO
         ZILg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:content-transfer-encoding
         :in-reply-to:user-agent;
        bh=Rau8DTLhA75HN92GYpCRUTjDJzQh4QiLbDwyZ3veNCQ=;
        b=d2DiQ5rI4RZ12CGKIRdGYLW7g/08WHUhHF91f0hQcTLMld9zGLSiQDHuOSqfGkuaYS
         YMa8RjAvSuwGgkEp7UxjuUa6GhPZf5qpY3YAodsHcH4qXZocS3n0UtjPd22sJjk/VvDX
         XOXu4/lNyMvj8ZIp5I01ZtdrFPkrskNHuOXOQUQy3PFTcvKaMGXEMnXibBq+NYQRoyd5
         oqLaW5VNlwYXXat/P8aSnr9sX9Sh0uAPWBbLVxSAEL2rHppTItcg+Hg0s4ObWcTTgwqE
         3e1phwbSp9WWuste3Fr3BVJQfIk4qV/AdhrqDgKkcgkOJlhE+Pp2eqGpRpcUjXG+aEL7
         dl4w==
X-Gm-Message-State: APjAAAUVFdv7yLQtJsh8qqS8VJBSDPIWERa1izcB05HU3cHWYrGTNCSv
	KHyacv4bzgjuT/wOYJ1rUxC9ZA==
X-Google-Smtp-Source: APXvYqysNleRHIxweJW4kUQqWciO4PnA7inG5RNUTSkUVmb1nCNlKeN951d2NRIAKVBELcjqlvEfqQ==
X-Received: by 2002:ac8:425a:: with SMTP id r26mr23111414qtm.309.1566307896020;
        Tue, 20 Aug 2019 06:31:36 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id m129sm2560940qkf.86.2019.08.20.06.31.35
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 20 Aug 2019 06:31:35 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1i04EZ-0000YV-7s; Tue, 20 Aug 2019 10:31:35 -0300
Date: Tue, 20 Aug 2019 10:31:35 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Chris Wilson <chris@chris-wilson.co.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Rientjes <rientjes@google.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Michal Hocko <mhocko@suse.com>,
	Christian =?utf-8?B?S8O2bmln?= <christian.koenig@amd.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: Re: [PATCH 2/4] mm, notifier: Prime lockdep
Message-ID: <20190820133135.GF29246@ziepe.ca>
References: <20190820081902.24815-1-daniel.vetter@ffwll.ch>
 <20190820081902.24815-3-daniel.vetter@ffwll.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190820081902.24815-3-daniel.vetter@ffwll.ch>
User-Agent: Mutt/1.9.4 (2018-02-28)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 20, 2019 at 10:19:00AM +0200, Daniel Vetter wrote:
> We want to teach lockdep that mmu notifiers can be called from direct
> reclaim paths, since on many CI systems load might never reach that
> level (e.g. when just running fuzzer or small functional tests).
>=20
> Motivated by a discussion with Jason.
>=20
> I've put the annotation into mmu_notifier_register since only when we
> have mmu notifiers registered is there any point in teaching lockdep
> about them. Also, we already have a kmalloc(, GFP_KERNEL), so this is
> safe.
>=20
> Cc: Jason Gunthorpe <jgg@ziepe.ca>
> Cc: Chris Wilson <chris@chris-wilson.co.uk>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: "Christian K=C3=B6nig" <christian.koenig@amd.com>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
> Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Cc: linux-mm@kvack.org
> Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>
>  mm/mmu_notifier.c | 7 +++++++
>  1 file changed, 7 insertions(+)
>=20
> diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
> index d12e3079e7a4..538d3bb87f9b 100644
> +++ b/mm/mmu_notifier.c
> @@ -256,6 +256,13 @@ static int do_mmu_notifier_register(struct mmu_not=
ifier *mn,
> =20
>  	BUG_ON(atomic_read(&mm->mm_users) <=3D 0);
> =20
> +	if (IS_ENABLED(CONFIG_LOCKDEP)) {
> +		fs_reclaim_acquire(GFP_KERNEL);
> +		lock_map_acquire(&__mmu_notifier_invalidate_range_start_map);
> +		lock_map_release(&__mmu_notifier_invalidate_range_start_map);
> +		fs_reclaim_release(GFP_KERNEL);
> +	}

Lets try it out at least

Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>

Jason

