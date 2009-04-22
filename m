Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 4A1186B00EA
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 12:13:13 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n3MGAIeu021513
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 10:10:18 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3MGDHri038396
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 10:13:20 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3MGDEQe014628
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 10:13:15 -0600
Subject: Re: [PATCH 02/22] Do not sanity check order in the fast path
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1240408407-21848-3-git-send-email-mel@csn.ul.ie>
References: <1240408407-21848-1-git-send-email-mel@csn.ul.ie>
	 <1240408407-21848-3-git-send-email-mel@csn.ul.ie>
Content-Type: text/plain
Date: Wed, 22 Apr 2009 09:13:11 -0700
Message-Id: <1240416791.10627.78.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2009-04-22 at 14:53 +0100, Mel Gorman wrote:
> No user of the allocator API should be passing in an order >= MAX_ORDER
> but we check for it on each and every allocation. Delete this check and
> make it a VM_BUG_ON check further down the call path.

Should we get the check re-added to some of the upper-level functions,
then?  Perhaps __get_free_pages() or things like alloc_pages_exact()? 

I'm selfishly thinking of what I did in profile_init().  Can I slab
alloc it?  Nope.  Page allocator?  Nope.  Oh, well, try vmalloc():

        prof_buffer = kzalloc(buffer_bytes, GFP_KERNEL);
        if (prof_buffer)
                return 0;

        prof_buffer = alloc_pages_exact(buffer_bytes, GFP_KERNEL|__GFP_ZERO);
        if (prof_buffer)
                return 0;

        prof_buffer = vmalloc(buffer_bytes);
        if (prof_buffer)
                return 0;

        free_cpumask_var(prof_cpu_mask);
        return -ENOMEM;

Same thing in __kmalloc_section_memmap():

        page = alloc_pages(GFP_KERNEL|__GFP_NOWARN, get_order(memmap_size));
        if (page)
                goto got_map_page;

        ret = vmalloc(memmap_size);
        if (ret)
                goto got_map_ptr;

I depend on the allocator to tell me when I've fed it too high of an
order.  If we really need this, perhaps we should do an audit and then
add a WARN_ON() for a few releases to catch the stragglers.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
