Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 3EA6E6B006C
	for <linux-mm@kvack.org>; Fri, 19 Jul 2013 04:23:41 -0400 (EDT)
Subject: =?utf-8?q?Re=3A_=5BPATCH_for_3=2E2=5D_memcg=3A_do_not_trap_chargers_with_full_callstack_on_OOM?=
Date: Fri, 19 Jul 2013 10:23:39 +0200
From: "azurIt" <azurit@pobox.sk>
References: <20130709135450.GI20281@dhcp22.suse.cz>, <20130710182506.F25DF461@pobox.sk>, <20130711072507.GA21667@dhcp22.suse.cz>, <20130714012641.C2DA4E05@pobox.sk>, <20130714015112.FFCB7AF7@pobox.sk>, <20130715154119.GA32435@dhcp22.suse.cz>, <20130715160006.GB32435@dhcp22.suse.cz>, <20130716153544.GX17812@cmpxchg.org>, <20130716160905.GA20018@dhcp22.suse.cz>, <20130716164830.GZ17812@cmpxchg.org> <20130719042124.GC17812@cmpxchg.org>
In-Reply-To: <20130719042124.GC17812@cmpxchg.org>
MIME-Version: 1.0
Message-Id: <20130719102339.34DF73E5@pobox.sk>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?q?Johannes_Weiner?= <hannes@cmpxchg.org>, =?utf-8?q?Michal_Hocko?= <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, =?utf-8?q?cgroups_mailinglist?= <cgroups@vger.kernel.org>, =?utf-8?q?KAMEZAWA_Hiroyuki?= <kamezawa.hiroyu@jp.fujitsu.com>, righi.andrea@gmail.com

> CC: linux-kernel@vger.kernel.org, linux-mm@kvack.org, "cgroups mailinglist" <cgroups@vger.kernel.org>, "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>, righi.andrea@gmail.com
>On Tue, Jul 16, 2013 at 12:48:30PM -0400, Johannes Weiner wrote:
>> On Tue, Jul 16, 2013 at 06:09:05PM +0200, Michal Hocko wrote:
>> > On Tue 16-07-13 11:35:44, Johannes Weiner wrote:
>> > > On Mon, Jul 15, 2013 at 06:00:06PM +0200, Michal Hocko wrote:
>> > > > On Mon 15-07-13 17:41:19, Michal Hocko wrote:
>> > > > > On Sun 14-07-13 01:51:12, azurIt wrote:
>> > > > > > > CC: "Johannes Weiner" <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "cgroups mailinglist" <cgroups@vger.kernel.org>, "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>, righi.andrea@gmail.com
>> > > > > > >> CC: "Johannes Weiner" <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "cgroups mailinglist" <cgroups@vger.kernel.org>, "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>, righi.andrea@gmail.com
>> > > > > > >>On Wed 10-07-13 18:25:06, azurIt wrote:
>> > > > > > >>> >> Now i realized that i forgot to remove UID from that cgroup before
>> > > > > > >>> >> trying to remove it, so cgroup cannot be removed anyway (we are using
>> > > > > > >>> >> third party cgroup called cgroup-uid from Andrea Righi, which is able
>> > > > > > >>> >> to associate all user's processes with target cgroup). Look here for
>> > > > > > >>> >> cgroup-uid patch:
>> > > > > > >>> >> https://www.develer.com/~arighi/linux/patches/cgroup-uid/cgroup-uid-v8.patch
>> > > > > > >>> >> 
>> > > > > > >>> >> ANYWAY, i'm 101% sure that 'tasks' file was empty and 'under_oom' was
>> > > > > > >>> >> permanently '1'.
>> > > > > > >>> >
>> > > > > > >>> >This is really strange. Could you post the whole diff against stable
>> > > > > > >>> >tree you are using (except for grsecurity stuff and the above cgroup-uid
>> > > > > > >>> >patch)?
>> > > > > > >>> 
>> > > > > > >>> 
>> > > > > > >>> Here are all patches which i applied to kernel 3.2.48 in my last test:
>> > > > > > >>> http://watchdog.sk/lkml/patches3/
>> > > > > > >>
>> > > > > > >>The two patches from Johannes seem correct.
>> > > > > > >>
>> > > > > > >>From a quick look even grsecurity patchset shouldn't interfere as it
>> > > > > > >>doesn't seem to put any code between handle_mm_fault and mm_fault_error
>> > > > > > >>and there also doesn't seem to be any new handle_mm_fault call sites.
>> > > > > > >>
>> > > > > > >>But I cannot tell there aren't other code paths which would lead to a
>> > > > > > >>memcg charge, thus oom, without proper FAULT_FLAG_KERNEL handling.
>> > > > > > >
>> > > > > > >
>> > > > > > >Michal,
>> > > > > > >
>> > > > > > >now i can definitely confirm that problem with unremovable cgroups
>> > > > > > >persists. What info do you need from me? I applied also your little
>> > > > > > >'WARN_ON' patch.
>> > > > > > 
>> > > > > > Ok, i think you want this:
>> > > > > > http://watchdog.sk/lkml/kern4.log
>> > > > > 
>> > > > > Jul 14 01:11:39 server01 kernel: [  593.589087] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
>> > > > > Jul 14 01:11:39 server01 kernel: [  593.589451] [12021]  1333 12021   172027    64723   4       0             0 apache2
>> > > > > Jul 14 01:11:39 server01 kernel: [  593.589647] [12030]  1333 12030   172030    64748   2       0             0 apache2
>> > > > > Jul 14 01:11:39 server01 kernel: [  593.589836] [12031]  1333 12031   172030    64749   3       0             0 apache2
>> > > > > Jul 14 01:11:39 server01 kernel: [  593.590025] [12032]  1333 12032   170619    63428   3       0             0 apache2
>> > > > > Jul 14 01:11:39 server01 kernel: [  593.590213] [12033]  1333 12033   167934    60524   2       0             0 apache2
>> > > > > Jul 14 01:11:39 server01 kernel: [  593.590401] [12034]  1333 12034   170747    63496   4       0             0 apache2
>> > > > > Jul 14 01:11:39 server01 kernel: [  593.590588] [12035]  1333 12035   169659    62451   1       0             0 apache2
>> > > > > Jul 14 01:11:39 server01 kernel: [  593.590776] [12036]  1333 12036   167614    60384   3       0             0 apache2
>> > > > > Jul 14 01:11:39 server01 kernel: [  593.590984] [12037]  1333 12037   166342    58964   3       0             0 apache2
>> > > > > Jul 14 01:11:39 server01 kernel: [  593.591178] Memory cgroup out of memory: Kill process 12021 (apache2) score 847 or sacrifice child
>> > > > > Jul 14 01:11:39 server01 kernel: [  593.591370] Killed process 12021 (apache2) total-vm:688108kB, anon-rss:255472kB, file-rss:3420kB
>> > > > > Jul 14 01:11:41 server01 kernel: [  595.392920] ------------[ cut here ]------------
>> > > > > Jul 14 01:11:41 server01 kernel: [  595.393096] WARNING: at kernel/exit.c:888 do_exit+0x7d0/0x870()
>> > > > > Jul 14 01:11:41 server01 kernel: [  595.393256] Hardware name: S5000VSA
>> > > > > Jul 14 01:11:41 server01 kernel: [  595.393415] Pid: 12037, comm: apache2 Not tainted 3.2.48-grsec #1
>> > > > > Jul 14 01:11:41 server01 kernel: [  595.393577] Call Trace:
>> > > > > Jul 14 01:11:41 server01 kernel: [  595.393737]  [<ffffffff8105520a>] warn_slowpath_common+0x7a/0xb0
>> > > > > Jul 14 01:11:41 server01 kernel: [  595.393903]  [<ffffffff8105525a>] warn_slowpath_null+0x1a/0x20
>> > > > > Jul 14 01:11:41 server01 kernel: [  595.394068]  [<ffffffff81059c50>] do_exit+0x7d0/0x870
>> > > > > Jul 14 01:11:41 server01 kernel: [  595.394231]  [<ffffffff81050254>] ? thread_group_times+0x44/0xb0
>> > > > > Jul 14 01:11:41 server01 kernel: [  595.394392]  [<ffffffff81059d41>] do_group_exit+0x51/0xc0
>> > > > > Jul 14 01:11:41 server01 kernel: [  595.394551]  [<ffffffff81059dc7>] sys_exit_group+0x17/0x20
>> > > > > Jul 14 01:11:41 server01 kernel: [  595.394714]  [<ffffffff815caea6>] system_call_fastpath+0x18/0x1d
>> > > > > Jul 14 01:11:41 server01 kernel: [  595.394921] ---[ end trace 738570e688acf099 ]---
>> > > > > 
>> > > > > OK, so you had an OOM which has been handled by in-kernel oom handler
>> > > > > (it killed 12021) and 12037 was in the same group. The warning tells us
>> > > > > that it went through mem_cgroup_oom as well (otherwise it wouldn't have
>> > > > > memcg_oom.wait_on_memcg set and the warning wouldn't trigger) and then
>> > > > > it exited on the userspace request (by exit syscall).
>> > > > > 
>> > > > > I do not see any way how, this could happen though. If mem_cgroup_oom
>> > > > > is called then we always return CHARGE_NOMEM which turns into ENOMEM
>> > > > > returned by __mem_cgroup_try_charge (invoke_oom must have been set to
>> > > > > true).  So if nobody screwed the return value on the way up to page
>> > > > > fault handler then there is no way to escape.
>> > > > > 
>> > > > > I will check the code.
>> > > > 
>> > > > OK, I guess I found it:
>> > > > __do_fault
>> > > >   fault = filemap_fault
>> > > >   do_async_mmap_readahead
>> > > >     page_cache_async_readahead
>> > > >       ondemand_readahead
>> > > >         __do_page_cache_readahead
>> > > >           read_pages
>> > > >             readpages = ext3_readpages
>> > > >               mpage_readpages			# Doesn't propagate ENOMEM
>> > > >                add_to_page_cache_lru
>> > > >                  add_to_page_cache
>> > > >                    add_to_page_cache_locked
>> > > >                      mem_cgroup_cache_charge
>> > > > 
>> > > > So the read ahead most probably. Again! Duhhh. I will try to think
>> > > > about a fix for this. One obvious place is mpage_readpages but
>> > > > __do_page_cache_readahead ignores read_pages return value as well and
>> > > > page_cache_async_readahead, even worse, is just void and exported as
>> > > > such.
>> > > > 
>> > > > So this smells like a hard to fix bugger. One possible, and really ugly
>> > > > way would be calling mem_cgroup_oom_synchronize even if handle_mm_fault
>> > > > doesn't return VM_FAULT_ERROR, but that is a crude hack.
>
>I fixed it by disabling the OOM killer altogether for readahead code.
>We don't do it globally, we should not do it in the memcg, these are
>optional allocations/charges.
>
>I also disabled it for kernel faults triggered from within a syscall
>(copy_*user, get_user_pages), which should just return -ENOMEM as
>usual (unless it's nested inside a userspace fault).  The only
>downside is that we can't get around annotating userspace faults
>anymore, so every architecture fault handler now passes
>FAULT_FLAG_USER to handle_mm_fault().  Makes the series a little less
>self-contained, but it's not unreasonable.
>
>It's easy to detect leaks now by checking if the memcg OOM context is
>setup and we are not returning VM_FAULT_OOM.
>
>Here is a combined diff based on 3.2.  azurIt, any chance you could
>give this a shot?  I tested it on my local machines, but you have a
>known reproducer of fairly unlikely scenarios...


I will be out of office between 25.7. and 1.8. and I don't want to run anything which can potentially do an outage of our services. I will test this patch after 2.8. Should I use also previous patches of this one is enough? Thank you very much Johannes.

azur

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
