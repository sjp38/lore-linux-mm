Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 355D96B0253
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 07:35:01 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id a4so206861073wme.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 04:35:01 -0800 (PST)
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com. [74.125.82.47])
        by mx.google.com with ESMTPS id ld7si421541wjb.222.2016.02.23.04.34.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 04:35:00 -0800 (PST)
Received: by mail-wm0-f47.google.com with SMTP id a4so206860366wme.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 04:34:59 -0800 (PST)
Date: Tue, 23 Feb 2016 13:34:58 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm,oom: exclude oom_task_origin processes if they are
 OOM-unkillable.
Message-ID: <20160223123457.GC14178@dhcp22.suse.cz>
References: <1455719460-7690-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.10.1602171430500.15429@chino.kir.corp.google.com>
 <20160218080909.GA18149@dhcp22.suse.cz>
 <alpine.DEB.2.10.1602221701170.4688@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1602221701170.4688@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, akpm@linux-foundation.org, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 22-02-16 17:06:29, David Rientjes wrote:
> On Thu, 18 Feb 2016, Michal Hocko wrote:
> 
> > > Anyway, this is NACK'd since task->signal->oom_score_adj is checked under 
> > > task_lock() for threads with memory attached, that's the purpose of 
> > > finding the correct thread in oom_badness() and taking task_lock().  We 
> > > aren't going to duplicate logic in several functions that all do the same 
> > > thing.
> > 
> > Is the task_lock really necessary, though? E.g. oom_task_origin()
> > doesn't seem to depend on it for task->signal safety. If you are
> > referring to races with changing oom_score_adj does such a race matter
> > at all?
> > 
> 
> oom_badness() ranges from 0 (don't kill) to 1000 (please kill).  It 
> factors in the setting of /proc/self/oom_score_adj to change that value.  
> That is where OOM_SCORE_ADJ_MIN is enforced. 

The question is whether the current placement of OOM_SCORE_ADJ_MIN
is appropriate. Wouldn't it make more sense to check it in oom_unkillable_task
instead? Sure, checking oom_score_adj under task_lock inside oom_badness will
prevent from races but the question I raised previously was whether we
actually care about those races? When would it matter? Is it really
likely that the update happen during the oom killing? And if yes what
prevents from the update happening _after_ the check?

If for nothing else oom_unkillable_task would be complete that way. E.g.
sysctl_oom_kill_allocating_task has to check for OOM_SCORE_ADJ_MIN
because it doesn't rely on oom_badness and that alone would suggest
that the check is misplaced.

That being said I do not really care that much. I would just find it
neater to have oom_unkillable_task that would really consider all the
cases where the OOM should ignore a task.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
