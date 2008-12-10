Date: Wed, 10 Dec 2008 16:41:26 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][RFT] memcg fix cgroup_mutex deadlock when cpuset reclaims
 memory
Message-Id: <20081210164126.8b3be761.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20081210151948.9a83f70a.nishimura@mxp.nes.nec.co.jp>
References: <20081210051947.GH7593@balbir.in.ibm.com>
	<20081210151948.9a83f70a.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: menage@google.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Miyakawa <dmiyakawa@google.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

On Wed, 10 Dec 2008 15:19:48 +0900, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> On Wed, 10 Dec 2008 10:49:47 +0530, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > Hi,
> > 
> > Here is a proposed fix for the memory controller cgroup_mutex deadlock
> > reported. It is lightly tested and reviewed. I need help with review
> > and test. Is the reported deadlock reproducible after this patch? A
> > careful review of the cpuset impact will also be highly appreciated.
> > 
> > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> > 
> > cpuset_migrate_mm() holds cgroup_mutex throughout the duration of
> > do_migrate_pages(). The issue with that is that
> > 
> > 1. It can lead to deadlock with memcg, as do_migrate_pages()
> >    enters reclaim
> > 2. It can lead to long latencies, preventing users from creating/
> >    destroying other cgroups anywhere else
> > 
> > The patch holds callback_mutex through the duration of cpuset_migrate_mm() and
> > gives up cgroup_mutex while doing so.
> > 
> I agree changing cpuset_migrate_mm not to hold cgroup_mutex to fix the dead lock
> is one choice, and it looks good to me at the first impression.
> 
> But I'm not sure it's good to change cpuset(other subsystem) code because of memcg.
> 
> Anyway, I'll test this patch and report the result tomorrow.
> (Sorry, I don't have enough time today.)
> 
Unfortunately, this patch doesn't seem enough.

This patch can fix dead lock caused by "circular lock of cgroup_mutex",
but cannot that of caused by "race between page reclaim and cpuset_attach(mpol_rebind_mm)".

(The dead lock I fixed in memcg-avoid-dead-lock-caused-by-race-between-oom-and-cpuset_attach.patch
was caused by "race between memcg's oom and mpol_rebind_mm, and was independent of hierarchy.)

I attach logs I got in testing this patch.


Thanks,
Daisuke Nishimura.

===
INFO: task automount:23438 blocked for more than 480 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
automount     D ffff88010ae963c0     0 23438      1
 ffff8803ab8f9300 0000000000000046 0000000000000000 0000000000000000
 ffff88010fb72600 ffff8803ab8f9670 0000000d00000000 0000000100026d3a
 ffffffffffffffff ffffffffffffffff ffffffffffffffff 7fffffffffffffff
Call Trace:
 [<ffffffff802699c3>] cgroup_show_options+0x20/0xa3
 [<ffffffff804ce493>] mutex_lock_nested+0x188/0x2b2
 [<ffffffff802699c3>] cgroup_show_options+0x20/0xa3
 [<ffffffff802c6490>] mntput_no_expire+0x1e/0x139
 [<ffffffff802c85ab>] seq_escape+0x3a/0xb8
 [<ffffffff802699c3>] cgroup_show_options+0x20/0xa3
 [<ffffffff802c80d6>] show_vfsmnt+0xd7/0xf5
 [<ffffffff802c8d2a>] seq_read+0x20c/0x2e5
 [<ffffffff802b2723>] vfs_read+0xaa/0x133
 [<ffffffff802b3234>] fget_light+0x49/0xe1
 [<ffffffff802b2a18>] sys_read+0x45/0x6e
 [<ffffffff8020bedb>] system_call_fastpath+0x16/0x1b
INFO: lockdep is turned off.
INFO: task automount:24873 blocked for more than 480 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
automount     D ffff88010ae963c0     0 24873      1
 ffff8803ab8fcc00 0000000000000046 0000000000000000 0000000000000000
 ffff8803afbe4c00 ffff8803ab8fcf70 0000000f00000000 0000000100029028
 ffffffffffffffff ffffffffffffffff ffffffffffffffff 7fffffffffffffff
Call Trace:
 [<ffffffff802699c3>] cgroup_show_options+0x20/0xa3
 [<ffffffff804ce493>] mutex_lock_nested+0x188/0x2b2
 [<ffffffff802699c3>] cgroup_show_options+0x20/0xa3
 [<ffffffff802c6490>] mntput_no_expire+0x1e/0x139
 [<ffffffff802c85ab>] seq_escape+0x3a/0xb8
 [<ffffffff802699c3>] cgroup_show_options+0x20/0xa3
 [<ffffffff802c80d6>] show_vfsmnt+0xd7/0xf5
 [<ffffffff802c8d2a>] seq_read+0x20c/0x2e5
 [<ffffffff802b2723>] vfs_read+0xaa/0x133
 [<ffffffff802b3234>] fget_light+0x49/0xe1
 [<ffffffff802b2a18>] sys_read+0x45/0x6e
 [<ffffffff8020bedb>] system_call_fastpath+0x16/0x1b
INFO: lockdep is turned off.
INFO: task mmapstress10:21307 blocked for more than 480 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
mmapstress10  D ffff88010acb84c0     0 21307  14494
 ffff88010ad8df00 0000000000000046 0000000000000000 0000000000000000
 ffff88010fada600 ffff88010ad8e270 0000000700000000 000000010002983e
 ffffffffffffffff ffffffffffffffff ffffffffffffffff 7fffffffffffffff
Call Trace:
 [<ffffffff802ae443>] mem_cgroup_get_first_node+0x29/0x8a
 [<ffffffff804ce493>] mutex_lock_nested+0x188/0x2b2
 [<ffffffff802ae443>] mem_cgroup_get_first_node+0x29/0x8a
 [<ffffffff802ae443>] mem_cgroup_get_first_node+0x29/0x8a
 [<ffffffff802ae4f0>] mem_cgroup_hierarchical_reclaim+0x4c/0xc6
 [<ffffffff802ae9f4>] __mem_cgroup_try_charge+0x151/0x1d1
 [<ffffffff802ae8e3>] __mem_cgroup_try_charge+0x40/0x1d1
 [<ffffffff802af2d8>] mem_cgroup_charge_common+0x46/0x72
 [<ffffffff80291440>] do_wp_page+0x45a/0x646
 [<ffffffff80292d85>] handle_mm_fault+0x6a8/0x737
 [<ffffffff80292db6>] handle_mm_fault+0x6d9/0x737
 [<ffffffff804d2371>] do_page_fault+0x3ab/0x753
 [<ffffffff804d034f>] page_fault+0x1f/0x30
INFO: lockdep is turned off.
INFO: task shmem_test_02:22746 blocked for more than 480 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
shmem_test_02 D ffff88010ac81c80     0 22746  14216
 ffff8800bf1fa600 0000000000000046 0000000000000000 0000000000000000
 ffff88010fa9a600 ffff8800bf1fa970 0000000400000000 000000010002593a
 ffffffffffffffff ffffffffffffffff ffffffffffffffff 7fffffffffffffff
Call Trace:
 [<ffffffff802ae443>] mem_cgroup_get_first_node+0x29/0x8a
 [<ffffffff804ce493>] mutex_lock_nested+0x188/0x2b2
 [<ffffffff802ae443>] mem_cgroup_get_first_node+0x29/0x8a
 [<ffffffff802ae443>] mem_cgroup_get_first_node+0x29/0x8a
 [<ffffffff802ae4f0>] mem_cgroup_hierarchical_reclaim+0x4c/0xc6
 [<ffffffff802ae9f4>] __mem_cgroup_try_charge+0x151/0x1d1
 [<ffffffff802ae8e3>] __mem_cgroup_try_charge+0x40/0x1d1
 [<ffffffff802af2d8>] mem_cgroup_charge_common+0x46/0x72
 [<ffffffff8028c9fe>] shmem_getpage+0x6ae/0x851
 [<ffffffff8022e1f0>] task_rq_lock+0x44/0x78
 [<ffffffff804cf73d>] trace_hardirqs_on_thunk+0x3a/0x3f
 [<ffffffff804cf73d>] trace_hardirqs_on_thunk+0x3a/0x3f
 [<ffffffff8020e304>] do_IRQ+0x139/0x15d
 [<ffffffff802c7b8d>] mnt_want_write+0x6e/0x76
 [<ffffffff802c604c>] mnt_drop_write+0x25/0xec
 [<ffffffff8028cc3b>] shmem_fault+0x3a/0x5f
 [<ffffffff802909be>] __do_fault+0x51/0x402
 [<ffffffff8029289e>] handle_mm_fault+0x1c1/0x737
 [<ffffffff804d2371>] do_page_fault+0x3ab/0x753
 [<ffffffff804d034f>] page_fault+0x1f/0x30
INFO: lockdep is turned off.
INFO: task move.sh:22750 blocked for more than 480 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
move.sh       D ffff88010b4ab900     0 22750  19661
 ffff8803ab8fdf00 0000000000000046 0000000000000000 0000000000000002
 ffff8803afbe4c00 ffff8803ab8fe270 0000000f00000000 0000000100025624
 ffffffffffffffff ffffffffffffffff ffffffffffffffff 7fffffffffffffff
Call Trace:
 [<ffffffff804cf64e>] __down_write_nested+0x7e/0x96
 [<ffffffff804ceb34>] down_write+0x64/0x75
 [<ffffffff802a43c0>] mpol_rebind_mm+0x16/0x3f
 [<ffffffff802a43c0>] mpol_rebind_mm+0x16/0x3f
 [<ffffffff8026e06a>] cpuset_attach+0x7d/0xa6
 [<ffffffff8026b05d>] cgroup_attach_task+0x33d/0x397
 [<ffffffff8026b1b1>] cgroup_tasks_write+0xfa/0x11e
 [<ffffffff8026b0f0>] cgroup_tasks_write+0x39/0x11e
 [<ffffffff8026b66e>] cgroup_file_write+0xed/0x20b
 [<ffffffff802b25f0>] vfs_write+0xad/0x136
 [<ffffffff802b2a86>] sys_write+0x45/0x6e
 [<ffffffff8020bedb>] system_call_fastpath+0x16/0x1b
INFO: lockdep is turned off.
INFO: task udev_run_devd:22758 blocked for more than 480 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
udev_run_devd D ffff88010eb39c80     0 22758      1
 ffff8801091e8000 0000000000000046 0000000000000000 0000000000000000
 ffff88010fb4cc00 ffff8801091e8370 0000000c00000000 0000000100024ffd
 ffffffffffffffff ffffffffffffffff ffffffffffffffff 7fffffffffffffff
Call Trace:
 [<ffffffff802699c3>] cgroup_show_options+0x20/0xa3
 [<ffffffff804ce493>] mutex_lock_nested+0x188/0x2b2
 [<ffffffff802699c3>] cgroup_show_options+0x20/0xa3
 [<ffffffff802c6490>] mntput_no_expire+0x1e/0x139
 [<ffffffff802c85ab>] seq_escape+0x3a/0xb8
 [<ffffffff802699c3>] cgroup_show_options+0x20/0xa3
 [<ffffffff802c80d6>] show_vfsmnt+0xd7/0xf5
 [<ffffffff802c8d2a>] seq_read+0x20c/0x2e5
 [<ffffffff802b2723>] vfs_read+0xaa/0x133
 [<ffffffff802b2a18>] sys_read+0x45/0x6e
 [<ffffffff8020bedb>] system_call_fastpath+0x16/0x1b
INFO: lockdep is turned off.
INFO: task ls:22850 blocked for more than 480 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
ls            D ffff88010e8897c0     0 22850   8012
 ffff8801091edf00 0000000000000046 0000000000000000 0000000000000000
 ffff88010fb22600 ffff8801091ee270 0000000a00000000 0000000100025a97
 ffffffffffffffff ffffffffffffffff ffffffffffffffff 7fffffffffffffff
Call Trace:
 [<ffffffff802699c3>] cgroup_show_options+0x20/0xa3
 [<ffffffff804ce493>] mutex_lock_nested+0x188/0x2b2
 [<ffffffff802699c3>] cgroup_show_options+0x20/0xa3
 [<ffffffff802c6490>] mntput_no_expire+0x1e/0x139
 [<ffffffff802c85ab>] seq_escape+0x3a/0xb8
 [<ffffffff802699c3>] cgroup_show_options+0x20/0xa3
 [<ffffffff802c80d6>] show_vfsmnt+0xd7/0xf5
 [<ffffffff802c8d2a>] seq_read+0x20c/0x2e5
 [<ffffffff802b2723>] vfs_read+0xaa/0x133
 [<ffffffff802b2a18>] sys_read+0x45/0x6e
 [<ffffffff8020bedb>] system_call_fastpath+0x16/0x1b
INFO: lockdep is turned off.
INFO: task multipath:27599 blocked for more than 480 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
multipath     D ffff88010b4af200     0 27599      1
 ffff8800ba971300 0000000000000046 0000000000000000 0000000000000000
 ffff8803afbe4c00 ffff8800ba971670 0000000f00000000 0000000100051678
 ffffffffffffffff ffffffffffffffff ffffffffffffffff 7fffffffffffffff
Call Trace:
 [<ffffffff802699c3>] cgroup_show_options+0x20/0xa3
 [<ffffffff804ce493>] mutex_lock_nested+0x188/0x2b2
 [<ffffffff802699c3>] cgroup_show_options+0x20/0xa3
 [<ffffffff802c6490>] mntput_no_expire+0x1e/0x139
 [<ffffffff802c85ab>] seq_escape+0x3a/0xb8
 [<ffffffff802699c3>] cgroup_show_options+0x20/0xa3
 [<ffffffff802c80d6>] show_vfsmnt+0xd7/0xf5
 [<ffffffff802c8d2a>] seq_read+0x20c/0x2e5
 [<ffffffff802b2723>] vfs_read+0xaa/0x133
 [<ffffffff802b2a18>] sys_read+0x45/0x6e
 [<ffffffff8020bedb>] system_call_fastpath+0x16/0x1b
INFO: lockdep is turned off.
INFO: task udev_run_hotplu:27601 blocked for more than 480 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
udev_run_hotp D ffff88010e476880     0 27601      1
 ffff8801091ea600 0000000000000046 0000000000000000 0000000000000000
 ffff88010fb48000 ffff8801091ea970 0000000b00000000 0000000100051867
 ffffffffffffffff ffffffffffffffff ffffffffffffffff 7fffffffffffffff
Call Trace:
 [<ffffffff802699c3>] cgroup_show_options+0x20/0xa3
 [<ffffffff804ce493>] mutex_lock_nested+0x188/0x2b2
 [<ffffffff802699c3>] cgroup_show_options+0x20/0xa3
 [<ffffffff802c6490>] mntput_no_expire+0x1e/0x139
 [<ffffffff802c85ab>] seq_escape+0x3a/0xb8
 [<ffffffff802699c3>] cgroup_show_options+0x20/0xa3
 [<ffffffff802c80d6>] show_vfsmnt+0xd7/0xf5
 [<ffffffff802c8d2a>] seq_read+0x20c/0x2e5
 [<ffffffff802b2723>] vfs_read+0xaa/0x133
 [<ffffffff802b2a18>] sys_read+0x45/0x6e
 [<ffffffff8020bedb>] system_call_fastpath+0x16/0x1b
INFO: lockdep is turned off.
===

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
