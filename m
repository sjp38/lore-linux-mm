Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61DCCC31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 14:42:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 26A6C214AF
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 14:42:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="jbRaxdb+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 26A6C214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B7DBA6B0003; Wed, 19 Jun 2019 10:42:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B550C8E0002; Wed, 19 Jun 2019 10:42:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A1D188E0001; Wed, 19 Jun 2019 10:42:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 687766B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 10:42:28 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id j36so12379053pgb.20
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 07:42:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ZUb5QTtqm4gVcMQkDqa/NfcfqCV/fqPlPHdvScpz0wo=;
        b=S846z2+nBBB1e8nJjpQF4+m5tzXaOdsLcVgix5nNZkVlNEdHkN4fq4xy1o/A1lBbQU
         2klkizp39HvP2mQ10QC7MYsrG1/rDO6khC1Q7lk/lX5ISwsKxy9Pu55DhGlO+52dOA3Z
         ag6KdJo9Epj7yz4MMIG8u+feWJeFM/8QRc+DuKh2q3bsUB06cx7TNJKRG0RFPZ8Jt53L
         LuOHKFmAU6ljTtnTMN1/8kD7iJBYvTGh3h/Umr7afmKQZJA0ONya6YRomVbsWvI/NVSX
         ITb3HUBEVXdRRfZKjPZhSm/zF8rwxD+ssDHIGy02cEbfRzoayxWLYVlwxpDys9LE1cLu
         vu/Q==
X-Gm-Message-State: APjAAAXcREjvsmZQcAZnsYpIp2Owe3uTNDk7uI6hmNRn1ZKcWWzRDNVJ
	7AXpyH6gUSf/Zmps3A1rR1y8owt37x0Zgzgd7Mq1/H7YDbVaaynaTdu45typ5mHZnH3QuLB2AE8
	XxTwjfLK15pYbXdpt6BoH6hIkFEg3X6cAOfqvoEGE/JXJLptRQUbxE2cdYBBZ/3zBLQ==
X-Received: by 2002:a17:902:54d:: with SMTP id 71mr8260262plf.140.1560955348009;
        Wed, 19 Jun 2019 07:42:28 -0700 (PDT)
X-Received: by 2002:a17:902:54d:: with SMTP id 71mr8260198plf.140.1560955347050;
        Wed, 19 Jun 2019 07:42:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560955347; cv=none;
        d=google.com; s=arc-20160816;
        b=Q4rsAr1KtkGOKUKXfL2TMcAhD77W/gyFSz0WwGPTXdPgrAS5aPT4nabx6hSaXsh5ck
         mujIHgd/DNA+nDqvBsNtTrRjXxGJhyRD7V1wFnrtO01/qkrgz5BB/Y6w1jthdMomexVH
         F3tYdharZuRq02O8zei+LeoQF6eBdsQQrURBKsuEwbr70ZMpsTsU5DgjyC558KkK6Z0R
         bLM7qHQH4Q0dxTWImL9lHN4L2GtOagUHZhKFO11jBX7qOjXJ7+Nl/WNV4P87gNl40pQE
         OF8twrwK0Lr3OLLb8l5fw6ekIlfgYiCe2OQdMijwXhrf6Xm9xzOTFBvTEk9hZ10kTOm3
         UdPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ZUb5QTtqm4gVcMQkDqa/NfcfqCV/fqPlPHdvScpz0wo=;
        b=DI5OyK7ZoFllhT7LuDGazw+JUJ3TKgHI7gfK5MmZA5BwoH0uMF9BYGAxI+xwJX+wUx
         wRs+3cAnWUc1eEISnaL2+hAkQyVxK2cbTXVBuLSnCrBDAA1lQHogOm/RlncjaXY7pAbN
         oNN9do1vIove/EayP/LtyCl+m4ELgMfjzGasDswvGLLpojR/UgIM9ZX3r8aZjf/xs05j
         y3nq9MpDpFG6uGq/1wnvCC+9xx8xCAyWqSS8ShxC7hTUT2+upE+eY3pyKD8IOggF3e1U
         f04g6TP7y1zt9+AeCWQkw+11+ZuVxFixW/kuFUilpAd1miV2GAO2/yUqVe3FAX5pPHhY
         Q32w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=jbRaxdb+;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bf4sor22001880plb.51.2019.06.19.07.42.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Jun 2019 07:42:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=jbRaxdb+;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ZUb5QTtqm4gVcMQkDqa/NfcfqCV/fqPlPHdvScpz0wo=;
        b=jbRaxdb+WWdzPQKppmuoBauA7dvRkdybKRNWtDi8BmVPL/duOwFKyfvGY1RtILXxC+
         E8fMNzdn99xzzaV1RU67k5BSaIeAySJVjGFam1tncgt0b1c3N/H+rn9Q1Ce9beAuIxY9
         4KU4S5Y6wyOdt8eRLq9iK/DasXwgpWgTB7OZoLagsJt17dKKFAk9z5/knt/SGGUXD1Pm
         OoCcVKVcumlyUAfwODg+GBNNkPYKXfWaLZhXGdXetH+hDPabh+cOTFmJx9VZ0MK9R5nx
         t58AUdQKa58pKb0SOzR1wBFV6nXGOJqmSpABaHdX/di+h0+s+ytlFiUVqPji7K9x3yTy
         3m5w==
X-Google-Smtp-Source: APXvYqz/8xJBvM5YApkc8q1BMr1dT5VicIPSZVfioxxqqY6SMtW097rTx7U+hky1E4IR1FcJP1uIwN60haaDiBmSyao=
X-Received: by 2002:a17:902:4183:: with SMTP id f3mr3975974pld.336.1560955346243;
 Wed, 19 Jun 2019 07:42:26 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1560339705.git.andreyknvl@google.com> <e024234e652f23be4d76d63227de114e7def5dff.1560339705.git.andreyknvl@google.com>
 <7cd942c0-d4c1-0cf4-623a-bce6ef14d992@arm.com> <20190612150040.GH28951@C02TF0J2HF1T.local>
In-Reply-To: <20190612150040.GH28951@C02TF0J2HF1T.local>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Wed, 19 Jun 2019 16:42:15 +0200
Message-ID: <CAAeHK+yWdW_sa2HgD8foCuwHj97dgGd07K2b1W1-9fpLXGmphQ@mail.gmail.com>
Subject: Re: [PATCH v17 15/15] selftests, arm64: add a selftest for passing
 tagged pointers to kernel
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Szabolcs Nagy <Szabolcs.Nagy@arm.com>, 
	"linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, 
	"linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, 
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>, 
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, 
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, 
	"linux-media@vger.kernel.org" <linux-media@vger.kernel.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, 
	"linux-kselftest@vger.kernel.org" <linux-kselftest@vger.kernel.org>, nd <nd@arm.com>, 
	Vincenzo Frascino <Vincenzo.Frascino@arm.com>, Will Deacon <Will.Deacon@arm.com>, 
	Mark Rutland <Mark.Rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kees Cook <keescook@chromium.org>, 
	Yishai Hadas <yishaih@mellanox.com>, Felix Kuehling <Felix.Kuehling@amd.com>, 
	Alexander Deucher <Alexander.Deucher@amd.com>, Christian Koenig <Christian.Koenig@amd.com>, 
	Mauro Carvalho Chehab <mchehab@kernel.org>, Jens Wiklander <jens.wiklander@linaro.org>, 
	Alex Williamson <alex.williamson@redhat.com>, Leon Romanovsky <leon@kernel.org>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave P Martin <Dave.Martin@arm.com>, 
	Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>, Jason Gunthorpe <jgg@ziepe.ca>, 
	Christoph Hellwig <hch@infradead.org>, Dmitry Vyukov <dvyukov@google.com>, 
	Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <Robin.Murphy@arm.com>, 
	Kevin Brodsky <Kevin.Brodsky@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 5:01 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
>
> On Wed, Jun 12, 2019 at 01:30:36PM +0100, Szabolcs Nagy wrote:
> > On 12/06/2019 12:43, Andrey Konovalov wrote:
> > > --- /dev/null
> > > +++ b/tools/testing/selftests/arm64/tags_lib.c
> > > @@ -0,0 +1,62 @@
> > > +// SPDX-License-Identifier: GPL-2.0
> > > +
> > > +#include <stdlib.h>
> > > +#include <sys/prctl.h>
> > > +
> > > +#define TAG_SHIFT  (56)
> > > +#define TAG_MASK   (0xffUL << TAG_SHIFT)
> > > +
> > > +#define PR_SET_TAGGED_ADDR_CTRL    55
> > > +#define PR_GET_TAGGED_ADDR_CTRL    56
> > > +#define PR_TAGGED_ADDR_ENABLE      (1UL << 0)
> > > +
> > > +void *__libc_malloc(size_t size);
> > > +void __libc_free(void *ptr);
> > > +void *__libc_realloc(void *ptr, size_t size);
> > > +void *__libc_calloc(size_t nmemb, size_t size);
> >
> > this does not work on at least musl.
> >
> > the most robust solution would be to implement
> > the malloc apis with mmap/munmap/mremap, if that's
> > too cumbersome then use dlsym RTLD_NEXT (although
> > that has the slight wart that in glibc it may call
> > calloc so wrapping calloc that way is tricky).
> >
> > in simple linux tests i'd just use static or
> > stack allocations or mmap.
> >
> > if a generic preloadable lib solution is needed
> > then do it properly with pthread_once to avoid
> > races etc.
>
> Thanks for the feedback Szabolcs. I guess we can go back to the initial
> simple test that Andrey had and drop the whole LD_PRELOAD hack (I'll
> just use it for my internal testing).

OK, will do in v18.

>
> BTW, when you get some time, please review Vincenzo's ABI documentation
> patches from a user/libc perspective. Once agreed, they should become
> part of this series.
>
> --
> Catalin

