Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 123F8C76195
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 05:09:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA7C6208C0
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 05:09:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA7C6208C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 66EC86B0003; Wed, 17 Jul 2019 01:09:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 620218E0001; Wed, 17 Jul 2019 01:09:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 50D406B0006; Wed, 17 Jul 2019 01:09:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 012256B0003
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 01:09:35 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id a5so17259304edx.12
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 22:09:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=n/MzqC4UbhACDHotnX/xUX3tawzLCdAYAusB3iHEXws=;
        b=A75JWUFxGQyhGALgYz0N4dKsXPogn7THnaD/8+Uv0V7tNLTTJVttPmKsxT7dpVOD8y
         MvauCZkSkOasfjX3a4Icb+grzmcG9qkF6nvKorEH+vx9jVAFnhEE22nmeFp1OP1DHLdf
         aRMAVNeaNHmiri0oiyR7wLZ4L2PCSf6OGN9birbL/mr8pHWugRo6moAy6kj9qAE09NuK
         hEeqjjmncjz5FNJxIH4MSBiRg67Smtld/pMZ5QBpLFGPlqfBOgL0YjMNekXq6eLfWEvS
         rSD1SZ+1n2not6xQe6dbwIRB5Gcs3Ircb8egMYMVJ2Gtb2gqGJjht1grbBvelU6jKUL6
         +fiA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXHUk0/CeY+ioiMdaNhI2JhVK2ORsJ1/XPx71ruXx7cTvQfZ6Ep
	wAtT/zP2ryUZ6ClA1UFFpzPGmjjphMkPE7EhuJ+ZkxuS2N4poyv6R5ghbkd6F/HpOwAI3Kkbl/e
	XBclODOpS5ILdkh4b9w4IhnlaUmwTHtZiTRNdIcsH6L/Q5Dd/wdlYegQ7Z6DbpqU=
X-Received: by 2002:a17:906:1292:: with SMTP id k18mr29535689ejb.146.1563340174545;
        Tue, 16 Jul 2019 22:09:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxzc4x6gmX8qe0xfGdXOElF9jrPUq+hlZ4VCVG5gSnLH5DdL4UAepBIwJ9lKJ6cAc6b105F
X-Received: by 2002:a17:906:1292:: with SMTP id k18mr29535648ejb.146.1563340173799;
        Tue, 16 Jul 2019 22:09:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563340173; cv=none;
        d=google.com; s=arc-20160816;
        b=IpVAd2Vm7yvy+UkjFBu8EcQ/kuCNtpu7Gsh7UChFIbYUnY7hae6l9VnksfZzpKTtVA
         YQj4UT0vmoB6IoSVo2Tocu3luB7xTLKI3kSiIRuzTJOezuXv+vm4HAASmE/++M4U+hVM
         zQec3rAqVzf7BOyq0hGmv5TGph7rdm5g6B+fIPKn8qpPls+OGhNi1cpQUaTM+uh5L6mV
         4xonCqpxOai5cdzSRnjayhfxrs+6UoGIkUMhYYuzBm0Tvqn8t3TNAMRjt2ArXEqKblZt
         ZnrMebOBnMd0rUf2FKyzdW/R3o62kzc5t1a4FcQtrcPtogSIYinfEcf0Gjs6jE+C3OMA
         UKHw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=n/MzqC4UbhACDHotnX/xUX3tawzLCdAYAusB3iHEXws=;
        b=zLeYQJ11Gxc86YOGpVZrHbcrsiC1mazFQNChvFOgpwuOAw16fVnmw5FavUbxDwOFho
         kd/zdQIkJEGVTY7VO/P1i3J+cHhpR2vYpdpTnrdByfSco+U2P++uTtmhberXO+CGNfPD
         tqPmiE315QdMFendZaicjZ3nS8uXgfzdVwDD+UQ/1QpRxkHG+MQmm9bOPP7hQ/rg3qqK
         wHTeinZ98bZHCxBVjuFrz0dzJbm8sqIthZON/r8VBZtRfQxpapswB04aK7bpoSxZTqUK
         pNRLF0J5eoBEyJJExjNz5rRzrA1bTKn52BpXp5UdSUQpQ0koQMGmNU5eH9keVvTNXe6Z
         ADqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x54si13863992edd.148.2019.07.16.22.09.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 22:09:33 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 679C6AC68;
	Wed, 17 Jul 2019 05:09:33 +0000 (UTC)
Date: Wed, 17 Jul 2019 07:09:32 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: catalin.marinas@arm.com, dvyukov@google.com, rientjes@google.com,
	willy@infradead.org, cai@lca.pw, akpm@linux-foundation.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] Revert "kmemleak: allow to coexist with fault injection"
Message-ID: <20190717050932.GB16284@dhcp22.suse.cz>
References: <1563299431-111710-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190717050711.GA16284@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190717050711.GA16284@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 17-07-19 07:07:11, Michal Hocko wrote:
> On Wed 17-07-19 01:50:31, Yang Shi wrote:
> > When running ltp's oom test with kmemleak enabled, the below warning was
> > triggerred since kernel detects __GFP_NOFAIL & ~__GFP_DIRECT_RECLAIM is
> > passed in:
> > 
> > WARNING: CPU: 105 PID: 2138 at mm/page_alloc.c:4608 __alloc_pages_nodemask+0x1c31/0x1d50
> > Modules linked in: loop dax_pmem dax_pmem_core ip_tables x_tables xfs virtio_net net_failover virtio_blk failover ata_generic virtio_pci virtio_ring virtio libata
> > CPU: 105 PID: 2138 Comm: oom01 Not tainted 5.2.0-next-20190710+ #7
> > Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.10.2-0-g5f4c7b1-prebuilt.qemu-project.org 04/01/2014
> > RIP: 0010:__alloc_pages_nodemask+0x1c31/0x1d50
> > ...
> >  kmemleak_alloc+0x4e/0xb0
> >  kmem_cache_alloc+0x2a7/0x3e0
> >  ? __kmalloc+0x1d6/0x470
> >  ? ___might_sleep+0x9c/0x170
> >  ? mempool_alloc+0x2b0/0x2b0
> >  mempool_alloc_slab+0x2d/0x40
> >  mempool_alloc+0x118/0x2b0
> >  ? __kasan_check_read+0x11/0x20
> >  ? mempool_resize+0x390/0x390
> >  ? lock_downgrade+0x3c0/0x3c0
> >  bio_alloc_bioset+0x19d/0x350
> >  ? __swap_duplicate+0x161/0x240
> >  ? bvec_alloc+0x1b0/0x1b0
> >  ? do_raw_spin_unlock+0xa8/0x140
> >  ? _raw_spin_unlock+0x27/0x40
> >  get_swap_bio+0x80/0x230
> >  ? __x64_sys_madvise+0x50/0x50
> >  ? end_swap_bio_read+0x310/0x310
> >  ? __kasan_check_read+0x11/0x20
> >  ? check_chain_key+0x24e/0x300
> >  ? bdev_write_page+0x55/0x130
> >  __swap_writepage+0x5ff/0xb20
> > 
> > The mempool_alloc_slab() clears __GFP_DIRECT_RECLAIM, however kmemleak has
> > __GFP_NOFAIL set all the time due to commit
> > d9570ee3bd1d4f20ce63485f5ef05663866fe6c0 ("kmemleak: allow to coexist
> > with fault injection").  But, it doesn't make any sense to have
> > __GFP_NOFAIL and ~__GFP_DIRECT_RECLAIM specified at the same time.
> > 
> > According to the discussion on the mailing list, the commit should be
> > reverted for short term solution.  Catalin Marinas would follow up with a better
> > solution for longer term.
> > 
> > The failure rate of kmemleak metadata allocation may increase in some
> > circumstances, but this should be expected side effect.
> > 
> > Suggested-by: Catalin Marinas <catalin.marinas@arm.com>
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: Dmitry Vyukov <dvyukov@google.com>
> > Cc: David Rientjes <rientjes@google.com>
> > Cc: Matthew Wilcox <willy@infradead.org>
> > Cc: Qian Cai <cai@lca.pw>
> > Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> 
> I forgot
> Acked-by: Michal Hocko <mhocko@suse.com>

Btw. If this leads to early allocation failures too often then
dropping __GFP_NORETRY should help for now until a better solution is
available. It could lead to OOM killer invocation which is probably
the reason why it has been added but probably better than completely
disabling kmemleak altogether. Up to Catalin I guess.
 
> > ---
> >  mm/kmemleak.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/mm/kmemleak.c b/mm/kmemleak.c
> > index 9dd581d..884a5e3 100644
> > --- a/mm/kmemleak.c
> > +++ b/mm/kmemleak.c
> > @@ -114,7 +114,7 @@
> >  /* GFP bitmask for kmemleak internal allocations */
> >  #define gfp_kmemleak_mask(gfp)	(((gfp) & (GFP_KERNEL | GFP_ATOMIC)) | \
> >  				 __GFP_NORETRY | __GFP_NOMEMALLOC | \
> > -				 __GFP_NOWARN | __GFP_NOFAIL)
> > +				 __GFP_NOWARN)
> >  
> >  /* scanning area inside a memory block */
> >  struct kmemleak_scan_area {
> > -- 
> > 1.8.3.1
> 
> -- 
> Michal Hocko
> SUSE Labs

-- 
Michal Hocko
SUSE Labs

