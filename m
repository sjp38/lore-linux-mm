Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 24447828E2
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 07:08:52 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id g62so22176112wme.0
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 04:08:52 -0800 (PST)
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com. [74.125.82.52])
        by mx.google.com with ESMTPS id 199si4710590wmv.97.2016.02.18.04.08.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Feb 2016 04:08:51 -0800 (PST)
Received: by mail-wm0-f52.google.com with SMTP id g62so22175509wme.0
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 04:08:50 -0800 (PST)
Date: Thu, 18 Feb 2016 13:08:49 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm,oom: exclude oom_task_origin processes if they are
 OOM-unkillable.
Message-ID: <20160218120849.GC18149@dhcp22.suse.cz>
References: <1455719460-7690-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.10.1602171430500.15429@chino.kir.corp.google.com>
 <20160218080909.GA18149@dhcp22.suse.cz>
 <201602181930.HIH09321.SFVFOQLHOFMJOt@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201602181930.HIH09321.SFVFOQLHOFMJOt@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, akpm@linux-foundation.org, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 18-02-16 19:30:12, Tetsuo Handa wrote:
[...]
> Commit 9cbb78bb314360a8 changed oom_scan_process_thread() to
> always pass memcg == NULL by removing memcg argument from
> oom_scan_process_thread(). As a result, after that commit,
> we are doing test_tsk_thread_flag(p, TIF_MEMDIE) check and
> oom_task_origin(p) check between two oom_unkillable_task()
> calls of memcg OOM case. Why don't we skip these checks by
> passing memcg != NULL to first oom_unkillable_task() call?
> Was this change by error?

I am not really sure I understand your question.  The point is
that mem_cgroup_out_of_memory does for_each_mem_cgroup_tree which
means that only tasks from the given memcg hierarchy is checked and
oom_unkillable_task cares about memcg only for

        /* When mem_cgroup_out_of_memory() and p is not member of the group */
        if (memcg && !task_in_mem_cgroup(p, memcg))
                return true;

which is never true by definition. I guess we can safely remove the memcg
argument from oom_badness and oom_unkillable_task. At least from a quick
glance...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
