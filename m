Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 983BA6B0003
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 09:50:20 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id k4-v6so1155615pls.15
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 06:50:20 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 66si1373354pfd.75.2018.03.20.06.50.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Mar 2018 06:50:18 -0700 (PDT)
Subject: Re: [PATCH 1/2] mm,oom_reaper: Show trace of unable to reap victim thread.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20180320122818.GL23100@dhcp22.suse.cz>
	<201803202152.HED82804.QFOHLMVFFtOOJS@I-love.SAKURA.ne.jp>
	<20180320131953.GM23100@dhcp22.suse.cz>
	<201803202230.HDH17140.OFtMQJVLOOFHSF@I-love.SAKURA.ne.jp>
	<20180320133445.GP23100@dhcp22.suse.cz>
In-Reply-To: <20180320133445.GP23100@dhcp22.suse.cz>
Message-Id: <201803202250.CHG18290.FJMOtOHLFVQFOS@I-love.SAKURA.ne.jp>
Date: Tue, 20 Mar 2018 22:50:21 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: linux-mm@kvack.org, rientjes@google.com

Michal Hocko wrote:
> On Tue 20-03-18 22:30:16, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Tue 20-03-18 21:52:33, Tetsuo Handa wrote:
> > > > Michal Hocko wrote:
> > > > > A single stack trace in the changelog would be sufficient IMHO.
> > > > > Appart from that. What do you expect users will do about this trace?
> > > > > Sure they will see a path which holds mmap_sem, we will see a bug report
> > > > > but we can hardly do anything about that. We simply cannot drop the lock
> > > > > from that path in 99% of situations. So _why_ do we want to add more
> > > > > information to the log?
> > > > 
> > > > This case is blocked at i_mmap_lock_write().
> > > 
> > > But why does i_mmap_lock_write matter for oom_reaping. We are not
> > > touching hugetlb mappings. dup_mmap holds mmap_sem for write which is
> > > the most probable source of the backoff.
> > 
> > If i_mmap_lock_write can bail out upon SIGKILL, the OOM victim will be able to
> > release mmap_sem held for write, which helps the OOM reaper not to back off.
> 
> There are so many other blocking calls (including allocations) in
> dup_mmap 

Yes. But

>          that I do not really think i_mmap_lock_write is the biggest
> problem. That will be likely the case for other mmap_sem write lockers.

i_mmap_lock_write() is one of the problems which we could afford fixing.
8 out of 11 "oom_reaper: unable to reap" messages are blocked at i_mmap_lock_write().

[  226.608508] oom_reaper: unable to reap pid:9261 (a.out)
[  226.611971] a.out           D13056  9261   6927 0x00100084
[  226.615879] Call Trace:
[  226.617926]  ? __schedule+0x25f/0x780
[  226.620559]  schedule+0x2d/0x80
[  226.623356]  rwsem_down_write_failed+0x2bb/0x440
[  226.626426]  ? rwsem_down_write_failed+0x55/0x440
[  226.629458]  ? anon_vma_fork+0x124/0x150
[  226.632679]  call_rwsem_down_write_failed+0x13/0x20
[  226.635884]  down_write+0x49/0x60
[  226.638867]  ? copy_process.part.41+0x12f2/0x1fe0
[  226.642042]  copy_process.part.41+0x12f2/0x1fe0
[  226.645087]  ? _do_fork+0xe6/0x560
[  226.647991]  _do_fork+0xe6/0x560
[  226.650495]  ? syscall_trace_enter+0x1a9/0x240
[  226.653443]  ? retint_user+0x18/0x18
[  226.656601]  ? page_fault+0x2f/0x50
[  226.659159]  ? trace_hardirqs_on_caller+0x11f/0x1b0
[  226.662399]  do_syscall_64+0x74/0x230
[  226.664989]  entry_SYSCALL_64_after_hwframe+0x42/0xb7

[  354.342331] oom_reaper: unable to reap pid:16611 (a.out)
[  354.346707] a.out           D13312 16611   6927 0x00100084
[  354.351173] Call Trace:
[  354.354164]  ? __schedule+0x25f/0x780
[  354.357633]  schedule+0x2d/0x80
[  354.360976]  rwsem_down_write_failed+0x2bb/0x440
[  354.364774]  ? rwsem_down_write_failed+0x55/0x440
[  354.368749]  call_rwsem_down_write_failed+0x13/0x20
[  354.372703]  down_write+0x49/0x60
[  354.376106]  ? copy_process.part.41+0x12f2/0x1fe0
[  354.379956]  copy_process.part.41+0x12f2/0x1fe0
[  354.383791]  ? _do_fork+0xe6/0x560
[  354.386967]  _do_fork+0xe6/0x560
[  354.390016]  ? syscall_trace_enter+0x1a9/0x240
[  354.393756]  ? retint_user+0x18/0x18
[  354.397296]  ? page_fault+0x2f/0x50
[  354.401081]  ? trace_hardirqs_on_caller+0x11f/0x1b0
[  354.404772]  do_syscall_64+0x74/0x230
[  354.407749]  entry_SYSCALL_64_after_hwframe+0x42/0xb7

[  380.525910] oom_reaper: unable to reap pid:6927 (a.out)
[  380.529274] a.out           R  running task    13544  6927      1 0x00100084
[  380.533264] Call Trace:
[  380.535433]  ? __schedule+0x25f/0x780
[  380.538052]  ? mark_held_locks+0x60/0x80
[  380.540775]  schedule+0x2d/0x80
[  380.543258]  schedule_timeout+0x1a4/0x350
[  380.546053]  ? __next_timer_interrupt+0xd0/0xd0
[  380.549033]  msleep+0x25/0x30
[  380.551458]  shrink_inactive_list+0x5b7/0x690
[  380.554408]  ? __lock_acquire+0x1f1/0xfd0
[  380.557228]  ? find_held_lock+0x2d/0x90
[  380.559959]  shrink_node_memcg+0x340/0x770
[  380.562776]  ? __lock_acquire+0x246/0xfd0
[  380.565532]  ? mem_cgroup_iter+0x121/0x4f0
[  380.568337]  ? mem_cgroup_iter+0x121/0x4f0
[  380.571203]  shrink_node+0xd8/0x370
[  380.573745]  do_try_to_free_pages+0xe3/0x390
[  380.576759]  try_to_free_pages+0xc8/0x110
[  380.579476]  __alloc_pages_slowpath+0x28a/0x8d9
[  380.582639]  __alloc_pages_nodemask+0x21d/0x260
[  380.585662]  new_slab+0x558/0x760
[  380.588188]  ___slab_alloc+0x353/0x6f0
[  380.590962]  ? copy_process.part.41+0x121f/0x1fe0
[  380.594008]  ? find_held_lock+0x2d/0x90
[  380.596750]  ? copy_process.part.41+0x121f/0x1fe0
[  380.599852]  __slab_alloc+0x41/0x7a
[  380.602469]  ? copy_process.part.41+0x121f/0x1fe0
[  380.605607]  kmem_cache_alloc+0x1a6/0x1f0
[  380.608528]  copy_process.part.41+0x121f/0x1fe0
[  380.611613]  ? _do_fork+0xe6/0x560
[  380.614299]  _do_fork+0xe6/0x560
[  380.616752]  ? syscall_trace_enter+0x1a9/0x240
[  380.619813]  ? retint_user+0x18/0x18
[  380.622588]  ? page_fault+0x2f/0x50
[  380.625184]  ? trace_hardirqs_on_caller+0x11f/0x1b0
[  380.628841]  do_syscall_64+0x74/0x230
[  380.631660]  entry_SYSCALL_64_after_hwframe+0x42/0xb7

[  408.397539] oom_reaper: unable to reap pid:6927 (a.out)
[  408.400862] a.out           D13544  6927      1 0x00100084
[  408.404262] Call Trace:
[  408.406449]  ? __schedule+0x25f/0x780
[  408.409063]  schedule+0x2d/0x80
[  408.411440]  rwsem_down_write_failed+0x2bb/0x440
[  408.414544]  ? rwsem_down_write_failed+0x55/0x440
[  408.417684]  call_rwsem_down_write_failed+0x13/0x20
[  408.420866]  down_write+0x49/0x60
[  408.423442]  ? copy_process.part.41+0x12f2/0x1fe0
[  408.426521]  copy_process.part.41+0x12f2/0x1fe0
[  408.429587]  ? _do_fork+0xe6/0x560
[  408.432134]  _do_fork+0xe6/0x560
[  408.434601]  ? syscall_trace_enter+0x1a9/0x240
[  408.437729]  ? retint_user+0x18/0x18
[  408.440391]  ? page_fault+0x2f/0x50
[  408.442955]  ? trace_hardirqs_on_caller+0x11f/0x1b0
[  408.446850]  do_syscall_64+0x74/0x230
[  408.449523]  entry_SYSCALL_64_after_hwframe+0x42/0xb7

[  435.702005] oom_reaper: unable to reap pid:7554 (a.out)
[  435.706759] a.out           D13328  7554   6928 0x00100084
[  435.711417] Call Trace:
[  435.714814]  ? __schedule+0x25f/0x780
[  435.718813]  schedule+0x2d/0x80
[  435.722308]  rwsem_down_write_failed+0x2bb/0x440
[  435.726661]  ? rwsem_down_write_failed+0x55/0x440
[  435.730881]  ? anon_vma_fork+0x124/0x150
[  435.734935]  call_rwsem_down_write_failed+0x13/0x20
[  435.739278]  down_write+0x49/0x60
[  435.743009]  ? copy_process.part.41+0x12f2/0x1fe0
[  435.747173]  copy_process.part.41+0x12f2/0x1fe0
[  435.751304]  ? _do_fork+0xe6/0x560
[  435.754924]  _do_fork+0xe6/0x560
[  435.758538]  ? syscall_trace_enter+0x1a9/0x240
[  435.762533]  ? retint_user+0x18/0x18
[  435.766115]  ? page_fault+0x2f/0x50
[  435.769646]  ? trace_hardirqs_on_caller+0x11f/0x1b0
[  435.773850]  do_syscall_64+0x74/0x230
[  435.777364]  entry_SYSCALL_64_after_hwframe+0x42/0xb7

[  466.269660] oom_reaper: unable to reap pid:7560 (a.out)
[  466.273267] a.out           D13120  7560   6928 0x00100084
[  466.276878] Call Trace:
[  466.279146]  ? __schedule+0x25f/0x780
[  466.281945]  schedule+0x2d/0x80
[  466.284421]  rwsem_down_write_failed+0x2bb/0x440
[  466.287748]  ? rwsem_down_write_failed+0x55/0x440
[  466.291012]  ? anon_vma_fork+0x124/0x150
[  466.293990]  call_rwsem_down_write_failed+0x13/0x20
[  466.297344]  down_write+0x49/0x60
[  466.299925]  ? copy_process.part.41+0x12f2/0x1fe0
[  466.303310]  copy_process.part.41+0x12f2/0x1fe0
[  466.306504]  ? _do_fork+0xe6/0x560
[  466.309257]  _do_fork+0xe6/0x560
[  466.311911]  ? syscall_trace_enter+0x1a9/0x240
[  466.315112]  ? retint_user+0x18/0x18
[  466.317937]  ? page_fault+0x2f/0x50
[  466.320667]  ? trace_hardirqs_on_caller+0x11f/0x1b0
[  466.324043]  do_syscall_64+0x74/0x230
[  466.326999]  entry_SYSCALL_64_after_hwframe+0x42/0xb7

[  495.621196] oom_reaper: unable to reap pid:7563 (a.out)
[  495.624785] a.out           D12992  7563   6928 0x00100084
[  495.628398] Call Trace:
[  495.630634]  ? __schedule+0x25f/0x780
[  495.633464]  schedule+0x2d/0x80
[  495.635952]  rwsem_down_write_failed+0x2bb/0x440
[  495.639169]  ? rwsem_down_write_failed+0x55/0x440
[  495.642432]  ? anon_vma_fork+0x124/0x150
[  495.645216]  call_rwsem_down_write_failed+0x13/0x20
[  495.648651]  down_write+0x49/0x60
[  495.651446]  ? copy_process.part.41+0x12f2/0x1fe0
[  495.654843]  copy_process.part.41+0x12f2/0x1fe0
[  495.658031]  ? _do_fork+0xe6/0x560
[  495.660718]  _do_fork+0xe6/0x560
[  495.663415]  ? syscall_trace_enter+0x1a9/0x240
[  495.666662]  ? retint_user+0x18/0x18
[  495.669369]  ? page_fault+0x2f/0x50
[  495.672162]  ? trace_hardirqs_on_caller+0x11f/0x1b0
[  495.675529]  do_syscall_64+0x74/0x230
[  495.678418]  entry_SYSCALL_64_after_hwframe+0x42/0xb7

[  536.271631] oom_reaper: unable to reap pid:6928 (a.out)
[  536.275197] a.out           D12992  6928      1 0x00100084
[  536.278972] Call Trace:
[  536.281110]  ? __schedule+0x25f/0x780
[  536.283883]  schedule+0x2d/0x80
[  536.286593]  rwsem_down_write_failed+0x2bb/0x440
[  536.289821]  ? rwsem_down_write_failed+0x55/0x440
[  536.293113]  ? anon_vma_fork+0x124/0x150
[  536.296262]  call_rwsem_down_write_failed+0x13/0x20
[  536.299554]  down_write+0x49/0x60
[  536.302514]  ? copy_process.part.41+0x12f2/0x1fe0
[  536.305816]  copy_process.part.41+0x12f2/0x1fe0
[  536.309032]  ? _do_fork+0xe6/0x560
[  536.312206]  _do_fork+0xe6/0x560
[  536.314810]  ? syscall_trace_enter+0x1a9/0x240
[  536.318335]  ? retint_user+0x18/0x18
[  536.321064]  ? page_fault+0x2f/0x50
[  536.323757]  ? trace_hardirqs_on_caller+0x11f/0x1b0
[  536.327396]  do_syscall_64+0x74/0x230
[  536.330175]  entry_SYSCALL_64_after_hwframe+0x42/0xb7

[  600.285293] oom_reaper: unable to reap pid:7550 (a.out)
[  600.289112] a.out           D13104  7550   6931 0x00100084
[  600.292918] Call Trace:
[  600.295506]  ? __schedule+0x25f/0x780
[  600.298614]  ? __lock_acquire+0x246/0xfd0
[  600.301879]  schedule+0x2d/0x80
[  600.304623]  schedule_timeout+0x1fd/0x350
[  600.307633]  ? find_held_lock+0x2d/0x90
[  600.310909]  ? mark_held_locks+0x60/0x80
[  600.314001]  ? _raw_spin_unlock_irq+0x24/0x30
[  600.317382]  wait_for_completion+0xab/0x130
[  600.320579]  ? wake_up_q+0x70/0x70
[  600.323419]  flush_work+0x1bd/0x260
[  600.326434]  ? flush_work+0x174/0x260
[  600.329332]  ? destroy_worker+0x90/0x90
[  600.332301]  drain_all_pages+0x16d/0x1e0
[  600.335464]  __alloc_pages_slowpath+0x443/0x8d9
[  600.338743]  __alloc_pages_nodemask+0x21d/0x260
[  600.342178]  new_slab+0x558/0x760
[  600.344861]  ___slab_alloc+0x353/0x6f0
[  600.347744]  ? copy_process.part.41+0x121f/0x1fe0
[  600.351213]  ? find_held_lock+0x2d/0x90
[  600.354119]  ? copy_process.part.41+0x121f/0x1fe0
[  600.357491]  __slab_alloc+0x41/0x7a
[  600.360206]  ? copy_process.part.41+0x121f/0x1fe0
[  600.363480]  kmem_cache_alloc+0x1a6/0x1f0
[  600.366579]  copy_process.part.41+0x121f/0x1fe0
[  600.369761]  ? _do_fork+0xe6/0x560
[  600.372382]  _do_fork+0xe6/0x560
[  600.375142]  ? syscall_trace_enter+0x1a9/0x240
[  600.378258]  ? retint_user+0x18/0x18
[  600.380978]  ? page_fault+0x2f/0x50
[  600.383814]  ? trace_hardirqs_on_caller+0x11f/0x1b0
[  600.387096]  do_syscall_64+0x74/0x230
[  600.389928]  entry_SYSCALL_64_after_hwframe+0x42/0xb7

[  664.684801] oom_reaper: unable to reap pid:7558 (a.out)
[  664.892292] a.out           D13272  7558   6931 0x00100084
[  664.895765] Call Trace:
[  664.897574]  ? __schedule+0x25f/0x780
[  664.900099]  schedule+0x2d/0x80
[  664.902260]  rwsem_down_write_failed+0x2bb/0x440
[  664.905249]  ? rwsem_down_write_failed+0x55/0x440
[  664.908335]  ? free_pgd_range+0x569/0x5e0
[  664.911145]  call_rwsem_down_write_failed+0x13/0x20
[  664.914121]  down_write+0x49/0x60
[  664.916519]  ? unlink_file_vma+0x28/0x50
[  664.919255]  unlink_file_vma+0x28/0x50
[  664.922234]  free_pgtables+0x36/0x100
[  664.924797]  exit_mmap+0xbb/0x180
[  664.927220]  mmput+0x50/0x110
[  664.929504]  copy_process.part.41+0xb61/0x1fe0
[  664.932448]  ? _do_fork+0xe6/0x560
[  664.934902]  ? _do_fork+0xe6/0x560
[  664.937361]  _do_fork+0xe6/0x560
[  664.939742]  ? syscall_trace_enter+0x1a9/0x240
[  664.942693]  ? retint_user+0x18/0x18
[  664.945309]  ? page_fault+0x2f/0x50
[  664.947896]  ? trace_hardirqs_on_caller+0x11f/0x1b0
[  664.951075]  do_syscall_64+0x74/0x230
[  664.953747]  entry_SYSCALL_64_after_hwframe+0x42/0xb7

[  744.980868] oom_reaper: unable to reap pid:6928 (a.out)
[  744.984653] a.out           D12992  6928      1 0x00100084
[  744.988278] Call Trace:
[  744.990524]  ? __schedule+0x25f/0x780
[  744.993435]  schedule+0x2d/0x80
[  744.995877]  rwsem_down_write_failed+0x2bb/0x440
[  744.999272]  ? rwsem_down_write_failed+0x55/0x440
[  745.002759]  ? anon_vma_fork+0x124/0x150
[  745.005789]  call_rwsem_down_write_failed+0x13/0x20
[  745.009324]  down_write+0x49/0x60
[  745.012134]  ? copy_process.part.41+0x12f2/0x1fe0
[  745.015574]  copy_process.part.41+0x12f2/0x1fe0
[  745.018845]  ? _do_fork+0xe6/0x560
[  745.021698]  _do_fork+0xe6/0x560
[  745.024275]  ? syscall_trace_enter+0x1a9/0x240
[  745.027443]  ? retint_user+0x18/0x18
[  745.030281]  ? page_fault+0x2f/0x50
[  745.033138]  ? trace_hardirqs_on_caller+0x11f/0x1b0
[  745.036703]  do_syscall_64+0x74/0x230
[  745.039476]  entry_SYSCALL_64_after_hwframe+0x42/0xb7

> 
> Really I am not sure dumping more information is beneficial here.

Converting to use killable where we can afford is beneficial.
