Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9616DC433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 09:05:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4818E208C3
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 09:05:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4818E208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D12C66B0275; Tue,  6 Aug 2019 05:05:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CC2966B0276; Tue,  6 Aug 2019 05:05:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B8ADD6B0277; Tue,  6 Aug 2019 05:05:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6C47B6B0275
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 05:05:20 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id n3so53374032edr.8
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 02:05:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=RA8PqlMouB2qG1krIkMVaqM6fr3aHeFON9RrYFoYIdU=;
        b=eaJs6KrqTABmAT6eLKpMvPOGW1Hy1l+mMvnUXn1KAKucMPLJ3A6FAE4lm1+36Y+uWm
         +u7hknZJTkjDlUYl1o6nMlz1CL72GzpCzqxEm816j/5ufABrkBg33A29fU3A4BJb0NnS
         64d9r+TwiOaqowHN5UY69tKzjV7chSSgypC1RN1KrGACdWz96aXYkVRBrR2hAE/QW10s
         ByIDKnUtehYIaHcTro8wv7PYoteEBT5OZyP7uskUhQaT+aULxfdcABFJlVXyX/BFcte0
         uFPLfEhzz9cNteW1VjEA3bw20VVDL0tC28OKLDTAeHuKSYISuBYRgH0IIWn89UHdJJgA
         77Ew==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVa7bcAG/z70Zg6N5Nzl7nBAgDmRu1RvXqwdQqElpCu06+NqLfG
	2C/FGef4UFVpgJ4ia8ApLBZwT3IQbvRZC/B6wK7zdsBqKoSOgYX0RvbzwPH2QBbQkk9iTpJRP6S
	MhadeMpVA9Qc4t+CBcr1XQNPr9rO/Yq169rGpabdYZUqKP3miC5fGF096hjXfIsA=
X-Received: by 2002:a17:906:af86:: with SMTP id mj6mr2085772ejb.157.1565082320010;
        Tue, 06 Aug 2019 02:05:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzdmW3u6LwTJv7jJoNPokjtpJlNGqURXRm2yWRWu1VKNVgPXiog2v3TQkJ85rddTtIF5fc4
X-Received: by 2002:a17:906:af86:: with SMTP id mj6mr2085728ejb.157.1565082319213;
        Tue, 06 Aug 2019 02:05:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565082319; cv=none;
        d=google.com; s=arc-20160816;
        b=Mko641ncf0Kcg6GSh0JOxqY2xa52EJpgKqnfyUlOYuhp7u5kTVnr9BqdXhx7+B77F3
         Fnsah8n4bsVTpN/pyywGsW5cO6Tdh1wmJEA8YjdluMhCFW5iKwEefR0FL0nFOUP39Gg3
         Egy4QbbcDfSxGedr2qkXlpioXovLn1mSv/WrkLQKWPiobXjXrS8OZ4LHIDlyfxHU+fK6
         6tsCivtKNMXd6W5S0JZZDh2FT0cm4V+T2q6Gst35OdLPXbvQI+lzWXcpfT2Hao0kI/ES
         aMAsxhvJPvWp0FwKL+6vMtKDSLsuFLNNQ09hE9VKzdJ6nz6AFUOU7O3RxlSEi8adKUH9
         2OGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=RA8PqlMouB2qG1krIkMVaqM6fr3aHeFON9RrYFoYIdU=;
        b=wXhAXMxqWaVOuvGR/p2lxfRaGIEE36D6Ad7SBOr+PZk91wHJ8RIHPOVmL06g6vfPzb
         4Oe/jBfWsM0zk3uerITzQaJAxD9s+LY5ctFXqq9RNqHsIEKqobdVC4juEzH3TIdHcjxc
         mqLALqqWZcovgdnRs6GPWXi4o7Mf81mWXfFGJd8F2upE2IWJSF8f/vXJJrze039yBKjn
         HrF0GNcIaO1aP8pUOGQg7Njhoay32tCKwCiBUtxSMN67tHSlJZV6FWMh0w7mboUhYAos
         DNF2TEWq0OlJ0pZkOa4VrYQ1J+RJ/0VwSQExcW+ruCtah10PjeVeqnf+Rc/ZSF5v0hBQ
         mFmA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i3si30071253eda.107.2019.08.06.02.05.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 02:05:19 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 57322AE1C;
	Tue,  6 Aug 2019 09:05:18 +0000 (UTC)
Date: Tue, 6 Aug 2019 11:05:16 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>,
	Daniel Jordan <daniel.m.jordan@oracle.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Christoph Lameter <cl@linux.com>,
	Yafang Shao <shaoyafang@didiglobal.com>
Subject: Re: [PATCH v2] mm/vmscan: shrink slab in node reclaim
Message-ID: <20190806090516.GM11812@dhcp22.suse.cz>
References: <1565075940-23121-1-git-send-email-laoar.shao@gmail.com>
 <20190806073525.GC11812@dhcp22.suse.cz>
 <20190806074137.GE11812@dhcp22.suse.cz>
 <CALOAHbBNV9BNmGhnV-HXOdx9QfArLHqBHsBe0cm-gxsGVSoenw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALOAHbBNV9BNmGhnV-HXOdx9QfArLHqBHsBe0cm-gxsGVSoenw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 06-08-19 16:57:22, Yafang Shao wrote:
> On Tue, Aug 6, 2019 at 3:41 PM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Tue 06-08-19 09:35:25, Michal Hocko wrote:
> > > On Tue 06-08-19 03:19:00, Yafang Shao wrote:
> > > > In the node reclaim, may_shrinkslab is 0 by default,
> > > > hence shrink_slab will never be performed in it.
> > > > While shrik_slab should be performed if the relcaimable slab is over
> > > > min slab limit.
> > > >
> > > > Add scan_control::no_pagecache so shrink_node can decide to reclaim page
> > > > cache, slab, or both as dictated by min_unmapped_pages and min_slab_pages.
> > > > shrink_node will do at least one of the two because otherwise node_reclaim
> > > > returns early.
> > > >
> > > > __node_reclaim can detect when enough slab has been reclaimed because
> > > > sc.reclaim_state.reclaimed_slab will tell us how many pages are
> > > > reclaimed in shrink slab.
> > > >
> > > > This issue is very easy to produce, first you continuously cat a random
> > > > non-exist file to produce more and more dentry, then you read big file
> > > > to produce page cache. And finally you will find that the denty will
> > > > never be shrunk in node reclaim (they can only be shrunk in kswapd until
> > > > the watermark is reached).
> > > >
> > > > Regarding vm.zone_reclaim_mode, we always set it to zero to disable node
> > > > reclaim. Someone may prefer to enable it if their different workloads work
> > > > on different nodes.
> > >
> > > Considering that this is a long term behavior of a rarely used node
> > > reclaim I would rather not touch it unless some _real_ workload suffers
> > > from this behavior. Or is there any reason to fix this even though there
> > > is no evidence of real workloads suffering from the current behavior?
> >
> > I have only now noticed that you have added
> > Fixes: 1c30844d2dfe ("mm: reclaim small amounts of memory when an external fragmentation event occurs")
> >
> > could you be more specific how that commit introduced a bug in the node
> > reclaim? It has introduced may_shrink_slab but the direct reclaim seems
> > to set it to 1.
> 
> As you said, the direct reclaim path set it to 1, but the
> __node_reclaim() forgot to process may_shrink_slab.

OK, I am blind obviously. Sorry about that. Anyway, why cannot we simply
get back to the original behavior by setting may_shrink_slab in that
path as well?
-- 
Michal Hocko
SUSE Labs

