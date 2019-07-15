Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41CFFC76195
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 16:01:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0CE7B20838
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 16:01:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="m3ylaWA1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0CE7B20838
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A5D396B0010; Mon, 15 Jul 2019 12:01:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A0D496B0266; Mon, 15 Jul 2019 12:01:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8D4F16B0269; Mon, 15 Jul 2019 12:01:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 59CA36B0010
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 12:01:42 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id d2so8489438pla.18
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 09:01:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=lChEEghQFkJA0ae9eAwhZ0QJmvdqy/WLUOFz361BXCQ=;
        b=PxfZWKXdJeZGaIcHxCcG/86HMdwBW1gVzc/4vhDBBNrFicFck2x54UEQN1Wz1+zeQw
         pyeyORvffFBjC1l3NhORE60Q+J5lDM660w8uUfMkeTooZ/lqFy8JFdb/b5rQM7xU3oe9
         mgOdLseN5512FxZJOXdYjefnV0t+tUfuQy2JaeoZRF5ecW2PEbL828htIzFuWx1irAl+
         qU1jetSdMXXdz5P6Bq39er58hQYOtJn/JHAV0r7KCKR7Zv3Efrm/lQU3TBn3KyZIdMJ4
         ShTfBGxUQ5fg7114YVwCIFngKo8aI2v3zcW/jTEzCOKGBVcH8Z2Mj9b9L3eWsvTHhOtF
         klrQ==
X-Gm-Message-State: APjAAAWIb2tSEqcI5a1yrm8yKDTFFn7piHn2Zkp4TS/F6/l8AsdycM34
	4dDU6dfAnZNkb+19tjtRYOxq0vVIVDNbn8FoRDssHnENyBfsv2aqB5PMTQoEfYIaYBnKwdcHGEc
	1IiEVlt0nhe/vM6WqE/vrQKuX0ancDLIKJVTlt6hr2OAR+dNyqzBmnNZJqIiYhTwdFw==
X-Received: by 2002:a17:902:20ec:: with SMTP id v41mr27541051plg.142.1563206502064;
        Mon, 15 Jul 2019 09:01:42 -0700 (PDT)
X-Received: by 2002:a17:902:20ec:: with SMTP id v41mr27540987plg.142.1563206501377;
        Mon, 15 Jul 2019 09:01:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563206501; cv=none;
        d=google.com; s=arc-20160816;
        b=GwIBiFWSC5CfuO8HG1BmqjCTuLY9BgkYWWNoIy1be8pQVZ79MkHo0kT9Tyw0BKgmzP
         ID3z/wt+VjnTkBEzALrVPPt7DsFsay90AZ/4JgMMec9FPiPHcLfqv+Q6sYamVKDw66YF
         be5zEMGfIzwsK9bgNFLVmEkx4iiG/LfNPr5FSbhjCGeUCJ5xGvd5ERKxktQIBX3G1JfN
         gnUCSumCT7eibhiXd4aH0fvNqGXfXqnaf8HDKmei4FoWYL/rpOnbWQkl7pNzTUUoW/sD
         ofHqnu8OBGiMbbsr0ACbn0nTTwAchiqm2AjgENQTy/SToUAAWb8KUcH1pMesDsTNFxSG
         6fhA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=lChEEghQFkJA0ae9eAwhZ0QJmvdqy/WLUOFz361BXCQ=;
        b=ZAf7FC9xoqnKn0pU42hOlfsO/EU9BhbpHCA6EfyPkhCEry3TxeLIho2FAkB5YjWlTA
         GoNFQSi3sR4LX1J8LHeDTA1N9KXvZLxHBfNrbmI1LuZER5k3e9IMWEnA8sCdjVD+XYQr
         YZ9q4Ds2FldOMRRMMEQ7848f9epAJ0kt6h6GR12uZzKPGIk27HfeB1XFvQnxus6Lxsfi
         L2+mbCL2+Fu7VdulE8i4RCKN/vmXG7T6DSB9z4S9uWjEblbtt7EbWdvL9qbCShTovrv8
         CKvM0eniIyqd0QCtoDyQTV7yLMs5GlotHo+F6pgCdFV8957OyYGd9jh8yYFQqr8xLVkS
         mEqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=m3ylaWA1;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t69sor21650182pjb.5.2019.07.15.09.01.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Jul 2019 09:01:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=m3ylaWA1;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=lChEEghQFkJA0ae9eAwhZ0QJmvdqy/WLUOFz361BXCQ=;
        b=m3ylaWA1nfDKOLFQBZbi5lVR91/hvH9n6ddTo7/UGe/KLQTke6nfJGGnTYTOxi8VCA
         HfS0hKS7p+bVQo6gCnikJZrIRnFAsBOo76vo66MNNR76VN9RpCPaB5uiN9mXzb/wKBaC
         2YPMCtyHAVUy8c0n2Hy0noVhGDDAso8pOP+OWaQofcmHPvFQjxyIKXwz5wkCf0bTrn7S
         NzX5/+eAUp4zqkWQrLjg7UELrWGHhufD8/uShStHD6i3q1aY9KquzAKDzGkmcTnssS5F
         Z3nCiKnfqdcqBaEFScvEV6fXgwg7XscQvG1/2qeAbDEIc8Yoj5aguZfuLCcnlHXlWZQG
         m73g==
X-Google-Smtp-Source: APXvYqyLZ0wS0QgBngEcy3YbbCLzw5RatJ3FtyfhyqUYHKhFv456jIze9R6yuxvC6+RP9cmNsJEN8HfxXPuILyhJ/1w=
X-Received: by 2002:a17:90a:a116:: with SMTP id s22mr29861239pjp.47.1563206500702;
 Mon, 15 Jul 2019 09:01:40 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1561386715.git.andreyknvl@google.com> <ea0ff94ef2b8af12ea6c222c5ebd970e0849b6dd.1561386715.git.andreyknvl@google.com>
 <20190624174015.GL29120@arrakis.emea.arm.com>
In-Reply-To: <20190624174015.GL29120@arrakis.emea.arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Mon, 15 Jul 2019 18:01:29 +0200
Message-ID: <CAAeHK+y8vE=G_odK6KH=H064nSQcVgkQkNwb2zQD9swXxKSyUQ@mail.gmail.com>
Subject: Re: [PATCH v18 11/15] IB/mlx4: untag user pointers in mlx4_get_umem_mr
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, 
	Vincenzo Frascino <vincenzo.frascino@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kees Cook <keescook@chromium.org>, 
	Yishai Hadas <yishaih@mellanox.com>, Felix Kuehling <Felix.Kuehling@amd.com>, 
	Alexander Deucher <Alexander.Deucher@amd.com>, Christian Koenig <Christian.Koenig@amd.com>, 
	Mauro Carvalho Chehab <mchehab@kernel.org>, Jens Wiklander <jens.wiklander@linaro.org>, 
	Alex Williamson <alex.williamson@redhat.com>, Leon Romanovsky <leon@kernel.org>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
	Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>, 
	Christoph Hellwig <hch@infradead.org>, Dmitry Vyukov <dvyukov@google.com>, 
	Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>, 
	Catalin Marinas <catalin.marinas@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 7:40 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
>
> On Mon, Jun 24, 2019 at 04:32:56PM +0200, Andrey Konovalov wrote:
> > This patch is a part of a series that extends kernel ABI to allow to pass
> > tagged user pointers (with the top byte set to something else other than
> > 0x00) as syscall arguments.
> >
> > mlx4_get_umem_mr() uses provided user pointers for vma lookups, which can
> > only by done with untagged pointers.
> >
> > Untag user pointers in this function.
> >
> > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > ---
> >  drivers/infiniband/hw/mlx4/mr.c | 7 ++++---
> >  1 file changed, 4 insertions(+), 3 deletions(-)
>
> Acked-by: Catalin Marinas <catalin.marinas@arm.com>
>
> This patch also needs an ack from the infiniband maintainers (Jason).

Hi Jason,

Could you take a look and give your acked-by?

Thanks!

>
> --
> Catalin

