Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 512FA8E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 03:11:06 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id x15so1297153edd.2
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 00:11:06 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e8si1021110eda.360.2019.01.08.00.11.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 00:11:04 -0800 (PST)
Date: Tue, 8 Jan 2019 09:11:01 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm, oom: marks all killed tasks as oom victims
Message-ID: <20190108081101.GN31793@dhcp22.suse.cz>
References: <20190107143802.16847-1-mhocko@kernel.org>
 <20190107143802.16847-2-mhocko@kernel.org>
 <1054b5c6-19c0-53a4-206e-dd55f5a3d732@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1054b5c6-19c0-53a4-206e-dd55f5a3d732@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 08-01-19 05:58:41, Tetsuo Handa wrote:
> On 2019/01/07 23:38, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > Historically we have called mark_oom_victim only to the main task
> > selected as the oom victim because oom victims have access to memory
> > reserves and granting the access to all killed tasks could deplete
> > memory reserves very quickly and cause even larger problems.
> > 
> > Since only a partial access to memory reserves is allowed there is no
> > longer this risk and so all tasks killed along with the oom victim
> > can be considered as well.
> > 
> > The primary motivation for that is that process groups which do not
> > shared signals would behave more like standard thread groups wrt oom
> > handling (aka tsk_is_oom_victim will work the same way for them).
> > 
> > - Use find_lock_task_mm to stabilize mm as suggested by Tetsuo
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> >  mm/oom_kill.c | 6 ++++++
> >  1 file changed, 6 insertions(+)
> > 
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index f0e8cd9edb1a..0246c7a4e44e 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -892,6 +892,7 @@ static void __oom_kill_process(struct task_struct *victim)
> >  	 */
> >  	rcu_read_lock();
> >  	for_each_process(p) {
> > +		struct task_struct *t;
> >  		if (!process_shares_mm(p, mm))
> >  			continue;
> >  		if (same_thread_group(p, victim))
> > @@ -911,6 +912,11 @@ static void __oom_kill_process(struct task_struct *victim)
> >  		if (unlikely(p->flags & PF_KTHREAD))
> >  			continue;
> >  		do_send_sig_info(SIGKILL, SEND_SIG_PRIV, p, PIDTYPE_TGID);
> > +		t = find_lock_task_mm(p);
> > +		if (!t)
> > +			continue;
> > +		mark_oom_victim(t);
> > +		task_unlock(t);
> 
> Thank you for updating this patch. This patch is correct from the point of
> view of avoiding TIF_MEMDIE race. But if I recall correctly, the reason we
> did not do this is to avoid depleting memory reserves. And we still grant
> full access to memory reserves for CONFIG_MMU=n case. Shouldn't the changelog
> mention CONFIG_MMU=n case?

Like so many times before. Does nommu matter in this context at all? You
keep bringing it up without actually trying to understand that nommu is
so special that reserves for those architectures are of very limited
use. I do not really see much point mentioning nommu in every oom patch.

Or do you know of a nommu oom killer bug out there? I would be more than
curious. Seriously.
-- 
Michal Hocko
SUSE Labs
