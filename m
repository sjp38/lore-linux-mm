Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45AE5C04E84
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 15:10:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C518020657
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 15:10:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="VBWQprmA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C518020657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 01D306B0007; Thu, 16 May 2019 11:10:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F10D86B0008; Thu, 16 May 2019 11:10:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DFEE46B000A; Thu, 16 May 2019 11:10:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id A6A1D6B0007
	for <linux-mm@kvack.org>; Thu, 16 May 2019 11:10:20 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id y9so2182541plt.11
        for <linux-mm@kvack.org>; Thu, 16 May 2019 08:10:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=WgItyBJzDLlqz5Gik0C+96TskxzuElNQz9xK2Z679ZU=;
        b=pBLh189hXgfbZzYvKvtAFQ0hbtKuCA0VczRjGrksjQuD3d5k1zGgUMSJu9h7LHPM4N
         xq9eHr2pZkXt162dumQC4Re9UA7w63tQR10qR9e1UHjjaCgVOnJ1yaL7z/lZXciLSysq
         fA3VLyhz+XHOK05UKXximCb8QMiJm9vLmmd7pXnMoVFFF90EtT/Nw3ROrezLdmnNwFtR
         A41nZKwnyCMPYekgyp4jBhVeblgMY0GKZwDg3Euv+eNfjDb842eWaz3G9MlZcwoLlpXl
         HrnJRWxwfYfSfY/0JrCRhyFhAPC+SueDGz0SW4KQ2lKAn6O52sx8BY81sRoGzjItwGwd
         0RZw==
X-Gm-Message-State: APjAAAVe6ALWyBwDXVr9oKBgEyH5XXHeSSM1pYQdikSXZIoNee6cCAZF
	ie4PoQoby+uRAzkPn5zWB7X6SS3mp6Qc0qoB4I5fpukMAfEwqc99q1liCxr7i3P+9p5u4ux26hp
	yM3JQbWxmd4YliRNtuNSOwhx1u66nwzZo1JtJnf8kN4ggusyN6J40E6HhLFSWqG0J7w==
X-Received: by 2002:a17:902:b584:: with SMTP id a4mr14082042pls.333.1558019420105;
        Thu, 16 May 2019 08:10:20 -0700 (PDT)
X-Received: by 2002:a17:902:b584:: with SMTP id a4mr14081896pls.333.1558019418750;
        Thu, 16 May 2019 08:10:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558019418; cv=none;
        d=google.com; s=arc-20160816;
        b=RrJZ/3Kc/c7Y63aHgfH851W7JW2PZOM0X1U3mfmbMZysgZUm0eFrK3a3OHW03y64/F
         jc5a0W70q8ffGmfrC4eGQWz5IM2m8Ra0QdWIuRm94iGiFpgCrJAcnMJsD6uxKWy7JXuc
         v/yj3O7v3K/lsMd8gOMDEQ9DpTWBQxq4zigyiMr16a2IA+Bjpu09SEIsguKqPDSog8IR
         mPxTI9mlks7opJrKDQbVHYbxzcfwzEFkdR2o14QZLUo/fcdCnraZcfnp/U8Vw02M17aq
         i58KXA/alIfptioc/rrvPJvQBG5qthLb1rTuD3yaR8Hy8/7grU6vlqTxHroUf0ylVxaj
         tjaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=WgItyBJzDLlqz5Gik0C+96TskxzuElNQz9xK2Z679ZU=;
        b=go8mwVGdr0o0mWwZ0IkbjVjYHkLODrZ1Jnh7KnS5F8PIDVNg6tdfKbo24Ng33z3fZi
         g3DhNMPNHs+0egImp2KUQMyt6nbYqNx+nLDNmoRxa/fZhSe+rPpGyLxKCxb0epUmyBZK
         FHrMwMCsseFPTXych4n3G1xg4mQn1FqRjVOf+qJaoS76bmr/A6WoP2pKq8UXiTP4lpGK
         VNEqntmE2GyO3zwzseOM4E+cx1AdoZqEDiCHl3kV/p6NroYoIqLpTGd3Y/ZAyUbtWK1M
         OUQSv1nsfjKUbDbeSo2zLiezyAbs8GKw+46Fi8mlhNH9LkWhQDarQhM5Lel6vwBjMoTZ
         p96Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=VBWQprmA;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id q65sor6333643pfi.11.2019.05.16.08.10.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 May 2019 08:10:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=VBWQprmA;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=WgItyBJzDLlqz5Gik0C+96TskxzuElNQz9xK2Z679ZU=;
        b=VBWQprmA5MZXlwsCQ6SwCKgJVN0e1o1lvPIlSlGB0YXBQ7jqt4v8fvoD4mi76vuqSM
         QiH7hBI2bl3frHolfT0kMLi9jGMjn/GJmWA9bakf6lgiL2WDCmE2w/PKCPQzWhp7Iem1
         sx0za8uNbzuAfjm3n7SLvyCizmCpY72aj8AJwWVjGE1aKvynWqKQlnH7DBbSYU8W6X73
         HCRpNHtdeWlBzb0QDCSzzJvEK2zPMKrw6F+oxIu/i0TNSezxiKi6pina0dLKUXOYU8Ma
         dUBa6NTSwUcZ/i8rc54cgBQGa5FBv9k8D4OhJdGdLZMRa3XAHOM3+B2fOA04NwYBN714
         gw1Q==
X-Google-Smtp-Source: APXvYqzKlIoNcZy0ZhhqzXFmL2Ia8ljcPo6txDYTujPDJiGwxQFbwyA5fAqpvMifyWIYzSQHgX3fKw==
X-Received: by 2002:a65:63d5:: with SMTP id n21mr51006664pgv.330.1558019414956;
        Thu, 16 May 2019 08:10:14 -0700 (PDT)
Received: from localhost ([2620:10d:c090:180::b2f6])
        by smtp.gmail.com with ESMTPSA id p2sm6305231pgd.63.2019.05.16.08.10.13
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 16 May 2019 08:10:14 -0700 (PDT)
Date: Thu, 16 May 2019 11:10:12 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Michal Hocko <mhocko@kernel.org>, Yang Shi <shy828301@gmail.com>,
	Huang Ying <ying.huang@intel.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	kirill.shutemov@linux.intel.com, Hugh Dickins <hughd@google.com>,
	Shakeel Butt <shakeelb@google.com>, william.kucharski@oracle.com,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [v2 PATCH] mm: vmscan: correct nr_reclaimed for THP
Message-ID: <20190516151012.GA20038@cmpxchg.org>
References: <1557505420-21809-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190513080929.GC24036@dhcp22.suse.cz>
 <c3c26c7a-748c-6090-67f4-3014bedea2e6@linux.alibaba.com>
 <20190513214503.GB25356@dhcp22.suse.cz>
 <CAHbLzkpUE2wBp8UjH72ugXjWSfFY5YjV1Ps9t5EM2VSRTUKxRw@mail.gmail.com>
 <20190514062039.GB20868@dhcp22.suse.cz>
 <509de066-17bb-e3cf-d492-1daf1cb11494@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <509de066-17bb-e3cf-d492-1daf1cb11494@linux.alibaba.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 14, 2019 at 01:44:35PM -0700, Yang Shi wrote:
> On 5/13/19 11:20 PM, Michal Hocko wrote:
> > On Mon 13-05-19 21:36:59, Yang Shi wrote:
> > > On Mon, May 13, 2019 at 2:45 PM Michal Hocko <mhocko@kernel.org> wrote:
> > > > On Mon 13-05-19 14:09:59, Yang Shi wrote:
> > > > [...]
> > > > > I think we can just account 512 base pages for nr_scanned for
> > > > > isolate_lru_pages() to make the counters sane since PGSCAN_KSWAPD/DIRECT
> > > > > just use it.
> > > > > 
> > > > > And, sc->nr_scanned should be accounted as 512 base pages too otherwise we
> > > > > may have nr_scanned < nr_to_reclaim all the time to result in false-negative
> > > > > for priority raise and something else wrong (e.g. wrong vmpressure).
> > > > Be careful. nr_scanned is used as a pressure indicator to slab shrinking
> > > > AFAIR. Maybe this is ok but it really begs for much more explaining
> > > I don't know why my company mailbox didn't receive this email, so I
> > > replied with my personal email.
> > > 
> > > It is not used to double slab pressure any more since commit
> > > 9092c71bb724 ("mm: use sc->priority for slab shrink targets"). It uses
> > > sc->priority to determine the pressure for slab shrinking now.
> > > 
> > > So, I think we can just remove that "double slab pressure" code. It is
> > > not used actually and looks confusing now. Actually, the "double slab
> > > pressure" does something opposite. The extra inc to sc->nr_scanned
> > > just prevents from raising sc->priority.
> > I have to get in sync with the recent changes. I am aware there were
> > some patches floating around but I didn't get to review them. I was
> > trying to point out that nr_scanned used to have a side effect to be
> > careful about. If it doesn't have anymore then this is getting much more
> > easier of course. Please document everything in the changelog.
> 
> Thanks for reminding. Yes, I remembered nr_scanned would double slab
> pressure. But, when I inspected into the code yesterday, it turns out it is
> not true anymore. I will run some test to make sure it doesn't introduce
> regression.

Yeah, sc->nr_scanned is used for three things right now:

1. vmpressure - this looks at the scanned/reclaimed ratio so it won't
change semantics as long as scanned & reclaimed are fixed in parallel

2. compaction/reclaim - this is broken. Compaction wants a certain
number of physical pages freed up before going back to compacting.
Without Yang Shi's fix, we can overreclaim by a factor of 512.

3. kswapd priority raising - this is broken. kswapd raises priority if
we scan fewer pages than the reclaim target (which itself is obviously
expressed in order-0 pages). As a result, kswapd can falsely raise its
aggressiveness even when it's making great progress.

Both sc->nr_scanned & sc->nr_reclaimed should be fixed.

> BTW, I noticed the counter of memory reclaim is not correct with THP swap on
> vanilla kernel, please see the below:
> 
> pgsteal_kswapd 21435
> pgsteal_direct 26573329
> pgscan_kswapd 3514
> pgscan_direct 14417775
> 
> pgsteal is always greater than pgscan, my patch could fix the problem.

Ouch, how is that possible with the current code?

I think it happens when isolate_lru_pages() counts 1 nr_scanned for a
THP, then shrink_page_list() splits the THP and we reclaim tail pages
one by one. This goes all the way back to the initial THP patch!

isolate_lru_pages() needs to be fixed. Its return value, nr_taken, is
correct, but its *nr_scanned parameter is wrong, which causes issues:

1. The trace point, as Yang Shi pointed out, will underreport the
number of pages scanned, as it reports it along with nr_to_scan (base
pages) and nr_taken (base pages)

2. vmstat and memory.stat count 'struct page' operations rather than
base pages, which makes zero sense to neither user nor kernel
developers (I routinely multiply these counters by 4096 to get a sense
of work performed).

All of isolate_lru_pages()'s accounting should be in base pages, which
includes nr_scanned and PGSCAN_SKIPPED.

That should also simplify the code; e.g.:

	for (total_scan = 0;
	     scan < nr_to_scan && nr_taken < nr_to_scan && !list_empty(src);
	     total_scan++) {

scan < nr_to_scan && nr_taken >= nr_to_scan is a weird condition that
does not make sense in page reclaim imo. Reclaim cares about physical
memory - freeing one THP is as much progress for reclaim as freeing
512 order-0 pages.

IMO *all* '++' in vmscan.c are suspicious and should be reviewed:
nr_scanned, nr_reclaimed, nr_dirty, nr_unqueued_dirty, nr_congested,
nr_immediate, nr_writeback, nr_ref_keep, nr_unmap_fail, pgactivate,
total_scan & scan, nr_skipped.

Yang Shi, it would be nice if you could convert all of these to base
page accounting in one patch, as it's a single logical fix for the
initial introduction of THP that had huge pages show up on the LRUs.

[ check_move_unevictable_pages() seems weird. It gets a pagevec from
  find_get_entries(), which, if I understand the THP page cache code
  correctly, might contain the same compound page over and over. It'll
  be !unevictable after the first iteration, so will only run once. So
  it produces incorrect numbers now, but it is probably best to ignore
  it until we figure out THP cache. Maybe add an XXX comment. ]

