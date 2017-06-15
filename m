Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id E2B1283292
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 06:53:33 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id k4so6872320otd.13
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 03:53:33 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id z57si1127361otd.109.2017.06.15.03.53.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Jun 2017 03:53:32 -0700 (PDT)
Subject: Re: [patch] mm, oom: prevent additional oom kills before memory is freed
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <alpine.DEB.2.10.1706141632100.93071@chino.kir.corp.google.com>
	<20170615103909.GG1486@dhcp22.suse.cz>
In-Reply-To: <20170615103909.GG1486@dhcp22.suse.cz>
Message-Id: <201706151953.HFH78657.tFFLOOOQHSMVFJ@I-love.SAKURA.ne.jp>
Date: Thu, 15 Jun 2017 19:53:24 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, rientjes@google.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Wed 14-06-17 16:43:03, David Rientjes wrote:
> > If mm->mm_users is not incremented because it is already zero by the oom
> > reaper, meaning the final refcount has been dropped, do not set
> > MMF_OOM_SKIP prematurely.
> > 
> > __mmput() may not have had a chance to do exit_mmap() yet, so memory from
> > a previous oom victim is still mapped.
> 
> true and do we have a _guarantee_ it will do it? E.g. can somebody block
> exit_aio from completing? Or can somebody hold mmap_sem and thus block
> ksm_exit resp. khugepaged_exit from completing? The reason why I was
> conservative and set such a mm as MMF_OOM_SKIP was because I couldn't
> give a definitive answer to those questions. And we really _want_ to
> have a guarantee of a forward progress here. Killing an additional
> proecess is a price to pay and if that doesn't trigger normall it sounds
> like a reasonable compromise to me.

Right. If you want this patch, __oom_reap_task_mm() must not return true without
setting MMF_OOM_SKIP (in other words, return false if __oom_reap_task_mm()
does not set MMF_OOM_SKIP). The most important role of the OOM reaper is to
guarantee that the OOM killer is re-enabled within finite time, for __mmput()
cannot guarantee that MMF_OOM_SKIP is set within finite time.

> 
> > __mput() naturally requires no
> > references on mm->mm_users to do exit_mmap().
> > 
> > Without this, several processes can be oom killed unnecessarily and the
> > oom log can show an abundance of memory available if exit_mmap() is in
> > progress at the time the process is skipped.
> 
> Have you seen this happening in the real life?
> 
> > Signed-off-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
