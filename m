Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54FB1C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 10:28:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 173F220B1F
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 10:28:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 173F220B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B27906B0010; Tue,  6 Aug 2019 06:28:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD6E16B0266; Tue,  6 Aug 2019 06:28:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9C58F6B0269; Tue,  6 Aug 2019 06:28:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4DA5A6B0010
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 06:28:49 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b12so53557651eds.14
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 03:28:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ha5GFA2SGTAUQ11Vm2BkOP3ESRMQ3aIntpZLWjjK6Pc=;
        b=Dg8axoyWicawvezPKuWURIXO/L9G28Gn3f9RvxV34R5FeiOKoElIIDSX3KhFTGTWMR
         lQHyt5E7bAvOkhT7IpbP068n7hdF28GqsML7GhIWSDP2I1xfWPqWhWakzrQkXKQIuJST
         ResXeOOIE3y2yWZwQu3Xty2hfldfieUxOZ1zHMGaseDJECA07MH+e/ypyutUDdYTY9Dq
         DpvHVE7JcFhzAs9iDbejbWI+7DM+qDELz3XGHccpaxsgkrVMyf0eIHgIVKgF8mpGhlO4
         J739UjPTJCXP46QRf+lHCOnuireB0iB37xLj7oKOrZ/zTvk+R072OSS8jq2I1xEKnZ+r
         /F8w==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVJNMHxdsiYP0AzFG3C1tS7ErXDv2efMdacJV7smIV6piN6mFyi
	qnHPf5DBnEWFcOq9Nqgtj/pVUrJX8o2KwylDD+d4H92UqvMioM46WVz2mKeU0ZOm7RqkRmrgtHY
	oft1d76qdZQGumHZdcsgfzTt9NhaJhxfBNTdo2bhujreKz9CmuofIvjxG4M2IUzg=
X-Received: by 2002:a17:906:30d9:: with SMTP id b25mr2297391ejb.55.1565087328878;
        Tue, 06 Aug 2019 03:28:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzGQLFrOTDmJwlgxf8Yss36XzcQ9nQhAWCf0EhTU81k5LuJatcSHHhOEe1QAvy8m5CSjDnK
X-Received: by 2002:a17:906:30d9:: with SMTP id b25mr2297327ejb.55.1565087327934;
        Tue, 06 Aug 2019 03:28:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565087327; cv=none;
        d=google.com; s=arc-20160816;
        b=zdEjGlxr3kKcFvCa6/5OunzzEbBAFDiUl/PjBQp1S9NHuOmagI9pjOwvlI/vUNNnWU
         RbIsgXPGzXPXGkjxYUauuqpOuYRz6KhMMHFskl+EK1sbjgPPapqywJo+rhF1FfzWLKgg
         IxlrtH+OL9RDCuXhkbn4CR7IPcYUNMQmZCRA58XAJ5c0tob/W7Ue7k1aZokJ9eW8cuvx
         StlXa0TiHLcXRzB2VYNJ2JPvmin8XAfzhlPLprzSJBoFiRfaOyfou1oU8YheMFd4SpOV
         vQxnqDssHA7CCgOCadVkXYbYP8J8BFzw6DVdndEQKiR5/GVneKHn3NqrjZX/nRtcRdXB
         OeMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ha5GFA2SGTAUQ11Vm2BkOP3ESRMQ3aIntpZLWjjK6Pc=;
        b=IYwjCy2PabziqWBgNdNcZ7BKvb/xQIlA21xjHNp4gLrLLj0iTR/4DDRq0kgOKnacnw
         gj3MzTXYwS5j+kUzPInGNhdRp1R6Yq9DKVGb8Tfh/fJMxcG5iAAx1JnMnNmz3xi0vwdb
         tv0YvEaDlE+qR3CsKax5eQfvQ0wpUchGbpocWP2zTvC8jvNMPD7KFklRb5vFfGSMueXC
         loW/SGLMcrmRNXvtnzg4nxdW26jTVrUaskDtG9rAfCWp7vatWT/wkhgfVod+duNmyaPj
         S44P+O/Cpe/B2unUqK/IOvvPuDB91o+CnBMhHESdswAz/3LySEGr4wrFddO8ZxBf6yt+
         ZD9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g15si27026660ejm.175.2019.08.06.03.28.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 03:28:47 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id EEB04AF38;
	Tue,  6 Aug 2019 10:28:46 +0000 (UTC)
Date: Tue, 6 Aug 2019 12:28:45 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Mel Gorman <mgorman@techsingularity.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>,
	Daniel Jordan <daniel.m.jordan@oracle.com>,
	Christoph Lameter <cl@linux.com>,
	Yafang Shao <shaoyafang@didiglobal.com>
Subject: Re: [PATCH v2] mm/vmscan: shrink slab in node reclaim
Message-ID: <20190806102845.GP11812@dhcp22.suse.cz>
References: <1565075940-23121-1-git-send-email-laoar.shao@gmail.com>
 <20190806073525.GC11812@dhcp22.suse.cz>
 <20190806074137.GE11812@dhcp22.suse.cz>
 <CALOAHbBNV9BNmGhnV-HXOdx9QfArLHqBHsBe0cm-gxsGVSoenw@mail.gmail.com>
 <20190806090516.GM11812@dhcp22.suse.cz>
 <CALOAHbDO5qmqKt8YmCkTPhh+m34RA+ahgYVgiLx1RSOJ-gM4Dw@mail.gmail.com>
 <20190806092531.GN11812@dhcp22.suse.cz>
 <20190806095028.GG2739@techsingularity.net>
 <CALOAHbAwSevM9rpReKzJUhwoZrz_FdbBzSgRtkUfWe9BMGxWJA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALOAHbAwSevM9rpReKzJUhwoZrz_FdbBzSgRtkUfWe9BMGxWJA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 06-08-19 17:54:02, Yafang Shao wrote:
> On Tue, Aug 6, 2019 at 5:50 PM Mel Gorman <mgorman@techsingularity.net> wrote:
> >
> > On Tue, Aug 06, 2019 at 11:25:31AM +0200, Michal Hocko wrote:
> > > On Tue 06-08-19 17:15:05, Yafang Shao wrote:
> > > > On Tue, Aug 6, 2019 at 5:05 PM Michal Hocko <mhocko@kernel.org> wrote:
> > > [...]
> > > > > > As you said, the direct reclaim path set it to 1, but the
> > > > > > __node_reclaim() forgot to process may_shrink_slab.
> > > > >
> > > > > OK, I am blind obviously. Sorry about that. Anyway, why cannot we simply
> > > > > get back to the original behavior by setting may_shrink_slab in that
> > > > > path as well?
> > > >
> > > > You mean do it as the commit 0ff38490c836 did  before ?
> > > > I haven't check in which commit the shrink_slab() is removed from
> > >
> > > What I've had in mind was essentially this:
> > >
> > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > index 7889f583ced9..8011288a80e2 100644
> > > --- a/mm/vmscan.c
> > > +++ b/mm/vmscan.c
> > > @@ -4088,6 +4093,7 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
> > >               .may_unmap = !!(node_reclaim_mode & RECLAIM_UNMAP),
> > >               .may_swap = 1,
> > >               .reclaim_idx = gfp_zone(gfp_mask),
> > > +             .may_shrinkslab = 1;
> > >       };
> > >
> > >       trace_mm_vmscan_node_reclaim_begin(pgdat->node_id, order,
> > >
> > > shrink_node path already does shrink slab when the flag allows that. In
> > > other words get us back to before 1c30844d2dfe because that has clearly
> > > changed the long term node reclaim behavior just recently.
> >
> > I'd be fine with this change. It was not intentional to significantly
> > change the behaviour of node reclaim in that patch.
> >
> 
> But if we do it like this, there will be bug in the knob vm.min_slab_ratio.
> Right ?

Yes, and the answer for that is a question why do we even care? Which
real life workload does suffer from the of min_slab_ratio misbehavior.
Also it is much more preferred to fix an obvious bug/omission which
lack of may_shrinkslab in node reclaim seem to be than a larger rewrite
with a harder to see changes.

Really, I wouldn't be opposing normally but node_reclaim is an odd ball
rarely used and changing its behavior based on some trivial testing
doesn't sound very convincing to me.

-- 
Michal Hocko
SUSE Labs

