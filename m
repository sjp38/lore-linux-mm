Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4DE40C4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 14:18:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D4F612084B
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 14:18:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="vY2U/oqZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D4F612084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 27CE66B0282; Tue,  2 Apr 2019 10:18:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 22B546B0286; Tue,  2 Apr 2019 10:18:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F4566B0287; Tue,  2 Apr 2019 10:18:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id CC2376B0282
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 10:18:06 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id q18so10011570pll.16
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 07:18:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=eOAI84sMzgs0Tu6es4MVTOPNdy29i+RjOyAHArShy5s=;
        b=Leo571+/GwheFbbFozVU55Ypjrey+d1FDK+vmRdDgGjH4pAxwlJ0xVvd2tVUWKOxRH
         wcK5QsmRYAFR8Sw1eWcA2GsaCMkerBVhdL2/a5wig55uZa3INha2KP3D118/dDXsRCkA
         lZ1esyGKkgjoWjzJSdKezK6UGM2TOnB01hfWlvgWksLqW51PO2eU8xP1wgIgCCGii9gn
         Ci3jOeQJVZy485nXqdZHtffPHhZ+YALRVDgSNPFVAmHQx0PFeWRmfLdmEMC5evrIVQqs
         ywGCJu2Ay11YEHgRVRyF0sZNfx1lWX9myTHm0eWAu2Wsk6ESM3nvy7sFHnAhIGBb5vmI
         WkJA==
X-Gm-Message-State: APjAAAV33oGOSEhamua7Sf55G2gB8cBCAO3JJcr5V2+uSfLBoV6ycDOE
	yttMLlUgFUwP+CbLdSqWuQ1wWWuxCVFU51SrIXnIDW5MQ5/5wy34RoqWNC/cObBYW24JqP7Qul+
	ayS0YkUSpgw2Ju1VbY99htsXR+ymWg5AV2w+LY2BOWmSivb3/yUCC0gETMAUStMZ0NA==
X-Received: by 2002:a63:c23:: with SMTP id b35mr26602821pgl.298.1554214686305;
        Tue, 02 Apr 2019 07:18:06 -0700 (PDT)
X-Received: by 2002:a63:c23:: with SMTP id b35mr26602763pgl.298.1554214685498;
        Tue, 02 Apr 2019 07:18:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554214685; cv=none;
        d=google.com; s=arc-20160816;
        b=jTvT6Y8evN4iQgQ7U98gX6WSiJvGYvf0lH9H5PuIFzZHNYb9TUoGGeekGhnrFszelt
         cdsTGQ+xEvEVodw0yL/2/cwq4Slju/coNhEHdbGDHFBlqcFyoz6P6zDPenyvfnzWrM7a
         tgoaZlj0J5lLv4Fxg4xWo+U7PTILZTXiKW8vAyZ9OKwbhbAtTvMctV4lOgjFGoFDToz4
         LzSaP9po6j4eSZJ1PNxyAci0ZYd1YOb6XtPW/dxjR8QKUbre8106niTOlYLAzZ3tnwhZ
         QFa0ick1Ip/cE8KRyp7zq2DwyUon5oT+POrRMmGNd55fCFFByFqnSXtD7j/B1Go4Dgcn
         9vZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=eOAI84sMzgs0Tu6es4MVTOPNdy29i+RjOyAHArShy5s=;
        b=kSdNp1vxyKpVIQxZafaWKjyi8jUV0W5DFsLXZNZmQASkiyGMXFt62Lu/0X+qjzXync
         ylpy7hS7fPIMHTrG9spkI53E0ZaG9MkOXUeK8EZN0Fec5/W4iiuuxzlZdl4hssTqfuqe
         3zH8CWCNmxb8mjvnAEMHthSF7iKnQIIGmvP2FHBfA9LHhLlN06m4qrv3kkIip2cMuIt1
         YF9avO73h7fDlC+woqVQT0bMw4oSqFhQJFz2aWz1iF6OiZ0o4WzBnMJskmWFEWRXjrpx
         OSpi79X1PPeV+2HDXSeZlboZurAglXypfqYT18O7D5FoU8F9sZajftKKMi1Mw3ycaysS
         zBHA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="vY2U/oqZ";
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s20sor1544277pgs.48.2019.04.02.07.18.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Apr 2019 07:18:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="vY2U/oqZ";
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=eOAI84sMzgs0Tu6es4MVTOPNdy29i+RjOyAHArShy5s=;
        b=vY2U/oqZJX6IKSTwDmd1X4FsSz4M6fhf/GeodVuw85FoLOWGSdqTBtlHv4yhHKxp9i
         S9+DXSMRZQkefqcVMz+Vgg3fbGq0RLwfdeU1GbU0/GmsPq3EVHgF+WfWDW7HS3Fy6qeZ
         34I1V8nDAujjSIAByvvZzZHBZXMUB1cixvl0yA1NajSjy3m18FVygrximmGPY/nt0sr4
         Mz2AMAVm3gYVBBpGdy2LYRuRbxr37R3gnQtCZTgDVZkeTGnm8XDe/mJ/A594aW/6j/1/
         MPZHce5yjiyP46NVTyiUtZLJONEdQDm79jp2vISRIq+yCnFnSdJ4mrU2QmGF7gQ/NWTx
         2XaA==
X-Google-Smtp-Source: APXvYqyX8M3QTakV9OF/0YEeR+dTk+qxhiJWNny/gVu4lXMnNodZJO66lQFzzfQvDJ5sld65cPfpShB6Sof4Wtggq8U=
X-Received: by 2002:a63:1f52:: with SMTP id q18mr67911652pgm.134.1554214683866;
 Tue, 02 Apr 2019 07:18:03 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1553093420.git.andreyknvl@google.com> <038360a0a9dc0abaaaf3ad84a2d07fd544abce1a.1553093421.git.andreyknvl@google.com>
 <20190322160057.GU13384@arrakis.emea.arm.com>
In-Reply-To: <20190322160057.GU13384@arrakis.emea.arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 2 Apr 2019 16:17:52 +0200
Message-ID: <CAAeHK+xAaxiyg7pea3-WX_9d-KvUHa8Pwmv8BRm7WVmqutmS5w@mail.gmail.com>
Subject: Re: [PATCH v13 15/20] drm/radeon, arm64: untag user pointers in radeon_ttm_tt_pin_userptr
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, 
	Robin Murphy <robin.murphy@arm.com>, Kees Cook <keescook@chromium.org>, 
	Kate Stewart <kstewart@linuxfoundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, 
	Shuah Khan <shuah@kernel.org>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>, 
	Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, 
	Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, 
	Alex Deucher <alexander.deucher@amd.com>, =?UTF-8?Q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>, 
	"David (ChunMing) Zhou" <David1.Zhou@amd.com>, Yishai Hadas <yishaih@mellanox.com>, 
	Mauro Carvalho Chehab <mchehab@kernel.org>, Jens Wiklander <jens.wiklander@linaro.org>, 
	Alex Williamson <alex.williamson@redhat.com>, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, 
	netdev <netdev@vger.kernel.org>, bpf <bpf@vger.kernel.org>, 
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Chintan Pandya <cpandya@codeaurora.org>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 22, 2019 at 5:01 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
>
> On Wed, Mar 20, 2019 at 03:51:29PM +0100, Andrey Konovalov wrote:
> > This patch is a part of a series that extends arm64 kernel ABI to allow to
> > pass tagged user pointers (with the top byte set to something else other
> > than 0x00) as syscall arguments.
> >
> > radeon_ttm_tt_pin_userptr() uses provided user pointers for vma
> > lookups, which can only by done with untagged pointers.
> >
> > Untag user pointers in this function.
> >
> > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > ---
> >  drivers/gpu/drm/radeon/radeon_ttm.c | 5 +++--
> >  1 file changed, 3 insertions(+), 2 deletions(-)
> >
> > diff --git a/drivers/gpu/drm/radeon/radeon_ttm.c b/drivers/gpu/drm/radeon/radeon_ttm.c
> > index 9920a6fc11bf..872a98796117 100644
> > --- a/drivers/gpu/drm/radeon/radeon_ttm.c
> > +++ b/drivers/gpu/drm/radeon/radeon_ttm.c
> > @@ -497,9 +497,10 @@ static int radeon_ttm_tt_pin_userptr(struct ttm_tt *ttm)
> >       if (gtt->userflags & RADEON_GEM_USERPTR_ANONONLY) {
> >               /* check that we only pin down anonymous memory
> >                  to prevent problems with writeback */
> > -             unsigned long end = gtt->userptr + ttm->num_pages * PAGE_SIZE;
> > +             unsigned long userptr = untagged_addr(gtt->userptr);
> > +             unsigned long end = userptr + ttm->num_pages * PAGE_SIZE;
> >               struct vm_area_struct *vma;
> > -             vma = find_vma(gtt->usermm, gtt->userptr);
> > +             vma = find_vma(gtt->usermm, userptr);
> >               if (!vma || vma->vm_file || vma->vm_end < end)
> >                       return -EPERM;
> >       }
>
> Same comment as on the previous patch.

As Kevin wrote in the amd driver related thread, the call trace is:
radeon_gem_userptr_ioctl()->radeon_ttm_tt_set_userptr()->...->radeon_ttm_tt_pin_userptr()->find_vma()

>
> --
> Catalin

