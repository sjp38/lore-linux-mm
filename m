Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32BFCC41514
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 14:02:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EAEB822C7D
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 14:02:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="HGjiQdK8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EAEB822C7D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7D8A06B0007; Wed, 24 Jul 2019 10:02:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7B00D6B0008; Wed, 24 Jul 2019 10:02:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 69F148E0002; Wed, 24 Jul 2019 10:02:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 32AA06B0007
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 10:02:25 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 71so24169499pld.1
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 07:02:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=1WV08YSE1XBp/V/oL6QW3i+VMnK5snm1td59dPVRgYI=;
        b=hUuWVfd+W09Oanu8VnAEXj9YpK5h4MhQI8NUHXuDvvkrHoGT5knLclitc0iGq2Bvi4
         58XQ3tBA0Ke5Jb4tXsGaXSVjpw8v0yBBRkQlr0NTB2cfaiFoWoJyMGQjoVsvW4cvmot6
         9/cySiMkwPQJeRASl7qvy0zWjiiTBWkyxN4Tv8iQ04onU9DdqkX2LtXRIMW0N5Hl3N5M
         rDEP2YfY/ewcq91dA5KEZiUKaqgKK2WOAnxMaDcHHpn+PROquFs9BcayV7kNsjlrgBf7
         B89U21txRtjXplx2WZkVPZm4DnXXY5/oh7O6Qlq6E9locK1YWeKDjNto8DKdPnaH+fMd
         YEsg==
X-Gm-Message-State: APjAAAVqnqTjVph19gw7YvUUFJaR9fgbjFt/q+WhID+SMRxJWwOuVLqH
	fbULnBM9y+M1pPWrLOGRaUQEwTGZ9DVFRPh6VBsM0kn5JF9zgV848mXCeKl+OJowyN3Ay+TwmFZ
	iFs2PDoqeilYNzFnbxBil83t2FS0ZiCnDFPCFdiUXUPtw0KlpS4O0Lr8XiDTyO+cTKw==
X-Received: by 2002:a63:ee08:: with SMTP id e8mr27561471pgi.70.1563976944625;
        Wed, 24 Jul 2019 07:02:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxOFmA0uYouR46XXEsfYpKoB5CAwmamA6naTs+r35ExD4rwAuPIpnajuFnG/nfVlbAoqPdU
X-Received: by 2002:a63:ee08:: with SMTP id e8mr27561300pgi.70.1563976942719;
        Wed, 24 Jul 2019 07:02:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563976942; cv=none;
        d=google.com; s=arc-20160816;
        b=aicn6j2UlmuzJOwYJsgQ1zxgq8FwChe4WNva5jOG6yjLJnC+nojxn4C53oVIftqztn
         gZjOWFG6dztezQxoeSsU8z+TqQfm48Ifrb5CzitJbi3lOGWI17Z33UR/GwmHuG6+k9c8
         fPp4VNUP3MqIy/Qdfl7IMFumaykfRB00rr/6q2TiJQAUXUFvKJjGZAU72nl8KaotwZUE
         czH2OFtYisqFeFUqS/oGzH1bmKpiXJjA2CAAv8lfgERHHJI/Sz1lHNDGL+abtZTOswen
         bvVVL5fDTKbv4EIWhePbWkVjqm4zS5Xztqjb8iQX5y+pzdwKSc1yoJ8koAbSvazJhXdt
         mX+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=1WV08YSE1XBp/V/oL6QW3i+VMnK5snm1td59dPVRgYI=;
        b=UEYAniRFnhOIa+04MDRNE7dSXhNwmwVs6svUXH8tzyD9C06Iv2BKpg2Z19dWzPSSZP
         tk4AxJp7qxIJP0nZR0SEaWAFqxqcmgdfa/ZeUJ5NHumqZuTlMeS8qCGuW1rBk/3V/NA0
         4iguL1OZZq8GRwyNDiG+aI0yX4mOoREeIetBGICBI+kPDBEEnXwOF9oCtI53/A/RZvOn
         9U3b2nROniVaVXFyr920muDVs3G8/FuWDyeZHQp5uQSMFNFbHMnT3s1OeifaI9+PzvQh
         wzwgeyqP1bZC4Tb3Vqz4nX4H3LJtUTXNzXZ2ChuFKkHSSNIqwmTkOzVJ5gY1KT5P0LNF
         zg3w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=HGjiQdK8;
       spf=pass (google.com: domain of will@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=will@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id bd11si13116715plb.184.2019.07.24.07.02.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 07:02:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of will@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=HGjiQdK8;
       spf=pass (google.com: domain of will@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=will@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from willie-the-truck (236.31.169.217.in-addr.arpa [217.169.31.236])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 0A09422BE8;
	Wed, 24 Jul 2019 14:02:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563976942;
	bh=akL4t3WLQfvH/sx6baSCdRPzrJPet6bQ0ZZAPYisZi4=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=HGjiQdK87WShqPUCUDRg97LnVe6uyeIf9yy5HPpwultEhX+41Yn3D/DKXjIK8Af4f
	 0ygT0V9wgzsE+RPZ4QFVtqujFkiagNZGrOWFPz6QtW3TCSySYN2+CMJ5pNSGE1vClG
	 0S7ixJF2Qf9InXHgM9sSGPD0ag6vRkrIxQa7ibh4=
Date: Wed, 24 Jul 2019 15:02:12 +0100
From: Will Deacon <will@kernel.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Mark Rutland <mark.rutland@arm.com>, kvm@vger.kernel.org,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Will Deacon <will.deacon@arm.com>, dri-devel@lists.freedesktop.org,
	Kostya Serebryany <kcc@google.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Leon Romanovsky <leon@kernel.org>, linux-rdma@vger.kernel.org,
	amd-gfx@lists.freedesktop.org,
	Christoph Hellwig <hch@infradead.org>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Dave Martin <Dave.Martin@arm.com>,
	Evgeniy Stepanov <eugenis@google.com>, linux-media@vger.kernel.org,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Kees Cook <keescook@chromium.org>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Alex Williamson <alex.williamson@redhat.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Linux Memory Management List <linux-mm@kvack.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Lee Smith <Lee.Smith@arm.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>, enh <enh@google.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [PATCH v19 00/15] arm64: untag user pointers passed to the kernel
Message-ID: <20190724140212.qzvbcx5j2gi5lcoj@willie-the-truck>
References: <cover.1563904656.git.andreyknvl@google.com>
 <CAAeHK+yc0D_nd7nTRsY4=qcSx+eQR0VLut3uXMf4NEiE-VpeCw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+yc0D_nd7nTRsY4=qcSx+eQR0VLut3uXMf4NEiE-VpeCw@mail.gmail.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrey,

On Tue, Jul 23, 2019 at 08:03:29PM +0200, Andrey Konovalov wrote:
> On Tue, Jul 23, 2019 at 7:59 PM Andrey Konovalov <andreyknvl@google.com> wrote:
> >
> > === Overview
> >
> > arm64 has a feature called Top Byte Ignore, which allows to embed pointer
> > tags into the top byte of each pointer. Userspace programs (such as
> > HWASan, a memory debugging tool [1]) might use this feature and pass
> > tagged user pointers to the kernel through syscalls or other interfaces.
> >
> > Right now the kernel is already able to handle user faults with tagged
> > pointers, due to these patches:
> >
> > 1. 81cddd65 ("arm64: traps: fix userspace cache maintenance emulation on a
> >              tagged pointer")
> > 2. 7dcd9dd8 ("arm64: hw_breakpoint: fix watchpoint matching for tagged
> >               pointers")
> > 3. 276e9327 ("arm64: entry: improve data abort handling of tagged
> >               pointers")
> >
> > This patchset extends tagged pointer support to syscall arguments.

[...]

> Do you think this is ready to be merged?
> 
> Should this go through the mm or the arm tree?

I would certainly prefer to take at least the arm64 bits via the arm64 tree
(i.e. patches 1, 2 and 15). We also need a Documentation patch describing
the new ABI.

Will

