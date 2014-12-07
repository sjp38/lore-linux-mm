Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 87F8A6B0075
	for <linux-mm@kvack.org>; Sun,  7 Dec 2014 05:45:42 -0500 (EST)
Received: by mail-wi0-f180.google.com with SMTP id n3so2375209wiv.1
        for <linux-mm@kvack.org>; Sun, 07 Dec 2014 02:45:42 -0800 (PST)
Received: from mail-wi0-x22d.google.com (mail-wi0-x22d.google.com. [2a00:1450:400c:c05::22d])
        by mx.google.com with ESMTPS id ha2si56955960wjc.161.2014.12.07.02.45.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 07 Dec 2014 02:45:41 -0800 (PST)
Received: by mail-wi0-f173.google.com with SMTP id r20so2334500wiv.12
        for <linux-mm@kvack.org>; Sun, 07 Dec 2014 02:45:41 -0800 (PST)
Date: Sun, 7 Dec 2014 11:45:39 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -v2 2/5] OOM: thaw the OOM victim if it is frozen
Message-ID: <20141207104539.GK15892@dhcp22.suse.cz>
References: <20141110163055.GC18373@dhcp22.suse.cz>
 <1417797707-31699-1-git-send-email-mhocko@suse.cz>
 <1417797707-31699-3-git-send-email-mhocko@suse.cz>
 <20141206130657.GC18711@htj.dyndns.org>
 <20141207102430.GF15892@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141207102430.GF15892@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "\\\"Rafael J. Wysocki\\\"" <rjw@rjwysocki.net>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-pm@vger.kernel.org

On Sun 07-12-14 11:24:30, Michal Hocko wrote:
> On Sat 06-12-14 08:06:57, Tejun Heo wrote:
> > Hello,
> > 
> > On Fri, Dec 05, 2014 at 05:41:44PM +0100, Michal Hocko wrote:
> > > oom_kill_process only sets TIF_MEMDIE flag and sends a signal to the
> > > victim. This is basically noop when the task is frozen though because
> > > the task sleeps in uninterruptible sleep. The victim is eventually
> > > thawed later when oom_scan_process_thread meets the task again in a
> > > later OOM invocation so the OOM killer doesn't live lock. But this is
> > > less than optimal. Let's add the frozen check and thaw the task right
> > > before we send SIGKILL to the victim.
> > > 
> > > The check and thawing in oom_scan_process_thread has to stay because the
> > > task might got access to memory reserves even without an explicit
> > > SIGKILL from oom_kill_process (e.g. it already has fatal signal pending
> > > or it is exiting already).
> > 
> > How else would a task get TIF_MEMDIE?  If there are other paths which
> > set TIF_MEMDIE, the right thing to do is creating a function which
> > thaws / wakes up the target task and use it there too.  Please
> > interlock these things properly from the get-go instead of scattering
> > these things around.
> 
> See __out_of_memory which sets TIF_MEMDIE on current when it is exiting
> or has fatal signals pending. This task cannot be frozen obviously.

On the other hand we are doing the same early in oom_kill_process which
doesn't work on the current. I've moved the __thaw_task
into mark_tsk_oom_victim so it catches all instances now.
oom_scan_process_thread doesn't need to thaw anymore.
---
