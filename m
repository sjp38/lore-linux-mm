Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 6EB146B0012
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 03:57:49 -0400 (EDT)
Date: Fri, 17 Jun 2011 08:57:43 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [BUGFIX][PATCH][-rc3] Define a consolidated definition of
 node_start/end_pfn for build error in page_cgroup.c (Was Re: mmotm
 2011-06-15-16-56 uploaded (mm/page_cgroup.c)
Message-ID: <20110617075743.GD5244@suse.de>
References: <201106160034.p5G0Y4dr028904@imap1.linux-foundation.org>
 <20110615214917.a7dce8e6.randy.dunlap@oracle.com>
 <20110616172819.1e2d325c.kamezawa.hiroyu@jp.fujitsu.com>
 <20110616103559.GA5244@suse.de>
 <20110617094628.aecf5ee1.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110617094628.aecf5ee1.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Randy Dunlap <randy.dunlap@oracle.com>, dave@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, mingo@elte.hu

On Fri, Jun 17, 2011 at 09:46:28AM +0900, KAMEZAWA Hiroyuki wrote:
> On Thu, 16 Jun 2011 11:35:59 +0100
> Mel Gorman <mgorman@suse.de> wrote:
> 
> > A caller that does node_end_pfn(nid++) will get a nasty surprise
> > due to side-effects. I know architectures currently get this wrong
> > including x86_64 but we might as well fix it up now. The definition
> > in arch/x86/include/asm/mmzone_32.h is immune to side-effects and
> > might be a better choice despite the use of a temporary variable.
> > 
> 
> Ok, here is a fixed one. Thank you for comments/review.
> ==
> From 507cc95c5ba2351bff16c5421255d1395a3b555b Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Thu, 16 Jun 2011 17:28:07 +0900
> Subject: [PATCH] Fix node_start/end_pfn() definition for mm/page_cgroup.c
> 
> commit 21a3c96 uses node_start/end_pfn(nid) for detection start/end
> of nodes. But, it's not defined in linux/mmzone.h but defined in
> /arch/???/include/mmzone.h which is included only under
> CONFIG_NEED_MULTIPLE_NODES=y.
> 
> Then, we see
> mm/page_cgroup.c: In function 'page_cgroup_init':
> mm/page_cgroup.c:308: error: implicit declaration of function 'node_start_pfn'
> mm/page_cgroup.c:309: error: implicit declaration of function 'node_end_pfn'
> 
> So, fixiing page_cgroup.c is an idea...
> 
> But node_start_pfn()/node_end_pfn() is a very generic macro and
> should be implemented in the same manner for all archs.
> (m32r has different implementation...)
> 
> This patch removes definitions of node_start/end_pfn() in each archs
> and defines a unified one in linux/mmzone.h. It's not under
> CONFIG_NEED_MULTIPLE_NODES, now.
> 
> A result of macro expansion is here (mm/page_cgroup.c)
> 
> for !NUMA
>  start_pfn = ((&contig_page_data)->node_start_pfn);
>   end_pfn = ({ pg_data_t *__pgdat = (&contig_page_data); __pgdat->node_start_pfn + __pgdat->node_spanned_pages;});
> 
> for NUMA (x86-64)
>   start_pfn = ((node_data[nid])->node_start_pfn);
>   end_pfn = ({ pg_data_t *__pgdat = (node_data[nid]); __pgdat->node_start_pfn + __pgdat->node_spanned_pages;});
> 
> 
> Reported-by: Randy Dunlap <randy.dunlap@oracle.com>
> Reported-by: Ingo Molnar <mingo@elte.hu>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 

Thanks.

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
