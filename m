Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 175F56B066D
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 03:53:43 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u7so6896092pgo.6
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 00:53:43 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id j24si5174848pfk.548.2017.08.03.00.53.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Aug 2017 00:53:41 -0700 (PDT)
Subject: Re: [PATCH] mm, oom: task_will_free_mem(current) should ignore MMF_OOM_SKIP for once.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1501718104-8099-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20170803071051.GB12521@dhcp22.suse.cz>
In-Reply-To: <20170803071051.GB12521@dhcp22.suse.cz>
Message-Id: <201708031653.JGD57352.OQFtVLSFOMOHJF@I-love.SAKURA.ne.jp>
Date: Thu, 3 Aug 2017 16:53:40 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, mjaggi@caviumnetworks.com, oleg@redhat.com, vdavydov@virtuozzo.com

Michal Hocko wrote:
> > We don't need to give up task_will_free_mem(current) without trying
> > allocation from memory reserves. We will need to select next OOM victim
> > only when allocation from memory reserves did not help.
> > 
> > Thus, this patch allows task_will_free_mem(current) to ignore MMF_OOM_SKIP
> > for once so that task_will_free_mem(current) will not start selecting next
> > OOM victim without trying allocation from memory reserves.
> 
> As I've already said this is an ugly hack and once we have
> http://lkml.kernel.org/r/20170727090357.3205-2-mhocko@kernel.org merged
> then it even shouldn't be needed because _all_ threads of the oom victim
> will have an instant access to memory reserves.
> 
> So I do not think we want to merge this.
> 

No, we still want to merge this, for 4.8+ kernels which won't get your patch
backported will need this. Even after your patch is merged, there is a race
window where allocating threads are between after gfp_pfmemalloc_allowed() and
before mutex_trylock(&oom_lock) in __alloc_pages_may_oom() which means that
some threads could call out_of_memory() and hit this task_will_free_mem(current)
test. Ignoring MMF_OOM_SKIP for once is still useful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
