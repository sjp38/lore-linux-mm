Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9A4D028024B
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 04:09:26 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l138so9888508wmg.3
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 01:09:26 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id w196si30359555wmf.100.2016.09.20.01.09.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Sep 2016 01:09:25 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id l132so1974493wmf.1
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 01:09:25 -0700 (PDT)
Date: Tue, 20 Sep 2016 10:09:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: migrate: Return false instead of -EAGAIN for dummy
 functions
Message-ID: <20160920080923.GE5477@dhcp22.suse.cz>
References: <1474096836-31045-1-git-send-email-chengang@emindsoft.com.cn>
 <20160917154659.GA29145@dhcp22.suse.cz>
 <57E05CD2.5090408@emindsoft.com.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57E05CD2.5090408@emindsoft.com.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <chengang@emindsoft.com.cn>
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, gi-oh.kim@profitbricks.com, opensource.ganesh@gmail.com, hughd@google.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chen Gang <gang.chen.5i5j@gmail.com>

On Tue 20-09-16 05:46:58, Chen Gang wrote:
> On 9/17/16 23:46, Michal Hocko wrote:
> > On Sat 17-09-16 15:20:36, chengang@emindsoft.com.cn wrote:
> > 
> >> Also change their related pure Boolean function numamigrate_isolate_page.
> > 
> > this is not true. Just look at the current usage
> > 
> > 	migrated = migrate_misplaced_page(page, vma, target_nid);
> > 	if (migrated) {
> > 		page_nid = target_nid;
> > 		flags |= TNF_MIGRATED;
> > 	} else
> > 		flags |= TNF_MIGRATE_FAIL;
> > 
> > and now take your change which changes -EAGAIN into false. See the
> > difference? Now I didn't even try to understand why
> > CONFIG_NUMA_BALANCING=n pretends a success but then in order to keep the
> > current semantic your patch should return true in that path. So NAK from
> > me until you either explain why this is OK or change it.
> >
> 
> For me, it really need return false:
> 
>  - For real implementation, when do nothing, it will return false.
> 
>  - I assume that the input page already is in a node (although maybe my
>    assumption incorrect), and migrate to the same node. When the real
>    implementation fails (e.g. -EAGAIN 10 times), it still returns false.
> 
>  - Original dummy implementation always return -EAGAIN, And -EAGAIN in
>    real implementation will trigger returning false, after 10 times.
> 
>  - After grep TNF_MIGRATE_FAIL and TNF_MIGRATED, we only use them in
>    task_numa_fault in kernel/sched/fair.c for numa_pages_migrated and
>    numa_faults_locality, I guess they are only used for statistics.
> 
> So for me the dummy implementation need return false instead of -EAGAIN.

I see that the return value semantic might be really confusing. But I am
not sure why bool would make it all of the sudden any less confusing.
migrate_page returns -EAGAIN on failure and 0 on success, migrate_pages
returns -EAGAIN or number of not migrated pages on failure and 0 on
success. So migrate_misplaced_page doesn't fit into this mode with the
bool return value. So I would argue that the code is not any better.

> > But to be honest I am not keen of this int -> bool changes much.
> > Especially if they are bringing a risk of subtle behavior change like
> > this patch. And without a good changelog explaining why this makes
> > sense.
> > 
> 
> If our original implementation already used bool, our this issue (return
> -EAGAIN) would be avoided (compiler would help us to find this issue).

OK, so you pushed me to look into it deeper and the fact is that
migrate_misplaced_page return value doesn't matter at all for
CONFIG_NUMA_BALANCING=n because task_numa_fault is noop for that
configuration. Moreover the whole do_numa_page should never execute with
that configuration because we will not have numa pte_protnone() ptes in
that path. do_huge_pmd_numa_page seems be in a similar case. So this
doesn't have any real impact on the runtime AFAICS.

So what is the point of this whole exercise? Do not take me wrong, this
area could see some improvements but I believe that doing int->bool
change is not just the right thing to do and worth spending both your
and reviewers time.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
