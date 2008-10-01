From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <4885269.1222855496500.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 1 Oct 2008 19:04:56 +0900 (JST)
Subject: Re: Re: [PATCH 3/6] memcg: charge-commit-cancel protocl
In-Reply-To: <20081001173313.69fb8c74.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <20081001173313.69fb8c74.nishimura@mxp.nes.nec.co.jp>
 <20081001165233.404c8b9c.kamezawa.hiroyu@jp.fujitsu.com>
	<20081001165734.e484cfe4.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, balbir@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

----- Original Message -----
>> @@ -531,18 +529,33 @@ static int mem_cgroup_charge_common(stru
>>  
>>  		if (!nr_retries--) {
>>  			mem_cgroup_out_of_memory(mem, gfp_mask);
>> -			goto out;
>> +			goto nomem;
>>  		}
>>  	}
>> +	return 0;
>> +nomem:
>> +	css_put(&mem->css);
>> +	return -ENOMEM;
>> +}
>>  
>> +/*
>> + * commit a charge got by mem_cgroup_try_charge() and makes page_cgroup to
 be
>> + * USED state. If already USED, uncharge and return.
>> + */
>> +
>> +static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
>> +				     struct page_cgroup *pc,
>> +				     enum charge_type ctype)
>> +{
>> +	struct mem_cgroup_per_zone *mz;
>> +	unsigned long flags;
>>  
>>  	lock_page_cgroup(pc);
>>  	if (unlikely(PageCgroupUsed(pc))) {
>>  		unlock_page_cgroup(pc);
>>  		res_counter_uncharge(&mem->res, PAGE_SIZE);
>>  		css_put(&mem->css);
>> -
>> -		goto done;
>> +		return;
>>  	}
>>  	pc->mem_cgroup = mem;
>>  	/*
>
>Hmm, this patch cannot be applied because of this part.
>
>After [2/6], mem_cgroup_charge_common looks like:
>
>---
>                if (!nr_retries--) {
>                        mem_cgroup_out_of_memory(mem, gfp_mask);
>                        goto out;
>                }
>        }
>
>
>        lock_page_cgroup(pc);
>
>        if (unlikely(PageCgroupUsed(pc))) {
>                unlock_page_cgroup(pc);
>                res_counter_uncharge(&mem->res, PAGE_SIZE);
>                css_put(&mem->css);
>
>                goto done;
>        }
>        pc->mem_cgroup = mem;
>        /*
>---
>
>There is an empty line after lock_page_cgroup.
>
>After removing this line, I can appliy this patch(and [4-6/6]).
>
Ah, sorry. maybe refresh miss..

I'll check it again tomorrow.

Thanks,
-Kame


>
>Thanks,
>Daisuke Nishimura.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
