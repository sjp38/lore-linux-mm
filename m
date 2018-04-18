Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0D5A06B0005
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 09:26:01 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id t66-v6so882151oih.9
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 06:26:01 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id t207-v6si397385oif.126.2018.04.18.06.25.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Apr 2018 06:25:59 -0700 (PDT)
Subject: Re: [patch v2] mm, oom: fix concurrent munlock and oom reaper unmap
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <alpine.DEB.2.21.1804171928040.100886@chino.kir.corp.google.com>
	<alpine.DEB.2.21.1804171951440.105401@chino.kir.corp.google.com>
	<20180418075051.GO17484@dhcp22.suse.cz>
	<201804182049.EDJ21857.OHJOMOLFQVFFtS@I-love.SAKURA.ne.jp>
	<20180418115830.GA17484@dhcp22.suse.cz>
In-Reply-To: <20180418115830.GA17484@dhcp22.suse.cz>
Message-Id: <201804182225.EII57887.OLMHOFVtQSFJOF@I-love.SAKURA.ne.jp>
Date: Wed, 18 Apr 2018 22:25:54 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, akpm@linux-foundation.org, aarcange@redhat.com, guro@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Michal Hocko wrote:
> > > Can we try a simpler way and get back to what I was suggesting before
> > > [1] and simply not play tricks with
> > > 		down_write(&mm->mmap_sem);
> > > 		up_write(&mm->mmap_sem);
> > > 
> > > and use the write lock in exit_mmap for oom_victims?
> > 
> > You mean something like this?
> 
> or simply hold the write lock until we unmap and free page tables.

That increases possibility of __oom_reap_task_mm() giving up reclaim and
setting MMF_OOM_SKIP when exit_mmap() is making forward progress, doesn't it?
I think that it is better that __oom_reap_task_mm() does not give up when
exit_mmap() can make progress. In that aspect, the section protected by
mmap_sem held for write should be as short as possible.

> It would make the locking rules much more straightforward.
> What you are proposing is more focused on this particular fix and it
> would work as well but the subtle locking would still stay in place.

Yes, this change is focused on -stable patch.

> I am not sure we want the trickiness.

I don't like the trickiness too. I think we can even consider direct OOM
reaping suggested at https://patchwork.kernel.org/patch/10095661/ .

> 
> > Then, I'm tempted to call __oom_reap_task_mm() before holding mmap_sem for write.
> > It would be OK to call __oom_reap_task_mm() at the beginning of __mmput()...
> 
> I am not sure I understand.

To reduce possibility of __oom_reap_task_mm() giving up reclaim and
setting MMF_OOM_SKIP.
