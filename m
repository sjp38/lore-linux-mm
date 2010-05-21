Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 2784C6B01B1
	for <linux-mm@kvack.org>; Fri, 21 May 2010 00:48:42 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4L4mdf6015321
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 21 May 2010 13:48:39 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 44EA645DE54
	for <linux-mm@kvack.org>; Fri, 21 May 2010 13:48:39 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 26C9345DE51
	for <linux-mm@kvack.org>; Fri, 21 May 2010 13:48:39 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id CACD11DB805D
	for <linux-mm@kvack.org>; Fri, 21 May 2010 13:48:38 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7A2331DB803F
	for <linux-mm@kvack.org>; Fri, 21 May 2010 13:48:38 +0900 (JST)
Date: Fri, 21 May 2010 13:44:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] online CPU before memory failed in pcpu_alloc_pages()
Message-Id: <20100521134424.45e0ee36.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100521105512.0c2cf254.sfr@canb.auug.org.au>
References: <1274163442-7081-1-git-send-email-chaohong_guo@linux.intel.com>
	<20100520134359.fdfb397e.akpm@linux-foundation.org>
	<20100521105512.0c2cf254.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, minskey guo <chaohong_guo@linux.intel.com>, linux-mm@kvack.org, prarit@redhat.com, andi.kleen@intel.com, linux-kernel@vger.kernel.org, minskey guo <chaohong.guo@intel.com>, Tejun Heo <tj@kernel.org>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 21 May 2010 10:55:12 +1000
Stephen Rothwell <sfr@canb.auug.org.au> wrote:

> Hi Andrew,
> 
> On Thu, 20 May 2010 13:43:59 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:
> >
> > > --- a/mm/percpu.c
> > > +++ b/mm/percpu.c
> > > @@ -714,13 +714,29 @@ static int pcpu_alloc_pages(struct pcpu_chunk *chunk,
> > 
> > In linux-next, Tejun has gone and moved pcpu_alloc_pages() into the new
> > mm/percpu-vm.c.  So either
> 
> This has gone into Linus' tree today ...
> 

Hmm, a comment here.

Recently, Lee Schermerhorn developed

 numa-introduce-numa_mem_id-effective-local-memory-node-id-fix2.patch

Then, you can use cpu_to_mem() instead of cpu_to_node() to find the
nearest available node.
I don't check cpu_to_mem() is synchronized with NUMA hotplug but
using cpu_to_mem() rather than adding 
=

+			if ((nid == -1) ||
+			    !(node_zonelist(nid, GFP_KERNEL)->_zonerefs->zone))
+				nid = numa_node_id();
+
==

is better. 

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
