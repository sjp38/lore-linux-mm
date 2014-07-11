Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id D4D3F6B0036
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 11:59:10 -0400 (EDT)
Received: by mail-qc0-f171.google.com with SMTP id w7so1156704qcr.2
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 08:59:10 -0700 (PDT)
Received: from qmta13.emeryville.ca.mail.comcast.net (qmta13.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:243])
        by mx.google.com with ESMTP id x9si3907130qax.121.2014.07.11.08.59.09
        for <linux-mm@kvack.org>;
        Fri, 11 Jul 2014 08:59:10 -0700 (PDT)
Date: Fri, 11 Jul 2014 10:58:52 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [RFC Patch V1 07/30] mm: Use cpu_to_mem()/numa_mem_id() to
 support memoryless node
In-Reply-To: <20140711152156.GB29137@htj.dyndns.org>
Message-ID: <alpine.DEB.2.11.1407111056060.27349@gentwo.org>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com> <1405064267-11678-8-git-send-email-jiang.liu@linux.intel.com> <20140711144205.GA27706@htj.dyndns.org> <alpine.DEB.2.11.1407111012210.25527@gentwo.org>
 <20140711152156.GB29137@htj.dyndns.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Vladimir Davydov <vdavydov@parallels.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Catalin Marinas <catalin.marinas@arm.com>, Jianyu Zhan <nasa4836@gmail.com>, malc <av1474@comtv.ru>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Fabian Frederick <fabf@skynet.be>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, 11 Jul 2014, Tejun Heo wrote:

> Hello,
>
> On Fri, Jul 11, 2014 at 10:13:57AM -0500, Christoph Lameter wrote:
> > Allocators typically fall back but they wont in some cases if you say
> > that you want memory from a particular node. A GFP_THISNODE would force a
> > failure of the alloc. In other cases it should fall back. I am not sure
> > that all allocations obey these conventions though.
>
> But, GFP_THISNODE + numa_mem_id() is identical to numa_node_id() +
> nearest node with memory fallback.  Is there any case where the user
> would actually want to always fail if it's on the memless node?

GFP_THISNODE allocatios must fail if there is no memory available on
the node. No fallback allowed.

If the allocator performs caching for a particular node (like SLAB) then
the allocator *cannnot* accept memory from another node and the alloc via
the page allocator  must fail so that the allocator can then pick another
node for keeping track of the allocations.

> Even if that's the case, there's no reason to burden everyone with
> this distinction.  Most users just wanna say "I'm on this node.
> Please allocate considering that".  There's nothing wrong with using
> numa_node_id() for that.

Well yes that speaks for this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
