Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l32Jt1vH013511
	for <linux-mm@kvack.org>; Mon, 2 Apr 2007 15:55:01 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l32Jt10l201870
	for <linux-mm@kvack.org>; Mon, 2 Apr 2007 13:55:01 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l32Jt084001703
	for <linux-mm@kvack.org>; Mon, 2 Apr 2007 13:55:00 -0600
Subject: Re: [PATCH 1/4] x86_64: Switch to SPARSE_VIRTUAL
From: Dave Hansen <hansendc@us.ibm.com>
In-Reply-To: <Pine.LNX.4.64.0704020851300.30394@schroedinger.engr.sgi.com>
References: <20070401071024.23757.4113.sendpatchset@schroedinger.engr.sgi.com>
	 <200704011246.52238.ak@suse.de>
	 <Pine.LNX.4.64.0704020832320.30394@schroedinger.engr.sgi.com>
	 <200704021744.39880.ak@suse.de>
	 <Pine.LNX.4.64.0704020851300.30394@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 02 Apr 2007 12:54:56 -0700
Message-Id: <1175543696.22373.51.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Martin Bligh <mbligh@google.com>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-04-02 at 08:54 -0700, Christoph Lameter wrote:
> > BTW there is no guarantee the node size is a multiple of 128MB so
> > you likely need to handle the overlap case. Otherwise we can 
> > get cache corruptions
> 
> How does sparsemem handle that? 

It doesn't. :)

In practice, this situation never happens because we don't have any
actual architectures that have any node boundaries on less than
MAX_ORDER, and the section size is at least MAX_ORDER.  If we *did* have
this, then the page allocator would already be broken for these
nodes. ;)

So, this SPARSE_VIRTUAL does introduce a new dependency, which Andi
calculated above.  But, in reality, I don't think it's a big deal.  Just
to spell it out a bit more, if this:

	VMEMMAP_MAPPING_SIZE/sizeof(struct page) * PAGE_SIZE

(where VMEMMAP_MAPPING_SIZE is PMD_SIZE in your case) is any larger than
the granularity on which your NUMA nodes are divided, then you might
have a problem with mem_map for one NUMA node getting allocated on
another.  

It might be worth a comment, or at least some kind of WARN_ON().
Perhaps we can stick something in online_page() to check if:

	page_to_nid(page) == page_to_nid(virt_to_page(page))

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
