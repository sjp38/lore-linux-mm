Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_MED,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 13DC7C28CC2
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 14:29:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D0A3D26AA1
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 14:29:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="sQG2/gyF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D0A3D26AA1
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6134D6B026F; Fri, 31 May 2019 10:29:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C4076B0278; Fri, 31 May 2019 10:29:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B3596B027A; Fri, 31 May 2019 10:29:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 133E36B026F
	for <linux-mm@kvack.org>; Fri, 31 May 2019 10:29:24 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id o12so6405172pll.17
        for <linux-mm@kvack.org>; Fri, 31 May 2019 07:29:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=evy368hWiI+gBYUbtpZ/Z/NwaFGt0gP/Ku0Se7jRDIs=;
        b=tknx3dyO0nCfxAGW787e4nLxSB5ywBo4tZJjcrLdw911qbfkF6H49IQ+Z/SM+UwDIj
         f2Hao3x1W+NZHqXc+9qopzDyOtn3/L4ZGBw4jkgpRdi8yWqT0aA9mwe/kHtnVSRmHpyQ
         HDMPYt1xaQw4VPX+KP27+6IPNsjmbv3rXiHu2QlxxmLAkDc+DxYKA8ASE9UEllf+0qRk
         tWRH8Mf7HEeh7SPCrtf8zbgJkAWOL/PzqR3/0VPu/SDyzLKnXusru4oVHwldn2sDQWL3
         CaCMwLwpRF7UAjstxE5008nxDcX50xDnFtHCclri4Yds7h40hKRoCkB091afB97MrSGJ
         5nxQ==
X-Gm-Message-State: APjAAAVF4PFzRXVoORHIUQLioeyOMWD6bRHp9lczTd+rUpHWLF4tAabV
	0fPC9gkoQR65phIfpQ9Tg2y42x1POL7sMpeb2dMn+Bmhik2MFhwHbEFXdh5gHnizjtOLdsBbQ6W
	p2F3cBoxZF0v/3hX7gtGueWO5ZcfvZOlRf96m+eUBP9cDKOk11nFSo8E8TFK0taKiiQ==
X-Received: by 2002:a63:6f8d:: with SMTP id k135mr5450841pgc.118.1559312963535;
        Fri, 31 May 2019 07:29:23 -0700 (PDT)
X-Received: by 2002:a63:6f8d:: with SMTP id k135mr5450750pgc.118.1559312962501;
        Fri, 31 May 2019 07:29:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559312962; cv=none;
        d=google.com; s=arc-20160816;
        b=MnGiIOkeNWdkDNBBG3iMt2htkMggVDnA4hpaOkWeHIgNiyIpmKukGgFAp48ayw7MIO
         7cecjuF6pi42wDpbudj9mZw5cYW5Yzs1RRBcciD6HVJ30UX9Jy4mmI3KLLuXYvpriaGt
         Tl4kZ97bOz3eCEMo93ZJe5DlvdWBy2qX55GleLU1LAnGrC6lD19Qn/i0bqZZTyb1Pd9I
         ADvFY2TGYU6BbR7GPqC1UjaXEfPZLdXxQ21mg0Z5x4PA5GXHhdcWK8Qfgxij338y0n2a
         31+tMVZYooC9QbsyDf1AGZrZIy3OpriTytwEllG+0wBcPeElCfO+TngPjqpsmQAnL9Re
         Y0MQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=evy368hWiI+gBYUbtpZ/Z/NwaFGt0gP/Ku0Se7jRDIs=;
        b=Xx7U/mrYmOEvODiccf1D17RpTAFlDoBndbFIZWy8Df7uZ+jzVO3dbm/t4vW2EUeRQb
         D3XNnne042yFgSdOrZ7Pp9H6vhBlyphjGAPCajXYIjHkZclKZjzMUB4xPqB/3nwSAuy3
         HNhSppoDzqPaMi2pU15vv+xrBedPWoawM1qTYZeGmFHKp6W+OhVwQERegqJMsts99E/x
         eKk3HT73eCVN0c8EUZHlpNJ4M9WNehHrCjqLALDKz6ygch5dPMZR+Sgnw4l4eeMbe7Q1
         sltfvWCVP/QHyLwz3laCboXLiHBc1cx25Z7aHnmTvfxa1aP0/FTeTQb3kJd6P7+IiGdO
         d9GQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="sQG2/gyF";
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l96sor6818225plb.68.2019.05.31.07.29.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 31 May 2019 07:29:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="sQG2/gyF";
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=evy368hWiI+gBYUbtpZ/Z/NwaFGt0gP/Ku0Se7jRDIs=;
        b=sQG2/gyFbhvQgnnYVMoq8Kda68VVztjS6NpVGpn+TJ/0x1CnUPLFGI7CfwhDx4Acpv
         +b2SfJPlJiXKHOPX0vraeScgQBz7b7Nl6PyJKu6e145lCoysI0y6J5myuuCSNlucfPw4
         OziFqAsvBRMmxzPBSxXT6y9ZOWT1qftFo2UhubNHkIM+xAKIuSxRN1IDkqLlB5D+IEDh
         9Lbkk942zOUUnqGLz1d6wvbTAZV2QEf8AYds1RPyvHK7XFYBgL+gUTiPMyMH1+mL85z0
         rHLvvgL9h/d8SCsWwDzjC1mOEMEITHFigTDJGZoVkvgiZ6th+Bg/aZrVlKENNn6Dl+G9
         3qvw==
X-Google-Smtp-Source: APXvYqzZNq7ZmlghEU+anyWYnwjjhfBSO821IIVYI0unmJhzupp13rZUJ7jf2s8ZHPUTRKkSRgHsOXgkfcRcIwbO8eo=
X-Received: by 2002:a17:902:8609:: with SMTP id f9mr9244481plo.252.1559312961740;
 Fri, 31 May 2019 07:29:21 -0700 (PDT)
MIME-Version: 1.0
References: <20190517144931.GA56186@arrakis.emea.arm.com> <CAFKCwrj6JEtp4BzhqO178LFJepmepoMx=G+YdC8sqZ3bcBp3EQ@mail.gmail.com>
 <20190521182932.sm4vxweuwo5ermyd@mbp> <201905211633.6C0BF0C2@keescook>
 <6049844a-65f5-f513-5b58-7141588fef2b@oracle.com> <20190523201105.oifkksus4rzcwqt4@mbp>
 <ffe58af3-7c70-d559-69f6-1f6ebcb0fec6@oracle.com> <20190524101139.36yre4af22bkvatx@mbp>
 <c6dd53d8-142b-3d8d-6a40-d21c5ee9d272@oracle.com> <CAAeHK+yAUsZWhp6xPAbWewX5Nbw+-G3svUyPmhXu5MVeEDKYvA@mail.gmail.com>
 <20190530171540.GD35418@arrakis.emea.arm.com>
In-Reply-To: <20190530171540.GD35418@arrakis.emea.arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Fri, 31 May 2019 16:29:10 +0200
Message-ID: <CAAeHK+y34+SNz3Vf+_378bOxrPaj_3GaLCeC2Y2rHAczuaSz1A@mail.gmail.com>
Subject: Re: [PATCH v15 00/17] arm64: untag user pointers passed to the kernel
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Kees Cook <keescook@chromium.org>, Evgenii Stepanov <eugenis@google.com>, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, 
	Vincenzo Frascino <vincenzo.frascino@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Yishai Hadas <yishaih@mellanox.com>, 
	Felix Kuehling <Felix.Kuehling@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, 
	Christian Koenig <Christian.Koenig@amd.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	Leon Romanovsky <leon@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, 
	Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, 
	Robin Murphy <robin.murphy@arm.com>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, 
	Dave Martin <Dave.Martin@arm.com>, Kevin Brodsky <kevin.brodsky@arm.com>, 
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>, Elliott Hughes <enh@google.com>, 
	Khalid Aziz <khalid.aziz@oracle.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 30, 2019 at 7:15 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
>
> On Tue, May 28, 2019 at 04:14:45PM +0200, Andrey Konovalov wrote:
> > Thanks for a lot of valuable input! I've read through all the replies
> > and got somewhat lost. What are the changes I need to do to this
> > series?
> >
> > 1. Should I move untagging for memory syscalls back to the generic
> > code so other arches would make use of it as well, or should I keep
> > the arm64 specific memory syscalls wrappers and address the comments
> > on that patch?
>
> Keep them generic again but make sure we get agreement with Khalid on
> the actual ABI implications for sparc.

OK, will do. I find it hard to understand what the ABI implications
are. I'll post the next version without untagging in brk, mmap,
munmap, mremap (for new_address), mmap_pgoff, remap_file_pages, shmat
and shmdt.

>
> > 2. Should I make untagging opt-in and controlled by a command line argument?
>
> Opt-in, yes, but per task rather than kernel command line option.
> prctl() is a possibility of opting in.

OK. Should I store a flag somewhere in task_struct? Should it be
inheritable on clone?

>
> > 3. Should I "add Documentation/core-api/user-addresses.rst to describe
> > proper care and handling of user space pointers with untagged_addr(),
> > with examples based on all the cases seen so far in this series"?
> > Which examples specifically should it cover?
>
> I think we can leave 3 for now as not too urgent. What I'd like is for
> Vincenzo's TBI user ABI document to go into a more common place since we
> can expand it to cover both sparc and arm64. We'd need an arm64-specific
> doc as well for things like prctl() and later MTE that sparc may support
> differently.

OK.

>
> --
> Catalin

