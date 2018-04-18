Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5DB526B0005
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 09:44:03 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 31-v6so1876524wrr.2
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 06:44:03 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l14si1456224edk.462.2018.04.18.06.44.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Apr 2018 06:44:02 -0700 (PDT)
Date: Wed, 18 Apr 2018 15:44:01 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch v2] mm, oom: fix concurrent munlock and oom reaper unmap
Message-ID: <20180418134401.GF17484@dhcp22.suse.cz>
References: <alpine.DEB.2.21.1804171928040.100886@chino.kir.corp.google.com>
 <alpine.DEB.2.21.1804171951440.105401@chino.kir.corp.google.com>
 <20180418075051.GO17484@dhcp22.suse.cz>
 <201804182049.EDJ21857.OHJOMOLFQVFFtS@I-love.SAKURA.ne.jp>
 <20180418115830.GA17484@dhcp22.suse.cz>
 <201804182225.EII57887.OLMHOFVtQSFJOF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201804182225.EII57887.OLMHOFVtQSFJOF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, akpm@linux-foundation.org, aarcange@redhat.com, guro@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 18-04-18 22:25:54, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > > > Can we try a simpler way and get back to what I was suggesting before
> > > > [1] and simply not play tricks with
> > > > 		down_write(&mm->mmap_sem);
> > > > 		up_write(&mm->mmap_sem);
> > > > 
> > > > and use the write lock in exit_mmap for oom_victims?
> > > 
> > > You mean something like this?
> > 
> > or simply hold the write lock until we unmap and free page tables.
> 
> That increases possibility of __oom_reap_task_mm() giving up reclaim and
> setting MMF_OOM_SKIP when exit_mmap() is making forward progress, doesn't it?

Yes it does. But it is not that likely and easily noticeable from the
logs so we can make the locking protocol more complex if this really
hits two often.

> I think that it is better that __oom_reap_task_mm() does not give up when
> exit_mmap() can make progress. In that aspect, the section protected by
> mmap_sem held for write should be as short as possible.

Sure, but then weight the complexity on the other side and try to think
whether simpler code which works most of the time is better than a buggy
complex one. The current protocol has 2 followup fixes which speaks for
itself.
 
[...]
> > > Then, I'm tempted to call __oom_reap_task_mm() before holding mmap_sem for write.
> > > It would be OK to call __oom_reap_task_mm() at the beginning of __mmput()...
> > 
> > I am not sure I understand.
> 
> To reduce possibility of __oom_reap_task_mm() giving up reclaim and
> setting MMF_OOM_SKIP.

Still do not understand. Do you want to call __oom_reap_task_mm from
__mmput? If yes why would you do so when exit_mmap does a stronger
version of it?

-- 
Michal Hocko
SUSE Labs
