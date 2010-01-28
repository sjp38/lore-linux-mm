Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5F8756B0047
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 07:37:33 -0500 (EST)
Date: Thu, 28 Jan 2010 13:36:32 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 28 of 30] memcg huge memory
Message-ID: <20100128123632.GA14876@random.random>
References: <patchbomb.1264054824@v2.random>
 <4c405faf58cfe5d1aa6e.1264054852@v2.random>
 <20100121161601.6612fd79.kamezawa.hiroyu@jp.fujitsu.com>
 <20100121160807.GB5598@random.random>
 <20100122091317.39db5546.kamezawa.hiroyu@jp.fujitsu.com>
 <4B602304.9000709@linux.vnet.ibm.com>
 <20100128113915.GH24242@random.random>
 <20100128122314.GC25191@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100128122314.GC25191@balbir.in.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 28, 2010 at 05:53:14PM +0530, Balbir Singh wrote:
> I would expect some Documentation stating the following
> 
> 1. Impact of transparent hugepages on memcg

Expected is none except using right page size for compound pages like
described in my comment so far. If there is an impact visible to the
user then we've got something to fix. Only change in implementation
terms is to use the right page_size instead of fixed PAGE_SIZE.

> 2. What does this mean to limit_in_bytes and usage_in_bytes and other
> features

Dunno but I would expect no change at all.

> 3. What does this mean for OOM, reclaim, etc, can there be some
> side-effects.

Zero impact, but lru ordering isn't always guaranteed _identical_ as
tail pages may have to be added to the lru while the lru head is
isolated and we can't mangle over the stack of the other cpu that is
accessed lockless. Same lru ordering is guaranteed however when
split_huge_page runs on a page that has PageLRU set (I add tail pages
to page_head->lru instead of the zone lru head in that case). besides
this lru detail may change in future implementation and it is totally
unrelated to memcg as far as I can tell so no idea why to document it
there...

> I'll read through your patchset and see if I can come up with a useful
> patch. 

Ok, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
