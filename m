Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id CDCA46B008A
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 15:45:04 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n3NJi2sU009460
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 13:44:02 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3NJjYxm069990
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 13:45:34 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3NJjXBB013064
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 13:45:33 -0600
Subject: Re: [PATCH 02/22] Do not sanity check order in the fast path
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1240514784.10627.171.camel@nimitz>
References: <1240408407-21848-1-git-send-email-mel@csn.ul.ie>
	 <1240408407-21848-3-git-send-email-mel@csn.ul.ie>
	 <1240416791.10627.78.camel@nimitz> <20090422171151.GF15367@csn.ul.ie>
	 <1240421415.10627.93.camel@nimitz>  <20090423001311.GA26643@csn.ul.ie>
	 <1240450447.10627.119.camel@nimitz>  <1240514784.10627.171.camel@nimitz>
Content-Type: text/plain
Date: Thu, 23 Apr 2009 12:45:30 -0700
Message-Id: <1240515930.10627.175.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2009-04-23 at 12:26 -0700, Dave Hansen wrote:
> I'm going to retry this with a NUMA config.  

Oddly enough, removing the alloc_pages() check didn't do anything to
text on a NUMA=y config, either: 

dave@kernel:~/work/mhp-build$ size i386-numaq-sparse.?/vmlinux
   text	   data	    bss	    dec	    hex	filename
3460792	 449336	1626112	5536240	 5479f0	i386-numaq-sparse.0/vmlinux
3460792	 449336	1626112	5536240	 5479f0	i386-numaq-sparse.1/vmlinux
3460776	 449336	1626112	5536224	 5479e0	i386-numaq-sparse.2/vmlinux

Here's bloatmeter from removing the alloc_pages_node() check:

dave@kernel:~/work/mhp-build$ ../linux-2.6.git/scripts/bloat-o-meter
i386-numaq-sparse.{1,2}/vmlinux 
add/remove: 0/0 grow/shrink: 9/16 up/down: 81/-99 (-18)
function                                     old     new   delta
st_int_ioctl                                2600    2624     +24
tcp_sendmsg                                 2153    2169     +16
diskstats_show                               739     753     +14
iov_shorten                                   49      58      +9
unmap_vmas                                  1653    1661      +8
sg_build_indirect                            449     455      +6
ahc_linux_biosparam                          251     253      +2
nlmclnt_call                                 557     558      +1
do_mount                                    1533    1534      +1
skb_icv_walk                                 420     419      -1
nfs_readpage_truncate_uninitialised_page     288     287      -1
find_first_zero_bit                           67      66      -1
enlarge_buffer                               339     337      -2
ahc_parse_msg                               2340    2338      -2
__get_free_pages                              36      33      -3
flock_lock_file_wait                         484     480      -4
find_vma_prepare                             108     103      -5
arp_ignore                                   104      99      -5
__udp4_lib_err                               312     307      -5
alloc_buddy_huge_page                        170     163      -7
pbus_size_mem                                907     899      -8
dma_generic_alloc_coherent                   245     236      -9
cache_alloc_refill                          1168    1158     -10
mempool_alloc_pages                           33      17     -16
do_mremap                                   1208    1188     -20


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
