Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2541C6B024D
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 12:50:13 -0400 (EDT)
Message-ID: <4C45D3B0.7030202@redhat.com>
Date: Tue, 20 Jul 2010 11:49:52 -0500
From: Eric Sandeen <sandeen@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2 RESEND] fix return value for mb_cache_shrink_fn when
 nr_to_scan > 0
References: <4C430830.9020903@gmail.com> <4C447CE9.20904@redhat.com>
In-Reply-To: <4C447CE9.20904@redhat.com>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wang Sheng-Hui <crosslonelyover@gmail.com>
Cc: linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk, linux-mm@kvack.org, linux-ext4 <linux-ext4@vger.kernel.org>, kernel-janitors <kernel-janitors@vger.kernel.org>, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

Eric Sandeen wrote:

...

> Reviewed-by: Eric Sandeen <sandeen@redhat.com>

Actually retract that, as Andreas pointed out:

>>  fs/mbcache.c |   22 +++++++++++-----------
>>  1 files changed, 11 insertions(+), 11 deletions(-)
>>
>> diff --git a/fs/mbcache.c b/fs/mbcache.c
>> index ec88ff3..5697d9e 100644
>> --- a/fs/mbcache.c
>> +++ b/fs/mbcache.c
>> @@ -201,21 +201,13 @@ mb_cache_shrink_fn(int nr_to_scan, gfp_t gfp_mask)
>>  {
>>  	LIST_HEAD(free_list);
>>  	struct list_head *l, *ltmp;
>> +	struct mb_cache *cache;
>>  	int count = 0;
>>
>> -	spin_lock(&mb_cache_spinlock);

you've lost this spin_lock ...

>> -	list_for_each(l, &mb_cache_list) {
>> -		struct mb_cache *cache =
>> -			list_entry(l, struct mb_cache, c_cache_list);
>> -		mb_debug("cache %s (%d)", cache->c_name,
>> -			  atomic_read(&cache->c_entry_count));
>> -		count += atomic_read(&cache->c_entry_count);
>> -	}
>>  	mb_debug("trying to free %d entries", nr_to_scan);
>> -	if (nr_to_scan == 0) {
>> -		spin_unlock(&mb_cache_spinlock);
>> +	if (nr_to_scan == 0)
>>  		goto out;
>> -	}
>> +

and here you're iterating over it while unlocked....

>>  	while (nr_to_scan-- && !list_empty(&mb_cache_lru_list)) {
>>  		struct mb_cache_entry *ce =
>>  			list_entry(mb_cache_lru_list.next,
                                   struct mb_cache_entry, e_lru_list);
                list_move_tail(&ce->e_lru_list, &free_list);
                __mb_cache_entry_unhash(ce);
        }
        spin_unlock(&mb_cache_spinlock);

.... and here you unlock an unlocked spinlock.

Sorry I missed that.

-Eric

>> @@ -229,6 +221,14 @@ mb_cache_shrink_fn(int nr_to_scan, gfp_t gfp_mask)
>>  						   e_lru_list), gfp_mask);
>>  	}
>>  out:
>> +	spin_lock(&mb_cache_spinlock);
>> +	list_for_each_entry(cache, &mb_cache_list, c_cache_list) {
>> +		mb_debug("cache %s (%d)", cache->c_name,
>> +			  atomic_read(&cache->c_entry_count));
>> +		count += atomic_read(&cache->c_entry_count);
>> +	}
>> +	spin_unlock(&mb_cache_spinlock);
>> +
>>  	return (count / 100) * sysctl_vfs_cache_pressure;
>>  }
>>
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ext4" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
