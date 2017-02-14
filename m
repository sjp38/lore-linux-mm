Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 52AE0680FD0
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 14:43:57 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id i10so48241467wrb.0
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 11:43:57 -0800 (PST)
Received: from mail2-relais-roc.national.inria.fr (mail2-relais-roc.national.inria.fr. [192.134.164.83])
        by mx.google.com with ESMTPS id q18si1992563wra.35.2017.02.14.11.43.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Feb 2017 11:43:56 -0800 (PST)
Date: Tue, 14 Feb 2017 20:43:54 +0100 (CET)
From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH 2/3 staging-next] oom: Add notification for oom_score_adj
 (fwd)
Message-ID: <alpine.DEB.2.20.1702142042370.2199@hadrien>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peter.enderborg@sonymobile.com
Cc: devel@driverdev.osuosl.org, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, arve@android.com, riandrews@android.com, torvalds@linux-foundation.org, linux-mm@kvack.org

It looks like an unlock is missing before line 1797.

julia

---------- Forwarded message ----------
Date: Wed, 15 Feb 2017 03:07:29 +0800
From: kbuild test robot <fengguang.wu@intel.com>
To: kbuild@01.org
Cc: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH 2/3 staging-next] oom: Add notification for oom_score_adj

Hi Peter,

[auto build test WARNING on staging/staging-testing]
[also build test WARNING on v4.10-rc8 next-20170214]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/peter-enderborg-sonymobile-com/android-Collect-statistics-from-lowmemorykiller/20170215-004327
:::::: branch date: 2 hours ago
:::::: commit date: 2 hours ago

>> kernel/fork.c:1887:1-7: preceding lock on line 1766
   kernel/fork.c:1887:1-7: preceding lock on line 1755

git remote add linux-review https://github.com/0day-ci/linux
git remote update linux-review
git checkout 0174c40bf153def3ac7b287f000a885b15048a38
vim +1887 kernel/fork.c

2d5516cbb Oleg Nesterov     2009-03-02  1760  		p->parent_exec_id = current->parent_exec_id;
2d5516cbb Oleg Nesterov     2009-03-02  1761  	} else {
^1da177e4 Linus Torvalds    2005-04-16  1762  		p->real_parent = current;
2d5516cbb Oleg Nesterov     2009-03-02  1763  		p->parent_exec_id = current->self_exec_id;
2d5516cbb Oleg Nesterov     2009-03-02  1764  	}
^1da177e4 Linus Torvalds    2005-04-16  1765
^1da177e4 Linus Torvalds    2005-04-16 @1766  	spin_lock(&current->sighand->siglock);
4a2c7a783 Oleg Nesterov     2006-03-28  1767
4a2c7a783 Oleg Nesterov     2006-03-28  1768  	/*
dbd952127 Kees Cook         2014-06-27  1769  	 * Copy seccomp details explicitly here, in case they were changed
dbd952127 Kees Cook         2014-06-27  1770  	 * before holding sighand lock.
dbd952127 Kees Cook         2014-06-27  1771  	 */
dbd952127 Kees Cook         2014-06-27  1772  	copy_seccomp(p);
dbd952127 Kees Cook         2014-06-27  1773
dbd952127 Kees Cook         2014-06-27  1774  	/*
4a2c7a783 Oleg Nesterov     2006-03-28  1775  	 * Process group and session signals need to be delivered to just the
4a2c7a783 Oleg Nesterov     2006-03-28  1776  	 * parent before the fork or both the parent and the child after the
4a2c7a783 Oleg Nesterov     2006-03-28  1777  	 * fork. Restart if a signal comes in before we add the new process to
4a2c7a783 Oleg Nesterov     2006-03-28  1778  	 * it's process group.
4a2c7a783 Oleg Nesterov     2006-03-28  1779  	 * A fatal signal pending means that current will exit, so the new
4a2c7a783 Oleg Nesterov     2006-03-28  1780  	 * thread can't slip out of an OOM kill (or normal SIGKILL).
4a2c7a783 Oleg Nesterov     2006-03-28  1781  	*/
4a2c7a783 Oleg Nesterov     2006-03-28  1782  	recalc_sigpending();
4a2c7a783 Oleg Nesterov     2006-03-28  1783  	if (signal_pending(current)) {
4a2c7a783 Oleg Nesterov     2006-03-28  1784  		spin_unlock(&current->sighand->siglock);
4a2c7a783 Oleg Nesterov     2006-03-28  1785  		write_unlock_irq(&tasklist_lock);
4a2c7a783 Oleg Nesterov     2006-03-28  1786  		retval = -ERESTARTNOINTR;
7e47682ea Aleksa Sarai      2015-06-09  1787  		goto bad_fork_cancel_cgroup;
4a2c7a783 Oleg Nesterov     2006-03-28  1788  	}
4a2c7a783 Oleg Nesterov     2006-03-28  1789
73b9ebfe1 Oleg Nesterov     2006-03-28  1790  	if (likely(p->pid)) {
4b9d33e6d Tejun Heo         2011-06-17  1791  		ptrace_init_task(p, (clone_flags & CLONE_PTRACE) || trace);
^1da177e4 Linus Torvalds    2005-04-16  1792
819077398 Oleg Nesterov     2013-07-03  1793  		init_task_pid(p, PIDTYPE_PID, pid);
^1da177e4 Linus Torvalds    2005-04-16  1794  		if (thread_group_leader(p)) {
0174c40bf Peter Enderborg   2017-02-14  1795  			retval = oom_score_notify_new(p);
0174c40bf Peter Enderborg   2017-02-14  1796  			if (retval)
0174c40bf Peter Enderborg   2017-02-14  1797  				goto bad_fork_cancel_cgroup;
0174c40bf Peter Enderborg   2017-02-14  1798
819077398 Oleg Nesterov     2013-07-03  1799  			init_task_pid(p, PIDTYPE_PGID, task_pgrp(current));
819077398 Oleg Nesterov     2013-07-03  1800  			init_task_pid(p, PIDTYPE_SID, task_session(current));
819077398 Oleg Nesterov     2013-07-03  1801
1c4042c29 Eric W. Biederman 2010-07-12  1802  			if (is_child_reaper(pid)) {
17cf22c33 Eric W. Biederman 2010-03-02  1803  				ns_of_pid(pid)->child_reaper = p;
1c4042c29 Eric W. Biederman 2010-07-12  1804  				p->signal->flags |= SIGNAL_UNKILLABLE;
1c4042c29 Eric W. Biederman 2010-07-12  1805  			}
5cd17569f Eric W. Biederman 2007-12-04  1806
fea9d1755 Oleg Nesterov     2008-02-08  1807  			p->signal->leader_pid = pid;
9c9f4ded9 Alan Cox          2008-10-13  1808  			p->signal->tty = tty_kref_get(current->signal->tty);
9cd80bbb0 Oleg Nesterov     2009-12-17  1809  			list_add_tail(&p->sibling, &p->real_parent->children);
5e85d4abe Eric W. Biederman 2006-04-18  1810  			list_add_tail_rcu(&p->tasks, &init_task.tasks);
819077398 Oleg Nesterov     2013-07-03  1811  			attach_pid(p, PIDTYPE_PGID);
819077398 Oleg Nesterov     2013-07-03  1812  			attach_pid(p, PIDTYPE_SID);
909ea9646 Christoph Lameter 2010-12-08  1813  			__this_cpu_inc(process_counts);
80628ca06 Oleg Nesterov     2013-07-03  1814  		} else {
80628ca06 Oleg Nesterov     2013-07-03  1815  			current->signal->nr_threads++;
80628ca06 Oleg Nesterov     2013-07-03  1816  			atomic_inc(&current->signal->live);
80628ca06 Oleg Nesterov     2013-07-03  1817  			atomic_inc(&current->signal->sigcnt);
80628ca06 Oleg Nesterov     2013-07-03  1818  			list_add_tail_rcu(&p->thread_group,
80628ca06 Oleg Nesterov     2013-07-03  1819  					  &p->group_leader->thread_group);
0c740d0af Oleg Nesterov     2014-01-21  1820  			list_add_tail_rcu(&p->thread_node,
0c740d0af Oleg Nesterov     2014-01-21  1821  					  &p->signal->thread_head);
^1da177e4 Linus Torvalds    2005-04-16  1822  		}
819077398 Oleg Nesterov     2013-07-03  1823  		attach_pid(p, PIDTYPE_PID);
^1da177e4 Linus Torvalds    2005-04-16  1824  		nr_threads++;
73b9ebfe1 Oleg Nesterov     2006-03-28  1825  	}
73b9ebfe1 Oleg Nesterov     2006-03-28  1826
^1da177e4 Linus Torvalds    2005-04-16  1827  	total_forks++;
3f17da699 Oleg Nesterov     2006-02-15  1828  	spin_unlock(&current->sighand->siglock);
4af4206be Oleg Nesterov     2014-04-13  1829  	syscall_tracepoint_update(p);
^1da177e4 Linus Torvalds    2005-04-16  1830  	write_unlock_irq(&tasklist_lock);
4af4206be Oleg Nesterov     2014-04-13  1831
c13cf856c Andrew Morton     2005-11-28  1832  	proc_fork_connector(p);
b53202e63 Oleg Nesterov     2015-12-03  1833  	cgroup_post_fork(p);
257058ae2 Tejun Heo         2011-12-12  1834  	threadgroup_change_end(current);
cdd6c482c Ingo Molnar       2009-09-21  1835  	perf_event_fork(p);
43d2b1132 KAMEZAWA Hiroyuki 2012-01-10  1836
43d2b1132 KAMEZAWA Hiroyuki 2012-01-10  1837  	trace_task_newtask(p, clone_flags);
3ab679661 Oleg Nesterov     2013-10-16  1838  	uprobe_copy_process(p, clone_flags);
43d2b1132 KAMEZAWA Hiroyuki 2012-01-10  1839
^1da177e4 Linus Torvalds    2005-04-16  1840  	return p;
^1da177e4 Linus Torvalds    2005-04-16  1841
7e47682ea Aleksa Sarai      2015-06-09  1842  bad_fork_cancel_cgroup:
b53202e63 Oleg Nesterov     2015-12-03  1843  	cgroup_cancel_fork(p);
425fb2b4b Pavel Emelyanov   2007-10-18  1844  bad_fork_free_pid:
568ac8882 Balbir Singh      2016-08-10  1845  	threadgroup_change_end(current);
425fb2b4b Pavel Emelyanov   2007-10-18  1846  	if (pid != &init_struct_pid)
425fb2b4b Pavel Emelyanov   2007-10-18  1847  		free_pid(pid);
0740aa5f6 Jiri Slaby        2016-05-20  1848  bad_fork_cleanup_thread:
0740aa5f6 Jiri Slaby        2016-05-20  1849  	exit_thread(p);
fd0928df9 Jens Axboe        2008-01-24  1850  bad_fork_cleanup_io:
b69f22920 Louis Rilling     2009-12-04  1851  	if (p->io_context)
b69f22920 Louis Rilling     2009-12-04  1852  		exit_io_context(p);
ab516013a Serge E. Hallyn   2006-10-02  1853  bad_fork_cleanup_namespaces:
444f378b2 Linus Torvalds    2007-01-30  1854  	exit_task_namespaces(p);
^1da177e4 Linus Torvalds    2005-04-16  1855  bad_fork_cleanup_mm:
c9f01245b David Rientjes    2011-10-31  1856  	if (p->mm)
^1da177e4 Linus Torvalds    2005-04-16  1857  		mmput(p->mm);
^1da177e4 Linus Torvalds    2005-04-16  1858  bad_fork_cleanup_signal:
4ab6c0833 Oleg Nesterov     2009-08-26  1859  	if (!(clone_flags & CLONE_THREAD))
1c5354de9 Mike Galbraith    2011-01-05  1860  		free_signal_struct(p->signal);
^1da177e4 Linus Torvalds    2005-04-16  1861  bad_fork_cleanup_sighand:
a7e5328a0 Oleg Nesterov     2006-03-28  1862  	__cleanup_sighand(p->sighand);
^1da177e4 Linus Torvalds    2005-04-16  1863  bad_fork_cleanup_fs:
^1da177e4 Linus Torvalds    2005-04-16  1864  	exit_fs(p); /* blocking */
^1da177e4 Linus Torvalds    2005-04-16  1865  bad_fork_cleanup_files:
^1da177e4 Linus Torvalds    2005-04-16  1866  	exit_files(p); /* blocking */
^1da177e4 Linus Torvalds    2005-04-16  1867  bad_fork_cleanup_semundo:
^1da177e4 Linus Torvalds    2005-04-16  1868  	exit_sem(p);
^1da177e4 Linus Torvalds    2005-04-16  1869  bad_fork_cleanup_audit:
^1da177e4 Linus Torvalds    2005-04-16  1870  	audit_free(p);
6c72e3501 Peter Zijlstra    2014-10-02  1871  bad_fork_cleanup_perf:
cdd6c482c Ingo Molnar       2009-09-21  1872  	perf_event_free_task(p);
6c72e3501 Peter Zijlstra    2014-10-02  1873  bad_fork_cleanup_policy:
^1da177e4 Linus Torvalds    2005-04-16  1874  #ifdef CONFIG_NUMA
f0be3d32b Lee Schermerhorn  2008-04-28  1875  	mpol_put(p->mempolicy);
e8604cb43 Li Zefan          2014-03-28  1876  bad_fork_cleanup_threadgroup_lock:
^1da177e4 Linus Torvalds    2005-04-16  1877  #endif
35df17c57 Shailabh Nagar    2006-08-31  1878  	delayacct_tsk_free(p);
^1da177e4 Linus Torvalds    2005-04-16  1879  bad_fork_cleanup_count:
d84f4f992 David Howells     2008-11-14  1880  	atomic_dec(&p->cred->user->processes);
e0e817392 David Howells     2009-09-02  1881  	exit_creds(p);
^1da177e4 Linus Torvalds    2005-04-16  1882  bad_fork_free:
405c07597 Andy Lutomirski   2016-10-31  1883  	p->state = TASK_DEAD;
68f24b08e Andy Lutomirski   2016-09-15  1884  	put_task_stack(p);
^1da177e4 Linus Torvalds    2005-04-16  1885  	free_task(p);
fe7d37d1f Oleg Nesterov     2006-01-08  1886  fork_out:
fe7d37d1f Oleg Nesterov     2006-01-08 @1887  	return ERR_PTR(retval);
^1da177e4 Linus Torvalds    2005-04-16  1888  }
^1da177e4 Linus Torvalds    2005-04-16  1889
f106eee10 Oleg Nesterov     2010-05-26  1890  static inline void init_idle_pids(struct pid_link *links)

:::::: The code at line 1887 was first introduced by commit
:::::: fe7d37d1fbf8ffe78abd72728b24fb0c64f7af55 [PATCH] copy_process: error path cleanup

:::::: TO: Oleg Nesterov <oleg@tv-sign.ru>
:::::: CC: Linus Torvalds <torvalds@g5.osdl.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
