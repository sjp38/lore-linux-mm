Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A10306B0087
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 15:26:08 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n3NJMvxP014061
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 15:22:57 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3NJQTGV189176
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 15:26:29 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3NJOfp5022594
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 15:24:42 -0400
Subject: Re: [PATCH 02/22] Do not sanity check order in the fast path
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1240450447.10627.119.camel@nimitz>
References: <1240408407-21848-1-git-send-email-mel@csn.ul.ie>
	 <1240408407-21848-3-git-send-email-mel@csn.ul.ie>
	 <1240416791.10627.78.camel@nimitz> <20090422171151.GF15367@csn.ul.ie>
	 <1240421415.10627.93.camel@nimitz>  <20090423001311.GA26643@csn.ul.ie>
	 <1240450447.10627.119.camel@nimitz>
Content-Type: text/plain
Date: Thu, 23 Apr 2009 12:26:24 -0700
Message-Id: <1240514784.10627.171.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2009-04-22 at 18:34 -0700, Dave Hansen wrote:
> I'll also go and see what the actual .text size
> changes are from this patch both for alloc_pages() and
> alloc_pages_node() separately to make sure what we're dealing with
> here.  Does this check even *exist* in the optimized code very
> often?  

While this isn't definitive by any means, I did get some interesting
results.  Pulling the check out of alloc_pages() had no effect at *all*
on text size because I'm trying with CONFIG_NUMA=n.

$ size i386-T41-laptop.{0,1}/vmlinux
   text	   data	    bss	    dec	    hex	filename
4348625	 286560	 860160	5495345	 53da31	i386-T41-laptop.0/vmlinux
4348625	 286560	 860160	5495345	 53da31	i386-T41-laptop.1/vmlinux

We get a slightly different when pulling the check out of
alloc_pages_node():

$ size i386-T41-laptop.{1,2}/vmlinux
   text	   data	    bss	    dec	    hex	filename
4348625	 286560	 860160	5495345	 53da31	i386-T41-laptop.1/vmlinux
4348601	 286560	 860160	5495321	 53da19	i386-T41-laptop.2/vmlinux

$ bloat-o-meter i386-T41-laptop.1/vmlinux i386-T41-laptop.2/vmlinux 
add/remove: 0/0 grow/shrink: 9/7 up/down: 78/-107 (-29)
function                                     old     new   delta
__get_user_pages                             717     751     +34
st_read                                     1936    1944      +8
shmem_truncate_range                        1660    1667      +7
pci_create_slot                              410     417      +7
sg_build_indirect                            449     455      +6
n_tty_read                                  1336    1342      +6
find_vma_prepare                             103     108      +5
as_update_iohist                             617     621      +4
ntfs_readdir                                3426    3427      +1
enlarge_buffer                               343     341      -2
__get_free_pages                              36      33      -3
dma_generic_alloc_coherent                   207     202      -5
mempool_alloc_pages                           33      17     -16
futex_lock_pi                               2120    2104     -16
kallsyms_lookup_name                         102      82     -20
cache_alloc_refill                          1171    1126     -45

I'm going to retry this with a NUMA config.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
