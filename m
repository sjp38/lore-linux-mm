Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id B521E6B0032
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 02:27:00 -0400 (EDT)
Message-ID: <51777B1E.5010901@parallels.com>
Date: Wed, 24 Apr 2013 10:26:38 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] vmpressure: in-kernel notifications
References: <1366705329-9426-1-git-send-email-glommer@openvz.org> <1366705329-9426-2-git-send-email-glommer@openvz.org> <20130423202446.GA2484@teo>
In-Reply-To: <20130423202446.GA2484@teo>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton@enomsg.org>
Cc: Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, John Stultz <john.stultz@linaro.org>, Joonsoo Kim <js1304@gmail.com>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On 04/24/2013 12:24 AM, Anton Vorontsov wrote:
> On Tue, Apr 23, 2013 at 12:22:08PM +0400, Glauber Costa wrote:
>> From: Glauber Costa <glommer@parallels.com>
>>
>> This patch extends that to also support in-kernel users. Events that
>> should be generated for in-kernel consumption will be marked as such,
>> and for those, we will call a registered function instead of triggering
>> an eventfd notification.
>
> Just a couple more questions... :-)
>
> [...]
>> @@ -238,14 +244,16 @@ void vmpressure(gfp_t gfp, struct mem_cgroup *memcg,
>>   	 * through vmpressure_prio(). But so far, keep calm.
>>   	 */
>>   	if (!scanned)
>> -		return;
>> +		goto schedule;
>>
>>   	mutex_lock(&vmpr->sr_lock);
>>   	vmpr->scanned += scanned;
>>   	vmpr->reclaimed += reclaimed;
>> +	vmpr->notify_userspace = true;
>
> Setting the variable on every event seems a bit wasteful... does it make
> sense to set it in vmpressure_register_event()? We'll have to make it a
> counter, but the good thing is that we won't need any additional locks for
> the counter.
>
Yes, vmpressure_register_event would be a better place for it. I will 
change and keep the acks, since it does not change the spirit of the 
patch too much.

I will also apply the cosmetics you attached. Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
