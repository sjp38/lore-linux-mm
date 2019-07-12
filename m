Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7836C742B4
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 10:10:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C24D2084B
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 10:10:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C24D2084B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2894E8E0135; Fri, 12 Jul 2019 06:10:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 23A808E00DB; Fri, 12 Jul 2019 06:10:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1021B8E0135; Fri, 12 Jul 2019 06:10:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B553E8E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 06:10:46 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b12so7389290eds.14
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 03:10:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=33AMLlJzR8G0tS5XS2ovvyYRIUrLAAdE44lWlh+5poY=;
        b=QnstZa5xIfx9THZVrLEEEJhWrv9RZXm2KB/fJTxMFXUzSdBAPFK6t80sGfP+lGiQSZ
         TtLULb4cpaa41hnHm4Su8BmrYJgqeFAn50irv+A2Z0ZPa9Y+XUU/lKL5+Xml4uRMcSex
         ED79bpnNtdGr5NiodPw7M/mAeEVs0XcLsNXyMxyqipZKohaGIojvHZEKKWaptTKl9bP7
         LADukw8z1fNl31oMHcXShzLjOJ2gBwf8OFT+t6ccxr5H6CkWQBgq9iB4t2F3mQHjq0XQ
         XPTG1MkfDfTBLDp2aUWJnGyZo/StJH90nQuvOapixqSbPs+yk5OPjh7o1jd9FaigtJDx
         T53g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
X-Gm-Message-State: APjAAAVDDXKQZhlI3ef/Ti4gm5jdiOnNQSNYZGY9HTLwrBKxbN71/8Zv
	h/nZivc9O64/rBWs45sgLWnKTcHUvR5urmRzdzkSPLslGT4qz1g3WhBy+8y3wTCwUO7esmaavLJ
	btJ9+QZ7zQoj6f4Ftl5lujR4YXsosWdGV2BlJ8NjYD6tXj6NbpvoygduBHZm/gL5AgA==
X-Received: by 2002:a50:8bfa:: with SMTP id n55mr8580194edn.9.1562926246276;
        Fri, 12 Jul 2019 03:10:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxbbeSjqeHZYoEgYC16WMRR8opNUudSZuU8vWDGFl97f89cS1xRq4ptwSqcTbZm5OeguM6O
X-Received: by 2002:a50:8bfa:: with SMTP id n55mr8580140edn.9.1562926245487;
        Fri, 12 Jul 2019 03:10:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562926245; cv=none;
        d=google.com; s=arc-20160816;
        b=DxIu0E7DLwZ/j14J8CSHS2yy+AWeM1xM3ChQ+0qEHSu7OPFVNsBwkW7gXI0BzVSVMC
         UQdhWBfmtibli6Ny/KVNQdoX1CTYydTv5p5qCuy7sJ9+cnagJnGUBvpmzXV8xyBarjKH
         v08kzO+/B1cp7qkNHxoXbZxSANkwmVHGClCPIzfLU2+c81Rd4mXFTx9wH0cY+oF69Kbl
         b2yRZv0wDoLyja8HWO09WydH2RdTPM0erGYS2wT3W64vl0NXdi3MBUs9ABiIU30Hy8hS
         bphaysIpJ1MtTl/i/+YRTDBPH3sgHAzPC3HpFUiTgtmqVgwXD2KeoKaeWbmmmrrkAnxi
         IOjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=33AMLlJzR8G0tS5XS2ovvyYRIUrLAAdE44lWlh+5poY=;
        b=hEzjwXulykYE+g0OTo1BI0u/Wan74KceDns+wBEGIvuK2cGPPjPzDVW6pFzePucV+u
         07Vzmd+aIcQYQ62OX8rLkkeNNifXxayJV1sEftxiHiPXXDdqX7BFGymUhUpFR/tAsqb3
         LAL/jamuho7gws2UmHXwQLUCYlvAU+yCTekuDFM/+JUvWTgsGo6dj/mbAg/6vvwrpGfZ
         zJ0+01Y2qQNgendy7oljuFzXNlO95mRQFH9AvKdNBVuspHk6TgqWEdFDDa9ArnTUNwzl
         T4r8sVXVuc8XWy2Oo6UrGbtpLHOEn4xD2QpLgS/cdcQY+AoVJ41sw74vU5un/qFtM1NJ
         bULw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q17si4224126eju.276.2019.07.12.03.10.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 03:10:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E308FAEBF;
	Fri, 12 Jul 2019 10:10:44 +0000 (UTC)
Date: Fri, 12 Jul 2019 11:10:43 +0100
From: Mel Gorman <mgorman@suse.de>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	mhocko@suse.cz, stable@vger.kernel.org
Subject: Re: [PATCH RFC] mm: migrate: Fix races of __find_get_block() and
 page migration
Message-ID: <20190712101042.GJ13484@suse.de>
References: <20190711125838.32565-1-jack@suse.cz>
 <20190711170455.5a9ae6e659cab1a85f9aa30c@linux-foundation.org>
 <20190712091746.GB906@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190712091746.GB906@quack2.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 12, 2019 at 11:17:46AM +0200, Jan Kara wrote:
> On Thu 11-07-19 17:04:55, Andrew Morton wrote:
> > On Thu, 11 Jul 2019 14:58:38 +0200 Jan Kara <jack@suse.cz> wrote:
> > 
> > > buffer_migrate_page_norefs() can race with bh users in a following way:
> > > 
> > > CPU1					CPU2
> > > buffer_migrate_page_norefs()
> > >   buffer_migrate_lock_buffers()
> > >   checks bh refs
> > >   spin_unlock(&mapping->private_lock)
> > > 					__find_get_block()
> > > 					  spin_lock(&mapping->private_lock)
> > > 					  grab bh ref
> > > 					  spin_unlock(&mapping->private_lock)
> > >   move page				  do bh work
> > > 
> > > This can result in various issues like lost updates to buffers (i.e.
> > > metadata corruption) or use after free issues for the old page.
> > > 
> > > Closing this race window is relatively difficult. We could hold
> > > mapping->private_lock in buffer_migrate_page_norefs() until we are
> > > finished with migrating the page but the lock hold times would be rather
> > > big. So let's revert to a more careful variant of page migration requiring
> > > eviction of buffers on migrated page. This is effectively
> > > fallback_migrate_page() that additionally invalidates bh LRUs in case
> > > try_to_free_buffers() failed.
> > 
> > Is this premature optimization?  Holding ->private_lock while messing
> > with the buffers would be the standard way of addressing this.  The
> > longer hold times *might* be an issue, but we don't know this, do we? 
> > If there are indeed such problems then they could be improved by, say,
> > doing more of the newpage preparation prior to taking ->private_lock.
> 
> I didn't check how long the private_lock hold times would actually be, it
> just seems there's a lot of work done before the page is fully migrated a
> we could release the lock. And since the lock blocks bh lookup,
> set_page_dirty(), etc. for the whole device, it just seemed as a bad idea.
> I don't think much of a newpage setup can be moved outside of private_lock
> - in particular page cache replacement, page copying, page state migration
> all need to be there so that bh code doesn't get confused.
> 
> But I guess it's fair to measure at least ballpark numbers of what the lock
> hold times would be to get idea whether the contention concern is
> substantiated or not.
> 

I think it would be tricky to measure and quantify how much the contention
is an issue. While it would be possible to construct a microbenchmark that
should illustrate the problem, it would tell us relatively little about
how much of a problem it is generally. It would be relatively difficult
to detect the contention and stalls in block lookups due to migration
would be tricky to spot. Careful use of lock_stat might help but
enabling that has consequences of its own.

However, a rise in allocation failures due to dirty pages not being
migrated is relatively easy to detect and the consequences are relatively
benign -- failed high-order allocation that is usually ok versus a stall
on block lookups that could have a wider general impact.

On that basis, I think the patch you proposed is the more appropriate as
a fix for the race which has the potential for data corruption. So;

Acked-by: Mel Gorman <mgorman@techsingularity.net>

> Finally, I guess I should mention there's one more approach to the problem
> I was considering: Modify bh code to fully rely on page lock instead of
> private_lock for bh lookup. That would make sense scalability-wise on its
> own. The problem with it is that __find_get_block() would become a sleeping
> function. There aren't that many places calling the function and most of
> them seem fine with it but still it is non-trivial amount of work to do the
> conversion and it can have some fallout so it didn't seem like a good
> solution for a data-corruption issue that needs to go to stable...
> 

Maybe *if* it's shown there is a major issue with increased high-order
allocation failures, it would be worth looking into but right now, I
think it's overkill with relatively high risk and closing the potential
race is more important.

-- 
Mel Gorman
SUSE Labs

