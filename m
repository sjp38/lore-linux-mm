Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 383F26B0069
	for <linux-mm@kvack.org>; Mon, 19 Sep 2016 17:39:31 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id e20so2933799itc.3
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 14:39:31 -0700 (PDT)
Received: from out28-2.mail.aliyun.com (out28-2.mail.aliyun.com. [115.124.28.2])
        by mx.google.com with ESMTP id q144si28215072itc.110.2016.09.19.14.39.29
        for <linux-mm@kvack.org>;
        Mon, 19 Sep 2016 14:39:30 -0700 (PDT)
Message-ID: <57E05CD2.5090408@emindsoft.com.cn>
Date: Tue, 20 Sep 2016 05:46:58 +0800
From: Chen Gang <chengang@emindsoft.com.cn>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: migrate: Return false instead of -EAGAIN for dummy
 functions
References: <1474096836-31045-1-git-send-email-chengang@emindsoft.com.cn> <20160917154659.GA29145@dhcp22.suse.cz>
In-Reply-To: <20160917154659.GA29145@dhcp22.suse.cz>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, gi-oh.kim@profitbricks.com, opensource.ganesh@gmail.com, hughd@google.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chen Gang <gang.chen.5i5j@gmail.com>

On 9/17/16 23:46, Michal Hocko wrote:
> On Sat 17-09-16 15:20:36, chengang@emindsoft.com.cn wrote:
> 
>> Also change their related pure Boolean function numamigrate_isolate_page.
> 
> this is not true. Just look at the current usage
> 
> 	migrated = migrate_misplaced_page(page, vma, target_nid);
> 	if (migrated) {
> 		page_nid = target_nid;
> 		flags |= TNF_MIGRATED;
> 	} else
> 		flags |= TNF_MIGRATE_FAIL;
> 
> and now take your change which changes -EAGAIN into false. See the
> difference? Now I didn't even try to understand why
> CONFIG_NUMA_BALANCING=n pretends a success but then in order to keep the
> current semantic your patch should return true in that path. So NAK from
> me until you either explain why this is OK or change it.
>

For me, it really need return false:

 - For real implementation, when do nothing, it will return false.

 - I assume that the input page already is in a node (although maybe my
   assumption incorrect), and migrate to the same node. When the real
   implementation fails (e.g. -EAGAIN 10 times), it still returns false.

 - Original dummy implementation always return -EAGAIN, And -EAGAIN in
   real implementation will trigger returning false, after 10 times.

 - After grep TNF_MIGRATE_FAIL and TNF_MIGRATED, we only use them in
   task_numa_fault in kernel/sched/fair.c for numa_pages_migrated and
   numa_faults_locality, I guess they are only used for statistics.

So for me the dummy implementation need return false instead of -EAGAIN.
 
> But to be honest I am not keen of this int -> bool changes much.
> Especially if they are bringing a risk of subtle behavior change like
> this patch. And without a good changelog explaining why this makes
> sense.
> 

If our original implementation already used bool, our this issue (return
-EAGAIN) would be avoided (compiler would help us to find this issue).


Thanks.
-- 
Chen Gang (e??a??)

Managing Natural Environments is the Duty of Human Beings.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
