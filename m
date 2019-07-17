Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE74FC76195
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 11:58:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A5DCD20665
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 11:58:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="WsXmWAFN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A5DCD20665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 64E2C6B0006; Wed, 17 Jul 2019 07:58:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5D97D6B0008; Wed, 17 Jul 2019 07:58:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 478E78E0001; Wed, 17 Jul 2019 07:58:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 24DD76B0006
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 07:58:31 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id h198so19935666qke.1
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 04:58:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=CtIW38CyixiEAESJE2x/hR6vvP9ZY7lyz3jE6erJEA4=;
        b=JJbqtKJ3OSa4s5E0KgXSXcQtY72muYpNPHXt/ImLNXhx9rWO66lrQIrbt8teSIC4eA
         3df3p//glzb2qnD6/J/OCi48+cpApGtWb0pkMOdxxXdZ8JUK+Tqw1hbWkCM5PCbwldA7
         VTVOZRH2vLNN99HRy73v1xAhiBwMGbKI0ishpqdvBtz5cZy6bWUa9cFC5hvem4j30NCu
         MPhOoSkyyrWNsk4mKgxLs0fSMaZ94MFa9TR1SJW+SGCwpUwdk/KEYkatiSnnP0eUUny/
         MHn1X4AxzxkYvT1VEmrFITbqgoX7o+/QPt4XD7NkOykHEemXxTJp86MCl9sQ+cW/m4Tq
         kwkw==
X-Gm-Message-State: APjAAAWiiun5p6gnoEw6miVBP3tS0C8fOE9O2H1lKMEHojgXaEVQ6Ffk
	UzbmtPpPMNeoyzoSWntfKfcRIeyxUXNv3eBZMjMB0JRtiv1KO6Ku22fL+k7NSxyMKGveBu2otGy
	qWJAkYV5NZA4J+/j5C6FZT8wp44F2j+2KVDN2/i2KcRUZpZl37CQHIBA4WGJPdyqg2w==
X-Received: by 2002:a37:a397:: with SMTP id m145mr25020038qke.271.1563364710891;
        Wed, 17 Jul 2019 04:58:30 -0700 (PDT)
X-Received: by 2002:a37:a397:: with SMTP id m145mr25020005qke.271.1563364710203;
        Wed, 17 Jul 2019 04:58:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563364710; cv=none;
        d=google.com; s=arc-20160816;
        b=NVt2v6JLtBa0CGMoaCEzI2q7wchWbfvXh9m9pPnO0PsCEHiHQ+3DLIWTzR1YuV3OiB
         OoHc/q/fvehrWAa0YKKgG5oGZ75hOXrILCsWXYz99+EQNs56RybtJIyyhOSuTyRay4v7
         NNfK9y2HsoY48Fu3CofLK9DZodmWjzBZO0TRfQzzyq4di3k8mDlp3BGuC6gx5sFkt3fp
         oTPCXi5HGRv/gfFkijlraPAswzPv++LeKgjB3KCVM3xwlUDTXc0W7Gl/B864S/rJUCTN
         NZlvMPFdh2RhR0eUQMCSeq9NxsiaziIIWmNQM6uCsAyiFd3bFZcSltJaoHBfuKjyg0fd
         7cFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=CtIW38CyixiEAESJE2x/hR6vvP9ZY7lyz3jE6erJEA4=;
        b=vevKaHMhfgOiNet5O0sbQOvl6MnPNA0rWSsmFSMby45xcipTwE6skUoXRkZiy3L8hT
         qpxEMH1G2ek636fp1dAj8mtEHUV2/oF7Ds/geD6w4PJDonaTqKdN/+tbPVIb6fmfbfVn
         hUqIA0qLhuuXh96hV5XHGVMW/LxsNhbvX/AC+D+WD1NR9erGzEpTqgnbRzxtmEoI+ndq
         2qyjq7Z2dC+AgZrxbl8BqBwNxAaOBadUj8ns0YIXcImYpDFvod1GLyyT49hNgFOkrH2y
         iQ5XZGhHlHNJ/0TsrjhLlE29uxqYE73H3bT7DCIZvt8/sxKg0K8WTweC9ZafvyQl4flV
         NnZA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=WsXmWAFN;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y8sor32277391qtm.63.2019.07.17.04.58.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Jul 2019 04:58:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=WsXmWAFN;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=CtIW38CyixiEAESJE2x/hR6vvP9ZY7lyz3jE6erJEA4=;
        b=WsXmWAFNLS9Y5gyPmjyVBufuKshUnoz9oYQO3m2Kyy2wMtQLDRqxhz084Ma4sggKxA
         VrwuLzOtiAy8rszSQKzE18fvnWZV7M1q7YnEAmJigLzdicTLpZGoNiZ3Gar/CFdANUGQ
         +gt0fDflhj1oNluiZIVGuibWAh1JTcQepAsHP/YRP7PCiQsEbkufbX49wfrYCtAj9p/q
         ZpOMd9vVDGljJ+MPyoKgDKJFbWpQx34cZ14/YkYB9E0gHWhEQolXuspRkMtBiWOO9Km7
         Ew1EzqQInlJf4dxI+ivorIznpDm2P9V/p9lWf5oiX205bEqIkGxkVFU6X6xClAOP44Zp
         QzPQ==
X-Google-Smtp-Source: APXvYqx+j7x9Tmvjx0AtdL0JLRa2IEARVY42fsMnhsZXPsgl7xwQHvLdp4tWEgHcwSJhOki+ORlGpQ==
X-Received: by 2002:ac8:394b:: with SMTP id t11mr26922427qtb.286.1563364709720;
        Wed, 17 Jul 2019 04:58:29 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id n18sm10459998qtr.28.2019.07.17.04.58.29
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Jul 2019 04:58:29 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hniZo-0003Vz-Og; Wed, 17 Jul 2019 08:58:28 -0300
Date: Wed, 17 Jul 2019 08:58:28 -0300
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
Message-ID: <20190717115828.GE12119@ziepe.ca>
References: <cover.1561386715.git.andreyknvl@google.com>
 <ea0ff94ef2b8af12ea6c222c5ebd970e0849b6dd.1561386715.git.andreyknvl@google.com>
 <20190624174015.GL29120@arrakis.emea.arm.com>
 <CAAeHK+y8vE=G_odK6KH=H064nSQcVgkQkNwb2zQD9swXxKSyUQ@mail.gmail.com>
 <20190715180510.GC4970@ziepe.ca>
 <CAAeHK+xPQqJP7p_JFxc4jrx9k7N0TpBWEuB8Px7XHvrfDU1_gw@mail.gmail.com>
 <20190716120624.GA29727@ziepe.ca>
 <CAAeHK+xPPQ9QjAksbfWG-Zmnawt-cdw9eO_6GVxjEYcaDGvaRA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+xPPQ9QjAksbfWG-Zmnawt-cdw9eO_6GVxjEYcaDGvaRA@mail.gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 17, 2019 at 01:44:07PM +0200, Andrey Konovalov wrote:
> On Tue, Jul 16, 2019 at 2:06 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> >
> > On Tue, Jul 16, 2019 at 12:42:07PM +0200, Andrey Konovalov wrote:
> > > On Mon, Jul 15, 2019 at 8:05 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> > > >
> > > > On Mon, Jul 15, 2019 at 06:01:29PM +0200, Andrey Konovalov wrote:
> > > > > On Mon, Jun 24, 2019 at 7:40 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
> > > > > >
> > > > > > On Mon, Jun 24, 2019 at 04:32:56PM +0200, Andrey Konovalov wrote:
> > > > > > > This patch is a part of a series that extends kernel ABI to allow to pass
> > > > > > > tagged user pointers (with the top byte set to something else other than
> > > > > > > 0x00) as syscall arguments.
> > > > > > >
> > > > > > > mlx4_get_umem_mr() uses provided user pointers for vma lookups, which can
> > > > > > > only by done with untagged pointers.
> > > > > > >
> > > > > > > Untag user pointers in this function.
> > > > > > >
> > > > > > > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > > > > > >  drivers/infiniband/hw/mlx4/mr.c | 7 ++++---
> > > > > > >  1 file changed, 4 insertions(+), 3 deletions(-)
> > > > > >
> > > > > > Acked-by: Catalin Marinas <catalin.marinas@arm.com>
> > > > > >
> > > > > > This patch also needs an ack from the infiniband maintainers (Jason).
> > > > >
> > > > > Hi Jason,
> > > > >
> > > > > Could you take a look and give your acked-by?
> > > >
> > > > Oh, I think I did this a long time ago. Still looks OK.
> > >
> > > Hm, maybe that was we who lost it. Thanks!
> > >
> > > > You will send it?
> > >
> > > I will resend the patchset once the merge window is closed, if that's
> > > what you mean.
> >
> > No.. I mean who send it to Linus's tree? ie do you want me to take
> > this patch into rdma?
> 
> I think the plan was to merge the whole series through the mm tree.
> But I don't mind if you want to take this patch into your tree. It's
> just that this patch doesn't make much sense without the rest of the
> series.

Generally I prefer if subsystem changes stay in subsystem trees. If
the patch is good standalone, and the untag API has already been
merged, this is a better strategy.

Jason

