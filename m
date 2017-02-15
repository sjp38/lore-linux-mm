Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D0A03680FD0
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 04:00:10 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id c85so13602940wmi.6
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 01:00:10 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k29si4633479wmh.124.2017.02.15.01.00.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 15 Feb 2017 01:00:09 -0800 (PST)
Subject: Re: [PATCH] oom_reaper: switch to struct list_head for reap queue
References: <20170214150714.6195-1-asarai@suse.de>
 <20170214163005.GA2450@cmpxchg.org>
 <e876e49b-8b65-d827-af7d-cbf8aef97585@suse.de>
 <20170214173717.GA8913@redhat.com>
From: Aleksa Sarai <asarai@suse.de>
Message-ID: <a35d6271-f9b3-834c-79da-30d522ec4813@suse.de>
Date: Wed, 15 Feb 2017 20:01:33 +1100
MIME-Version: 1.0
In-Reply-To: <20170214173717.GA8913@redhat.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cyphar@cyphar.com

>>> This is an extra pointer to task_struct and more lines of code to
>>> accomplish the same thing. Why would we want to do that?
>>
>> I don't think it's more "actual" lines of code (I think the wrapping is
>> inflating the line number count),
>
> I too think it doesn't make sense to blow task_struct and the generated code.
> And to me this patch doesn't make the source code more clean.
>
>> but switching it means that it's more in
>> line with other queues in the kernel (it took me a bit to figure out what
>> was going on with oom_reaper_list beforehand).
>
> perhaps you can turn oom_reaper_list into llist_head then. This will also
> allow to remove oom_reaper_lock. Not sure this makes sense too.

Actually, I just noticed that the original implementation is a stack not 
a queue. So the reaper will always reap the *most recent* task to get 
OOMed as opposed to the least recent. Since select_bad_process() will 
always pick worse processes first, this means that the reaper will reap 
"less bad" processes (lower oom score) before it reaps worse ones 
(higher oom score).

While it's not a /huge/ deal (N is going to be small in most OOM cases), 
is this something that we should consider?

RE: llist_head, the problem with that is that appending to the end is an 
O(n) operation. Though, as I said, n is not going to be very large in 
most cases.

-- 
Aleksa Sarai
Software Engineer (Containers)
SUSE Linux GmbH
https://www.cyphar.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
