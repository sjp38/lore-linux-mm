Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id C846F6B009D
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 18:03:38 -0400 (EDT)
Date: Tue, 10 Sep 2013 18:03:29 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 0/7] improve memcg oom killer robustness v2
Message-ID: <20130910220329.GK856@cmpxchg.org>
References: <20130909172849.GG856@cmpxchg.org>
 <20130909215917.96932098@pobox.sk>
 <20130909201238.GH856@cmpxchg.org>
 <20130910201359.D0984EFF@pobox.sk>
 <20130910183740.GI856@cmpxchg.org>
 <20130910213253.A1E666C5@pobox.sk>
 <20130910201222.GA25972@cmpxchg.org>
 <20130910230853.FEEC19B5@pobox.sk>
 <20130910211823.GJ856@cmpxchg.org>
 <20130910233247.9EDF4DBA@pobox.sk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130910233247.9EDF4DBA@pobox.sk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Sep 10, 2013 at 11:32:47PM +0200, azurIt wrote:
> >On Tue, Sep 10, 2013 at 11:08:53PM +0200, azurIt wrote:
> >> >On Tue, Sep 10, 2013 at 09:32:53PM +0200, azurIt wrote:
> >> >> Here is full kernel log between 6:00 and 7:59:
> >> >> http://watchdog.sk/lkml/kern6.log
> >> >
> >> >Wow, your apaches are like the hydra.  Whenever one is OOM killed,
> >> >more show up!
> >> 
> >> 
> >> 
> >> Yeah, it's supposed to do this ;)

How are you expecting the machine to recover from an OOM situation,
though?  I guess I don't really understand what these machines are
doing.  But if you are overloading them like crazy, isn't that the
expected outcome?

> >> >> >> What do you think? I'm now running kernel with your previous patch, not with the newest one.
> >> >> >
> >> >> >Which one exactly?  Can you attach the diff?
> >> >> 
> >> >> 
> >> >> 
> >> >> I meant, the problem above occured on kernel with your latest patch:
> >> >> http://watchdog.sk/lkml/7-2-memcg-fix.patch
> >> >
> >> >The above log has the following callstack:
> >> >
> >> >Sep 10 07:59:43 server01 kernel: [ 3846.337628]  [<ffffffff810d19fe>] dump_header+0x7e/0x1e0
> >> >Sep 10 07:59:43 server01 kernel: [ 3846.337707]  [<ffffffff810d18ff>] ? find_lock_task_mm+0x2f/0x70
> >> >Sep 10 07:59:43 server01 kernel: [ 3846.337790]  [<ffffffff810d18ff>] ? find_lock_task_mm+0x2f/0x70
> >> >Sep 10 07:59:43 server01 kernel: [ 3846.337874]  [<ffffffff81094bb0>] ? __css_put+0x50/0x90
> >> >Sep 10 07:59:43 server01 kernel: [ 3846.337952]  [<ffffffff810d1ec5>] oom_kill_process+0x85/0x2a0
> >> >Sep 10 07:59:43 server01 kernel: [ 3846.338037]  [<ffffffff810d2448>] mem_cgroup_out_of_memory+0xa8/0xf0
> >> >Sep 10 07:59:43 server01 kernel: [ 3846.338120]  [<ffffffff81110858>] T.1154+0x8b8/0x8f0
> >> >Sep 10 07:59:43 server01 kernel: [ 3846.338201]  [<ffffffff81110fa6>] mem_cgroup_charge_common+0x56/0xa0
> >> >Sep 10 07:59:43 server01 kernel: [ 3846.338283]  [<ffffffff81111035>] mem_cgroup_newpage_charge+0x45/0x50
> >> >Sep 10 07:59:43 server01 kernel: [ 3846.338364]  [<ffffffff810f3039>] handle_pte_fault+0x609/0x940
> >> >Sep 10 07:59:43 server01 kernel: [ 3846.338451]  [<ffffffff8102ab1f>] ? pte_alloc_one+0x3f/0x50
> >> >Sep 10 07:59:43 server01 kernel: [ 3846.338532]  [<ffffffff8107e455>] ? sched_clock_local+0x25/0x90
> >> >Sep 10 07:59:43 server01 kernel: [ 3846.338617]  [<ffffffff810f34d7>] handle_mm_fault+0x167/0x340
> >> >Sep 10 07:59:43 server01 kernel: [ 3846.338699]  [<ffffffff8102714b>] do_page_fault+0x13b/0x490
> >> >Sep 10 07:59:43 server01 kernel: [ 3846.338781]  [<ffffffff810f8848>] ? do_brk+0x208/0x3a0
> >> >Sep 10 07:59:43 server01 kernel: [ 3846.338865]  [<ffffffff812dba22>] ? gr_learn_resource+0x42/0x1e0
> >> >Sep 10 07:59:43 server01 kernel: [ 3846.338951]  [<ffffffff815cb7bf>] page_fault+0x1f/0x30
> >> >
> >> >The charge code seems to be directly invoking the OOM killer, which is
> >> >not possible with 7-2-memcg-fix.  Are you sure this is the right patch
> >> >for this log?  This _looks_ more like what 7-1-memcg-fix was doing,
> >> >with a direct kill in the charge context and a fixup later on.
> >> 
> >> I, luckyly, still have the kernel source from which that kernel was build. I tried to re-apply the 7-2-memcg-fix.patch:
> >> 
> >> # patch -p1 --dry-run < 7-2-memcg-fix.patch 
> >> patching file arch/x86/mm/fault.c
> >> Reversed (or previously applied) patch detected!  Assume -R? [n] 
> >> Apply anyway? [n] 
> >> Skipping patch.
> >> 4 out of 4 hunks ignored -- saving rejects to file arch/x86/mm/fault.c.rej
> >> patching file include/linux/memcontrol.h
> >> Hunk #1 succeeded at 141 with fuzz 2 (offset 21 lines).
> >> Hunk #2 succeeded at 391 with fuzz 1 (offset 39 lines).
> >
> >Uhm, some of it applied...  I have absolutely no idea what state that
> >tree is in now...
> 
> I used '--dry-run' so it should be ok :)

Ah, right.

> >> patching file include/linux/mm.h
> >> Reversed (or previously applied) patch detected!  Assume -R? [n] 
> >> Apply anyway? [n] 
> >> Skipping patch.
> >> 1 out of 1 hunk ignored -- saving rejects to file include/linux/mm.h.rej
> >> patching file include/linux/sched.h
> >> Reversed (or previously applied) patch detected!  Assume -R? [n] 
> >> Apply anyway? [n] 
> >> Skipping patch.
> >> 1 out of 1 hunk ignored -- saving rejects to file include/linux/sched.h.rej
> >> patching file mm/memcontrol.c
> >> Reversed (or previously applied) patch detected!  Assume -R? [n] 
> >> Apply anyway? [n] 
> >> Skipping patch.
> >> 10 out of 10 hunks ignored -- saving rejects to file mm/memcontrol.c.rej
> >> patching file mm/memory.c
> >> Reversed (or previously applied) patch detected!  Assume -R? [n] 
> >> Apply anyway? [n] 
> >> Skipping patch.
> >> 2 out of 2 hunks ignored -- saving rejects to file mm/memory.c.rej
> >> patching file mm/oom_kill.c
> >> Reversed (or previously applied) patch detected!  Assume -R? [n] 
> >> Apply anyway? [n] 
> >> Skipping patch.
> >> 1 out of 1 hunk ignored -- saving rejects to file mm/oom_kill.c.rej
> >> 
> >> 
> >> Can you tell from this if the source has the right patch?
> >
> >Not reliably, I don't think.  Can you send me
> >
> >  include/linux/memcontrol.h
> >  mm/memcontrol.c
> >  mm/memory.c
> >  mm/oom_kill.c
> >
> >from those sources?
> >
> >It might be easier to start the application from scratch...  Keep in
> >mind that 7-2 was not an incremental fix, you need to remove the
> >previous memcg patches (as opposed to 7-1).
> 
> 
> 
> Yes, i used only 7-2 from your patches. Here are the files:
> http://watchdog.sk/lkml/kernel
> 
> orig - kernel source which was used to build the kernel i was talking about earlier
> new - newly unpacked and patched 3.2.50 with all of 'my' patches

Ok, thanks!

> Here is how your patch was applied:
> 
> # patch -p1 < 7-2-memcg-fix.patch 
> patching file arch/x86/mm/fault.c
> Hunk #1 succeeded at 944 (offset 102 lines).
> Hunk #2 succeeded at 970 (offset 102 lines).
> Hunk #3 succeeded at 1273 with fuzz 1 (offset 212 lines).
> Hunk #4 succeeded at 1382 (offset 223 lines).

Ah, I forgot about this one.  Could you provide that file (fault.c) as
well please?

> patching file include/linux/memcontrol.h
> Hunk #1 succeeded at 122 with fuzz 2 (offset 2 lines).
> Hunk #2 succeeded at 354 (offset 2 lines).

Looks good, still.

> patching file include/linux/mm.h
> Hunk #1 succeeded at 163 (offset 7 lines).
> patching file include/linux/sched.h
> Hunk #1 succeeded at 1644 (offset 76 lines).
> patching file mm/memcontrol.c
> Hunk #1 succeeded at 1752 (offset 9 lines).
> Hunk #2 succeeded at 1777 (offset 9 lines).
> Hunk #3 succeeded at 1828 (offset 9 lines).
> Hunk #4 succeeded at 1867 (offset 9 lines).
> Hunk #5 succeeded at 2256 (offset 9 lines).
> Hunk #6 succeeded at 2317 (offset 9 lines).
> Hunk #7 succeeded at 2348 (offset 9 lines).
> Hunk #8 succeeded at 2411 (offset 9 lines).
> Hunk #9 succeeded at 2419 (offset 9 lines).
> Hunk #10 succeeded at 2432 (offset 9 lines).
> patching file mm/memory.c
> Hunk #1 succeeded at 3712 (offset 273 lines).
> Hunk #2 succeeded at 3812 (offset 317 lines).
> patching file mm/oom_kill.c

These look good as well.

That leaves the weird impossible stack trace.  Did you double check
that this crash came from a kernel with those exact files?

I'm also confused about the freezer.  You used to freeze cgroups that
were out of memory in the past, right?  Are you no longer doing this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
