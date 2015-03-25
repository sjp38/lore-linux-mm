Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id A5AB06B0038
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 13:01:53 -0400 (EDT)
Received: by wixw10 with SMTP id w10so79198194wix.0
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 10:01:53 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cl5si5360177wjc.37.2015.03.25.10.01.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 25 Mar 2015 10:01:52 -0700 (PDT)
Message-ID: <5512E9FC.7090105@suse.cz>
Date: Wed, 25 Mar 2015 18:01:48 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [patch 08/12] mm: page_alloc: wait for OOM killer progress before
 retrying
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>	<1427264236-17249-9-git-send-email-hannes@cmpxchg.org> <201503252315.FBJ09847.FSOtOJQFOMLFVH@I-love.SAKURA.ne.jp>
In-Reply-To: <201503252315.FBJ09847.FSOtOJQFOMLFVH@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, hannes@cmpxchg.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org, ying.huang@intel.com, aarcange@redhat.com, david@fromorbit.com, mhocko@suse.cz, tytso@mit.edu

On 03/25/2015 03:15 PM, Tetsuo Handa wrote:
> Johannes Weiner wrote:
>> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
>> index 5cfda39b3268..e066ac7353a4 100644
>> --- a/mm/oom_kill.c
>> +++ b/mm/oom_kill.c
>> @@ -711,12 +711,15 @@ bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
>>   		killed = 1;
>>   	}
>>   out:
>> +	if (test_thread_flag(TIF_MEMDIE))
>> +		return true;
>>   	/*
>> -	 * Give the killed threads a good chance of exiting before trying to
>> -	 * allocate memory again.
>> +	 * Wait for any outstanding OOM victims to die.  In rare cases
>> +	 * victims can get stuck behind the allocating tasks, so the
>> +	 * wait needs to be bounded.  It's crude alright, but cheaper
>> +	 * than keeping a global dependency tree between all tasks.
>>   	 */
>> -	if (killed)
>> -		schedule_timeout_killable(1);
>> +	wait_event_timeout(oom_victims_wait, !atomic_read(&oom_victims), HZ);
>>
>>   	return true;
>>   }
>
> out_of_memory() returning true with bounded wait effectively means that
> wait forever without choosing subsequent OOM victims when first OOM victim
> failed to die. The system will lock up, won't it?

And after patch 12, does this mean that you may not be waiting long 
enough for the victim to die, before you fail the allocation, 
prematurely? I can imagine there would be situations where the victim is 
not deadlocked, but still take more than HZ to finish, no?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
