Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 146F86B007E
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 20:48:50 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id s73so81289351pfs.0
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 17:48:50 -0700 (PDT)
Received: from smtpbgsg2.qq.com (smtpbgsg2.qq.com. [54.254.200.128])
        by mx.google.com with ESMTPS id zh6si1937232pab.23.2016.06.02.17.48.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Jun 2016 17:48:49 -0700 (PDT)
Subject: Re: [PATCH] mm: Introduce dedicated WQ_MEM_RECLAIM workqueue to do
 lru_add_drain_all
References: <1464853731-8599-1-git-send-email-shhuiw@foxmail.com>
 <20160602143925.GJ14868@mtj.duckdns.org>
From: Wang Sheng-Hui <shhuiw@foxmail.com>
Message-ID: <d9b1b94a-8244-432b-5509-1d742e4fd4b7@foxmail.com>
Date: Fri, 3 Jun 2016 08:48:37 +0800
MIME-Version: 1.0
In-Reply-To: <20160602143925.GJ14868@mtj.duckdns.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: keith.busch@intel.com, peterz@infradead.org, treding@nvidia.com, mingo@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org

Tejun,


On 6/2/2016 10:39 PM, Tejun Heo wrote:
> On Thu, Jun 02, 2016 at 03:48:51PM +0800, Wang Sheng-Hui wrote:
>> +static int __init lru_init(void)
>> +{
>> +	lru_add_drain_wq = alloc_workqueue("lru-add-drain",
>> +		WQ_MEM_RECLAIM | WQ_UNBOUND, 0);
> Why is it unbound?
Sorry, I just pasted from other wq create statement.

WQ_MEM_RECLAIM is the key. Will drop WQ_UNBOUND in new version patch.


>> +	if (WARN(!lru_add_drain_wq,
>> +		"Failed to create workqueue lru_add_drain_wq"))
>> +		return -ENOMEM;
> I don't think we need an explicit warn here.  Doesn't error return
> from an init function trigger boot failure anyway?
Will drop the warn and return -ENOMEM directly on failure.
>> +	return 0;
>> +}
>> +early_initcall(lru_init);
>> +
>>  void lru_add_drain_all(void)
>>  {
>>  	static DEFINE_MUTEX(lock);
>>  	static struct cpumask has_work;
>>  	int cpu;
>>  
>> +	struct workqueue_struct *lru_wq = lru_add_drain_wq ?: system_wq;
>> +
>> +	WARN_ONCE(!lru_add_drain_wq,
>> +		"Use system_wq to do lru_add_drain_all()");
> Ditto.  The system is crashing for sure.  What's the point of this
> warning?
It's for above warn failure. Will crash instead of falling back to system_wq

>
> Thanks.
>
Thanks,
Sheng-Hui


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
