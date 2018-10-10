Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0A2B96B0275
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 20:13:08 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id o6-v6so2467932oib.9
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 17:13:08 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id n5si4070248otj.129.2018.10.09.17.13.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Oct 2018 17:13:06 -0700 (PDT)
Message-Id: <201810100012.w9A0Cjtn047782@www262.sakura.ne.jp>
Subject: Re: INFO: rcu detected stall in =?ISO-2022-JP?B?c2htZW1fZmF1bHQ=?=
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Wed, 10 Oct 2018 09:12:45 +0900
References: <000000000000dc48d40577d4a587@google.com>
In-Reply-To: <000000000000dc48d40577d4a587@google.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <syzbot+77e6b28a7a7106ad0def@syzkaller.appspotmail.com>, hannes@cmpxchg.org, mhocko@kernel.org
Cc: akpm@linux-foundation.org, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rientjes@google.com, syzkaller-bugs@googlegroups.com, yang.s@alibaba-inc.com

syzbot is hitting RCU stall due to memcg-OOM event.
https://syzkaller.appspot.com/bug?id=4ae3fff7fcf4c33a47c1192d2d62d2e03efffa64

What should we do if memcg-OOM found no killable task because the allocating task
was oom_score_adj == -1000 ? Flooding printk() until RCU stall watchdog fires 
(which seems to be caused by commit 3100dab2aa09dc6e ("mm: memcontrol: print proper
OOM header when no eligible victim left") because syzbot was terminating the test
upon WARN(1) removed by that commit) is not a good behavior.


syz-executor0 invoked oom-killer: gfp_mask=0x6200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null), order=0, oom_score_adj=-1000
syz-executor0 cpuset=syz0 mems_allowed=0
CPU: 0 PID: 2050 Comm: syz-executor0 Not tainted 4.19.0-rc7-next-20181009+ #90
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
Call Trace:
(...snipped...)
Memory limit reached of cgroup /syz0
memory: usage 205168kB, limit 204800kB, failcnt 6909
memory+swap: usage 0kB, limit 9007199254740988kB, failcnt 0
kmem: usage 0kB, limit 9007199254740988kB, failcnt 0
Memory cgroup stats for /syz0: cache:680KB rss:176336KB rss_huge:163840KB shmem:740KB mapped_file:660KB dirty:0KB writeback:0KB swap:0KB inactive_anon:712KB active_anon:176448KB inactive_file:0KB active_file:4KB unevictable:0KB
Out of memory and no killable processes...
