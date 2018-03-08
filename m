Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 62F7D6B0003
	for <linux-mm@kvack.org>; Wed,  7 Mar 2018 23:51:37 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id l5-v6so2242678pli.8
        for <linux-mm@kvack.org>; Wed, 07 Mar 2018 20:51:37 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id c14si3064391pgn.681.2018.03.07.20.51.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Mar 2018 20:51:32 -0800 (PST)
Subject: Re: [PATCH] mm: oom: Fix race condition between oom_badness and
 do_exit of task
References: <1520427454-22813-1-git-send-email-gkohli@codeaurora.org>
 <alpine.DEB.2.20.1803071254410.165297@chino.kir.corp.google.com>
From: "Kohli, Gaurav" <gkohli@codeaurora.org>
Message-ID: <22ebd655-ece4-37e5-5a98-e9750cb20665@codeaurora.org>
Date: Thu, 8 Mar 2018 10:21:26 +0530
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1803071254410.165297@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org

On 3/8/2018 2:26 AM, David Rientjes wrote:

> On Wed, 7 Mar 2018, Gaurav Kohli wrote:
>
>> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
>> index 6fd9773..5f4cc4b 100644
>> --- a/mm/oom_kill.c
>> +++ b/mm/oom_kill.c
>> @@ -114,9 +114,11 @@ struct task_struct *find_lock_task_mm(struct task_struct *p)
>>   
>>   	for_each_thread(p, t) {
>>   		task_lock(t);
>> +		get_task_struct(t);
>>   		if (likely(t->mm))
>>   			goto found;
>>   		task_unlock(t);
>> +		put_task_struct(t);
>>   	}
>>   	t = NULL;
>>   found:
> We hold rcu_read_lock() here, so perhaps only do get_task_struct() before
> doing rcu_read_unlock() and we have a non-NULL t?

Here rcu_read_lock will not help, as our task may change due to below algo:

for_each_thread(p, t) {
  		task_lock(t);
+		get_task_struct(t);
  		if (likely(t->mm))
  			goto found;
  		task_unlock(t);
+		put_task_struct(t)


So only we can increase usage counter here only at the current task.

I have seen you new patch, that seems valid to me and it will resolve our issue.
Thanks for support.

Regards

Gaurav

>
-- 
Qualcomm India Private Limited, on behalf of Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
a Linux Foundation Collaborative Project.
