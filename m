Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 530A66B03FE
	for <linux-mm@kvack.org>; Thu, 22 Dec 2016 04:35:08 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id c85so3259449wmi.6
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 01:35:08 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q126si27448086wme.18.2016.12.22.01.35.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Dec 2016 01:35:06 -0800 (PST)
Date: Thu, 22 Dec 2016 10:35:01 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, oom_reaper: Move oom_lock from __oom_reap_task_mm()
 to oom_reap_task().
Message-ID: <20161222093501.GE6048@dhcp22.suse.cz>
References: <1481540152-7599-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20161212115918.GI18163@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161212115918.GI18163@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org

On Mon 12-12-16 12:59:18, Michal Hocko wrote:
> On Mon 12-12-16 19:55:52, Tetsuo Handa wrote:
> > Since commit 862e3073b3eed13f
> > ("mm, oom: get rid of signal_struct::oom_victims")
> > changed to wait until MMF_OOM_SKIP is set rather than wait while
> > TIF_MEMDIE is set, rationale comment for commit e2fe14564d3316d1
> > ("oom_reaper: close race with exiting task") needs to be updated.
> 
> True.
> 
> > While holding oom_lock can make sure that other threads waiting for
> > oom_lock at __alloc_pages_may_oom() are given a chance to call
> > get_page_from_freelist() after the OOM reaper called unmap_page_range()
> > via __oom_reap_task_mm(), it can defer calling of __oom_reap_task_mm().
> > 
> > Therefore, this patch moves oom_lock from __oom_reap_task_mm() to
> > oom_reap_task() (without any functional change). By doing so, the OOM
> > killer can call __oom_reap_task_mm() if we don't want to defer calling
> > of __oom_reap_task_mm() (e.g. when oom_evaluate_task() aborted by
> > finding existing OOM victim's mm without MMF_OOM_SKIP).
> 
> But I fail to understand this part of the changelog. It sounds like a
> preparatory for other changes. There doesn't seem to be any other user
> of __oom_reap_task_mm in the current tree.
> 
> Please send a patch which removes the comment which is no longer true
> on its own and feel free to add
> 
> Acked-by: Michal Hocko <mhocko@suse.com>
> 
> but do not make other changes if you do not have any follow up patch
> which would benefit from that.

Do you plan to pursue this?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
