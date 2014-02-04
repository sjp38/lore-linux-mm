Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	by kanga.kvack.org (Postfix) with ESMTP id 9BA5F6B0035
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 09:50:13 -0500 (EST)
Received: by mail-lb0-f174.google.com with SMTP id l4so6469870lbv.19
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 06:50:12 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id g9si3270752lam.108.2014.02.04.06.50.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Feb 2014 06:50:11 -0800 (PST)
Message-ID: <52F0FE17.1050109@parallels.com>
Date: Tue, 4 Feb 2014 18:49:59 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/8] memcg: export kmemcg cache id via cgroup fs
References: <cover.1391356789.git.vdavydov@parallels.com> <570a97e4dfaded0939a9ddbea49055019dcc5803.1391356789.git.vdavydov@parallels.com> <20140204144033.GE4890@dhcp22.suse.cz>
In-Reply-To: <20140204144033.GE4890@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: akpm@linux-foundation.org, rientjes@google.com, penberg@kernel.org, cl@linux.com, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org

On 02/04/2014 06:40 PM, Michal Hocko wrote:
> On Sun 02-02-14 20:33:46, Vladimir Davydov wrote:
>> Per-memcg kmem caches are named as follows:
>>
>>   <global-cache-name>(<cgroup-kmem-id>:<cgroup-name>)
>>
>> where <cgroup-kmem-id> is the unique id of the memcg the cache belongs
>> to, <cgroup-name> is the relative name of the memcg on the cgroup fs.
>> Cache names are exposed to userspace for debugging purposes (e.g. via
>> sysfs in case of slub or via dmesg).
> If this is only for debugging purposes then it shouldn't pollute regular
> memcg cgroupfs namespace.
>
>> Using relative names makes it impossible in general (in case the cgroup
>> hierarchy is not flat) to find out which memcg a particular cache
>> belongs to, because <cgroup-kmem-id> is not known to the user. Since
>> using absolute cgroup names would be an overkill,
> I do not consider it an overkill. We are using the full path when
> dumping OOM information so I do not see any reason this should be any
> different.

When we dump information, we simply print the cgroup path to dmesg and
forget about it while the memcg cache's name will leave at least until
the memcg is destroyed. Basically that means PATH_MAX *
NR_KMEM_ACTIVE_MEMCGS * NR_SLAB_CACHES memory overhead at max.

Anyway, I decided to drop this patch, so please see version 2 of this
patchset (you must be in CC):

https://lkml.org/lkml/2014/2/3/268

Thanks.

>
>> let's fix this by
>> exporting the id of kmem-active memcg via cgroup fs file
>> "memory.kmem.id".
>>
>> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> Nacked-by: Michal Hocko <mhocko@suse.cz>
>
>> ---
>>  mm/memcontrol.c |   12 ++++++++++++
>>  1 file changed, 12 insertions(+)
>>
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 53385cd4e6f0..91d242707404 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -3113,6 +3113,14 @@ int memcg_cache_id(struct mem_cgroup *memcg)
>>  	return memcg ? memcg->kmemcg_id : -1;
>>  }
>>  
>> +static s64 mem_cgroup_cache_id_read(struct cgroup_subsys_state *css,
>> +				    struct cftype *cft)
>> +{
>> +	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
>> +
>> +	return memcg_can_account_kmem(memcg) ? memcg_cache_id(memcg) : -1;
>> +}
>> +
>>  static size_t memcg_caches_array_size(int num_groups)
>>  {
>>  	ssize_t size;
>> @@ -6301,6 +6309,10 @@ static struct cftype mem_cgroup_files[] = {
>>  #endif
>>  #ifdef CONFIG_MEMCG_KMEM
>>  	{
>> +		.name = "kmem.id",
>> +		.read_s64 = mem_cgroup_cache_id_read,
>> +	},
>> +	{
>>  		.name = "kmem.limit_in_bytes",
>>  		.private = MEMFILE_PRIVATE(_KMEM, RES_LIMIT),
>>  		.write_string = mem_cgroup_write,
>> -- 
>> 1.7.10.4
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
