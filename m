Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B887360021B
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 14:29:24 -0500 (EST)
Subject: Re: [RFC] high system time & lock contention running large mixed
	workload
From: Larry Woodman <lwoodman@redhat.com>
In-Reply-To: <20091204092445.587D.A69D9226@jp.fujitsu.com>
References: <4B15CEE0.2030503@redhat.com>
	 <1259878496.2345.57.camel@dhcp-100-19-198.bos.redhat.com>
	 <20091204092445.587D.A69D9226@jp.fujitsu.com>
Content-Type: text/plain
Date: Fri, 04 Dec 2009 14:31:57 -0500
Message-Id: <1259955117.3221.2.camel@dhcp-100-19-198.bos.redhat.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2009-12-04 at 09:36 +0900, KOSAKI Motohiro wrote:

> > 
> > Also, BTW, check this out: an 8-CPU/16GB system running AIM 7 Compute
> > has 196491 isolated_anon pages.  This means that ~6140 processes are
> > somewhere down in try_to_free_pages() since we only isolate 32 pages at
> > a time, this is out of 9000 processes...
> > 
> > 
> > ---------------------------------------------------------------------
> > active_anon:2140361 inactive_anon:453356 isolated_anon:196491
> >  active_file:3438 inactive_file:1100 isolated_file:0
> >  unevictable:2802 dirty:153 writeback:0 unstable:0
> >  free:578920 slab_reclaimable:49214 slab_unreclaimable:93268
> >  mapped:1105 shmem:0 pagetables:139100 bounce:0
> > 
> > Node 0 Normal free:1647892kB min:12500kB low:15624kB high:18748kB 
> > active_anon:7835452kB inactive_anon:785764kB active_file:13672kB 
> > inactive_file:4352kB unevictable:11208kB isolated(anon):785964kB 
> > isolated(file):0kB present:12410880kB mlocked:11208kB dirty:604kB 
> > writeback:0kB mapped:4344kB shmem:0kB slab_reclaimable:177792kB 
> > slab_unreclaimable:368676kB kernel_stack:73256kB pagetables:489972kB 
> > unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0
> > 
> > 202895 total pagecache pages
> > 197629 pages in swap cache
> > Swap cache stats: add 6954838, delete 6757209, find 1251447/2095005
> > Free swap  = 65881196kB
> > Total swap = 67354616kB
> > 3997696 pages RAM
> > 207046 pages reserved
> > 1688629 pages shared
> > 3016248 pages non-shared
> 
> This seems we have to improve reclaim bale out logic. the system already
> have 1.5GB free pages. IOW, the system don't need swap-out anymore.
> 
> 

Whats going on here is there are about 7500 runable processes and the
memory is already low.  A process runs, requests memory and eventually
ends up in try_to_free_pages.  Since the page reclaim code calls
cond_resched()in several places so the scheduler eventually puts that
process on the run queue and runs another process which does the same
thing.  Eventually you end up with thousands of runnable processes in
the page reclaim code continuing to reclaim even though there is plenty
of free memory.  

procs -----------memory---------- ---swap-- -----io---- --system--
-----cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy 
id wa st
7480 421 1474396 2240060   7640  12988   23   27    24    40   14   40 
12 45 43  1  0
7524 405 1474772 2224504   7644  13460  759  689   764   689 8932
11076  
8 92  0  0  0
7239 401 1474164 2210572   7656  13524  596  592   596   596 8809
10494  
9 91  0  0  0

BTW, this is easy to reproduce.  Fork thousands of processes that
collectively overcommit memory and keep them allocating...




  


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
