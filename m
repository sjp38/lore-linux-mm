Message-ID: <47D8EC5A.20907@openvz.org>
Date: Thu, 13 Mar 2008 11:56:58 +0300
From: Pavel Emelyanov <xemul@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] Make res_counter hierarchical
References: <47D16004.7050204@openvz.org> <20080312230541.CB9021E703D@siro.lan>
In-Reply-To: <20080312230541.CB9021E703D@siro.lan>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: balbir@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, menage@google.com, containers@lists.osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

YAMAMOTO Takashi wrote:
>> @@ -36,10 +37,26 @@ int res_counter_charge(struct res_counter *counter, unsigned long val)
>>  {
>>  	int ret;
>>  	unsigned long flags;
>> +	struct res_counter *c, *unroll_c;
>> +
>> +	local_irq_save(flags);
>> +	for (c = counter; c != NULL; c = c->parent) {
>> +		spin_lock(&c->lock);
>> +		ret = res_counter_charge_locked(c, val);
>> +		spin_unlock(&c->lock);
>> +		if (ret < 0)
>> +			goto unroll;
>> +	}
>> +	local_irq_restore(flags);
>> +	return 0;
>>  
>> -	spin_lock_irqsave(&counter->lock, flags);
>> -	ret = res_counter_charge_locked(counter, val);
>> -	spin_unlock_irqrestore(&counter->lock, flags);
>> +unroll:
>> +	for (unroll_c = counter; unroll_c != c; unroll_c = unroll_c->parent) {
>> +		spin_lock(&unroll_c->lock);
>> +		res_counter_uncharge_locked(unroll_c, val);
>> +		spin_unlock(&unroll_c->lock);
>> +	}
>> +	local_irq_restore(flags);
>>  	return ret;
>>  }
> 
> what prevents the topology (in particular, ->parent pointers) from
> changing behind us?

The res_counter client must provide this. Currently cgroup subsystem does this.

> YAMAMOTO Takashi
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
