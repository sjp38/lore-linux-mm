Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 5AD4B6B003D
	for <linux-mm@kvack.org>; Fri, 24 Apr 2009 05:21:37 -0400 (EDT)
Date: Fri, 24 Apr 2009 10:21:51 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 02/22] Do not sanity check order in the fast path
Message-ID: <20090424092151.GA14283@csn.ul.ie>
References: <1240408407-21848-1-git-send-email-mel@csn.ul.ie> <1240408407-21848-3-git-send-email-mel@csn.ul.ie> <1240416791.10627.78.camel@nimitz> <20090422171151.GF15367@csn.ul.ie> <1240421415.10627.93.camel@nimitz> <20090423001311.GA26643@csn.ul.ie> <1240450447.10627.119.camel@nimitz> <1240514784.10627.171.camel@nimitz> <1240515930.10627.175.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1240515930.10627.175.camel@nimitz>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 23, 2009 at 12:45:30PM -0700, Dave Hansen wrote:
> On Thu, 2009-04-23 at 12:26 -0700, Dave Hansen wrote:
> > I'm going to retry this with a NUMA config.  
> 
> Oddly enough, removing the alloc_pages() check didn't do anything to
> text on a NUMA=y config, either: 
> 
> dave@kernel:~/work/mhp-build$ size i386-numaq-sparse.?/vmlinux
>    text	   data	    bss	    dec	    hex	filename
> 3460792	 449336	1626112	5536240	 5479f0	i386-numaq-sparse.0/vmlinux
> 3460792	 449336	1626112	5536240	 5479f0	i386-numaq-sparse.1/vmlinux
> 3460776	 449336	1626112	5536224	 5479e0	i386-numaq-sparse.2/vmlinux
> 
> Here's bloatmeter from removing the alloc_pages_node() check:
> 
> dave@kernel:~/work/mhp-build$ ../linux-2.6.git/scripts/bloat-o-meter
> i386-numaq-sparse.{1,2}/vmlinux 
> add/remove: 0/0 grow/shrink: 9/16 up/down: 81/-99 (-18)
> function                                     old     new   delta
> st_int_ioctl                                2600    2624     +24
> tcp_sendmsg                                 2153    2169     +16
> diskstats_show                               739     753     +14
> iov_shorten                                   49      58      +9
> unmap_vmas                                  1653    1661      +8
> sg_build_indirect                            449     455      +6
> ahc_linux_biosparam                          251     253      +2
> nlmclnt_call                                 557     558      +1
> do_mount                                    1533    1534      +1

It doesn't make sense at all that text increased in size. Did you make clean
between each .config change and patch application? Are you using distcc
or anything else that might cause confusion? I found I had to eliminate
distscc and clean after each patch application because sometimes
net/ipv4/udp.c would sometimes generate different assembly when
accessing struct zone. Not really sure what was going on there.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
