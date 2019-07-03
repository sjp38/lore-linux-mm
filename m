Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89159C5B578
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 05:55:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B7E621871
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 05:55:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WarTlUln"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B7E621871
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CC1BD6B0005; Wed,  3 Jul 2019 01:55:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C72008E0003; Wed,  3 Jul 2019 01:55:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B88B78E0001; Wed,  3 Jul 2019 01:55:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 52C236B0005
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 01:55:29 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id x19so248163ljh.21
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 22:55:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=p9G7dahqqLBvpWifetVIRcTe56P9tGwywaRmRI7DVfM=;
        b=SScCxowZJBXdCEzk6NIc1NQFqzKtw4odyQHEiwEPN785pRxF0PI9w1x0XjSTlu9lEc
         Tq2QLnBf2Adh1V8kfxBKaaLW+6w+jV/bzYatHQf6soAgNaZ48K70FkQxgMM56Pf98hMF
         SB1pBf2QWPGg+1eNVpga5SpGP1h5PXD0noGPw29TnA21Bqs98O89RkzJckiVZPGqRVI+
         sRmQbNir3lnx8mXAbooLXQTmkheS1TeSzpgvzrzBpBTZ0oGbm+NFlIgHSjVBSuQ/LI6o
         D+q/tcQekBgGt3m78zm+UlqQ/nzCmJ9BhZEa+5QOlrNOtlLmSoy/tGht8sabP+IRh3sG
         oY7Q==
X-Gm-Message-State: APjAAAUi0U2luhJHQR6pgaRMYp4qRxOKI22fs2sC//QshpzzuzhKC5HG
	mzeBwq1Li25SuMtMOsFEKe3E1jxjogzKqBMyU98mu6w7wE3myjvP0TIwbWB3JzAnZEbdN52OC3a
	eIxhK4abo6UHNlYTP5MBI19M5dEhIgtqXrt2I/2YjfzESW0B9SqxbD64yAdGFezaV5w==
X-Received: by 2002:ac2:4c29:: with SMTP id u9mr16848540lfq.100.1562133328311;
        Tue, 02 Jul 2019 22:55:28 -0700 (PDT)
X-Received: by 2002:ac2:4c29:: with SMTP id u9mr16848512lfq.100.1562133327717;
        Tue, 02 Jul 2019 22:55:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562133327; cv=none;
        d=google.com; s=arc-20160816;
        b=MtHpk6Axv0a330OkOqif9h08xiybubGHziuUIRo9rA4e7t8oH0yJ0mh6o0h1RrJ+sX
         sDfKOhZ2C8NoH159l9TJc7qexqCf9AgQclrlO+fd8J0pTRdIBxz1nAaHYKKmYS2Q7kJ4
         8V+dLIrHFzWgzvM6Ic91WUIA9DUUwl03TW6Yspz2YzVZPjxrwcgxB7vxF+Slo2jHUFMX
         o5LjFWX7s9YpjKtvchh5HjSLMyilWfQNWNLx2HBXLF31U2UVT77VJLiQMmIA/wrOcXHy
         IXFv/ZvuD0NISLiiO/zigoLIwjpo9TG7In3CRo05rTo51cAa6lL6MNEwu4SaQ+dZnW7f
         LvKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=p9G7dahqqLBvpWifetVIRcTe56P9tGwywaRmRI7DVfM=;
        b=A1NNSWZqlBrUqUCCrhCnKyIMFHE8Pqs8DwlbcGjtmJpm0OBB1jxZJpv7sgXCm+mOQA
         mrRHrhuNH/5M1Gl1WNY98EbPZMMnAgQUOUiPgL5dAsAPOAIVWYEJwqPhbZWSzMF6zGoe
         hgozWTIcF8UMeMmDDBC3ku3INn6rWAanHLll/8Td+vHPsTKM764SfOIZo00kFXLRA8II
         KBusQqtMniJXM/GQAWqloPMOYJNWRjsGn0SMPCxoBmhXqe21/aKWcfncJsCNIgttHq6O
         iBWfcepB9U5m7UmQkmaecOBT/RyhzEeXN5Qq4TDDl2c1BNt/neTapC6zk2uPV6TeehgI
         lMBA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WarTlUln;
       spf=pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vitalywool@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 6sor485395ljs.44.2019.07.02.22.55.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Jul 2019 22:55:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WarTlUln;
       spf=pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vitalywool@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=p9G7dahqqLBvpWifetVIRcTe56P9tGwywaRmRI7DVfM=;
        b=WarTlUlnWaTK3MA99/Eo051DVjcu20CodKEPYS65TJisSvxsw78y3F7ulzzkOCDRuP
         7JLRlmfDNMOYtEMrVkmMTckvpYu8O/pZkDVKsFgt5RK8du2XOA/r1SkwyajYIw1xKKCn
         5zQJiGasB1K7g6R6NHs08k6nLqhMoHOda3Rio0FL8uPeHB/1VdUskxNHuCgQloRfvIYH
         HhGN5KBWFTKPyQXdKqZO77vgALn1KQpid4RTKA6PFdzy0BZmwVLTpyBuLkSyNz5bQET2
         7RReYiAPMe1BoKcE5VmOicBWENLCIAFcAUheORMcAmsQuKITwV0rBqcT1ZeoxOr2m/EA
         S6qw==
X-Google-Smtp-Source: APXvYqxbYWrWiGbrJerEdqPo1pfbe/idItfy/Bn8xk0BK95BO1LruB1YeM1oZ4jyeNbc7V2VFV/xNXdxvPvz22kFobw=
X-Received: by 2002:a2e:86cc:: with SMTP id n12mr19527958ljj.146.1562133327468;
 Tue, 02 Jul 2019 22:55:27 -0700 (PDT)
MIME-Version: 1.0
References: <20190702005122.41036-1-henryburns@google.com> <CALvZod5Fb+2mR_KjKq06AHeRYyykZatA4woNt_K5QZNETvw4nw@mail.gmail.com>
 <CAGQXPTjU0xAWCLTWej8DdZ5TbH91m8GzeiCh5pMJLQajtUGu_g@mail.gmail.com>
 <20190702141930.e31bf1c07a77514d976ef6e2@linux-foundation.org> <CAGQXPTiONoPARFTep-kzECtggS+zo2pCivbvPEakRF+qqq9SWA@mail.gmail.com>
In-Reply-To: <CAGQXPTiONoPARFTep-kzECtggS+zo2pCivbvPEakRF+qqq9SWA@mail.gmail.com>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Wed, 3 Jul 2019 07:54:29 +0200
Message-ID: <CAMJBoFPDKZScs-uKSH-YggE5Jqocb6e74FdCPTOGnO5qfUXd2Q@mail.gmail.com>
Subject: Re: [PATCH v2] mm/z3fold.c: Lock z3fold page before __SetPageMovable()
To: Henry Burns <henryburns@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shakeel Butt <shakeelb@google.com>, 
	Vitaly Vul <vitaly.vul@sony.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, 
	Xidong Wang <wangxidong_97@163.com>, Jonathan Adams <jwadams@google.com>, 
	Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 3, 2019 at 12:18 AM Henry Burns <henryburns@google.com> wrote:
>
> On Tue, Jul 2, 2019 at 2:19 PM Andrew Morton <akpm@linux-foundation.org> wrote:
> >
> > On Mon, 1 Jul 2019 18:16:30 -0700 Henry Burns <henryburns@google.com> wrote:
> >
> > > Cc: Vitaly Wool <vitalywool@gmail.com>, Vitaly Vul <vitaly.vul@sony.com>
> >
> > Are these the same person?
> I Think it's the same person, but i wasn't sure which email to include
> because one was
> in the list of maintainers and I had contacted the other earlier.

This is the same person, it's the transliteration done differently
that caused this :)

~Vitaly

