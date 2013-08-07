Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 748576B0031
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 20:55:14 -0400 (EDT)
Message-ID: <52019ACF.1020006@huawei.com>
Date: Wed, 7 Aug 2013 08:54:39 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/mempolicy: return NULL if node is NUMA_NO_NODE in
 get_task_policy
References: <52007660.7070907@huawei.com> <20130806140326.1d0d75874e6be221a432c3bc@linux-foundation.org>
In-Reply-To: <20130806140326.1d0d75874e6be221a432c3bc@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hanjun Guo <guohanjun@huawei.com>

Hi Andrew,

On 2013/8/7 5:03, Andrew Morton wrote:

> On Tue, 6 Aug 2013 12:06:56 +0800 Jianguo Wu <wujianguo@huawei.com> wrote:
> 
>> If node == NUMA_NO_NODE, pol is NULL, we should return NULL instead of
>> do "if (!pol->mode)" check.
>>
>> Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
>> ---
>>  mm/mempolicy.c | 2 ++
>>  1 file changed, 2 insertions(+)
>>
>> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
>> index 4baf12e..e0e3398 100644
>> --- a/mm/mempolicy.c
>> +++ b/mm/mempolicy.c
>> @@ -129,6 +129,8 @@ static struct mempolicy *get_task_policy(struct task_struct *p)
>>  		node = numa_node_id();
>>  		if (node != NUMA_NO_NODE)
>>  			pol = &preferred_node_policy[node];
>> +		else
>> +			return NULL;
>>  
>>  		/* preferred_node_policy is not initialised early in boot */
>>  		if (!pol->mode)
> 
> Well yes, it'll dereference a null pointer
> 
> This is neater, I think:
> 

Yes, this is more readable, Thanks.

> --- a/mm/mempolicy.c~mm-mempolicy-return-null-if-node-is-numa_no_node-in-get_task_policy
> +++ a/mm/mempolicy.c
> @@ -123,16 +123,19 @@ static struct mempolicy preferred_node_p
>  static struct mempolicy *get_task_policy(struct task_struct *p)
>  {
>  	struct mempolicy *pol = p->mempolicy;
> -	int node;
>  
>  	if (!pol) {
> -		node = numa_node_id();
> -		if (node != NUMA_NO_NODE)
> -			pol = &preferred_node_policy[node];
> +		int node = numa_node_id();
>  
> -		/* preferred_node_policy is not initialised early in boot */
> -		if (!pol->mode)
> -			pol = NULL;
> +		if (node != NUMA_NO_NODE) {
> +			pol = &preferred_node_policy[node];
> +			/*
> +			 * preferred_node_policy is not initialised early in
> +			 * boot
> +			 */
> +			if (!pol->mode)
> +				pol = NULL;
> +		}
>  	}
>  
>  	return pol;
> _
> 
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
