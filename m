Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 181D06B0038
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 02:39:35 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id n124so10716278lfd.4
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 23:39:35 -0800 (PST)
Received: from SELDSEGREL01.sonyericsson.com (seldsegrel01.sonyericsson.com. [37.139.156.29])
        by mx.google.com with ESMTPS id f96si583400lfi.23.2017.02.09.23.39.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Feb 2017 23:39:33 -0800 (PST)
Subject: Re: [PATCH 3/3 staging-next] mm: Remove RCU and tasklocks from lmk
References: <6d83fb15-db88-52d3-bc24-2dd8b6d9b614@sonymobile.com>
 <20170209200507.GE31906@dhcp22.suse.cz>
From: peter enderborg <peter.enderborg@sonymobile.com>
Message-ID: <0537b930-dfb0-bdb9-04f0-e061a060c162@sonymobile.com>
Date: Fri, 10 Feb 2017 08:39:11 +0100
MIME-Version: 1.0
In-Reply-To: <20170209200507.GE31906@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: devel@driverdev.osuosl.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, =?UTF-8?Q?Arve_Hj=c3=b8nnev=c3=a5g?= <arve@android.com>, Riley Andrews <riandrews@android.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org

On 02/09/2017 09:05 PM, Michal Hocko wrote:
> On Thu 09-02-17 14:21:52, peter enderborg wrote:
>> Fundamental changes:
>> 1 Does NOT take any RCU lock in shrinker functions.
>> 2 It returns same result for scan and counts, so  we dont need to do
>>   shinker will know when it is pointless to call scan.
>> 3 It does not lock any other process than the one that is
>>   going to be killed.
>>
>> Background.
>> The low memory killer scans for process that can be killed to free
>> memory. This can be cpu consuming when there is a high demand for
>> memory. This can be seen by analysing the kswapd0 task work.
>> The stats function added in earler patch adds a counter for waste work.
>>
>> How it works.
>> This patch create a structure within the lowmemory killer that caches
>> the user spaces processes that it might kill. It is done with a
>> sorted rbtree so we can very easy find the candidate to be killed,
>> and knows its properies as memory usage and sorted by oom_score_adj
>> to look up the task with highest oom_score_adj. To be able to achive
>> this it uses oom_score_notify events.
>>
>> This patch also as a other effect, we are now free to do other
>> lowmemorykiller configurations.  Without the patch there is a need
>> for a tradeoff between freed memory and task and rcu locks. This
>> is no longer a concern for tuning lmk. This patch is not intended
>> to do any calculation changes other than we do use the cache for
>> calculate the count values and that makes kswapd0 to shrink other
>> areas.
> I have to admit I really do not understand big part of the above
> paragraph as well as how this all is supposed to work. A quick glance
> over the implementation. __lmk_task_insert seems to be only called from
> the oom_score notifier context. If nobody updates the value then no task
> will get into the tree. Or am I missing something really obvious here?
> Moreover oom scores tend to be mostly same for tasks. That means that
> your sorted tree will become sorted by pids in most cases. I do not see
> any sorting based on the rss nor any updates that would reflect updates
> of rss. How can this possibly work?

The task tree nodes are created,updated or removed from the notifier when
there is a relevant oom_score_adj change. If no one create a task that
is in the range for the lowmemorykiller the tree will be empty. This is
an android feature so the score will be updated very often. It is
part of activity manager to prioritise tasks.  Why should we do sort of
rss?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
