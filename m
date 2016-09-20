Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 773BC6B0038
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 17:59:27 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id v67so62336461pfv.1
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 14:59:27 -0700 (PDT)
Received: from out4435.biz.mail.alibaba.com (out4435.biz.mail.alibaba.com. [47.88.44.35])
        by mx.google.com with ESMTP id rd11si36880423pac.109.2016.09.20.14.59.25
        for <linux-mm@kvack.org>;
        Tue, 20 Sep 2016 14:59:26 -0700 (PDT)
Message-ID: <57E1B2F4.5070009@emindsoft.com.cn>
Date: Wed, 21 Sep 2016 06:06:44 +0800
From: Chen Gang <chengang@emindsoft.com.cn>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: migrate: Return false instead of -EAGAIN for dummy
 functions
References: <1474096836-31045-1-git-send-email-chengang@emindsoft.com.cn> <20160917154659.GA29145@dhcp22.suse.cz> <57E05CD2.5090408@emindsoft.com.cn> <20160920080923.GE5477@dhcp22.suse.cz>
In-Reply-To: <20160920080923.GE5477@dhcp22.suse.cz>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, gi-oh.kim@profitbricks.com, opensource.ganesh@gmail.com, hughd@google.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chen Gang <gang.chen.5i5j@gmail.com>

On 9/20/16 16:09, Michal Hocko wrote:
> On Tue 20-09-16 05:46:58, Chen Gang wrote:
>>
>> For me, it really need return false:
>>
>>  - For real implementation, when do nothing, it will return false.
>>
>>  - I assume that the input page already is in a node (although maybe my
>>    assumption incorrect), and migrate to the same node. When the real
>>    implementation fails (e.g. -EAGAIN 10 times), it still returns false.
>>
>>  - Original dummy implementation always return -EAGAIN, And -EAGAIN in
>>    real implementation will trigger returning false, after 10 times.
>>
>>  - After grep TNF_MIGRATE_FAIL and TNF_MIGRATED, we only use them in
>>    task_numa_fault in kernel/sched/fair.c for numa_pages_migrated and
>>    numa_faults_locality, I guess they are only used for statistics.
>>
>> So for me the dummy implementation need return false instead of -EAGAIN.
> 
> I see that the return value semantic might be really confusing. But I am
> not sure why bool would make it all of the sudden any less confusing.
> migrate_page returns -EAGAIN on failure and 0 on success, migrate_pages
> returns -EAGAIN or number of not migrated pages on failure and 0 on
> success. So migrate_misplaced_page doesn't fit into this mode with the
> bool return value. So I would argue that the code is not any better.
> 

I guess, numamigrate_isolate_page can be bool, at least.

And yes, commonly, bool functions are for asking something, and int
functions are for doing something, but not must be. When the caller care
about success, but never care about every failure details, bool is OK.

In our case, for me, numa balancing is for performance. When return
failure, the system has no any negative effect -- only lose a chance for
improving performance.

 - For user, the failure times statistics is enough, they need not care
   about every failure details.

 - For tracer, the failure details statistics are meaningfulness, but
   focusing on each failure details is meaningless. Now, it finishes a
   part of failure details statistics -- which can be improved next.

 - For debugger (or printing log), focusing on each failure details is
   useful. But debugger already can check every details, returning every
   failure details is still a little helpful, but not necessary.

>>
>> If our original implementation already used bool, our this issue (return
>> -EAGAIN) would be avoided (compiler would help us to find this issue).
> 
> OK, so you pushed me to look into it deeper and the fact is that
> migrate_misplaced_page return value doesn't matter at all for
> CONFIG_NUMA_BALANCING=n because task_numa_fault is noop for that
> configuration. Moreover the whole do_numa_page should never execute with
> that configuration because we will not have numa pte_protnone() ptes in
> that path. do_huge_pmd_numa_page seems be in a similar case. So this
> doesn't have any real impact on the runtime AFAICS.
> 

OK, thanks.

> So what is the point of this whole exercise? Do not take me wrong, this
> area could see some improvements but I believe that doing int->bool
> change is not just the right thing to do and worth spending both your
> and reviewers time.
> 

I am not quite sure about that.

Thanks.
-- 
Chen Gang (e??a??)

Managing Natural Environments is the Duty of Human Beings.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
