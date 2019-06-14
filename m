Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8CD50C31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 18:04:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4EAAF20644
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 18:04:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="KVXUFAN3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4EAAF20644
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D88F56B000C; Fri, 14 Jun 2019 14:04:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D387C6B000D; Fri, 14 Jun 2019 14:04:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C00146B000E; Fri, 14 Jun 2019 14:04:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 94EFD6B000C
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 14:04:07 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id a21so1468272otk.17
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 11:04:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=KI77U09jc4yTSNFo3uKcj1zjV8YecEqjHXwcoLePMbY=;
        b=BPuXf/giXXN8MhPKVcEDpEfNa87/8nYs8grhaL+XuIPGXMYhY57+1EbNuT+1Zzqe+Y
         ruJbuHuLnmMUIP2ng3dqvsx7m00B1Qjxctgg9RwOFiGRZgVUq8pMCf6XRx2w+oysAWl/
         683sBazGxTnTcsZem/FnZBM196pisHyh5Vj/BOLORGokfVHDalUMt3HkJSJooF8WDlW7
         qYcPTq5RBWNyMsMwrSgCwyIh+jy1O3qNEjpGWUEQUMOHKimMMEGIl3RhfcwQJlIeM4pe
         r3Az/qigFJd5gA9eFMJkfryhpBr0omfUU9/lxRA3hJwb7ZAs3KUdIGDAmlVusRMCZ0tc
         kinw==
X-Gm-Message-State: APjAAAW3/ZHnlPfGwg6OYP2PYc+nL3tCSX/OuwMwnlSvGKLvTBgLLHMA
	YEa/czoXJtZryakNQzmym6C3l9xXQpVa+Cr+0bTshYWz5a9bb8/2JpdDdxAv/quRvnoitERsMf5
	P9XUk/Qgd70Qhrr31sIQEhCQ7FN6vPHdrgqLVlpqSZ5DGgFtljg5Ikme40BxHKUJuaQ==
X-Received: by 2002:aca:d550:: with SMTP id m77mr2758489oig.155.1560535447168;
        Fri, 14 Jun 2019 11:04:07 -0700 (PDT)
X-Received: by 2002:aca:d550:: with SMTP id m77mr2758459oig.155.1560535446430;
        Fri, 14 Jun 2019 11:04:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560535446; cv=none;
        d=google.com; s=arc-20160816;
        b=mQO+cvUDcoJ0Aw0fShywfF2J9XeFkBqfTuxqY5mR6VXxAuAMG9hMY29py2jSJUfK2W
         2WjtU5+3l3s0JTcxzC3B19v/vlFGC6JSQHDluAbDibgcCM+zWNpXk/qaI59BCUFK3Uux
         R350iwoOqOSAEfHIWq1lwFZOxzUSqskG+VMOwXa166BwjC7F2x94vncTSQSyNWStRqUt
         zhTMrblZQbqEoI/BBkq8g9pFe7jUlnYhyn2WEGrv54AkwnyC4x+mRTUKg3UwcVZ15xYo
         /26XDZ+LbedJ7UAvylx//spANPIilHnFXpzwQfmLB4KQYpI8ZQhktnrWnIosC9oUixZj
         zBSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=KI77U09jc4yTSNFo3uKcj1zjV8YecEqjHXwcoLePMbY=;
        b=KodcMupcLYyhStgdZKIrDRJ6hePnYK4w8q6wBlhziZffrMQWYB4WsyDmPthXmK0fK/
         cSBKGCSy5gtJYUNwEBk2zg3S+hhxsZVr5ZrSDmo3lVY0bKLNnd2PUGaERcsTHNm1ZihK
         gv/X/BoOm3e/Z90j0Q4ztOUNP2qxG+wD+9bVcchDDxHTCMGeGBuDxCI3lOvWFq8Msq49
         2oF7Fis4VvMYqNzR1xAuWM28+KKazGqt6j6wkQ2WV9tkLnV/WRV+YHjq3g+FeB4lteoR
         BFaiPyMR5QQJvbXUS/TqQVUcHI43xXH3FPS/zP0i4PtpOtMy8uIPK988dqaG6HZGkOFj
         QZNg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=KVXUFAN3;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x206sor1510795oif.28.2019.06.14.11.04.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 14 Jun 2019 11:04:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=KVXUFAN3;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=KI77U09jc4yTSNFo3uKcj1zjV8YecEqjHXwcoLePMbY=;
        b=KVXUFAN3swMFWBGzzixjB8VlLjL76aesYtmPDtHwjQ4F2McCRNHoqKURqafp/z9EzM
         CAB5WYDWPfK52bdUBpHevist0z44Pi2lSZn189XQJxSDbdHQfkUYppM1ZJysDXyxLF9j
         +Xm0fCtvrQaDvbqusIZe7jzFxi25W/YjyILyNf5tasvgIEADk/uTH1mnlPi8s7MYFP/8
         EODfrEggoA1lfki5F+9dja6mP9uPJruC1He/5jm9B0GhXCV1WKodyOoCFK/Gc+Y9KRdF
         7C1NEl1EFI4aOl01s/23HOQgsTtc9R5bUauyt0GKzfzdpx8EXaePvYzuSjjyqZRp/sWE
         lsCA==
X-Google-Smtp-Source: APXvYqwbsBOYR/vwuJCqEYhR3cOJgH0hPf6MeFYglFOg2KYQKUxstG5xreGllhZuqvwSfn7udfK/3H+QuupdLKIx3Yo=
X-Received: by 2002:aca:4208:: with SMTP id p8mr2745114oia.105.1560535446101;
 Fri, 14 Jun 2019 11:04:06 -0700 (PDT)
MIME-Version: 1.0
References: <1560366952-10660-1-git-send-email-cai@lca.pw> <CAPcyv4hn0Vz24s5EWKr39roXORtBTevZf7dDutH+jwapgV3oSw@mail.gmail.com>
 <CAPcyv4iuNYXmF0-EMP8GF5aiPsWF+pOFMYKCnr509WoAQ0VNUA@mail.gmail.com>
 <1560376072.5154.6.camel@lca.pw> <87lfy4ilvj.fsf@linux.ibm.com> <1560524365.5154.21.camel@lca.pw>
In-Reply-To: <1560524365.5154.21.camel@lca.pw>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 14 Jun 2019 11:03:55 -0700
Message-ID: <CAPcyv4jAzMzFjSD22VU9Csw+kgGbf8r=XHbdJYzgL_uH_GVEvw@mail.gmail.com>
Subject: Re: [PATCH -next] mm/hotplug: skip bad PFNs from pfn_to_online_page()
To: Qian Cai <cai@lca.pw>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Oscar Salvador <osalvador@suse.de>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 14, 2019 at 7:59 AM Qian Cai <cai@lca.pw> wrote:
>
> On Fri, 2019-06-14 at 14:28 +0530, Aneesh Kumar K.V wrote:
> > Qian Cai <cai@lca.pw> writes:
> >
> >
> > > 1) offline is busted [1]. It looks like test_pages_in_a_zone() missed the
> > > same
> > > pfn_section_valid() check.
> > >
> > > 2) powerpc booting is generating endless warnings [2]. In
> > > vmemmap_populated() at
> > > arch/powerpc/mm/init_64.c, I tried to change PAGES_PER_SECTION to
> > > PAGES_PER_SUBSECTION, but it alone seems not enough.
> > >
> >
> > Can you check with this change on ppc64.  I haven't reviewed this series yet.
> > I did limited testing with change . Before merging this I need to go
> > through the full series again. The vmemmap poplulate on ppc64 needs to
> > handle two translation mode (hash and radix). With respect to vmemap
> > hash doesn't setup a translation in the linux page table. Hence we need
> > to make sure we don't try to setup a mapping for a range which is
> > arleady convered by an existing mapping.
>
> It works fine.

Strange... it would only change behavior if valid_section() is true
when pfn_valid() is not or vice versa. They "should" be identical
because subsection-size == section-size on PowerPC, at least with the
current definition of SUBSECTION_SHIFT. I suspect maybe
free_area_init_nodes() is too late to call subsection_map_init() for
PowerPC.

