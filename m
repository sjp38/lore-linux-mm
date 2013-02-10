Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 8F8076B0002
	for <linux-mm@kvack.org>; Sun, 10 Feb 2013 10:03:18 -0500 (EST)
Received: by mail-ee0-f53.google.com with SMTP id e53so2825180eek.40
        for <linux-mm@kvack.org>; Sun, 10 Feb 2013 07:03:16 -0800 (PST)
Date: Sun, 10 Feb 2013 16:03:13 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH for 3.2.34] memcg: do not trigger OOM if PF_NO_MEMCG_OOM
 is set
Message-ID: <20130210150310.GA9504@dhcp22.suse.cz>
References: <20130206160051.GG10254@dhcp22.suse.cz>
 <20130208060304.799F362F@pobox.sk>
 <20130208094420.GA7557@dhcp22.suse.cz>
 <20130208120249.FD733220@pobox.sk>
 <20130208123854.GB7557@dhcp22.suse.cz>
 <20130208145616.FB78CE24@pobox.sk>
 <20130208152402.GD7557@dhcp22.suse.cz>
 <20130208165805.8908B143@pobox.sk>
 <20130208171012.GH7557@dhcp22.suse.cz>
 <20130208220243.EDEE0825@pobox.sk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130208220243.EDEE0825@pobox.sk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Fri 08-02-13 22:02:43, azurIt wrote:
> >
> >I assume you have checked that the killed processes eventually die,
> >right?
> 
> 
> When i killed them by hand, yes, they dissappeard from process list (i
> saw it). I don't know if they really died when OOM killed them.
> 
> 
> >Well, I do not see anything supsicious during that time period
> >(timestamps translate between Fri Feb  8 02:34:05 and Fri Feb  8
> >02:36:48). The kernel log shows a lot of oom during that time. All
> >killed processes die eventually.
> 
> 
> No, they didn't died by OOM when cgroup was freezed. Just check PIDs
> from memcg-bug-4.tar.gz and try to find them in kernel log.

OK, you seem to be right. My initial examination showed that each cgroup
under OOM was able to move forward - in other words it was able to send
SIGKILL somebody and we didn't loop on a single task which cannot die
for some reason. Now when looking closer it seem we really have 2 tasks
which didn't die after being killed by OOM killer:

$ for i in `grep "Memory cgroup out of memory:" kern2.log | sed 's@.*Kill process \([0-9]*\) .*@\1@'`; 
do 
	find bug -name $i; 
done | sed 's@.*/@@' | sort | uniq -c
    141 18211
    141 8102

$ md5sum bug/*/18211/stack | cut -d" " -f1 | uniq -c
    141 3b8ce17e82a065a24ee046112033e1e8
So all the stacks are same:
[<ffffffff81069f94>] ptrace_stop+0x114/0x290
[<ffffffff8106a198>] ptrace_do_notify+0x88/0xa0
[<ffffffff8106a203>] ptrace_notify+0x53/0x70
[<ffffffff8100d168>] syscall_trace_enter+0xf8/0x1c0
[<ffffffff815b6983>] tracesys+0x71/0xd7
[<ffffffffffffffff>] 0xffffffffffffffff

stuck in the ptrace code.

The other task is more interesting:
$ md5sum bug/*/8102/stack | cut -d" " -f1 | sort | uniq -c
    135 042e893c0e6657ed321ea9045e528f3e
      6 dc7e71ce73be2a5c73404b565926e709

All snapshots with 042e893c0e6657ed321ea9045e528f3e are in:
[<ffffffff8110ae51>] mem_cgroup_handle_oom+0x241/0x3b0
[<ffffffff8110ba83>] T.1149+0x5f3/0x600
[<ffffffff8110bf5c>] mem_cgroup_charge_common+0x6c/0xb0
[<ffffffff8110bfe5>] mem_cgroup_newpage_charge+0x45/0x50
[<ffffffff810ee2a9>] handle_pte_fault+0x609/0x940
[<ffffffff810ee718>] handle_mm_fault+0x138/0x260
[<ffffffff810270bd>] do_page_fault+0x13d/0x460
[<ffffffff815b633f>] page_fault+0x1f/0x30
[<ffffffffffffffff>] 0xffffffffffffffff

While the others do not show any stack:
cat 1360287257/8102/stack 
[<ffffffffffffffff>] 0xffffffffffffffff

Which is quite interesting because we are talking about snapshots
starting at 1360287245 (which maps to 02:34:05) but the kern2.log tells
us that this process has been killed much earlier at:

Feb  8 01:18:30 server01 kernel: [  511.139921] Task in /1293/uid killed as a result of limit of /1293
[...]
Feb  8 01:18:30 server01 kernel: [  511.229755] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
Feb  8 01:18:30 server01 kernel: [  511.230146] [ 8102]  1293  8102   170258    65869   7       0             0 apache2
Feb  8 01:18:30 server01 kernel: [  511.230339] [ 8113]  1293  8113   163756    59442   5       0             0 apache2
Feb  8 01:18:30 server01 kernel: [  511.230528] [ 8116]  1293  8116   170094    65675   2       0             0 apache2
Feb  8 01:18:30 server01 kernel: [  511.230726] [ 8119]  1293  8119   170094    65675   6       0             0 apache2
Feb  8 01:18:30 server01 kernel: [  511.230924] [ 8123]  1293  8123   169070    64612   7       0             0 apache2
Feb  8 01:18:30 server01 kernel: [  511.231132] [ 8124]  1293  8124   170094    65675   5       0             0 apache2
Feb  8 01:18:30 server01 kernel: [  511.231321] [ 8125]  1293  8125   170094    65673   1       0             0 apache2
Feb  8 01:18:30 server01 kernel: [  511.231516] Memory cgroup out of memory: Kill process 8102 (apache2) score 1000 or sacrifice child

This would suggest that the task is hung and cannot be killed but if we
have a look at the following OOM in the same group 1293 it was _not_
present in the process list for that group:

Feb  8 01:18:33 server01 kernel: [  514.789550] Task in /1293/uid killed as a result of limit of /1293
[...]
Feb  8 01:18:33 server01 kernel: [  514.893198] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
Feb  8 01:18:33 server01 kernel: [  514.893594] [ 8113]  1293  8113   168212    64036   1       0             0 apache2
Feb  8 01:18:33 server01 kernel: [  514.893786] [ 8116]  1293  8116   170258    65870   6       0             0 apache2
Feb  8 01:18:33 server01 kernel: [  514.893976] [ 8119]  1293  8119   170258    65870   7       0             0 apache2
Feb  8 01:18:33 server01 kernel: [  514.894166] [ 8123]  1293  8123   170158    65824   6       0             0 apache2
Feb  8 01:18:33 server01 kernel: [  514.894356] [ 8124]  1293  8124   170258    65870   5       0             0 apache2
Feb  8 01:18:33 server01 kernel: [  514.894547] [ 8125]  1293  8125   170158    65824   1       0             0 apache2
Feb  8 01:18:33 server01 kernel: [  514.894749] [ 8149]  1293  8149   163989    59647   7       0             0 apache2
Feb  8 01:18:33 server01 kernel: [  514.894944] Memory cgroup out of memory: Kill process 8113 (apache2) score 1000 or sacrifice child

This is all _before_ you started collecting stacks and it also says that
8102 is gone.

This all suggests that a) stack unwinder which displays
/proc/<pid>/stack is somehow confused and it doesn't show the correct
stack for this process and b) the two processes cannot terminate due to
some issue related to ptrace (stracing) the dying process.

The above oom list doesn't include any processes which already released
the memory which would explain why you still can see it as a member of
the group (when looking into cgroup/tasks file). My guess would be that
there is a bug in ptrace which doesn't free a reference to the task
so it cannot cannot go away although it has dropped all the resources
already.

> Why are all PIDs waiting on 'mem_cgroup_handle_oom' and there is no
> OOM message in the log?

I am not sure what you mean here but there are
$ grep "Memory cgroup out of memory:" kern2.collected.log | wc -l
16

OOM killer events during the time you were gathering memcg-bug-4 data.

>  Data in memcg-bug-4.tar.gz are only for 2
> minutes but i let it run for about 15-20 minutes, no single process
> killed by OOM.

I can see
$ grep "Memory cgroup out of memory:" kern2.after.log | wc -l
57

killed after 02:38:47 when you stopped gathering data for memcg-bug-4

> I'm 100% sure that OOM was not killing them (maybe it was trying to
> but it didn't happen).

OK, let's do a little exercise. The list of processes eligible for OOM
are listed before any task is killed. So if we collect both pid lists
and "Kill process" messages per pid then no entries in the pid list
should be present after the specific pid is killed.

$ mkdir out
$ for i in `grep "Memory cgroup out of memory: Kill process" kern2.log | sed 's@.*Kill process \([0-9]*\) .*@\1@'`
do 
	grep -e "Memory cgroup out of memory: Kill process $i" \
	     -e "\[ *\<$i\]" kern2.log > out/$i
done
$ for i in out/*
do 
	tail -n1 $i | grep "Memory cgroup out of memory:" >/dev/null|| echo "$i has already killed tasks"
done
out/6698 has already killed tasks
out/6703 has already killed tasks

OK, so there are two pids which were listed after they have been
killed. Let's have a look at them.
$ cat out/6698
Feb  8 01:17:04 server01 kernel: [  425.497924] [ 6698]  1293  6698   170258    65846   1       0             0 apache2
Feb  8 01:17:05 server01 kernel: [  426.079010] [ 6698]  1293  6698   170258    65846   1       0             0 apache2
Feb  8 01:17:10 server01 kernel: [  431.144460] [ 6698]  1293  6698   169358    65220   1       0             0 apache2
Feb  8 01:17:10 server01 kernel: [  431.146058] Memory cgroup out of memory: Kill process 6698 (apache2) score 1000 or sacrifice child
Feb  8 03:27:57 server01 kernel: [ 8278.439896] [ 6698]  1020  6698   168518    64219   0       0             0 apache2
Feb  8 03:27:57 server01 kernel: [ 8278.879439] [ 6698]  1020  6698   168518    64218   6       0             0 apache2
Feb  8 03:27:59 server01 kernel: [ 8280.023944] [ 6698]  1020  6698   168816    64540   7       0             0 apache2
Feb  8 03:28:02 server01 kernel: [ 8283.242282] [ 6698]  1020  6698   171953    67751   6       0             0 apache2
$ cat out/6703
Feb  8 01:17:04 server01 kernel: [  425.498118] [ 6703]  1293  6703   170258    65844   6       0             0 apache2
Feb  8 01:17:05 server01 kernel: [  426.079206] [ 6703]  1293  6703   170258    65844   6       0             0 apache2
Feb  8 01:17:10 server01 kernel: [  431.144653] [ 6703]  1293  6703   169358    65219   2       0             0 apache2
Feb  8 01:17:10 server01 kernel: [  431.258924] [ 6703]  1293  6703   169358    65219   5       0             0 apache2
Feb  8 01:17:10 server01 kernel: [  431.260282] Memory cgroup out of memory: Kill process 6703 (apache2) score 1000 or sacrifice child
Feb  8 03:27:57 server01 kernel: [ 8278.440043] [ 6703]  1020  6703   166286    61978   7       0             0 apache2
Feb  8 03:27:57 server01 kernel: [ 8278.879587] [ 6703]  1020  6703   166286    61977   7       0             0 apache2
Feb  8 03:27:59 server01 kernel: [ 8280.024091] [ 6703]  1020  6703   166484    62233   7       0             0 apache2
Feb  8 03:28:02 server01 kernel: [ 8283.242429] [ 6703]  1020  6703   167402    63118   0       0             0 apache2

Lists have the following columns:
[ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name

As we can see the uid changed for both pids after it has been killed
(from 1293 to 1020) which suggests that the pid has been reused later
for a different user (which is a clear sign that those pids died) - thus
different group in your setup.
So those two died as well, apparently.

> >Nothing shows it would be a deadlock so far. It is well possible that
> >the userspace went mad when seeing a lot of processes dying because it
> >doesn't expect it.
> 
> Lots of processes are dying also now, without your latest patch, and
> no such things are happening. I'm sure there is something more it
> this, maybe it revealed another bug?

So far nothing shows that there would be anything broken wrt. memcg OOM
killer. The ptrace issue sounds strange, all right, but that is another
story and worth a separate investigation. I would be interested whether
you still see anything wrong going on without that in game.

You can get pretty nice overview of what is going on wrt. OOM from the
log.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
