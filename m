Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AAECAC46460
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 11:28:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 661082081C
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 11:28:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 661082081C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 00AA66B026C; Tue, 28 May 2019 07:28:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EFD7D6B026E; Tue, 28 May 2019 07:28:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC62E6B026F; Tue, 28 May 2019 07:28:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 912CF6B026C
	for <linux-mm@kvack.org>; Tue, 28 May 2019 07:28:43 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id d15so32661307edm.7
        for <linux-mm@kvack.org>; Tue, 28 May 2019 04:28:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=1B4uoHTNdfko9WmrNN2BpcoqYYUTL2Nv11TESTX+IZc=;
        b=ltUZiHGpEz4l7JRjvRJkqGQ21cHwXv8q8Wwq3RG4RLucMvutkZi0e/Vb2wF0FXiJfz
         bFvBFBXIL9yLioIiSXh1pb6HQGPI6lyqIH82Aeb2xW9IQU/yPo7z3Wy2koi8fOVjnGzM
         KZO5zppHG/LPy6vI6qUs2zxbq+QYr8MCYeEJCvFwjHqn253lPt6Or20LafU5KS5P/MmA
         of2Tf1kYh9ujkgqiZhLCYRUwb9w7D49JjxbP0Hcdq3//kCtDtyO3JV4DGJJv5sqciKcr
         MFKtHLE+iATxc/yeqKHwqYeJ1pHuooPqftub2zz++DfGgkN2gDqcn+FWsctWVOTFxL9d
         w/rA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWS4Hwl4gv66fGlmy3zWjQVtVTX1GrCAJZZJXyrVH3EtC9k5XHX
	wLiDfwv/+uKLBk1QXDGVL38td085w7YklF6REViahxuJla40D7h9GZf3t7B3621WAvbapj73S1p
	6if0bzONLJpTixPE6PFiPnPesMnKWJnWhNZhz1X5rYvgR4snMXou02MtkuJEssJE=
X-Received: by 2002:a50:9968:: with SMTP id l37mr127076202edb.143.1559042923146;
        Tue, 28 May 2019 04:28:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzPNRJIES8T8qwzJvCAUYCE6H22j8JETRk7n/hhvU5/Up3EO270sxh1qBjtxol6+WV02BQy
X-Received: by 2002:a50:9968:: with SMTP id l37mr127076136edb.143.1559042922323;
        Tue, 28 May 2019 04:28:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559042922; cv=none;
        d=google.com; s=arc-20160816;
        b=Ndu/yVKpLVv5IwS+mkcKDr2hWg6sb3bvUGliKA7O2GZqn55UY5emJ2X5kl2rMzrQqA
         u9jYHL8USzL9iz2FeyrttYR/lD5e6g2o1qPVZeRIOVTUof6Bq/DJNl8z5UezSL3Xn+l+
         5SXexljk/LPZRt0kxCfG3tDH44DYD9Ti9dxgKRLOlQoHyp3suZcoVesA45hM8+VDBhhp
         RDjZLw5n1JubXr9MYVQMOFRoAutb4nWpcKxQr4V6i60wZP8CID2rDPEKi4POazmlfXu8
         EuRN/oYZTXbMctHg3dFhUvFP0iZvqqsAhMI4nf9Fe6S3nDvLdDNf1OWohE7ebT1C0NiB
         1VCQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=1B4uoHTNdfko9WmrNN2BpcoqYYUTL2Nv11TESTX+IZc=;
        b=J7qIUK8jGpaNGK38dI6z6/o4kqjJlavFGqluQUKPmOf+OSZSQ8HsxNg8BK6bxr8p0c
         YOtkM0ShoClM/h1JfYE7lobRTlbMbqdzOlSOIjfNUf0QTVzqGaaC/4lBkWdcI1AKAfbX
         dvWoc+baY0++lDUgR+M7mbraerwhnvxs8G+4js9iJk1NAEcgTHbIaVRc/XIiw/ILvp06
         luCk/qUldOFJCi6acuXD6xN7y9A8uI+WoEyfR/QU9we3n50SeUnVk4wPnma29g/+Af8t
         HoMwhvnwFXYZiF7a9fMqWXLAaervmIltz6nssrqWTEdwk4RYlq4UZyXLXYzU+hLuwADI
         vxKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s27si9474959edm.307.2019.05.28.04.28.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 04:28:42 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 5C877AF1C;
	Tue, 28 May 2019 11:28:41 +0000 (UTC)
Date: Tue, 28 May 2019 13:28:40 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Daniel Colascione <dancol@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>,
	Linux API <linux-api@vger.kernel.org>
Subject: Re: [RFC 7/7] mm: madvise support MADV_ANONYMOUS_FILTER and
 MADV_FILE_FILTER
Message-ID: <20190528112840.GY1658@dhcp22.suse.cz>
References: <20190527124411.GC1658@dhcp22.suse.cz>
 <20190528032632.GF6879@google.com>
 <20190528062947.GL1658@dhcp22.suse.cz>
 <20190528081351.GA159710@google.com>
 <CAKOZuesnS6kBFX-PKJ3gvpkv8i-ysDOT2HE2Z12=vnnHQv0FDA@mail.gmail.com>
 <20190528084927.GB159710@google.com>
 <20190528090821.GU1658@dhcp22.suse.cz>
 <20190528103256.GA9199@google.com>
 <20190528104117.GW1658@dhcp22.suse.cz>
 <20190528111208.GA30365@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190528111208.GA30365@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 28-05-19 20:12:08, Minchan Kim wrote:
> On Tue, May 28, 2019 at 12:41:17PM +0200, Michal Hocko wrote:
> > On Tue 28-05-19 19:32:56, Minchan Kim wrote:
> > > On Tue, May 28, 2019 at 11:08:21AM +0200, Michal Hocko wrote:
> > > > On Tue 28-05-19 17:49:27, Minchan Kim wrote:
> > > > > On Tue, May 28, 2019 at 01:31:13AM -0700, Daniel Colascione wrote:
> > > > > > On Tue, May 28, 2019 at 1:14 AM Minchan Kim <minchan@kernel.org> wrote:
> > > > > > > if we went with the per vma fd approach then you would get this
> > > > > > > > feature automatically because map_files would refer to file backed
> > > > > > > > mappings while map_anon could refer only to anonymous mappings.
> > > > > > >
> > > > > > > The reason to add such filter option is to avoid the parsing overhead
> > > > > > > so map_anon wouldn't be helpful.
> > > > > > 
> > > > > > Without chiming on whether the filter option is a good idea, I'd like
> > > > > > to suggest that providing an efficient binary interfaces for pulling
> > > > > > memory map information out of processes.  Some single-system-call
> > > > > > method for retrieving a binary snapshot of a process's address space
> > > > > > complete with attributes (selectable, like statx?) for each VMA would
> > > > > > reduce complexity and increase performance in a variety of areas,
> > > > > > e.g., Android memory map debugging commands.
> > > > > 
> > > > > I agree it's the best we can get *generally*.
> > > > > Michal, any opinion?
> > > > 
> > > > I am not really sure this is directly related. I think the primary
> > > > question that we have to sort out first is whether we want to have
> > > > the remote madvise call process or vma fd based. This is an important
> > > > distinction wrt. usability. I have only seen pid vs. pidfd discussions
> > > > so far unfortunately.
> > > 
> > > With current usecase, it's per-process API with distinguishable anon/file
> > > but thought it could be easily extended later for each address range
> > > operation as userspace getting smarter with more information.
> > 
> > Never design user API based on a single usecase, please. The "easily
> > extended" part is by far not clear to me TBH. As I've already mentioned
> > several times, the synchronization model has to be thought through
> > carefuly before a remote process address range operation can be
> > implemented.
> 
> I agree with you that we shouldn't design API on single usecase but what
> you are concerning is actually not our usecase because we are resilient
> with the race since MADV_COLD|PAGEOUT is not destruptive.
> Actually, many hints are already racy in that the upcoming pattern would
> be different with the behavior you thought at the moment.

How come they are racy wrt address ranges? You would have to be in
multithreaded environment and then the onus of synchronization is on
threads. That model is quite clear. But we are talking about separate
processes and some of them might be even not aware of an external entity
tweaking their address space.

> If you are still concerning of address range synchronization, how about
> moving such hints to per-process level like prctl?
> Does it make sense to you?

No it doesn't. How is prctl any relevant to any address range
operations.

-- 
Michal Hocko
SUSE Labs

