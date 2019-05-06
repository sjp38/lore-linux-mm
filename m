Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96622C04AAD
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 16:22:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 38F8A2087F
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 16:22:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="DVotpDP1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 38F8A2087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 837E36B0007; Mon,  6 May 2019 12:22:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E94F6B0008; Mon,  6 May 2019 12:22:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D86C6B000A; Mon,  6 May 2019 12:22:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 370516B0007
	for <linux-mm@kvack.org>; Mon,  6 May 2019 12:22:10 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id z7so8326631pgc.1
        for <linux-mm@kvack.org>; Mon, 06 May 2019 09:22:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=40wSFiuSnxDz381aUfzuDl5Kav43yI7Ct1/keTyO3F8=;
        b=j0xIKqClTtvbT9JiBR1dUhgowC6csiECZnYduu0ErmKozo+W5AJykNcU/Re7qcCT1g
         pF3BBpYZjVu8EnqxFxwiZUGINzPWSZ91i496u5jMCRVoWWzX2oDFvcwuwNN2ITDotHPd
         Br/sDgKalmtEdf1tZGl/KOe/BsavW5ahOn6c6UHZromJJxZy3RiWmPQiLPdm2ZQvhfxn
         NNPNjQabiEGB7JasLFV33RAEJvtkcQXfXCz0XSXqxJgirHanmuK2Ul7gq98QtHN2PUKd
         XP4d/owcYbuj9qNIy5VEZ7GcrxYBsqggn11FUitNrfm/qwFVnVx1Epx0Gz8rMl/Iz1Ta
         wWIQ==
X-Gm-Message-State: APjAAAUJXf323EL4MBpkc5sEJ5aAOjOUEFqQh09JCktVEeOcI4LKwB+t
	j+aDuUrmbIam05H0SG423ehSUwpvcXoCvzgcS7GPTEnr40WeDATpNjr5hsm9RnmoQVaIpoZ7+6S
	p00mCUCBH0l2Rv5i9xgQc6/vTGYUWwLJHHkS8R2D6aI3Ytq10RoKJnY7YS/YRewQL5w==
X-Received: by 2002:a63:cc0a:: with SMTP id x10mr33436073pgf.179.1557159729713;
        Mon, 06 May 2019 09:22:09 -0700 (PDT)
X-Received: by 2002:a63:cc0a:: with SMTP id x10mr33435960pgf.179.1557159728726;
        Mon, 06 May 2019 09:22:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557159728; cv=none;
        d=google.com; s=arc-20160816;
        b=IZ2LSoop8GY6k21nMrFBSB5m2Sl/sDSrs5YFtDQbk3NWaE/3InhOVBN0Hq8/L5ZkBy
         NWqq4i9GbswepaGMFg5dIgce6ivQFTGHCfe/RjQYjEKvRt+wvPzlvtGZiYxRBUccw6xg
         bV06i8bQ8ogNdihKQa/gWYA2Gd5tw8kYSbhp3EAaSwbs8x1WfgW2jI1tWX4dpSbSI4Sf
         x19dQwpigzfT+3NyQsTBA/EwbM1JoTtk03reuDCna8Ed7LzEOgNtX512I5twBvNxmFNw
         OIQxfSeGZ+Jxty9BJc626/1Xous7Wq9VyuQnX5XNznxixKgdYQ5mL1Uvor93ML5DYOVk
         opSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=40wSFiuSnxDz381aUfzuDl5Kav43yI7Ct1/keTyO3F8=;
        b=sFF5x/9vnmV5qRwxVPT1EWRwQx+KXzL52g30rSDzjwXOrLDHZrVgw3TmiDSrXiakIo
         yNLhPehP4fJIwktBOHu4VOJQuNw4On41zIQAohBa5sdOqo/uUQ0+Jak1tuQ5bLTKK6Tp
         pVCgtLH8hBMRim0AKKNXVl8O02/XqZvyi9hCL/BKxZZDMiirUfw/aXqOoFHLwJIGrbXy
         MLO13vD1OdNACRV2jd/+Tl6HhPo73EUVp2e8ugcBGcXEXZYkntPsNDcUBjahfhb3JllY
         UqxdcaNqA6h4vzOfcCh+gjWdBgldI47EmzYqTWVpEzowtmV53u0Hj53teQH2f4+pEmjy
         nFfQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=DVotpDP1;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h76sor5480598pfd.68.2019.05.06.09.22.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 May 2019 09:22:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=DVotpDP1;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=40wSFiuSnxDz381aUfzuDl5Kav43yI7Ct1/keTyO3F8=;
        b=DVotpDP1BfYOu9EIG5sO2py/kG385U8+4RKehRk0tC71Vfe/y8Dohrbwudfghmv4gC
         V1LDKukVm8TPgSIGKPKH/+AzQnvMn07KhJn3HSkyadIn3jlSJ5ClUm6UwCAwkx5Lj2ec
         jTZ+KF06FbPmw0HHf3CBeQEfXVzStv1Mct1AUlW1wy4NJfE7vbBjZ0bMdocNxT2oB1CS
         9lHhKeWSjQzqoRHwiiBianLagL8GKIjs0O4OySI/oLm6QzImAzv5mMB4tTPiN7x1FtTU
         rnBUs5QzACe456XBtVa1RIzVbxerlIOvNFz0tCOCg55SYKbtj/SOkAkOVG3enaPf58Zc
         SNbQ==
X-Google-Smtp-Source: APXvYqw0KbWeRobzhAngWvuw0v+iBDWRKwDC2xGNXHO8L4kdi1iOFuLP64D72WK0vtdzu/2x0qr2r6kf9SEmu6uA3nY=
X-Received: by 2002:aa7:90ce:: with SMTP id k14mr30343128pfk.239.1557159727868;
 Mon, 06 May 2019 09:22:07 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1556630205.git.andreyknvl@google.com> <05c0c078b8b5984af4cc3b105a58c711dcd83342.1556630205.git.andreyknvl@google.com>
 <20190503170310.GL55449@arrakis.emea.arm.com>
In-Reply-To: <20190503170310.GL55449@arrakis.emea.arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Mon, 6 May 2019 18:21:56 +0200
Message-ID: <CAAeHK+weVYv4Tgj8DXv0ZTFZzGEpLYsn-3wxxmQN+ZW88MXbMw@mail.gmail.com>
Subject: Re: [PATCH v14 13/17] IB/mlx4, arm64: untag user pointers in mlx4_get_umem_mr
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, 
	Vincenzo Frascino <vincenzo.frascino@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kees Cook <keescook@chromium.org>, 
	Yishai Hadas <yishaih@mellanox.com>, Kuehling@google.com, Felix <Felix.Kuehling@amd.com>, 
	Deucher@google.com, Alexander <Alexander.Deucher@amd.com>, Koenig@google.com, 
	Christian <Christian.Koenig@amd.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	Leon Romanovsky <leon@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Chintan Pandya <cpandya@codeaurora.org>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, 
	Dave Martin <Dave.Martin@arm.com>, Kevin Brodsky <kevin.brodsky@arm.com>, 
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>, Leon Romanovsky <leonro@mellanox.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 3, 2019 at 7:03 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
>
> On Tue, Apr 30, 2019 at 03:25:09PM +0200, Andrey Konovalov wrote:
> > This patch is a part of a series that extends arm64 kernel ABI to allow to
> > pass tagged user pointers (with the top byte set to something else other
> > than 0x00) as syscall arguments.
> >
> > mlx4_get_umem_mr() uses provided user pointers for vma lookups, which can
> > only by done with untagged pointers.
> >
> > Untag user pointers in this function.
> >
> > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > Reviewed-by: Leon Romanovsky <leonro@mellanox.com>
> > ---
> >  drivers/infiniband/hw/mlx4/mr.c | 7 ++++---
> >  1 file changed, 4 insertions(+), 3 deletions(-)
> >
> > diff --git a/drivers/infiniband/hw/mlx4/mr.c b/drivers/infiniband/hw/mlx4/mr.c
> > index 395379a480cb..9a35ed2c6a6f 100644
> > --- a/drivers/infiniband/hw/mlx4/mr.c
> > +++ b/drivers/infiniband/hw/mlx4/mr.c
> > @@ -378,6 +378,7 @@ static struct ib_umem *mlx4_get_umem_mr(struct ib_udata *udata, u64 start,
> >        * again
> >        */
> >       if (!ib_access_writable(access_flags)) {
> > +             unsigned long untagged_start = untagged_addr(start);
> >               struct vm_area_struct *vma;
> >
> >               down_read(&current->mm->mmap_sem);
> > @@ -386,9 +387,9 @@ static struct ib_umem *mlx4_get_umem_mr(struct ib_udata *udata, u64 start,
> >                * cover the memory, but for now it requires a single vma to
> >                * entirely cover the MR to support RO mappings.
> >                */
> > -             vma = find_vma(current->mm, start);
> > -             if (vma && vma->vm_end >= start + length &&
> > -                 vma->vm_start <= start) {
> > +             vma = find_vma(current->mm, untagged_start);
> > +             if (vma && vma->vm_end >= untagged_start + length &&
> > +                 vma->vm_start <= untagged_start) {
> >                       if (vma->vm_flags & VM_WRITE)
> >                               access_flags |= IB_ACCESS_LOCAL_WRITE;
> >               } else {
>
> Discussion ongoing on the previous version of the patch but I'm more
> inclined to do this in ib_uverbs_(re)reg_mr() on cmd.start.

OK, I want to publish v15 sooner to fix the issue with emails
addresses, so I'll implement this approach there for now.



>
> --
> Catalin

