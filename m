Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id D2B326B00F2
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 10:26:21 -0400 (EDT)
Date: Mon, 16 Apr 2012 16:26:19 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: question about memsw of memory cgroup-subsystem
Message-ID: <20120416142619.GA2014@tiehlicka.suse.cz>
References: <op.wco7ekvhn27o5l@gaoqiang-d1.corp.qihoo.net>
 <20120413144954.GA9227@tiehlicka.suse.cz>
 <op.wct9zibjn27o5l@gaoqiang-d1.corp.qihoo.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <op.wct9zibjn27o5l@gaoqiang-d1.corp.qihoo.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gaoqiang <gaoqiangscut@gmail.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org

On Mon 16-04-12 11:43:56, gaoqiang wrote:
> a?? Fri, 13 Apr 2012 22:49:54 +0800i 1/4 ?Michal Hocko <mhocko@suse.cz> a??e??:
> 
> >[CC linux-mm]
> >
> >Hi,
> >
> >On Fri 13-04-12 18:00:10, gaoqiang wrote:
> >>
> >>
> >>I put a single process into a cgroup and set memory.limit_in_bytes
> >>to 100M,and memory.memsw.limit_in_bytes to 1G.
> >>
> >>howevery,the process was oom-killed before mem+swap hit 1G. I tried
> >>many times,and it was killed randomly when memory+swap
> >>
> >>exceed 100M but less than 1G.  what is the matter ?
> >
> >could you be more specific about your kernel version, workload and could
> >you provide us with GROUP/memory.stat snapshots taken during your test?
> >
> >One reason for oom might be that you are hitting the hard limit (you
> >cannot get over even if memsw limit says more) and you cannot swap out
> >any pages (e.g. they are mlocked or under writeback).
> >
> 
> many thanks.
> 
> 
> The system is a vmware virtual machine,running centos6.2 with kernel
> 2.6.32-220.7.1.el6.x86_64.

Are you able to reproduce with the vanilla (same version) or a newer
kernel?

> the attachments are memory.stat, 

When did you take this one? Before/during/after the test

> the test program and the /var/log/message of the oom.
> 
> the workload is nearly 0,with searal sshd and bash program running.
> 
> I just did the following command when testing:
> 
> ./t
> # this program will pause at the "getchar()" line and in another
> terminal,run :
> 
> cgclear
> service cgconfig restart
> mkdir /cgroup/memory/test
> cd /cgroup/memory/test
> echo 100m > memory.limit_in_bytes
> echo 1G > memory.memsw.limit_in_bytes
> echo 'pid' > tasks
> 
> # then continue the t command
> 
> 
> Apr 16 11:34:50 localhost kernel: t invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=0, oom_score_adj=0
> Apr 16 11:34:50 localhost kernel: t cpuset=/ mems_allowed=0
> Apr 16 11:34:50 localhost kernel: Pid: 15462, comm: t Not tainted 2.6.32-220.7.1.el6.x86_64 #1
> Apr 16 11:34:50 localhost kernel: Call Trace:
> Apr 16 11:34:50 localhost kernel: [<ffffffff810c2c61>] ? cpuset_print_task_mems_allowed+0x91/0xb0
> Apr 16 11:34:50 localhost kernel: [<ffffffff811139e0>] ? dump_header+0x90/0x1b0
> Apr 16 11:34:50 localhost kernel: [<ffffffff811693b5>] ? task_in_mem_cgroup+0x35/0xb0
> Apr 16 11:34:50 localhost kernel: [<ffffffff8120d7ac>] ? security_real_capable_noaudit+0x3c/0x70
> Apr 16 11:34:50 localhost kernel: [<ffffffff81113e6a>] ? oom_kill_process+0x8a/0x2c0
> Apr 16 11:34:50 localhost kernel: [<ffffffff81113d5e>] ? select_bad_process+0x9e/0x120
> Apr 16 11:34:50 localhost kernel: [<ffffffff81114602>] ? mem_cgroup_out_of_memory+0x92/0xb0
> Apr 16 11:34:50 localhost kernel: [<ffffffff81169357>] ? mem_cgroup_handle_oom+0x147/0x170
> Apr 16 11:34:50 localhost kernel: [<ffffffff81090a90>] ? autoremove_wake_function+0x0/0x40
> Apr 16 11:34:50 localhost kernel: [<ffffffff8116a61b>] ? __mem_cgroup_try_charge+0x3bb/0x420
> Apr 16 11:34:50 localhost kernel: [<ffffffff81123851>] ? __alloc_pages_nodemask+0x111/0x940
> Apr 16 11:34:50 localhost kernel: [<ffffffff8116b917>] ? mem_cgroup_charge_common+0x87/0xd0
> Apr 16 11:34:50 localhost kernel: [<ffffffff8116bae8>] ? mem_cgroup_newpage_charge+0x48/0x50
> Apr 16 11:34:50 localhost kernel: [<ffffffff8113beca>] ? handle_pte_fault+0x79a/0xb50
> Apr 16 11:34:50 localhost kernel: [<ffffffff810471c7>] ? pte_alloc_one+0x37/0x50
> Apr 16 11:34:50 localhost kernel: [<ffffffff81171ad9>] ? do_huge_pmd_anonymous_page+0xb9/0x370
> Apr 16 11:34:50 localhost kernel: [<ffffffff8100bc0e>] ? apic_timer_interrupt+0xe/0x20
> Apr 16 11:34:50 localhost kernel: [<ffffffff8113c464>] ? handle_mm_fault+0x1e4/0x2b0
> Apr 16 11:34:50 localhost kernel: [<ffffffff81042b79>] ? __do_page_fault+0x139/0x480
> Apr 16 11:34:50 localhost kernel: [<ffffffff811424ea>] ? do_mmap_pgoff+0x33a/0x380
> Apr 16 11:34:50 localhost kernel: [<ffffffff814f253e>] ? do_page_fault+0x3e/0xa0
> Apr 16 11:34:50 localhost kernel: [<ffffffff814ef8f5>] ? page_fault+0x25/0x30
> Apr 16 11:34:50 localhost kernel: Task in /test killed as a result of limit of /test
> Apr 16 11:34:50 localhost kernel: memory: usage 102400kB, limit 102400kB, failcnt 756
> Apr 16 11:34:50 localhost kernel: memory+swap: usage 206240kB, limit 1048576kB, failcnt 0
> Apr 16 11:34:50 localhost kernel: Mem-Info:
[...]
> Apr 16 11:34:50 localhost kernel: active_anon:14198 inactive_anon:66406 isolated_anon:0
> Apr 16 11:34:50 localhost kernel: active_file:62480 inactive_file:88538 isolated_file:0
> Apr 16 11:34:50 localhost kernel: unevictable:0 dirty:0 writeback:12822 unstable:0
> Apr 16 11:34:50 localhost kernel: free:27898 slab_reclaimable:8884 slab_unreclaimable:9427
> Apr 16 11:34:50 localhost kernel: mapped:2723 shmem:68 pagetables:1747 bounce:0

There still seem to be a lot of anon memory that could be reclaimed...
[...]
> Apr 16 11:34:50 localhost kernel: 211205 total pagecache pages
> Apr 16 11:34:50 localhost kernel: 60108 pages in swap cache
> Apr 16 11:34:50 localhost kernel: Swap cache stats: add 1240384, delete 1180276, find 400/507
> Apr 16 11:34:50 localhost kernel: Free swap  = 1720104kB

And a lot of swap space where to put that memory. I do not see any
reason why we should fail to swap out some memory and so get down under
the hard limit. Btw. oom would come sooner or later with your test case.

Anyway there were quite "some" fixes since 2.6.32...

> Apr 16 11:34:50 localhost kernel: Total swap = 2064376kB
> Apr 16 11:34:50 localhost kernel: 294896 pages RAM
> Apr 16 11:34:50 localhost kernel: 7632 pages reserved
> Apr 16 11:34:50 localhost kernel: 100154 pages shared
> Apr 16 11:34:50 localhost kernel: 171738 pages non-shared
> Apr 16 11:34:50 localhost kernel: [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
> Apr 16 11:34:50 localhost kernel: [15462]   500 15462    58346    12903   3       0             0 t
> Apr 16 11:34:50 localhost kernel: Memory cgroup out of memory: Kill process 15462 (t) score 1000 or sacrifice child
> Apr 16 11:34:50 localhost kernel: Killed process 15462, UID 500, (t) total-vm:233384kB, anon-rss:51228kB, file-rss:384kB
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
