Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3E52A6B006A
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 07:45:41 -0500 (EST)
Date: Thu, 14 Jan 2010 23:45:26 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 5/8] vmalloc: simplify vread()/vwrite()
Message-ID: <20100114124526.GB7518@laptop>
References: <20100113135305.013124116@intel.com>
 <20100113135957.833222772@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100113135957.833222772@intel.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Christoph Lameter <cl@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 13, 2010 at 09:53:10PM +0800, Wu Fengguang wrote:
> vread()/vwrite() is only called from kcore/kmem to access one page at a time.
> So the logic can be vastly simplified.
> 
> The changes are:
> - remove the vmlist walk and rely solely on vmalloc_to_page()
> - replace the VM_IOREMAP check with (page && page_is_ram(pfn))
> - rename to vread_page()/vwrite_page()
> 
> The page_is_ram() check is necessary because kmap_atomic() is not
> designed to work with non-RAM pages.

I don't know if you can really do this. Previously vmlist_lock would be
taken, which will prevent these vm areas from being freed.

 
> Note that even for a RAM page, we don't own the page, and cannot assume
> it's a _PAGE_CACHE_WB page.

So why is this not a problem for your patch? I don't see how you handle
it.

What's the problem with the current code, exactly? I would prefer that
you continue using the same vmlist locking and checking for validating
addresses.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
