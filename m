Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 1B3D76B01B2
	for <linux-mm@kvack.org>; Sun, 27 Jun 2010 22:30:25 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5S2ULJO007323
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 28 Jun 2010 11:30:22 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 69CD045DE61
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 11:30:21 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 22D5645DE57
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 11:30:21 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E658EE08007
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 11:30:20 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 934FE1DB803E
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 11:30:20 +0900 (JST)
Date: Mon, 28 Jun 2010 11:25:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [S+Q 04/16] slub: Use a constant for a unspecified node.
Message-Id: <20100628112550.87fbb1e4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100625212103.443416439@quilx.com>
References: <20100625212026.810557229@quilx.com>
	<20100625212103.443416439@quilx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@suse.de>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Fri, 25 Jun 2010 16:20:30 -0500
Christoph Lameter <cl@linux-foundation.org> wrote:

> kmalloc_node() and friends can be passed a constant -1 to indicate
> that no choice was made for the node from which the object needs to
> come.
> 
> Use NUMA_NO_NODE instead of -1.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
> 
Reviewd-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

How about more updates ?

Hmm, by grep (mmotm)
==
static struct page *get_partial(struct kmem_cache *s, gfp_t flags, int node)
{
        struct page *page;
        int searchnode = (node == -1) ? numa_node_id() : node;
==
==
static inline int node_match(struct kmem_cache_cpu *c, int node)
{
#ifdef CONFIG_NUMA
        if (node != -1 && c->node != node)
                return 0;
#endif
        return 1;
}
==

==
debug:
        if (!alloc_debug_processing(s, c->page, object, addr))
                goto another_slab;

        c->page->inuse++;
        c->page->freelist = get_freepointer(s, object);
        c->node = -1;
        goto unlock_out;
}
==

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
