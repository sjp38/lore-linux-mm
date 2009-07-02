Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E1F226B004D
	for <linux-mm@kvack.org>; Thu,  2 Jul 2009 01:57:31 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n625xitg020887
	for <linux-mm@kvack.org> (envelope-from y-goto@jp.fujitsu.com);
	Thu, 2 Jul 2009 14:59:44 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1A63B45DE4F
	for <linux-mm@kvack.org>; Thu,  2 Jul 2009 14:59:44 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DC9A645DE52
	for <linux-mm@kvack.org>; Thu,  2 Jul 2009 14:59:43 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A91F3E0800C
	for <linux-mm@kvack.org>; Thu,  2 Jul 2009 14:59:43 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 452FA1DB803B
	for <linux-mm@kvack.org>; Thu,  2 Jul 2009 14:59:43 +0900 (JST)
Date: Thu, 02 Jul 2009 14:59:19 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: + memory-hotplug-alloc-page-from-other-node-in-memory-online.patch added to -mm tree
In-Reply-To: <20090702102208.ff480a2d.kamezawa.hiroyu@jp.fujitsu.com>
References: <1246497073.18688.28.camel@localhost.localdomain> <20090702102208.ff480a2d.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20090702144415.8B21.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: yakui <yakui.zhao@intel.com>, "Li, Shaohua" <shaohua.li@intel.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> On Thu, 02 Jul 2009 09:11:13 +0800
> yakui <yakui.zhao@intel.com> wrote:
> 
> > On Thu, 2009-07-02 at 01:22 +0800, Christoph Lameter wrote:
> > > On Wed, 1 Jul 2009, yakui wrote:
> > > 
> > > > If we can't allocate memory from other node when there is no memory on
> > > > this node, we will have to do something like the bootmem allocator.
> > > > After the memory page is added to the system memory, we will have to
> > > > free the memory space used by the memory allocator. At the same time we
> > > > will have to assure that the hot-plugged memory exists physically.
> > > 
> > > The bootmem allocator must stick around it seems. Its more like a node
> > > bootstrap allocator then.
> > > 
> > > Maybe we can generalize that. The bootstrap allocator may only need to be
> > > able boot one node (which simplifies design). During system bringup only
> > > the boot node is brought up.
> > > 
> > > Then the other nodes are hotplugged later all in turn using the bootstrap
> > > allocator for their node setup?
> > Your idea looks fragrant. But it seems that it is difficult to realize.
> > In the boot phase the bootmem allocator is initialized. And after the
> > page buddy mechanism is enabled, the memory space used by bootmem
> > allocator will be freed.
> > 
> > If we also do the similar thing for the hotplugged node, how and when to
> > free the memory space used by the bootstrap allocator? It seems that we
> > will have to wait before all the memory sections are onlined for this
> > hotplugged node. And before all the memory sections are onlined, the
> > bootstrap allocator and buddy page allocator will co-exist.
> > 
> 
> When I was an eager developper of memory hotplug, I planned that.
> A special page allocater which works from allocating pgdat until memmap setup.
> But there were problems.
> example)
>   1. We wanted to reuse bootmem.c but it was difficult.
>   2. IBM guys uses 16MB section. Then, they cannot allocate local pgdat/memmap
>     as other platform which have larger section size.
>   3. At memory hotplug, "memory section which includes pgdat for a node should be
>      removed after all other sections on the node are removed"
>      There is the same problem to memmap.
> 
> Because current memory hotplug works sane and above problem was too complicated for
> me, I stopped. But there are more NUMAs than we implemented memory hotplug initially.
> I hope someone fixes this mis-allocation problem.
> 
> IIUC, "3" is the worst problem. It creates dependency among memory.

I made tiny basic functions to make it 1 or 2 years ago.
get_page_bootmem() record section/node id or counting up
how many other pages use it. It would be used for dependency
checking when removing memory.
I was going to make new allocator with those information.
(put_page_bootmem() is to free them.)

However, I don't enough time for memory hotplug now, 
and they are just redundant functions now.
If someone create new allocator (and unifying bootmem allocator),
I'm very glad. :-)


Bye.


-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
