Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1D89C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 23:03:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 50E4E206BA
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 23:03:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="R1whbY0D"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 50E4E206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 10B6C6B0003; Wed, 22 May 2019 19:03:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0BA7D6B0006; Wed, 22 May 2019 19:03:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E9DF66B0007; Wed, 22 May 2019 19:03:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f70.google.com (mail-ua1-f70.google.com [209.85.222.70])
	by kanga.kvack.org (Postfix) with ESMTP id C49B36B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 19:03:51 -0400 (EDT)
Received: by mail-ua1-f70.google.com with SMTP id j43so1059266uae.16
        for <linux-mm@kvack.org>; Wed, 22 May 2019 16:03:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=083fICcLHdIZzVNufU25syYhE84WJwTKtiHOZtf8SA0=;
        b=JlJqpIl9d3OeHEaOjeuzbk9lXg/9TUNGXKjnrWklXt6b2qjgEs+Vrn5fizm4U1cOzq
         /pSkQhPsqW6c7M9uJu8OZqkjsvH8JRWAuA8AAvMv5J52Bm+rnr0TN9EPp24DnqtwEMVR
         5bDzM5YYFIn9GCOZd2Ns3WURWRXJifBvDLB34l/CGHPrgFlpItGgjoShj1Flq3/uXMKI
         F2VXtm+WvShbLhwtZgmITlYmqPy9oWnHr9yLy3Nhw0Z5J9DXk4fUQeNwIYiAdUUoQC/f
         7Sq4tOprlS5FB6GmWtIiexr6ypo0/DcpSMEv1kTPZI6Bw7cBdbq/tdMiz/q5Fyi4nyeg
         pNLg==
X-Gm-Message-State: APjAAAXrv9BZwFApaqoqsb2G/KuEEDQ59OI8kRYhZNnkk42JVSqZvfW9
	+ZdgsnKNuIa2aVeUh8cXKS4REj6FfxtIFKMrEAI4vaWEsM+sydA1GpYddgyvE9htHm70txaBG2D
	ZSYSS99rl2QLqriCM7X6JT7wNOR+LSaX/TfQAgT7FjLvOw23b0uUEIKMKW3VONiivWQ==
X-Received: by 2002:a1f:a854:: with SMTP id r81mr118215vke.55.1558566231449;
        Wed, 22 May 2019 16:03:51 -0700 (PDT)
X-Received: by 2002:a1f:a854:: with SMTP id r81mr118171vke.55.1558566230555;
        Wed, 22 May 2019 16:03:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558566230; cv=none;
        d=google.com; s=arc-20160816;
        b=K6l/VIn8zrA0zvQQvDw/Ll95Axl73w1V2u6rT6Bjq1xbvGjbGErIcl6acekL/nQXF7
         WQYlnW+CM+n5z1+IjML2hKz3Xwi5yaPbiCh41ZGvrMT5QcPbCY+rIhgSr9nzoETzXlse
         cHUHry+3/sDUKWL9lf34FHILR/DFlssIMTqtv2TLyoJEqPfafes4mz63XwWDaeXEoysh
         o/dt+fAqPvMcXOyD4vL5NGeCKHv9EK6mo7+g+w92+Zudnh4PDa1XKlHHUzLXF9pJq+Yk
         2QPKqZeeyY6FwaoMqNhJ3kS0D19a5PHCLP0jE/aOev9St/m7ijBs1AGQUtU6SD5MTsKb
         eklQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=083fICcLHdIZzVNufU25syYhE84WJwTKtiHOZtf8SA0=;
        b=FPZMzUIegRjVLPxgXoPMm/SwZ/mnsIe5KWXLeWsMRpW/w5BznpwQ+TCZdQLp0CfMEO
         eN01nix+tjiMd4d0kRuO+Hz/6Ed8prlrymCu3/4bf9u5qCTrOV1RKzqDAPh0U1XwvZAH
         +DAHVVa1PcoHaRTrFtTxQQzN7wFIYhwK+cQkcxKUSV49vOkDo4q/f5n9fsnCl76vlMgy
         nmw79q7fLEnt/cpMdxEAzpxT7znjgigRO/seSXSgdzjoOKLRn0hhq8296+3M4yiqxJHf
         g1t+kBkk6josVnK62KNCUdFLdiGSuW1OweR4JPfi6n0tPi511bq3i5vSQ2m8oDIDvyAu
         3JaA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=R1whbY0D;
       spf=pass (google.com: domain of eugenis@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=eugenis@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y206sor3346479vky.70.2019.05.22.16.03.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 May 2019 16:03:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of eugenis@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=R1whbY0D;
       spf=pass (google.com: domain of eugenis@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=eugenis@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=083fICcLHdIZzVNufU25syYhE84WJwTKtiHOZtf8SA0=;
        b=R1whbY0DRJvYeo6WDezCnq6bV0i36te0/v1SFgHuDKDfWdFfZ1uqlfu6C2/257hQWf
         13OBZbWoVT2d4n1OkMyYTaJdzzdNJVODvxD7ax/78bOTFn0UZG6rkpjhsDxguOSNWQSW
         /pem354o3ayyWSPYKkkwbewRgzXJsoaUxgC/ouAEGxy6liid3L/+YVw/SLmKu4nN5deA
         sI1HZSYq1Jfkv/d/KsZmiH7dePki/Ktib/+2n6rc/FESU7nQ1RBKbd2tskxVzb2WzGm/
         +2fOWm+jMAJ/JCuclmW37/f6kDPw2o5cg4ErXP4x4jo4xyXhp8lPR9gvbLshZk81RzVf
         ErKA==
X-Google-Smtp-Source: APXvYqxPKtiNPawqkCkuPCNw0GStvO0zt/hmYPvT2nokhB6CEYZVKos9gwheEkiU5Yy2rN1PLFcfrDl2WDUSCoUDbnM=
X-Received: by 2002:a1f:4ec6:: with SMTP id c189mr128107vkb.17.1558566229772;
 Wed, 22 May 2019 16:03:49 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1557160186.git.andreyknvl@google.com> <20190517144931.GA56186@arrakis.emea.arm.com>
 <CAFKCwrj6JEtp4BzhqO178LFJepmepoMx=G+YdC8sqZ3bcBp3EQ@mail.gmail.com>
 <20190521182932.sm4vxweuwo5ermyd@mbp> <201905211633.6C0BF0C2@keescook>
 <20190522101110.m2stmpaj7seezveq@mbp> <CAJgzZoosKBwqXRyA6fb8QQSZXFqfHqe9qO9je5TogHhzuoGXJQ@mail.gmail.com>
 <20190522163527.rnnc6t4tll7tk5zw@mbp> <201905221316.865581CF@keescook>
In-Reply-To: <201905221316.865581CF@keescook>
From: Evgenii Stepanov <eugenis@google.com>
Date: Wed, 22 May 2019 16:03:36 -0700
Message-ID: <CAFKCwrjOjdJAbcABp3qxwyYy+hgfyQirvmqGkDSJVJe5pSz0Uw@mail.gmail.com>
Subject: Re: [PATCH v15 00/17] arm64: untag user pointers passed to the kernel
To: Kees Cook <keescook@chromium.org>
Cc: Catalin Marinas <catalin.marinas@arm.com>, enh <enh@google.com>, 
	Andrey Konovalov <andreyknvl@google.com>, Khalid Aziz <khalid.aziz@oracle.com>, 
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
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 22, 2019 at 1:47 PM Kees Cook <keescook@chromium.org> wrote:
>
> On Wed, May 22, 2019 at 05:35:27PM +0100, Catalin Marinas wrote:
> > The two hard requirements I have for supporting any new hardware feature
> > in Linux are (1) a single kernel image binary continues to run on old
> > hardware while making use of the new feature if available and (2) old
> > user space continues to run on new hardware while new user space can
> > take advantage of the new feature.
>
> Agreed! And I think the series meets these requirements, yes?
>
> > For MTE, we just can't enable it by default since there are applications
> > who use the top byte of a pointer and expect it to be ignored rather
> > than failing with a mismatched tag. Just think of a hwasan compiled
> > binary where TBI is expected to work and you try to run it with MTE
> > turned on.
>
> Ah! Okay, here's the use-case I wasn't thinking of: the concern is TBI
> conflicting with MTE. And anything that starts using TBI suddenly can't
> run in the future because it's being interpreted as MTE bits? (Is that
> the ABI concern? I feel like we got into the weeds about ioctl()s and
> one-off bugs...)
>
> So there needs to be some way to let the kernel know which of three
> things it should be doing:
> 1- leaving userspace addresses as-is (present)
> 2- wiping the top bits before using (this series)
> 3- wiping the top bits for most things, but retaining them for MTE as
>    needed (the future)
>
> I expect MTE to be the "default" in the future. Once a system's libc has
> grown support for it, everything will be trying to use MTE. TBI will be
> the special case (but TBI is effectively a prerequisite).
>
> AFAICT, the only difference I see between 2 and 3 will be the tag handling
> in usercopy (all other places will continue to ignore the top bits). Is
> that accurate?
>
> Is "1" a per-process state we want to keep? (I assume not, but rather it
> is available via no TBI/MTE CONFIG or a boot-time option, if at all?)
>
> To choose between "2" and "3", it seems we need a per-process flag to
> opt into TBI (and out of MTE). For userspace, how would a future binary
> choose TBI over MTE? If it's a library issue, we can't use an ELF bit,
> since the choice may be "late" after ELF load (this implies the need
> for a prctl().) If it's binary-only ("built with HWKASan") then an ELF
> bit seems sufficient. And without the marking, I'd expect the kernel to
> enforce MTE when there are high bits.
>
> > I would also expect the C library or dynamic loader to check for the
> > presence of a HWCAP_MTE bit before starting to tag memory allocations,
> > otherwise it would get SIGILL on the first MTE instruction it tries to
> > execute.
>
> I've got the same question as Elliot: aren't MTE instructions just NOP
> to older CPUs? I.e. if the CPU (or kernel) don't support it, it just
> gets entirely ignored: checking is only needed to satisfy curiosity
> or behavioral expectations.

MTE instructions are not NOP. Most of them have side effects (changing
register values, zeroing memory).
This only matters for stack tagging, though. Heap tagging is a runtime
decision in the allocator.

If an image needs to run on old hardware, it will have to do heap tagging only.

> To me, the conflict seems to be using TBI in the face of expecting MTE to
> be the default state of the future. (But the internal changes needed
> for TBI -- this series -- is a prereq for MTE.)
>
> --
> Kees Cook

