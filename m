Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id B118D6B005A
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 17:36:26 -0500 (EST)
Received: by mail-ea0-f174.google.com with SMTP id e13so1639057eaa.33
        for <linux-mm@kvack.org>; Thu, 20 Dec 2012 14:36:25 -0800 (PST)
Date: Thu, 20 Dec 2012 23:36:23 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH v3] mm: limit mmu_gather batching to fix soft lockups on
 !CONFIG_PREEMPT
Message-ID: <20121220223623.GA9012@dhcp22.suse.cz>
References: <1355847088-1207-1-git-send-email-mhocko@suse.cz>
 <20121218140219.45867ddd.akpm@linux-foundation.org>
 <20121218235042.GA10350@dhcp22.suse.cz>
 <20121218160030.baf723aa.akpm@linux-foundation.org>
 <20121219150423.GA12888@dhcp22.suse.cz>
 <20121219131316.7d13fcb1.akpm@linux-foundation.org>
 <20121220124710.GA31912@dhcp22.suse.cz>
 <20121220122746.72d889fd.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121220122746.72d889fd.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Thu 20-12-12 12:27:46, Andrew Morton wrote:
> On Thu, 20 Dec 2012 13:47:10 +0100
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > > > + */
> > > > +#if defined(CONFIG_PREEMPT_COUNT)
> > > > +#define MAX_GATHER_BATCH_COUNT	(UINT_MAX)
> > > > +#else
> > > > +#define MAX_GATHER_BATCH_COUNT	(((1UL<<(30-PAGE_SHIFT))/MAX_GATHER_BATCH))
> > > 
> > > Geeze.  I spent waaaaay too long staring at that expression trying to
> > > work out "how many pages is in a batch" and gave up.
> > > 
> > > Realistically, I don't think we need to worry about CONFIG_PREEMPT here
> > > - if we just limit the thing to, say, 64k pages per batch then that
> > > will be OK for preemptible and non-preemptible kernels. 
> > 
> > I wanted the fix to be as non-intrusive as possible so I didn't want to
> > touch PREEMPT (which is default in many configs) at all. I am OK to a
> > single limit of course.
> 
> non-intrusive is nice, but best-implementation is nicer.
> 
> > > The performance difference between "64k" and "infinite" will be
> > > miniscule and unmeasurable.
> > > 
> > > Also, the batch count should be independent of PAGE_SIZE.  Because
> > > PAGE_SIZE can vary by a factor of 16 and you don't want to fix the
> > > problem on 4k page size but leave it broken on 64k page size.
> > 
> > MAX_GATHER_BATCH depends on the page size so I didn't want to differ
> > without a good reason.
> 
> There's a good reason!  PAGE_SIZE can vary by a factor of 16, and if
> this results in the unpreemptible-CPU-effort varying by a factor of 16
> then that's bad, and we should change things so the
> unpreemptible-CPU-effort is independent of PAGE_SIZE.

Yes you are right. Let's make the number of entries (pages) fixed instead
(in the end we are just freeing pages which have more or less constant
cost). Then something like the following should work:
---
