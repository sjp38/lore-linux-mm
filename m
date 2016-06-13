Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 693C86B0005
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 07:27:49 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r5so27670535wmr.0
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 04:27:49 -0700 (PDT)
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com. [74.125.82.53])
        by mx.google.com with ESMTPS id w123si517044wmd.120.2016.06.13.04.27.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jun 2016 04:27:48 -0700 (PDT)
Received: by mail-wm0-f53.google.com with SMTP id n184so74027797wmn.1
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 04:27:48 -0700 (PDT)
Date: Mon, 13 Jun 2016 13:27:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 07/10] mm, oom: fortify task_will_free_mem
Message-ID: <20160613112746.GD6518@dhcp22.suse.cz>
References: <1465473137-22531-1-git-send-email-mhocko@kernel.org>
 <1465473137-22531-8-git-send-email-mhocko@kernel.org>
 <201606092218.FCC48987.MFQLVtSHJFOOFO@I-love.SAKURA.ne.jp>
 <20160609142026.GF24777@dhcp22.suse.cz>
 <201606111710.IGF51027.OJLSOQtHVOFFFM@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606111710.IGF51027.OJLSOQtHVOFFFM@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Sat 11-06-16 17:10:03, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > > Also, I think setting TIF_MEMDIE on p when find_lock_task_mm(p) != p is
> > > wrong. While oom_reap_task() will anyway clear TIF_MEMDIE even if we set
> > > TIF_MEMDIE on p when p->mm == NULL, it is not true for CONFIG_MMU=n case.
> > 
> > Yes this would be racy for !CONFIG_MMU but does it actually matter?
> 
> I don't know because I've never used CONFIG_MMU=n kernels. But I think it
> actually matters. You fixed this race by commit 83363b917a2982dd ("oom:
> make sure that TIF_MEMDIE is set under task_lock").

Yes and that commit was trying to address a highly theoretical issue
reported by you. Let me quote:
:oom_kill_process is currently prone to a race condition when the OOM
:victim is already exiting and TIF_MEMDIE is set after the task releases
:its address space.  This might theoretically lead to OOM livelock if the
:OOM victim blocks on an allocation later during exiting because it
:wouldn't kill any other process and the exiting one won't be able to exit.
:The situation is highly unlikely because the OOM victim is expected to
:release some memory which should help to sort out OOM situation.

Even if such a race is possible it wouldn't be with the oom
reaper. Regarding CONFIG_MMU=n I am even less sure it is possible and
I would rather focus on CONFIG_MMU=y where we know that problems exist
rather than speculating about something as special as nommu which even
might not care at all.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
