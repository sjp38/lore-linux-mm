Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 2DA0C6B00DC
	for <linux-mm@kvack.org>; Tue,  7 May 2013 11:30:13 -0400 (EDT)
Message-ID: <51891DF6.6060007@oracle.com>
Date: Tue, 07 May 2013 23:29:58 +0800
From: Jeff Liu <jeff.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] memcg: replace memparse to avoid input overflow
References: <1367768681-4451-1-git-send-email-handai.szj@taobao.com> <20130507141208.GD9497@dhcp22.suse.cz> <51891816.806@oracle.com> <20130507151508.GF9497@dhcp22.suse.cz>
In-Reply-To: <20130507151508.GF9497@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Sha Zhengju <handai.szj@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, nishimura@mxp.nes.nec.co.jp, akpm@linux-foundation.org, Sha Zhengju <handai.szj@taobao.com>

On 05/07/2013 11:15 PM, Michal Hocko wrote:
> On Tue 07-05-13 23:04:54, Jeff Liu wrote:
>> On 05/07/2013 10:12 PM, Michal Hocko wrote:
>>> On Sun 05-05-13 23:44:41, Sha Zhengju wrote:
>>>> memparse() doesn't check if overflow has happens, and it even has no
>>>> args to inform user that the unexpected situation has occurred. Besides,
>>>> some of its callers make a little artful use of the current implementation
>>>> and it also seems to involve too much if changing memparse() interface.
>>>>
>>>> This patch rewrites memcg's internal res_counter_memparse_write_strategy().
>>>> It doesn't use memparse() any more and replaces simple_strtoull() with
>>>> kstrtoull() to avoid input overflow.
>>>
>>> I do not like this to be honest. I do not think we should be really
>>> worried about overflows here. Or where this turned out to be a real
>>> issue? 
>> Yes. e.g.
>> Without this validation, user could specify a big value larger than ULLONG_MAX
>> which would result in 0 because of an overflow.  Even worse, all the processes
>> belonging to this group will be killed by OOM-Killer in this situation.
> 
> I would consider this to be a configuration problem.
It mostly should be a problem of configuration.
>  
>>> The new implementation is inherently slower without a good
>>> reason.
>> In talking about this, I also concerned for the overhead as per an offline
>> discussion with Sha when she wrote this fix.  However, can we consider it to be
>> a tradeoff as this helper is not being used in any hot path?
> 
> what is the positive part of the trade off? Fixing a potential overflow
> when somebody sets a limit to an unreasonable value?
I suppose it to be a defense for unreasonable value because this issue
is found on a production environment for an incorrect manipulation, but
it's up to you.

Thanks,
-Jeff
> 
>> That's why we didn't directly touch memparse(), but extracted those codes for
>> parsing memory string out of it to res_counter_memparse_write_strategy() instead.
>>
>> Thanks,
>> -Jeff
>>>
>>>> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
>>>> ---
>>>>  kernel/res_counter.c |   41 ++++++++++++++++++++++++++++++++++++-----
>>>>  1 file changed, 36 insertions(+), 5 deletions(-)
>>>>
>>>> diff --git a/kernel/res_counter.c b/kernel/res_counter.c
>>>> index be8ddda..a990e8e0 100644
>>>> --- a/kernel/res_counter.c
>>>> +++ b/kernel/res_counter.c
>>>> @@ -182,19 +182,50 @@ int res_counter_memparse_write_strategy(const char *buf,
>>>>  {
>>>>  	char *end;
>>>>  	unsigned long long res;
>>>> +	int ret, len, suffix = 0;
>>>> +	char *ptr;
>>>>  
>>>>  	/* return RES_COUNTER_MAX(unlimited) if "-1" is specified */
>>>>  	if (*buf == '-') {
>>>> -		res = simple_strtoull(buf + 1, &end, 10);
>>>> -		if (res != 1 || *end != '\0')
>>>> +		ret = kstrtoull(buf + 1, 10, &res);
>>>> +		if (res != 1 || ret)
>>>>  			return -EINVAL;
>>>>  		*resp = RES_COUNTER_MAX;
>>>>  		return 0;
>>>>  	}
>>>>  
>>>> -	res = memparse(buf, &end);
>>>> -	if (*end != '\0')
>>>> -		return -EINVAL;
>>>> +	len = strlen(buf);
>>>> +	end = buf + len - 1;
>>>> +	switch (*end) {
>>>> +	case 'G':
>>>> +	case 'g':
>>>> +		suffix ++;
>>>> +	case 'M':
>>>> +	case 'm':
>>>> +		suffix ++;
>>>> +	case 'K':
>>>> +	case 'k':
>>>> +		suffix ++;
>>>> +		len --;
>>>> +	default:
>>>> +		break;
>>>> +	}
>>>> +
>>>> +	ptr = kmalloc(len + 1, GFP_KERNEL);
>>>> +	if (!ptr) return -ENOMEM;
>>>> +
>>>> +	strlcpy(ptr, buf, len + 1);
>>>> +	ret = kstrtoull(ptr, 0, &res);
>>>> +	kfree(ptr);
>>>> +	if (ret) return -EINVAL;
>>>> +
>>>> +	while (suffix) {
>>>> +		/* check for overflow while multiplying suffix number */
>>>> +		if (unlikely(res & (~0ull << 54)))
>>>> +			return -EINVAL;
>>>> +		res <<= 10;
>>>> +		suffix --;
>>>> +	}
>>>>  
>>>>  	if (PAGE_ALIGN(res) >= res)
>>>>  		res = PAGE_ALIGN(res);
>>>> -- 
>>>> 1.7.9.5
>>>>
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe cgroups" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
