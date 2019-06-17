Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD6EAC31E5D
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 21:59:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 69BAA2082C
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 21:59:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="kvgoo1AW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 69BAA2082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C894C8E0002; Mon, 17 Jun 2019 17:59:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C39AA8E0001; Mon, 17 Jun 2019 17:59:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B27918E0002; Mon, 17 Jun 2019 17:59:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8A15C8E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 17:59:42 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id a2so5285909vkg.14
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 14:59:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=EAhatab0HAVyw+PnT7+3nUVy3uXQEI6O1vd8Cnx2LKk=;
        b=uG/3Z5sGNhPwKHIpIYcCChnaIapXjcFvzxkEjAe9A+b4AZO7PttvXnF/iLyY8H557w
         p6inSsUNlFPLLrRchaqNuOD9rSaZyyaVBGfUK97pp0HOOiwgks318ebeHIxJ0SPaCA16
         NizEn1k1yU34cey/cWli4qfyD+CvhBbMQIfLuy1KLbiNXW7JXRXcWemWrhHl6W0rlWxC
         KznEb6WqGM8VM2fzWA4PdgXLKg4QXp44px7jBwOXiFqZ5xAnVl6JWwBY1LU+Z2FOscbj
         tg79+S9v+66uLsxbtj/ZAPxi1pkCaifUuNY5HlL+QelQYZ+em4q+LAwWBUIaVFsoQ7AT
         eBpA==
X-Gm-Message-State: APjAAAWdUYuzNtaR2apD0DUjm+3ZPQRIL6Cespckd3Y44di7+mRh6/jZ
	sB7xIEovaNlI+YQsGZNCVAhXoheTl2w5RYgIhOKpOqdcbwsEF0Iao1Qfho8IvGfjmiSGNx6OgM/
	B3AKNKyzJ4/c/siByLel9CODacfYudPrKIV7f7AZMrU+2joneFPYbiPoef71m4kAX4w==
X-Received: by 2002:a67:fc50:: with SMTP id p16mr42361247vsq.79.1560808782286;
        Mon, 17 Jun 2019 14:59:42 -0700 (PDT)
X-Received: by 2002:a67:fc50:: with SMTP id p16mr42361235vsq.79.1560808781766;
        Mon, 17 Jun 2019 14:59:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560808781; cv=none;
        d=google.com; s=arc-20160816;
        b=xxf4ZuSGcJMY1JPXjw3bUnbrq4lyind7kE3+pu9OtEOE9WvZ8UYEI7cm31p4lK/F70
         CG957aKapXvxEQ2M3umLdmF5GZMxLc/bbiYU52kGzSaEYK5fCvHKwjSqw5fi/QrN/WCr
         MZpfe3qzVyfgjB3v0YLkrW86Kw5nmxH6HYXYechdtj/fZzAy7TK8gXPL1g9bs3wEsCMa
         w2T/qorpTWJ00/I3N43UbkYQxqfTSAt7LKYmuPnGKwT+kA5onGBN4WcZoJzrxCAAeMv7
         23WK5QMdVSei6hEJHHnKW/ReddZps/3Qzej7RAuW3EyJXsIPmd8Ctfjl5fpni8WfCGbV
         Cncg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=EAhatab0HAVyw+PnT7+3nUVy3uXQEI6O1vd8Cnx2LKk=;
        b=mWsLmQKKwA2iNeICqRlBpKnDaOD8O8M7Z2YaabsFq5YuqI5vCynMc6MzPW5iRnrTxr
         zlKO+UoOpIr0pxulllWYnKfca0PJNtGROE9vvXzoAVBQ56i9s+lffXznitLz9RjgPeVl
         qCFX3QvYLneXU05g0TwwIRZY92ZYatzBjF+gDOqZQqNBh6soFp9hgXGQUo1JpGbKoyS2
         MrAOLdrbnyZ4/qbYJLUJqDHBhsohurVHLRiYCVzDox6p8z6nXlCC/u3DTz+MT+xfLV3D
         7d0cF6bpY8M2U4CgLf1pSJD93AutzIxD7t6hfaNPi/oLVxvxwF/3lzEQj2ds3DxsngiF
         F9IQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=kvgoo1AW;
       spf=pass (google.com: domain of eugenis@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=eugenis@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d8sor5619968uam.6.2019.06.17.14.59.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Jun 2019 14:59:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of eugenis@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=kvgoo1AW;
       spf=pass (google.com: domain of eugenis@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=eugenis@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=EAhatab0HAVyw+PnT7+3nUVy3uXQEI6O1vd8Cnx2LKk=;
        b=kvgoo1AWJ53ectZxNh7vumo7uHVF3ezzA+dmS6OCiyHy7q38adiyo8Mt48b9s1ecuS
         8vbgSWAHi7F66ZbJb0OnnHkka0SZfIdhx44ptJvkStf7KSPyjOUktnOEWU+P5uVTHP64
         eN+AH0Y198g5GhXwzgWWBTwbfohtVJT/rFQhRmBXLkxVDGhPtni3s7vOLmfSoppPuiMS
         fw+6xL0t8nIg9W/VqAlmea2Xi/QAMj43r70NCnqPKdZOQ+k2pXu+G5fUMaRe8zFdt2fk
         JWWQc2NJ/zMPTaMg9M5+VHQpiaQGfqqosa4YWPSG3qztsQIxZrsszWUCVKNg2vbMMWht
         a6XA==
X-Google-Smtp-Source: APXvYqx2nWcd1UUVmxVOfqTdpy/EjWGEE63D+8CgDq6wsvkYXGUtTG/eldJ/84K4uXpb1xaJ0VQplOCTsiiUpsYmcEg=
X-Received: by 2002:ab0:234e:: with SMTP id h14mr10788176uao.25.1560808781025;
 Mon, 17 Jun 2019 14:59:41 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1560339705.git.andreyknvl@google.com> <a7a2933bea5fe57e504891b7eec7e9432e5e1c1a.1560339705.git.andreyknvl@google.com>
 <20190617135636.GC1367@arrakis.emea.arm.com> <CAFKCwrjJ+0ijNKa3ioOP7xa91QmZU0NhkO=tNC-Q_ThC69vTug@mail.gmail.com>
 <20190617171813.GC34565@arrakis.emea.arm.com>
In-Reply-To: <20190617171813.GC34565@arrakis.emea.arm.com>
From: Evgenii Stepanov <eugenis@google.com>
Date: Mon, 17 Jun 2019 14:59:29 -0700
Message-ID: <CAFKCwrhuQ+x-KprJV=CPCrnQR9Ky9qL=M5q_pa3fGj27oo4mng@mail.gmail.com>
Subject: Re: [PATCH v17 03/15] arm64: Introduce prctl() options to control the
 tagged user addresses ABI
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
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
	Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>, Jason Gunthorpe <jgg@ziepe.ca>, 
	Christoph Hellwig <hch@infradead.org>, Dmitry Vyukov <dvyukov@google.com>, 
	Kostya Serebryany <kcc@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 10:18 AM Catalin Marinas
<catalin.marinas@arm.com> wrote:
>
> On Mon, Jun 17, 2019 at 09:57:36AM -0700, Evgenii Stepanov wrote:
> > On Mon, Jun 17, 2019 at 6:56 AM Catalin Marinas <catalin.marinas@arm.com> wrote:
> > > On Wed, Jun 12, 2019 at 01:43:20PM +0200, Andrey Konovalov wrote:
> > > > From: Catalin Marinas <catalin.marinas@arm.com>
> > > >
> > > > It is not desirable to relax the ABI to allow tagged user addresses into
> > > > the kernel indiscriminately. This patch introduces a prctl() interface
> > > > for enabling or disabling the tagged ABI with a global sysctl control
> > > > for preventing applications from enabling the relaxed ABI (meant for
> > > > testing user-space prctl() return error checking without reconfiguring
> > > > the kernel). The ABI properties are inherited by threads of the same
> > > > application and fork()'ed children but cleared on execve().
> > > >
> > > > The PR_SET_TAGGED_ADDR_CTRL will be expanded in the future to handle
> > > > MTE-specific settings like imprecise vs precise exceptions.
> > > >
> > > > Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
> > >
> > > A question for the user-space folk: if an application opts in to this
> > > ABI, would you want the sigcontext.fault_address and/or siginfo.si_addr
> > > to contain the tag? We currently clear it early in the arm64 entry.S but
> > > we could find a way to pass it down if needed.
> >
> > For HWASan this would not be useful because we instrument memory
> > accesses with explicit checks anyway. For MTE, on the other hand, it
> > would be very convenient to know the fault address tag without
> > disassembling the code.
>
> I could as this differently: does anything break if, once the user
> opts in to TBI, fault_address and/or si_addr have non-zero top byte?

I think it would be fine.

> Alternatively, we could present the original FAR_EL1 register as a
> separate field as we do with ESR_EL1, independently of whether the user
> opted in to TBI or not.
>
> --
> Catalin

