Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 4D8436B0081
	for <linux-mm@kvack.org>; Sun, 20 May 2012 22:44:31 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so9361532pbb.14
        for <linux-mm@kvack.org>; Sun, 20 May 2012 19:44:30 -0700 (PDT)
Date: Mon, 21 May 2012 10:51:49 +0800
From: Zheng Liu <gnehzuil.liu@gmail.com>
Subject: Re: [PATCH] mm: consider all swapped back pages in used-once logic
Message-ID: <20120521025149.GA32375@gmail.com>
References: <1337246033-13719-1-git-send-email-mhocko@suse.cz>
 <20120517195342.GB1800@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120517195342.GB1800@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>

On Thu, May 17, 2012 at 09:54:25PM +0200, Johannes Weiner wrote:
> On Thu, May 17, 2012 at 11:13:53AM +0200, Michal Hocko wrote:
> > [64574746 vmscan: detect mapped file pages used only once] made mapped pages
> > have another round in inactive list because they might be just short
> > lived and so we could consider them again next time. This heuristic
> > helps to reduce pressure on the active list with a streaming IO
> > worklods.
> > This patch fixes a regression introduced by this commit for heavy shmem
> > based workloads because unlike Anon pages, which are excluded from this
> > heuristic because they are usually long lived, shmem pages are handled
> > as a regular page cache.
> > This doesn't work quite well, unfortunately, if the workload is mostly
> > backed by shmem (in memory database sitting on 80% of memory) with a
> > streaming IO in the background (backup - up to 20% of memory). Anon
> > inactive list is full of (dirty) shmem pages when watermarks are
> > hit. Shmem pages are kept in the inactive list (they are referenced)
> > in the first round and it is hard to reclaim anything else so we reach
> > lower scanning priorities very quickly which leads to an excessive swap
> > out.
> > 
> > Let's fix this by excluding all swap backed pages (they tend to be long
> > lived wrt. the regular page cache anyway) from used-once heuristic and
> > rather activate them if they are referenced.
> 
> Yes, the algorithm only makes sense for file cache, which is easy to
> reclaim.  Thanks for the fix!

Hi Johannes,

Out of curiosity, I notice that, in this patch (64574746), the commit log
said that this patch aims to reduce the impact of pages used only once.
Could you please tell why you think these pages will flood the active
list?  How do you find this problem?

Actually, we met a huge regression in our product system.  This
application uses mmap/munmap and read/write simultaneously.  Meanwhile
it wants to keep mapped file pages in memory as much as possible.  But
this patch causes that mapped file pages are reclaimed frequently.  So I
want to know whether or not this patch consider this situation.  Thank
you.

Regards,
Zheng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
