Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 14E28280011
	for <linux-mm@kvack.org>; Fri, 31 Oct 2014 14:17:46 -0400 (EDT)
Received: by mail-wi0-f176.google.com with SMTP id h11so2031228wiw.9
        for <linux-mm@kvack.org>; Fri, 31 Oct 2014 11:17:46 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id o5si27520774wia.62.2014.10.31.11.17.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Oct 2014 11:17:44 -0700 (PDT)
Date: Fri, 31 Oct 2014 14:17:26 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: initialize variable for mem_cgroup_end_page_stat
Message-ID: <20141031181726.GA8821@phnom.home.cmpxchg.org>
References: <1414633464-19419-1-git-send-email-sasha.levin@oracle.com>
 <20141030082712.GB4664@dhcp22.suse.cz>
 <54523DDE.9000904@oracle.com>
 <20141030141401.GA24520@phnom.home.cmpxchg.org>
 <54524A2F.5050907@oracle.com>
 <20141030153159.GA3639@dhcp22.suse.cz>
 <20141030172632.GA25217@phnom.home.cmpxchg.org>
 <20141030174241.GD3639@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141030174241.GD3639@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Sasha Levin <sasha.levin@oracle.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, riel@redhat.com, peterz@infradead.org, linux-mm@kvack.org

On Thu, Oct 30, 2014 at 06:42:41PM +0100, Michal Hocko wrote:
> On Thu 30-10-14 13:26:32, Johannes Weiner wrote:
> > On Thu, Oct 30, 2014 at 04:31:59PM +0100, Michal Hocko wrote:
> > > I have discussed that with our gcc guys and you are right. Strictly
> > > speaking the compiler is free to do
> > > if (!memcg) abort();
> > > mem_cgroup_end_page_stat(...);
> > > 
> > > but it is highly unlikely that this will ever happen. Anyway better be
> > > safe than sorry. I guess the following should be sufficient and even
> > > more symmetric:
> > 
> > The functional aspect of this is a terrible motivation for this
> > change.  Sure the compiler could, but it doesn't, and it won't.
> > 
> > But there is some merit in keeping the checker's output meaningful as
> > long as it doesn't obfuscate the interface too much.

[...]

> > So let's change it to pointers, but at the same time be clear that
> > this doesn't make the code better.  It just fixes the checker.
> 
> No it is not about the checker which is correct here actually. A simple
> load to setup parameter from an uninitialized variable is an undefined
> behavior (that load happens unconditionally). This has nothing to do
> with the way how we use locked and flags inside the function.

Never mind... :)  The diff looks fine.

> From b2762f30d3896172c5666066e72938b3f5f9158a Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Thu, 30 Oct 2014 18:35:19 +0100
> Subject: [PATCH] mm, memcg: fix potential undefined when for page stat
>  accounting
> 
> since d7365e783edb (mm: memcontrol: fix missed end-writeback page
> accounting) mem_cgroup_end_page_stat consumes locked and flags variables
> directly rather than via pointers which might trigger C undefined
> behavior as those variables are initialized only in the slow path of
> mem_cgroup_begin_page_stat.
> Although mem_cgroup_end_page_stat handles parameters correctly and
> touches them only when they hold a sensible value it is caller which
> loads a potentially uninitialized value which then might allow compiler
> to do crazy things.
> 
> I haven't seen any warning from gcc and it seems that the current
> version (4.9) doesn't exploit this type undefined behavior but Sasha has
> reported the following:
> [   26.868116] ================================================================================
> [   26.870376] UBSan: Undefined behaviour in mm/rmap.c:1084:2
> [   26.871792] load of value 255 is not a valid value for type '_Bool'
> [   26.873256] CPU: 4 PID: 8304 Comm: rngd Not tainted 3.18.0-rc2-next-20141029-sasha-00039-g77ed13d-dirty #1427
> [   26.875636]  ffff8800cac17ff0 0000000000000000 0000000000000000 ffff880069ffbb28
> [   26.877611]  ffffffffaf010c16 0000000000000037 ffffffffb1c0d050 ffff880069ffbb38
> [   26.879140]  ffffffffa6e97899 ffff880069ffbbb8 ffffffffa6e97cc7 ffff880069ffbbb8
> [   26.880765] Call Trace:
> [   26.881185] dump_stack (lib/dump_stack.c:52)
> [   26.882755] ubsan_epilogue (lib/ubsan.c:159)
> [   26.883555] __ubsan_handle_load_invalid_value (lib/ubsan.c:482)
> [   26.884492] ? mem_cgroup_begin_page_stat (mm/memcontrol.c:1962)
> [   26.885441] ? unmap_page_range (./arch/x86/include/asm/paravirt.h:694 mm/memory.c:1091 mm/memory.c:1258 mm/memory.c:1279 mm/memory.c:1303)
> [   26.886242] page_remove_rmap (mm/rmap.c:1084 mm/rmap.c:1096)
> [   26.886922] unmap_page_range (./arch/x86/include/asm/atomic.h:27 include/linux/mm.h:463 mm/memory.c:1146 mm/memory.c:1258 mm/memory.c:1279 mm/memory.c:1303)
> [   26.887824] unmap_single_vma (mm/memory.c:1348)
> [   26.888582] unmap_vmas (mm/memory.c:1377 (discriminator 3))
> [   26.889430] exit_mmap (mm/mmap.c:2837)
> [   26.890060] mmput (kernel/fork.c:659)
> [   26.890656] do_exit (./arch/x86/include/asm/thread_info.h:168 kernel/exit.c:462 kernel/exit.c:747)
> [   26.891359] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
> [   26.892287] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2559 kernel/locking/lockdep.c:2601)
> [   26.893107] ? syscall_trace_enter_phase2 (arch/x86/kernel/ptrace.c:1598 (discriminator 2))
> [   26.893974] do_group_exit (include/linux/sched.h:775 kernel/exit.c:873)
> [   26.894695] SyS_exit_group (kernel/exit.c:901)
> [   26.895433] tracesys_phase2 (arch/x86/kernel/entry_64.S:529)
> [   26.896134] ================================================================================
> 
> Fix this by using pointer parameters for both locked and flags and be
> more robust for future compiler changes even though the current code is
> implemented correctly.
> 
> Reported-by: Sasha Levin <sasha.levin@oracle.com>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
