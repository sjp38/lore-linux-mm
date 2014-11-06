Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f45.google.com (mail-qa0-f45.google.com [209.85.216.45])
	by kanga.kvack.org (Postfix) with ESMTP id 9F80D6B00B3
	for <linux-mm@kvack.org>; Thu,  6 Nov 2014 11:33:10 -0500 (EST)
Received: by mail-qa0-f45.google.com with SMTP id dc16so982882qab.32
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 08:33:10 -0800 (PST)
Received: from mail-qg0-x22a.google.com (mail-qg0-x22a.google.com. [2607:f8b0:400d:c04::22a])
        by mx.google.com with ESMTPS id bk7si12579319qcb.43.2014.11.06.08.33.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Nov 2014 08:33:09 -0800 (PST)
Received: by mail-qg0-f42.google.com with SMTP id i50so1020033qgf.1
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 08:33:09 -0800 (PST)
Date: Thu, 6 Nov 2014 11:33:04 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/4] OOM, PM: OOM killed task shouldn't escape PM suspend
Message-ID: <20141106163304.GE25642@htj.dyndns.org>
References: <20141105160115.GA28226@dhcp22.suse.cz>
 <20141105162929.GD14386@htj.dyndns.org>
 <20141105163956.GD28226@dhcp22.suse.cz>
 <20141105165428.GF14386@htj.dyndns.org>
 <20141105170111.GG14386@htj.dyndns.org>
 <20141106130543.GE7202@dhcp22.suse.cz>
 <20141106150927.GB25642@htj.dyndns.org>
 <20141106160158.GI7202@dhcp22.suse.cz>
 <20141106161211.GC25642@htj.dyndns.org>
 <20141106163124.GK7202@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141106163124.GK7202@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <xiyou.wangcong@gmail.com>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux PM list <linux-pm@vger.kernel.org>

On Thu, Nov 06, 2014 at 05:31:24PM +0100, Michal Hocko wrote:
> On Thu 06-11-14 11:12:11, Tejun Heo wrote:
> > On Thu, Nov 06, 2014 at 05:01:58PM +0100, Michal Hocko wrote:
> > > Yes, OOM killer simply kicks the process sets TIF_MEMDIE and terminates.
> > > That will release the read_lock, allow this to take the write lock and
> > > check whether it the current has been killed without any races.
> > > OOM killer doesn't wait for the killed task. The allocation is retried.
> > > 
> > > Does this explain your concern?
> > 
> > Draining oom killer then doesn't mean anything, no?  OOM killer may
> > have been disabled and drained but the killed tasks might wake up
> > after the PM freezer considers them to be frozen, right?  What am I
> > missing?
> 
> The mutual exclusion between OOM and the freezer will cause that the
> victim will have TIF_MEMDIE already set when try_to_freeze_tasks even
> starts. Then freezing_slow_path wouldn't allow the task to enter the
> fridge so the wake up moment is not really that important.

What if it was already in the freezer?

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
