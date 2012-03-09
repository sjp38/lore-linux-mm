Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 8E7946B0083
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 23:35:48 -0500 (EST)
Received: by dadv6 with SMTP id v6so1240256dad.14
        for <linux-mm@kvack.org>; Thu, 08 Mar 2012 20:35:47 -0800 (PST)
Message-ID: <4F598204.9030504@gmail.com>
Date: Fri, 09 Mar 2012 12:07:32 +0800
From: Sha Zhengju <handai.szj@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: Free spare array to avoid memory leak
References: <1331036004-7550-1-git-send-email-handai.szj@taobao.com> <20120309124021.810f5267.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120309124021.810f5267.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, kirill@shutemov.name, Sha Zhengju <handai.szj@taobao.com>

On 03/09/2012 11:40 AM, KAMEZAWA Hiroyuki wrote:
> On Tue,  6 Mar 2012 20:13:24 +0800
> Sha Zhengju<handai.szj@gmail.com>  wrote:
>
>> From: Sha Zhengju<handai.szj@taobao.com>
>>
>> When the last event is unregistered, there is no need to keep the spare
>> array anymore. So free it to avoid memory leak.
>>
>> Signed-off-by: Sha Zhengju<handai.szj@taobao.com>
>>
>> ---
>>   mm/memcontrol.c |    6 ++++++
>>   1 files changed, 6 insertions(+), 0 deletions(-)
>>
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 22d94f5..3c09a84 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -4412,6 +4412,12 @@ static void mem_cgroup_usage_unregister_event(struct cgroup *cgrp,
>>   swap_buffers:
>>   	/* Swap primary and spare array */
>>   	thresholds->spare = thresholds->primary;
>> +	/* If all events are unregistered, free the spare array */
>> +	if (!new) {
>> +		kfree(thresholds->spare);
>> +		thresholds->spare = NULL;
>> +	}
>> +
> Could you clear thresholds->primary ? I don't like a pointer points to freed memory.
Do you meaning I should set a??thresholds->primary = NULLa?? i 1/4 ?
But the following rcu_assign_pointer will do this :

+	/* If all events are unregistered, free the spare array */
+	if (!new) {
+		kfree(thresholds->spare);
+		thresholds->spare = NULL;
+	}
+
  	rcu_assign_pointer(thresholds->primary, new);<---------*HERE*

  	/* To be sure that nobody uses thresholds */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
