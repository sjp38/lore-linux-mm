Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id 99DBD828E2
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 10:33:39 -0500 (EST)
Received: by mail-qk0-f169.google.com with SMTP id y67so40122927qkc.2
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 07:33:39 -0800 (PST)
Received: from mail-qk0-x235.google.com (mail-qk0-x235.google.com. [2607:f8b0:400d:c09::235])
        by mx.google.com with ESMTPS id 41si7859855qkr.118.2016.01.14.07.33.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jan 2016 07:33:38 -0800 (PST)
Received: by mail-qk0-x235.google.com with SMTP id y67so40121947qkc.2
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 07:33:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160114143847.GD5046@dhcp22.suse.cz>
References: <001a113abaa499606605294b5b17@google.com>
	<20160114143847.GD5046@dhcp22.suse.cz>
Date: Thu, 14 Jan 2016 16:33:38 +0100
Message-ID: <CA+_MTtwZ7Wo-9GsJEb6yH9j3qwL6DFShuUXhHr7whczZVywk_w@mail.gmail.com>
Subject: Re: [PATCH] memcg: Only free spare array when readers are done
From: Martijn Coenen <maco@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jan 14, 2016 at 3:38 PM, Michal Hocko <mhocko@kernel.org> wrote:
> On Thu 14-01-16 14:33:52, Martijn Coenen wrote:
>> A spare array holding mem cgroup threshold events is kept around
>> to make sure we can always safely deregister an event and have an
>> array to store the new set of events in.
>>
>> In the scenario where we're going from 1 to 0 registered events, the
>> pointer to the primary array containing 1 event is copied to the spare
>> slot, and then the spare slot is freed because no events are left.
>> However, it is freed before calling synchronize_rcu(), which means
>> readers may still be accessing threshold->primary after it is freed.
>
> Have you seen this triggering in the real life?
(Sorry for the HTML mess).
It was pretty easy to reproduce in a stress test setup, where we spawn
a process, put it in a mem cgroup and setup the threshold, have it
allocate a lot of memory quickly (crossing the threshold), unregister
the event, kill and repeat. Usually within 30 mins.

>
>>
>> Fixed by only freeing after synchronize_rcu().
>>
>
> Fixes: 8c7577637ca3 ("memcg: free spare array to avoid memory leak")
>> Signed-off-by: Martijn Coenen <maco@google.com>
> Cc: stable
>
> Acked-by: Michal Hocko <mhocko@suse.com>
>
> Thanks!
>
>> ---
>>  mm/memcontrol.c | 11 ++++++-----
>>  1 file changed, 6 insertions(+), 5 deletions(-)
>>
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 14cb1db..73228b6 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -3522,16 +3522,17 @@ static void
>> __mem_cgroup_usage_unregister_event(struct mem_cgroup *memcg,
>>  swap_buffers:
>>       /* Swap primary and spare array */
>>       thresholds->spare = thresholds->primary;
>> -     /* If all events are unregistered, free the spare array */
>> -     if (!new) {
>> -             kfree(thresholds->spare);
>> -             thresholds->spare = NULL;
>> -     }
>>
>>       rcu_assign_pointer(thresholds->primary, new);
>>
>>       /* To be sure that nobody uses thresholds */
>>       synchronize_rcu();
>> +
>> +     /* If all events are unregistered, free the spare array */
>> +     if (!new) {
>> +             kfree(thresholds->spare);
>> +             thresholds->spare = NULL;
>> +     }
>>  unlock:
>>       mutex_unlock(&memcg->thresholds_lock);
>>  }
>> --
>> 2.6.0.rc2.230.g3dd15c0
>
> --
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
