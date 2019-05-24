Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E998EC072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 12:30:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA4A120863
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 12:30:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA4A120863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C4036B0003; Fri, 24 May 2019 08:30:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 375116B0006; Fri, 24 May 2019 08:30:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 28B266B0007; Fri, 24 May 2019 08:30:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id CD5E46B0003
	for <linux-mm@kvack.org>; Fri, 24 May 2019 08:30:51 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id h2so13960237edi.13
        for <linux-mm@kvack.org>; Fri, 24 May 2019 05:30:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=fFS+WZ4t7rQXh2Ru0Wt6QNmNrJwe117QMLfy+/zFpWY=;
        b=ezuw+BGsMm1V8R69W0XrV/+jLQl9OKw+mUyOqh6+8L8rDqPhRb+pERGD6hUv4HdXHv
         RFMHyEC2XDoaY9XEWA5xvXHWabY1yl7BggGAZPSOoaJANuVGCnBIGikMinIzSwTioQJB
         DaSRYI4dg+LdXBGEXJKL8/f8QFcozeGRjQwG0zT3VtuGuZWhkECCQywnuEHRwnVdNCIT
         w65XxmDzLdlAqmJ3blhGX18lyiXJW29j/DIf6giQbLVRyPyKH52q+AXlTS1vniP97zex
         TARmdvIbjxwa+u8/sxib0BTBA2AU1oomRB5a2eO5VXYrhkbnIYsKyrB0oi45x4PmIVXL
         AE3w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.35 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAX/NoSlaKQGr7beIxQ+AGNqwN/65K41eNkVnjYEYiczRg4FgGKn
	gaAk4KmOLpbgH9EACouj+K4va4TtURXZ0mqbX4k6NtypLH8RvniFNQKvzEUZqSElMvRBbQy3uBh
	ZkT0UfgVDdfV6TkmotdmEwgqHVkfrHEtQkBKV8uEg9RUnQ2v4TNgwCzdfU90pMIbpDA==
X-Received: by 2002:a17:906:b2d3:: with SMTP id cf19mr6920393ejb.10.1558701051370;
        Fri, 24 May 2019 05:30:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqymG4UiNjxisQYDGEdI0dU6X4R7CQ860uyxiVgoic7Xny1Ktc9V4fS2NrZ6PcjrSO2gQOLF
X-Received: by 2002:a17:906:b2d3:: with SMTP id cf19mr6920215ejb.10.1558701049483;
        Fri, 24 May 2019 05:30:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558701049; cv=none;
        d=google.com; s=arc-20160816;
        b=Gk1QYiKuObg9hgLhZX5OCpdGedZU+9kfCfBKOvAFDP6j/++jYl0NEcQaL1Od0INZ4b
         HtDl2at/SYc/JwuzmqtgeoQd0L40hWTbLmaNToyBTK31snhtDtP/W7CWf3DW3+tCba1S
         7JcCs91dzfKpfeUimN79J9sS/8CzI2Zybp0A1PELVCYBugOg5bx4pL2SQ5Pod1E2LXO1
         C44mwNZPEs0WI8133B+2DW0odIboSlfgh3ZD54ayr/4O9GyXdnei/YRwEBGZO8HHscwi
         pZQn34WshqKWBYBfewhphWiie3uW3OzKw+lfxSaAVP3LykFiFBsS6i9uV9v6XIVJ4rgV
         U44Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=fFS+WZ4t7rQXh2Ru0Wt6QNmNrJwe117QMLfy+/zFpWY=;
        b=Uzzs9ILUnTmYovA1nZiDInGx6ZVxyuSN+HNScH/DVSvlbfJQDK5iVZGKDVyiScxZsm
         mC0l/jFHRxPEis4E+g0hUIYJFhsCfYFKbLBS4ndQsMA42apdCKvJIkEQEuICZaTjQq9b
         3cXkgVR6tGwrsb9jBroYQD1tNRrf3SdQyhC40nNwivQ0whXz4a1Eo30w71P7VIBXlm3V
         VCy19dh00xo5bjGI97ciLtIZEW+ACALp1tw6BfJ/z1p39LdH9GR5PCqPU2WiOLoZ2hit
         PALlaBZB5PaCsxqwk1zyfIMTw9aR0XXfIZJCfPbO0tp4tWLql6cXi2h6FckBHd15598W
         7byA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.35 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id m20si690314ejb.67.2019.05.24.05.30.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 May 2019 05:30:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.35 as permitted sender) client-ip=81.17.249.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.35 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 19BF4F4005
	for <linux-mm@kvack.org>; Fri, 24 May 2019 12:30:49 +0000 (UTC)
Received: (qmail 27446 invoked from network); 24 May 2019 12:30:49 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 24 May 2019 12:30:48 -0000
Date: Fri, 24 May 2019 13:30:47 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Suzuki K Poulose <suzuki.poulose@arm.com>, linux-mm@kvack.org,
	akpm@linux-foundation.org, mhocko@suse.com, cai@lca.pw,
	linux-kernel@vger.kernel.org, marc.zyngier@arm.com,
	kvmarm@lists.cs.columbia.edu, kvm@vger.kernel.org
Subject: Re: mm/compaction: BUG: NULL pointer dereference
Message-ID: <20190524123047.GO18914@techsingularity.net>
References: <1558689619-16891-1-git-send-email-suzuki.poulose@arm.com>
 <cfddd75a-b302-5557-05b8-2b328bba27c8@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <cfddd75a-b302-5557-05b8-2b328bba27c8@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 24, 2019 at 04:26:16PM +0530, Anshuman Khandual wrote:
> 
> 
> On 05/24/2019 02:50 PM, Suzuki K Poulose wrote:
> > Hi,
> > 
> > We are hitting NULL pointer dereferences while running stress tests with KVM.
> > See splat [0]. The test is to spawn 100 VMs all doing standard debian
> > installation (Thanks to Marc's automated scripts, available here [1] ).
> > The problem has been reproduced with a better rate of success from 5.1-rc6
> > onwards.
> > 
> > The issue is only reproducible with swapping enabled and the entire
> > memory is used up, when swapping heavily. Also this issue is only reproducible
> > on only one server with 128GB, which has the following memory layout:
> > 
> > [32GB@4GB, hole , 96GB@544GB]
> > 
> > Here is my non-expert analysis of the issue so far.
> > 
> > Under extreme memory pressure, the kswapd could trigger reset_isolation_suitable()
> > to figure out the cached values for migrate/free pfn for a zone, by scanning through
> > the entire zone. On our server it does so in the range of [ 0x10_0000, 0xa00_0000 ],
> > with the following area of holes : [ 0x20_0000, 0x880_0000 ].
> > In the failing case, we end up setting the cached migrate pfn as : 0x508_0000, which
> > is right in the center of the zone pfn range. i.e ( 0x10_0000 + 0xa00_0000 ) / 2,
> > with reset_migrate = 0x88_4e00, reset_free = 0x10_0000.
> > 
> > Now these cached values are used by the fast_isolate_freepages() to find a pfn. However,
> > since we cant find anything during the search we fall back to using the page belonging
> > to the min_pfn (which is the migrate_pfn), without proper checks to see if that is valid
> > PFN or not. This is then passed on to fast_isolate_around() which tries to do :
> > set_pageblock_skip(page) on the page which blows up due to an NULL mem_section pointer.
> > 
> > The following patch seems to fix the issue for me, but I am not quite convinced that
> > it is the right fix. Thoughts ?
> > 
> > 
> > diff --git a/mm/compaction.c b/mm/compaction.c
> > index 9febc8c..9e1b9ac 100644
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -1399,7 +1399,7 @@ fast_isolate_freepages(struct compact_control *cc)
> >  				page = pfn_to_page(highest);
> >  				cc->free_pfn = highest;
> >  			} else {
> > -				if (cc->direct_compaction) {
> > +				if (cc->direct_compaction && pfn_valid(min_pfn)) {
> >  					page = pfn_to_page(min_pfn);
> 
> pfn_to_online_page() here would be better as it does not add pfn_valid() cost on
> architectures which does not subscribe to CONFIG_HOLES_IN_ZONE. But regardless if
> the compaction is trying to scan pfns in zone holes, then it should be avoided.

CONFIG_HOLES_IN_ZONE typically applies in special cases where an arch
punches holes within a section. As both do a section lookup, the cost is
similar but pfn_valid in general is less subtle in this case. Normally
pfn_valid_within is only ok when a pfn_valid check has been made on the
max_order aligned range as well as a zone boundary check. In this case,
it's much more straight-forward to leave it as pfn_valid.

-- 
Mel Gorman
SUSE Labs

