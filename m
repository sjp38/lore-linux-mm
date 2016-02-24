Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id E09676B0009
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 05:05:23 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id a4so22013771wme.1
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 02:05:23 -0800 (PST)
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com. [74.125.82.45])
        by mx.google.com with ESMTPS id k71si45069770wmd.15.2016.02.24.02.05.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Feb 2016 02:05:22 -0800 (PST)
Received: by mail-wm0-f45.google.com with SMTP id g62so263211978wme.1
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 02:05:22 -0800 (PST)
Date: Wed, 24 Feb 2016 11:05:20 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm,oom: exclude oom_task_origin processes if they are
 OOM-unkillable.
Message-ID: <20160224100520.GB20863@dhcp22.suse.cz>
References: <1455719460-7690-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.10.1602171430500.15429@chino.kir.corp.google.com>
 <20160218080909.GA18149@dhcp22.suse.cz>
 <alpine.DEB.2.10.1602221701170.4688@chino.kir.corp.google.com>
 <20160223123457.GC14178@dhcp22.suse.cz>
 <alpine.DEB.2.10.1602231420590.744@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1602231420590.744@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, akpm@linux-foundation.org, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 23-02-16 14:33:01, David Rientjes wrote:
> On Tue, 23 Feb 2016, Michal Hocko wrote:
> 
> > > oom_badness() ranges from 0 (don't kill) to 1000 (please kill).  It 
> > > factors in the setting of /proc/self/oom_score_adj to change that value.  
> > > That is where OOM_SCORE_ADJ_MIN is enforced. 
> > 
> > The question is whether the current placement of OOM_SCORE_ADJ_MIN
> > is appropriate. Wouldn't it make more sense to check it in oom_unkillable_task
> > instead?
> 
> oom_unkillable_task() deals with the type of task it is (init or kthread) 
> or being ineligible due to the memcg and cpuset placement.

Yes and OOM disabled is yet another condition.

> We want to 
> exclude them from consideration and also suppress them from the task dump 
> in the kernel log.  We don't want to suppress oom disabled processes, we 
> really want to know their rss, for example.

Hmm, is it really helpful though? What would you deduce from seeing a
large rss an OOM_SCORE_ADJ_MIN task? Misconfigured system? There must
have been a reason to mark the task that way in the first place so you
can hardly do anything about it. Moreover you can deduce the same from
the available information.

I would even argue that displaying OOM_SCORE_ADJ_MIN might be a bit
counterproductive because you have to filter them out when looking at
the listing.

> It could be renamed is_ineligible_task().

That wouldn't really help imho because OOM_SCORE_ADJ_MIN is an
uneligible task.

> > Sure, checking oom_score_adj under task_lock inside oom_badness will
> > prevent from races but the question I raised previously was whether we
> > actually care about those races? When would it matter? Is it really
> > likely that the update happen during the oom killing? And if yes what
> > prevents from the update happening _after_ the check?
> > 
> 
> It's not necessarily to take task_lock(), but find_lock_task_mm() is the 
> means we have to iterate threads to find any with memory attached.  We 
> need that logic in oom_badness() to avoid racing with threads that have 
> entered exit_mm().  It's possible for a thread to have a non-NULL ->mm in 
> oom_scan_process_thread(), the thread enters exit_mm() without kill, and 
> oom_badness() can still find it to be eligible because other threads have 
> not exited.  We still want to issue a kill to this process and task_lock() 
> protects the setting of task->mm to NULL: don't consider it to be a race 
> in setting oom_score_adj, consider it to be a race in unmapping (but not 
> freeing) memory in th exit path.

I am confused now. This all is true but it is independent on OOM_SCORE_ADJ_MIN
check? The check is per signal_struct so checking all the threads will
not change anything.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
