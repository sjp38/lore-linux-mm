Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 0AF3E6007F3
	for <linux-mm@kvack.org>; Sun, 18 Jul 2010 05:45:28 -0400 (EDT)
Received: by pzk33 with SMTP id 33so1337053pzk.14
        for <linux-mm@kvack.org>; Sun, 18 Jul 2010 02:45:27 -0700 (PDT)
Message-ID: <4C42CD52.3070601@vflare.org>
Date: Sun, 18 Jul 2010 15:15:54 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: Re: [PATCH 2/8] Basic zcache functionality
References: <1279283870-18549-1-git-send-email-ngupta@vflare.org> <1279283870-18549-3-git-send-email-ngupta@vflare.org> <4C42B7EA.4020409@cs.helsinki.fi>
In-Reply-To: <4C42B7EA.4020409@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, Christoph Hellwig <hch@infradead.org>, Minchan Kim <minchan.kim@gmail.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


On 07/18/2010 01:44 PM, Pekka Enberg wrote:
> Nitin Gupta wrote:
>> +/*
>> + * Individual percpu values can go negative but the sum across all CPUs
>> + * must always be positive (we store various counts). So, return sum as
>> + * unsigned value.
>> + */
>> +static u64 zcache_get_stat(struct zcache_pool *zpool,
>> +        enum zcache_pool_stats_index idx)
>> +{
>> +    int cpu;
>> +    s64 val = 0;
>> +
>> +    for_each_possible_cpu(cpu) {
>> +        unsigned int start;
>> +        struct zcache_pool_stats_cpu *stats;
>> +
>> +        stats = per_cpu_ptr(zpool->stats, cpu);
>> +        do {
>> +            start = u64_stats_fetch_begin(&stats->syncp);
>> +            val += stats->count[idx];
>> +        } while (u64_stats_fetch_retry(&stats->syncp, start));
> 
> Can we use 'struct percpu_counter' for this? OTOH, the warning on top of include/linux/percpu_counter.h makes me think not.
>

Yes, that warning only scared me :)

 
>> +    }
>> +
>> +    BUG_ON(val < 0);
> 
> BUG_ON() seems overly aggressive. How about
> 
>   if (WARN_ON(val < 0))
>           return 0;
> 

Yes, this sounds better. I will change it.


>> +    return val;
>> +}
>> +
>> +static void zcache_add_stat(struct zcache_pool *zpool,
>> +        enum zcache_pool_stats_index idx, s64 val)
>> +{
>> +    struct zcache_pool_stats_cpu *stats;
>> +
>> +    preempt_disable();
>> +    stats = __this_cpu_ptr(zpool->stats);
>> +    u64_stats_update_begin(&stats->syncp);
>> +    stats->count[idx] += val;
>> +    u64_stats_update_end(&stats->syncp);
>> +    preempt_enable();
> 
> What is the preempt_disable/preempt_enable trying to do here?
>

On 32-bit there will be no seqlock to protect this value. So, if we
get preempted after __this_cpu_ptr(), two CPUs can end up racy-writing
to the same variable. I think for the same reason this_cpu_add() finally
does increment with preempt disabled.

Also, I think we shouldn't use this_cpu_add (as you suggested in
another mail) since we have to do this_cpu_ptr() first to get access
to seqlock (stats->syncp) anyways. So, simple increment on thus
obtained pcpu pointer should be okay.

 
>> +static void zcache_destroy_pool(struct zcache_pool *zpool)
>> +{
>> +    int i;
>> +
>> +    if (!zpool)
>> +        return;
>> +
>> +    spin_lock(&zcache->pool_lock);
>> +    zcache->num_pools--;
>> +    for (i = 0; i < MAX_ZCACHE_POOLS; i++)
>> +        if (zcache->pools[i] == zpool)
>> +            break;
>> +    zcache->pools[i] = NULL;
>> +    spin_unlock(&zcache->pool_lock);
>> +
>> +    if (!RB_EMPTY_ROOT(&zpool->inode_tree)) {
> 
> Use WARN_ON here to get a stack trace?
>

This sounds better, will change it.

 
>> +        pr_warn("Memory leak detected. Freeing non-empty pool!\n");
>> +        zcache_dump_stats(zpool);
>> +    }
>> +
>> +    free_percpu(zpool->stats);
>> +    kfree(zpool);
>> +}
>> +
>> +/*
>> + * Allocate a new zcache pool and set default memlimit.
>> + *
>> + * Returns pool_id on success, negative error code otherwise.
>> + */
>> +int zcache_create_pool(void)
>> +{
>> +    int ret;
>> +    u64 memlimit;
>> +    struct zcache_pool *zpool = NULL;
>> +
>> +    spin_lock(&zcache->pool_lock);
>> +    if (zcache->num_pools == MAX_ZCACHE_POOLS) {
>> +        spin_unlock(&zcache->pool_lock);
>> +        pr_info("Cannot create new pool (limit: %u)\n",
>> +                    MAX_ZCACHE_POOLS);
>> +        ret = -EPERM;
>> +        goto out;
>> +    }
>> +    zcache->num_pools++;
>> +    spin_unlock(&zcache->pool_lock);
>> +
>> +    zpool = kzalloc(sizeof(*zpool), GFP_KERNEL);
>> +    if (!zpool) {
>> +        spin_lock(&zcache->pool_lock);
>> +        zcache->num_pools--;
>> +        spin_unlock(&zcache->pool_lock);
>> +        ret = -ENOMEM;
>> +        goto out;
>> +    }
> 
> Why not kmalloc() an new struct zcache_pool object first and then take zcache->pool_lock() and check for MAX_ZCACHE_POOLS? That should make the locking little less confusing here.
> 

kmalloc() before this check should be better. This also avoids unnecessary
num_pools decrement later if kmalloc fails.


>> +
>> +    src_data = kmap_atomic(page, KM_USER0);
>> +    dest_data = kmap_atomic(zpage, KM_USER1);
>> +    memcpy(dest_data, src_data, PAGE_SIZE);
>> +    kunmap_atomic(src_data, KM_USER0);
>> +    kunmap_atomic(dest_data, KM_USER1);
> 
> copy_highpage()
>

Ok. But we will again have to open-code this memcpy() when we start using
xvmalloc (patch 7/8). Same applies to another instance you pointed out.
 

>> +static int zcache_get_page(int pool_id, ino_t inode_no,
>> +            pgoff_t index, struct page *page)
>> +{
>> +    int ret = -1;
>> +    unsigned long flags;
>> +    struct page *src_page;
>> +    void *src_data, *dest_data;
>> +    struct zcache_inode_rb *znode;
>> +    struct zcache_pool *zpool = zcache->pools[pool_id];
>> +
>> +    znode = zcache_find_inode(zpool, inode_no);
>> +    if (!znode)
>> +        goto out;
>> +
>> +    BUG_ON(znode->inode_no != inode_no);
> 
> Maybe use WARN_ON here and return -1?
>

okay.


Thanks for the review.
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
