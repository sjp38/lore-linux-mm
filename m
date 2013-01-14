Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 094AC6B0071
	for <linux-mm@kvack.org>; Mon, 14 Jan 2013 05:49:32 -0500 (EST)
Date: Mon, 14 Jan 2013 10:49:30 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: compaction: Partially revert capture of suitable
 high-order page
Message-ID: <20130114104930.GP13304@suse.de>
References: <20130111092701.GK13304@suse.de>
 <1358046453.1518.1.camel@kernel.cn.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1358046453.1518.1.camel@kernel.cn.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Eric Wong <normalperson@yhbt.net>, Eric Dumazet <eric.dumazet@gmail.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org

On Sat, Jan 12, 2013 at 09:07:33PM -0600, Simon Jeons wrote:
> On Fri, 2013-01-11 at 09:27 +0000, Mel Gorman wrote:
> > Eric Wong reported on 3.7 and 3.8-rc2 that ppoll() got stuck when waiting
> > for POLLIN on a local TCP socket. It was easier to trigger if there was disk
> > IO and dirty pages at the same time and he bisected it to commit 1fb3f8ca
> > "mm: compaction: capture a suitable high-order page immediately when it
> > is made available".
> > 
> > The intention of that patch was to improve high-order allocations under
> > memory pressure after changes made to reclaim in 3.6 drastically hurt
> > THP allocations but the approach was flawed. For Eric, the problem was
> > that page->pfmemalloc was not being cleared for captured pages leading to
> > a poor interaction with swap-over-NFS support causing the packets to be
> > dropped. However, I identified a few more problems with the patch including
> > the fact that it can increase contention on zone->lock in some cases which
> > could result in async direct compaction being aborted early.
> > 
> > In retrospect the capture patch took the wrong approach. What it should
> > have done is mark the pageblock being migrated as MIGRATE_ISOLATE if it
> > was allocating for THP and avoided races that way. While the patch was
> 
> Hi Mel,
> 
> Mark pageblock being migrated as MIGRATE_ISOLATE if it was allocating
> for THP and avoided races that way is a good idea. But why I can't see
> you do it in this patch?
> 

Because it is not what the patch does. Implementing that idea will take
time to do properly and cleanly with no guarantee it'll work well enough
to justify the complexity. Fixing the POLLIN bug was more important.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
