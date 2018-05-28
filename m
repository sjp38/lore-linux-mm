Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 943916B0007
	for <linux-mm@kvack.org>; Mon, 28 May 2018 11:32:18 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id j18-v6so1365015wme.5
        for <linux-mm@kvack.org>; Mon, 28 May 2018 08:32:18 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 61-v6si394667edc.134.2018.05.28.08.32.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 May 2018 08:32:16 -0700 (PDT)
Date: Mon, 28 May 2018 16:10:00 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v6] Refactor part of the oom report in dump_header
Message-ID: <20180528141000.GG27180@dhcp22.suse.cz>
References: <1527413551-5982-1-git-send-email-ufo19890607@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1527413551-5982-1-git-send-email-ufo19890607@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ufo19890607 <ufo19890607@gmail.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun 27-05-18 10:32:31, ufo19890607 wrote:
> The dump_header does not print the memcg's name when the system
> oom happened, so users cannot locate the certain container which
> contains the task that has been killed by the oom killer.
> 
> I follow the advices of David Rientjes and Michal Hocko, and refactor
> part of the oom report in a backwards compatible way. After this patch,
> users can get the memcg's path from the oom report and check the certain
> container more quickly.
> 
> Below is the part of the oom report in the dmesg
> ...
> [  142.158316] panic cpuset=/ mems_allowed=0-1
> [  142.158983] CPU: 15 PID: 8682 Comm: panic Not tainted 4.17.0-rc6+ #13
> [  142.159659] Hardware name: Inspur SA5212M4/YZMB-00370-107, BIOS 4.1.10 11/14/2016
> [  142.160342] Call Trace:
> [  142.161037]  dump_stack+0x78/0xb3
> [  142.161734]  dump_header+0x7d/0x334
> [  142.162433]  oom_kill_process+0x228/0x490
> [  142.163126]  ? oom_badness+0x2a/0x130
> [  142.163821]  out_of_memory+0xf0/0x280
> [  142.164532]  __alloc_pages_slowpath+0x711/0xa07
> [  142.165241]  __alloc_pages_nodemask+0x23f/0x260
> [  142.165947]  alloc_pages_vma+0x73/0x180
> [  142.166665]  do_anonymous_page+0xed/0x4e0
> [  142.167388]  __handle_mm_fault+0xbd2/0xe00
> [  142.168114]  handle_mm_fault+0x116/0x250
> [  142.168841]  __do_page_fault+0x233/0x4d0
> [  142.169567]  do_page_fault+0x32/0x130
> [  142.170303]  ? page_fault+0x8/0x30
> [  142.171036]  page_fault+0x1e/0x30
> [  142.171764] RIP: 0033:0x7f403000a860
> [  142.172517] RSP: 002b:00007ffc9f745c28 EFLAGS: 00010206
> [  142.173268] RAX: 00007f3f6fd7d000 RBX: 0000000000000000 RCX: 00007f3f7f5cd000
> [  142.174040] RDX: 00007f3fafd7d000 RSI: 0000000000000000 RDI: 00007f3f6fd7d000
> [  142.174806] RBP: 00007ffc9f745c50 R08: ffffffffffffffff R09: 0000000000000000
> [  142.175623] R10: 0000000000000022 R11: 0000000000000246 R12: 0000000000400490
> [  142.176542] R13: 00007ffc9f745d30 R14: 0000000000000000 R15: 0000000000000000
> [  142.177709] oom-kill: constrain=CONSTRAINT_NONE nodemask=(null) origin_memcg= kill_memcg=/test/test1/test2 task=panic pid= 8622 uid=    0

Is it really helpful to dump the nodemask here again? We already have it
as a part of the "%s invoked oom-killer:" message.

Also I am worried that you are trying to do too many thing in a single
patch. One part is to provide an additional information. The other is
to guarantee a single line output. While the later is nice to have is
2*PATH_MAX static buffer justified for something that shouldn't really
occure? Also how often is the OOM report unreadable due to interleaving
messages?
-- 
Michal Hocko
SUSE Labs
