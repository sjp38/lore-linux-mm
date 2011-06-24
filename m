Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 4F75290023D
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 18:23:28 -0400 (EDT)
Date: Fri, 24 Jun 2011 15:23:10 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [BUG?] numa required on x86_64?
Message-Id: <20110624152310.10803ffa.randy.dunlap@oracle.com>
In-Reply-To: <1308952859.25830.8.camel@pi>
References: <1308952859.25830.8.camel@pi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: pomac@vapor.com, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Sat, 25 Jun 2011 00:00:58 +0200 Ian Kumlien wrote:

> Hi all,
> 
> Just found this when wanting to play with development kernels again.
> Since there is no -gitXX snapshots anymore, I cloned the git =)...
> 
> But, it failed to build properly with my config:
> 
> mm/page_cgroup.c line 308: node_start_pfn and node_end_pfn is only
> defined under NUMA on x86_64.
> 
> The commit that changed the use of this was introduced recently while
> the mmzone_64.h hasn't been changed since april.

You should have cc-ed the commit Author (I did so).

> commit 37573e8c718277103f61f03741bdc5606d31b07e
> Author: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date:   Wed Jun 15 15:08:42 2011 -0700
> 
>     memcg: fix init_page_cgroup nid with sparsemem
>     
>     Commit 21a3c9646873 ("memcg: allocate memory cgroup structures in local
>     nodes") makes page_cgroup allocation as NUMA aware.  But that caused a
>     problem https://bugzilla.kernel.org/show_bug.cgi?id=36192.
>     
>     The problem was getting a NID from invalid struct pages, which was not
>     initialized because it was out-of-node, out of [node_start_pfn,
>     node_end_pfn)
>     
>     Now, with sparsemem, page_cgroup_init scans pfn from 0 to max_pfn.  But
>     this may scan a pfn which is not on any node and can access memmap which
>     is not initialized.
>     
>     This makes page_cgroup_init() for SPARSEMEM node aware and remove a code
>     to get nid from page->flags.  (Then, we'll use valid NID always.)
>     
>     [akpm@linux-foundation.org: try to fix up comments]
>     Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>     Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

A patch for this has been posted at least 2 times.
It's here:  http://marc.info/?l=linux-mm&m=130827204306775&w=2

Andrew, please merge this (^that^) patch.

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
