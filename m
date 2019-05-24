Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2C3DC072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 04:23:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B6DA2133D
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 04:23:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="WnRK49CE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B6DA2133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1615F6B0005; Fri, 24 May 2019 00:23:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1132C6B0006; Fri, 24 May 2019 00:23:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0006B6B0007; Fri, 24 May 2019 00:23:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id D379E6B0005
	for <linux-mm@kvack.org>; Fri, 24 May 2019 00:23:24 -0400 (EDT)
Received: by mail-vs1-f72.google.com with SMTP id q25so1659321vsk.0
        for <linux-mm@kvack.org>; Thu, 23 May 2019 21:23:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=xAYnRWw3Tu8/93j9I1Decyj4SiwalEXjnp8HjDGWVMk=;
        b=CPBfRh/EHJUu6Rt3KG0iBNIKGIRi4dhzI9xDNFKjJZAixEbfAKxZAhlNjWogBV11vc
         joopW2nYb9rVxhaQDaKNk5YIlBpBduIggEi5x+IRpB7RVp8yph6mSAqelGW9B6KhSiZC
         8nA0ny0wyAhCQeI3T+Fb19N5z1yRW8dK2k3HC7nRXApszvxg5MqWj5F/gHS17VD2QGgA
         gxkr9BVxvQxmOGncNVviMbycE8Rm7+/sl0x+ZuL6Z1sDuTaFwgKBjr3l5R2EPPICBVw6
         +azLWSPMaKWV8edgnzlyEjJb8P43rEbYTURpjRJCzTsC7BuLZmOlDAgDi+Hx6rmHroZs
         bVkw==
X-Gm-Message-State: APjAAAXq9gcSltDmHgyo0IjU/Ebjwu2LgCXTeg5e89DqI4VBGedHLq5B
	hDN4LRF9AIPrj2i0eebiChoAHM9rNoUWWs5wC32gjqisTQDsQHH9JUyTayI4xKLYvDjDunMCaFX
	hfCF89L9WYemnI9GxeEogjqJQtM67+/N2yEXnFs544NvoT2x5bwqqJvaquM+DbzghuA==
X-Received: by 2002:a67:f7d2:: with SMTP id a18mr4236293vsp.5.1558671804489;
        Thu, 23 May 2019 21:23:24 -0700 (PDT)
X-Received: by 2002:a67:f7d2:: with SMTP id a18mr4236262vsp.5.1558671803519;
        Thu, 23 May 2019 21:23:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558671803; cv=none;
        d=google.com; s=arc-20160816;
        b=To2XpanCsCt4tQvcS9tEEnLTHAl64XUNbj2u7KRa1KvauJcHn4fe0N9l9fELajvN5R
         bdZ/JzmCGN2VNzIL6hOQWXKWBUhmr1qU1TIxOKNd7HqqVoOckZ/zbCWMYWgp6V6nGwMs
         jEI9DuIKs078FWSF3J7YDjftSgXfv1gIXR0wSrtogpMr8bjiynJ6lha5iFT8rYh1f+9q
         zXRk5vyoAwYRaZDf4G6DgDfUHutyR3mYpBRnJoXYdpjDIQUOsqv9dx6Dqe+af1v3L1BH
         da7BWtutv39HKlXQtu2PJftbSAR8iAoWEp023UeZ8u2UyJQlczhnUAMfKxv83Qs6jZeF
         gVmw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=xAYnRWw3Tu8/93j9I1Decyj4SiwalEXjnp8HjDGWVMk=;
        b=KMKAFm1COKDnBE6ApNLqgFvsHYfpY+7hDy97axkjkUtTDhODlZev6BeQszs4xOE1G8
         ibIL+r5iIzo6gFrBh7SJokqAM14DDXj7Q0l5jNvSKbpPYQoDhZCbY2Tp9rd0ENME9VDe
         VuBxghAic57GRcIzgGBMSMFTpJZqTN1h8j1up6Y2qEzxuPWXLrnGoBxIYx0r4PNtRwyw
         KIYBy2tChnNG2nv6n9GhQdsU3DsXVxqiLOgdnphDOMHvrdXuWYcVK4QDxn551Za2sPAC
         LIMQlzuUwjckJQQV62LwV+nZHeSQavw3X5srbjH/aJi2sG/9zWzj7qkdXXB6Bh0IwdBp
         bjSw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=WnRK49CE;
       spf=pass (google.com: domain of eugenis@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=eugenis@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y10sor739532uao.29.2019.05.23.21.23.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 May 2019 21:23:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of eugenis@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=WnRK49CE;
       spf=pass (google.com: domain of eugenis@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=eugenis@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=xAYnRWw3Tu8/93j9I1Decyj4SiwalEXjnp8HjDGWVMk=;
        b=WnRK49CElZNooeneU/rmiXD4MNL+NGJ+1q+LoLrd8r1BWPG0vFLLn5srrzAwJdtZCr
         YNvRiKrpydE8yY/WwhILnly3Zvune3jCfbXw7GsuMvu4P+dyMtapEbIZ2jkKw+bAAaZT
         /NstjIQP+l4nVYqupG3KK3t/H/Zt2rSh8UshTl0ZeyMDpnbmZlbVjVV+q+S0iwZ4uNET
         wEULW4QLu8xXLGSpfqZElCLKOXZT2Zp/eFOfWYxNKR73Qs1kFKXoJK7Lexkh9qJC8nqp
         yZ2rrh8i3toWpfjsayQpALHrdDwRoiqV6AXbdW6lkKZym6fAr2YHiokI7QWgzJYQeySd
         EWQQ==
X-Google-Smtp-Source: APXvYqx5Zm1ZYEN7Vn9AdcFTjSw8M3oFO3UV+ZriQQ1V2wP6o6e1yzY7Ig//CYIK3KGeMPCh4oSMGn+kEBJ+ngdeAaM=
X-Received: by 2002:ab0:3109:: with SMTP id e9mr449008ual.66.1558671802883;
 Thu, 23 May 2019 21:23:22 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1557160186.git.andreyknvl@google.com> <00eb4c63fefc054e2c8d626e8fedfca11d7c2600.1557160186.git.andreyknvl@google.com>
 <20190522114910.emlckebwzv2qz42i@mbp> <CAFKCwrjyP+x0JJy=qpBFsp4pub3He6UkvU0qnf1UOKt6W1LPRQ@mail.gmail.com>
 <20190523090427.GA44383@arrakis.emea.arm.com>
In-Reply-To: <20190523090427.GA44383@arrakis.emea.arm.com>
From: Evgenii Stepanov <eugenis@google.com>
Date: Thu, 23 May 2019 21:23:13 -0700
Message-ID: <CAFKCwrgk0+yR48Z5nhuZG5f7g==vRb4u+CS-4FS0mM7Eriavgw@mail.gmail.com>
Subject: Re: [PATCH v15 05/17] arms64: untag user pointers passed to memory syscalls
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrey Konovalov <andreyknvl@google.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>, 
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
	Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 2:04 AM Catalin Marinas <catalin.marinas@arm.com> wrote:
>
> On Wed, May 22, 2019 at 02:16:57PM -0700, Evgenii Stepanov wrote:
> > On Wed, May 22, 2019 at 4:49 AM Catalin Marinas <catalin.marinas@arm.com> wrote:
> > > On Mon, May 06, 2019 at 06:30:51PM +0200, Andrey Konovalov wrote:
> > > > This patch is a part of a series that extends arm64 kernel ABI to allow to
> > > > pass tagged user pointers (with the top byte set to something else other
> > > > than 0x00) as syscall arguments.
> > > >
> > > > This patch allows tagged pointers to be passed to the following memory
> > > > syscalls: brk, get_mempolicy, madvise, mbind, mincore, mlock, mlock2,
> > > > mmap, mmap_pgoff, mprotect, mremap, msync, munlock, munmap,
> > > > remap_file_pages, shmat and shmdt.
> > > >
> > > > This is done by untagging pointers passed to these syscalls in the
> > > > prologues of their handlers.
> > >
> > > I'll go through them one by one to see if we can tighten the expected
> > > ABI while having the MTE in mind.
> > >
> > > > diff --git a/arch/arm64/kernel/sys.c b/arch/arm64/kernel/sys.c
> > > > index b44065fb1616..933bb9f3d6ec 100644
> > > > --- a/arch/arm64/kernel/sys.c
> > > > +++ b/arch/arm64/kernel/sys.c
> > > > @@ -35,10 +35,33 @@ SYSCALL_DEFINE6(mmap, unsigned long, addr, unsigned long, len,
> > > >  {
> > > >       if (offset_in_page(off) != 0)
> > > >               return -EINVAL;
> > > > -
> > > > +     addr = untagged_addr(addr);
> > > >       return ksys_mmap_pgoff(addr, len, prot, flags, fd, off >> PAGE_SHIFT);
> > > >  }
> > >
> > > If user passes a tagged pointer to mmap() and the address is honoured
> > > (or MAP_FIXED is given), what is the expected return pointer? Does it
> > > need to be tagged with the value from the hint?
> >
> > For HWASan the most convenient would be to use the tag from the hint.
> > But since in the TBI (not MTE) mode the kernel has no idea what
> > meaning userspace assigns to pointer tags, perhaps it should not try
> > to guess, and should return raw (zero-tagged) address instead.
>
> Then, just to relax the ABI for hwasan, shall we simply disallow tagged
> pointers on mmap() arguments? We can leave them in for
> mremap(old_address), madvise().

I think this would be fine. We should allow tagged in pointers in
mprotect though.

> > > With MTE, we may want to use this as a request for the default colour of
> > > the mapped pages (still under discussion).
> >
> > I like this - and in that case it would make sense to return the
> > pointer that can be immediately dereferenced without crashing the
> > process, i.e. with the matching tag.
>
> This came up from the Android investigation work where large memory
> allocations (using mmap) could be more efficiently pre-tagged by the
> kernel on page fault. Not sure about the implementation details yet.
>
> --
> Catalin

