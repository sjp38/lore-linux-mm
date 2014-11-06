Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f170.google.com (mail-qc0-f170.google.com [209.85.216.170])
	by kanga.kvack.org (Postfix) with ESMTP id 872C5280002
	for <linux-mm@kvack.org>; Thu,  6 Nov 2014 10:09:32 -0500 (EST)
Received: by mail-qc0-f170.google.com with SMTP id l6so903779qcy.15
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 07:09:32 -0800 (PST)
Received: from mail-qa0-x22f.google.com (mail-qa0-x22f.google.com. [2607:f8b0:400d:c00::22f])
        by mx.google.com with ESMTPS id 4si12151667qas.84.2014.11.06.07.09.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Nov 2014 07:09:31 -0800 (PST)
Received: by mail-qa0-f47.google.com with SMTP id dc16so846227qab.20
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 07:09:31 -0800 (PST)
Date: Thu, 6 Nov 2014 10:09:27 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/4] OOM, PM: OOM killed task shouldn't escape PM suspend
Message-ID: <20141106150927.GB25642@htj.dyndns.org>
References: <20141105130247.GA14386@htj.dyndns.org>
 <20141105133100.GC4527@dhcp22.suse.cz>
 <20141105134219.GD4527@dhcp22.suse.cz>
 <20141105154436.GB14386@htj.dyndns.org>
 <20141105160115.GA28226@dhcp22.suse.cz>
 <20141105162929.GD14386@htj.dyndns.org>
 <20141105163956.GD28226@dhcp22.suse.cz>
 <20141105165428.GF14386@htj.dyndns.org>
 <20141105170111.GG14386@htj.dyndns.org>
 <20141106130543.GE7202@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141106130543.GE7202@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <xiyou.wangcong@gmail.com>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux PM list <linux-pm@vger.kernel.org>

On Thu, Nov 06, 2014 at 02:05:43PM +0100, Michal Hocko wrote:
> But this is nothing new. Suspend hasn't been checking for fatal signals
> nor for TIF_MEMDIE since the OOM disabling was introduced and I suppose
> even before.
> 
> This is not harmful though. The previous OOM kill attempt would kick the
> current TASK and mark it with TIF_MEMDIE and retry the allocation. After
> OOM is disabled the allocation simply fails. The current will die on its
> way out of the kernel. Definitely worth fixing. In a separate patch.

Hah?  Isn't this a new outright A-B B-A deadlock involving the rwsem
you added?

> > disable() call must be able to fail.
> 
> This would be a way to do it without requiring caller to check for
> TIF_MEMDIE explicitly. The fewer of them we have the better.

Why the hell would the caller ever even KNOW about this?  This is
something which must be encapsulated in the OOM killer disable/enable
interface.

> +bool oom_killer_disable(void)
>  {
> +	bool ret = true;
> +
>  	down_write(&oom_sem);

How would this task pass the above down_write() if the OOM killer is
already read locking oom_sem?  Or is the OOM killer guaranteed to make
forward progress even if the killed task can't make forward progress?
But, if so, what are we talking about in this thread?

> +
> +	/* We might have been killed while waiting for the oom_sem. */
> +	if (fatal_signal_pending(current) || test_thread_flag(TIF_MEMDIE)) {
> +		up_write(&oom_sem);
> +		ret = false;
> +	}

This is pointless.  What does the above do?

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
