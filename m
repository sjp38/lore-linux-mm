Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B21A7C0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 12:39:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 71EB420693
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 12:39:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="YPayV2Ts"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 71EB420693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0C6878E0003; Tue, 30 Jul 2019 08:39:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 04F818E0001; Tue, 30 Jul 2019 08:39:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E62E18E0003; Tue, 30 Jul 2019 08:39:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id AC43D8E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 08:39:42 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 145so40729277pfw.16
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 05:39:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Ab9+yQllgrxhV1PV/fDiWkVd8KTBl0Z4jc93v/FyaQw=;
        b=V+T/Zujvu0bE0+UtCBS0uC8CLGbq6Fa23aDR26yNZbL2unpVVgJ9bs2sAMRXOezuZn
         3p/cDLXfpKHht/OOlED/3idRw9iG8gKOrWA6cPTD7KQ7WcT/4Po3LEUGrZd5WCx6PAdd
         EZ+aX4Nrp6OXS6Ui1OguNY9QJu8ahlgkHChng3Mq+0da5xbJc+ke5i3VmisMPYoHXYdm
         HBCwOI31vbhAyhfUM7sUUnkvYR90G5rKRDzaW8SdGKnxsWpYQSfRCuYaww9JUyH96mkE
         G8WpqR0hCZB2Q7yYNtXKwV3KXvlMECIi0i06hlvOJtIBy2XAzUbr0lZ0Dgq2+yPSgjqM
         VBeg==
X-Gm-Message-State: APjAAAUWsfvaikRxwlEyYrk3oA3zEbFT3bMx/EF1VCmjBjYFj1g2dSrO
	D3vHy/wyqWl9J/PsKVRmD9VQZzYxB9vRlFH86wmy4jzyYdN6rx7OwIe/GyAKKxdk8SWov/94ekq
	M7j2qUTwjLXsHAbONT3Sm1tV8sBf0/5j5w2NaCyvFcN9Zl7IZ2tKlb0D0Lw+2omA=
X-Received: by 2002:a17:902:9004:: with SMTP id a4mr115545956plp.109.1564490382339;
        Tue, 30 Jul 2019 05:39:42 -0700 (PDT)
X-Received: by 2002:a17:902:9004:: with SMTP id a4mr115545917plp.109.1564490381602;
        Tue, 30 Jul 2019 05:39:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564490381; cv=none;
        d=google.com; s=arc-20160816;
        b=mB0DrkzSWvaXiLkJFhCQy0f0OqtMWI7licPDZD7Hk5OS44TNNuueyDbIoMDziYTpUu
         qb6yWw+y3nr+yZmYcJfrNh40jSgVUsCHbsdjFPGCoakw3rXDhlhDQgBevfUBLpBGQqFf
         SLNNfRh4x1UgZd9Ln22/fV5kCe/2OI1KcL929of3pKWw2tSF9V8gntJJVXGD0P3fgeNe
         1Z+ufTQAQJeuJb2LNvWXX5YxWREH5U8mjN/fcxbTHMAy5g+SUVLr/jlwxbhDGbdz7ssl
         H8AwsQz1TYH4bCr204dsq3AWdG00FH3u9D2dEb07oY4oYmDgKeb+LbqT7oiDN1dR4vhg
         9zNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=Ab9+yQllgrxhV1PV/fDiWkVd8KTBl0Z4jc93v/FyaQw=;
        b=0ypdw4OFCWtFJLTkBJ9BJXnr7DC05utry46X/VVmqhCePF136EkELv4HM2FPqITOAp
         /mb0wkyXVwbWqtSbUdxG3zVmA7kJOfG07QWZFnT6DjRcftA1mth4CDnf1jm1mAcSo0PA
         ahzGn508HaHMZe2fwQ7gXXpKkucL2rXm0Nyo/eKvQInU9hyG1ILrxdRybqi1ZMqQKvMA
         qrb8oE6yPylgWkJYiJl5yJl5qfxfEZeu4Za1UVslgtjQmgixiDsasjjGUJ29/cVNPSKT
         hZx0Een+QhtgO/xxPUqy6ASfu4PWUFNULsZZOfEgpSNxMAc4GbWxKpsSO3onya5ydebA
         pHXg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=YPayV2Ts;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o6sor41863517pgp.76.2019.07.30.05.39.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Jul 2019 05:39:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=YPayV2Ts;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Ab9+yQllgrxhV1PV/fDiWkVd8KTBl0Z4jc93v/FyaQw=;
        b=YPayV2Tsa3gOdnqXV9g1d7Z1RXrW8NzdVyVVzOilsA1igzI/rHFmlxWqz2QNxpW4U6
         dD5MFPpint7VYr6z8bGMtBS+li8hGGd4Nu1XQkS7keaj6l/7tg/mAyHSxedtcGS9wFw6
         9sJgyM95LXS43bfOXzUMz6mCasAm7hzL44R90nb1HLTsJewZ4NcItRMQpRzVNSKcTpb1
         58FaOZwjOG0vLlee5mEg2Axr4+CZnXJwJP36yn4oI9ZOOP3a3cOPAi1CPhNv/AQ+E+Gx
         nbtaK5VP7nEcHtlYX8cu2649N1q2zeVjHVwCVQaPys5UeyUD8TWr/IT8oWKWqYsSyFdJ
         zK4g==
X-Google-Smtp-Source: APXvYqyKe+n/nS4aOkmskr/0g93PGfZyD+f/iJDZav+UStfSIraoDl2l/xmMU8fmzTdF6fnjVG6qKQ==
X-Received: by 2002:a63:db47:: with SMTP id x7mr108219665pgi.375.1564490381025;
        Tue, 30 Jul 2019 05:39:41 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id k70sm64512464pje.14.2019.07.30.05.39.37
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 30 Jul 2019 05:39:39 -0700 (PDT)
Date: Tue, 30 Jul 2019 21:39:35 +0900
From: Minchan Kim <minchan@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Miguel de Dios <migueldedios@google.com>, Wei Wang <wvw@google.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: release the spinlock on zap_pte_range
Message-ID: <20190730123935.GB184615@google.com>
References: <20190729071037.241581-1-minchan@kernel.org>
 <20190729074523.GC9330@dhcp22.suse.cz>
 <20190729082052.GA258885@google.com>
 <20190729083515.GD9330@dhcp22.suse.cz>
 <20190730121110.GA184615@google.com>
 <20190730123237.GR9330@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190730123237.GR9330@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 30, 2019 at 02:32:37PM +0200, Michal Hocko wrote:
> On Tue 30-07-19 21:11:10, Minchan Kim wrote:
> > On Mon, Jul 29, 2019 at 10:35:15AM +0200, Michal Hocko wrote:
> > > On Mon 29-07-19 17:20:52, Minchan Kim wrote:
> > > > On Mon, Jul 29, 2019 at 09:45:23AM +0200, Michal Hocko wrote:
> > > > > On Mon 29-07-19 16:10:37, Minchan Kim wrote:
> > > > > > In our testing(carmera recording), Miguel and Wei found unmap_page_range
> > > > > > takes above 6ms with preemption disabled easily. When I see that, the
> > > > > > reason is it holds page table spinlock during entire 512 page operation
> > > > > > in a PMD. 6.2ms is never trivial for user experince if RT task couldn't
> > > > > > run in the time because it could make frame drop or glitch audio problem.
> > > > > 
> > > > > Where is the time spent during the tear down? 512 pages doesn't sound
> > > > > like a lot to tear down. Is it the TLB flushing?
> > > > 
> > > > Miguel confirmed there is no such big latency without mark_page_accessed
> > > > in zap_pte_range so I guess it's the contention of LRU lock as well as
> > > > heavy activate_page overhead which is not trivial, either.
> > > 
> > > Please give us more details ideally with some numbers.
> > 
> > I had a time to benchmark it via adding some trace_printk hooks between
> > pte_offset_map_lock and pte_unmap_unlock in zap_pte_range. The testing
> > device is 2018 premium mobile device.
> > 
> > I can get 2ms delay rather easily to release 2M(ie, 512 pages) when the
> > task runs on little core even though it doesn't have any IPI and LRU
> > lock contention. It's already too heavy.
> > 
> > If I remove activate_page, 35-40% overhead of zap_pte_range is gone
> > so most of overhead(about 0.7ms) comes from activate_page via
> > mark_page_accessed. Thus, if there are LRU contention, that 0.7ms could
> > accumulate up to several ms.
> 
> Thanks for this information. This is something that should be a part of
> the changelog. I am sorry to still poke into this because I still do not

I will include it.

> have a full understanding of what is going on and while I do not object
> to drop the spinlock I still suspect this is papering over a deeper
> problem.

I couldn't come up with better solution. Feel free to suggest it.

> 
> If mark_page_accessed is really expensive then why do we even bother to
> do it in the tear down path in the first place? Why don't we simply set
> a referenced bit on the page to reflect the young pte bit? I might be
> missing something here of course.

commit bf3f3bc5e73
Author: Nick Piggin <npiggin@suse.de>
Date:   Tue Jan 6 14:38:55 2009 -0800

    mm: don't mark_page_accessed in fault path

    Doing a mark_page_accessed at fault-time, then doing SetPageReferenced at
    unmap-time if the pte is young has a number of problems.

    mark_page_accessed is supposed to be roughly the equivalent of a young pte
    for unmapped references. Unfortunately it doesn't come with any context:
    after being called, reclaim doesn't know who or why the page was touched.

    So calling mark_page_accessed not only adds extra lru or PG_referenced
    manipulations for pages that are already going to have pte_young ptes anyway,
    but it also adds these references which are difficult to work with from the
    context of vma specific references (eg. MADV_SEQUENTIAL pte_young may not
    wish to contribute to the page being referenced).

    Then, simply doing SetPageReferenced when zapping a pte and finding it is
    young, is not a really good solution either. SetPageReferenced does not
    correctly promote the page to the active list for example. So after removing
    mark_page_accessed from the fault path, several mmap()+touch+munmap() would
    have a very different result from several read(2) calls for example, which
    is not really desirable.

    Signed-off-by: Nick Piggin <npiggin@suse.de>
    Acked-by: Johannes Weiner <hannes@saeurebad.de>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

