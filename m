Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2F19E6B0010
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 08:34:05 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id v40so637104ote.8
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 05:34:05 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id p187-v6si499284oia.60.2018.10.23.05.34.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Oct 2018 05:34:03 -0700 (PDT)
Subject: Re: [RFC PATCH 2/2] memcg: do not report racy no-eligible OOM tasks
References: <f9a8079f-55b0-301e-9b3d-a5250bd7d277@i-love.sakura.ne.jp>
 <20181022120308.GB18839@dhcp22.suse.cz>
 <201810230101.w9N118i3042448@www262.sakura.ne.jp>
 <20181023114246.GR18839@dhcp22.suse.cz>
 <20181023121055.GS18839@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <a55e70bd-dc5f-9a11-72e6-7cd7b3b48ab7@I-love.SAKURA.ne.jp>
Date: Tue, 23 Oct 2018 21:33:43 +0900
MIME-Version: 1.0
In-Reply-To: <20181023121055.GS18839@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 2018/10/23 21:10, Michal Hocko wrote:
> On Tue 23-10-18 13:42:46, Michal Hocko wrote:
>> On Tue 23-10-18 10:01:08, Tetsuo Handa wrote:
>>> Michal Hocko wrote:
>>>> On Mon 22-10-18 20:45:17, Tetsuo Handa wrote:
>>>>>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>>>>>> index e79cb59552d9..a9dfed29967b 100644
>>>>>> --- a/mm/memcontrol.c
>>>>>> +++ b/mm/memcontrol.c
>>>>>> @@ -1380,10 +1380,22 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>>>>>>  		.gfp_mask = gfp_mask,
>>>>>>  		.order = order,
>>>>>>  	};
>>>>>> -	bool ret;
>>>>>> +	bool ret = true;
>>>>>>  
>>>>>>  	mutex_lock(&oom_lock);
>>>>>> +
>>>>>> +	/*
>>>>>> +	 * multi-threaded tasks might race with oom_reaper and gain
>>>>>> +	 * MMF_OOM_SKIP before reaching out_of_memory which can lead
>>>>>> +	 * to out_of_memory failure if the task is the last one in
>>>>>> +	 * memcg which would be a false possitive failure reported
>>>>>> +	 */
>>>>>> +	if (tsk_is_oom_victim(current))
>>>>>> +		goto unlock;
>>>>>> +
>>>>>
>>>>> This is not wrong but is strange. We can use mutex_lock_killable(&oom_lock)
>>>>> so that any killed threads no longer wait for oom_lock.
>>>>
>>>> tsk_is_oom_victim is stronger because it doesn't depend on
>>>> fatal_signal_pending which might be cleared throughout the exit process.
>>>>
>>>
>>> I still want to propose this. No need to be memcg OOM specific.
>>
>> Well, I maintain what I've said [1] about simplicity and specific fix
>> for a specific issue. Especially in the tricky code like this where all
>> the consequences are far more subtle than they seem to be.
>>
>> This is obviously a matter of taste but I don't see much point discussing
>> this back and forth for ever. Unless there is a general agreement that
>> the above is less appropriate then I am willing to consider a different
>> change but I simply do not have energy to nit pick for ever.
>>
>> [1] http://lkml.kernel.org/r/20181022134315.GF18839@dhcp22.suse.cz
> 
> In other words. Having a memcg specific fix means, well, a memcg
> maintenance burden. Like any other memcg specific oom decisions we
> already have. So are you OK with that Johannes or you would like to see
> a more generic fix which might turn out to be more complex?
> 

I don't know what "that Johannes" refers to.

If you don't want to affect SysRq-OOM and pagefault-OOM cases,
are you OK with having a global-OOM specific fix?

 mm/page_alloc.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e2ef1c1..f59f029 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3518,6 +3518,17 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 	if (gfp_mask & __GFP_THISNODE)
 		goto out;
 
+	/*
+	 * It is possible that multi-threaded OOM victims get
+	 * task_will_free_mem(current) == false when the OOM reaper quickly
+	 * set MMF_OOM_SKIP. But since we know that tsk_is_oom_victim() == true
+	 * tasks won't loop forever (unless it is a __GFP_NOFAIL allocation
+	 * request), we don't need to select next OOM victim.
+	 */
+	if (tsk_is_oom_victim(current) && !(gfp_mask & __GFP_NOFAIL)) {
+		*did_some_progress = 1;
+		goto out;
+	}
 	/* Exhausted what can be done so it's blame time */
 	if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
 		*did_some_progress = 1;
-- 
1.8.3.1
