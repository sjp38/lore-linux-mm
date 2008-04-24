Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3ONshOQ019188
	for <linux-mm@kvack.org>; Thu, 24 Apr 2008 19:54:43 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3ONshAH1067686
	for <linux-mm@kvack.org>; Thu, 24 Apr 2008 19:54:43 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3ONsbLb014889
	for <linux-mm@kvack.org>; Thu, 24 Apr 2008 19:54:38 -0400
Date: Thu, 24 Apr 2008 16:54:31 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 02/18] hugetlb: factor out huge_new_page
Message-ID: <20080424235431.GB4741@us.ibm.com>
References: <20080423015302.745723000@nick.local0.net> <20080423015429.834926000@nick.local0.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080423015429.834926000@nick.local0.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On 23.04.2008 [11:53:04 +1000], npiggin@suse.de wrote:
> Needed to avoid code duplication in follow up patches.
> 
> This happens to fix a minor bug. When alloc_bootmem_node returns
> a fallback node on a different node than passed the old code
> would have put it into the free lists of the wrong node.
> Now it would end up in the freelist of the correct node.

This is rather frustrating. The whole point of having the __GFP_THISNODE
flag is to indicate off-node allocations are *not* supported from the
caller... This was all worked on quite heavily a while back.

I expect this will lead to imbalanced allocations, as hugetlb.c will
assume that the previous node successfully allocated and move the
iterator forward, allocating again on the fallback node. Since hugetlb
code will anyways iterate over the nodes appropriately, can't we just
make alloc_bootmem_node (or the eventual call-path that results therein)
do the right thing for __GFP_THISNODE allocations? Minimally, the
varying semantics need to be documented somewhere...

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
