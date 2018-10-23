Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 907F76B000A
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 21:01:22 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id d10so13671778itk.3
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 18:01:22 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id n19-v6si9782994itn.23.2018.10.22.18.01.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Oct 2018 18:01:21 -0700 (PDT)
Message-Id: <201810230101.w9N118i3042448@www262.sakura.ne.jp>
Subject: Re: [RFC PATCH 2/2] memcg: do not report racy no-eligible OOM tasks
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Tue, 23 Oct 2018 10:01:08 +0900
References: <f9a8079f-55b0-301e-9b3d-a5250bd7d277@i-love.sakura.ne.jp> <20181022120308.GB18839@dhcp22.suse.cz>
In-Reply-To: <20181022120308.GB18839@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

Michal Hocko wrote:
> On Mon 22-10-18 20:45:17, Tetsuo Handa wrote:
> > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > index e79cb59552d9..a9dfed29967b 100644
> > > --- a/mm/memcontrol.c
> > > +++ b/mm/memcontrol.c
> > > @@ -1380,10 +1380,22 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
> > >  		.gfp_mask = gfp_mask,
> > >  		.order = order,
> > >  	};
> > > -	bool ret;
> > > +	bool ret = true;
> > >  
> > >  	mutex_lock(&oom_lock);
> > > +
> > > +	/*
> > > +	 * multi-threaded tasks might race with oom_reaper and gain
> > > +	 * MMF_OOM_SKIP before reaching out_of_memory which can lead
> > > +	 * to out_of_memory failure if the task is the last one in
> > > +	 * memcg which would be a false possitive failure reported
> > > +	 */
> > > +	if (tsk_is_oom_victim(current))
> > > +		goto unlock;
> > > +
> > 
> > This is not wrong but is strange. We can use mutex_lock_killable(&oom_lock)
> > so that any killed threads no longer wait for oom_lock.
> 
> tsk_is_oom_victim is stronger because it doesn't depend on
> fatal_signal_pending which might be cleared throughout the exit process.
> 

I still want to propose this. No need to be memcg OOM specific.

 mm/memcontrol.c |  3 ++-
 mm/oom_kill.c   | 10 ++++++++++
 2 files changed, 12 insertions(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e79cb59..2c1e1ac 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1382,7 +1382,8 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	};
 	bool ret;
 
-	mutex_lock(&oom_lock);
+	if (mutex_lock_killable(&oom_lock))
+		return true;
 	ret = out_of_memory(&oc);
 	mutex_unlock(&oom_lock);
 	return ret;
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index f10aa53..e453bad 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -1055,6 +1055,16 @@ bool out_of_memory(struct oom_control *oc)
 	unsigned long freed = 0;
 	enum oom_constraint constraint = CONSTRAINT_NONE;
 
+	/*
+	 * It is possible that multi-threaded OOM victims get
+	 * task_will_free_mem(current) == false when the OOM reaper quickly
+	 * set MMF_OOM_SKIP. But since we know that tsk_is_oom_victim() == true
+	 * tasks won't loop forever (unleess it is a __GFP_NOFAIL allocation
+	 * request), we don't need to select next OOM victim.
+	 */
+	if (tsk_is_oom_victim(current) && !(oc->gfp_mask & __GFP_NOFAIL))
+		return true;
+
 	if (oom_killer_disabled)
 		return false;
 
-- 
1.8.3.1
