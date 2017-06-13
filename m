Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id BB1EE6B0372
	for <linux-mm@kvack.org>; Tue, 13 Jun 2017 08:02:02 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id u51so31519354qte.15
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 05:02:02 -0700 (PDT)
Received: from mail-qt0-x243.google.com (mail-qt0-x243.google.com. [2607:f8b0:400d:c0d::243])
        by mx.google.com with ESMTPS id u65si11401768qkf.84.2017.06.13.05.01.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jun 2017 05:02:00 -0700 (PDT)
Received: by mail-qt0-x243.google.com with SMTP id x58so33526075qtc.2
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 05:01:59 -0700 (PDT)
Date: Tue, 13 Jun 2017 08:01:57 -0400
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH 1/2] mm: use slab size in the slab shrinking ratio
 calculation
Message-ID: <20170613120156.GA16003@destiny>
References: <1496949546-2223-1-git-send-email-jbacik@fb.com>
 <20170613052802.GA16061@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170613052802.GA16061@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: josef@toxicpanda.com, hannes@cmpxchg.org, riel@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, kernel-team@fb.com, Josef Bacik <jbacik@fb.com>

On Tue, Jun 13, 2017 at 02:28:02PM +0900, Minchan Kim wrote:
> Hello,
> 
> On Thu, Jun 08, 2017 at 03:19:05PM -0400, josef@toxicpanda.com wrote:
> > From: Josef Bacik <jbacik@fb.com>
> > 
> > When testing a slab heavy workload I noticed that we often would barely
> > reclaim anything at all from slab when kswapd started doing reclaim.
> > This is because we use the ratio of nr_scanned / nr_lru to determine how
> > much of slab we should reclaim.  But in a slab only/mostly workload we
> > will not have much page cache to reclaim, and thus our ratio will be
> > really low and not at all related to where the memory on the system is.
> 
> I want to understand this clearly.
> Why nr_scanned / nr_lru is low if system doesnt' have much page cache?
> Could you elaborate it a bit?
> 

Yeah so for example on my freshly booted test box I have this

Active:            58840 kB
Inactive:          46860 kB

Every time we do a get_scan_count() we do this

scan = size >> sc->priority

where sc->priority starts at DEF_PRIORITY, which is 12.  The first loop through
reclaim would result in a scan target of 2 pages to 11715 total inactive pages,
and 3 pages to 14710 total active pages.  This is a really really small target
for a system that is entirely slab pages.  And this is super optimistic, this
assumes we even get to scan these pages.  We don't increment sc->nr_scanned
unless we 1) isolate the page, which assumes it's not in use, and 2) can lock
the page.  Under pressure these numbers could probably go down, I'm sure there's
some random pages from daemons that aren't actually in use, so the targets get
even smaller.

We have to get sc->priority down a lot before we start to get to the 1:1 ratio
that would even start to be useful for reclaim in this scenario.  Add to this
that most shrinkable slabs have this idea that their objects have to loop
through the LRU twice (no longer icache/dcache as Al took my patch to fix that
thankfully) and you end up spending a lot of time looping and reclaiming
nothing.  Basing it on actual slab usage makes more sense logically and avoids
this kind of problem.  Thanks,

Josef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
