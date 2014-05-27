Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f180.google.com (mail-ve0-f180.google.com [209.85.128.180])
	by kanga.kvack.org (Postfix) with ESMTP id F25D76B00A9
	for <linux-mm@kvack.org>; Tue, 27 May 2014 11:32:01 -0400 (EDT)
Received: by mail-ve0-f180.google.com with SMTP id db12so10825327veb.39
        for <linux-mm@kvack.org>; Tue, 27 May 2014 08:32:01 -0700 (PDT)
Received: from qmta08.emeryville.ca.mail.comcast.net (qmta08.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:80])
        by mx.google.com with ESMTP id k15si17821239qae.86.2014.05.27.08.32.01
        for <linux-mm@kvack.org>;
        Tue, 27 May 2014 08:32:01 -0700 (PDT)
Date: Tue, 27 May 2014 10:31:58 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH] page_alloc: skip cpuset enforcement for lower zone
 allocations
In-Reply-To: <20140527145352.GB3765@amt.cnet>
Message-ID: <alpine.DEB.2.10.1405271027430.14466@gentwo.org>
References: <20140523193706.GA22854@amt.cnet> <alpine.DEB.2.10.1405270917510.13999@gentwo.org> <20140527145352.GB3765@amt.cnet>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcelo Tosatti <mtosatti@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Lai Jiangshan <laijs@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, 27 May 2014, Marcelo Tosatti wrote:

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

GFP_KERNEL is used for page tables.

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

Page table allocations are GFP_KERNEL allocations. So the above use case
is ok if you switch off the hardwall flag in the cpuset.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
