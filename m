Date: Tue, 18 Sep 2007 11:41:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH/RFC 1/14] Reclaim Scalability:  Convert anon_vma lock to
 read/write lock
Message-Id: <20070918114142.abbd5421.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070917110234.GF25706@skynet.ie>
References: <20070914205359.6536.98017.sendpatchset@localhost>
	<20070914205405.6536.37532.sendpatchset@localhost>
	<20070917110234.GF25706@skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, akpm@linux-foundation.org, clameter@sgi.com, riel@redhat.com, balbir@linux.vnet.ibm.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Mon, 17 Sep 2007 12:02:35 +0100
mel@skynet.ie (Mel Gorman) wrote:

> On (14/09/07 16:54), Lee Schermerhorn didst pronounce:
> > [PATCH/RFC] 01/14 Reclaim Scalability:  Convert anon_vma list lock a read/write lock
> > 
> > Against 2.6.23-rc4-mm1
> > 
> > Make the anon_vma list lock a read/write lock.  Heaviest use of this
> > lock is in the page_referenced()/try_to_unmap() calls from vmscan
> > [shrink_page_list()].  These functions can use a read lock to allow
> > some parallelism for different cpus trying to reclaim pages mapped
> > via the same set of vmas.
<snip>
> In light of what Peter and Linus said about rw-locks being more expensive
> than spinlocks, we'll need to measure this with some benchmark. The plus
> side is that this patch can be handled in isolation because it's either a
> scalability fix or it isn't. It's worth investigating because you say it
> fixed a real problem where under load the job was able to complete with
> this patch and live-locked without it.
>
> When you decide on a test-case, I can test just this patch and see what
> results I find.
> 

One of the case I can imagine is..
==
1. Use NUMA.
2. create *large* anon_vma and use it with MPOL_INTERLEAVE
3. When memory is exhausted (on several nodes), all kswapd on nodes will
   see one anon_vma->lock.
==
Maybe the worst case.

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
