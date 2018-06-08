Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id B532E6B0003
	for <linux-mm@kvack.org>; Fri,  8 Jun 2018 08:49:56 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id x32-v6so7291047pld.16
        for <linux-mm@kvack.org>; Fri, 08 Jun 2018 05:49:56 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f20-v6sor726637pga.98.2018.06.08.05.49.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Jun 2018 05:49:54 -0700 (PDT)
From: ufo19890607@gmail.com
Subject: [PATCH v8 0/1] Refactor part of the oom report in dump_header
Date: Fri,  8 Jun 2018 20:49:37 +0800
Message-Id: <1528462178-29250-1-git-send-email-ufo19890607@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, yuzhoujian@didichuxing.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, ufo19890607 <ufo19890607@gmail.com>

From: ufo19890607 <ufo19890607@gmail.com>

Some users complains that system-wide oom report does not print memcg's
name which contains the task killed by the oom-killer. The current system
wide oom report prints the task's command, gfp_mask, order ,oom_score_adj 
and shows the memory info, but misses some important information, etc. the 
memcg that has reached its limit and the memcg to which the killed process 
is attached.

I follow the advices of David Rientjes and Michal Hocko, and refactor
part of the oom report. After this patch, users can get the memcg's 
path from the oom report and check the certain container more quickly.

Below is the part of the oom report in the dmesg
...
[  142.158316] panic cpuset=/ mems_allowed=0-1
[  142.158983] CPU: 15 PID: 8682 Comm: panic Not tainted 4.17.0-rc6+ #13
[  142.159659] Hardware name: Inspur SA5212M4/YZMB-00370-107, BIOS 4.1.10 11/14/2016
[  142.160342] Call Trace:
[  142.161037]  dump_stack+0x78/0xb3
[  142.161734]  dump_header+0x7d/0x334
[  142.162433]  oom_kill_process+0x228/0x490
[  142.163126]  ? oom_badness+0x2a/0x130
[  142.163821]  out_of_memory+0xf0/0x280
[  142.164532]  __alloc_pages_slowpath+0x711/0xa07
[  142.165241]  __alloc_pages_nodemask+0x23f/0x260
[  142.165947]  alloc_pages_vma+0x73/0x180
[  142.166665]  do_anonymous_page+0xed/0x4e0
[  142.167388]  __handle_mm_fault+0xbd2/0xe00
[  142.168114]  handle_mm_fault+0x116/0x250
[  142.168841]  __do_page_fault+0x233/0x4d0
[  142.169567]  do_page_fault+0x32/0x130
[  142.170303]  ? page_fault+0x8/0x30
[  142.171036]  page_fault+0x1e/0x30
[  142.171764] RIP: 0033:0x7f403000a860
[  142.172517] RSP: 002b:00007ffc9f745c28 EFLAGS: 00010206
[  142.173268] RAX: 00007f3f6fd7d000 RBX: 0000000000000000 RCX: 00007f3f7f5cd000
[  142.174040] RDX: 00007f3fafd7d000 RSI: 0000000000000000 RDI: 00007f3f6fd7d000
[  142.174806] RBP: 00007ffc9f745c50 R08: ffffffffffffffff R09: 0000000000000000
[  142.175623] R10: 0000000000000022 R11: 0000000000000246 R12: 0000000000400490
[  142.176542] R13: 00007ffc9f745d30 R14: 0000000000000000 R15: 0000000000000000
[  142.177709] oom-kill:constraint=CONSTRAINT_NONE,nodemask=(null),origin_memcg=(null),kill_memcg=/test/test1/test2,task=panic,pid= 8622,uid=    0
...

ufo19890607 (1):
  Refactor part of the oom report in dump_header

 include/linux/memcontrol.h | 29 ++++++++++++++++++++++++++---
 mm/memcontrol.c            | 43 ++++++++++++++++++++++++++++++++-----------
 mm/oom_kill.c              | 26 +++++++++++---------------
 3 files changed, 69 insertions(+), 29 deletions(-)

-- 
2.14.1
