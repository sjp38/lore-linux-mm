Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A509C74A21
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 14:15:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C1E252064B
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 14:15:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="AwdPd/ng"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C1E252064B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5ADC88E0078; Wed, 10 Jul 2019 10:15:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 55CEE8E0032; Wed, 10 Jul 2019 10:15:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 44BDC8E0078; Wed, 10 Jul 2019 10:15:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 25DF78E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 10:15:50 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id d9so2066215qko.8
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 07:15:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=vODFuMSbeG4w9Dj8p2oXEkAy/A03DVwyuAKVY4sFSRA=;
        b=YfuezKnYniHs4kaV/9jAHvoI9H7J4jmB+8waUZTST10d9SxoNYkPDyJx1wPdZuLTgR
         gAuvj/LzueP8rInmiabvSNOb8G5CzbcXJWDdNk14OQfAtSUP6troihhM3MFbDqkNDOXt
         CGyVxGax24TdvqrBhq3x1EIWZK/oFzvYblYxOpRnHUwLsK3f22aHZXoLi4gC1lTHidzC
         FK+pnaIcr9Z6gHznoZ+70xAA8sfUJirTh4WsI+10pm5jYYPUqpf6HgsKFsSuBYGIKOS0
         Bx1KlKNoIP6eJxhB5izSBdfUaSO9YqTtALHObOV9r/ttMx5mPmB6+Axt93QWS3zLwYUE
         CK8Q==
X-Gm-Message-State: APjAAAVsdLU5OBGWRnFq6Ne8nl8y50ZLF0Xawn+a7+czL3ISwNJeV6v0
	v+dBYUkQAuCqZbt1b6rLCM6yAJseu5U0d3DTvpR6ZwGMlCnmyKVeI7bKPfLN1LrCddkPgzs36cZ
	tDLKJNpozGPJkhBIIy7WVDn/gjzsjfmFMqCZmWGim1nhAep1E48ZwJxNg8LCI1mPwEA==
X-Received: by 2002:a05:620a:1116:: with SMTP id o22mr23898066qkk.82.1562768149940;
        Wed, 10 Jul 2019 07:15:49 -0700 (PDT)
X-Received: by 2002:a05:620a:1116:: with SMTP id o22mr23898030qkk.82.1562768149404;
        Wed, 10 Jul 2019 07:15:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562768149; cv=none;
        d=google.com; s=arc-20160816;
        b=tvMJEGMvUvIk6ofXg+kIS3LS598i+i6Ssf5VHER2crFlfOsb76/wGxYsJscSw0ki+1
         G4j/O83W42VQeqc+JTgEJObEbDmlKl4SVInVTatzsfW8XGwVWkdthYsXkGkOp/sm2yTK
         yO8+X660mRxRG7K8nFcKGaelgHWjEBKCzsfF7dtyXKafoF6VXdrtYIhsD6OEhmN46aCB
         JBH/ufeMHrFrqJQpqJVwrojGGlpfB6EHQxJZBbBXWcQk5bL2PO68EIe524hmui9LxzjW
         PtA7+52S0xBOIk7fWJXFENt30Q9nvP5u5u7NpPT8a2zuqDG1XTsW/1RBrslcuZbbnRI+
         X1bA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=vODFuMSbeG4w9Dj8p2oXEkAy/A03DVwyuAKVY4sFSRA=;
        b=iL+xpZEz/HtsGcnSHM1YRnNH23DRgch74VRFu3sSD4s/+Y4WYVn5X2cHjgHzwwLGSM
         feOVi22eFsW4mWl+/HSbRHWywb6774CgcAHB9vZeu7ZGCE4LqGsh0Dj5nt2o2XG6+9bj
         uqOXMby6znuG4bWqtXZhty4T/Ub4Ra2UODav1wfAs/g3QSjjIE9yZ86bOCibx3QCm0Yi
         Je9SZR23PldSuovg3GDWxCfaQ2ORvyXHaMsY4qhDC1yAeaDfcIwQMBUvYjL3uC33mNMg
         vozyBOTMvN+xh31X5PMF69v4f3WhlObcQ1FfTXRe4NV80BzmxcLgvxj1tmBmhwfoKp8f
         Xq1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b="AwdPd/ng";
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z187sor1292583qkc.163.2019.07.10.07.15.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jul 2019 07:15:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b="AwdPd/ng";
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=vODFuMSbeG4w9Dj8p2oXEkAy/A03DVwyuAKVY4sFSRA=;
        b=AwdPd/ngT3mJRYvTsNi7+k6Pexs7qADcyr631JXNtQYsxsI+pH7+y4Ce9rum+RXvxW
         m6QBM9fvhZyOBfFcND8pcYtyZWgTB4xQtqhO9xec9FnEJqGhT5MTG3e9VhN/LHD9dgZa
         f6KOC1WXJurqXAAjkgCghV2QgM6A9EVmh5WxWeFLyGZ145JlBsCAs1BNm9jIM7t9z+Hc
         EKiq9t1c2J3X+T5XD78LORMaSqOdjhRrOwldzb/ODveWc7eQ/bjHUQA8gV5DDMl8dAJ8
         rbTcSw4HlbgcmSJKmRzKBIRGpIR9wdnJ3ZyQy1J/UbNA1XsBCR8R5xEtifXe51rYR1ZI
         Q9Nw==
X-Google-Smtp-Source: APXvYqwXdpeAq5FslPtKDZcIHkELBHHKwO4EIuzyaxhuC4csZ6L2yQ89iBXj5IXMg03W1UYI3SVt8w==
X-Received: by 2002:a05:620a:1456:: with SMTP id i22mr23125794qkl.170.1562768149112;
        Wed, 10 Jul 2019 07:15:49 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id i27sm1079838qkk.58.2019.07.10.07.15.48
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 10 Jul 2019 07:15:48 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hlDNr-0001Pb-Qi; Wed, 10 Jul 2019 11:15:47 -0300
Date: Wed, 10 Jul 2019 11:15:47 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: janani <janani@linux.ibm.com>
Cc: Bharata B Rao <bharata@linux.ibm.com>, linuxppc-dev@lists.ozlabs.org,
	linuxram@us.ibm.com, cclaudio@linux.ibm.com,
	kvm-ppc@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com,
	aneesh.kumar@linux.vnet.ibm.com, paulus@au1.ibm.com,
	sukadev@linux.vnet.ibm.com,
	Anshuman Khandual <khandual@linux.vnet.ibm.com>,
	Linuxppc-dev <linuxppc-dev-bounces+janani=linux.ibm.com@lists.ozlabs.org>
Subject: Re: [PATCH v5 7/7] KVM: PPC: Ultravisor: Add PPC_UV config option
Message-ID: <20190710141547.GB4051@ziepe.ca>
References: <20190709102545.9187-1-bharata@linux.ibm.com>
 <20190709102545.9187-8-bharata@linux.ibm.com>
 <6759c8a79b2962d07ed99f2b1cd05637@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6759c8a79b2962d07ed99f2b1cd05637@linux.vnet.ibm.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 10, 2019 at 08:24:56AM -0500, janani wrote:
> On 2019-07-09 05:25, Bharata B Rao wrote:
> > From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> > 
> > CONFIG_PPC_UV adds support for ultravisor.
> > 
> > Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> > Signed-off-by: Bharata B Rao <bharata@linux.ibm.com>
> > Signed-off-by: Ram Pai <linuxram@us.ibm.com>
> > [ Update config help and commit message ]
> > Signed-off-by: Claudio Carvalho <cclaudio@linux.ibm.com>
>  Reviewed-by: Janani Janakiraman <janani@linux.ibm.com>
> >  arch/powerpc/Kconfig | 20 ++++++++++++++++++++
> >  1 file changed, 20 insertions(+)
> > 
> > diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
> > index f0e5b38d52e8..20c6c213d2be 100644
> > +++ b/arch/powerpc/Kconfig
> > @@ -440,6 +440,26 @@ config PPC_TRANSACTIONAL_MEM
> >           Support user-mode Transactional Memory on POWERPC.
> > 
> > +config PPC_UV
> > +	bool "Ultravisor support"
> > +	depends on KVM_BOOK3S_HV_POSSIBLE
> > +	select HMM_MIRROR
> > +	select HMM
> > +	select ZONE_DEVICE

These configs have also been changed lately, I didn't see any calls to
hmm_mirror in this patchset, so most likely the two HMM selects should
be dropped and all you'll need is ZONE_DEVICE..

Jason

