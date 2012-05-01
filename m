Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id E12E96B004D
	for <linux-mm@kvack.org>; Tue,  1 May 2012 17:26:59 -0400 (EDT)
Date: Tue, 1 May 2012 14:26:56 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 0/5] refault distance-based file cache sizing
Message-Id: <20120501142656.c9160d96.akpm@linux-foundation.org>
In-Reply-To: <4FA05354.8000304@redhat.com>
References: <1335861713-4573-1-git-send-email-hannes@cmpxchg.org>
	<20120501120819.0af1e54b.akpm@linux-foundation.org>
	<4FA05354.8000304@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, 01 May 2012 17:19:16 -0400
Rik van Riel <riel@redhat.com> wrote:

> On 05/01/2012 03:08 PM, Andrew Morton wrote:
> > On Tue,  1 May 2012 10:41:48 +0200
> > Johannes Weiner<hannes@cmpxchg.org>  wrote:
> >
> >> This series stores file cache eviction information in the vacated page
> >> cache radix tree slots and uses it on refault to see if the pages
> >> currently on the active list need to have their status challenged.
> >
> > So we no longer free the radix-tree node when everything under it has
> > been reclaimed?  One could create workloads which would result in a
> > tremendous amount of memory used by radix_tree_node_cachep objects.
> >
> > So I assume these things get thrown away at some point.  Some
> > discussion about the life-cycle here would be useful.
> 
> I assume that in the current codebase Johannes has, we would
> have to rely on the inode cache shrinker to reclaim the inode
> and throw out the radix tree nodes.
> 
> Having a better way to deal with radix tree nodes that contain
> stale entries (where the evicted pages would no longer receive
> special treatment on re-fault, because it has been so long) get
> reclaimed would be nice for a future version.
> 

Well, think of a stupid workload which creates a large number of very
large but sparse files (populated with one page in each 64, for
example).  Get them all in cache, then sit there touching the inodes to
keep then fresh.  What's the worst case here?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
