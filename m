Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9EF136B0006
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 16:01:08 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b189so11391746pfa.10
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 13:01:08 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s13-v6sor6061491plq.79.2018.04.24.13.01.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Apr 2018 13:01:06 -0700 (PDT)
Date: Tue, 24 Apr 2018 13:01:03 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2] mm, oom: fix concurrent munlock and oom reaperunmap
In-Reply-To: <20180424130432.GB17484@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.21.1804241256000.231037@chino.kir.corp.google.com>
References: <20180419063556.GK17484@dhcp22.suse.cz> <alpine.DEB.2.21.1804191214130.157851@chino.kir.corp.google.com> <20180420082349.GW17484@dhcp22.suse.cz> <20180420124044.GA17484@dhcp22.suse.cz> <alpine.DEB.2.21.1804212019400.84222@chino.kir.corp.google.com>
 <201804221248.CHE35432.FtOMOLSHOFJFVQ@I-love.SAKURA.ne.jp> <alpine.DEB.2.21.1804231706340.18716@chino.kir.corp.google.com> <20180424130432.GB17484@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrea Arcangeli <aarcange@redhat.com>, guro@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 24 Apr 2018, Michal Hocko wrote:

> Is there any reason why we cannot simply call __oom_reap_task_mm as we
> have it now? mmap_sem for read shouldn't fail here because this is the
> last reference of the mm and we are past the ksm and khugepaged
> synchronizations. So unless my jed laged brain fools me the patch should
> be as simple as the following (I haven't tested it at all).
> 

I wanted to remove all per task checks because they are now irrelevant: 
this would be the first dependency that exit_mmap() has on any 
task_struct, which isn't intuitive -- we simply want to exit the mmap.  
There's no requirement that current owns the mm other than this.  I wanted 
to avoid the implicit dependency on MMF_OOM_SKIP and make it explicit in 
the exit path to be matched with the oom reaper.  I didn't want anything 
additional printed to the kernel log about oom reaping unless the 
oom_reaper actually needed to intervene, which is useful knowledge outside 
of basic exiting.

My patch has passed intensive testing on both x86 and powerpc, so I'll ask 
that it's pushed for 4.17-rc3.  Many thanks to Tetsuo for the suggestion 
on calling __oom_reap_task_mm() from exit_mmap().
