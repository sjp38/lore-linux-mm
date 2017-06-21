Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id F1E006B03F0
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 09:18:54 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id f49so15862734wrf.5
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 06:18:54 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w141si17028416wme.144.2017.06.21.06.18.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Jun 2017 06:18:53 -0700 (PDT)
Date: Wed, 21 Jun 2017 15:18:50 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom_kill: Close race window of needlessly selecting
 new victims.
Message-ID: <20170621131850.GA27494@dhcp22.suse.cz>
References: <20170615103909.GG1486@dhcp22.suse.cz>
 <alpine.DEB.2.10.1706151420300.95906@chino.kir.corp.google.com>
 <20170615214133.GB20321@dhcp22.suse.cz>
 <201706162122.ACE95321.tOFLOOVFFHMSJQ@I-love.SAKURA.ne.jp>
 <20170616141255.GN30580@dhcp22.suse.cz>
 <201706171417.JHG48401.JOQLHMFSVOOFtF@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.10.1706201509170.109574@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1706201509170.109574@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 20-06-17 15:12:55, David Rientjes wrote:
[...]
> This doesn't prevent serial oom killing for either the system oom killer 
> or for the memcg oom killer.
> 
> The oom killer cannot detect tsk_is_oom_victim() if the task has either 
> been removed from the tasklist or has already done cgroup_exit(). For 
> memcg oom killings in particular, cgroup_exit() is usually called very 
> shortly after the oom killer has sent the SIGKILL.  If the oom reaper does 
> not fail (for example by failing to grab mm->mmap_sem) before another 
> memcg charge after cgroup_exit(victim), additional processes are killed 
> because the iteration does not view the victim.
> 
> This easily kills all processes attached to the memcg with no memory 
> freeing from any victim.

It took me some time to decrypt the above but you are right. Pinning
mm_users will prevent exit path to exit_mmap and that can indeed cause
another premature oom killing because the task might be unhashed or
removed from the memcg before the oom reaper has a chance to reap the
task. Thanks for pointing this out. This means that we either have to
reimplement the unhashing/cgroup_exit for oom victims or get back to
allowing oom reaper to race with exit_mmap. The later sounds much more
easier to me.

I was offline last two days but I will revisit my original idea ASAP.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
