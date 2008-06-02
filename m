From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <28005342.1212400352991.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 2 Jun 2008 18:52:32 +0900 (JST)
Subject: Re: Re: [RFC][PATCH 1/2] memcg: res_counter hierarchy
In-Reply-To: <20080602021540.5C6705A0D@siro.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <20080602021540.5C6705A0D@siro.lan>
 <20080530104515.9afefdbb.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, balbir@linux.vnet.ibm.com, xemul@openvz.org, menage@google.com, lizf@cn.fujitsu.com
List-ID: <linux-mm.kvack.org>

----- Original Message -----

>> @@ -135,13 +138,118 @@ ssize_t res_counter_write(struct res_cou
>>  		if (*end != '\0')
>>  			goto out_free;
>>  	}
>> -	spin_lock_irqsave(&counter->lock, flags);
>> -	val = res_counter_member(counter, member);
>> -	*val = tmp;
>> -	spin_unlock_irqrestore(&counter->lock, flags);
>> -	ret = nbytes;
>> +	if (member != RES_LIMIT || !callback) {
>
>is there any reason to check member != RES_LIMIT here,
>rather than in callers?

Hmm...ok. This is messy. I'll rearrange this.


>
>> +/*
>> + * Move resource to its parent.
>> + *   child->limit -= val.
>> + *   parent->usage -= val.
>> + *   parent->limit -= val.
>
>s/limit/for_children/
>
>> + */
>> +
>> +int res_counter_repay_resource(struct res_counter *child,
>> +				struct res_counter *parent,
>> +				unsigned long long val,
>> +				res_shrink_callback_t callback, int retry)
>
>can you reduce gratuitous differences between
>res_counter_borrow_resource and res_counter_repay_resource?
>eg. 'success' vs 'done', how to decrement 'retry'.
>

Ah, sorry. I'll rewrite.
I'll make next version's quality better.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
