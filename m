Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id 022C36B0031
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 07:34:38 -0500 (EST)
Received: by mail-la0-f52.google.com with SMTP id y1so7056616lam.39
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 04:34:38 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id ww4si18412380lbb.42.2013.12.03.04.34.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 03 Dec 2013 04:34:37 -0800 (PST)
Message-ID: <529DCFC2.5010400@parallels.com>
Date: Tue, 3 Dec 2013 16:34:10 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v12 12/18] fs: make icache, dcache shrinkers memcg-aware
References: <cover.1385974612.git.vdavydov@parallels.com> <8e7582ad42f35cd9a9ea274bd203e2423b944b62.1385974612.git.vdavydov@parallels.com> <20131203114557.GS10988@dastard>
In-Reply-To: <20131203114557.GS10988@dastard>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: hannes@cmpxchg.org, mhocko@suse.cz, dchinner@redhat.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, glommer@openvz.org, Al Viro <viro@zeniv.linux.org.uk>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On 12/03/2013 03:45 PM, Dave Chinner wrote:
> On Mon, Dec 02, 2013 at 03:19:47PM +0400, Vladimir Davydov wrote:
>> Using the per-memcg LRU infrastructure introduced by previous patches,
>> this patch makes dcache and icache shrinkers memcg-aware. To achieve
>> that, it converts s_dentry_lru and s_inode_lru from list_lru to
>> memcg_list_lru and restricts the reclaim to per-memcg parts of the lists
>> in case of memcg pressure.
>>
>> Other FS objects are currently ignored and only reclaimed on global
>> pressure, because their shrinkers are heavily FS-specific and can't be
>> converted to be memcg-aware so easily. However, we can pass on target
>> memcg to the FS layer and let it decide if per-memcg objects should be
>> reclaimed.
> And now you have a big problem, because that means filesystems like
> XFS won't reclaim inodes during memcg reclaim.
>
> That is, for XFS, prune_icache_lru() does not free any memory. All
> it does is remove all the VFS references to the struct xfs_inode,
> which is then reclaimed via the sb->s_op->free_cached_objects()
> method.
>
> IOWs, what you've done is broken.

Missed that, thanks for pointing out.

>
>> Note that with this patch applied we lose global LRU order, but it does
> We don't have global LRU order today for the filesystem caches.
> We have per superblock, per-node LRU reclaim order.
>
>> --- a/fs/dcache.c
>> +++ b/fs/dcache.c
>> @@ -343,18 +343,24 @@ static void dentry_unlink_inode(struct dentry * dentry)
>>  #define D_FLAG_VERIFY(dentry,x) WARN_ON_ONCE(((dentry)->d_flags & (DCACHE_LRU_LIST | DCACHE_SHRINK_LIST)) != (x))
>>  static void d_lru_add(struct dentry *dentry)
>>  {
>> +	struct list_lru *lru =
>> +		mem_cgroup_kmem_list_lru(&dentry->d_sb->s_dentry_lru, dentry);
>> +
>>  	D_FLAG_VERIFY(dentry, 0);
>>  	dentry->d_flags |= DCACHE_LRU_LIST;
>>  	this_cpu_inc(nr_dentry_unused);
>> -	WARN_ON_ONCE(!list_lru_add(&dentry->d_sb->s_dentry_lru, &dentry->d_lru));
>> +	WARN_ON_ONCE(!list_lru_add(lru, &dentry->d_lru));
>>  }
> This is what I mean about pushing memcg cruft into places where it
> is not necessary. This can be done entirely behind list_lru_add(),
> without the caller having to care.
>
>> @@ -970,9 +976,9 @@ dentry_lru_isolate(struct list_head *item, spinlock_t *lru_lock, void *arg)
>>  }
>>  
>>  /**
>> - * prune_dcache_sb - shrink the dcache
>> - * @sb: superblock
>> - * @nr_to_scan : number of entries to try to free
>> + * prune_dcache_lru - shrink the dcache
>> + * @lru: dentry lru list
>> + * @nr_to_scan: number of entries to try to free
>>   * @nid: which node to scan for freeable entities
>>   *
>>   * Attempt to shrink the superblock dcache LRU by @nr_to_scan entries. This is
>> @@ -982,14 +988,13 @@ dentry_lru_isolate(struct list_head *item, spinlock_t *lru_lock, void *arg)
>>   * This function may fail to free any resources if all the dentries are in
>>   * use.
>>   */
>> -long prune_dcache_sb(struct super_block *sb, unsigned long nr_to_scan,
>> -		     int nid)
>> +long prune_dcache_lru(struct list_lru *lru, unsigned long nr_to_scan, int nid)
>>  {
>>  	LIST_HEAD(dispose);
>>  	long freed;
>>  
>> -	freed = list_lru_walk_node(&sb->s_dentry_lru, nid, dentry_lru_isolate,
>> -				       &dispose, &nr_to_scan);
>> +	freed = list_lru_walk_node(lru, nid, dentry_lru_isolate,
>> +				   &dispose, &nr_to_scan);
>>  	shrink_dentry_list(&dispose);
>>  	return freed;
>>  }
> And here, you pass an LRU when what we really need to pass is the
> struct shrink_control that contains nr_to_scan, nid, and the memcg
> that pruning is targetting.
>
> Because of the tight integration of the LRUs and shrinkers, it makes
> sense to pass the shrink control all the way into the list. i.e:
>
> 	freed = list_lru_scan(&sb->s_dentry_lru, sc, dentry_lru_isolate,
> 			      &dispose);
>
> And again, that hides everything to do with memcg based LRUs and
> reclaim from the callers. It's clean, simple and hard to get wrong.
>
>> @@ -1029,7 +1034,7 @@ void shrink_dcache_sb(struct super_block *sb)
>>  	do {
>>  		LIST_HEAD(dispose);
>>  
>> -		freed = list_lru_walk(&sb->s_dentry_lru,
>> +		freed = memcg_list_lru_walk_all(&sb->s_dentry_lru,
>>  			dentry_lru_isolate_shrink, &dispose, UINT_MAX);
>>  
> list_lru_walk() is, by definition, supposed to walk every single
> object on the LRU. With memcg awareness, it should be walking all
> the memcg lists, too.
>
>> diff --git a/fs/super.c b/fs/super.c
>> index cece164..b198da4 100644
>> --- a/fs/super.c
>> +++ b/fs/super.c
>> @@ -57,6 +57,8 @@ static unsigned long super_cache_scan(struct shrinker *shrink,
>>  				      struct shrink_control *sc)
>>  {
>>  	struct super_block *sb;
>> +	struct list_lru *inode_lru;
>> +	struct list_lru *dentry_lru;
>>  	long	fs_objects = 0;
>>  	long	total_objects;
>>  	long	freed = 0;
>> @@ -75,11 +77,14 @@ static unsigned long super_cache_scan(struct shrinker *shrink,
>>  	if (!grab_super_passive(sb))
>>  		return SHRINK_STOP;
>>  
>> -	if (sb->s_op->nr_cached_objects)
>> +	if (sb->s_op->nr_cached_objects && !sc->memcg)
>>  		fs_objects = sb->s_op->nr_cached_objects(sb, sc->nid);
>>  
>> -	inodes = list_lru_count_node(&sb->s_inode_lru, sc->nid);
>> -	dentries = list_lru_count_node(&sb->s_dentry_lru, sc->nid);
>> +	inode_lru = mem_cgroup_list_lru(&sb->s_inode_lru, sc->memcg);
>> +	dentry_lru = mem_cgroup_list_lru(&sb->s_dentry_lru, sc->memcg);
>> +
>> +	inodes = list_lru_count_node(inode_lru, sc->nid);
>> +	dentries = list_lru_count_node(dentry_lru, sc->nid);
>>  	total_objects = dentries + inodes + fs_objects + 1;
> Again: list_lru_count_sc(&sb->s_inode_lru, sc).
>
> And push the scan control down into ->nr_cached_objects, too.

Thanks for the tip! Now I see your point, it would really look better if
we used shrink_control here.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
