Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 163666B0003
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 05:13:13 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id g36-v6so2849373edb.3
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 02:13:13 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w14-v6si49309ejv.239.2018.10.10.02.13.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 02:13:11 -0700 (PDT)
Date: Wed, 10 Oct 2018 11:13:09 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: INFO: rcu detected stall in shmem_fault
Message-ID: <20181010091309.GE5873@dhcp22.suse.cz>
References: <000000000000dc48d40577d4a587@google.com>
 <201810100012.w9A0Cjtn047782@www262.sakura.ne.jp>
 <alpine.DEB.2.21.1810092106190.83503@chino.kir.corp.google.com>
 <CACT4Y+bmYbNpu3mQR+X52KX+yPD1N2dnZOtd=iu-oETkevQ9RA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+bmYbNpu3mQR+X52KX+yPD1N2dnZOtd=iu-oETkevQ9RA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, syzbot <syzbot+77e6b28a7a7106ad0def@syzkaller.appspotmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, guro@fb.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Yang Shi <yang.s@alibaba-inc.com>

On Wed 10-10-18 09:55:57, Dmitry Vyukov wrote:
> On Wed, Oct 10, 2018 at 6:11 AM, 'David Rientjes' via syzkaller-bugs
> <syzkaller-bugs@googlegroups.com> wrote:
> > On Wed, 10 Oct 2018, Tetsuo Handa wrote:
> >
> >> syzbot is hitting RCU stall due to memcg-OOM event.
> >> https://syzkaller.appspot.com/bug?id=4ae3fff7fcf4c33a47c1192d2d62d2e03efffa64
> >>
> >> What should we do if memcg-OOM found no killable task because the allocating task
> >> was oom_score_adj == -1000 ? Flooding printk() until RCU stall watchdog fires
> >> (which seems to be caused by commit 3100dab2aa09dc6e ("mm: memcontrol: print proper
> >> OOM header when no eligible victim left") because syzbot was terminating the test
> >> upon WARN(1) removed by that commit) is not a good behavior.
> 
> 
> You want to say that most of the recent hangs and stalls are actually
> caused by our attempt to sandbox test processes with memory cgroup?
> The process with oom_score_adj == -1000 is not supposed to consume any
> significant memory; we have another (test) process with oom_score_adj
> == 0 that's actually consuming memory.
> But should we refrain from using -1000? Perhaps it would be better to
> use -500/500 for control/test process, or -999/1000?

oom disable on a task (especially when this is the only task in the
memcg) is tricky. Look at the memcg report
[  935.562389] Memory limit reached of cgroup /syz0
[  935.567398] memory: usage 204808kB, limit 204800kB, failcnt 6081
[  935.573768] memory+swap: usage 0kB, limit 9007199254740988kB, failcnt 0
[  935.580650] kmem: usage 0kB, limit 9007199254740988kB, failcnt 0
[  935.586923] Memory cgroup stats for /syz0: cache:152KB rss:176336KB rss_huge:163840KB shmem:344KB mapped_file:264KB dirty:0KB writeback:0KB swap:0KB inactive_anon:260KB active_anon:176448KB inactive_file:4KB active_file:0KB

There is still somebody holding anonymous (THP) memory. If there is no
other eligible oom victim then it must be some of the oom disabled ones.
You have suppressed the task list information so we do not know who that
might be though.
 
So it looks like there is some misconfiguration or a bug in the oom
victim selection.
-- 
Michal Hocko
SUSE Labs
