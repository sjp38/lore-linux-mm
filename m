Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 656CDC76191
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 14:17:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1F45B22ADB
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 14:17:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="DWU4WjGA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1F45B22ADB
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C38A58E0007; Wed, 24 Jul 2019 10:17:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BE8ED8E0002; Wed, 24 Jul 2019 10:17:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB12E8E0007; Wed, 24 Jul 2019 10:17:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6F5328E0002
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 10:17:02 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id m19so13935547pgv.7
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 07:17:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=iVEa+BrbD+ybsnA2U1ljAFs3yPdamhmoGuSiTUjWPJ4=;
        b=mEuMVVyzIQTFTxSjZD+qjNs3YAA4FMRgaUHoaGJRqWYjd2VGSIyT2yigdhK0ydxI8W
         Mm3XPoyCXHAqKpajlfd+NVkxgyHaAZpr/Ntxwa0iV5R7wbKNyXBzkdUPE3xL9eM2lO/0
         S8HhngjRXzdtkEcn9KDTddHfE2mH7WfOvJqJaqvOkB8GGpOMdA8DfGggUNGrKbOZ5alU
         V3q/Y+HE4GngyRVVprqasrQDmO6w3yAQEsNn7d1cCzaYPWlQt22jJLb16zmB4TUIjKMc
         7LNx6Z9rb6fUDcuXWQQYhSJjhJBqsGbMHu8MBLlIHeMW1U6h3EIDSRqwKhe0zshj8hnh
         7aRg==
X-Gm-Message-State: APjAAAUdcPdBWHUn+hTOuD/Zc+QLuIir1S8nQ7JXd/zUeAhrsBe6biDd
	ji2xVcTt8lApTvmALnKOUCUlSeCpxYOKBDy0tJaSUwZHAXH2CEiNm3mAgmWAmQkreSS4T4ZBV4C
	UzXqbeSiGvZ/j0YN+SaYeYDFyynE06htQ0ySY4oB2NoKwZa/lAaEiBYN8ret5KjXxgg==
X-Received: by 2002:a63:ea50:: with SMTP id l16mr82981552pgk.160.1563977822005;
        Wed, 24 Jul 2019 07:17:02 -0700 (PDT)
X-Received: by 2002:a63:ea50:: with SMTP id l16mr82981499pgk.160.1563977821298;
        Wed, 24 Jul 2019 07:17:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563977821; cv=none;
        d=google.com; s=arc-20160816;
        b=sgsSz11o5KFQMKi0QnyCcnPRmDPq/Au4kSA4+UmBVVwNNJIjDAUp6MGvtKm4S9ibWP
         cxCTOtlHm4yGK40j15fIWlEefsge517kLUoYfpWBdeFMJ8+Fc0GNsNiDz2VHUAriWqBQ
         ZvE+it3W3wk60HNLsXHmYDoPJs5Tp2jtBRdI1iUzcPwTe3gyzcm0qn04XqQzkwsj1/+g
         3e4Ek+BHo9uA0yKZXjvH4LhxKOr8Bx5rfT1q9hYWKhzqPcQO6srpPoMoALaWF3EQfUm7
         3sRlLmUc/GQ7Rq/N+YazsAD4W8jwJpp6wC0TEJ1qA6KxUjq35PlJIEZplxZDZpDjanFx
         itvg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=iVEa+BrbD+ybsnA2U1ljAFs3yPdamhmoGuSiTUjWPJ4=;
        b=0ZTrZhrc6S+RskVXvP3S6wa96xANG902kqDhE5KpyeluIuCiimuPd1ZS6X+GlidVza
         irDGqcH6oRPHZGfmbe+Fe8LM4W7QiEakm7VTRDhDxVyw3fdQjdmi766xX+B/DDfVtfRs
         gwamiqouDGhZK/bc7lh5lM50PT7/hlsM1sHQyPHt3taNQlHUnmpl8soO67LYgJfkW9lL
         qSpD59Yj5oHPWwKu2C3e1wiNJh4GdrFuAqwa8707qgzJunWzcd+4HzYta3n96J1uwQpX
         4vuBbNDX2Pj7OsJv7UeC8NZfyDMTYQTfqP/yFyw7eaEaqpk2MtgziOuQxiN2AQqe+tQH
         Y4bA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=DWU4WjGA;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r202sor27718343pfr.51.2019.07.24.07.17.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 07:17:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=DWU4WjGA;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=iVEa+BrbD+ybsnA2U1ljAFs3yPdamhmoGuSiTUjWPJ4=;
        b=DWU4WjGAtgl8VCFFOjc8wXQ0g23uMAUtJpd38Z3oaJgwn4NfatixOvhmdpOdL+fxhG
         e0wlc3X1shT5Iq30jjbbWGUReEBT4OBXlYiiQUhWx2Q7uiFMfOEneT8NH6f9J2qp0V5H
         uul5tf2SvUAF38K7907CwJA6dKexcEorDJsv/KoSqA3HSUAO6tsOMxjz0hFsJBWrp9kB
         d53dWGlSvFswyl6j+n5LUh4qGYRvo3+KwFNfAV8S+2jUqD0GvKKHxnABV1FWZ1+b1OBh
         oB2T3ZDN/Zfw5qlFjUWW5qYsM2z/YZXngByjiqcmIeT7gWGze9CMbYqnOAvNwjkoL4TA
         mEew==
X-Google-Smtp-Source: APXvYqz2dMxGxnq2kAfIP49TpeG4FcaV+yTvRZ4CcUcR9QT0oeQ2GoQPtuki1B+xbKFnrASZfeBQUkyN7t1WRbfNCv8=
X-Received: by 2002:aa7:86c6:: with SMTP id h6mr11779914pfo.51.1563977820600;
 Wed, 24 Jul 2019 07:17:00 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1563904656.git.andreyknvl@google.com> <CAAeHK+yc0D_nd7nTRsY4=qcSx+eQR0VLut3uXMf4NEiE-VpeCw@mail.gmail.com>
 <20190724140212.qzvbcx5j2gi5lcoj@willie-the-truck>
In-Reply-To: <20190724140212.qzvbcx5j2gi5lcoj@willie-the-truck>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Wed, 24 Jul 2019 16:16:49 +0200
Message-ID: <CAAeHK+xXzdQHpVXL7f1T2Ef2P7GwFmDMSaBH4VG8fT3=c_OnjQ@mail.gmail.com>
Subject: Re: [PATCH v19 00/15] arm64: untag user pointers passed to the kernel
To: Will Deacon <will@kernel.org>, Vincenzo Frascino <vincenzo.frascino@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, kvm@vger.kernel.org, 
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>, Will Deacon <will.deacon@arm.com>, 
	dri-devel@lists.freedesktop.org, Kostya Serebryany <kcc@google.com>, 
	Khalid Aziz <khalid.aziz@oracle.com>, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, Felix Kuehling <Felix.Kuehling@amd.com>, 
	Jacob Bramley <Jacob.Bramley@arm.com>, Leon Romanovsky <leon@kernel.org>, linux-rdma@vger.kernel.org, 
	amd-gfx@lists.freedesktop.org, Christoph Hellwig <hch@infradead.org>, 
	Jason Gunthorpe <jgg@ziepe.ca>, Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Dave Martin <Dave.Martin@arm.com>, Evgeniy Stepanov <eugenis@google.com>, linux-media@vger.kernel.org, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Kees Cook <keescook@chromium.org>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Alex Williamson <alex.williamson@redhat.com>, 
	Mauro Carvalho Chehab <mchehab@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, 
	Linux Memory Management List <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Yishai Hadas <yishaih@mellanox.com>, LKML <linux-kernel@vger.kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Lee Smith <Lee.Smith@arm.com>, 
	Alexander Deucher <Alexander.Deucher@amd.com>, enh <enh@google.com>, 
	Robin Murphy <robin.murphy@arm.com>, Christian Koenig <Christian.Koenig@amd.com>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 4:02 PM Will Deacon <will@kernel.org> wrote:
>
> Hi Andrey,
>
> On Tue, Jul 23, 2019 at 08:03:29PM +0200, Andrey Konovalov wrote:
> > On Tue, Jul 23, 2019 at 7:59 PM Andrey Konovalov <andreyknvl@google.com> wrote:
> > >
> > > === Overview
> > >
> > > arm64 has a feature called Top Byte Ignore, which allows to embed pointer
> > > tags into the top byte of each pointer. Userspace programs (such as
> > > HWASan, a memory debugging tool [1]) might use this feature and pass
> > > tagged user pointers to the kernel through syscalls or other interfaces.
> > >
> > > Right now the kernel is already able to handle user faults with tagged
> > > pointers, due to these patches:
> > >
> > > 1. 81cddd65 ("arm64: traps: fix userspace cache maintenance emulation on a
> > >              tagged pointer")
> > > 2. 7dcd9dd8 ("arm64: hw_breakpoint: fix watchpoint matching for tagged
> > >               pointers")
> > > 3. 276e9327 ("arm64: entry: improve data abort handling of tagged
> > >               pointers")
> > >
> > > This patchset extends tagged pointer support to syscall arguments.
>
> [...]
>
> > Do you think this is ready to be merged?
> >
> > Should this go through the mm or the arm tree?
>
> I would certainly prefer to take at least the arm64 bits via the arm64 tree
> (i.e. patches 1, 2 and 15). We also need a Documentation patch describing
> the new ABI.

Sounds good! Should I post those patches together with the
Documentation patches from Vincenzo as a separate patchset?

Vincenzo, could you share the last version of the Documentation patches?

Thanks!

>
> Will

