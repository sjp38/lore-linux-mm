Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E963C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 15:12:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E5DA82089E
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 15:12:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E5DA82089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C9BB6B0007; Tue,  6 Aug 2019 11:12:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 879D06B0008; Tue,  6 Aug 2019 11:12:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 790036B000A; Tue,  6 Aug 2019 11:12:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2B3036B0007
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 11:12:54 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id i9so54107907edr.13
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 08:12:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=a8F6IWt+yH5hIHKyiDiW3gMueBErBc7yXGi0lV+mARw=;
        b=HACUtL5Skvguld2kwuxV4GUGRfyj2FBePCz7yrwArKaQ83+gssQiJN3cGHI4+Ir2ea
         nBot5qK60uWwidiUtcMBSOHM+bfxlNZyIpPrO/O0gWvKy7QS8smY/M+LjfHVa6D6ng8i
         wMsXbMBK6u1WWJpmjeyFJ9+PVr/kOJvkw24HuXUO+lY/rK8Wo3BFjv5Qd5RsaMIZM3gh
         UHxwbKUiQLjbiLeVjgqYrBl8xyvkFZ+OpUkYbHyO/t3G53fDrTwwkqb76KqhqRrufjrP
         5jBG6gDATmc2+h4kEjt4Ie6DazyLkpAW3ZZIWq0m4bjjNuaqFcz2mB9U7m28Ta49TjXK
         09fA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWT++QLZpL4xMWBu3FqlEvX4nVWON+r/s9sQ4U6dfKgtIO0ugqx
	wlVHIH5WZ2/OHRtQRdo9yEOgEILXtdO3kmcx/nXwpZdJ3uR5FpKx9NtlNPdYUbtK6cfqbSCw6jf
	+Z9tELyw/DqM1ymL9fLlKGKSZOTLm/H3hEV4SdyEqK7RETkP+8xbKpLYp0td8/ik=
X-Received: by 2002:a50:b122:: with SMTP id k31mr4421097edd.204.1565104373703;
        Tue, 06 Aug 2019 08:12:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwvVQw9fQfJbSK74jyiI/FWFlvrhXdtk8LZ6T3qSngHJhjwb3h39qUZy1xDQoBbWTtLf0i1
X-Received: by 2002:a50:b122:: with SMTP id k31mr4421022edd.204.1565104372947;
        Tue, 06 Aug 2019 08:12:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565104372; cv=none;
        d=google.com; s=arc-20160816;
        b=Tg15YsI19ruZkofhiCnQqwNKbMkzaj5MbK1BwqaJ9i0gIbcJrl+msVpQsuijblDylz
         y27VRU83EZxCRG5W8fHwJD7KHOo2h+lkrw8Yl1HoRvgKr1Gg2jWK2LPpPYkavZdFGPvt
         0r774WJQQWl8EVKU3qqp4PtRYO3SdAFSGCkJl2ntoxMLp/txtH/OjRsSlYDpTQBAT2eo
         P54RWZiYc1qJsnnjm34OpOrTF810Jc3Hn1nSC/DFqlwVPD7sZp4SIcSWXqEvO3xr60Sb
         VYODhxg4z8Zl5JT66icDHt5w+Xu4+dng/3Z20UI1n2xPNi0EL2uxuy9WEo8jufDG4/F+
         ERJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=a8F6IWt+yH5hIHKyiDiW3gMueBErBc7yXGi0lV+mARw=;
        b=m4MUv1dA04uMKo9S4uFvKavFqQdl2us8uIFBav6EkwNV9npZyJV2zSFEu6UTzQQm2m
         olyrhiiJka2KpWLTt9doUnpaVwvFdABq0xde5zo7oQ8vis32Ba2LY2jOhH2H0gpz+t1e
         /cbuh6BuvG/HgFpgyzUgX+PMX6zIEwtyU4AtIBdIykLuuKG5uFhIowlzonAACNHEYgD0
         +cGuVDwphjosuhGQHKjq0mmP2kD1I8k41AIIJybFEfS9jDm2gFB6V32nsUCdERbsTxl8
         sNtT39GlqlMdlDBhMFfWEpKVEWcE7P4I8c1JH6Gwd88mqOCNDYJddO/8GVSLONOMv+3f
         LhUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cx18si27041302ejb.366.2019.08.06.08.12.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 08:12:52 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8B566AF4C;
	Tue,  6 Aug 2019 15:12:52 +0000 (UTC)
Date: Tue, 6 Aug 2019 17:12:51 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Pankaj Suryawanshi <pankajssuryawanshi@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, pankaj.suryawanshi@einfochips.com
Subject: Re: oom-killer
Message-ID: <20190806151251.GJ11812@dhcp22.suse.cz>
References: <CACDBo54Jbueeq1XbtbrFOeOEyF-Q4ipZJab8mB7+0cyK1Foqyw@mail.gmail.com>
 <20190805112437.GF7597@dhcp22.suse.cz>
 <0821a17d-1703-1b82-d850-30455e19e0c1@suse.cz>
 <20190805120525.GL7597@dhcp22.suse.cz>
 <CACDBo562xHy6McF5KRq3yngKqAm4a15FFKgbWkCTGQZ0pnJWgw@mail.gmail.com>
 <20190805201650.GT7597@dhcp22.suse.cz>
 <CACDBo54kBy_YBcXBzs1dOxQRg+TKFQox_aqqtB2dvL+mmusDVg@mail.gmail.com>
 <20190806150733.GH11812@dhcp22.suse.cz>
 <CACDBo54KihsV=8NLGZkTghTzb2p70WURF2L5op=fW7DGj_vJ1A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACDBo54KihsV=8NLGZkTghTzb2p70WURF2L5op=fW7DGj_vJ1A@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 06-08-19 20:39:22, Pankaj Suryawanshi wrote:
> On Tue, Aug 6, 2019 at 8:37 PM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Tue 06-08-19 20:24:03, Pankaj Suryawanshi wrote:
> > > On Tue, 6 Aug, 2019, 1:46 AM Michal Hocko, <mhocko@kernel.org> wrote:
> > > >
> > > > On Mon 05-08-19 21:04:53, Pankaj Suryawanshi wrote:
> > > > > On Mon, Aug 5, 2019 at 5:35 PM Michal Hocko <mhocko@kernel.org> wrote:
> > > > > >
> > > > > > On Mon 05-08-19 13:56:20, Vlastimil Babka wrote:
> > > > > > > On 8/5/19 1:24 PM, Michal Hocko wrote:
> > > > > > > >> [  727.954355] CPU: 0 PID: 56 Comm: kworker/u8:2 Tainted: P           O  4.14.65 #606
> > > > > > > > [...]
> > > > > > > >> [  728.029390] [<c034a094>] (oom_kill_process) from [<c034af24>] (out_of_memory+0x140/0x368)
> > > > > > > >> [  728.037569]  r10:00000001 r9:c12169bc r8:00000041 r7:c121e680 r6:c1216588 r5:dd347d7c > [  728.045392]  r4:d5737080
> > > > > > > >> [  728.047929] [<c034ade4>] (out_of_memory) from [<c03519ac>]  (__alloc_pages_nodemask+0x1178/0x124c)
> > > > > > > >> [  728.056798]  r7:c141e7d0 r6:c12166a4 r5:00000000 r4:00001155
> > > > > > > >> [  728.062460] [<c0350834>] (__alloc_pages_nodemask) from [<c021e9d4>] (copy_process.part.5+0x114/0x1a28)
> > > > > > > >> [  728.071764]  r10:00000000 r9:dd358000 r8:00000000 r7:c1447e08 r6:c1216588 r5:00808111
> > > > > > > >> [  728.079587]  r4:d1063c00
> > > > > > > >> [  728.082119] [<c021e8c0>] (copy_process.part.5) from [<c0220470>] (_do_fork+0xd0/0x464)
> > > > > > > >> [  728.090034]  r10:00000000 r9:00000000 r8:dd008400 r7:00000000 r6:c1216588 r5:d2d58ac0
> > > > > > > >> [  728.097857]  r4:00808111
> > > > > > > >
> > > > > > > > The call trace tells that this is a fork (of a usermodhlper but that is
> > > > > > > > not all that important.
> > > > > > > > [...]
> > > > > > > >> [  728.260031] DMA free:17960kB min:16384kB low:25664kB high:29760kB active_anon:3556kB inactive_anon:0kB active_file:280kB inactive_file:28kB unevictable:0kB writepending:0kB present:458752kB managed:422896kB mlocked:0kB kernel_stack:6496kB pagetables:9904kB bounce:0kB free_pcp:348kB local_pcp:0kB free_cma:0kB
> > > > > > > >> [  728.287402] lowmem_reserve[]: 0 0 579 579
> > > > > > > >
> > > > > > > > So this is the only usable zone and you are close to the min watermark
> > > > > > > > which means that your system is under a serious memory pressure but not
> > > > > > > > yet under OOM for order-0 request. The situation is not great though
> > > > > > >
> > > > > > > Looking at lowmem_reserve above, wonder if 579 applies here? What does
> > > > > > > /proc/zoneinfo say?
> > > > >
> > > > >
> > > > > What is  lowmem_reserve[]: 0 0 579 579 ?
> > > >
> > > > This controls how much of memory from a lower zone you might an
> > > > allocation request for a higher zone consume. E.g. __GFP_HIGHMEM is
> > > > allowed to use both lowmem and highmem zones. It is preferable to use
> > > > highmem zone because other requests are not allowed to use it.
> > > >
> > > > Please see __zone_watermark_ok for more details.
> > > >
> > > >
> > > > > > This is GFP_KERNEL request essentially so there shouldn't be any lowmem
> > > > > > reserve here, no?
> > > > >
> > > > >
> > > > > Why only low 1G is accessible by kernel in 32-bit system ?
> > >
> > >
> > > 1G ivirtual or physical memory (I have 2GB of RAM) ?
> >
> > virtual
> >
>  I have set 2G/2G still it works ?

It would reduce the amount of memory that userspace might use. It may
work for your particular case but the fundamental restriction is still
there.
-- 
Michal Hocko
SUSE Labs

