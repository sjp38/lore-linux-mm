Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 364506B000A
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 09:20:00 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id n15so951723pff.14
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 06:20:00 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q4-v6si1607117plr.365.2018.03.20.06.19.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 20 Mar 2018 06:19:56 -0700 (PDT)
Date: Tue, 20 Mar 2018 14:19:53 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 1/2] mm,oom_reaper: Show trace of unable to reap victim
 thread.
Message-ID: <20180320131953.GM23100@dhcp22.suse.cz>
References: <1521547076-3399-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180320122818.GL23100@dhcp22.suse.cz>
 <201803202152.HED82804.QFOHLMVFFtOOJS@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201803202152.HED82804.QFOHLMVFFtOOJS@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com

On Tue 20-03-18 21:52:33, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Tue 20-03-18 20:57:55, Tetsuo Handa wrote:
> > > I found that it is not difficult to hit "oom_reaper: unable to reap pid:"
> > > messages if the victim thread is doing copy_process(). Since I noticed
> > > that it is likely helpful to show trace of unable to reap victim thread
> > > for finding locations which should use killable wait, this patch does so.
> > > 
> > > [  226.608508] oom_reaper: unable to reap pid:9261 (a.out)
> > > [  226.611971] a.out           D13056  9261   6927 0x00100084
> > > [  226.615879] Call Trace:
> > > [  226.617926]  ? __schedule+0x25f/0x780
> > > [  226.620559]  schedule+0x2d/0x80
> > > [  226.623356]  rwsem_down_write_failed+0x2bb/0x440
> > > [  226.626426]  ? rwsem_down_write_failed+0x55/0x440
> > > [  226.629458]  ? anon_vma_fork+0x124/0x150
> > > [  226.632679]  call_rwsem_down_write_failed+0x13/0x20
> > > [  226.635884]  down_write+0x49/0x60
> > > [  226.638867]  ? copy_process.part.41+0x12f2/0x1fe0
> > > [  226.642042]  copy_process.part.41+0x12f2/0x1fe0 /* i_mmap_lock_write() in dup_mmap() */
> > > [  226.645087]  ? _do_fork+0xe6/0x560
> > > [  226.647991]  _do_fork+0xe6/0x560
> > > [  226.650495]  ? syscall_trace_enter+0x1a9/0x240
> > > [  226.653443]  ? retint_user+0x18/0x18
> > > [  226.656601]  ? page_fault+0x2f/0x50
> > > [  226.659159]  ? trace_hardirqs_on_caller+0x11f/0x1b0
> > > [  226.662399]  do_syscall_64+0x74/0x230
> > > [  226.664989]  entry_SYSCALL_64_after_hwframe+0x42/0xb7
> > 
> > A single stack trace in the changelog would be sufficient IMHO.
> > Appart from that. What do you expect users will do about this trace?
> > Sure they will see a path which holds mmap_sem, we will see a bug report
> > but we can hardly do anything about that. We simply cannot drop the lock
> > from that path in 99% of situations. So _why_ do we want to add more
> > information to the log?
> 
> This case is blocked at i_mmap_lock_write().

But why does i_mmap_lock_write matter for oom_reaping. We are not
touching hugetlb mappings. dup_mmap holds mmap_sem for write which is
the most probable source of the backoff.

-- 
Michal Hocko
SUSE Labs
