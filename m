Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 866BE6B026D
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 16:30:13 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id t19-v6so10814847plo.9
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 13:30:13 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d2-v6sor933750pll.134.2018.07.09.13.30.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 09 Jul 2018 13:30:12 -0700 (PDT)
Date: Mon, 9 Jul 2018 13:30:10 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v3] mm, oom: fix unnecessary killing of additional
 processes
In-Reply-To: <20180709123524.GK22049@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.21.1807091323570.101462@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1806211434420.51095@chino.kir.corp.google.com> <20180705164621.0a4fe6ab3af27a1d387eecc9@linux-foundation.org> <alpine.DEB.2.21.1807061652430.71359@chino.kir.corp.google.com> <20180709123524.GK22049@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, kbuild test robot <fengguang.wu@intel.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 9 Jul 2018, Michal Hocko wrote:

> > Blockable mmu notifiers and mlocked memory is not the extent of the 
> > problem, if a process has a lot of virtual memory we must wait until 
> > free_pgtables() completes in exit_mmap() to prevent unnecessary oom 
> > killing.  For implementations such as tcmalloc, which does not release 
> > virtual memory, this is important because, well, it releases this only at 
> > exit_mmap().  Of course we cannot do that with only the protection of 
> > mm->mmap_sem for read.
> 
> And how exactly a timeout helps to prevent from "unnecessary killing" in
> that case?

As my patch does, it becomes mandatory to move MMF_OOM_SKIP to after 
free_pgtables() in exit_mmap() and then repurpose MMF_UNSTABLE to 
indicate that the oom reaper should not operate on a given mm.  In the 
event we cannot reach MMF_OOM_SKIP, we need to ensure forward progress and 
that is possible with a timeout period in the very rare instance where 
additional memory freeing is needed, and without unnecessary oom killing 
when it is not needed.
