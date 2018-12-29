Return-Path: <SRS0=mZRB=PG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 769FBC43387
	for <linux-mm@archiver.kernel.org>; Sat, 29 Dec 2018 06:38:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2A54720866
	for <linux-mm@archiver.kernel.org>; Sat, 29 Dec 2018 06:38:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="DOZNU3tn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2A54720866
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8659A8E0059; Sat, 29 Dec 2018 01:38:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7EDE08E0001; Sat, 29 Dec 2018 01:38:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 68FE08E0059; Sat, 29 Dec 2018 01:38:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3D2128E0001
	for <linux-mm@kvack.org>; Sat, 29 Dec 2018 01:38:22 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id d20so20699725iom.0
        for <linux-mm@kvack.org>; Fri, 28 Dec 2018 22:38:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=0ZeViuD5AR+Y+bp3iOoy+E0zr6PwSy4elFOzmd/xbXE=;
        b=Uvnfm9C6Qje8rJSahTT91xCamNP/+YAIyFqJCd7wiQZtWWuuC6TVIGueov4s8Q2QQ7
         zG94JecDFf1lme/uxUbRPmIk3BsipR61S4buVNUTabFZkOXbjVlA6fEuIYSCT0Gpmjc/
         BsxcWxN3xLG2U0SKIoXeKm/Df/dFtnUmfV9I4scxSwKk5tOlYzBfg4rTnGBPEFhBlOtX
         b72YHNp2NvsYfqYqpTceJHtcy8ujiiNiTjVCJaFTRlyCk1SUp5On+hVncJjzFu8ETbUS
         GvaVKbnqROfKHB+GAGB1Hx2GgkattUzIfMwoiGtamoAJcKtf+71QvCveFVtRTkUNY/tF
         hM4w==
X-Gm-Message-State: AA+aEWbHFOkKrPgbrf5YF2L1LcEHKvNirGYX5OvsIoMZOcGvuw/E4HSt
	K08z2FczzKmwEKqAp9yYK8Vnxh9pkvgfLrTZ+Y5gPavr/S5I+M74IlQXyocJylaVtrQGM5ZCIJi
	NC96V6BUR4vuhpsJ76dnw/K9c440NyzrIsg+BYwZqg/n+I5Z/5xLWYbsDEoTSKCCtpzQmFi600C
	0nyypcZ+XMTpXOIm6Qa1uPTb1DeuNf5DFJnVcAqeEPucDEKTvirbdlMoLK4kPnT5okWSOqMegzN
	3kj4jlUpSJLZinf0aRThWLi1l4Pao/RePk+4/4CS+DnmfGbi8uxJARXmFugGkCVqvTc4A/ZSyCl
	8O/hA+s1OTHMxfi+ei+KrgasoThF2RNqunT3BCx6ex+XF2B1aYk6UrgEZqnn2zGCqPIQn2T8vx2
	M
X-Received: by 2002:a24:3dca:: with SMTP id n193mr20896902itn.48.1546065501967;
        Fri, 28 Dec 2018 22:38:21 -0800 (PST)
X-Received: by 2002:a24:3dca:: with SMTP id n193mr20896886itn.48.1546065501187;
        Fri, 28 Dec 2018 22:38:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546065501; cv=none;
        d=google.com; s=arc-20160816;
        b=c7LihLx/5hjSM2XxlfYTPC+k+p6reg3Xu1WuibOO/Dltph7WdK5qF7tSvs8sZlFx0d
         /ct3IplsoCTGiAR/ukyJbeib99tBEHhGPrFAjieKjc9M0kqWST6ZTv8ovGmqPtYA1ps4
         uC/rvSy3QXLAGYXhYL9cam1Hjk3egITvBSaDkwbY9CgOPDseuM0nFX+coZ/jQbZ/S+oX
         zZCJ8O16F4hRvOpgvDxSNzmoP5E3/urqLOxuBwDBekWF3ANL1LXN6t0gzyf5TpkIW13M
         URQjOFek0+W6xfWzLOVY21O616gpC2M6TO86zEVBKryGd8p+hZCUvbtXg06aYiQ4iHr3
         KzGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=0ZeViuD5AR+Y+bp3iOoy+E0zr6PwSy4elFOzmd/xbXE=;
        b=O9OX4ouPyhtRpBxSq5DdSULOis9FJSXLAf5lVnwS7xNhfPypQQP2q7daPALEAueHTV
         dWw7EHZ8oKtGvUrsHToli3qeRKSyMz8QQQ8nz8eeRxE5HeHLlRXeWS5FZgvJKymgtU7e
         2Ubijjk2JIwlv0HQQicrlB9WWfbIN8zrTsys98MU0SifvhsL4LQp2msHJDtWarSE6r6w
         sxV8mbqsOLSIWf1lQ4IfHOPWysehCPLBOgVaaxqy0dsF3TKYO2AcO7mqUjhbdBmeroea
         zjZDiNyd/XAEwog4TFPLviGQAwervfrc/Y2Dfp61Bt5HAk8cK82iIcmVRO+HmEXA6vf5
         cLwg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=DOZNU3tn;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p140sor33220668itp.36.2018.12.28.22.38.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Dec 2018 22:38:21 -0800 (PST)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=DOZNU3tn;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=0ZeViuD5AR+Y+bp3iOoy+E0zr6PwSy4elFOzmd/xbXE=;
        b=DOZNU3tnUpe3S5szXlK+1lPigHq7aVQtRCwSeOBr7gaBXGdeui6Lefv2gCbxrvhn4o
         RbWLUDO8qEUnJkMxq2zEAXSLxJ9/y6o38Quqt8VWYmKWtsDYidlFGwwiEw6t8OMzBTG+
         S/aU4oCrIqovMK1nGSYaaGRixhV9i89JAAvKbR+1pMFyrbUCovEI8QCrUFE7VdktPkED
         ys5KH1faWRcfS+JZuLyl7MGHsvHjtmfquZkvtPX1Pq0h1gHNDZzmFl8eUsmeWZPon+kS
         8J1zfM8LHG7bvwC6Ek8aZ1zpYi7THDHhnCU67rj8XgpCZ9szi7bfYJAQgfOJwLTKZVIm
         wPZA==
X-Google-Smtp-Source: AFSGD/VTVfmZo7L+A3EKKs5v5i701C7j+p049SieQz8gnFKGhE1cYMuWcvH8o1w6L7mw6Z5qngDH1UXv/vP88thKM84=
X-Received: by 2002:a24:b20e:: with SMTP id u14mr19830088ite.12.1546065500564;
 Fri, 28 Dec 2018 22:38:20 -0800 (PST)
MIME-Version: 1.0
References: <000000000000b57d19057e1b383d@google.com> <20181228130938.c9e42c213cdcc35a93dd0dac@linux-foundation.org>
 <20181228235106.okk3oastsnpxusxs@kshutemo-mobl1>
In-Reply-To: <20181228235106.okk3oastsnpxusxs@kshutemo-mobl1>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Sat, 29 Dec 2018 07:38:08 +0100
Message-ID:
 <CACT4Y+Ynm+LPupT0OM=E8AdF0bQDKc-arPy3M=V1D5V0tCmZ=g@mail.gmail.com>
Subject: Re: KASAN: use-after-free Read in filemap_fault
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, 
	syzbot <syzbot+b437b5a429d680cf2217@syzkaller.appspotmail.com>, 
	"Darrick J. Wong" <darrick.wong@oracle.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, josef@toxicpanda.com, 
	Souptick Joarder <jrdr.linux@gmail.com>, LKML <linux-kernel@vger.kernel.org>, 
	Linux-MM <linux-mm@kvack.org>, Stephen Rothwell <sfr@canb.auug.org.au>, 
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Matthew Wilcox <willy@infradead.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181229063808.pSdyjRPwDaOwyPSO5Z7Xob0SwoqeBDGO7YW1g4Oc0eg@z>

On Sat, Dec 29, 2018 at 12:51 AM Kirill A. Shutemov
<kirill@shutemov.name> wrote:
>
> On Fri, Dec 28, 2018 at 01:09:38PM -0800, Andrew Morton wrote:
> > On Fri, 28 Dec 2018 12:51:04 -0800 syzbot <syzbot+b437b5a429d680cf2217@syzkaller.appspotmail.com> wrote:
> >
> > > Hello,
> > >
> > > syzbot found the following crash on:
> >
> > uh-oh.  Josef, could you please take a look?
> >
> > :     page = find_get_page(mapping, offset);
> > :     if (likely(page) && !(vmf->flags & FAULT_FLAG_TRIED)) {
> > :             /*
> > :              * We found the page, so try async readahead before
> > :              * waiting for the lock.
> > :              */
> > :             fpin = do_async_mmap_readahead(vmf, page);
> > :     } else if (!page) {
> > :             /* No page in the page cache at all */
> > :             fpin = do_sync_mmap_readahead(vmf);
> > :             count_vm_event(PGMAJFAULT);
> > :             count_memcg_event_mm(vmf->vma->vm_mm, PGMAJFAULT);
> >
> > vmf->vma has been freed at this point.
> >
> > :             ret = VM_FAULT_MAJOR;
> > : retry_find:
> > :             page = pagecache_get_page(mapping, offset,
> > :                                       FGP_CREAT|FGP_FOR_MMAP,
> > :                                       vmf->gfp_mask);
> > :             if (!page) {
> > :                     if (fpin)
> > :                             goto out_retry;
> > :                     return vmf_error(-ENOMEM);
> > :             }
> > :     }
> >
>
> Here's a fixup for "filemap: drop the mmap_sem for all blocking operations".

If you are going to squash this, please add:

Tested-by: syzbot+b437b5a429d680cf2217@syzkaller.appspotmail.com


> do_sync_mmap_readahead() drops mmap_sem now, so by the time of
> dereferencing vmf->vma for count_memcg_event_mm() the VMA can be gone.
>
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 00a9315f45d4..65c85c47bdb1 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -2554,10 +2554,10 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
>                 fpin = do_async_mmap_readahead(vmf, page);
>         } else if (!page) {
>                 /* No page in the page cache at all */
> -               fpin = do_sync_mmap_readahead(vmf);
>                 count_vm_event(PGMAJFAULT);
>                 count_memcg_event_mm(vmf->vma->vm_mm, PGMAJFAULT);
>                 ret = VM_FAULT_MAJOR;
> +               fpin = do_sync_mmap_readahead(vmf);
>  retry_find:
>                 page = pagecache_get_page(mapping, offset,
>                                           FGP_CREAT|FGP_FOR_MMAP,
> --
>  Kirill A. Shutemov
>
> --
> You received this message because you are subscribed to the Google Groups "syzkaller-bugs" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller-bugs+unsubscribe@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/syzkaller-bugs/20181228235106.okk3oastsnpxusxs%40kshutemo-mobl1.
> For more options, visit https://groups.google.com/d/optout.

