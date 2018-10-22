Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id C111B6B0003
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 06:43:44 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id x8-v6so3051072pgp.9
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 03:43:44 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e7-v6si35850685plk.294.2018.10.22.03.43.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Oct 2018 03:43:43 -0700 (PDT)
Date: Mon, 22 Oct 2018 12:43:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/2] mm, oom: marks all killed tasks as oom victims
Message-ID: <20181022104341.GY18839@dhcp22.suse.cz>
References: <20181022071323.9550-1-mhocko@kernel.org>
 <20181022071323.9550-2-mhocko@kernel.org>
 <201810220758.w9M7wojE016890@www262.sakura.ne.jp>
 <20181022084842.GW18839@dhcp22.suse.cz>
 <f5b257f9-47a5-e071-02fa-ce901bd34b04@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f5b257f9-47a5-e071-02fa-ce901bd34b04@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Mon 22-10-18 18:42:30, Tetsuo Handa wrote:
> On 2018/10/22 17:48, Michal Hocko wrote:
> > On Mon 22-10-18 16:58:50, Tetsuo Handa wrote:
> >> Michal Hocko wrote:
> >>> --- a/mm/oom_kill.c
> >>> +++ b/mm/oom_kill.c
> >>> @@ -898,6 +898,7 @@ static void __oom_kill_process(struct task_struct *victim)
> >>>  		if (unlikely(p->flags & PF_KTHREAD))
> >>>  			continue;
> >>>  		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, PIDTYPE_TGID);
> >>> +		mark_oom_victim(p);
> >>>  	}
> >>>  	rcu_read_unlock();
> >>>  
> >>> -- 
> >>
> >> Wrong. Either
> > 
> > You are right. The mm might go away between process_shares_mm and here.
> > While your find_lock_task_mm would be correct I believe we can do better
> > by using the existing mm that we already have. I will make it a separate
> > patch to clarity.
> 
> Still wrong. p->mm == NULL means that we are too late to set TIF_MEMDIE
> on that thread. Passing non-NULL mm to mark_oom_victim() won't help.

Why would it be too late? Or in other words why would this be harmful?
-- 
Michal Hocko
SUSE Labs
