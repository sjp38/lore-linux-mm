Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED2A5C7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 11:17:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 86F1B22BF5
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 11:17:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="PFlEvXsH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86F1B22BF5
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DDE918E0065; Thu, 25 Jul 2019 07:17:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D8EDA8E0059; Thu, 25 Jul 2019 07:17:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C7E4E8E0065; Thu, 25 Jul 2019 07:17:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 923B58E0059
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 07:17:46 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 65so26098389plf.16
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 04:17:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ceQemw0wuGQ3uiCqTlyBUwO60vemC2ljY3rBL1bAUvc=;
        b=t8CbQNOu5sbohkTWkxf3H//QKw1+q9SDH1i+OXszCMbkdkL0kqrAYHLRn38Rzxzg9b
         S4mO+X+9h2S4XygoqKPl/KHQ5GiWBbR6a9ReP6I3SpxHbsbwMSjyPZCrWJz31W0lOzGq
         5LZj2AdxclSOqp+JEH94DBr3Z/kaS9TtBWHAZx7sTczdgylTECdCRIGB69iidlWmNGB3
         2GJYrb11WuOgjX+hbNN8Gdi7qf/Fj2yHlT7ZWJpSQh6yni+ZCIYfEDnoBlukrU5n2TUe
         1r/rBivXHAgBCWUD6DGIekBtlGvxHK7XkfpNYFKJm5xcAIGZtAnLfnlcLKkdwsAerYlA
         +C4Q==
X-Gm-Message-State: APjAAAVPxw18/14gc7Jw/vDpxEAnagpqwYaVMJIr/367BnkVx1xgcYf2
	dlJgTcVTdnQ77zj3vH1NpIz0nZyZ/788fd3sct/BHQSGOA+rTkC5pr3AQtsWSm1oBt5glXOXA1c
	XaDnEHaSRQwnvzTbm87fZwRYwkyn2p/2laO2ckY4mj7euXh1F8E87MyaQNhj6ZngGPQ==
X-Received: by 2002:a17:90a:8984:: with SMTP id v4mr92157421pjn.133.1564053466121;
        Thu, 25 Jul 2019 04:17:46 -0700 (PDT)
X-Received: by 2002:a17:90a:8984:: with SMTP id v4mr92157353pjn.133.1564053465158;
        Thu, 25 Jul 2019 04:17:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564053465; cv=none;
        d=google.com; s=arc-20160816;
        b=Rfl1cro2wsHESlKXlgLFIszAolovrOwj9JE/P79zHoWzkGogmtvOcXwdOM8ojwMHE+
         zK014b23bTqVO32mDYETGMhYy+i8+2D6IwWcvnpYK6jhbB+JxW/lDrnkLC9FD183qe4X
         Qg6ygnyz/JxvfWKgkqGlgt7E22afrlBSC6klk65haKjQQWm0eZC8F8nYbcWGrzFsunrn
         di/Ab6XORcu0gqI4g82ZMk2CQrmrTq+8ygNAKHw+iKrM7XPyPuAB9sCY4bnqRngOoM8L
         idsV6dj+4yy/A93vimnQitKlKTg7aDqmBwSbdxRGsC5V1voVNSzs5dLp3RmdgL5qgEDy
         ajJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ceQemw0wuGQ3uiCqTlyBUwO60vemC2ljY3rBL1bAUvc=;
        b=WtyvT69LX0gNr6byQJOcxCn3Lnf+W73ASTFA7Gw/PFwSmhCtYemTljU32hUIy0FXx4
         5fdm1HCaIsmI4Mq4J7gjaglCbkbz2tg6GY5rF2b+S4oJOCwPrFVmb4bZ+maE5N1eKVbV
         owGbYxg3q30aHIZ79muHJl+R5v4gNhhYO1TO80SqlkwE2Bhfc6Rp8XB7Rw16rzWkBdrl
         T1bqNCs/Oz6mdLiI8DahjkHYKp131DOs3JwnEpWeMHXkGugNetSUPN0lb8xPQDpmRC9z
         rFSBt2YsI+jfwBZXk9AFuLV0eTqJfg6q95i7yo6HoyLqW1Dkj1Zdfg/0gjHkgC0aPAPQ
         DUbg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=PFlEvXsH;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u13sor59518651pjx.25.2019.07.25.04.17.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jul 2019 04:17:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=PFlEvXsH;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ceQemw0wuGQ3uiCqTlyBUwO60vemC2ljY3rBL1bAUvc=;
        b=PFlEvXsHYv4lFKGCCfXZ2BH9B+e/+FJBGpnFm58EL07XzmLkrfPE7grKe+lK7OJ+3q
         abjryupEyT3OpTe6vXeYbGcL1BUr5elNwdNVi9kwG5uLVwrmRNAlILwAOBEDWE3BDhoL
         wa/mA/jPR9b/azqkL/67D+Mm2vUNeUnKTr67F6b6zVcvZzUWDrGmaUvbPo48izoM48MU
         N0VWZj0yxfEFkbETpli1M4tpWnMK/JyQnFJyyMLRYouRu9gpM1Vf3XJFNTnOwCnTu9Ld
         itsx5ZgymWeM6DKM8q2cX7rBLN4FseRE3aGipc8TJcBEDMtdp1GaAUz+JB2Q86Y09iS0
         iOkA==
X-Google-Smtp-Source: APXvYqzUlCi07nILNklNsNS4HJ/lH+Efr4GjVTNZTHkDEiuYwLiGivIelhkfNGv3x1TCnih2kaTB3NQT1G7052KvmkQ=
X-Received: by 2002:a17:90a:a116:: with SMTP id s22mr91662102pjp.47.1564053464334;
 Thu, 25 Jul 2019 04:17:44 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1563904656.git.andreyknvl@google.com> <7969018013a67ddbbf784ac7afeea5a57b1e2bcb.1563904656.git.andreyknvl@google.com>
 <20190724192504.GA5716@ziepe.ca>
In-Reply-To: <20190724192504.GA5716@ziepe.ca>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Thu, 25 Jul 2019 13:17:32 +0200
Message-ID: <CAAeHK+x5JFgkLLzhrkQBfa78pkyQXLhgOfXOGuHK=AfwFLHntg@mail.gmail.com>
Subject: Re: [PATCH v19 11/15] IB/mlx4: untag user pointers in mlx4_get_umem_mr
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, 
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
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 9:25 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
>
> On Tue, Jul 23, 2019 at 07:58:48PM +0200, Andrey Konovalov wrote:
> > This patch is a part of a series that extends kernel ABI to allow to pass
> > tagged user pointers (with the top byte set to something else other than
> > 0x00) as syscall arguments.
> >
> > mlx4_get_umem_mr() uses provided user pointers for vma lookups, which can
> > only by done with untagged pointers.
> >
> > Untag user pointers in this function.
> >
> > Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
> > Acked-by: Catalin Marinas <catalin.marinas@arm.com>
> > Reviewed-by: Kees Cook <keescook@chromium.org>
> > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > ---
> >  drivers/infiniband/hw/mlx4/mr.c | 7 ++++---
> >  1 file changed, 4 insertions(+), 3 deletions(-)
>
> Applied to rdma-for next, please don't sent it via other trees :)

Sure, thanks!

>
> Thanks,
> Jason

