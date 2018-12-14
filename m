Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A46068E01DC
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 11:24:32 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id w15so2996980edl.21
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 08:24:32 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id la26-v6si1806376ejb.33.2018.12.14.08.24.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Dec 2018 08:24:30 -0800 (PST)
Received: from relay1.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7248EAE5B
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 16:24:30 +0000 (UTC)
Date: Fri, 14 Dec 2018 16:24:28 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/6] mm: migration: Factor out code to compute expected
 number of page references
Message-ID: <20181214162428.GH28934@suse.de>
References: <20181211172143.7358-1-jack@suse.cz>
 <20181211172143.7358-2-jack@suse.cz>
 <20181214151045.GG28934@suse.de>
 <20181214155311.GG8896@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20181214155311.GG8896@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, mhocko@suse.cz

On Fri, Dec 14, 2018 at 04:53:11PM +0100, Jan Kara wrote:
> > I noticed during testing that THP allocation success rates under the
> > mmtests configuration global-dhp__workload_thpscale-madvhugepage-xfs were
> > terrible with massive latencies introduced somewhere in the series. I
> > haven't tried chasing it down as it's relatively late but this block
> > looked odd and I missed it the first time.
> 
> Interesting. I've run config-global-dhp__workload_thpscale and that didn't
> show anything strange. But the numbers were fluctuating a lot both with and
> without my patches applied. I'll have a look if I can reproduce this
> sometime next week and look what could be causing the delays.
> 

Ah, it's the difference between madvise and !madvise. The configuration
you used does very little compaction as it neither wakes kswapd of
kcompactd. It just falls back to base pages to limit fault latency so
you wouldn't have hit the same paths of interest.

> > This page->mapping test is relevant for the "Anonymous page without
> > mapping" check but I think it's wrong. An anonymous page without mapping
> > doesn't have a NULL mapping, it sets PAGE_MAPPING_ANON and the field can
> > be special in other ways. I think you meant to use page_mapping(page)
> > here, not page->mapping?
> 
> Yes, that's a bug. It should have been page_mapping(page). Thanks for
> catching this.
> 

My pleasure, should have spotted it the first time around :/

-- 
Mel Gorman
SUSE Labs
