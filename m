Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8C17C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 17:44:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 79AEF20C01
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 17:44:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="kGCc9AZ3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 79AEF20C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C8726B0008; Tue,  6 Aug 2019 13:44:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 179DF6B000A; Tue,  6 Aug 2019 13:44:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 068E76B000C; Tue,  6 Aug 2019 13:44:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id DAEF16B0008
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 13:44:52 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id c1so76327610qkl.7
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 10:44:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=bZtzSRQjhSrRQjuTGnm0cayQZPAGjzejTXG905wfdw0=;
        b=jOD81PBnRER+UYp4LhZCzp5RE8I6RF+oyGq/QiAv0kVzJ2ghVq1p9+lizwSXqcLyt/
         dym41irwHAmbSIkaSquIru2Z9MAbYhFEL2i+6nEWLUFVpA93wRsEOvWjw8Fb0VCRdo5o
         JqpFelUTn4xvda5dVHEluAgoi1vc0QNNLAPwJxJ9TjdFw4iKgyuwVuvTVSQpHmbfwbcs
         Wiuxb1UFSy9ypLI1mIh4qVBFWyRSvpt0SfZF41a9v0zERCjDn0jLGBlta9jZP69LaXjR
         ZwbWuPghEtAOqJGTa28mkHLEbFJ+qYfC11Dpaskljf7dPmD5VyqeFJ12XhiIP6FhBxAp
         ZAbg==
X-Gm-Message-State: APjAAAV+DRbH/jiaOJEjsxi/mRfDZsnIHJxyJEfuJgWQW196Wz3wVJZ0
	GN8QPlFLAzIsLHfk6WU2bC1vwxrR7+eAS+sUjH3y1DYsdk/OX17cV0liE3vVF4VGBsJsDRqGd8O
	RjbcDabHmkDLqGXkUlcf4l/aeoB86f83qnbTCBysEvpvSsB2wCAKMjDE02ShXL3Gzlg==
X-Received: by 2002:a37:7847:: with SMTP id t68mr4284635qkc.128.1565113492682;
        Tue, 06 Aug 2019 10:44:52 -0700 (PDT)
X-Received: by 2002:a37:7847:: with SMTP id t68mr4284607qkc.128.1565113492254;
        Tue, 06 Aug 2019 10:44:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565113492; cv=none;
        d=google.com; s=arc-20160816;
        b=s10r3rxkq7D0IGHaiXwI4yvBU9SP3Consc/dkeMnr8qXS4KLf05b7AlM9qJLdREcX7
         KWDumkjAlBPgoglnDlZChX61/RajQ316gu0Enr/3z9cyWWGYajS2Ezi9qp6pasebSkQ8
         oLgo8JF7lxo4WGgYnDalFV4z08pxO2jmbpSRi2cIVdLI+ZM5f+UyjTLCO4fmXpaOR8E0
         81nI+6R1vZry99ga0wVwE8jUUDXAhXjgEjeYjM/m2xNo0t+if/Lle0UlrBQUTtaiH7gM
         Z1f3ahuKzmSNAnHFTb4wcFK+cqavX7FfR5TIi6cfDaNxn1FpVUeXIOsXHqcuJ8tC6oJe
         /qrA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=bZtzSRQjhSrRQjuTGnm0cayQZPAGjzejTXG905wfdw0=;
        b=dqoNMj7thwBB8CyIO8/x/nbUlzM3Q3LD2IldXlXW5Bke0h22w9ZysZUCmsIrpgKEOR
         OnsyTghqZcy7Giwgej7K92S8rrtEo+jtNHe0n3aSHvYdi9x+qHE6ojdK+uZ6UnniUYx7
         VvAB0hrtF1Pmx0rUXSE2lLUB8h2AmBuROcHJiROUY5HegIOi7TQNI+wQXTl5fHJMxgcs
         oaX1mtD4rDvo7L8kGMWSbtji6ra1X5mOGmYxzk9uf8pk6cBOK+swEARERuL4zPT8Acf8
         QkeHB2N6ZK629QKsm1ktC9iIC1bcJemgzxir6Hu6FGDsryjDMglOmRbAZ21GGH59zXYA
         CuJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=kGCc9AZ3;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 8sor113539006qtz.21.2019.08.06.10.44.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 10:44:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=kGCc9AZ3;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=bZtzSRQjhSrRQjuTGnm0cayQZPAGjzejTXG905wfdw0=;
        b=kGCc9AZ3EnQ1hENpi10zxnp8FPxEY+gZ4u/zkReV8Gk0g4EsnIsOyP2vX5idcMBB+N
         VqjEaaMot6kbdFxVmOlEm3tUIYXwEQT/y/7s11UZ+8vUXizamKWn9OUzoZVObkKRPWF5
         PC2DJb3kBYP003JMyG9RuoIAMt1yp2NAIcUhv0kLoc/5yOiIHRVEpLR3JQfH/W8OKUNe
         XjpQ60F11rN9ibmfNaecBWtkVeRv7sFxnhwEglCFAfG9t9UMxDtUa5fCeFlLC9UqkNOe
         29/8m0lfjCMFnxcTMwNskT+B5FKI1Hwf/xwSEWFHQlKgvBiwTtYdYbvXxZ38LEH2twL7
         VMaQ==
X-Google-Smtp-Source: APXvYqyZhLDncBVUJEIu2HEUQvEmb0gPiZCNGeOuB4xFtTfpcIsHYizrdBS0HYUKqNFQSDBwyqBK0g==
X-Received: by 2002:ac8:43d8:: with SMTP id w24mr4245586qtn.25.1565113492016;
        Tue, 06 Aug 2019 10:44:52 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id i22sm46601023qti.30.2019.08.06.10.44.51
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 06 Aug 2019 10:44:51 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hv3Vz-0008Vn-5w; Tue, 06 Aug 2019 14:44:51 -0300
Date: Tue, 6 Aug 2019 14:44:51 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Christoph Hellwig <hch@lst.de>
Cc: =?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Ralph Campbell <rcampbell@nvidia.com>, linux-mm@kvack.org,
	nouveau@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	amd-gfx@lists.freedesktop.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 14/15] mm: make HMM_MIRROR an implicit option
Message-ID: <20190806174451.GL11627@ziepe.ca>
References: <20190806160554.14046-1-hch@lst.de>
 <20190806160554.14046-15-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806160554.14046-15-hch@lst.de>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 07:05:52PM +0300, Christoph Hellwig wrote:
> Make HMM_MIRROR an option that is selected by drivers wanting to use it
> instead of a user visible option as it is just a low-level
> implementation detail.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  drivers/gpu/drm/amd/amdgpu/Kconfig |  4 +++-
>  drivers/gpu/drm/nouveau/Kconfig    |  4 +++-
>  mm/Kconfig                         | 14 ++++++--------
>  3 files changed, 12 insertions(+), 10 deletions(-)

Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>

Jason

