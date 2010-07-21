Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A63F16B02A3
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 05:41:13 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id o6L9f82R018200
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 02:41:08 -0700
Received: from pvh11 (pvh11.prod.google.com [10.241.210.203])
	by wpaz9.hot.corp.google.com with ESMTP id o6L9f6WF006712
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 02:41:07 -0700
Received: by pvh11 with SMTP id 11so3251093pvh.38
        for <linux-mm@kvack.org>; Wed, 21 Jul 2010 02:41:06 -0700 (PDT)
Date: Wed, 21 Jul 2010 02:41:03 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/6] sparc: remove dependency on __GFP_NOFAIL
In-Reply-To: <20100720.203100.254885062.davem@davemloft.net>
Message-ID: <alpine.DEB.2.00.1007210237500.19769@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1007201936210.8728@chino.kir.corp.google.com> <alpine.DEB.2.00.1007201938100.8728@chino.kir.corp.google.com> <20100720.203100.254885062.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Miller <davem@davemloft.net>
Cc: akpm@linux-foundation.org, benh@kernel.crashing.org, sparclinux@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 20 Jul 2010, David Miller wrote:

> > The kmalloc() in mdesc_kmalloc() is failable, so remove __GFP_NOFAIL from
> > its mask.
> > 
> > Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> > Signed-off-by: David Rientjes <rientjes@google.com>
> 
> The __GFP_NOFAIL is there intentionally.
> 
> The code above this, in the cases where the machine description is
> dynamically updated by the hypervisor at run time, long after boot,
> has no failure handling.
> 
> We absolutely must accept the machine descriptor update and fetch it
> from the hypervisor into a new buffer.
> 
> Please don't remove this.
> 

Ok, fair enough.  I was convinced by the error handling in both 
mdesc_update() and mdesc_kmallloc() that this was a failable allocation, 
but I understand how mdesc_update() must succeed given your description.  
We can remove those branches from those two functions, though, since 
__GFP_NOFAIL will always succeed before returning.

I'm planning on replacing __GFP_NOFAIL with a __GFP_KILLABLE flag that 
will use all of the page allocator's capabilities (direct reclaim, memory 
compaction for order > 0, and the oom killer) before failing.  Then, 
existing __GFP_NOFAIL users can use

	do {
		page = alloc_page(GFP_KERNEL | __GFP_KILLABLE);
	} while (!page);

to remove several branches from the page allocator that we'll no longer 
need.  I'll do this in phase two and make sure to convert this instance to 
do that.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
