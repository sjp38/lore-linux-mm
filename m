Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id 4E11E6B0035
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 12:04:24 -0400 (EDT)
Received: by mail-qg0-f42.google.com with SMTP id e89so1134100qgf.15
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 09:04:24 -0700 (PDT)
Received: from qmta13.emeryville.ca.mail.comcast.net (qmta13.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:243])
        by mx.google.com with ESMTP id s8si4030924qam.56.2014.07.11.09.04.22
        for <linux-mm@kvack.org>;
        Fri, 11 Jul 2014 09:04:23 -0700 (PDT)
Date: Fri, 11 Jul 2014 11:04:05 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [RFC Patch V1 07/30] mm: Use cpu_to_mem()/numa_mem_id() to
 support memoryless node
In-Reply-To: <20140711155838.GB30865@htj.dyndns.org>
Message-ID: <alpine.DEB.2.11.1407111101070.27434@gentwo.org>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com> <1405064267-11678-8-git-send-email-jiang.liu@linux.intel.com> <20140711144205.GA27706@htj.dyndns.org> <alpine.DEB.2.11.1407111012210.25527@gentwo.org> <20140711152156.GB29137@htj.dyndns.org>
 <20140711153302.GA30865@htj.dyndns.org> <alpine.DEB.2.11.1407111054190.27349@gentwo.org> <20140711155838.GB30865@htj.dyndns.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Vladimir Davydov <vdavydov@parallels.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Catalin Marinas <catalin.marinas@arm.com>, Jianyu Zhan <nasa4836@gmail.com>, malc <av1474@comtv.ru>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Fabian Frederick <fabf@skynet.be>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, 11 Jul 2014, Tejun Heo wrote:

> On Fri, Jul 11, 2014 at 10:55:59AM -0500, Christoph Lameter wrote:
> > > Where X is the memless node.  num_mem_id() on X would return either B
> > > or C, right?  If B or C can't satisfy the allocation, the allocator
> > > would fallback to A from B and D for C, both of which aren't optimal.
> > > It should first fall back to C or B respectively, which the allocator
> > > can't do anymoe because the information is lost when the caller side
> > > performs numa_mem_id().
> >
> > True but the advantage is that the numa_mem_id() allows the use of a
> > consitent sort of "local" node which increases allocator performance due
> > to the abillity to cache objects from that node.
>
> But the allocator can do the mapping the same.  I really don't see why
> we'd push the distinction to the individual users.

The "users" (I guess you mean general kernel code/drivers) can use various
memory allocators which will do the right thing internally regarding
GFP_THISNODE. They do not need to worry too much about this unless there
are reasons beyond optimizing NUMA placement to need memory from a
particuylar node (f.e. a device that requires memory from a numa node that
is local to the PCI bus where the hardware resides).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
