Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id EF7C16B0005
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 16:22:48 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id s6so9297440pgn.16
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 13:22:48 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v5sor4601663pfe.74.2018.04.24.13.22.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Apr 2018 13:22:47 -0700 (PDT)
Date: Tue, 24 Apr 2018 13:22:45 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2] mm, oom: fix concurrent munlock and oom reaperunmap
In-Reply-To: <20180424201352.GV17484@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.21.1804241317200.231037@chino.kir.corp.google.com>
References: <20180419063556.GK17484@dhcp22.suse.cz> <alpine.DEB.2.21.1804191214130.157851@chino.kir.corp.google.com> <20180420082349.GW17484@dhcp22.suse.cz> <20180420124044.GA17484@dhcp22.suse.cz> <alpine.DEB.2.21.1804212019400.84222@chino.kir.corp.google.com>
 <201804221248.CHE35432.FtOMOLSHOFJFVQ@I-love.SAKURA.ne.jp> <alpine.DEB.2.21.1804231706340.18716@chino.kir.corp.google.com> <20180424130432.GB17484@dhcp22.suse.cz> <alpine.DEB.2.21.1804241256000.231037@chino.kir.corp.google.com>
 <20180424201352.GV17484@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrea Arcangeli <aarcange@redhat.com>, guro@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 24 Apr 2018, Michal Hocko wrote:

> > I wanted to remove all per task checks because they are now irrelevant: 
> > this would be the first dependency that exit_mmap() has on any 
> > task_struct, which isn't intuitive -- we simply want to exit the mmap.  
> > There's no requirement that current owns the mm other than this. 
> 
> There is no such requirement in the __oom_reap_task_mm. The given task
> is used for reporting purposes.
> 

And tracing, which is pointless.  And it unnecessarily spams the kernel 
log for basic exiting.

> > I wanted 
> > to avoid the implicit dependency on MMF_OOM_SKIP and make it explicit in 
> > the exit path to be matched with the oom reaper.
> 
> Well, I find it actually better that the code is not explicit about
> MMF_OOM_SKIP. The whole thing happens in the oom proper which should be
> really preferable. The whole synchronization is then completely
> transparent to the oom (including the oom lock etc).
> 

It's already done in exit_mmap().  I'm not changing 

> > I didn't want anything 
> > additional printed to the kernel log about oom reaping unless the 
> > oom_reaper actually needed to intervene, which is useful knowledge outside 
> > of basic exiting.
> 
> Can we shave all those parts as follow ups and make the fix as simple as
> possible?
>  

It is as simple as possible.  It is not doing any unnecessary locking or 
checks that the exit path does not need to do for the sake of a smaller 
patch.  The number of changed lines in the patch is not what I'm 
interested in, I am interested in something that is stable, something that 
works, doesn't add additional (and unnecessary locking), and doesn't 
change around what function sets what bit when called from what path.

> > My patch has passed intensive testing on both x86 and powerpc, so I'll ask 
> > that it's pushed for 4.17-rc3.  Many thanks to Tetsuo for the suggestion 
> > on calling __oom_reap_task_mm() from exit_mmap().
> 
> Yeah, but your patch does have a problem with blockable mmu notifiers
> IIUC.

What on earth are you talking about?  exit_mmap() does 
mmu_notifier_release().  There are no blockable mmu notifiers.
