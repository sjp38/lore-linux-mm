Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0D26F6B0033
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 13:34:25 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id g19so1609202lfh.1
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 10:34:24 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g100sor2279761lji.5.2017.12.18.10.34.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Dec 2017 10:34:23 -0800 (PST)
Subject: Re: [PATCH] mm: vmscan: make unregister_shrinker() safer
References: <20171216192937.13549-1-akaraliou.dev@gmail.com>
 <20171218084948.GK16951@dhcp22.suse.cz>
From: ak <akaraliou.dev@gmail.com>
Message-ID: <04b38213-5330-bf47-8865-eee7e18b8612@gmail.com>
Date: Mon, 18 Dec 2017 21:34:20 +0300
MIME-Version: 1.0
In-Reply-To: <20171218084948.GK16951@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, minchan@kernel.org, linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

On 12/18/2017 11:49 AM, Michal Hocko wrote:

> On Sat 16-12-17 22:29:37, Aliaksei Karaliou wrote:
>> unregister_shrinker() does not have any sanitizing inside so
>> calling it twice will oops because of double free attempt or so.
>> This patch makes unregister_shrinker() safer and allows calling
>> it on resource freeing path without explicit knowledge of whether
>> shrinker was successfully registered or not.
> Tetsuo has made it half way to this already [1]. So maybe we should
> fold shrinker->nr_deferred = NULL to his patch and finally merge it.
>
> [1] http://lkml.kernel.org/r/1511523385-6433-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp
Yeah, no problem from my side.
I'm sorry, it seems that I haven't done enough research to realize that 
someone is already
looking at that place.


The only my concern/question is whether we should also add some paranoid 
stuff in that
extra branch (check that list is empty for example) or not.
>> Signed-off-by: Aliaksei Karaliou <akaraliou.dev@gmail.com>
>> ---
>>   mm/vmscan.c | 4 ++++
>>   1 file changed, 4 insertions(+)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 65c4fa26abfa..7cb56db5e9ca 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -281,10 +281,14 @@ EXPORT_SYMBOL(register_shrinker);
>>    */
>>   void unregister_shrinker(struct shrinker *shrinker)
>>   {
>> +	if (!shrinker->nr_deferred)
>> +		return;
>> +
>>   	down_write(&shrinker_rwsem);
>>   	list_del(&shrinker->list);
>>   	up_write(&shrinker_rwsem);
>>   	kfree(shrinker->nr_deferred);
>> +	shrinker->nr_deferred = NULL;
>>   }
>>   EXPORT_SYMBOL(unregister_shrinker);
>>   
>> -- 
>> 2.11.0
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
