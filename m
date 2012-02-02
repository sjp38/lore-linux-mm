Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 0AA296B13F0
	for <linux-mm@kvack.org>; Thu,  2 Feb 2012 05:54:25 -0500 (EST)
Received: by iagz16 with SMTP id z16so4200861iag.14
        for <linux-mm@kvack.org>; Thu, 02 Feb 2012 02:54:25 -0800 (PST)
Message-ID: <4F2A6B5F.3090303@gmail.com>
Date: Thu, 02 Feb 2012 18:54:23 +0800
From: Sha Zhengju <handai.szj@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: make threshold index in the right position
References: <1328175919-11209-1-git-send-email-handai.szj@taobao.com> <20120202101410.GA12291@shutemov.name>
In-Reply-To: <20120202101410.GA12291@shutemov.name>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On 02/02/2012 06:14 PM, Kirill A. Shutemov wrote:
> On Thu, Feb 02, 2012 at 05:45:19PM +0800, Sha Zhengju wrote:
>> From: Sha Zhengju<handai.szj@taobao.com>
>>
>> Index current_threshold may point to threshold that just equal to
>> usage after __mem_cgroup_threshold is triggerd.
> I don't see it. Could you describe conditions?
>
It is because of the following code path in __mem_cgroup_threshold:
{
     ...
         i = t->current_threshold;

         for (; i >= 0 && unlikely(t->entries[i].threshold > usage); i--)
                 eventfd_signal(t->entries[i].eventfd, 1);
         i++;

         for (; i < t->size && unlikely(t->entries[i].threshold <= 
usage); i++)
                 eventfd_signal(t->entries[i].eventfd, 1);

         t->current_threshold = i - 1;
     ...
}

For example:
now:
     threshold array:  3  5  7  9   (usage = 6)
                                    ^
                                 index

next turn:
     threshold array:  3  5  7  9   (usage = 7)
                                        ^
                                     index

after registering a new event(threshold = 10):
     threshold array:  3  5  7  9  10 (usage = 7)
                                    ^
                                 index
>> But after registering
>> a new event, it will change (pointing to threshold just below usage).
>> So make it consistent here.
>>
>> Cc: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
>> Cc: Kirill A. Shutemov<kirill@shutemov.name>
>> Signed-off-by: Sha Zhengju<handai.szj@taobao.com>
>> ---
>>   mm/memcontrol.c |    7 ++++---
>>   1 files changed, 4 insertions(+), 3 deletions(-)
>>
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 22d94f5..79f4a58 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -183,7 +183,7 @@ struct mem_cgroup_threshold {
>>
>>   /* For threshold */
>>   struct mem_cgroup_threshold_ary {
>> -	/* An array index points to threshold just below usage. */
>> +	/* An array index points to threshold just below or equal to usage. */
>>   	int current_threshold;
>>   	/* Size of entries[] */
>>   	unsigned int size;
>> @@ -4319,14 +4319,15 @@ static int mem_cgroup_usage_register_event(struct cgroup *cgrp,
>>   	/* Find current threshold */
>>   	new->current_threshold = -1;
>>   	for (i = 0; i<  size; i++) {
>> -		if (new->entries[i].threshold<  usage) {
>> +		if (new->entries[i].threshold<= usage) {
>>   			/*
>>   			 * new->current_threshold will not be used until
>>   			 * rcu_assign_pointer(), so it's safe to increment
>>   			 * it here.
>>   			 */
>>   			++new->current_threshold;
>> -		}
>> +		} else
>> +			break;
>>   	}
>>
>>   	/* Free old spare buffer and save old primary buffer as spare */
>> -- 
>> 1.7.4.1
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
