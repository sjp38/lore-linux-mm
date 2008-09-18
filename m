Date: Thu, 18 Sep 2008 13:26:13 +0900 (JST)
Message-Id: <20080918.132613.74431429.taka@valinux.co.jp>
Subject: Re: [RFC][PATCH] Remove cgroup member from struct page (v3)
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20080917184008.92b7fc4c.akpm@linux-foundation.org>
References: <20080911105638.1581db90.kamezawa.hiroyu@jp.fujitsu.com>
	<20080917232826.GA19256@balbir.in.ibm.com>
	<20080917184008.92b7fc4c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: balbir@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, dave@linux.vnet.ibm.com, nickpiggin@yahoo.com.au, hugh@veritas.com, menage@google.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

> > Before trying the sparsemem approach, I tried a radix tree per node,
> > per zone and I seemed to actually get some performance
> > improvement.(1.5% (noise maybe))
> > 
> > But please do see and review (tested on my x86_64 box with unixbench
> > and some other simple tests)
> > 
> > v4..v3
> > 1. Use a radix tree per node, per zone
> > 
> > v3...v2
> > 1. Convert flags to unsigned long
> > 2. Move page_cgroup->lock to a bit spin lock in flags
> > 
> > v2...v1
> > 
> > 1. Fix a small bug, don't call radix_tree_preload_end(), if preload fails
> > 
> > This is a rewrite of a patch I had written long back to remove struct page
> > (I shared the patches with Kamezawa, but never posted them anywhere else).
> > I spent the weekend, cleaning them up for 2.6.27-rc5-mmotm (29 Aug 2008).
> > 
> > I've tested the patches on an x86_64 box, I've run a simple test running
> > under the memory control group and the same test running concurrently under
> > two different groups (and creating pressure within their groups).
> > 
> > Advantages of the patch
> > 
> > 1. It removes the extra pointer in struct page
> > 
> > Disadvantages
> > 
> > 1. Radix tree lookup is not an O(1) operation, once the page is known
> >    getting to the page_cgroup (pc) is a little more expensive now.
> 
> Why are we doing this?  I can guess, but I'd rather not have to.

I think this design is just temporary and the goal is to pre-allocate
all page_cgroups at boot time if it isn't disabled.

But I think each memory model type should have its own way of managing
its page_cgroup arrays as doing for its struct page arrays.
It would be better rather than the sparsemem approach he said.

> a) It's slower.
> 
> b) It uses even more memory worst-case.
> 
> c) It uses less memory best-case.
> 
> someone somewhere decided that (Aa + Bb) / Cc < 1.0.  What are the values
> of A, B and C and where did they come from? ;)
> 
> (IOW, your changelog is in the category "sucky", along with 90% of the others)
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
