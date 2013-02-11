Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id A6C366B0002
	for <linux-mm@kvack.org>; Mon, 11 Feb 2013 06:22:43 -0500 (EST)
Date: Mon, 11 Feb 2013 12:22:40 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH for 3.2.34] memcg: do not trigger OOM if PF_NO_MEMCG_OOM
 is set
Message-ID: <20130211112240.GC19922@dhcp22.suse.cz>
References: <20130208094420.GA7557@dhcp22.suse.cz>
 <20130208120249.FD733220@pobox.sk>
 <20130208123854.GB7557@dhcp22.suse.cz>
 <20130208145616.FB78CE24@pobox.sk>
 <20130208152402.GD7557@dhcp22.suse.cz>
 <20130208165805.8908B143@pobox.sk>
 <20130208171012.GH7557@dhcp22.suse.cz>
 <20130208220243.EDEE0825@pobox.sk>
 <20130210150310.GA9504@dhcp22.suse.cz>
 <20130210174619.24F20488@pobox.sk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130210174619.24F20488@pobox.sk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Sun 10-02-13 17:46:19, azurIt wrote:
> >stuck in the ptrace code.
> 
> 
> But this happens _after_ the cgroup was freezed and i tried to strace
> one of it's processes (to see what's happening):
> 
> Feb  8 01:29:46 server01 kernel: [ 1187.540672] grsec: From 178.40.250.111: process /usr/lib/apache2/mpm-itk/apache2(apache2:18211) attached to via ptrace by /usr/bin/strace[strace:18258] uid/euid:0/0 gid/egid:0/0, parent /usr/bin/htop[htop:2901] uid/euid:0/0 gid/egid:0/0

Hmmm,
Feb  8 01:39:16 server01 kernel: [ 1757.266678] Memory cgroup out of memory: Kill process 18211 (apache2) score 725 or sacrifice child)

So the process has been killed 10 minutes ago and this was really the
last OOM event for group /1258:

$ grep "Task in /1258/uid killed" kern2.log | tail -n2
Feb  8 01:39:16 server01 kernel: [ 1757.045021] Task in /1258/uid killed as a result of limit of /1258
Feb  8 01:39:16 server01 kernel: [ 1757.167984] Task in /1258/uid killed as a result of limit of /1258

But this was still before you started collecting data for memcg-bug-4
(2:34) so we do not know what was the previous stack unfortunatelly.

> >> Why are all PIDs waiting on 'mem_cgroup_handle_oom' and there is no
> >> OOM message in the log?
> >
> >I am not sure what you mean here but there are
> >$ grep "Memory cgroup out of memory:" kern2.collected.log | wc -l
> >16
> >
> >OOM killer events during the time you were gathering memcg-bug-4 data.
> >
> >>  Data in memcg-bug-4.tar.gz are only for 2
> >> minutes but i let it run for about 15-20 minutes, no single process
> >> killed by OOM.
> >
> >I can see
> >$ grep "Memory cgroup out of memory:" kern2.after.log | wc -l
> >57
> >
> >killed after 02:38:47 when you stopped gathering data for memcg-bug-4
> 
> 
> I meant no single process was killed inside cgroup 1258 (data from
> this cgroup are in memcg-bug-4.tar.gz).
>
> Just get data from memcg-bug-4.tar.gz which were taken from cgroup
> 1258.

Are you sure about that? When I extracted all pids from timestamp
directories and greped them in the log I got this:
for i in `cat bug/pids` ; do grep "\[ *\<$i\>\]" kern2.log ; done
Feb  8 01:31:02 server01 kernel: [ 1263.429212] [18211]  1258 18211   164338    60950   0       0             0 apache2
Feb  8 01:31:15 server01 kernel: [ 1276.655241] [18211]  1258 18211   164338    60950   0       0             0 apache2
Feb  8 01:32:29 server01 kernel: [ 1350.797835] [18211]  1258 18211   164338    60950   0       0             0 apache2
Feb  8 01:32:42 server01 kernel: [ 1363.662242] [18211]  1258 18211   164338    60950   0       0             0 apache2
Feb  8 01:32:46 server01 kernel: [ 1367.181798] [18211]  1258 18211   164338    60950   0       0             0 apache2
Feb  8 01:32:46 server01 kernel: [ 1367.381627] [18211]  1258 18211   164338    60950   0       0             0 apache2
Feb  8 01:32:46 server01 kernel: [ 1367.490896] [18211]  1258 18211   164338    60950   0       0             0 apache2
Feb  8 01:33:02 server01 kernel: [ 1383.709652] [18211]  1258 18211   164338    60950   0       0             0 apache2
Feb  8 01:36:26 server01 kernel: [ 1587.458967] [18211]  1258 18211   164338    60950   0       0             0 apache2
Feb  8 01:36:26 server01 kernel: [ 1587.558419] [18211]  1258 18211   164338    60950   0       0             0 apache2
Feb  8 01:36:26 server01 kernel: [ 1587.652474] [18211]  1258 18211   164338    60950   0       0             0 apache2
Feb  8 01:39:02 server01 kernel: [ 1743.107086] [18211]  1258 18211   164338    60950   0       0             0 apache2
Feb  8 01:39:16 server01 kernel: [ 1757.015359] [18211]  1258 18211   164338    60950   0       0             0 apache2
Feb  8 01:39:16 server01 kernel: [ 1757.133998] [18211]  1258 18211   164338    60950   0       0             0 apache2
Feb  8 01:39:16 server01 kernel: [ 1757.262992] [18211]  1258 18211   164338    60950   0       0             0 apache2
Feb  8 01:18:12 server01 kernel: [  493.156641] [ 7888]  1293  7888   169326    64876   3       0             0 apache2
Feb  8 01:18:12 server01 kernel: [  493.269129] [ 7888]  1293  7888   169390    64876   4       0             0 apache2
Feb  8 01:18:21 server01 kernel: [  502.384221] [ 8011]  1293  8011   170094    65675   5       0             0 apache2
Feb  8 01:18:24 server01 kernel: [  505.052600] [ 8011]  1293  8011   170260    65854   2       0             0 apache2
Feb  8 01:18:24 server01 kernel: [  505.200454] [ 8011]  1293  8011   170260    65854   2       0             0 apache2
Feb  8 01:18:33 server01 kernel: [  514.538637] [ 8054]  1258  8054   164404    60618   1       0             0 apache2
Feb  8 01:18:30 server01 kernel: [  511.230146] [ 8102]  1293  8102   170258    65869   7       0             0 apache2

So at least 7888, 8011 and 8102 were from a different group (1293).
Others were never listed in the eligible processes list which is a bit
unexpected. It is also unfortunate because I cannot match them to their
groups from the log.
$ for i in `cat bug/pids` ; do grep "\[ *\<$i\>\]" kern2.log >/dev/null || echo "$i not listed" ; done
7265 not listed
7474 not listed
7710 not listed
7969 not listed
7988 not listed
7997 not listed
8000 not listed
8014 not listed
8016 not listed
8019 not listed
8057 not listed
8058 not listed
8059 not listed
8063 not listed
8064 not listed
8066 not listed
8067 not listed
8069 not listed
8070 not listed
8071 not listed
8072 not listed
8075 not listed
8091 not listed
8092 not listed
8094 not listed
8098 not listed
8099 not listed
8100 not listed

Are you sure all of them belong to 1258 group?

> Almost all processes are in 'mem_cgroup_handle_oom' so cgroup
> is under OOM. 

You are right, almost all of them are waiting in mem_cgroup_handle_oom
which suggest that they should be listed in a per group eligible tasks
list.

One way how this might happen is when a process which manages to
get oom_lock has a fatal signal pending. Then we wouldn't get to
oom_kill_process and no OOM messages would get printed. This is correct
because such a task would terminate soon anyway and all the waiters
would wake up eventually. If not enough memory would be freed another
task would get the oom_lock and this one would trigger OOM (unless it
has fatal signal pending as well).

Another option would be that no task could be selected - e.g. because
select_bad_process sees TIF_MEMDIE marked task - the one already killed
by OOM killer but that wasn't able to terminate for some reason. 18211
could be such a task. But we do not know what was going on with it
before strace attached to it.

Finally it is possible that the OOM header (everything up to Kill process)
was suppressed because of rate limiting. But
$ grep -B1 "Kill process" kern2.log
Feb  8 01:15:02 server01 kernel: [  304.000402] [ 4969]  1258  4969   163761    59554   6       0             0 apache2
Feb  8 01:15:02 server01 kernel: [  304.000649] Memory cgroup out of memory: Kill process 4816 (apache2) score 1000 or sacrifice child
--
Feb  8 01:15:51 server01 kernel: [  352.924573] [ 5847]  1709  5847   163433    58952   6       0             0 apache2
Feb  8 01:15:51 server01 kernel: [  352.924761] Memory cgroup out of memory: Kill process 5212 (apache2) score 1000 or sacrifice child
[...]

says that the message was preceded by a process list so we can exclude
rate limiting.

> I assume that this is suppose to take only few seconds
> while kernel finds any process and kill it (and maybe do it again
> until enough of memory is freed). I was gathering the data for
> about 2 and a half minutes and NO SINGLE process was killed (just
> compate list of PIDs from the first and the last directory inside
> memcg-bug-4.tar.gz). Even more, no single process was killed in cgroup
> 1258 also after i stopped gathering the data. You can also take the
> list od PID from memcg-bug-4.tar.gz and you will find only 18211 and
> 8102 (which are the two stucked processes).
>
> So my question is: Why no process was killed inside cgroup 1258
> while it was under OOM?

I would bet that there is something weird going on with pid:18211. But I
do not have enough information to find out what and why.

> It was under OOM for at least 2 and a half of minutes while i was
> gathering the data (then i let it run for additional, cca, 10 minutes
> and then killed processes by hand but i cannot proof this). Why kernel
> didn't kill any process for so long and ends the OOM?

As already mentioned above, select_bad_process doesn't select any task
if there is one which is on the way out. Maybe this is what is going on here.
 
> Btw, processes in cgroup 1258 (memcg-bug-4.tar.gz) are looping in this
> two tasks (i pasted only first line of stack):
> mem_cgroup_handle_oom+0x241/0x3b0
> 0xffffffffffffffff

0xffffffffffffffff is just a bogus entry. No idea why this happens.

> Some of them are in 'poll_schedule_timeout' and then they start to
> loop as above. Is this correct behavior?
> For example, do (first line of stack from process 7710 from all
> timestamps): for i in */7710/stack; do head -n1 $i; done

Yes, this is perfectly ok, because that task starts with:
$ cat bug/1360287245/7710/stack
[<ffffffff81125eb9>] poll_schedule_timeout+0x49/0x70
[<ffffffff8112675b>] do_sys_poll+0x54b/0x680
[<ffffffff81126b4c>] sys_poll+0x7c/0xf0
[<ffffffff815b6866>] system_call_fastpath+0x18/0x1d
[<ffffffffffffffff>] 0xffffffffffffffff

and then later on it gets into OOM because of a page fault:
$ cat bug/1360287250/7710/stack
[<ffffffff8110ae51>] mem_cgroup_handle_oom+0x241/0x3b0
[<ffffffff8110ba83>] T.1149+0x5f3/0x600
[<ffffffff8110bf5c>] mem_cgroup_charge_common+0x6c/0xb0
[<ffffffff8110bfe5>] mem_cgroup_newpage_charge+0x45/0x50
[<ffffffff810eca1e>] do_wp_page+0x14e/0x800
[<ffffffff810edf04>] handle_pte_fault+0x264/0x940
[<ffffffff810ee718>] handle_mm_fault+0x138/0x260
[<ffffffff810270bd>] do_page_fault+0x13d/0x460
[<ffffffff815b633f>] page_fault+0x1f/0x30
[<ffffffffffffffff>] 0xffffffffffffffff

And it loops in it until the end which is possible as well if the group
is under permanent OOM condition and the task is not selected to be
killed.

Unfortunately I am not able to reproduce this behavior even if I try
to hammer OOM like mad so I am afraid I cannot help you much without
further debugging patches.
I do realize that experimenting in your environment is a problem but I
do not many options left. Please do not use strace and rather collect
/proc/pid/stack instead. It would be also helpful to get group/tasks
file to have a full list of tasks in the group
---
