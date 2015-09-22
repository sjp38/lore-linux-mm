Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 7E50F6B0253
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 19:04:21 -0400 (EDT)
Received: by pacbt3 with SMTP id bt3so3580715pac.3
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 16:04:21 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id ez4si752005pbd.42.2015.09.22.16.04.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 16:04:20 -0700 (PDT)
Received: by pacbt3 with SMTP id bt3so3580436pac.3
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 16:04:20 -0700 (PDT)
Date: Tue, 22 Sep 2015 16:04:18 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: can't oom-kill zap the victim's memory?
In-Reply-To: <20150922160608.GA2716@redhat.com>
Message-ID: <alpine.DEB.2.10.1509221557070.1150@chino.kir.corp.google.com>
References: <1442512783-14719-1-git-send-email-kwalker@redhat.com> <20150919150316.GB31952@redhat.com> <CA+55aFwkvbMrGseOsZNaxgP3wzDoVjkGasBKFxpn07SaokvpXA@mail.gmail.com> <20150920125642.GA2104@redhat.com> <CA+55aFyajHq2W9HhJWbLASFkTx_kLSHtHuY6mDHKxmoW-LnVEw@mail.gmail.com>
 <20150921134414.GA15974@redhat.com> <20150921142423.GC19811@dhcp22.suse.cz> <20150921153252.GA21988@redhat.com> <20150921161203.GD19811@dhcp22.suse.cz> <20150922160608.GA2716@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stanislav Kozina <skozina@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

On Tue, 22 Sep 2015, Oleg Nesterov wrote:

> Finally. Whatever we do, we need to change oom_kill_process() first,
> and I think we should do this regardless. The "Kill all user processes
> sharing victim->mm" logic looks wrong and suboptimal/overcomplicated.
> I'll try to make some patches tomorrow if I have time...
> 

Killing all processes sharing the ->mm has been done in the past to 
obviously ensure that memory is eventually freed, but also to solve 
mm->mmap_sem livelocks where a thread is holding a contended mutex and 
needs a fatal signal to acquire TIF_MEMDIE if it calls into the oom killer 
and be able to allocate so that it may eventually drop the mutex.

> But. Can't we just remove another ->oom_score_adj check when we try
> to kill all mm users (the last for_each_process loop). If yes, this
> all can be simplified.
> 

For complete correctness, we would avoid killing any process that shares 
memory with an oom disabled thread since the oom killer shall not kill it 
and otherwise we do not free any memory.

> I guess we can't and its a pity. Because it looks simply pointless
> to not kill all mm users. This just means the select_bad_process()
> picked the wrong task.
> 

This is a side-effect of moving oom scoring to signal_struct from 
mm_struct.  It could be improved separately by flagging mm_structs that 
are unkillable which would also allow for an optimization in 
find_lock_task_mm().

> And while this completely offtopic... why does it take task_lock()
> to protect ->comm? Sure, without task_lock() we can print garbage.
> Is it really that important? I am asking because sometime people
> think that it is not safe to use ->comm lockless, but this is not
> true.
> 

This has come up a couple times in the past and, from what I recall, 
Andrew has said that we don't actually care since the string will always 
be terminated and if we race we don't actually care.  There are other 
places in the kernel where task_lock() isn't used solely to protect 
->comm.  It can be removed from the oom_kill_process() loop checking for 
other potential victims.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
