Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 0B7B76B0099
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 17:32:49 -0400 (EDT)
Subject: =?utf-8?q?Re=3A_=5Bpatch_0=2F7=5D_improve_memcg_oom_killer_robustness_v2?=
Date: Tue, 10 Sep 2013 23:32:47 +0200
From: "azurIt" <azurit@pobox.sk>
References: <20130905115430.GB856@cmpxchg.org>, <20130909151010.3A3CBC6A@pobox.sk>, <20130909172849.GG856@cmpxchg.org>, <20130909215917.96932098@pobox.sk>, <20130909201238.GH856@cmpxchg.org>, <20130910201359.D0984EFF@pobox.sk>, <20130910183740.GI856@cmpxchg.org>, <20130910213253.A1E666C5@pobox.sk>, <20130910201222.GA25972@cmpxchg.org>, <20130910230853.FEEC19B5@pobox.sk> <20130910211823.GJ856@cmpxchg.org>
In-Reply-To: <20130910211823.GJ856@cmpxchg.org>
MIME-Version: 1.0
Message-Id: <20130910233247.9EDF4DBA@pobox.sk>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?q?Johannes_Weiner?= <hannes@cmpxchg.org>
Cc: =?utf-8?q?Andrew_Morton?= <akpm@linux-foundation.org>, =?utf-8?q?Michal_Hocko?= <mhocko@suse.cz>, =?utf-8?q?David_Rientjes?= <rientjes@google.com>, =?utf-8?q?KAMEZAWA_Hiroyuki?= <kamezawa.hiroyu@jp.fujitsu.com>, =?utf-8?q?KOSAKI_Motohiro?= <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

>On Tue, Sep 10, 2013 at 11:08:53PM +0200, azurIt wrote:
>> >On Tue, Sep 10, 2013 at 09:32:53PM +0200, azurIt wrote:
>> >> >On Tue, Sep 10, 2013 at 08:13:59PM +0200, azurIt wrote:
>> >> >> >On Mon, Sep 09, 2013 at 09:59:17PM +0200, azurIt wrote:
>> >> >> >> >On Mon, Sep 09, 2013 at 03:10:10PM +0200, azurIt wrote:
>> >> >> >> >> >Hi azur,
>> >> >> >> >> >
>> >> >> >> >> >On Wed, Sep 04, 2013 at 10:18:52AM +0200, azurIt wrote:
>> >> >> >> >> >> > CC: "Andrew Morton" <akpm@linux-foundation.org>, "Michal Hocko" <mhocko@suse.cz>, "David Rientjes" <rientjes@google.com>, "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>, "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org
>> >> >> >> >> >> >Hello azur,
>> >> >> >> >> >> >
>> >> >> >> >> >> >On Mon, Sep 02, 2013 at 12:38:02PM +0200, azurIt wrote:
>> >> >> >> >> >> >> >>Hi azur,
>> >> >> >> >> >> >> >>
>> >> >> >> >> >> >> >>here is the x86-only rollup of the series for 3.2.
>> >> >> >> >> >> >> >>
>> >> >> >> >> >> >> >>Thanks!
>> >> >> >> >> >> >> >>Johannes
>> >> >> >> >> >> >> >>---
>> >> >> >> >> >> >> >
>> >> >> >> >> >> >> >
>> >> >> >> >> >> >> >Johannes,
>> >> >> >> >> >> >> >
>> >> >> >> >> >> >> >unfortunately, one problem arises: I have (again) cgroup which cannot be deleted :( it's a user who had very high memory usage and was reaching his limit very often. Do you need any info which i can gather now?
>> >> >> >> >> >> >
>> >> >> >> >> >> >Did the OOM killer go off in this group?
>> >> >> >> >> >> >
>> >> >> >> >> >> >Was there a warning in the syslog ("Fixing unhandled memcg OOM
>> >> >> >> >> >> >context")?
>> >> >> >> >> >> 
>> >> >> >> >> >> 
>> >> >> >> >> >> 
>> >> >> >> >> >> Ok, i see this message several times in my syslog logs, one of them is also for this unremovable cgroup (but maybe all of them cannot be removed, should i try?). Example of the log is here (don't know where exactly it starts and ends so here is the full kernel log):
>> >> >> >> >> >> http://watchdog.sk/lkml/oom_syslog.gz
>> >> >> >> >> >There is an unfinished OOM invocation here:
>> >> >> >> >> >
>> >> >> >> >> >  Aug 22 13:15:21 server01 kernel: [1251422.715112] Fixing unhandled memcg OOM context set up from:
>> >> >> >> >> >  Aug 22 13:15:21 server01 kernel: [1251422.715191]  [<ffffffff811105c2>] T.1154+0x622/0x8f0
>> >> >> >> >> >  Aug 22 13:15:21 server01 kernel: [1251422.715274]  [<ffffffff8111153e>] mem_cgroup_cache_charge+0xbe/0xe0
>> >> >> >> >> >  Aug 22 13:15:21 server01 kernel: [1251422.715357]  [<ffffffff810cf31c>] add_to_page_cache_locked+0x4c/0x140
>> >> >> >> >> >  Aug 22 13:15:21 server01 kernel: [1251422.715443]  [<ffffffff810cf432>] add_to_page_cache_lru+0x22/0x50
>> >> >> >> >> >  Aug 22 13:15:21 server01 kernel: [1251422.715526]  [<ffffffff810cfdd3>] find_or_create_page+0x73/0xb0
>> >> >> >> >> >  Aug 22 13:15:21 server01 kernel: [1251422.715608]  [<ffffffff811493ba>] __getblk+0xea/0x2c0
>> >> >> >> >> >  Aug 22 13:15:21 server01 kernel: [1251422.715692]  [<ffffffff8114ca73>] __bread+0x13/0xc0
>> >> >> >> >> >  Aug 22 13:15:21 server01 kernel: [1251422.715774]  [<ffffffff81196968>] ext3_get_branch+0x98/0x140
>> >> >> >> >> >  Aug 22 13:15:21 server01 kernel: [1251422.715859]  [<ffffffff81197557>] ext3_get_blocks_handle+0xd7/0xdc0
>> >> >> >> >> >  Aug 22 13:15:21 server01 kernel: [1251422.715942]  [<ffffffff81198304>] ext3_get_block+0xc4/0x120
>> >> >> >> >> >  Aug 22 13:15:21 server01 kernel: [1251422.716023]  [<ffffffff81155c3a>] do_mpage_readpage+0x38a/0x690
>> >> >> >> >> >  Aug 22 13:15:21 server01 kernel: [1251422.716107]  [<ffffffff81155f8f>] mpage_readpage+0x4f/0x70
>> >> >> >> >> >  Aug 22 13:15:21 server01 kernel: [1251422.716188]  [<ffffffff811973a8>] ext3_readpage+0x28/0x60
>> >> >> >> >> >  Aug 22 13:15:21 server01 kernel: [1251422.716268]  [<ffffffff810cfa48>] filemap_fault+0x308/0x560
>> >> >> >> >> >  Aug 22 13:15:21 server01 kernel: [1251422.716350]  [<ffffffff810ef898>] __do_fault+0x78/0x5a0
>> >> >> >> >> >  Aug 22 13:15:21 server01 kernel: [1251422.716433]  [<ffffffff810f2ab4>] handle_pte_fault+0x84/0x940
>> >> >> >> >> >
>> >> >> >> >> >__getblk() has this weird loop where it tries to instantiate the page,
>> >> >> >> >> >frees memory on failure, then retries.  If the memcg goes OOM, the OOM
>> >> >> >> >> >path might be entered multiple times and each time leak the memcg
>> >> >> >> >> >reference of the respective previous OOM invocation.
>> >> >> >> >> >
>> >> >> >> >> >There are a few more find_or_create() sites that do not propagate an
>> >> >> >> >> >error and it's incredibly hard to find out whether they are even taken
>> >> >> >> >> >during a page fault.  It's not practical to annotate them all with
>> >> >> >> >> >memcg OOM toggles, so let's just catch all OOM contexts at the end of
>> >> >> >> >> >handle_mm_fault() and clear them if !VM_FAULT_OOM instead of treating
>> >> >> >> >> >this like an error.
>> >> >> >> >> >
>> >> >> >> >> >azur, here is a patch on top of your modified 3.2.  Note that Michal
>> >> >> >> >> >might be onto something and we are looking at multiple issues here,
>> >> >> >> >> >but the log excert above suggests this fix is required either way.
>> >> >> >> >> 
>> >> >> >> >> 
>> >> >> >> >> 
>> >> >> >> >> 
>> >> >> >> >> Johannes, is this still up to date? Thank you.
>> >> >> >> >
>> >> >> >> >No, please use the following on top of 3.2 (i.e. full replacement, not
>> >> >> >> >incremental to what you have):
>> >> >> >> 
>> >> >> >> 
>> >> >> >> 
>> >> >> >> Unfortunately it didn't compile:
>> >> >> >> 
>> >> >> >> 
>> >> >> >> 
>> >> >> >> 
>> >> >> >>   LD      vmlinux.o
>> >> >> >>   MODPOST vmlinux.o
>> >> >> >> WARNING: modpost: Found 4924 section mismatch(es).
>> >> >> >> To see full details build your kernel with:
>> >> >> >> 'make CONFIG_DEBUG_SECTION_MISMATCH=y'
>> >> >> >>   GEN     .version
>> >> >> >>   CHK     include/generated/compile.h
>> >> >> >>   UPD     include/generated/compile.h
>> >> >> >>   CC      init/version.o
>> >> >> >>   LD      init/built-in.o
>> >> >> >>   LD      .tmp_vmlinux1
>> >> >> >> arch/x86/built-in.o: In function `do_page_fault':
>> >> >> >> (.text+0x26a77): undefined reference to `handle_mm_fault'
>> >> >> >> mm/built-in.o: In function `fixup_user_fault':
>> >> >> >> (.text+0x224d3): undefined reference to `handle_mm_fault'
>> >> >> >> mm/built-in.o: In function `__get_user_pages':
>> >> >> >> (.text+0x24a0f): undefined reference to `handle_mm_fault'
>> >> >> >> make: *** [.tmp_vmlinux1] Error 1
>> >> >> >
>> >> >> >Oops, sorry about that.  Must be configuration dependent because it
>> >> >> >works for me (and handle_mm_fault is obviously defined).
>> >> >> >
>> >> >> >Do you have warnings earlier in the compilation?  You can use make -s
>> >> >> >to filter out everything but warnings.
>> >> >> >
>> >> >> >Or send me your configuration so I can try to reproduce it here.
>> >> >> >
>> >> >> >Thanks!
>> >> >> 
>> >> >> 
>> >> >> Johannes,
>> >> >> 
>> >> >> the server went down early in the morning, the symptoms were similar as before - huge I/O. Can't tell what exactly happened since I wasn't able to login even on the console. But I have some info:
>> >> >>  - applications were able to write to HDD so it wasn't deadlocked as before
>> >> >>  - here is how it looked on graphs: http://watchdog.sk/lkml/graphs.jpg
>> >> >>  - server wasn't responding from 6:36, it was down between 6:54 and 7:02 (i had to hard reboot it), I was awoken at 6:36 by really creepy sound from my phone ;)
>> >> >>  - my 'load check' script successfully killed apache at 6:41 but it didn't help as you can see
>> >> >>  - i have one screen with info from atop from time 6:44, looks like i/o was done by init (??!): http://watchdog.sk/lkml/atop.jpg (ignore swap warning, i have no swap)
>> >> >>  - also other type of logs are available
>> >> >>  - nothing like this happened before
>> >> >
>> >> >That IO from init looks really screwy, I have no idea what's going on
>> >> >on that machine, but it looks like there is more than just a memcg
>> >> >problem...  Any chance your thirdparty security patches are concealing
>> >> >kernel daemon activity behind the init process and the IO is actually
>> >> >coming from a kernel thread like the flushers or kswapd?
>> >> 
>> >> 
>> >> 
>> >> 
>> >> I really cannot tell but I never ever saw this before and i'm using all of my patches for several years. Here are all patches which i'm using right now (+ your patch):
>> >> http://watchdog.sk/lkml/patches3
>> >> 
>> >> 
>> >> 
>> >> 
>> >> >Are there OOM kill messages in the syslog?
>> >> 
>> >> 
>> >> 
>> >> Here is full kernel log between 6:00 and 7:59:
>> >> http://watchdog.sk/lkml/kern6.log
>> >
>> >Wow, your apaches are like the hydra.  Whenever one is OOM killed,
>> >more show up!
>> 
>> 
>> 
>> Yeah, it's supposed to do this ;)
>> 
>> 
>> 
>> >> >> What do you think? I'm now running kernel with your previous patch, not with the newest one.
>> >> >
>> >> >Which one exactly?  Can you attach the diff?
>> >> 
>> >> 
>> >> 
>> >> I meant, the problem above occured on kernel with your latest patch:
>> >> http://watchdog.sk/lkml/7-2-memcg-fix.patch
>> >
>> >The above log has the following callstack:
>> >
>> >Sep 10 07:59:43 server01 kernel: [ 3846.337628]  [<ffffffff810d19fe>] dump_header+0x7e/0x1e0
>> >Sep 10 07:59:43 server01 kernel: [ 3846.337707]  [<ffffffff810d18ff>] ? find_lock_task_mm+0x2f/0x70
>> >Sep 10 07:59:43 server01 kernel: [ 3846.337790]  [<ffffffff810d18ff>] ? find_lock_task_mm+0x2f/0x70
>> >Sep 10 07:59:43 server01 kernel: [ 3846.337874]  [<ffffffff81094bb0>] ? __css_put+0x50/0x90
>> >Sep 10 07:59:43 server01 kernel: [ 3846.337952]  [<ffffffff810d1ec5>] oom_kill_process+0x85/0x2a0
>> >Sep 10 07:59:43 server01 kernel: [ 3846.338037]  [<ffffffff810d2448>] mem_cgroup_out_of_memory+0xa8/0xf0
>> >Sep 10 07:59:43 server01 kernel: [ 3846.338120]  [<ffffffff81110858>] T.1154+0x8b8/0x8f0
>> >Sep 10 07:59:43 server01 kernel: [ 3846.338201]  [<ffffffff81110fa6>] mem_cgroup_charge_common+0x56/0xa0
>> >Sep 10 07:59:43 server01 kernel: [ 3846.338283]  [<ffffffff81111035>] mem_cgroup_newpage_charge+0x45/0x50
>> >Sep 10 07:59:43 server01 kernel: [ 3846.338364]  [<ffffffff810f3039>] handle_pte_fault+0x609/0x940
>> >Sep 10 07:59:43 server01 kernel: [ 3846.338451]  [<ffffffff8102ab1f>] ? pte_alloc_one+0x3f/0x50
>> >Sep 10 07:59:43 server01 kernel: [ 3846.338532]  [<ffffffff8107e455>] ? sched_clock_local+0x25/0x90
>> >Sep 10 07:59:43 server01 kernel: [ 3846.338617]  [<ffffffff810f34d7>] handle_mm_fault+0x167/0x340
>> >Sep 10 07:59:43 server01 kernel: [ 3846.338699]  [<ffffffff8102714b>] do_page_fault+0x13b/0x490
>> >Sep 10 07:59:43 server01 kernel: [ 3846.338781]  [<ffffffff810f8848>] ? do_brk+0x208/0x3a0
>> >Sep 10 07:59:43 server01 kernel: [ 3846.338865]  [<ffffffff812dba22>] ? gr_learn_resource+0x42/0x1e0
>> >Sep 10 07:59:43 server01 kernel: [ 3846.338951]  [<ffffffff815cb7bf>] page_fault+0x1f/0x30
>> >
>> >The charge code seems to be directly invoking the OOM killer, which is
>> >not possible with 7-2-memcg-fix.  Are you sure this is the right patch
>> >for this log?  This _looks_ more like what 7-1-memcg-fix was doing,
>> >with a direct kill in the charge context and a fixup later on.
>> 
>> 
>> 
>> 
>> I, luckyly, still have the kernel source from which that kernel was build. I tried to re-apply the 7-2-memcg-fix.patch:
>> 
>> # patch -p1 --dry-run < 7-2-memcg-fix.patch 
>> patching file arch/x86/mm/fault.c
>> Reversed (or previously applied) patch detected!  Assume -R? [n] 
>> Apply anyway? [n] 
>> Skipping patch.
>> 4 out of 4 hunks ignored -- saving rejects to file arch/x86/mm/fault.c.rej
>> patching file include/linux/memcontrol.h
>> Hunk #1 succeeded at 141 with fuzz 2 (offset 21 lines).
>> Hunk #2 succeeded at 391 with fuzz 1 (offset 39 lines).
>
>Uhm, some of it applied...  I have absolutely no idea what state that
>tree is in now...




I used '--dry-run' so it should be ok :)




>> patching file include/linux/mm.h
>> Reversed (or previously applied) patch detected!  Assume -R? [n] 
>> Apply anyway? [n] 
>> Skipping patch.
>> 1 out of 1 hunk ignored -- saving rejects to file include/linux/mm.h.rej
>> patching file include/linux/sched.h
>> Reversed (or previously applied) patch detected!  Assume -R? [n] 
>> Apply anyway? [n] 
>> Skipping patch.
>> 1 out of 1 hunk ignored -- saving rejects to file include/linux/sched.h.rej
>> patching file mm/memcontrol.c
>> Reversed (or previously applied) patch detected!  Assume -R? [n] 
>> Apply anyway? [n] 
>> Skipping patch.
>> 10 out of 10 hunks ignored -- saving rejects to file mm/memcontrol.c.rej
>> patching file mm/memory.c
>> Reversed (or previously applied) patch detected!  Assume -R? [n] 
>> Apply anyway? [n] 
>> Skipping patch.
>> 2 out of 2 hunks ignored -- saving rejects to file mm/memory.c.rej
>> patching file mm/oom_kill.c
>> Reversed (or previously applied) patch detected!  Assume -R? [n] 
>> Apply anyway? [n] 
>> Skipping patch.
>> 1 out of 1 hunk ignored -- saving rejects to file mm/oom_kill.c.rej
>> 
>> 
>> Can you tell from this if the source has the right patch?
>
>Not reliably, I don't think.  Can you send me
>
>  include/linux/memcontrol.h
>  mm/memcontrol.c
>  mm/memory.c
>  mm/oom_kill.c
>
>from those sources?
>
>It might be easier to start the application from scratch...  Keep in
>mind that 7-2 was not an incremental fix, you need to remove the
>previous memcg patches (as opposed to 7-1).



Yes, i used only 7-2 from your patches. Here are the files:
http://watchdog.sk/lkml/kernel

orig - kernel source which was used to build the kernel i was talking about earlier
new - newly unpacked and patched 3.2.50 with all of 'my' patches


Here is how your patch was applied:

# patch -p1 < 7-2-memcg-fix.patch 
patching file arch/x86/mm/fault.c
Hunk #1 succeeded at 944 (offset 102 lines).
Hunk #2 succeeded at 970 (offset 102 lines).
Hunk #3 succeeded at 1273 with fuzz 1 (offset 212 lines).
Hunk #4 succeeded at 1382 (offset 223 lines).
patching file include/linux/memcontrol.h
Hunk #1 succeeded at 122 with fuzz 2 (offset 2 lines).
Hunk #2 succeeded at 354 (offset 2 lines).
patching file include/linux/mm.h
Hunk #1 succeeded at 163 (offset 7 lines).
patching file include/linux/sched.h
Hunk #1 succeeded at 1644 (offset 76 lines).
patching file mm/memcontrol.c
Hunk #1 succeeded at 1752 (offset 9 lines).
Hunk #2 succeeded at 1777 (offset 9 lines).
Hunk #3 succeeded at 1828 (offset 9 lines).
Hunk #4 succeeded at 1867 (offset 9 lines).
Hunk #5 succeeded at 2256 (offset 9 lines).
Hunk #6 succeeded at 2317 (offset 9 lines).
Hunk #7 succeeded at 2348 (offset 9 lines).
Hunk #8 succeeded at 2411 (offset 9 lines).
Hunk #9 succeeded at 2419 (offset 9 lines).
Hunk #10 succeeded at 2432 (offset 9 lines).
patching file mm/memory.c
Hunk #1 succeeded at 3712 (offset 273 lines).
Hunk #2 succeeded at 3812 (offset 317 lines).
patching file mm/oom_kill.c



>> >It's somewhat eerie that you have to manually apply these patches
>> >because of grsec because I have no idea of knowing what the end result
>> >is, especially since you had compile errors in this area before.  Is
>> >grsec making changes to memcg code or why are these patches not
>> >applying cleanly?
>> 
>> 
>> 
>> 
>> The problem was in mm/memory.c (first hunk) because grsec added this:
>> 
>>         pgd_t *pgd;
>>         pud_t *pud;
>>         pmd_t *pmd;
>>         pte_t *pte;
>> 
>> +#ifdef CONFIG_PAX_SEGMEXEC
>> +        struct vm_area_struct *vma_m;
>> +#endif  
>> 
>>         if (unlikely(is_vm_hugetlb_page(vma)))
>> 
>> 
>> 
>> I'm not using PAX anyway so it shouldn't be used. This was the only rejection but there were lots of fuzz too - I wasn't considering it as a problem, should I?
>
>It COULD be...  Can you send me the files listed above after
>application?
>
>> >> but after i had to reboot the server i booted the kernel with your previous patch:
>> >> http://watchdog.sk/lkml/7-1-memcg-fix.patch
>> >
>> >This one still has the known memcg leak.
>> 
>> 
>> 
>> I know but it's the best I have which don't take down the server (yet).
>
>Ok.  I wouldn't expect it to crash under regular load but it will
>probably create hangs again when you try to remove memcgs.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
