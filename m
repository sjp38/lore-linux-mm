Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC101C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 06:57:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7089F24DB7
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 06:57:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7089F24DB7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0E8FC6B000D; Tue,  4 Jun 2019 02:57:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 09A046B0266; Tue,  4 Jun 2019 02:57:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ECAC46B0269; Tue,  4 Jun 2019 02:57:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9BF316B000D
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 02:57:00 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y24so31084747edb.1
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 23:57:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=1GQmtwGpoklobeThBbBuDIsNFjH1FXyEVH8SqLexiJ4=;
        b=ZME16oQgORkG6Mm2sVLWXUkwrym8jvjFe6dEvo4WUOyk1E31R9G28E+O3NI+03UfKK
         dSpOchtuX8g490cdeCPXZd2+jDtEYLZR5CaVlIvD+veyV7S44XLVwq54BAtyzFXmV7Sm
         8jz3mPZ9gBh9nnJQa38BrPAmAowGIf9XIaKBctCS0xDtDYGtixCk6c5DlJh+MDYGz+5e
         c0PAQWU2EVLwl8/mGOnG+LvqPPnpXHliM8EhnEjCnKohZknqepKyRqdytBJw8Oh7UQ6Z
         d+HoS+1BvqaoQPM/6HFACrj7ZttJR+YNF3zFu4J5+Ch0tyz8tmWFkKWxwIFvQ/B7aj7d
         I4WA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUQOycXMd0GDSzeoKQsXgPwxPpZFOb2V9TFqOMQ5yTuqcBN7Y9y
	nRKTWGcrt7NY+QHcNQk4tZbGVYTtg2H72fGgMnOJxHUIDU/kcv9Y6S/I1MvaxM8k3hZWPXjBwB3
	yHa8wk0RlT07dK+5V1ZZaoAuA9BizYtuJiFZz0pRyncnTZHsBe2ZPgJh0CsMFv0o=
X-Received: by 2002:a17:906:164f:: with SMTP id n15mr26857016ejd.224.1559631420165;
        Mon, 03 Jun 2019 23:57:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzuAtfOX4KWQR5YdgMwq74AWhjFhZPAooxoEfwnnNMxnCislsjX8nFR0Od7WGRIFD0UrSHI
X-Received: by 2002:a17:906:164f:: with SMTP id n15mr26856968ejd.224.1559631419317;
        Mon, 03 Jun 2019 23:56:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559631419; cv=none;
        d=google.com; s=arc-20160816;
        b=GLY/uohw0kWIgHnQkPGmL43TKAvQp2sAwZFfezJtVKJphdaCfOYFdqHGzqmvt8VC1Q
         72+nSx+DsAg1fXVd300Vyj0oEdD6NMsnnJ9yt5hzIZGDL0lsiosXVbjeks7lkqfcN8wK
         gWp8QUhwo4Wg9/ijxsgRBSyeUCfcPSIm/bi7AMfYtmOHVeh/ddJIEP3QBuxB79U4GIxP
         p9CbM99+H91kDnuBuTNO2Cf6GhJZB2dfPCqhD8TPXdekETS1g0uuCoLK4/fYsczDLpSR
         Ap7mXE5Qi16phDYLr+utqy6ETZr7bob7MngXgGlp6mbxLrt3mOn4lXlGSCqZtrOAzvXu
         GIfw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=1GQmtwGpoklobeThBbBuDIsNFjH1FXyEVH8SqLexiJ4=;
        b=tDxNTzk7FXTNwqt8O5c9PXIB9Eo/ju4Jc2ceIDNuYgpN4UL0ROihJRNrpRB8dabljF
         Sefb504uRHtAhOztXht4aerLg5uVKtwUOl3jJDaMekTp49hEBWTsKgWRwZ9axnIghEZN
         Y6hyZw23oLR7NEZfBUxfwkQlAp/b+pbx9gT4CbIvuz9PKW41lRyIFmu1VdCWZ03rBKGl
         RtxwxqYYVgMvKrNMP5kvD8rxbzbGBVDkfnsbJ/DudG4ov5wLDHRlTgDuIyQzQqCza3Sr
         kxyfYLoOXSdEDFiwJdjDubvSn0A6Rz6+YHBp2hbr4WzgE+xXMlCneMIIBvRJphAhVorR
         +Y1g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 22si1295894edu.283.2019.06.03.23.56.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 23:56:59 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7767FAD69;
	Tue,  4 Jun 2019 06:56:58 +0000 (UTC)
Date: Tue, 4 Jun 2019 08:56:57 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, jannh@google.com,
	oleg@redhat.com, christian@brauner.io, oleksandr@redhat.com,
	hdanton@sina.com
Subject: Re: [RFCv2 1/6] mm: introduce MADV_COLD
Message-ID: <20190604065657.GC4669@dhcp22.suse.cz>
References: <20190531064313.193437-2-minchan@kernel.org>
 <20190531084752.GI6896@dhcp22.suse.cz>
 <20190531133904.GC195463@google.com>
 <20190531140332.GT6896@dhcp22.suse.cz>
 <20190531143407.GB216592@google.com>
 <20190603071607.GB4531@dhcp22.suse.cz>
 <20190603172717.GA30363@cmpxchg.org>
 <20190603203230.GB22799@dhcp22.suse.cz>
 <20190603215059.GA16824@cmpxchg.org>
 <20190603230205.GA43390@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190603230205.GA43390@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 04-06-19 08:02:05, Minchan Kim wrote:
> Hi Johannes,
> 
> On Mon, Jun 03, 2019 at 05:50:59PM -0400, Johannes Weiner wrote:
> > On Mon, Jun 03, 2019 at 10:32:30PM +0200, Michal Hocko wrote:
> > > On Mon 03-06-19 13:27:17, Johannes Weiner wrote:
> > > > On Mon, Jun 03, 2019 at 09:16:07AM +0200, Michal Hocko wrote:
> > > > > On Fri 31-05-19 23:34:07, Minchan Kim wrote:
> > > > > > On Fri, May 31, 2019 at 04:03:32PM +0200, Michal Hocko wrote:
> > > > > > > On Fri 31-05-19 22:39:04, Minchan Kim wrote:
> > > > > > > > On Fri, May 31, 2019 at 10:47:52AM +0200, Michal Hocko wrote:
> > > > > > > > > On Fri 31-05-19 15:43:08, Minchan Kim wrote:
> > > > > > > > > > When a process expects no accesses to a certain memory range, it could
> > > > > > > > > > give a hint to kernel that the pages can be reclaimed when memory pressure
> > > > > > > > > > happens but data should be preserved for future use.  This could reduce
> > > > > > > > > > workingset eviction so it ends up increasing performance.
> > > > > > > > > > 
> > > > > > > > > > This patch introduces the new MADV_COLD hint to madvise(2) syscall.
> > > > > > > > > > MADV_COLD can be used by a process to mark a memory range as not expected
> > > > > > > > > > to be used in the near future. The hint can help kernel in deciding which
> > > > > > > > > > pages to evict early during memory pressure.
> > > > > > > > > > 
> > > > > > > > > > Internally, it works via deactivating pages from active list to inactive's
> > > > > > > > > > head if the page is private because inactive list could be full of
> > > > > > > > > > used-once pages which are first candidate for the reclaiming and that's a
> > > > > > > > > > reason why MADV_FREE move pages to head of inactive LRU list. Therefore,
> > > > > > > > > > if the memory pressure happens, they will be reclaimed earlier than other
> > > > > > > > > > active pages unless there is no access until the time.
> > > > > > > > > 
> > > > > > > > > [I am intentionally not looking at the implementation because below
> > > > > > > > > points should be clear from the changelog - sorry about nagging ;)]
> > > > > > > > > 
> > > > > > > > > What kind of pages can be deactivated? Anonymous/File backed.
> > > > > > > > > Private/shared? If shared, are there any restrictions?
> > > > > > > > 
> > > > > > > > Both file and private pages could be deactived from each active LRU
> > > > > > > > to each inactive LRU if the page has one map_count. In other words,
> > > > > > > > 
> > > > > > > >     if (page_mapcount(page) <= 1)
> > > > > > > >         deactivate_page(page);
> > > > > > > 
> > > > > > > Why do we restrict to pages that are single mapped?
> > > > > > 
> > > > > > Because page table in one of process shared the page would have access bit
> > > > > > so finally we couldn't reclaim the page. The more process it is shared,
> > > > > > the more fail to reclaim.
> > > > > 
> > > > > So what? In other words why should it be restricted solely based on the
> > > > > map count. I can see a reason to restrict based on the access
> > > > > permissions because we do not want to simplify all sorts of side channel
> > > > > attacks but memory reclaim is capable of reclaiming shared pages and so
> > > > > far I haven't heard any sound argument why madvise should skip those.
> > > > > Again if there are any reasons, then document them in the changelog.
> > > > 
> > > > I think it makes sense. It could be explained, but it also follows
> > > > established madvise semantics, and I'm not sure it's necessarily
> > > > Minchan's job to re-iterate those.
> > > > 
> > > > Sharing isn't exactly transparent to userspace. The kernel does COW,
> > > > ksm etc. When you madvise, you can really only speak for your own
> > > > reference to that memory - "*I* am not using this."
> > > > 
> > > > This is in line with other madvise calls: MADV_DONTNEED clears the
> > > > local page table entries and drops the corresponding references, so
> > > > shared pages won't get freed. MADV_FREE clears the pte dirty bit and
> > > > also has explicit mapcount checks before clearing PG_dirty, so again
> > > > shared pages don't get freed.
> > > 
> > > Right, being consistent with other madvise syscalls is certainly a way
> > > to go. And I am not pushing one way or another, I just want this to be
> > > documented with a reasoning behind. Consistency is certainly an argument
> > > to use.
> > > 
> > > On the other hand these non-destructive madvise operations are quite
> > > different and the shared policy might differ as a result as well. We are
> > > aging objects rather than destroying them after all. Being able to age
> > > a pagecache with a sufficient privileges sounds like a useful usecase to
> > > me. In other words you are able to cause the same effect indirectly
> > > without the madvise operation so it kinda makes sense to allow it in a
> > > more sophisticated way.
> > 
> > Right, I don't think it's about permission - as you say, you can do
> > this indirectly. Page reclaim is all about relative page order, so if
> > we thwarted you from demoting some pages, you could instead promote
> > other pages to cause a similar end result.
> > 
> > I think it's about intent. You're advising the kernel that *you're*
> > not using this memory and would like to have it cleared out based on
> > that knowledge. You could do the same by simply allocating the new
> > pages and have the kernel sort it out. However, if the kernel sorts it
> > out, it *will* look at other users of the page, and it might decide
> > that other pages are actually colder when considering all users.
> > 
> > When you ignore shared state, on the other hand, the pages you advise
> > out could refault right after. And then, not only did you not free up
> > the memory, but you also caused IO that may interfere with bringing in
> > the new data for which you tried to create room in the first place.
> > 
> > So I don't think it ever makes sense to override it.
> > 
> > But it might be better to drop the explicit mapcount check and instead
> > make the local pte young and call shrink_page_list() without the
>                      ^
>                      old?
> 
> > TTU_IGNORE_ACCESS, ignore_references flags - leave it to reclaim code
> > to handle references and shared pages exactly the same way it would if
> > those pages came fresh off the LRU tail, excluding only the reference
> > from the mapping that we're madvising.
> 
> You are confused from the name change. Here, MADV_COLD is deactivating
> , not pageing out. Therefore, shrink_page_list doesn't matter.
> And madvise_cold_pte_range already makes the local pte *old*(I guess
> your saying was typo).
> I guess that's exactly what Michal wanted: just removing page_mapcount
> check and defers to decision on normal page reclaim policy:
> If I didn't miss your intention, it seems you and Michal are on same page.
> (Please correct me if you want to say something other)

Indeed.

> I could drop the page_mapcount check at next revision.

Yes please.
-- 
Michal Hocko
SUSE Labs

