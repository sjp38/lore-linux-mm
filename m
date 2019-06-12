Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2D68C31E47
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:02:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 95B662080A
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:02:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 95B662080A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E7EC6B0003; Wed, 12 Jun 2019 07:02:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 298946B0005; Wed, 12 Jun 2019 07:02:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 188CE6B0006; Wed, 12 Jun 2019 07:02:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C0E866B0003
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 07:02:13 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id s5so25337829eda.10
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 04:02:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=nqzzf4GCLLsGQ5lQsyxet53k3a8ig4fb5xPtbi3OI2A=;
        b=h0OIDhsRL5x46VmB8ZRVFKOG9l5L6uzrtB0a5LFpica/GFYPg1uJ2Q6730t0flDVXt
         a6RFYWMH61JNXzy2PeUVpsJTP5nqxFh7KP+xw7PtxsHdyumZvEbd5ClRMS/1u6A9L4ky
         WkWU529SzpNDbt7xKCmXECpMO0KfRSFZI+6HGvNdKnq1PQZzhc3ced3BoK289GIKKLuV
         KpdnOyOFzusHaEOHM16a27bPlODlvhYr8XxoOVt95/FM6IhM3ueqCM8rF9WnGYANvEwn
         2rTFYmDWbn3OOgtXYILDt/QSOodnQeMnZIaP2O3JqFV9lWKB5GIz+86ZCPBlfjTnHoFr
         QGUg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAUcF/OfIWKmi9RxYZlK9Y/Wf8/9wAxXup30HFlZWrlzX27GrkzA
	SLxI11FKowc+o5Uy3J/UCXtOHxp2FLws4d9OYWCtalAx6gtRMiCGTYJeg3Kn8O5XxSxXRbvDZxJ
	dQOUJEA0/y3o4OF9qw5rupNIEAcRXOCHjnSWW6KlQIvnLHslMuOp6AX/boOVGDMH11A==
X-Received: by 2002:a17:906:c3d0:: with SMTP id cj16mr40430317ejb.96.1560337332992;
        Wed, 12 Jun 2019 04:02:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzxD+Ebg8D1TpgjUOP65MAfm2LAJygs9y3OraJT1v5QH20+/ZyHYAEu0zcBcfxumU2OTat3
X-Received: by 2002:a17:906:c3d0:: with SMTP id cj16mr40430235ejb.96.1560337332111;
        Wed, 12 Jun 2019 04:02:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560337332; cv=none;
        d=google.com; s=arc-20160816;
        b=FUMQn5G7/U0Fw4XA/6XztXs4X9XNftwq1dm/4YeJ9JjV5juFEqwlmp+UyMB4mzv5JH
         3HyLsPM1tjnQRM6J/iYnf+f8jwCfpZhey9Cmk2aMsKdoiJA1uBNxHER46Dk5yGCb+9Hu
         Uaub1Fix7gTpqLWwmfsZlx8jJ2aNj+aeCTq1OwwbcwOV6dbGcjDO0CyGY2FTDD4f6Obd
         /1LyPHnXa6GixSWXZXeeWOoQKDzwAYn4a1XlBoSIGuxxTB+1Ro/NgGgWK+gkl9ObyYEb
         g5tUkbmoVyTfhV1p+LdJyNSYdKVxm/6z5pkVNmX4QXabEXgmQj50m/nv8yybP1QuP21a
         IO4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=nqzzf4GCLLsGQ5lQsyxet53k3a8ig4fb5xPtbi3OI2A=;
        b=LHBoKMfYXbf33+FEGZTQ2QKlPWBSBRv2OU+5rgxSMmdsjWcYtFT0WpVQ26NfZ0ihfD
         oCy8ZFWdUZsL18WMMis3fu7DXIdLXy6qvHMyAmwQDSc5PpS9VlWA69In8rhQyGbIzvJB
         2zsMYUvirKFGXGEuEK/Ba1pSAwCmDxs/88Q4fqNw8sQwPeYeBfwVzicCe5Tnw3O9RjzZ
         C+2c0c1Xsw+t0lNj0Y9FtKX8HugNqEJdNohDJnAJDfHPvwpeaxUW33SgcV/Xa00kLygQ
         F+u2p+5M7xY6+CYGnYpQooBfEgi18uPy2crecxK2Z1WfJwpXBBTi7041pvOl/qbG4eZC
         inEg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id f10si1168066ejq.375.2019.06.12.04.02.11
        for <linux-mm@kvack.org>;
        Wed, 12 Jun 2019 04:02:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 1E16528;
	Wed, 12 Jun 2019 04:02:11 -0700 (PDT)
Received: from C02TF0J2HF1T.local (unknown [172.31.20.19])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 04CA33F246;
	Wed, 12 Jun 2019 04:03:23 -0700 (PDT)
Date: Wed, 12 Jun 2019 12:01:34 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Kees Cook <keescook@chromium.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Leon Romanovsky <leon@kernel.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>,
	Christoph Hellwig <hch@infradead.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v16 12/16] IB, arm64: untag user pointers in
 ib_uverbs_(re)reg_mr()
Message-ID: <20190612110129.GC28951@C02TF0J2HF1T.local>
References: <cover.1559580831.git.andreyknvl@google.com>
 <c829f93b19ad6af1b13be8935ce29baa8e58518f.1559580831.git.andreyknvl@google.com>
 <20190603174619.GC11474@ziepe.ca>
 <CAAeHK+xy-dx4dLDLLj9dRzRNSVG9H5nDPPnjpYF38qKZNNCh_g@mail.gmail.com>
 <20190604122714.GA15385@ziepe.ca>
 <CAAeHK+xyqwuJyviGhvU7L1wPZQF7Mf9g2vgKSsYmML3fV6NrXg@mail.gmail.com>
 <20190604130207.GD15385@ziepe.ca>
 <CAAeHK+xBxDB-OBuzPDcNaTHCNJqu6djHwqoVGSYpxG33w-YR9g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+xBxDB-OBuzPDcNaTHCNJqu6djHwqoVGSYpxG33w-YR9g@mail.gmail.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 04, 2019 at 03:09:26PM +0200, Andrey Konovalov wrote:
> On Tue, Jun 4, 2019 at 3:02 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> > On Tue, Jun 04, 2019 at 02:45:32PM +0200, Andrey Konovalov wrote:
> > > On Tue, Jun 4, 2019 at 2:27 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> > > > On Tue, Jun 04, 2019 at 02:18:19PM +0200, Andrey Konovalov wrote:
> > > > > On Mon, Jun 3, 2019 at 7:46 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> > > > > > On Mon, Jun 03, 2019 at 06:55:14PM +0200, Andrey Konovalov wrote:
> > > > > > > This patch is a part of a series that extends arm64 kernel ABI to allow to
> > > > > > > pass tagged user pointers (with the top byte set to something else other
> > > > > > > than 0x00) as syscall arguments.
> > > > > > >
> > > > > > > ib_uverbs_(re)reg_mr() use provided user pointers for vma lookups (through
> > > > > > > e.g. mlx4_get_umem_mr()), which can only by done with untagged pointers.
> > > > > > >
> > > > > > > Untag user pointers in these functions.
> > > > > > >
> > > > > > > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > > > > > >  drivers/infiniband/core/uverbs_cmd.c | 4 ++++
> > > > > > >  1 file changed, 4 insertions(+)
> > > > > > >
> > > > > > > diff --git a/drivers/infiniband/core/uverbs_cmd.c b/drivers/infiniband/core/uverbs_cmd.c
> > > > > > > index 5a3a1780ceea..f88ee733e617 100644
> > > > > > > +++ b/drivers/infiniband/core/uverbs_cmd.c
> > > > > > > @@ -709,6 +709,8 @@ static int ib_uverbs_reg_mr(struct uverbs_attr_bundle *attrs)
> > > > > > >       if (ret)
> > > > > > >               return ret;
> > > > > > >
> > > > > > > +     cmd.start = untagged_addr(cmd.start);
> > > > > > > +
> > > > > > >       if ((cmd.start & ~PAGE_MASK) != (cmd.hca_va & ~PAGE_MASK))
> > > > > > >               return -EINVAL;
> > > > > >
> > > > > > I feel like we shouldn't thave to do this here, surely the cmd.start
> > > > > > should flow unmodified to get_user_pages, and gup should untag it?
> > > > > >
> > > > > > ie, this sort of direction for the IB code (this would be a giant
> > > > > > patch, so I didn't have time to write it all, but I think it is much
> > > > > > saner):
> > > > >
> > > > > ib_uverbs_reg_mr() passes cmd.start to mlx4_get_umem_mr(), which calls
> > > > > find_vma(), which only accepts untagged addresses. Could you explain
> > > > > how your patch helps?
> > > >
> > > > That mlx4 is just a 'weird duck', it is not the normal flow, and I
> > > > don't think the core code should be making special consideration for
> > > > it.
> > >
> > > How do you think we should do untagging (or something else) to deal
> > > with this 'weird duck' case?
> >
> > mlx4 should handle it around the call to find_vma like other patches
> > do, ideally as part of the cast from a void __user * to the unsigned
> > long that find_vma needs
> 
> So essentially what we had a few versions ago
> (https://lkml.org/lkml/2019/4/30/785) plus changing unsigned longs to
> __user * across all IB code? I think the second part is something
> that's not related to this series and needs to be done separately. I
> can move untagging back to mlx4_get_umem_mr() though.
> 
> Catalin, you've initially asked to to move untagging out of
> mlx4_get_umem_mr(), do you have any comments on this?

It's fine by me either way. My original reasoning was to untag this at
the higher level as tags may not be relevant to the mlx4 code. If that's
what Jason prefers, go for it.

-- 
Catalin

