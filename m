Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 3C56B6B00A5
	for <linux-mm@kvack.org>; Thu,  6 Nov 2014 11:02:01 -0500 (EST)
Received: by mail-wg0-f44.google.com with SMTP id x12so1577157wgg.3
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 08:02:00 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id xv4si9982078wjb.167.2014.11.06.08.02.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Nov 2014 08:02:00 -0800 (PST)
Date: Thu, 6 Nov 2014 17:01:58 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/4] OOM, PM: OOM killed task shouldn't escape PM suspend
Message-ID: <20141106160158.GI7202@dhcp22.suse.cz>
References: <20141105133100.GC4527@dhcp22.suse.cz>
 <20141105134219.GD4527@dhcp22.suse.cz>
 <20141105154436.GB14386@htj.dyndns.org>
 <20141105160115.GA28226@dhcp22.suse.cz>
 <20141105162929.GD14386@htj.dyndns.org>
 <20141105163956.GD28226@dhcp22.suse.cz>
 <20141105165428.GF14386@htj.dyndns.org>
 <20141105170111.GG14386@htj.dyndns.org>
 <20141106130543.GE7202@dhcp22.suse.cz>
 <20141106150927.GB25642@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141106150927.GB25642@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <xiyou.wangcong@gmail.com>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux PM list <linux-pm@vger.kernel.org>

On Thu 06-11-14 10:09:27, Tejun Heo wrote:
> On Thu, Nov 06, 2014 at 02:05:43PM +0100, Michal Hocko wrote:
> > But this is nothing new. Suspend hasn't been checking for fatal signals
> > nor for TIF_MEMDIE since the OOM disabling was introduced and I suppose
> > even before.
> > 
> > This is not harmful though. The previous OOM kill attempt would kick the
> > current TASK and mark it with TIF_MEMDIE and retry the allocation. After
> > OOM is disabled the allocation simply fails. The current will die on its
> > way out of the kernel. Definitely worth fixing. In a separate patch.
> 
> Hah?  Isn't this a new outright A-B B-A deadlock involving the rwsem
> you added?

No, see below.
 
> > > disable() call must be able to fail.
> > 
> > This would be a way to do it without requiring caller to check for
> > TIF_MEMDIE explicitly. The fewer of them we have the better.
> 
> Why the hell would the caller ever even KNOW about this?  This is
> something which must be encapsulated in the OOM killer disable/enable
> interface.
> 
> > +bool oom_killer_disable(void)
> >  {
> > +	bool ret = true;
> > +
> >  	down_write(&oom_sem);
> 
> How would this task pass the above down_write() if the OOM killer is
> already read locking oom_sem?  Or is the OOM killer guaranteed to make
> forward progress even if the killed task can't make forward progress?
> But, if so, what are we talking about in this thread?

Yes, OOM killer simply kicks the process sets TIF_MEMDIE and terminates.
That will release the read_lock, allow this to take the write lock and
check whether it the current has been killed without any races.
OOM killer doesn't wait for the killed task. The allocation is retried.

Does this explain your concern?

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
