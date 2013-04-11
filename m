Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 521D66B0027
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 19:23:00 -0400 (EDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 12 Apr 2013 09:16:00 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 2D6AE2CE804A
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 09:22:56 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3BN9aPZ8389046
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 09:09:36 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3BNMtJp026107
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 09:22:56 +1000
Date: Fri, 12 Apr 2013 07:22:53 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 02/10] staging: zcache: remove zcache_freeze
Message-ID: <20130411232253.GB29398@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1365553560-32258-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1365553560-32258-3-git-send-email-liwanp@linux.vnet.ibm.com>
 <ecb7519b-669a-48e4-b217-a77ecb60afd4@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ecb7519b-669a-48e4-b217-a77ecb60afd4@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>

On Thu, Apr 11, 2013 at 10:13:42AM -0700, Dan Magenheimer wrote:
>> From: Wanpeng Li [mailto:liwanp@linux.vnet.ibm.com]
>> Subject: [PATCH 02/10] staging: zcache: remove zcache_freeze
>> 
>> The default value of zcache_freeze is false and it won't be modified by
>> other codes. Remove zcache_freeze since no routine can disable zcache
>> during system running.
>> 
>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>
>I'd prefer to leave this code in place as it may be very useful
>if/when zcache becomes more tightly integrated into the MM subsystem
>and the rest of the kernel.  And the subtleties for temporarily disabling
>zcache (which is what zcache_freeze does) are non-obvious and
>may cause data loss so if someone wants to add this functionality
>back in later and don't have this piece of code, it may take
>a lot of pain to get it working.
>
>Usage example: All CPUs are fully saturated so it is questionable
>whether spending CPU cycles for compression is wise.  Kernel
>could disable zcache using zcache_freeze.  (Yes, a new entry point
>would need to be added to enable/disable zcache_freeze.)
>
>My two cents... others are welcome to override.
>

Fair enough. ;-)

Regards,
Wanpeng Li 

>> ---
>>  drivers/staging/zcache/zcache-main.c |   55 +++++++++++-----------------------
>>  1 file changed, 18 insertions(+), 37 deletions(-)
>> 
>> diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
>> index e23d814..fe6801a 100644
>> --- a/drivers/staging/zcache/zcache-main.c
>> +++ b/drivers/staging/zcache/zcache-main.c
>> @@ -1118,15 +1118,6 @@ free_and_out:
>>  #endif /* CONFIG_ZCACHE_WRITEBACK */
>> 
>>  /*
>> - * When zcache is disabled ("frozen"), pools can be created and destroyed,
>> - * but all puts (and thus all other operations that require memory allocation)
>> - * must fail.  If zcache is unfrozen, accepts puts, then frozen again,
>> - * data consistency requires all puts while frozen to be converted into
>> - * flushes.
>> - */
>> -static bool zcache_freeze;
>> -
>> -/*
>>   * This zcache shrinker interface reduces the number of ephemeral pageframes
>>   * used by zcache to approximately the same as the total number of LRU_FILE
>>   * pageframes in use, and now also reduces the number of persistent pageframes
>> @@ -1221,44 +1212,34 @@ int zcache_put_page(int cli_id, int pool_id, struct tmem_oid *oidp,
>>  {
>>  	struct tmem_pool *pool;
>>  	struct tmem_handle th;
>> -	int ret = -1;
>> +	int ret = 0;
>>  	void *pampd = NULL;
>> 
>>  	BUG_ON(!irqs_disabled());
>>  	pool = zcache_get_pool_by_id(cli_id, pool_id);
>>  	if (unlikely(pool == NULL))
>>  		goto out;
>> -	if (!zcache_freeze) {
>> -		ret = 0;
>> -		th.client_id = cli_id;
>> -		th.pool_id = pool_id;
>> -		th.oid = *oidp;
>> -		th.index = index;
>> -		pampd = zcache_pampd_create((char *)page, size, raw,
>> -				ephemeral, &th);
>> -		if (pampd == NULL) {
>> -			ret = -ENOMEM;
>> -			if (ephemeral)
>> -				inc_zcache_failed_eph_puts();
>> -			else
>> -				inc_zcache_failed_pers_puts();
>> -		} else {
>> -			if (ramster_enabled)
>> -				ramster_do_preload_flnode(pool);
>> -			ret = tmem_put(pool, oidp, index, 0, pampd);
>> -			if (ret < 0)
>> -				BUG();
>> -		}
>> -		zcache_put_pool(pool);
>> +
>> +	th.client_id = cli_id;
>> +	th.pool_id = pool_id;
>> +	th.oid = *oidp;
>> +	th.index = index;
>> +	pampd = zcache_pampd_create((char *)page, size, raw,
>> +			ephemeral, &th);
>> +	if (pampd == NULL) {
>> +		ret = -ENOMEM;
>> +		if (ephemeral)
>> +			inc_zcache_failed_eph_puts();
>> +		else
>> +			inc_zcache_failed_pers_puts();
>>  	} else {
>> -		inc_zcache_put_to_flush();
>>  		if (ramster_enabled)
>>  			ramster_do_preload_flnode(pool);
>> -		if (atomic_read(&pool->obj_count) > 0)
>> -			/* the put fails whether the flush succeeds or not */
>> -			(void)tmem_flush_page(pool, oidp, index);
>> -		zcache_put_pool(pool);
>> +		ret = tmem_put(pool, oidp, index, 0, pampd);
>> +		if (ret < 0)
>> +			BUG();
>>  	}
>> +	zcache_put_pool(pool);
>>  out:
>>  	return ret;
>>  }
>> --
>> 1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
