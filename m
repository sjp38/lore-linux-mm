Return-Path: <SRS0=RgjX=VG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9BE9C73C53
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 19:33:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 73B6F2080C
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 19:33:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="nJSBYwdx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 73B6F2080C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 17E418E0058; Tue,  9 Jul 2019 15:33:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 107A58E0032; Tue,  9 Jul 2019 15:33:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F10918E0058; Tue,  9 Jul 2019 15:33:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id CA6CC8E0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2019 15:33:22 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id h198so20253059qke.1
        for <linux-mm@kvack.org>; Tue, 09 Jul 2019 12:33:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=TqnFX/ucbxcY5k2LU8B7XgzLfUpDzAFYa9LXap9J5UU=;
        b=FMNl2mhCDiWGSoL6FvDXGSKSEhh5hWA7mqIMlsR5z+Vk5htpQznBgK/eT7Brb/QVIs
         AwR2JcGgIfglfNRRYgtv/y1jnAe9gR9XL4hT8OJkpJVvXrWWsM/XLFKe6mbO7396zR3m
         90P6wLZhHsDTEseODPU8tpdPdItNILSeATt6Th/E3ksYyJQRV/ZhsKZs4atk5wM4+CRi
         uPQ1TXGYOLrnPTfayBzVhVr4HWmrNunKSJ86deMEVL3gDKi09JcAOYxX8B4PQqtCk0su
         f45lgnJj+xccmnuqNHDr8zhfoPTLNh11P+fSx71lznG9S7Hzz3ns8f5kePtWzIYwooXK
         nKeA==
X-Gm-Message-State: APjAAAUB7cVQ8vp4PfhCcZlfqYR2dIQk42j70GE6L0qT3W806pmn4XDt
	C3YFq9Vx/sej9MOviDyvTrrfCeG3ojy/CVyW0zB4NOM9+O9yJf4PKIzVrKfp2/FjTmEiKOrc3ik
	4X0ocHYnCV/3A3C3gsCb/OsgYHgrv0n5LQ+6oishzgsUjKmWXwaORRLlbuCvDXaGv+A==
X-Received: by 2002:a37:9144:: with SMTP id t65mr21016870qkd.367.1562700802538;
        Tue, 09 Jul 2019 12:33:22 -0700 (PDT)
X-Received: by 2002:a37:9144:: with SMTP id t65mr21016836qkd.367.1562700802031;
        Tue, 09 Jul 2019 12:33:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562700802; cv=none;
        d=google.com; s=arc-20160816;
        b=eqJ2oR8dzizmHbGFxvUAtSd4kzmsUN4uzeyuEvXVsoZCXbYO7BLzpOxoeiJJCpGJls
         T0IDXPkGuvc08wZ8qTYSv3QdfSMHWVIzmVhWpXSI+02rZE3zzUfvSrKUntB/wafblgxL
         Anv25hIXtvUIWygKY9TxVVaRw//8kn5J3fq61xqsk+BVgILJq/vf+gWwRKiTP/bUuvFV
         Z4l3Q3bvRyTG04D9e47EJzcpFO/mIU4vCxMD1fHf+TbwxpMZGqSoUzqeZQP+f0QtrhRf
         CQzKLlO+tyMinupMT/S7fD6igGEN0Vegq/scGwJfF0S5tZsmLlROjkI7/uRLbZ2or6Mp
         dlLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=TqnFX/ucbxcY5k2LU8B7XgzLfUpDzAFYa9LXap9J5UU=;
        b=M4q2inUpybXK90aaNs9xuOy8jucJzWO8zqIlJhUJ/ZfASr78qRujNILsZ1Xs2Rc/cs
         2pZnsKUiEX0RuEboxKq7JBPhUvWZRcCnw3BudwyaYjviOQrDA4d6jrOoMK+N2MNwD2GD
         JQgG0ENXxdDS+WeNMrQnEZUtXi5uzjSJXkNZohmUGgmo0ydoUD1fpvB58Wg4mZ5qzusk
         PTLrdQobplKph391+7U5Zs3A+ASfoaC6KQI8KNP6t112OByfHdMtvlA8Jwz2pHWRza4N
         2bfJmMBb+roGXBVpQkx4x+sStZDnCAStAXtiPhRafqk27hBuYZ7fDwza45G5zs/I7caf
         T76A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=nJSBYwdx;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h127sor7987667qke.197.2019.07.09.12.33.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Jul 2019 12:33:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=nJSBYwdx;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=TqnFX/ucbxcY5k2LU8B7XgzLfUpDzAFYa9LXap9J5UU=;
        b=nJSBYwdxUv5VMP0rEUMz93pcWQ28dTbOLxoOwrWHLWCf1MSxkLTpKz2x8fxtV2+E/R
         tXsUU3isWUYxjOPUM6t0qCMv560B5H1unNR0QcR5JPw3ycBYCoKo4LDe/wsMqNEhL/zl
         ZczdjxlpNisocOP3/OhjpkUf2xKW2V9mrCM6eDI3EmS5aK4e6AbXWsFA/MaZCNHhyEnk
         w4Z42pcMYK3A/nvN2x/95LPHdAv9lAcaP70awzU4Hvnyy2CUphCP4NqDwoLxyz/O5kpd
         AcIgjMsPHoTqJr8TeoXVzKWAKEnMRS83pZDgNEkgwGuWMagj18LeXUOa06mYcaDBm5pC
         i90Q==
X-Google-Smtp-Source: APXvYqwJv1A9aQVqldMtbeBQ5nnec3iTfBKL3S6OeKUyA3kkYjNI/CON0uVEHClqFsFEEJNKMO/I9A==
X-Received: by 2002:a05:620a:1006:: with SMTP id z6mr2854127qkj.312.1562700801760;
        Tue, 09 Jul 2019 12:33:21 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id 67sm9662013qkh.108.2019.07.09.12.33.21
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 09 Jul 2019 12:33:21 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hkvrc-0003nt-Rl; Tue, 09 Jul 2019 16:33:20 -0300
Date: Tue, 9 Jul 2019 16:33:20 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Christoph Hellwig <hch@lst.de>
Cc: =?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>, linux-mm@kvack.org,
	nouveau@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: Re: hmm_range_fault related fixes and legacy API removal v2
Message-ID: <20190709193320.GD3422@ziepe.ca>
References: <20190703220214.28319-1-hch@lst.de>
 <20190705123336.GA31543@ziepe.ca>
 <20190709143038.GA3092@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190709143038.GA3092@lst.de>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 09, 2019 at 04:30:38PM +0200, Christoph Hellwig wrote:
> On Fri, Jul 05, 2019 at 09:33:36AM -0300, Jason Gunthorpe wrote:
> > On Wed, Jul 03, 2019 at 03:02:08PM -0700, Christoph Hellwig wrote:
> > > Hi Jérôme, Ben and Jason,
> > > 
> > > below is a series against the hmm tree which fixes up the mmap_sem
> > > locking in nouveau and while at it also removes leftover legacy HMM APIs
> > > only used by nouveau.
> >
> > As much as I like this series, it won't make it to this merge window,
> > sorry.
> 
> Note that patch 4 fixes a pretty severe locking bug, and 1-3 is just
> preparation for that.  

Yes, I know, but that code is all marked STAGING last I saw, so I
don't feel an urgency to get severe bug fixes in for it after the
merge window opens.

I'd like to apply it to hmm.git when rc1 comes out with Ralph's test
result..

Jason

