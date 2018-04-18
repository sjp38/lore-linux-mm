Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id A2EFF6B0005
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 04:00:58 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id i4-v6so903958wrh.4
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 01:00:58 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b1si1032933edb.360.2018.04.18.01.00.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Apr 2018 01:00:57 -0700 (PDT)
Date: Wed, 18 Apr 2018 10:00:56 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v4 PATCH] mm: introduce arg_lock to protect arg_start|end and
 env_start|end in mm_struct
Message-ID: <20180418080056.GQ17484@dhcp22.suse.cz>
References: <1523730291-109696-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180417112957.84de526138f404a04298ec4c@linux-foundation.org>
 <20180417203919.GF19578@uranus.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180417203919.GF19578@uranus.lan>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Yang Shi <yang.shi@linux.alibaba.com>, adobriyan@gmail.com, willy@infradead.org, mguzik@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 17-04-18 23:39:19, Cyrill Gorcunov wrote:
> On Tue, Apr 17, 2018 at 11:29:57AM -0700, Andrew Morton wrote:
> > On Sun, 15 Apr 2018 02:24:51 +0800 Yang Shi <yang.shi@linux.alibaba.com> wrote:
> > 
> > > mmap_sem is on the hot path of kernel, and it very contended, but it is
> > > abused too. It is used to protect arg_start|end and evn_start|end when
> > > reading /proc/$PID/cmdline and /proc/$PID/environ, but it doesn't make
> > > sense since those proc files just expect to read 4 values atomically and
> > > not related to VM, they could be set to arbitrary values by C/R.
> > > 
> > > And, the mmap_sem contention may cause unexpected issue like below:
> > > 
> > > INFO: task ps:14018 blocked for more than 120 seconds.
> > >        Tainted: G            E 4.9.79-009.ali3000.alios7.x86_64 #1
> > >  "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this
> > > message.
> > >  ps              D    0 14018      1 0x00000004
> > >   ffff885582f84000 ffff885e8682f000 ffff880972943000 ffff885ebf499bc0
> > >   ffff8828ee120000 ffffc900349bfca8 ffffffff817154d0 0000000000000040
> > >   00ffffff812f872a ffff885ebf499bc0 024000d000948300 ffff880972943000
> > >  Call Trace:
> > >   [<ffffffff817154d0>] ? __schedule+0x250/0x730
> > >   [<ffffffff817159e6>] schedule+0x36/0x80
> > >   [<ffffffff81718560>] rwsem_down_read_failed+0xf0/0x150
> > >   [<ffffffff81390a28>] call_rwsem_down_read_failed+0x18/0x30
> > >   [<ffffffff81717db0>] down_read+0x20/0x40
> > >   [<ffffffff812b9439>] proc_pid_cmdline_read+0xd9/0x4e0
> > >   [<ffffffff81253c95>] ? do_filp_open+0xa5/0x100
> > >   [<ffffffff81241d87>] __vfs_read+0x37/0x150
> > >   [<ffffffff812f824b>] ? security_file_permission+0x9b/0xc0
> > >   [<ffffffff81242266>] vfs_read+0x96/0x130
> > >   [<ffffffff812437b5>] SyS_read+0x55/0xc0
> > >   [<ffffffff8171a6da>] entry_SYSCALL_64_fastpath+0x1a/0xc5
> > > 
> > > Both Alexey Dobriyan and Michal Hocko suggested to use dedicated lock
> > > for them to mitigate the abuse of mmap_sem.
> > > 
> > > So, introduce a new spinlock in mm_struct to protect the concurrent
> > > access to arg_start|end, env_start|end and others, as well as replace
> > > write map_sem to read to protect the race condition between prctl and
> > > sys_brk which might break check_data_rlimit(), and makes prctl more
> > > friendly to other VM operations.
> > 
> > (We should move check_data_rlimit() out of the .h file)
> > 
> > It seems inconsistent to be using mmap_sem to protect ->start_brk and
> > friends in sys_brk().  We've already declared that these are protected
> > by arg_lock so that's what we should be using?  And getting this
> > consistent should permit us to stop using mmap_sem in prctl()
> > altogether?
> 
> Nope, we still can't. Look, the down_read part order the call with
> sys_brk. while arg_lock orders prctl call itself. That said if
> someone is calling sys_brk while we're in a middle of prctl it
> should wait until prctl finished. But two simultaneous prcl
> may proceed without taking a write lock using arg_lock as
> a barrier.

A small comment would be due. The changelog mentions this but it would
be nicer to comment why we care about mmap_sem for read in prctl.

-- 
Michal Hocko
SUSE Labs
