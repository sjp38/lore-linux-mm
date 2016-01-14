Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id D784B828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 19:57:10 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id 65so89995404pff.2
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 16:57:10 -0800 (PST)
Received: from mail-pf0-x233.google.com (mail-pf0-x233.google.com. [2607:f8b0:400e:c00::233])
        by mx.google.com with ESMTPS id r19si5496270pfi.140.2016.01.13.16.57.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 16:57:10 -0800 (PST)
Received: by mail-pf0-x233.google.com with SMTP id e65so90250628pfe.0
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 16:57:10 -0800 (PST)
Date: Wed, 13 Jan 2016 16:57:08 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] mm,oom: Exclude TIF_MEMDIE processes from
 candidates.
In-Reply-To: <201601131952.HAJ18298.OQLtSOFOFFMVJH@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.10.1601131653420.3847@chino.kir.corp.google.com>
References: <201601072231.DGG78695.OOFVLHJFFQOStM@I-love.SAKURA.ne.jp> <20160107145841.GN27868@dhcp22.suse.cz> <20160107154436.GO27868@dhcp22.suse.cz> <201601081909.CDJ52685.HLFOFJFOQMVOtS@I-love.SAKURA.ne.jp> <alpine.DEB.2.10.1601121626310.28831@chino.kir.corp.google.com>
 <201601131952.HAJ18298.OQLtSOFOFFMVJH@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: mhocko@kernel.org, hannes@cmpxchg.org, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 13 Jan 2016, Tetsuo Handa wrote:

> David Rientjes wrote:
> > > @@ -171,7 +195,7 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
> > >  	if (oom_unkillable_task(p, memcg, nodemask))
> > >  		return 0;
> > > 
> > > -	p = find_lock_task_mm(p);
> > > +	p = find_lock_non_victim_task_mm(p);
> > >  	if (!p)
> > >  		return 0;
> > > 
> > 
> > I understand how this may make your test case pass, but I simply don't 
> > understand how this could possibly be the correct thing to do.  This would 
> > cause oom_badness() to return 0 for any process where a thread has 
> > TIF_MEMDIE set.  If the oom killer is called from the page allocator, 
> > kills a thread, and it is recalled before that thread may exit, then this 
> > will panic the system if there are no other eligible processes to kill.
> > 
> Why? oom_badness() is called after oom_scan_process_thread() returned OOM_SCAN_OK.
> oom_scan_process_thread() returns OOM_SCAN_ABORT if a thread has TIF_MEMDIE set.
> 

oom_scan_process_thread() checks for TIF_MEMDIE on p, not on p's threads.  
If one of p's threads has TIF_MEMDIE set and p does not, we actually want 
to set TIF_MEMDIE for p.  That's the current behavior since it will lead 
to p->mm memory freeing.  Your patch is excluding such processes entirely 
and selecting another process to kill unnecessarily.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
