Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id D32CA6B00A3
	for <linux-mm@kvack.org>; Tue, 27 May 2014 11:06:00 -0400 (EDT)
Received: by mail-la0-f52.google.com with SMTP id gl10so6382753lab.25
        for <linux-mm@kvack.org>; Tue, 27 May 2014 08:06:00 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id ub4si22322696wjc.56.2014.05.27.08.05.58
        for <linux-mm@kvack.org>;
        Tue, 27 May 2014 08:05:59 -0700 (PDT)
Date: Tue, 27 May 2014 11:57:08 -0300
From: Marcelo Tosatti <mtosatti@redhat.com>
Subject: Re: [PATCH] page_alloc: skip cpuset enforcement for lower zone
 allocations
Message-ID: <20140527145708.GA21238@amt.cnet>
References: <20140523193706.GA22854@amt.cnet>
 <alpine.DEB.2.10.1405270917510.13999@gentwo.org>
 <20140527145352.GB3765@amt.cnet>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140527145352.GB3765@amt.cnet>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Lai Jiangshan <laijs@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, May 27, 2014 at 11:53:52AM -0300, Marcelo Tosatti wrote:
> On Tue, May 27, 2014 at 09:21:32AM -0500, Christoph Lameter wrote:
> > On Fri, 23 May 2014, Marcelo Tosatti wrote:
> > 
> > > Zone specific allocations, such as GFP_DMA32, should not be restricted
> > > to cpusets allowed node list: the zones which such allocations demand
> > > might be contained in particular nodes outside the cpuset node list.
> > >
> > > The alternative would be to not perform such allocations from
> > > applications which are cpuset restricted, which is unrealistic.
> > >
> > > Fixes KVM's alloc_page(gfp_mask=GFP_DMA32) with cpuset as explained.
> > 
> > Memory policies are only applied to a specific zone so this is not
> > unprecedented. However, if a user wants to limit allocation to a specific
> > node and there is no DMA memory there then may be that is a operator
> > error? After all the application will be using memory from a node that the
> > operator explicitly wanted not to be used.
> 
> Ok here is the use-case:
> 
> - machine contains driver which requires zone specific memory (such as
> KVM, which requires root pagetable at paddr < 4GB).
> 
> - user wants to limit allocation of application to nodeX, and nodeX has
> no memory < 4GB.
> 
> How would you solve that? Options:
> 
> 1) force admin to allow allocation from node(s) which contain 0-4GB
>   range, which unfortunately would allow every allocation, including
>   ones which are not restricted to particular nodes, to be performed
>   there.
> 
> or
> 
> 2) allow zone specific allocations to bypass memory policies.
> 
> It seems 2) is the best option (and there is precedent for it).
> 
> > There is also the hardwall flag. I think its ok to allocate outside of the
> > cpuset if that flag is not set. However, if it is set then any attempt to
> > alloc outside of the cpuset should fail.
> 
> GFP_ATOMIC bypasses hardwall:
> 
>  * The second pass through get_page_from_freelist() doesn't even call
>  * here for GFP_ATOMIC calls.  For those calls, the __alloc_pages()
>  * variable 'wait' is not set, and the bit ALLOC_CPUSET is not set
>  * in alloc_flags.  That logic and the checks below have the combined
>  * affect that:
>  *      in_interrupt - any node ok (current task context irrelevant)
>  *      GFP_ATOMIC   - any node ok
>  *      TIF_MEMDIE   - any node ok
>  *      GFP_KERNEL   - any node in enclosing hardwalled cpuset ok
>  *      GFP_USER     - only nodes in current tasks mems allowed ok.

Thats softwall nevermind. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
