Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 494E7C31E47
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:13:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0870E20896
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:13:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Wa+GrRii"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0870E20896
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 996FF6B0006; Wed, 12 Jun 2019 07:13:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 920556B0007; Wed, 12 Jun 2019 07:13:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7998C6B0008; Wed, 12 Jun 2019 07:13:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3E8666B0006
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 07:13:22 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id g9so11142868pgd.17
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 04:13:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=CPH48pl3zgEAvx1ZV8NCaa+NrirZ7d55m0K/3ZW0DB4=;
        b=exbODVop5oSm0yhAzS7BhUV8wUf+DxC+YTWjXmuG7TQ55IOMUpDzk7BmDJjqooVKtA
         ZwGOItQ7zYD4aCGut7nTarhhwza4teF///yD41LJZ5AmlrbWMCOoPPwLdrMt3vKD5lkX
         Z8LLjTdltMzXgBa8KBHohHPP2tJgeBVTdmO+sX91BHGLzTZ/ghqM6b8YstP6ox58sFWX
         BHeiZLaie465OiYAHlc/zVOhohP0b3ISNm2h7m0OFL5RG3cxh1G/cAIEbtsJmImzKalK
         2WcB9OtVBSAIGlxh1iWRlqVXKN6GCxZ3lp9+G1ZjSO/mNEPqd1gMj77I84XbPCXL0Eyc
         +YGw==
X-Gm-Message-State: APjAAAX3Xnv7EqqX3aF6oRjXZRDf7KmWgeKnMVujRAmVeAt55sgqP2id
	8bN1yUVseErjCsRitYKV1OvQ9OMaLydHMlmVrysGSJumGYwNgL5KYVnxOq8UFsQjpkHBK+miY5y
	DyxGzUTLMJq3JncMZJqOYPvLbuftas/BhPJYk85iwPGC722waaGi2mC07nqlA9vyeWA==
X-Received: by 2002:aa7:8013:: with SMTP id j19mr24169255pfi.212.1560338001846;
        Wed, 12 Jun 2019 04:13:21 -0700 (PDT)
X-Received: by 2002:aa7:8013:: with SMTP id j19mr24169109pfi.212.1560338000251;
        Wed, 12 Jun 2019 04:13:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560338000; cv=none;
        d=google.com; s=arc-20160816;
        b=CHOQangEimlBTtnIrDQXOPfE8lMK0FyEeUo+AG5S+M+BdA2M9F8bYfZlN2cbhW9Ul6
         wJQSgMvbU2aUwUbDEx1W5xHINM0Pz/DrjFw30yGNIQBi4YEegiREHKuXJxZaQBfl8jCq
         XPo10mjP2/c0SNjjbBL/jXGI1uEgwfJi0mcvb3Lu60aW7RZpAgg/mADq0vkXKoVJ7/yQ
         z2CzIJDogBExFJ6D50I2strz9NTf/2L2wCd5dy0UOSyEIf8xyROYgTy79UQZ3+gO/ATc
         n7heRbLwKrg335EqcxrepVH5I85ZuhnjH6xxNJ7spZ1ZhZdlWeNEe5L06O3lnOPlQ5rU
         kSOA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=CPH48pl3zgEAvx1ZV8NCaa+NrirZ7d55m0K/3ZW0DB4=;
        b=irGQotl/oCLuD5y14gL6eQhv9LMBxg2vtPinaIZt37qeKjTnVfYyL+CL1Uugsymov4
         qTNfTUrkTOkILWhIJxYc4+zSwS0r3sd7LkXv2wM/qQmtvePRroegtxIz5WaigNR55tV/
         u7xXxntl4Qt1HgoHgaWEUsBQGpx+TqNAHqMiVZQ+138sQhepw+JA7nxhZt94xCz+Ro3X
         wp4Uak5N4HifhNEYIJc2xoh8QF8b//X/LSsYgTt600YAC/GJgWq9fhBNDgdZXpis/Vuc
         BvH136s7NMqj8WAps3qXYkHIzWGH/dSyw/TmTe+sZMU0pn1idiRs03j2GuFBjQJoRw0i
         Fc1g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Wa+GrRii;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x27sor8911694pfo.43.2019.06.12.04.13.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Jun 2019 04:13:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Wa+GrRii;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=CPH48pl3zgEAvx1ZV8NCaa+NrirZ7d55m0K/3ZW0DB4=;
        b=Wa+GrRiixuq08ZJy7YLBy/hw4N6KCGD4D0JGPHXeAhrhP7aYFGu2wrFVi/4U57v07h
         gabUfJpQMd/ZxixypJh6LG438zDMAFuaLmx1zNosW/bNS5e9DE+bfIpQfyXphO/5R37q
         J4BK+9faydCecf+zFNicytUzZ+34IwX2nZrUTbQwSG0d5Mwjsh+M/iy5iKaSTm2HU1Vc
         APJmA3gO7zhEVXs30R27Red8E5MuIvjfWVaZNPU7/jpeOCWo81HFfgpvxUE+snFq9nK5
         AQ9h1nAmh3KAeta7IGYJp8hdQcsOoF6BnZ35/+mA9Y0+45iTzl1SsN8NtN8M46KVCGVs
         tN2Q==
X-Google-Smtp-Source: APXvYqwzlagi41UpMXh0yb3QZZS2gyEag7Dm2eoj6v2jESPsCD8f1MNuoUw/t7+/hDiqSvkq5q/rQO7JKsp+xiDho38=
X-Received: by 2002:a65:5845:: with SMTP id s5mr25017064pgr.286.1560337999517;
 Wed, 12 Jun 2019 04:13:19 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1559580831.git.andreyknvl@google.com> <045a94326401693e015bf80c444a4d946a5c68ed.1559580831.git.andreyknvl@google.com>
 <20190610142824.GB10165@c02tf0j2hf1t.cambridge.arm.com> <CAAeHK+zBDB6i+iEw+TJY14gZeccvWeOBEaU+otn1F+jzDLaRpA@mail.gmail.com>
 <20190611174448.exg2zycfqf4a2vea@mbp>
In-Reply-To: <20190611174448.exg2zycfqf4a2vea@mbp>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Wed, 12 Jun 2019 13:13:08 +0200
Message-ID: <CAAeHK+wkA8PskRrdfJ7MMr+je+x71WW3yDgWajxPRPwPBRNVfA@mail.gmail.com>
Subject: Re: [PATCH v16 05/16] arm64: untag user pointers passed to memory syscalls
To: Catalin Marinas <catalin.marinas@arm.com>
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
	Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>, Jason Gunthorpe <jgg@ziepe.ca>, 
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

On Tue, Jun 11, 2019 at 7:45 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
>
> On Tue, Jun 11, 2019 at 05:35:31PM +0200, Andrey Konovalov wrote:
> > On Mon, Jun 10, 2019 at 4:28 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
> > > On Mon, Jun 03, 2019 at 06:55:07PM +0200, Andrey Konovalov wrote:
> > > > This patch is a part of a series that extends arm64 kernel ABI to allow to
> > > > pass tagged user pointers (with the top byte set to something else other
> > > > than 0x00) as syscall arguments.
> > > >
> > > > This patch allows tagged pointers to be passed to the following memory
> > > > syscalls: get_mempolicy, madvise, mbind, mincore, mlock, mlock2, mprotect,
> > > > mremap, msync, munlock.
> > > >
> > > > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > >
> > > I would add in the commit log (and possibly in the code with a comment)
> > > that mremap() and mmap() do not currently accept tagged hint addresses.
> > > Architectures may interpret the hint tag as a background colour for the
> > > corresponding vma. With this:
> >
> > I'll change the commit log. Where do you you think I should put this
> > comment? Before mmap and mremap definitions in mm/?
>
> On arm64 we use our own sys_mmap(). I'd say just add a comment on the
> generic mremap() just before the untagged_addr() along the lines that
> new_address is not untagged for preserving similar behaviour to mmap().

Will do in v17, thanks!

>
> --
> Catalin

