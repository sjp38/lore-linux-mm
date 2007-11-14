From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <22200238.1195036142565.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 14 Nov 2007 19:29:02 +0900 (JST)
Subject: Re: Re: [RFC][ for -mm] memory controller enhancements for NUMA [10/10] per-zone-lru
In-Reply-To: <20071114091138.30BA11CD65F@siro.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <20071114091138.30BA11CD65F@siro.lan>
 <20071114175737.d5066644.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: kamezawa.hiroyu@jp.fujitsu.com, containers@lists.osdl.org, linux-mm@kvack.org, hugh@veritas.com, balbir@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

>> +struct mc_lru_head {
>> +	struct list_head active_list[MAX_NR_ZONES];
>> +	struct list_head inactive_list[MAX_NR_ZONES];
>> +};
>> +
>
>i guess
>	struct foo {
>		struct list_head active_list;
>		struct list_head inactive_list;
>	} lists[MAX_NR_ZONES];
>is better.
Ah, yes. I'll change this.


>> @@ -139,8 +144,20 @@ struct mem_cgroup {
>>  	 * Per zone statistics (used for memory reclaim)
>>  	 */
>>  	struct mem_cgroup_zonestat zstat;
>> +#ifndef CONFIG_NUMA
>> +	struct lru_head	local_head;
>> +#endif
>
>	struct mc_lru_head local_lru;
>
thanks, I'll do test with !CONFIG_NUMA in the next post.

>> +static int mem_cgroup_init_lru(struct mem_cgroup *mem)
>> +{
>> +	int zone;
>> +	mem->lrus[0] = &mem->local_lru;
>
>'zone' seems unused.

ok.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
