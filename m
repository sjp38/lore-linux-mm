Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B02446B0003
	for <linux-mm@kvack.org>; Wed, 30 May 2018 16:56:44 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id k13-v6so4407044pgr.11
        for <linux-mm@kvack.org>; Wed, 30 May 2018 13:56:44 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n59-v6sor1065976plb.0.2018.05.30.13.56.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 May 2018 13:56:43 -0700 (PDT)
Date: Wed, 30 May 2018 13:56:41 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v6] Refactor part of the oom report in dump_header
In-Reply-To: <20180528141000.GG27180@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.21.1805301353140.150424@chino.kir.corp.google.com>
References: <1527413551-5982-1-git-send-email-ufo19890607@gmail.com> <20180528141000.GG27180@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: ufo19890607 <ufo19890607@gmail.com>, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 28 May 2018, Michal Hocko wrote:

> > Below is the part of the oom report in the dmesg
> > ...
> > [  142.158316] panic cpuset=/ mems_allowed=0-1
> > [  142.158983] CPU: 15 PID: 8682 Comm: panic Not tainted 4.17.0-rc6+ #13
> > [  142.159659] Hardware name: Inspur SA5212M4/YZMB-00370-107, BIOS 4.1.10 11/14/2016
> > [  142.160342] Call Trace:
> > [  142.161037]  dump_stack+0x78/0xb3
> > [  142.161734]  dump_header+0x7d/0x334
> > [  142.162433]  oom_kill_process+0x228/0x490
> > [  142.163126]  ? oom_badness+0x2a/0x130
> > [  142.163821]  out_of_memory+0xf0/0x280
> > [  142.164532]  __alloc_pages_slowpath+0x711/0xa07
> > [  142.165241]  __alloc_pages_nodemask+0x23f/0x260
> > [  142.165947]  alloc_pages_vma+0x73/0x180
> > [  142.166665]  do_anonymous_page+0xed/0x4e0
> > [  142.167388]  __handle_mm_fault+0xbd2/0xe00
> > [  142.168114]  handle_mm_fault+0x116/0x250
> > [  142.168841]  __do_page_fault+0x233/0x4d0
> > [  142.169567]  do_page_fault+0x32/0x130
> > [  142.170303]  ? page_fault+0x8/0x30
> > [  142.171036]  page_fault+0x1e/0x30
> > [  142.171764] RIP: 0033:0x7f403000a860
> > [  142.172517] RSP: 002b:00007ffc9f745c28 EFLAGS: 00010206
> > [  142.173268] RAX: 00007f3f6fd7d000 RBX: 0000000000000000 RCX: 00007f3f7f5cd000
> > [  142.174040] RDX: 00007f3fafd7d000 RSI: 0000000000000000 RDI: 00007f3f6fd7d000
> > [  142.174806] RBP: 00007ffc9f745c50 R08: ffffffffffffffff R09: 0000000000000000
> > [  142.175623] R10: 0000000000000022 R11: 0000000000000246 R12: 0000000000400490
> > [  142.176542] R13: 00007ffc9f745d30 R14: 0000000000000000 R15: 0000000000000000
> > [  142.177709] oom-kill: constrain=CONSTRAINT_NONE nodemask=(null) origin_memcg= kill_memcg=/test/test1/test2 task=panic pid= 8622 uid=    0
> 
> Is it really helpful to dump the nodemask here again? We already have it
> as a part of the "%s invoked oom-killer:" message.
> 

At the risk of making the patch more complex, it would be possible to 
suppress nodemask=<mask> for constraints that are not 
CONSTRAINT_MEMORY_POLICY, but the goal was to provide a single line output 
that userspace can parse for all information and not rely on surrounding 
lines to match oom kills with invocations (the invocation itself may have 
been lost from the ring buffer), and we want this to not be subjected to 
any ratelimit.

We need to eliminate the spurious spaces in the output, though, and fix 
the spelling of "constrain".  There should be no spaces between pid and 
uid values.
