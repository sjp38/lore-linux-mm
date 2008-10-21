Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9L8chca032208
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 21 Oct 2008 17:38:43 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 723A22AC026
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 17:38:43 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D10312C047
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 17:38:43 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1AF3A1DB803A
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 17:38:43 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B57351DB8042
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 17:38:42 +0900 (JST)
Date: Tue, 21 Oct 2008 17:38:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [memcg BUG] unable to handle kernel NULL pointer derefence at
 00000000
Message-Id: <20081021173817.892a9099.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081021083454.GA2427@csn.ul.ie>
References: <6599ad830810201253u3bca41d4rabe48eb1ec1d529f@mail.gmail.com>
	<20081021101430.d2629a81.kamezawa.hiroyu@jp.fujitsu.com>
	<48FD6901.6050301@linux.vnet.ibm.com>
	<20081021143955.eeb86d49.kamezawa.hiroyu@jp.fujitsu.com>
	<48FD74AB.9010307@cn.fujitsu.com>
	<20081021155454.db6888e4.kamezawa.hiroyu@jp.fujitsu.com>
	<48FD7EEF.3070803@cn.fujitsu.com>
	<20081021161621.bb51af90.kamezawa.hiroyu@jp.fujitsu.com>
	<48FD82E3.9050502@cn.fujitsu.com>
	<20081021171801.4c16c295.kamezawa.hiroyu@jp.fujitsu.com>
	<20081021083454.GA2427@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Li Zefan <lizf@cn.fujitsu.com>, balbir@linux.vnet.ibm.com, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 21 Oct 2008 09:34:54 +0100
mel@skynet.ie (Mel Gorman) wrote:

> On Tue, Oct 21, 2008 at 05:18:01PM +0900, KAMEZAWA Hiroyuki wrote:
> > On Tue, 21 Oct 2008 15:21:07 +0800
> > Li Zefan <lizf@cn.fujitsu.com> wrote:
> > > dmesg is attached.
> > > 
> > Thanks....I think I caught some. (added Mel Gorman to CC:)
> > 
> > NODE_DATA(nid)->spanned_pages just means sum of zone->spanned_pages in node.
> > 
> > So, If there is a hole between zone, node->spanned_pages doesn't mean
> > length of node's memmap....(then, some hole can be skipped.)
> > 
> 
> This is correct. pgdat->node_spanned_pages is the range of PFNs the node
> covers. In some cases, this can even overlap other nodes. There can be
> memory holes and there is no guarantee there is memmap present for the holes.
> The number of actual pages is pgdat->node_present_pages.
> 

Thank you for clarification.

> > OMG....Could you try this ? 
> > 
> > -Kame
> > ==
> > NODE_DATA(nid)->node_spanned_pages doesn't means width of node's memory
> > but means sum of spanned_pages in all zones of node.
> > 
> 
> Does not necessarily mean that either. Conceivably there could be gaps
> between the zones.
> 
I see.

> > alloc_node_page_cgroup() misunderstand it. This patch tries to use
> > the same algorithm as alloc_node_mem_map() for allocating page_cgroup()
> > for node.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> >  mm/page_cgroup.c |   17 ++++++++++++++---
> >  1 file changed, 14 insertions(+), 3 deletions(-)
> > 
> > Index: linux-2.6.27/mm/page_cgroup.c
> > ===================================================================
> > --- linux-2.6.27.orig/mm/page_cgroup.c
> > +++ linux-2.6.27/mm/page_cgroup.c
> > @@ -41,10 +41,18 @@ static int __init alloc_node_page_cgroup
> >  {
> >  	struct page_cgroup *base, *pc;
> >  	unsigned long table_size;
> > -	unsigned long start_pfn, nr_pages, index;
> > +	unsigned long start, end, start_pfn, nr_pages, index;
> >  
> > -	start_pfn = NODE_DATA(nid)->node_start_pfn;
> > -	nr_pages = NODE_DATA(nid)->node_spanned_pages;
> > +	/*
> > +	 * Instead of allocating page_cgroup for [start, end)
> > +	 * We allocate page_cgroup to the same size of mem_map.
> > +	 * See page_alloc.c::alloc_node_mem_map()
> > +	 */
> > +	start = NODE_DATA(nid)->node_start_pfn & ~(MAX_ORDER_NR_PAGES - 1);
> > +	end = NODE_DATA(nid)->node_start_pfn
> > +			+ NODE_DATA(nid)->node_spanned_pages;
> > +	end = ALIGN(end, MAX_ORDER_NR_PAGES);
> > +	nr_pages = end - start;
> >  
> 
> I don't know what this function is doing, but that will calculate nr_pages
> to be the full width of a node, holes and all which is what I think you're
> trying to do. Again, remember this could cover another node as you can have
> a situation where the pfn ranges are
> 
>       node1_pages   |   node0_pages	|  node1_pages
> start <---------------------------------------------->end
> 
> Maybe this is not a problem for you. It all depends on how you map a PFN
> to a table. There is also a concern for memory usage as;
> 
> >  	table_size = sizeof(struct page_cgroup) * nr_pages;
> >  
> 
> this is potentially a very large table.
> 

yes. I know. usual big-address-space people will use SPARSEMEM version.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
