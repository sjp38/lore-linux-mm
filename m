From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <22163671.1206024572593.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 20 Mar 2008 23:49:32 +0900 (JST)
Subject: Re: Re: [PATCH 7/7] memcg: freeing page_cgroup at suitable chance
In-Reply-To: <1205999706.8514.394.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <1205999706.8514.394.camel@twins>
 <20080314185954.5cd51ff6.kamezawa.hiroyu@jp.fujitsu.com>
	 <20080314192253.edb38762.kamezawa.hiroyu@jp.fujitsu.com>
	 <1205962399.6437.30.camel@lappy>
	 <20080320140703.935073df.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, balbir@linux.vnet.ibm.com, xemul@openvz.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

>On Thu, 2008-03-20 at 14:07 +0900, KAMEZAWA Hiroyuki wrote:
>> On Wed, 19 Mar 2008 22:33:19 +0100
>> Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
>> 
>> > > +		if (spin_trylock(&root->tree_lock)) {
>> > > +			/* radix tree is freed by RCU. so they will not call
>> > > +			   free_pages() right now.*/
>> > > +			radix_tree_delete(&root->root_node, idx);
>> > > +			spin_unlock(&root->tree_lock);
>> > > +			/* We can free this in lazy fashion .*/
>> > > +			free_page_cgroup(head);
>> > 
>> > No RCU based freeing? I'd expected a call_rcu(), otherwise we race with
>> > lookups.
>> > 
>> SLAB itself is SLAB_DESTROY_BY_RCU. I'll add comments here.
>
>SLAB_DESTROYED_BY_RCU is not enough, that will just ensure the slab does
>not get invalid, but it does not guarantee the objects will not be
>re-used. So you still have a race here, the lookup can see another
>object than it went for.
>
>Consider:
>
>
>	A				B
>
>rcu_read_lock()
>				spin_lock(&tree_lock)
>				obj = radix_tree_remove(&tree, idx)
>				spin_unlock(&tree_lock)
>
>				kmem_cache_free(s, obj)
>
>obj = radix_tree_lookup(&tree, idx)
>rcu_read_unlock()
>
>				obj2 = kmem_cache_alloc(s)
>				spin_lock(&tree_lock)
>				radix_tree_insert(&tree_lock, idx2)
>				spin_unlock(&tree_lock)
>
>
>return obj->data
>
>
>If B's obj2 == obj (possible), then A will return the object for idx2,
>while it asked for idx.
>
>So A needs an object validate and retry loop, or you need to RCU-free
>objects and extend the rcu_read_lock() range to cover obj's usage.
>
ok. thank you for pointing out and explaining kindly.

I'll fix it.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
