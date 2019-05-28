Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE700C04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 12:06:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AD96F20B7C
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 12:06:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AD96F20B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2AE976B026E; Tue, 28 May 2019 08:06:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 25E8F6B026F; Tue, 28 May 2019 08:06:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0FFF36B0272; Tue, 28 May 2019 08:06:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B87D16B026E
	for <linux-mm@kvack.org>; Tue, 28 May 2019 08:06:17 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id z5so32815526edz.3
        for <linux-mm@kvack.org>; Tue, 28 May 2019 05:06:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=atALGkc/9d+3aESPAIxbybpgVzCALCCsfmt3kGF7Bas=;
        b=Z/oW2/TmJJ08b9d9BEKywHVyy4fYTuESO4SPR6xIyOXad7mBzYJNgCJF5/Dps7zn9i
         lReZ9000lCN0vCLi3cb/+MYa/+kfX4Rh31dG35nM5iCRzNovc8jmkqA0b1AyeCr/GEHA
         jaBrNVP64ndyYGwCj7EQvK/8l5ZCfxNcxDf7wFsjZAaS3OKBkEOqi/MBWFdzjZzCNH2W
         Awa7vFfzCgEbKK1DuvbXngEHtSfUlivcVxTYRRxbtG/qYxTuuR349Vu3AeBjGrU66q64
         Szpwh0N58mYS9jv07LO3eXOJA7abNI99e2Yqylh5//KAhi8WP1F+qMmJUvLGYqYdT+0z
         qIyQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUj/BibgWdbIRLVAfr16JK60K3QyA/zHu9aQqRhvR2MU3+37EvK
	T55E/xyOWWr7gjRDIDGIRD1Y7nAIyVkY0eDB4y0J30PoV7T8bOQffZODQYmwvb5NLYs881qX0YL
	hidwe03+OYvpcf0RWzssZ3/+MLQNNzF4JVO049HwA9ZzdobQeajJ8qvz/aQ//wm4=
X-Received: by 2002:a05:6402:180b:: with SMTP id g11mr129847072edy.268.1559045177281;
        Tue, 28 May 2019 05:06:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxLI9c1ayV7SrMohDMSjOoLAtfhFjv9JwRWZZxWPOkdVupwK4bbs3YLlgxtbjvMZas83dEq
X-Received: by 2002:a05:6402:180b:: with SMTP id g11mr129846976edy.268.1559045176441;
        Tue, 28 May 2019 05:06:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559045176; cv=none;
        d=google.com; s=arc-20160816;
        b=bGHs95HkB/y3FduKvjF2+OMAbf1zkEfrJLuPqgMnYBW90bgHXOVrPvEULXI2jkKdTt
         rYanaDjU6qBg4cpVUw0gQqIeiLs+dv0SdSejpRs2sC4BuR71wOP7LZUQL3WTzb2mEcQe
         vyYbV4WlEO4UeC6Y/5hH0dMjPqKmvuK97I4WCx30EobWrxasCTvVo5Xk+iD2oWhn2ADw
         aTeCyv1kMt4elPqPBNS7oP0P0gWpkebwHJWMSXuloaME2GkocV8riVLAZssukmTtW9Ip
         Ig6ncKZIW8R1YQcej9JlMJFMt7zXnda6zQuYWtH4bAa52wOr/limNO9jwPUrX5PLZ5+J
         Iu2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=atALGkc/9d+3aESPAIxbybpgVzCALCCsfmt3kGF7Bas=;
        b=MXps9qn1rRXJAHNd2HUcflZvnMwcFwZodf24qGhvoPjfaCiQ8nMcyQuVznGPTtWCC7
         d2cHQpzDIHkapXsstr7Saie3jFvx2lUwd0D4yMZiZcgSTT4Zjx+jSuQKAxo5ut/VirwP
         AKshztdSEhcw9v1BxAaS8PEijj32tEqeKaCB+RxlbmFRxFxmApdgXARpBY+U6FZN0YL+
         57Rl+ZCyQeWOjjDlqNpTo39lGYXvnZPuS9dPEltW7EAIEIg/Qv4INOjQGNl75dJ+J7Wn
         jjsZ4ic7s4QjHPQ0Mtv7UZbfGsF0QbVH85K+qDSbdFkG6JpYcW1f2buC/VCt6l7dvX8R
         0A0w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b51si4685640edc.153.2019.05.28.05.06.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 05:06:16 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 9D27DAEF9;
	Tue, 28 May 2019 12:06:15 +0000 (UTC)
Date: Tue, 28 May 2019 14:06:14 +0200
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
Message-ID: <20190528120614.GB1658@dhcp22.suse.cz>
References: <20190528062947.GL1658@dhcp22.suse.cz>
 <20190528081351.GA159710@google.com>
 <CAKOZuesnS6kBFX-PKJ3gvpkv8i-ysDOT2HE2Z12=vnnHQv0FDA@mail.gmail.com>
 <20190528084927.GB159710@google.com>
 <20190528090821.GU1658@dhcp22.suse.cz>
 <20190528103256.GA9199@google.com>
 <20190528104117.GW1658@dhcp22.suse.cz>
 <20190528111208.GA30365@google.com>
 <20190528112840.GY1658@dhcp22.suse.cz>
 <20190528114436.GB30365@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190528114436.GB30365@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 28-05-19 20:44:36, Minchan Kim wrote:
> On Tue, May 28, 2019 at 01:28:40PM +0200, Michal Hocko wrote:
> > On Tue 28-05-19 20:12:08, Minchan Kim wrote:
> > > On Tue, May 28, 2019 at 12:41:17PM +0200, Michal Hocko wrote:
> > > > On Tue 28-05-19 19:32:56, Minchan Kim wrote:
> > > > > On Tue, May 28, 2019 at 11:08:21AM +0200, Michal Hocko wrote:
> > > > > > On Tue 28-05-19 17:49:27, Minchan Kim wrote:
> > > > > > > On Tue, May 28, 2019 at 01:31:13AM -0700, Daniel Colascione wrote:
> > > > > > > > On Tue, May 28, 2019 at 1:14 AM Minchan Kim <minchan@kernel.org> wrote:
> > > > > > > > > if we went with the per vma fd approach then you would get this
> > > > > > > > > > feature automatically because map_files would refer to file backed
> > > > > > > > > > mappings while map_anon could refer only to anonymous mappings.
> > > > > > > > >
> > > > > > > > > The reason to add such filter option is to avoid the parsing overhead
> > > > > > > > > so map_anon wouldn't be helpful.
> > > > > > > > 
> > > > > > > > Without chiming on whether the filter option is a good idea, I'd like
> > > > > > > > to suggest that providing an efficient binary interfaces for pulling
> > > > > > > > memory map information out of processes.  Some single-system-call
> > > > > > > > method for retrieving a binary snapshot of a process's address space
> > > > > > > > complete with attributes (selectable, like statx?) for each VMA would
> > > > > > > > reduce complexity and increase performance in a variety of areas,
> > > > > > > > e.g., Android memory map debugging commands.
> > > > > > > 
> > > > > > > I agree it's the best we can get *generally*.
> > > > > > > Michal, any opinion?
> > > > > > 
> > > > > > I am not really sure this is directly related. I think the primary
> > > > > > question that we have to sort out first is whether we want to have
> > > > > > the remote madvise call process or vma fd based. This is an important
> > > > > > distinction wrt. usability. I have only seen pid vs. pidfd discussions
> > > > > > so far unfortunately.
> > > > > 
> > > > > With current usecase, it's per-process API with distinguishable anon/file
> > > > > but thought it could be easily extended later for each address range
> > > > > operation as userspace getting smarter with more information.
> > > > 
> > > > Never design user API based on a single usecase, please. The "easily
> > > > extended" part is by far not clear to me TBH. As I've already mentioned
> > > > several times, the synchronization model has to be thought through
> > > > carefuly before a remote process address range operation can be
> > > > implemented.
> > > 
> > > I agree with you that we shouldn't design API on single usecase but what
> > > you are concerning is actually not our usecase because we are resilient
> > > with the race since MADV_COLD|PAGEOUT is not destruptive.
> > > Actually, many hints are already racy in that the upcoming pattern would
> > > be different with the behavior you thought at the moment.
> > 
> > How come they are racy wrt address ranges? You would have to be in
> > multithreaded environment and then the onus of synchronization is on
> > threads. That model is quite clear. But we are talking about separate
> 
> Think about MADV_FREE. Allocator would think the chunk is worth to mark
> "freeable" but soon, user of the allocator asked the chunk - ie, it's not
> freeable any longer once user start to use it.

That is not a race in the address space, right. The underlying object
hasn't changed. It has been declared as freeable and since that moment
nobody can rely on the content because it might have been discarded.
Or put simply, the content is undefined. It is responsibility of the
madvise caller to make sure that the object is not in active use while
it is marking it.

> My point is that kinds of *hints* are always racy so any synchronization
> couldn't help a lot. That's why I want to restrict hints process_madvise
> supports as such kinds of non-destruptive one at next respin.

I agree that a non-destructive operations are safer against paralel
modifications because you just get a annoying and unexpected latency at
worst case. But we should discuss whether this assumption is sufficient
for further development. I am pretty sure once we open remote madvise
people will find usecases for destructive operations or even new madvise
modes we haven't heard of. What then?

> > processes and some of them might be even not aware of an external entity
> > tweaking their address space.
> > 
> > > If you are still concerning of address range synchronization, how about
> > > moving such hints to per-process level like prctl?
> > > Does it make sense to you?
> > 
> > No it doesn't. How is prctl any relevant to any address range
> > operations.
> 
> "whether we want to have the remote madvise call process or vma fd based."

Still not following. So you want to have a prctl (one of the worst API
we have along with ioctl) to tell the semantic? This sounds like a
terrible idea to me.
-- 
Michal Hocko
SUSE Labs

