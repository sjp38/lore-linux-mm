Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 550076B0294
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 11:12:26 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c2-v6so1056887edi.20
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 08:12:26 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o1-v6si1203358edd.161.2018.07.03.08.12.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 08:12:24 -0700 (PDT)
Date: Tue, 3 Jul 2018 17:12:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/8] OOM killer/reaper changes for avoiding OOM lockup
 problem.
Message-ID: <20180703151223.GP16767@dhcp22.suse.cz>
References: <1530627910-3415-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1530627910-3415-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org

On Tue 03-07-18 23:25:01, Tetsuo Handa wrote:
> This series provides
> 
>   (1) Mitigation and a fix for CVE-2016-10723.
> 
>   (2) A mitigation for needlessly selecting next OOM victim reported
>       by David Rientjes and rejected by Michal Hocko.
> 
>   (3) A preparation for handling many concurrent OOM victims which
>       could become real by introducing memcg-aware OOM killer.

It would have been great to describe the overal design in the cover
letter. So let me summarize just to be sure I understand the proposal.
You are removing the oom_reaper and moving the oom victim tear down to
the oom path. To handle cases where we cannot get mmap_sem to do that
work you simply decay oom_badness over time if there are no changes in
the victims oom score. In order to not block in the oom context for too
long because the address space might be quite large, you allow to
direct oom reap from multiple contexts.

You fail to explain why is this approach more appropriate and how you
have settled with your current tuning with 3s timeout etc...

Considering how subtle this whole area is I am not overly happy about
another rewrite without a really strong reasoning behind. There is none
here, unfortunately. Well, except for statements how I reject something
without telling the whole story etc...
 
> Tetsuo Handa (7):
>   mm,oom: Don't call schedule_timeout_killable() with oom_lock held.
>   mm,oom: Check pending victims earlier in out_of_memory().
>   mm,oom: Fix unnecessary killing of additional processes.
>   mm,page_alloc: Make oom_reserves_allowed() even.
>   mm,oom: Bring OOM notifier to outside of oom_lock.
>   mm,oom: Make oom_lock static variable.
>   mm,oom: Do not sleep with oom_lock held.
> Michal Hocko (1):
>   mm,page_alloc: Move the short sleep to should_reclaim_retry().
> 
>  drivers/tty/sysrq.c        |   2 -
>  include/linux/memcontrol.h |   9 +-
>  include/linux/oom.h        |   6 +-
>  include/linux/sched.h      |   7 +-
>  include/trace/events/oom.h |  64 -------
>  kernel/fork.c              |   2 +
>  mm/memcontrol.c            |  24 +--
>  mm/mmap.c                  |  17 +-
>  mm/oom_kill.c              | 439 +++++++++++++++++++++------------------------
>  mm/page_alloc.c            | 134 ++++++--------
>  10 files changed, 287 insertions(+), 417 deletions(-)
> 
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs
