Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 071546B0028
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 05:22:00 -0500 (EST)
Message-ID: <5107A2BF.3@oracle.com>
Date: Tue, 29 Jan 2013 18:21:51 +0800
From: Jeff Liu <jeff.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 5/6] memcg: introduce swap_cgroup_init()/swap_cgroup_free()
References: <510658F7.6050806@oracle.com> <51079D10.1050201@parallels.com>
In-Reply-To: <51079D10.1050201@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lord Glauber Costa of Sealand <glommer@parallels.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org

On 01/29/2013 05:57 PM, Lord Glauber Costa of Sealand wrote:
> On 01/28/2013 02:54 PM, Jeff Liu wrote:
>> Introduce swap_cgroup_init()/swap_cgroup_free() to allocate buffers when creating the first
>> non-root memcg and deallocate buffers on the last non-root memcg is gone.
>>
>> Signed-off-by: Jie Liu <jeff.liu@oracle.com>
>> CC: Glauber Costa <glommer@parallels.com>
>> CC: Michal Hocko <mhocko@suse.cz>
>> CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> CC: Johannes Weiner <hannes@cmpxchg.org>
>> CC: Mel Gorman <mgorman@suse.de>
>> CC: Andrew Morton <akpm@linux-foundation.org>
>> CC: Sha Zhengju <handai.szj@taobao.com>
>>
> 
> Looks sane.
> 
> Reviewed-by: Glauber Costa <glommer@parallels.com>
> 
> Only:
> 
>>  #endif /* !__GENERATING_BOUNDS_H */
>> diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
>> index 189fbf5..0ebd127 100644
>> --- a/mm/page_cgroup.c
>> +++ b/mm/page_cgroup.c
>> @@ -362,14 +362,28 @@ static int swap_cgroup_prepare(int type)
>>  	unsigned long idx, max;
>>  
>>  	ctrl = &swap_cgroup_ctrl[type];
>> +	if (!ctrl->length) {
>> +		/*
>> +		 * Bypass the buffer allocation if the corresponding swap
>> +		 * partition/file was turned off.
>> +		 */
>> +		pr_debug("couldn't allocate swap_cgroup on a disabled swap "
>> +			 "partition or file, index: %d\n", type);
>> +		return 0;
>> +	}
>> +
>>  	ctrl->map = vzalloc(ctrl->length * sizeof(void *));
>> -	if (!ctrl->map)
>> +	if (!ctrl->map) {
>> +		ctrl->length = 0;
> 
> Considering moving this assignment somewhere in the exit path in the
> labels region.
Nice point.  Both "ctrl->length = 0" statements in this function should be
moved down to the exit path of "nomem:" label.

Thanks,
-Jeff
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
