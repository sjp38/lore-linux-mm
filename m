Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB0DBC76188
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 12:06:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A442521721
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 12:06:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="D1pZEppi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A442521721
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 306586B0006; Tue, 16 Jul 2019 08:06:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2B6436B0008; Tue, 16 Jul 2019 08:06:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 17C3F6B000A; Tue, 16 Jul 2019 08:06:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id E565D6B0006
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 08:06:26 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id x7so17799661qtp.15
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 05:06:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=QhpcQElL3lG0JSgeqXLUe/9qK61Ylnz+wgQS3Fp7AjE=;
        b=XJ8pLIRidonYOlOaALhpZd3XJXLrtds8nhHPfPUL+PMw74ObtX9vaJiSTSjx6SFpQl
         7/MKeOkeGlAYUUncRzEP6HYqXLZAyg+vZLg59IxwiNDljprTaXBaXXhdbmlYfbICWRue
         k3htJjg4zw3UIE6DqAgb68vx4IAR2Nz8VuziEYoo2bMizRktq7hCm09jx6B4ERrfejbC
         LSoXaQaRIAOp8GGne9961fe5funuAsdDkdhOmGALVidJy6BCoU87TLEHOZQ5c1ir4tRh
         zrnNnEFYuPrTLghtCL6oMvPLGzm80iSfdcQHuycPo99Pbqwm1Uy4b3GPxWwh8PVM8EtI
         lUPQ==
X-Gm-Message-State: APjAAAUalhBEepOuq6GibhXK5qjPnu9B0LVwMxcHNYVAKZgmrY7tpSWw
	Oxk0O5nfyj1zi2VFAsS3LfeEv4w52L1bINECWd0w1stUGUt+GfxX9OVfnq8JnzjRdRZGvvY3Hx1
	b0hhEc6msgIv8TrByqu0PBFzC/DqM0rLGKu13DZVLM+4ZDZiUvm1Uc8Gc464bSFbWRQ==
X-Received: by 2002:a0c:ae6d:: with SMTP id z42mr23461683qvc.8.1563278786694;
        Tue, 16 Jul 2019 05:06:26 -0700 (PDT)
X-Received: by 2002:a0c:ae6d:: with SMTP id z42mr23461641qvc.8.1563278786132;
        Tue, 16 Jul 2019 05:06:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563278786; cv=none;
        d=google.com; s=arc-20160816;
        b=JNMFzCPfnYRS3fCzg6sXj85mkPFo/HjYFcQNjjjJDXpQL9u4BR7/N+TNVraUNbBfAH
         +VQSzJp3TDYSgtmF9nOs3D+fz/ubVq+8/y/IwmuuitvT9Or9FDXXcVNEIr/IsyixgPVf
         aYk3RkODN74UMRr5yXYvKJ4OlaZkqjMTKL/cVMAV9sjlYxEKPOqNrRn+mz6exAt6ysHE
         ebZOjlqlZF1pyonrJyfLnZe5P6CmgicwwFZtFdF4uUk8xZ0L8z3EoF9wzBbtHmZyT8vP
         R/3ukn/IBxACA7ANtrCF2s+G1gdHgaGmuEAJXllns+OpPTZwYouMtwTq3NR+CZ4deS9r
         lO2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=QhpcQElL3lG0JSgeqXLUe/9qK61Ylnz+wgQS3Fp7AjE=;
        b=oJiJASwYRdN2G5s3VSDj30DFlSDnoSkb47yydGXYrc4ItI/pCfOR7yoQgIdudr6wzZ
         OjPZZ3P0w0iLpnDixgRU+iipShuFFpy6/r6LA5N5fanjCXlWj2EJTKlhaQVQ1i/sNorf
         AHix1Z9X0ls0fBEhk5Iu2TosMANMTosP24AJclayLrY20LyOqauVJLJW5h68gwLYRCwE
         8hLxdrRlOXMdOhyecRAa1IP/B8GQe8P9S0E5UfpsM0brEfn2rMu92tHQCm/RlbeSgDnH
         akW256e8GieA1BX8lrn7ayibS9Ih/6siR5hl72nJidnzZOkDZsmznaNyQFXLmxnhFRfx
         Zx+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=D1pZEppi;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u36sor18086106qvg.34.2019.07.16.05.06.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Jul 2019 05:06:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=D1pZEppi;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=QhpcQElL3lG0JSgeqXLUe/9qK61Ylnz+wgQS3Fp7AjE=;
        b=D1pZEppikXtQIEAGheASyppn4vPK1DguzWZpiaVk939PKpSlX+xsQppOI0OBkx+nKq
         1JMeoAeO2RtNcmtGWYdKLbdcc2TbWA6drTUMGhZaq0sz3Geu8LfsJw1hCEqbsa4Bc/j+
         JrOL+39tH0pc4sSRyK3u0NuDnGgXAecwBuMSo8RvbrqgC5vpbNsoC1TREtbzabbzYUMS
         k9WxSC0qQS+DehVxRxUbV/PWa/pVTJQcjtukye20Ck/yNfMpOiGdSRCyc7pAxi48HA7M
         W3ECRyTg6vWSNWsyBv8+jZrvPzt1c26ISNAUAqR3Nk0GH9Y/cYJuNImJ996hTYW3Y9ab
         lyPQ==
X-Google-Smtp-Source: APXvYqwaXFZZiwZu977J+QGokWcpz5v06kUp2glLI/ZNMEHnjOvZ6hmUglcng9VwXT1727jmbSrxcg==
X-Received: by 2002:a0c:e703:: with SMTP id d3mr22592037qvn.194.1563278785764;
        Tue, 16 Jul 2019 05:06:25 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id a6sm8577367qkn.59.2019.07.16.05.06.25
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 16 Jul 2019 05:06:25 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hnMDw-0007mK-JQ; Tue, 16 Jul 2019 09:06:24 -0300
Date: Tue, 16 Jul 2019 09:06:24 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Linux ARM <linux-arm-kernel@lists.infradead.org>,
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
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v18 11/15] IB/mlx4: untag user pointers in
 mlx4_get_umem_mr
Message-ID: <20190716120624.GA29727@ziepe.ca>
References: <cover.1561386715.git.andreyknvl@google.com>
 <ea0ff94ef2b8af12ea6c222c5ebd970e0849b6dd.1561386715.git.andreyknvl@google.com>
 <20190624174015.GL29120@arrakis.emea.arm.com>
 <CAAeHK+y8vE=G_odK6KH=H064nSQcVgkQkNwb2zQD9swXxKSyUQ@mail.gmail.com>
 <20190715180510.GC4970@ziepe.ca>
 <CAAeHK+xPQqJP7p_JFxc4jrx9k7N0TpBWEuB8Px7XHvrfDU1_gw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+xPQqJP7p_JFxc4jrx9k7N0TpBWEuB8Px7XHvrfDU1_gw@mail.gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 16, 2019 at 12:42:07PM +0200, Andrey Konovalov wrote:
> On Mon, Jul 15, 2019 at 8:05 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> >
> > On Mon, Jul 15, 2019 at 06:01:29PM +0200, Andrey Konovalov wrote:
> > > On Mon, Jun 24, 2019 at 7:40 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
> > > >
> > > > On Mon, Jun 24, 2019 at 04:32:56PM +0200, Andrey Konovalov wrote:
> > > > > This patch is a part of a series that extends kernel ABI to allow to pass
> > > > > tagged user pointers (with the top byte set to something else other than
> > > > > 0x00) as syscall arguments.
> > > > >
> > > > > mlx4_get_umem_mr() uses provided user pointers for vma lookups, which can
> > > > > only by done with untagged pointers.
> > > > >
> > > > > Untag user pointers in this function.
> > > > >
> > > > > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > > > >  drivers/infiniband/hw/mlx4/mr.c | 7 ++++---
> > > > >  1 file changed, 4 insertions(+), 3 deletions(-)
> > > >
> > > > Acked-by: Catalin Marinas <catalin.marinas@arm.com>
> > > >
> > > > This patch also needs an ack from the infiniband maintainers (Jason).
> > >
> > > Hi Jason,
> > >
> > > Could you take a look and give your acked-by?
> >
> > Oh, I think I did this a long time ago. Still looks OK.
> 
> Hm, maybe that was we who lost it. Thanks!
> 
> > You will send it?
> 
> I will resend the patchset once the merge window is closed, if that's
> what you mean.

No.. I mean who send it to Linus's tree? ie do you want me to take
this patch into rdma?

Jason

