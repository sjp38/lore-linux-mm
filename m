Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 408FD6B02C3
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 04:06:25 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id h64so2733560wmg.0
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 01:06:25 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i12si2252305wmg.60.2017.06.16.01.06.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 16 Jun 2017 01:06:23 -0700 (PDT)
Date: Fri, 16 Jun 2017 10:06:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mm, oom: prevent additional oom kills before memory is
 freed
Message-ID: <20170616080620.GB30580@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1706141632100.93071@chino.kir.corp.google.com>
 <20170615103909.GG1486@dhcp22.suse.cz>
 <alpine.DEB.2.10.1706151420300.95906@chino.kir.corp.google.com>
 <20170615214133.GB20321@dhcp22.suse.cz>
 <alpine.DEB.2.10.1706151459530.64172@chino.kir.corp.google.com>
 <20170615221236.GB22341@dhcp22.suse.cz>
 <alpine.DEB.2.10.1706151534170.140219@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1706151534170.140219@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 15-06-17 15:42:23, David Rientjes wrote:
> On Fri, 16 Jun 2017, Michal Hocko wrote:
> 
> > I am sorry but I have really hard to make the oom reaper a reliable way
> > to stop all the potential oom lockups go away. I do not want to
> > reintroduce another potential lockup now.
> 
> Please show where this "potential lockup" ever existed in a bug report or 
> a testcase?

I am not aware of any specific bug report. But the main point of the
reaper is to close all _possible_ lockups due to oom victim being stuck
somewhere. exit_aio waits for all kiocbs. Can we guarantee that none
of them will depend on an allocation (directly or via a lock chain) to
proceed? Likewise ksm_exit/khugepaged_exit depend on mmap_sem for write
to proceed. Are we _guaranteed_ nobody can hold mmap_sem for read at
that time and depend on an allocation? Can we guarantee that __mmput
path will work without any depency on allocation in future?

> I have never seen __mmput() block when trying to free the 
> memory it maps.
> 
> > I also do not see why any
> > solution should be rushed into. I have proposed a way to go and unless
> > it is clear that this is not a way forward then I simply do not agree
> > with any partial workarounds or shortcuts.
> 
> This is not a shortcut, it is a bug fix.  4.12 kills 1-4 processes 
> unnecessarily as a result of setting MMF_OOM_SKIP incorrectly before the 
> mm's memory can be freed.  If you have not seen this issue before, which 
> is why you asked if I ever observed it in practice, then you have not 
> stress tested oom reaping.  It is very observable and reproducible.  

I am not questioning that it works for your particular test. I just
argue that it reduces the robustness of the oom reaper because it allows
oom victim to leave the reaper without MMF_OOM_SKIP set and that is the
core concept to guarantee a forward progress. So we should think about
something more appropriate.

> I do 
> not agree that adding additional and obscure locking into __mmput() is the 
> solution to what is plainly and obviously fixed with this simple patch.

Well, __mmput path already depends on the mmap_sem for write. So this is
not a new concept. I am not saying using mmap_sem is the only way. I
will think about that more.
 
> 4.12 needs to stop killing 2-5 processes on every oom condition instead of 
> 1.

Believe me, I am not dismissing the issue nor the fact it _has_ to be
fixed. I just disagree we should make the oom reaper less robust.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
