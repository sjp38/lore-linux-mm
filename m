Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1E6CC28CC4
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 10:41:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4EB65271F6
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 10:41:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rjoKGRLL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4EB65271F6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A01C66B0005; Sat,  1 Jun 2019 06:41:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9B2C26B0006; Sat,  1 Jun 2019 06:41:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A1C86B0007; Sat,  1 Jun 2019 06:41:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 25BAF6B0005
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 06:41:14 -0400 (EDT)
Received: by mail-lf1-f72.google.com with SMTP id d8so2708883lfa.21
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 03:41:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=HfG8SFYlwhX2T6RV6yxB9+NDJcpkM3O1MaSrYiv8LPo=;
        b=f7rt16g6+UgwBR3FWVoGZPPMPjJ+S/SkJihGVys4k7rEsw7EECegD7eR0WyEikqqhj
         Ui2fq4zTj56B50swo5fNFaq9yY+iWTiYXUwrRplDsL6hlqj0mWyNzvcxz0j05luPQC1q
         1vzPj0G8ewJiKdNx87phgpEPSgRoj8GuxreETORQq/gperCGVwblaZdwt2i+N48xTU79
         RwYmp9i82eiJGxORzg4Jp2UhDq9ybT+V8dDg6SpjMysPBM9iipLWf2qGKxMzsOzO9nUO
         Le5BHnvHHHxZbGgC/Fk92pTBEZkrNASls6DFDsjR40GbN0ZngClSni16TordB7C7kmor
         qz3g==
X-Gm-Message-State: APjAAAX0pLL0L//u6HQqn4YV5aF3CgPfIlbXW4yyqVnoIqvfc+V5bx0u
	j8b/shu5ZRcy0YrDhXsANsbnRi4q07XcWrDqu9TzGDZFWg25wh/NsnI6yiJN+mWGxv01sFYiCvT
	PoOHe2SPR0JbN3OQ7LHiA0nxMuekxDZVQxNA7wc5oX5lSio50elU/qc6bham22Rr1OQ==
X-Received: by 2002:a2e:824d:: with SMTP id j13mr8355515ljh.137.1559385673159;
        Sat, 01 Jun 2019 03:41:13 -0700 (PDT)
X-Received: by 2002:a2e:824d:: with SMTP id j13mr8355469ljh.137.1559385671950;
        Sat, 01 Jun 2019 03:41:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559385671; cv=none;
        d=google.com; s=arc-20160816;
        b=DTTd4RaFm8V/81U4PFSn0yuz1vg7LnZdDPw68b69h7As2bdkbdObh35Ega88Vb16fZ
         BblGj/gJPXVALimJUEkU6KqEVaCBOO5yMlTF0fdyFuoIq6e7q0YX+viDeooqUe5CX7DM
         3MSqZ1Fv3xicverfHSP86dTTPl5irNGYjeR9aO6DR1aBM24YXKijJxC64v6ySi/GyJeI
         wwQHOiG7d2AyMloas2HKJcleWo3RGx+Ks/Acc1uBe+Guna2IpkICwxsrtBUdhSeOTqck
         euyO0gzty2ukEK7LimUjvYJw+2TGsNrgDccS6Y6o6CZP9PJ8PP5SSqVGTfhyFhzhce/w
         zJ2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=HfG8SFYlwhX2T6RV6yxB9+NDJcpkM3O1MaSrYiv8LPo=;
        b=l9DBtcAMH5VIbNQuMQFKc42Wq5w+mYtzXmIEAa6EitvQCmlFlohMciz+6iuVjML/gx
         pvESg6o70X9If+8uX5T0PzuH9jK4UO7hkIhGYjUDi0UlkkscxKXorEuL0UVyopkA4Usi
         O2cq3iX41XbHuSxO8JnwCTgDWOCfxPimmKSi0ZavzJDsgwSc/bbWYskGWGgRLqn2cU/j
         V0uD0NA0+d0DPTJZhtESxXB808rurnTDBNkALb+h4BjH0znC6PhU8aoevpIGHkyIKMIp
         0GOukgVKwe+InqDZWiYO+y6bOHJuTdlFeBfhKrrGGUGk2CLjEip3xi34HCXDbvyJb1Uo
         GQQw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rjoKGRLL;
       spf=pass (google.com: domain of miguel.ojeda.sandonis@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=miguel.ojeda.sandonis@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u3sor5791775ljg.35.2019.06.01.03.41.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 01 Jun 2019 03:41:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of miguel.ojeda.sandonis@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rjoKGRLL;
       spf=pass (google.com: domain of miguel.ojeda.sandonis@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=miguel.ojeda.sandonis@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=HfG8SFYlwhX2T6RV6yxB9+NDJcpkM3O1MaSrYiv8LPo=;
        b=rjoKGRLLtJKt2NLllelbm573MDL2ykr+faYahdLKjSY7Y5bcl9oOcfgIPjxjLRT8Rg
         mveZbNR6/4PcibX5IGuiP2ht/kulnh3WcI4MaWK2Y1A0DXjutsYEwD3qTftFhiv8GqfK
         7+qaDof1ZYd3doX7X1h+7WeRcfHVpsj0pwMdcoQ9xEdSqbExbR0q5XsGZkhOjNfO0bju
         T5gSSanCNIC12PTxtOjXIjZmgaW8TSijlkhgbcIQjczBFFhQDLrsYZl8VwB/3MG1Gh3c
         8YfiZYGEuJBRTypFu7XSl1WsefQ2ppNKSDi5woINqma62CXA6zpRINHHLvZ5yGrTw5X8
         DUHQ==
X-Google-Smtp-Source: APXvYqwo+hRPRQiNwv/GCJLziYFhPRmDBka35PISCOCnRhr43lAq1JZzc9/8GlGwArLsGmyrafsMQ15XfcxCKdwIxNE=
X-Received: by 2002:a2e:9157:: with SMTP id q23mr8892650ljg.188.1559385671552;
 Sat, 01 Jun 2019 03:41:11 -0700 (PDT)
MIME-Version: 1.0
References: <20190528193004.GA7744@gmail.com> <CAFqt6zZ0SHXddLoQMoO3LHT=50Br0x4r3Wn4XviypRxRUtn9zQ@mail.gmail.com>
In-Reply-To: <CAFqt6zZ0SHXddLoQMoO3LHT=50Br0x4r3Wn4XviypRxRUtn9zQ@mail.gmail.com>
From: Miguel Ojeda <miguel.ojeda.sandonis@gmail.com>
Date: Sat, 1 Jun 2019 12:41:00 +0200
Message-ID: <CANiq72m7YURu2XiKHQ+F8sxitVecZyrCPFBw=wGr2CddEv3khg@mail.gmail.com>
Subject: Re: [PATCH] mm: Fail when offset == num in first check of vm_map_pages_zero()
To: Souptick Joarder <jrdr.linux@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>, Peter Zijlstra <peterz@infradead.org>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Huang Ying <ying.huang@intel.com>, 
	open list <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 29, 2019 at 9:09 AM Souptick Joarder <jrdr.linux@gmail.com> wrote:
>
> On Wed, May 29, 2019 at 1:38 AM Miguel Ojeda
> <miguel.ojeda.sandonis@gmail.com> wrote:
> >
> > If the user asks us for offset == num, we should already fail in the
> > first check, i.e. the one testing for offsets beyond the object.
> >
> > At the moment, we are failing on the second test anyway,
> > since count cannot be 0. Still, to agree with the comment of the first
> > test, we should first there.
>
> I think, we need to cc linux-mm.

Cc'ing Andrew as well as Souptick suggested me.

Cheers,
Miguel

