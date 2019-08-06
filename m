Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD3DBC31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 15:07:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 99D1E2089E
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 15:07:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 99D1E2089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3286E6B0003; Tue,  6 Aug 2019 11:07:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D8F06B0006; Tue,  6 Aug 2019 11:07:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1A1AB6B0007; Tue,  6 Aug 2019 11:07:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C22096B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 11:07:36 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b12so54071077ede.23
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 08:07:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=V0C5FM682nwgsm1K9JTQeRx+7xNx5W2bzwV96Gj7X7o=;
        b=DF68PtQv4VFjmA9I3TH9n5pjZZiHbkiK6HkmDl1Tb7XCwT0DRKvGnfvDCVtAqXYotC
         VZloxYGIqxwAz71pmdPaP8xQA6hpmYRU8jmsJ3qGMcenmScqmqTC3wB87uPkCECYxxTK
         LhJ4ZuPGmmejlLL5zKk1GYCoIlrTSoWiGNeyyBi5ohcFPx3nbLmAoNyp71aC4yw3krZW
         hZx2hdKYu3KSrYUKREYTcfLWhYbZ/ch46CM6KR9D2+ihpR3/uW2CjmEB5FUAqJ4jPTca
         3u5UNp5865O5Qju8TvUKCSc4NrNxguQ0IvYny/9f/aZHEVJ1qj0SyFxPdFZcKik9/U1g
         W9Wg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUHiASvxQft6Vz8U2ESdOULLA4FxRIrjSdob1CqGQp9QJII5h4R
	l+dKB4c0rEbRRtMUGYvJjvObzuil/utp8lLiSa3kkzSdHHfvdPewYyx/gXuZD5PMyxxEw9rhQ7A
	gNPx5GWO+mH5txdev2D4r/q7LWJobU75HY6EulbkbkUwEtzNVstNOSAh40ahSKNU=
X-Received: by 2002:a17:906:30d9:: with SMTP id b25mr3529076ejb.55.1565104056358;
        Tue, 06 Aug 2019 08:07:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxEHAXCClPm54Y82UVpXziOpPyKkSrXSKcMnlKgqlZ/Jwx9F3WWr2azlIWkzQR/7NNgFg+h
X-Received: by 2002:a17:906:30d9:: with SMTP id b25mr3528994ejb.55.1565104055481;
        Tue, 06 Aug 2019 08:07:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565104055; cv=none;
        d=google.com; s=arc-20160816;
        b=AnzOE6+alkGFEmDZ1iQYcCWov3ZK7WVNLGdaqlUeFUBqLa/UsjgZSRhgcLZB+6irDI
         lz+k5TdqMCEWXjvn2I7+/+G0kMCcd2G0FP5il8krj1boSYoGzM/WvdYbnS7nxuRlZml4
         z7xdHsYZlyWJYCvth0D9NbT9cGsAlNmAdow16aNxgAOpUzvRzeWCFxY/3WLSNQgn1F3I
         OeYM9whBmFvIQZ15SNSOan7l703VkVez5qYVCK1TIekVmEkzuFgDSkPepFt96wWlLOyH
         oxlUX4+bxvU9Xn0tgsyBngMxD/YuLb79rRYCq0RZeHG7K0T66ABuZp3lEt/RAcHj9oli
         y0rg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=V0C5FM682nwgsm1K9JTQeRx+7xNx5W2bzwV96Gj7X7o=;
        b=GMfn92gD5tPsZiLGhrSsZ1gNkWmNAp+o1pTdbshQZYO/dNzAC1bZzo+7MtEjUL8TeU
         061WTjB0SeOidrn3lwoNjMMdXWr6kt+nGSn0Zmf2TD3NJfIwGw3FKSLylhj3w7CnAyrz
         K5fbZ8z2yfcgPO4uiBIEB0A/XSUyItIz14wRoHlsXSdfXPL9uZRgP0p/yYUSIL22HBv0
         AxSjvqFzE/gWtynig1y2hUxWjFK7q0NFXXdeNuYiCvdRqSZIQu3uHFLq6V6e9oFhirsZ
         TvV5RZZofJSZDRyBoH2P00/thAq3G/FTnX0XIw+3rJ6UJJPNgeA8OZVVwJhbIkrllYaN
         7b4g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k21si27837795ejr.44.2019.08.06.08.07.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 08:07:35 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B3CBBAE65;
	Tue,  6 Aug 2019 15:07:34 +0000 (UTC)
Date: Tue, 6 Aug 2019 17:07:33 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Pankaj Suryawanshi <pankajssuryawanshi@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, pankaj.suryawanshi@einfochips.com
Subject: Re: oom-killer
Message-ID: <20190806150733.GH11812@dhcp22.suse.cz>
References: <CACDBo54Jbueeq1XbtbrFOeOEyF-Q4ipZJab8mB7+0cyK1Foqyw@mail.gmail.com>
 <20190805112437.GF7597@dhcp22.suse.cz>
 <0821a17d-1703-1b82-d850-30455e19e0c1@suse.cz>
 <20190805120525.GL7597@dhcp22.suse.cz>
 <CACDBo562xHy6McF5KRq3yngKqAm4a15FFKgbWkCTGQZ0pnJWgw@mail.gmail.com>
 <20190805201650.GT7597@dhcp22.suse.cz>
 <CACDBo54kBy_YBcXBzs1dOxQRg+TKFQox_aqqtB2dvL+mmusDVg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACDBo54kBy_YBcXBzs1dOxQRg+TKFQox_aqqtB2dvL+mmusDVg@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 06-08-19 20:24:03, Pankaj Suryawanshi wrote:
> On Tue, 6 Aug, 2019, 1:46 AM Michal Hocko, <mhocko@kernel.org> wrote:
> >
> > On Mon 05-08-19 21:04:53, Pankaj Suryawanshi wrote:
> > > On Mon, Aug 5, 2019 at 5:35 PM Michal Hocko <mhocko@kernel.org> wrote:
> > > >
> > > > On Mon 05-08-19 13:56:20, Vlastimil Babka wrote:
> > > > > On 8/5/19 1:24 PM, Michal Hocko wrote:
> > > > > >> [  727.954355] CPU: 0 PID: 56 Comm: kworker/u8:2 Tainted: P           O  4.14.65 #606
> > > > > > [...]
> > > > > >> [  728.029390] [<c034a094>] (oom_kill_process) from [<c034af24>] (out_of_memory+0x140/0x368)
> > > > > >> [  728.037569]  r10:00000001 r9:c12169bc r8:00000041 r7:c121e680 r6:c1216588 r5:dd347d7c > [  728.045392]  r4:d5737080
> > > > > >> [  728.047929] [<c034ade4>] (out_of_memory) from [<c03519ac>]  (__alloc_pages_nodemask+0x1178/0x124c)
> > > > > >> [  728.056798]  r7:c141e7d0 r6:c12166a4 r5:00000000 r4:00001155
> > > > > >> [  728.062460] [<c0350834>] (__alloc_pages_nodemask) from [<c021e9d4>] (copy_process.part.5+0x114/0x1a28)
> > > > > >> [  728.071764]  r10:00000000 r9:dd358000 r8:00000000 r7:c1447e08 r6:c1216588 r5:00808111
> > > > > >> [  728.079587]  r4:d1063c00
> > > > > >> [  728.082119] [<c021e8c0>] (copy_process.part.5) from [<c0220470>] (_do_fork+0xd0/0x464)
> > > > > >> [  728.090034]  r10:00000000 r9:00000000 r8:dd008400 r7:00000000 r6:c1216588 r5:d2d58ac0
> > > > > >> [  728.097857]  r4:00808111
> > > > > >
> > > > > > The call trace tells that this is a fork (of a usermodhlper but that is
> > > > > > not all that important.
> > > > > > [...]
> > > > > >> [  728.260031] DMA free:17960kB min:16384kB low:25664kB high:29760kB active_anon:3556kB inactive_anon:0kB active_file:280kB inactive_file:28kB unevictable:0kB writepending:0kB present:458752kB managed:422896kB mlocked:0kB kernel_stack:6496kB pagetables:9904kB bounce:0kB free_pcp:348kB local_pcp:0kB free_cma:0kB
> > > > > >> [  728.287402] lowmem_reserve[]: 0 0 579 579
> > > > > >
> > > > > > So this is the only usable zone and you are close to the min watermark
> > > > > > which means that your system is under a serious memory pressure but not
> > > > > > yet under OOM for order-0 request. The situation is not great though
> > > > >
> > > > > Looking at lowmem_reserve above, wonder if 579 applies here? What does
> > > > > /proc/zoneinfo say?
> > >
> > >
> > > What is  lowmem_reserve[]: 0 0 579 579 ?
> >
> > This controls how much of memory from a lower zone you might an
> > allocation request for a higher zone consume. E.g. __GFP_HIGHMEM is
> > allowed to use both lowmem and highmem zones. It is preferable to use
> > highmem zone because other requests are not allowed to use it.
> >
> > Please see __zone_watermark_ok for more details.
> >
> >
> > > > This is GFP_KERNEL request essentially so there shouldn't be any lowmem
> > > > reserve here, no?
> > >
> > >
> > > Why only low 1G is accessible by kernel in 32-bit system ?
> 
> 
> 1G ivirtual or physical memory (I have 2GB of RAM) ?

virtual

> > https://www.kernel.org/doc/gorman/, https://lwn.net/Articles/75174/
> > and many more articles. In very short, the 32b virtual address space
> > is quite small and it has to cover both the users space and the
> > kernel. That is why we do split it into 3G reserved for userspace and 1G
> > for kernel. Kernel can only access its 1G portion directly everything
> > else has to be mapped explicitly (e.g. while data is copied).
> > Thanks Michal.
> 
> 
> >
> > > My system configuration is :-
> > > 3G/1G - vmsplit
> > > vmalloc = 480M (I think vmalloc size will set your highmem ?)
> >
> > No, vmalloc is part of the 1GB kernel adress space.
> 
> I read in one article , vmalloc end is fixed if you increase vmalloc
> size it decrease highmem. ?
> Total = lowmem + (vmalloc + high mem)

As the kernel is using vmalloc area _directly_ then it has to be a part
of the kernel address space - thus reducing the lowmem.
-- 
Michal Hocko
SUSE Labs

