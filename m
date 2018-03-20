Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 831C56B000C
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 08:52:30 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id i11so842095pgq.10
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 05:52:30 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id i131si1137284pgc.347.2018.03.20.05.52.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Mar 2018 05:52:29 -0700 (PDT)
Subject: Re: [PATCH 1/2] mm,oom_reaper: Show trace of unable to reap victim thread.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1521547076-3399-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20180320122818.GL23100@dhcp22.suse.cz>
In-Reply-To: <20180320122818.GL23100@dhcp22.suse.cz>
Message-Id: <201803202152.HED82804.QFOHLMVFFtOOJS@I-love.SAKURA.ne.jp>
Date: Tue, 20 Mar 2018 21:52:33 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: linux-mm@kvack.org, rientjes@google.com

Michal Hocko wrote:
> On Tue 20-03-18 20:57:55, Tetsuo Handa wrote:
> > I found that it is not difficult to hit "oom_reaper: unable to reap pid:"
> > messages if the victim thread is doing copy_process(). Since I noticed
> > that it is likely helpful to show trace of unable to reap victim thread
> > for finding locations which should use killable wait, this patch does so.
> > 
> > [  226.608508] oom_reaper: unable to reap pid:9261 (a.out)
> > [  226.611971] a.out           D13056  9261   6927 0x00100084
> > [  226.615879] Call Trace:
> > [  226.617926]  ? __schedule+0x25f/0x780
> > [  226.620559]  schedule+0x2d/0x80
> > [  226.623356]  rwsem_down_write_failed+0x2bb/0x440
> > [  226.626426]  ? rwsem_down_write_failed+0x55/0x440
> > [  226.629458]  ? anon_vma_fork+0x124/0x150
> > [  226.632679]  call_rwsem_down_write_failed+0x13/0x20
> > [  226.635884]  down_write+0x49/0x60
> > [  226.638867]  ? copy_process.part.41+0x12f2/0x1fe0
> > [  226.642042]  copy_process.part.41+0x12f2/0x1fe0 /* i_mmap_lock_write() in dup_mmap() */
> > [  226.645087]  ? _do_fork+0xe6/0x560
> > [  226.647991]  _do_fork+0xe6/0x560
> > [  226.650495]  ? syscall_trace_enter+0x1a9/0x240
> > [  226.653443]  ? retint_user+0x18/0x18
> > [  226.656601]  ? page_fault+0x2f/0x50
> > [  226.659159]  ? trace_hardirqs_on_caller+0x11f/0x1b0
> > [  226.662399]  do_syscall_64+0x74/0x230
> > [  226.664989]  entry_SYSCALL_64_after_hwframe+0x42/0xb7
> 
> A single stack trace in the changelog would be sufficient IMHO.
> Appart from that. What do you expect users will do about this trace?
> Sure they will see a path which holds mmap_sem, we will see a bug report
> but we can hardly do anything about that. We simply cannot drop the lock
> from that path in 99% of situations. So _why_ do we want to add more
> information to the log?

This case is blocked at i_mmap_lock_write(). If we can add error handling path
there, we can replace i_mmap_lock_write() with i_mmap_lock_write_killable() and
bail out soon. This patch helps finding such locations.
