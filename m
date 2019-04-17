Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5AD4C282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 13:00:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 519832173C
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 13:00:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="BjZsvhO3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 519832173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E0E0D6B0005; Wed, 17 Apr 2019 09:00:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DBB7D6B0006; Wed, 17 Apr 2019 09:00:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C5CF06B0007; Wed, 17 Apr 2019 09:00:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5C93B6B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 09:00:57 -0400 (EDT)
Received: by mail-lf1-f72.google.com with SMTP id x13so1200254lff.23
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 06:00:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=nD5N/gZK0Hc9/leGn/iw1G+jz11LpAQc97DIEWLBEH0=;
        b=b3leRsvNPY+0TDQzP+djcqbDLna/ccDCE97ufHwlegH5aiCfMhDxIaRPNko7QHmrx+
         VRk+C4wHhG1B5+Knrrkn1PF7pNM86oehQVl21jzkYB+DeCrp1NfoCf/tcx9o0jYwfLBx
         mDJljT3LPrJBzcEQn5q811OI//QWoTkUVNf3b+n2dmxFRM7DjOic7uJodMzRBF2GfvU3
         elK2nWSA3euz32nXZoY/q3cqfpPfPeFDOp8BtaEiJ5/WDM/u2IDQU/P8VZjgLstThc8G
         ge8PzJlTDaFL60lR/kszoY1+4KNCe00HxWRHVFfG3CiMf9l7dKLUoU5sstZ72Rw3gycG
         4nIA==
X-Gm-Message-State: APjAAAWP82/TNmCscBRy3kEPYMUrA2uPxrm5jmiQ+cAmYaKRvrgC2LO8
	4SFXclJv3swDcrYIfXU8ca9fTfRL8P5NyKcXDOj99Jl+6Qvpy014bgN8sfs7LFHq5YxYLSVaEUi
	Pjo/8db/rALjuPGe60+xf/WIX7TPCL81VLNT9lJWaaN81t7qOpsenltupJM2ypPtewg==
X-Received: by 2002:a2e:97d3:: with SMTP id m19mr8469830ljj.63.1555506056405;
        Wed, 17 Apr 2019 06:00:56 -0700 (PDT)
X-Received: by 2002:a2e:97d3:: with SMTP id m19mr8469780ljj.63.1555506055358;
        Wed, 17 Apr 2019 06:00:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555506055; cv=none;
        d=google.com; s=arc-20160816;
        b=xFFt6BuD/k2ay0qtk2vsSMb9/bQP/ty2Z2tXqXcbyeDJaN+tk9xiU2h0qHKzRKLe+2
         DMptP+YYI5X+3jn8UF44sKu3Zz8DFjB7WObXZzj0Ai+uIWzh2cgOv/DKSUPamtOCIZ/A
         z7bac3N67BV9ZpFpwh+Om7ogdJkxKqcotFwbBxgx+xWJNJJa6TKhwaUZhm/XxPtTPM3k
         ZSynavAj8AZ7Vq6tnLkiVXIy/k268RtPMUiNV4K7DBub7yBZf6K9xpunJdedI+RFEWXx
         1d2pTOfEPHsiQP1S2UCVH6rA/J15EzsBMIds1sbkjXTX+NhVb7pyB+cVn7zTJ2D+9r6T
         ksKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=nD5N/gZK0Hc9/leGn/iw1G+jz11LpAQc97DIEWLBEH0=;
        b=VIFVUYC3i9neXlgpE/pUs7HWYxG5/zxrL6uMeiqPBs3BSE7aNFOD4zi8ZwG3St1mtN
         jthz5xt0YpNpScn8zC7zROkOboSWNv8V06KYi7CdvG1x2gWGZzwz3ao4XXhD+sIH8/qz
         JNBP7HvEPc6p9vFhmaVSgaybsm3ORBssrpYh72llkCG1HUdbfzXzptWou9ecDZjYB8SL
         ZHMDGvftforCY1+KPw/X3YaXgd06WXit9K7Ms6nppWK5tTqcsXu/tC7gLjHhwlg2J64B
         eiNIxZnjya0rzOW42yBBC4844w/FJEuvBrm5oEn+nOtauaQg7u8RvgQdQKgxu1VybSSE
         PVBw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=BjZsvhO3;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 16sor2607663lfr.9.2019.04.17.06.00.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 06:00:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=BjZsvhO3;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=nD5N/gZK0Hc9/leGn/iw1G+jz11LpAQc97DIEWLBEH0=;
        b=BjZsvhO3f2TtZdypKM0jxF9FMvsBQgKsjOjoxn88+v7JSDK6dBNSiffPm+ktPRILcE
         HmWGSWZxWZHKnDwj5FtEyQyi0yj7N3sx12LtX22qusLXABFr0uNQaTgY4ME5c+GsOW5/
         cdEURgaDBigSxdcG2kpRozIdV+yh2dtTvlQyqrQdcX1l+FHwwNxp3WKEhssRK+Dtj5ML
         bol8BNRZ/nTq/h9U2713ozFZCt/zN6G1HMOANjAJqqVeRne08HkFoDLPlb2H/asmksvu
         e57LwlEC/XyHZJILatdvhwGcZTcgiOGrP3JA0IsDCg6RlFrY0cwU1y9ZqEANl9d65w8L
         IoVA==
X-Google-Smtp-Source: APXvYqzYJsHEPZUdZi7dgUmK7iczzP/OpZWI0kCGkirNZhXZR65KeukbkI/1y7q+0vV1rRiXwgEe0vywbPgmOrs7Vcs=
X-Received: by 2002:a19:3f09:: with SMTP id m9mr14983716lfa.36.1555506054907;
 Wed, 17 Apr 2019 06:00:54 -0700 (PDT)
MIME-Version: 1.0
References: <20190412160338.64994-1-thellstrom@vmware.com> <20190412160338.64994-2-thellstrom@vmware.com>
 <CAFqt6zb4qBdrWev1KEruDzPJt5wP4ax_7hUyz+JMV9zLxd_iiw@mail.gmail.com> <e9211a5c28de521bbaabf1c2576c640f3195b0c2.camel@vmware.com>
In-Reply-To: <e9211a5c28de521bbaabf1c2576c640f3195b0c2.camel@vmware.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Wed, 17 Apr 2019 18:30:43 +0530
Message-ID: <CAFqt6zYw=Fj8R-18TJ-Xwdjs+AD7nW1pVO57vT8wuUK0Tv+FCQ@mail.gmail.com>
Subject: Re: [PATCH 1/9] mm: Allow the [page|pfn]_mkwrite callbacks to drop
 the mmap_sem
To: Thomas Hellstrom <thellstrom@vmware.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, 
	"peterz@infradead.org" <peterz@infradead.org>, "willy@infradead.org" <willy@infradead.org>, 
	"linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>, "minchan@kernel.org" <minchan@kernel.org>, 
	"jglisse@redhat.com" <jglisse@redhat.com>, 
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, 
	"will.deacon@arm.com" <will.deacon@arm.com>, 
	Linux-graphics-maintainer <Linux-graphics-maintainer@vmware.com>, "mhocko@suse.com" <mhocko@suse.com>, 
	"ying.huang@intel.com" <ying.huang@intel.com>, "riel@surriel.com" <riel@surriel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 4:28 PM Thomas Hellstrom <thellstrom@vmware.com> wr=
ote:
>
> Hi, Souptick,
>
> On Sat, 2019-04-13 at 20:41 +0530, Souptick Joarder wrote:
> > On Fri, Apr 12, 2019 at 9:34 PM Thomas Hellstrom <
> > thellstrom@vmware.com> wrote:
> > > Driver fault callbacks are allowed to drop the mmap_sem when
> > > expecting
> > > long hardware waits to avoid blocking other mm users. Allow the
> > > mkwrite
> > > callbacks to do the same by returning early on VM_FAULT_RETRY.
> > >
> > > In particular we want to be able to drop the mmap_sem when waiting
> > > for
> > > a reservation object lock on a GPU buffer object. These locks may
> > > be
> > > held while waiting for the GPU.
> > >
> > > Cc: Andrew Morton <akpm@linux-foundation.org>
> > > Cc: Matthew Wilcox <willy@infradead.org>
> > > Cc: Will Deacon <will.deacon@arm.com>
> > > Cc: Peter Zijlstra <peterz@infradead.org>
> > > Cc: Rik van Riel <riel@surriel.com>
> > > Cc: Minchan Kim <minchan@kernel.org>
> > > Cc: Michal Hocko <mhocko@suse.com>
> > > Cc: Huang Ying <ying.huang@intel.com>
> > > Cc: Souptick Joarder <jrdr.linux@gmail.com>
> > > Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
> > > Cc: linux-mm@kvack.org
> > > Cc: linux-kernel@vger.kernel.org
> > >
> > > Signed-off-by: Thomas Hellstrom <thellstrom@vmware.com>
> > > ---
> > >  mm/memory.c | 10 ++++++----
> > >  1 file changed, 6 insertions(+), 4 deletions(-)
> > >
> > > diff --git a/mm/memory.c b/mm/memory.c
> > > index e11ca9dd823f..a95b4a3b1ae2 100644
> > > --- a/mm/memory.c
> > > +++ b/mm/memory.c
> > > @@ -2144,7 +2144,7 @@ static vm_fault_t do_page_mkwrite(struct
> > > vm_fault *vmf)
> > >         ret =3D vmf->vma->vm_ops->page_mkwrite(vmf);
> > >         /* Restore original flags so that caller is not surprised
> > > */
> > >         vmf->flags =3D old_flags;
> > > -       if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))
> > > +       if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_RETRY |
> > > VM_FAULT_NOPAGE)))
> >
> > With this patch there will multiple instances of (VM_FAULT_ERROR |
> > VM_FAULT_RETRY | VM_FAULT_NOPAGE)
> > in mm/memory.c. Does it make sense to wrap it in a macro and use it ?
>
> Even though the code will look neater, it might be trickier to follow a
> particular error path. Could we perhaps postpone to a follow-up patch?

Sure. follow-up-patch is fine.

>
> Thomas
>
>
>
> >
> > >                 return ret;
> > >         if (unlikely(!(ret & VM_FAULT_LOCKED))) {
> > >                 lock_page(page);
> > > @@ -2419,7 +2419,7 @@ static vm_fault_t wp_pfn_shared(struct
> > > vm_fault *vmf)
> > >                 pte_unmap_unlock(vmf->pte, vmf->ptl);
> > >                 vmf->flags |=3D FAULT_FLAG_MKWRITE;
> > >                 ret =3D vma->vm_ops->pfn_mkwrite(vmf);
> > > -               if (ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE))
> > > +               if (ret & (VM_FAULT_ERROR | VM_FAULT_RETRY |
> > > VM_FAULT_NOPAGE))
> > >                         return ret;
> > >                 return finish_mkwrite_fault(vmf);
> > >         }
> > > @@ -2440,7 +2440,8 @@ static vm_fault_t wp_page_shared(struct
> > > vm_fault *vmf)
> > >                 pte_unmap_unlock(vmf->pte, vmf->ptl);
> > >                 tmp =3D do_page_mkwrite(vmf);
> > >                 if (unlikely(!tmp || (tmp &
> > > -                                     (VM_FAULT_ERROR |
> > > VM_FAULT_NOPAGE)))) {
> > > +                                     (VM_FAULT_ERROR |
> > > VM_FAULT_RETRY |
> > > +                                      VM_FAULT_NOPAGE)))) {
> > >                         put_page(vmf->page);
> > >                         return tmp;
> > >                 }
> > > @@ -3494,7 +3495,8 @@ static vm_fault_t do_shared_fault(struct
> > > vm_fault *vmf)
> > >                 unlock_page(vmf->page);
> > >                 tmp =3D do_page_mkwrite(vmf);
> > >                 if (unlikely(!tmp ||
> > > -                               (tmp & (VM_FAULT_ERROR |
> > > VM_FAULT_NOPAGE)))) {
> > > +                               (tmp & (VM_FAULT_ERROR |
> > > VM_FAULT_RETRY |
> > > +                                       VM_FAULT_NOPAGE)))) {
> > >                         put_page(vmf->page);
> > >                         return tmp;
> > >                 }
> > > --
> > > 2.20.1
> > >

