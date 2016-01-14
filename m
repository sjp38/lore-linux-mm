Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id 0FFC4828DF
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 05:26:35 -0500 (EST)
Received: by mail-ob0-f181.google.com with SMTP id vt7so79370445obb.1
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 02:26:35 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id x12si6433046oix.96.2016.01.14.02.26.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Jan 2016 02:26:33 -0800 (PST)
Subject: Re: [PATCH v2] mm,oom: Exclude TIF_MEMDIE processes from candidates.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160107154436.GO27868@dhcp22.suse.cz>
	<201601081909.CDJ52685.HLFOFJFOQMVOtS@I-love.SAKURA.ne.jp>
	<alpine.DEB.2.10.1601121626310.28831@chino.kir.corp.google.com>
	<201601131952.HAJ18298.OQLtSOFOFFMVJH@I-love.SAKURA.ne.jp>
	<alpine.DEB.2.10.1601131653420.3847@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1601131653420.3847@chino.kir.corp.google.com>
Message-Id: <201601141926.JHG56933.OFFHOFOLQMtJSV@I-love.SAKURA.ne.jp>
Date: Thu, 14 Jan 2016 19:26:19 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com
Cc: mhocko@kernel.org, hannes@cmpxchg.org, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

David Rientjes wrote:
> On Wed, 13 Jan 2016, Tetsuo Handa wrote:
> 
> > David Rientjes wrote:
> > > > @@ -171,7 +195,7 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
> > > >  	if (oom_unkillable_task(p, memcg, nodemask))
> > > >  		return 0;
> > > > 
> > > > -	p = find_lock_task_mm(p);
> > > > +	p = find_lock_non_victim_task_mm(p);
> > > >  	if (!p)
> > > >  		return 0;
> > > > 
> > > 
> > > I understand how this may make your test case pass, but I simply don't 
> > > understand how this could possibly be the correct thing to do.  This would 
> > > cause oom_badness() to return 0 for any process where a thread has 
> > > TIF_MEMDIE set.  If the oom killer is called from the page allocator, 
> > > kills a thread, and it is recalled before that thread may exit, then this 
> > > will panic the system if there are no other eligible processes to kill.
> > > 
> > Why? oom_badness() is called after oom_scan_process_thread() returned OOM_SCAN_OK.
> > oom_scan_process_thread() returns OOM_SCAN_ABORT if a thread has TIF_MEMDIE set.
> > 
> 
> oom_scan_process_thread() checks for TIF_MEMDIE on p, not on p's threads.
> If one of p's threads has TIF_MEMDIE set and p does not, we actually want 
> to set TIF_MEMDIE for p.  That's the current behavior since it will lead 
> to p->mm memory freeing.  Your patch is excluding such processes entirely 
> and selecting another process to kill unnecessarily.
> 

I think p's threads are checked by oom_scan_process_thread() for TIF_MEMDIE
even if p does not have TIF_MEMDIE. What am I misunderstanding about what
for_each_process_thread(g, p) is doing?

  #define for_each_process_thread(p, t) for_each_process(p) for_each_thread(p, t)

  select_bad_process() {
    for_each_process_thread(g, p) {
      oom_scan_process_thread(oc, p, totalpages));
      oom_badness(p);
    }
  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
