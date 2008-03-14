Date: Fri, 14 Mar 2008 11:16:09 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] Move memory controller allocations to their own slabs
 (v3)
In-Reply-To: <20080314115645.e78b7f5c.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0803141100110.19587@blonde.site>
References: <20080313140307.20133.30405.sendpatchset@localhost.localdomain>
 <20080314115645.e78b7f5c.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, 14 Mar 2008, KAMEZAWA Hiroyuki wrote:
> At first, in my understanding,
> - MOVABLE is for migratable pages. (so, not for kernel objects.)
> - RECLAIMABLE is for reclaimable kernel objects. (for slab etc..)
> 
> All reclaimable objects are not necessary to be always reclaimable but
> some amount of RECLAIMABLE objects (not all) should be recraimable easily.
> For example, some of dentry-cache, inode-cache is reclaimable because *unused*
> objects are cached.
> 
> When it comes to page_cgroup, *all* objects has dependency to pages which are
> assigned to.  And user pages are reclaimable.
> There is a similar object....the radix tree. radix-tree's node is allocated as
> RECLAIMABLE object.
> 
> So I think it makes sense to changing page_cgroup to be reclaimable.
> 
> But final decision should be done by how fragmentation avoidance works.
> It's good to test "how many hugepages can be allocated dynamically" when we
> make page_cgroup to be GFP_RECAIMABLE 

I agree with you on all points.  No need for it to be done in the same
patch as Balbir's, but yes, __GFP_RECLAIMABLE appears to be appropriate
for the page_cgroup kmem_cache.

(I think it's a better fit than for the radix_tree_node cache: though
the common pagecache usage of the radix_tree implies that its nodes
are reclaimable, I can't see why radix_tree nodes would intrinsically
be reclaimable.  If a significant non-reclaimable user of radix-tree
comes on the scene, I'd expect us to change that assumption.)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
