Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 1F6546B0009
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 17:33:05 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id yy13so192878pab.3
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 14:33:05 -0800 (PST)
Received: from mail-pf0-x22b.google.com (mail-pf0-x22b.google.com. [2607:f8b0:400e:c00::22b])
        by mx.google.com with ESMTPS id x9si49889554pas.72.2016.02.23.14.33.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 14:33:04 -0800 (PST)
Received: by mail-pf0-x22b.google.com with SMTP id x65so276718pfb.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 14:33:04 -0800 (PST)
Date: Tue, 23 Feb 2016 14:33:01 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] mm,oom: exclude oom_task_origin processes if they
 are OOM-unkillable.
In-Reply-To: <20160223123457.GC14178@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1602231420590.744@chino.kir.corp.google.com>
References: <1455719460-7690-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp> <alpine.DEB.2.10.1602171430500.15429@chino.kir.corp.google.com> <20160218080909.GA18149@dhcp22.suse.cz> <alpine.DEB.2.10.1602221701170.4688@chino.kir.corp.google.com>
 <20160223123457.GC14178@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, akpm@linux-foundation.org, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 23 Feb 2016, Michal Hocko wrote:

> > oom_badness() ranges from 0 (don't kill) to 1000 (please kill).  It 
> > factors in the setting of /proc/self/oom_score_adj to change that value.  
> > That is where OOM_SCORE_ADJ_MIN is enforced. 
> 
> The question is whether the current placement of OOM_SCORE_ADJ_MIN
> is appropriate. Wouldn't it make more sense to check it in oom_unkillable_task
> instead?

oom_unkillable_task() deals with the type of task it is (init or kthread) 
or being ineligible due to the memcg and cpuset placement.  We want to 
exclude them from consideration and also suppress them from the task dump 
in the kernel log.  We don't want to suppress oom disabled processes, we 
really want to know their rss, for example.  It could be renamed 
is_ineligible_task().

> Sure, checking oom_score_adj under task_lock inside oom_badness will
> prevent from races but the question I raised previously was whether we
> actually care about those races? When would it matter? Is it really
> likely that the update happen during the oom killing? And if yes what
> prevents from the update happening _after_ the check?
> 

It's not necessarily to take task_lock(), but find_lock_task_mm() is the 
means we have to iterate threads to find any with memory attached.  We 
need that logic in oom_badness() to avoid racing with threads that have 
entered exit_mm().  It's possible for a thread to have a non-NULL ->mm in 
oom_scan_process_thread(), the thread enters exit_mm() without kill, and 
oom_badness() can still find it to be eligible because other threads have 
not exited.  We still want to issue a kill to this process and task_lock() 
protects the setting of task->mm to NULL: don't consider it to be a race 
in setting oom_score_adj, consider it to be a race in unmapping (but not 
freeing) memory in th exit path.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
