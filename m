Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id A38C86B0038
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 20:19:38 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id qs7so74819497wjc.4
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 17:19:38 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id i7si90531824wjl.146.2017.01.06.17.19.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jan 2017 17:19:36 -0800 (PST)
Date: Fri, 6 Jan 2017 20:19:31 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: 4.10-rc2 list_lru_isolate list corruption
Message-ID: <20170107011931.GA9698@cmpxchg.org>
References: <20170106052056.jihy5denyxsnfuo5@codemonkey.org.uk>
 <20170106165941.GA19083@cmpxchg.org>
 <20170106195851.7pjpnn5w2bjasc7w@codemonkey.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170106195851.7pjpnn5w2bjasc7w@codemonkey.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@codemonkey.org.uk>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org

On Fri, Jan 06, 2017 at 02:58:51PM -0500, Dave Jones wrote:
> On Fri, Jan 06, 2017 at 11:59:41AM -0500, Johannes Weiner wrote:
>  > diff --git a/lib/radix-tree.c b/lib/radix-tree.c
>  > index 6f382e07de77..0783af1c0ebb 100644
>  > --- a/lib/radix-tree.c
>  > +++ b/lib/radix-tree.c
>  > @@ -640,6 +640,8 @@ static inline void radix_tree_shrink(struct radix_tree_root *root,
>  >  				update_node(node, private);
>  >  		}
>  >  
>  > +		WARN_ON_ONCE(!list_empty(&node->private_list));
>  > +
>  >  		radix_tree_node_free(node);
>  >  	}
>  >  }
> 
> [ 8467.462878] WARNING: CPU: 2 PID: 53 at lib/radix-tree.c:643 delete_node+0x1e4/0x200
> [ 8467.468770] CPU: 2 PID: 53 Comm: kswapd0 Not tainted 4.10.0-rc2-think+ #3 
> [ 8467.480436] Call Trace:
> [ 8467.486213]  dump_stack+0x4f/0x73
> [ 8467.491999]  __warn+0xcb/0xf0
> [ 8467.497769]  warn_slowpath_null+0x1d/0x20
> [ 8467.503566]  delete_node+0x1e4/0x200
> [ 8467.509468]  __radix_tree_delete_node+0xd/0x10
> [ 8467.515425]  shadow_lru_isolate+0xe6/0x220
> [ 8467.521337]  __list_lru_walk_one.isra.4+0x9b/0x190
> [ 8467.527176]  ? memcg_drain_all_list_lrus+0x1d0/0x1d0
> [ 8467.533066]  list_lru_walk_one+0x23/0x30
> [ 8467.538953]  scan_shadow_nodes+0x2e/0x40
> [ 8467.544840]  shrink_slab.part.44+0x23d/0x5d0
> [ 8467.550751]  ? 0xffffffffa023a077
> [ 8467.556639]  shrink_node+0x22c/0x330
> [ 8467.562542]  kswapd+0x392/0x8f0
> [ 8467.568422]  kthread+0x10f/0x150
> [ 8467.574313]  ? mem_cgroup_shrink_node+0x2e0/0x2e0
> [ 8467.580266]  ? kthread_create_on_node+0x60/0x60
> [ 8467.586203]  ret_from_fork+0x29/0x40
> [ 8467.592109] ---[ end trace f790bafb683609d5 ]---

Argh, __radix_tree_delete_node() makes the flawed assumption that only
the immediate branch it's mucking with can collapse. But this warning
points out that a sibling branch can collapse too, including its leaf.

Can you try if this patch fixes the problem?

---
