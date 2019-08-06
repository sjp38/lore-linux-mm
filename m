Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D85FAC31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 14:54:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 85F2C20C01
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 14:54:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Ed48aOZ5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 85F2C20C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 09A996B0007; Tue,  6 Aug 2019 10:54:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 04CA46B0008; Tue,  6 Aug 2019 10:54:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E7B6F6B000A; Tue,  6 Aug 2019 10:54:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id C759D6B0007
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 10:54:13 -0400 (EDT)
Received: by mail-vk1-f199.google.com with SMTP id u202so37994009vku.5
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 07:54:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=uvULGp1ehQoSmPrEiVP/M3/oGZ8fYVuLJ335Bn5PpFs=;
        b=T+l2xKJDQm4ALjdqFT1+MWnhgf2iJEWN3uJFkU1bj+xd4AJJ/iH1M/yu3JifVi20G0
         8/wpoUsLI6uA1RBvs2x1kCjdaiMa5Zs11qbKTO70dnsI/pHWbjTiTTKCbRZUtn0gMlg1
         RvBB3DBI2EZIlKdiBk6/YvFrNl32RJMkn1eDcEqe+igZ3gbh4QWsmTo5UiauP/ycFZvh
         1QqkdrgVBcAXWRTsv/wKRtAB1YFDQ5LaTChTE/03dBf8YObv2CU7t82h2g2q/sLROrmh
         vXFD6DZg8aE9l4o2EdGfjLSCQEQTh3kvWKWCZaUdumb8Tbv/vemNw53mhShkymXVRI5u
         CU4g==
X-Gm-Message-State: APjAAAUCkNQPB1Rtw/LHEEKqHRTw9V/qldQF6erWYFRwESRgjzssgj1d
	oP+ER4L70OVN6c6AIoBJOSDzANNLNK29E9Kci/suUKUhmpQD4HIMMD4wnhmpHhBx2G+qBUFhwt8
	D3/wZHARDmOoWzSBI6K+8jEvqAwjwmDRh/+rq4nUQLjrG5DX9k6Lc7YZm4oTqGRCQ1g==
X-Received: by 2002:ac5:c7ce:: with SMTP id e14mr1284839vkn.61.1565103253410;
        Tue, 06 Aug 2019 07:54:13 -0700 (PDT)
X-Received: by 2002:ac5:c7ce:: with SMTP id e14mr1284806vkn.61.1565103252574;
        Tue, 06 Aug 2019 07:54:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565103252; cv=none;
        d=google.com; s=arc-20160816;
        b=cObH5aVMRGYYiEjA0C7A3u5a+nPD3mtglh7rGPhkqT/ICALerWPrZsXj+XDGF3MB3I
         3banC3oGCBmxghsWgnLjoMDXRCRKC1sUIVlt1I9PdCzHyos1eFgr59bmzE1WEtvVfPjQ
         jlBwe64Po5ftw2cB3+X3ZMiVhX+l8zSia56StRA+EISR/qks6HnDSImXg8dZ64Mtw9/x
         GzfAdfC1eyKHNjt8NKQ7ecJIC801KNj4+XYFa61E9qG66s1JOQgg2TJ5VYrhqpYXTpn8
         eHFNO7HjAkrLy7kpXkHXQuc/IV61/4uL43PIUUHmAH5wXNyiDYQ4NapO+rKbHD0PBqfH
         qQMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=uvULGp1ehQoSmPrEiVP/M3/oGZ8fYVuLJ335Bn5PpFs=;
        b=NmTB3hRctLOZ3Nee2yg8ESgiQnVOmL53VNBHZk5wOBin5pbX5y7lJnKv1cO9UhAuI4
         2Jr7Eee++HkU0xMlojK+/jyocx40a4LjB8CYL3X7K4E+PYE9uUSRswi6RZVVsMwZlTXb
         2jmsrmyAIKkQ+wv7nzJ1NA9WTecnllrPOjTvwppoVjP2QeBw09HzR4ZgrrwDUH9M8IyB
         fTkyLX4/YjidQexTox32QGGFlhO2o9U9280w/RJcjdjdvM7p7xozfq9IesgvNGML5cl9
         cFxhHpDyAukdjlVW5BryRSY27MwoGBUeuotMtdZNyPHwDbA5HOkZKFLS/azMtR7oqzj1
         bW7g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Ed48aOZ5;
       spf=pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pankajssuryawanshi@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v7sor43346107uaa.45.2019.08.06.07.54.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 07:54:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Ed48aOZ5;
       spf=pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pankajssuryawanshi@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=uvULGp1ehQoSmPrEiVP/M3/oGZ8fYVuLJ335Bn5PpFs=;
        b=Ed48aOZ5j6nT/dtVv/GAtNCJDj2Y6SOrZ2m2P4e9bDvOTXYQMeUqvTPD8JihOCTORa
         /irekEVryct63qTQoaOdrZdqdexMEEryJ1tUPZLExH9sUib/KKJpVAXtXlxcjF38UjfL
         arMW1RzMRYKMtERM0yAO+D1t3ruRuqrOO0P+qbrTTdXfkTcYkIZoa4qnAtBWJ/5mrsUq
         O1wE4S+RxSLNF7JBi2vvXr05Rlkqagf2aCTNp/3HyNxvyw07Nq1wqHnvniTI5PQhZuNk
         2hfsZ5KFsxcSMKUFp7/ij2bAwOtu8FDlzyMYvSWDifkcoh5eQoJVD9ubHFeIJ6bc0c2m
         bBfg==
X-Google-Smtp-Source: APXvYqz5RlQpnTg5vbJ7r6mVEyHAMw9NN6Rt/D5U956sQumpAHTHPDXJBO8i7kxg6dL/LfyJV+S4wmwy06f68hNOEH4=
X-Received: by 2002:ab0:208c:: with SMTP id r12mr2400372uak.27.1565103252167;
 Tue, 06 Aug 2019 07:54:12 -0700 (PDT)
MIME-Version: 1.0
References: <CACDBo54Jbueeq1XbtbrFOeOEyF-Q4ipZJab8mB7+0cyK1Foqyw@mail.gmail.com>
 <20190805112437.GF7597@dhcp22.suse.cz> <0821a17d-1703-1b82-d850-30455e19e0c1@suse.cz>
 <20190805120525.GL7597@dhcp22.suse.cz> <CACDBo562xHy6McF5KRq3yngKqAm4a15FFKgbWkCTGQZ0pnJWgw@mail.gmail.com>
 <20190805201650.GT7597@dhcp22.suse.cz>
In-Reply-To: <20190805201650.GT7597@dhcp22.suse.cz>
From: Pankaj Suryawanshi <pankajssuryawanshi@gmail.com>
Date: Tue, 6 Aug 2019 20:24:03 +0530
Message-ID: <CACDBo54kBy_YBcXBzs1dOxQRg+TKFQox_aqqtB2dvL+mmusDVg@mail.gmail.com>
Subject: Re: oom-killer
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	pankaj.suryawanshi@einfochips.com
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 6 Aug, 2019, 1:46 AM Michal Hocko, <mhocko@kernel.org> wrote:
>
> On Mon 05-08-19 21:04:53, Pankaj Suryawanshi wrote:
> > On Mon, Aug 5, 2019 at 5:35 PM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Mon 05-08-19 13:56:20, Vlastimil Babka wrote:
> > > > On 8/5/19 1:24 PM, Michal Hocko wrote:
> > > > >> [  727.954355] CPU: 0 PID: 56 Comm: kworker/u8:2 Tainted: P     =
      O  4.14.65 #606
> > > > > [...]
> > > > >> [  728.029390] [<c034a094>] (oom_kill_process) from [<c034af24>]=
 (out_of_memory+0x140/0x368)
> > > > >> [  728.037569]  r10:00000001 r9:c12169bc r8:00000041 r7:c121e680=
 r6:c1216588 r5:dd347d7c > [  728.045392]  r4:d5737080
> > > > >> [  728.047929] [<c034ade4>] (out_of_memory) from [<c03519ac>]  (=
__alloc_pages_nodemask+0x1178/0x124c)
> > > > >> [  728.056798]  r7:c141e7d0 r6:c12166a4 r5:00000000 r4:00001155
> > > > >> [  728.062460] [<c0350834>] (__alloc_pages_nodemask) from [<c021=
e9d4>] (copy_process.part.5+0x114/0x1a28)
> > > > >> [  728.071764]  r10:00000000 r9:dd358000 r8:00000000 r7:c1447e08=
 r6:c1216588 r5:00808111
> > > > >> [  728.079587]  r4:d1063c00
> > > > >> [  728.082119] [<c021e8c0>] (copy_process.part.5) from [<c022047=
0>] (_do_fork+0xd0/0x464)
> > > > >> [  728.090034]  r10:00000000 r9:00000000 r8:dd008400 r7:00000000=
 r6:c1216588 r5:d2d58ac0
> > > > >> [  728.097857]  r4:00808111
> > > > >
> > > > > The call trace tells that this is a fork (of a usermodhlper but t=
hat is
> > > > > not all that important.
> > > > > [...]
> > > > >> [  728.260031] DMA free:17960kB min:16384kB low:25664kB high:297=
60kB active_anon:3556kB inactive_anon:0kB active_file:280kB inactive_file:2=
8kB unevictable:0kB writepending:0kB present:458752kB managed:422896kB mloc=
ked:0kB kernel_stack:6496kB pagetables:9904kB bounce:0kB free_pcp:348kB loc=
al_pcp:0kB free_cma:0kB
> > > > >> [  728.287402] lowmem_reserve[]: 0 0 579 579
> > > > >
> > > > > So this is the only usable zone and you are close to the min wate=
rmark
> > > > > which means that your system is under a serious memory pressure b=
ut not
> > > > > yet under OOM for order-0 request. The situation is not great tho=
ugh
> > > >
> > > > Looking at lowmem_reserve above, wonder if 579 applies here? What d=
oes
> > > > /proc/zoneinfo say?
> >
> >
> > What is  lowmem_reserve[]: 0 0 579 579 ?
>
> This controls how much of memory from a lower zone you might an
> allocation request for a higher zone consume. E.g. __GFP_HIGHMEM is
> allowed to use both lowmem and highmem zones. It is preferable to use
> highmem zone because other requests are not allowed to use it.
>
> Please see __zone_watermark_ok for more details.
>
>
> > > This is GFP_KERNEL request essentially so there shouldn't be any lowm=
em
> > > reserve here, no?
> >
> >
> > Why only low 1G is accessible by kernel in 32-bit system ?


1G ivirtual or physical memory (I have 2GB of RAM) ?
>
>
> https://www.kernel.org/doc/gorman/, https://lwn.net/Articles/75174/
> and many more articles. In very short, the 32b virtual address space
> is quite small and it has to cover both the users space and the
> kernel. That is why we do split it into 3G reserved for userspace and 1G
> for kernel. Kernel can only access its 1G portion directly everything
> else has to be mapped explicitly (e.g. while data is copied).
> Thanks Michal.


>
> > My system configuration is :-
> > 3G/1G - vmsplit
> > vmalloc =3D 480M (I think vmalloc size will set your highmem ?)
>
> No, vmalloc is part of the 1GB kernel adress space.

I read in one article , vmalloc end is fixed if you increase vmalloc
size it decrease highmem. ?
Total =3D lowmem + (vmalloc + high mem)
>
>
> --
> Michal Hocko
> SUSE Labs

