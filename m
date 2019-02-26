Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 431C9C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 18:20:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C72CF20C01
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 18:20:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C72CF20C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F8988E0003; Tue, 26 Feb 2019 13:20:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A68F8E0001; Tue, 26 Feb 2019 13:20:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 395F38E0003; Tue, 26 Feb 2019 13:20:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id D67A98E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 13:20:09 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id d31so5820795eda.1
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 10:20:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ulR1z8Icbp9hBEZRteavqKxz+nYkOVC2eBJ4G8ARXRE=;
        b=REOPnNusMT840Psjld1Owvj2rCulVYPxJsir9bjOaavsNlyosFryugrBnmhPjqUg6w
         WiCUL7AL1umU4M7Vi+AVpGFbW2pyJ4LPbA5Si8Ws4lgf0SYtBQQl5nCH00AQRQ8w/tEr
         Kk5DS0c8ALXSw3Y37wjAuT/5/G3pym022ns5Yfkplpf4K/AtpLfejm5hCLApUUg+/kU+
         YgTWNlLgpZVnoq8UwwhtEqEAECcOLdCzqDIZmgX0g/tTVMcLUB4wTpY7w80CqClzo5QG
         VU0TwCZj/eLRxa32N5b2KLvkHAFyERckQ4RZLpScinsDB2MIB7l9co76974YKhn3Oxpo
         7gqg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAubKt5p2MMrIVLvLMoPrNKvA6Xbjd5Hzyj+AQZgnjn9p1Mzqnxfh
	1VetHoq1Vaw4cpjTcwtOFrepNXinjQZkb1b9Q3Mgu97KkrEGREXKHk/MzlNYtPZBGMgI8l1TDH8
	LetEQ9TkkQdWVqfWa13WSQbhs3+dEr9NDoCdfST1CQ5VqWQWz+Ibb6aQ31onA3/8=
X-Received: by 2002:a50:9622:: with SMTP id y31mr20543062eda.248.1551205209430;
        Tue, 26 Feb 2019 10:20:09 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZWYq2nmYk25S5VMerHo2smAfoZT5vnmCPdp5O7exbpRQjpV28sCqGOH3/FzilrvttDuH6l
X-Received: by 2002:a50:9622:: with SMTP id y31mr20543022eda.248.1551205208624;
        Tue, 26 Feb 2019 10:20:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551205208; cv=none;
        d=google.com; s=arc-20160816;
        b=GjbKkMd2b0ZMvlYV0YGlN+b50Z/gAN+Tf0TIfL8Mwif7l8onjgu6uZCyMB5rOSJYV1
         WbpXK5Z7euTIFhZBnwFNWg5KkcNSyv5L334XNDdWRp6lz4wsAWr54KZBnkGk7nh0JLkp
         fM5AZEdxVl0dPVZY++G0t9Sv+0ro/Maftqbs2xLTfDNMYCv1KEMKhq6NFoCLA/AsYaSy
         3QCzlG3aehyGGFG6qBVmYcU1nQXRzS/LPbMl6TpmF7OAWfDVwhD23Cr46cgrO/w4TtWj
         QvgvH0q1imluK1/2sT5QtqdwIwNGea7BVi47iIKNQCbrxXJgQzd84lgJzopziFDdjgOz
         TQLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ulR1z8Icbp9hBEZRteavqKxz+nYkOVC2eBJ4G8ARXRE=;
        b=VO1tx8//ZoSKuza9QN34CFvx+EknRAAUyhpn+m6oP0uoPEcHhBoKexkKiwvlLwc2J6
         Fqh3HpI/wrYnnuEhNVUYQG+V/6Eg2e6tgtFlEK1Zn5l4LH7Uhj/J8+hZeaFmBhG8Tylq
         CBVQItyI7VByzRnSfvnl/iE2hYNhjgt1nvuT3BsoY6n+NzS9s4FzO+H8btuXpfYLGUuw
         8ERc4yxBvagc0mOYN1nD4i0OLIaTQFyi7BDgqLL3zvKmhn57VWcgncJoE1DtkUiWyaGq
         B0fz/lt6M53dAtdtL1Hd/TrlySvOxR1tWCRRYOLPPujSyuLKKoRQpcNKy0TwACqiTnmQ
         Bo4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e2si626249ejc.314.2019.02.26.10.20.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 10:20:08 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 00E02AD05;
	Tue, 26 Feb 2019 18:20:07 +0000 (UTC)
Date: Tue, 26 Feb 2019 19:20:07 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/hotplug: fix an imbalance with DEBUG_PAGEALLOC
Message-ID: <20190226182007.GH10588@dhcp22.suse.cz>
References: <20190225191710.48131-1-cai@lca.pw>
 <20190226123521.GZ10588@dhcp22.suse.cz>
 <4d4d3140-6d83-6d22-efdb-370351023aea@lca.pw>
 <20190226142352.GC10588@dhcp22.suse.cz>
 <1551203585.6911.47.camel@lca.pw>
 <20190226181648.GG10588@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190226181648.GG10588@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 26-02-19 19:16:48, Michal Hocko wrote:
> On Tue 26-02-19 12:53:05, Qian Cai wrote:
> > On Tue, 2019-02-26 at 15:23 +0100, Michal Hocko wrote:
> > > On Tue 26-02-19 09:16:30, Qian Cai wrote:
> > > > 
> > > > 
> > > > On 2/26/19 7:35 AM, Michal Hocko wrote:
> > > > > On Mon 25-02-19 14:17:10, Qian Cai wrote:
> > > > > > When onlining memory pages, it calls kernel_unmap_linear_page(),
> > > > > > However, it does not call kernel_map_linear_page() while offlining
> > > > > > memory pages. As the result, it triggers a panic below while onlining on
> > > > > > ppc64le as it checks if the pages are mapped before unmapping,
> > > > > > Therefore, let it call kernel_map_linear_page() when setting all pages
> > > > > > as reserved.
> > > > > 
> > > > > This really begs for much more explanation. All the pages should be
> > > > > unmapped as they get freed AFAIR. So why do we need a special handing
> > > > > here when this path only offlines free pages?
> > > > > 
> > > > 
> > > > It sounds like this is exact the point to explain the imbalance. When
> > > > offlining,
> > > > every page has already been unmapped and marked reserved. When onlining, it
> > > > tries to free those reserved pages via __online_page_free(). Since those
> > > > pages
> > > > are order 0, it goes free_unref_page() which in-turn call
> > > > kernel_unmap_linear_page() again without been mapped first.
> > > 
> > > How is this any different from an initial page being freed to the
> > > allocator during the boot?
> > > 
> > 
> > As least for IBM POWER8, it does this during the boot,
> > 
> > early_setup
> >   early_init_mmu
> >     harsh__early_init_mmu
> >       htab_initialize [1]
> >         htab_bolt_mapping [2]
> > 
> > where it effectively map all memblock regions just like
> > kernel_map_linear_page(), so later mem_init() -> memblock_free_all() will unmap
> > them just fine.
> > 
> > [1]
> > for_each_memblock(memory, reg) {
> > 	base = (unsigned long)__va(reg->base);
> > 	size = reg->size;
> > 
> > 	DBG("creating mapping for region: %lx..%lx (prot: %lx)\n",
> > 		base, size, prot);
> > 
> > 	BUG_ON(htab_bolt_mapping(base, base + size, __pa(base),
> > 		prot, mmu_linear_psize, mmu_kernel_ssize));
> > 	}
> > 
> > [2] linear_map_hash_slots[paddr >> PAGE_SHIFT] = ret | 0x80;
> 
> Thanks for the clarification. I would have expected that there is a
> generic path to do kernel_map_pages from an appropriate place. I am also
> wondering whether blowing up is actually the right thing to do. Is the
> ppc specific code correct? Isn't your patch simply working around a
> bogus condition?

Btw. what happens if the offlined pfn range is removed completely? Is
the range still mapped? What kind of consequences does this have?
Also when does this tweak happens on a completely new hotplugged memory
range?
-- 
Michal Hocko
SUSE Labs

