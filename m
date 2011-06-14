Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8CCCF6B0012
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 07:48:57 -0400 (EDT)
Date: 14 Jun 2011 07:48:54 -0400
Message-ID: <20110614114854.31801.qmail@science.horizon.com>
From: "George Spelvin" <linux@horizon.com>
Subject: 3.0-rc1 stuck process in munmap()
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux@horizon.com, linux-mm@kvack.org

3.0-rc1 kernel, with 7f58aabc reverted.  32-bit x86 kernel. Core 2 duo
laptop w/ 2 GB RAM.  X86_32_SMP=y, NO_HZ=y, PREEMPT_VOLUNTARY=y, HZ=300.
Came out of a few days' suspend, browsed the net a bit, ran vlc, and
discovered that switching back to the Firefox screen, it didn't refersh.
I wasn't using it actively at the time of the lockup.

It's been stuck since last night in the D state, and a "ps axf" also
got stuck.  I'm going to try rebooting with -rc3 and see if the
problem recurs.

Not a great bug report, but I have backtraces and I thought I'd throw it
out here anyway.

INFO: task firefox-bin:26283 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
firefox-bin     D f5959500     0 26283   2914 0x00000000
 f34246e0 00000086 00000000 f5959500 00000000 00000000 e012df04 00000000
 c14f22c0 f3424854 c14f22c0 f69dcf20 f69dcf40 f69dce60 f69dce80 f69dcea0
 f69dcec0 f69dcee0 000007fb f2321b00 4b800000 4b800000 00000000 c107346b
Call Trace:
 [<c107346b>] ? sys_madvise+0x42b/0x46c
 [<c130491d>] ? rwsem_down_failed_common+0xa1/0xc9
 [<c13049a2>] ? call_rwsem_down_write_failed+0x6/0x8
 [<c1304419>] ? down_write+0x1c/0x1e
 [<c10781f2>] ? sys_munmap+0x18/0x35
 [<c1305310>] ? sysenter_do_call+0x12/0x26
 [<c1300000>] ? wait_for_panic+0x25/0x36
INFO: task firefox-bin:26283 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
firefox-bin     D f5959500     0 26283   2914 0x00000000
 f34246e0 00000086 00000000 f5959500 00000000 00000000 e012df04 00000000
 c14f22c0 f3424854 c14f22c0 f69dcf20 f69dcf40 f69dce60 f69dce80 f69dcea0
 f69dcec0 f69dcee0 000007fb f2321b00 4b800000 4b800000 00000000 c107346b
Call Trace:
 [<c107346b>] ? sys_madvise+0x42b/0x46c
 [<c130491d>] ? rwsem_down_failed_common+0xa1/0xc9
 [<c13049a2>] ? call_rwsem_down_write_failed+0x6/0x8
 [<c1304419>] ? down_write+0x1c/0x1e
 [<c10781f2>] ? sys_munmap+0x18/0x35
 [<c1305310>] ? sysenter_do_call+0x12/0x26
 [<c1300000>] ? wait_for_panic+0x25/0x36
INFO: task firefox-bin:27872 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
firefox-bin     D d732bf58     0 27872   2914 0x00000000
 f3424370 00000086 00000002 d732bf58 00000000 00000000 00000000 00000001
 c14f22c0 f34244e4 c14f22c0 00000000 00000000 b147d7c0 00000000 00000002
 00000001 f35bfc88 000007fb e0252b00 34cff000 34cff000 00000000 c107346b
Call Trace:
 [<c107346b>] ? sys_madvise+0x42b/0x46c
 [<c130491d>] ? rwsem_down_failed_common+0xa1/0xc9
 [<c13049a2>] ? call_rwsem_down_write_failed+0x6/0x8
 [<c1304419>] ? down_write+0x1c/0x1e
 [<c10781f2>] ? sys_munmap+0x18/0x35
 [<c1305310>] ? sysenter_do_call+0x12/0x26
 [<c1300000>] ? wait_for_panic+0x25/0x36
INFO: task ps:30517 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
ps              D d7325e80     0 30517  30515 0x00000000
 f612a940 00000086 00000002 d7325e80 c13129c0 c56c4080 00000000 00000000
 c14f22c0 f612aab4 c14f22c0 00000001 c1065a63 00000001 00000041 00007815
 00000001 00000246 00000246 00000001 00000041 c56c4080 00000000 00000001
Call Trace:
 [<c1065a63>] ? zone_watermark_ok+0x2a/0x30
 [<c130491d>] ? rwsem_down_failed_common+0xa1/0xc9
 [<c1304997>] ? call_rwsem_down_read_failed+0x7/0xc
 [<c130442f>] ? down_read+0x14/0x16
 [<c1075f48>] ? __access_remote_vm+0x1f/0x14d
 [<c107625b>] ? access_process_vm+0x3e/0x51
 [<c10b6a90>] ? proc_pid_cmdline+0x58/0xc8
 [<c10b75d0>] ? proc_info_read+0x44/0x8c
 [<c10b758c>] ? proc_single_show+0x59/0x59
 [<c1088e58>] ? vfs_read+0x75/0x9b
 [<c1088ebf>] ? sys_read+0x41/0x64
 [<c1304bdd>] ? syscall_call+0x7/0xb
INFO: task firefox-bin:27872 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
firefox-bin     D d732bf58     0 27872   2914 0x00000000
 f3424370 00000086 00000002 d732bf58 00000000 00000000 00000000 00000001
 c14f22c0 f34244e4 c14f22c0 00000000 00000000 b147d7c0 00000000 00000002
 00000001 f35bfc88 000007fb e0252b00 34cff000 34cff000 00000000 c107346b
Call Trace:
 [<c107346b>] ? sys_madvise+0x42b/0x46c
 [<c130491d>] ? rwsem_down_failed_common+0xa1/0xc9
 [<c13049a2>] ? call_rwsem_down_write_failed+0x6/0x8
 [<c1304419>] ? down_write+0x1c/0x1e
 [<c10781f2>] ? sys_munmap+0x18/0x35
 [<c1305310>] ? sysenter_do_call+0x12/0x26
 [<c1300000>] ? wait_for_panic+0x25/0x36
INFO: task ps:30517 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
ps              D d7325e80     0 30517  30515 0x00000000
 f612a940 00000086 00000002 d7325e80 c13129c0 c56c4080 00000000 00000000
 c14f22c0 f612aab4 c14f22c0 00000001 c1065a63 00000001 00000041 00007815
 00000001 00000246 00000246 00000001 00000041 c56c4080 00000000 00000001
Call Trace:
 [<c1065a63>] ? zone_watermark_ok+0x2a/0x30
 [<c130491d>] ? rwsem_down_failed_common+0xa1/0xc9
 [<c1304997>] ? call_rwsem_down_read_failed+0x7/0xc
 [<c130442f>] ? down_read+0x14/0x16
 [<c1075f48>] ? __access_remote_vm+0x1f/0x14d
 [<c107625b>] ? access_process_vm+0x3e/0x51
 [<c10b6a90>] ? proc_pid_cmdline+0x58/0xc8
 [<c10b75d0>] ? proc_info_read+0x44/0x8c
 [<c10b758c>] ? proc_single_show+0x59/0x59
 [<c1088e58>] ? vfs_read+0x75/0x9b
 [<c1088ebf>] ? sys_read+0x41/0x64
 [<c1304bdd>] ? syscall_call+0x7/0xb
INFO: task firefox-bin:27872 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
firefox-bin     D d732bf58     0 27872   2914 0x00000000
 f3424370 00000086 00000002 d732bf58 00000000 00000000 00000000 00000001
 c14f22c0 f34244e4 c14f22c0 00000000 00000000 b147d7c0 00000000 00000002
 00000001 f35bfc88 000007fb e0252b00 34cff000 34cff000 00000000 c107346b
Call Trace:
 [<c107346b>] ? sys_madvise+0x42b/0x46c
 [<c130491d>] ? rwsem_down_failed_common+0xa1/0xc9
 [<c13049a2>] ? call_rwsem_down_write_failed+0x6/0x8
 [<c1304419>] ? down_write+0x1c/0x1e
 [<c10781f2>] ? sys_munmap+0x18/0x35
 [<c1305310>] ? sysenter_do_call+0x12/0x26
 [<c1300000>] ? wait_for_panic+0x25/0x36
INFO: task ps:30517 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
ps              D d7325e80     0 30517  30515 0x00000000
 f612a940 00000086 00000002 d7325e80 c13129c0 c56c4080 00000000 00000000
 c14f22c0 f612aab4 c14f22c0 00000001 c1065a63 00000001 00000041 00007815
 00000001 00000246 00000246 00000001 00000041 c56c4080 00000000 00000001
Call Trace:
 [<c1065a63>] ? zone_watermark_ok+0x2a/0x30
 [<c130491d>] ? rwsem_down_failed_common+0xa1/0xc9
 [<c1304997>] ? call_rwsem_down_read_failed+0x7/0xc
 [<c130442f>] ? down_read+0x14/0x16
 [<c1075f48>] ? __access_remote_vm+0x1f/0x14d
 [<c107625b>] ? access_process_vm+0x3e/0x51
 [<c10b6a90>] ? proc_pid_cmdline+0x58/0xc8
 [<c10b75d0>] ? proc_info_read+0x44/0x8c
 [<c10b758c>] ? proc_single_show+0x59/0x59
 [<c1088e58>] ? vfs_read+0x75/0x9b
 [<c1088ebf>] ? sys_read+0x41/0x64
 [<c1304bdd>] ? syscall_call+0x7/0xb
INFO: task firefox-bin:27872 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
firefox-bin     D d732bf58     0 27872   2914 0x00000000
 f3424370 00000086 00000002 d732bf58 00000000 00000000 00000000 00000001
 c14f22c0 f34244e4 c14f22c0 00000000 00000000 b147d7c0 00000000 00000002
 00000001 f35bfc88 000007fb e0252b00 34cff000 34cff000 00000000 c107346b
Call Trace:
 [<c107346b>] ? sys_madvise+0x42b/0x46c
 [<c130491d>] ? rwsem_down_failed_common+0xa1/0xc9
 [<c13049a2>] ? call_rwsem_down_write_failed+0x6/0x8
 [<c1304419>] ? down_write+0x1c/0x1e
 [<c10781f2>] ? sys_munmap+0x18/0x35
 [<c1305310>] ? sysenter_do_call+0x12/0x26
 [<c1300000>] ? wait_for_panic+0x25/0x36
INFO: task ps:30517 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
ps              D d7325e80     0 30517  30515 0x00000000
 f612a940 00000086 00000002 d7325e80 c13129c0 c56c4080 00000000 00000000
 c14f22c0 f612aab4 c14f22c0 00000001 c1065a63 00000001 00000041 00007815
 00000001 00000246 00000246 00000001 00000041 c56c4080 00000000 00000001
Call Trace:
 [<c1065a63>] ? zone_watermark_ok+0x2a/0x30
 [<c130491d>] ? rwsem_down_failed_common+0xa1/0xc9
 [<c1304997>] ? call_rwsem_down_read_failed+0x7/0xc
 [<c130442f>] ? down_read+0x14/0x16
 [<c1075f48>] ? __access_remote_vm+0x1f/0x14d
 [<c107625b>] ? access_process_vm+0x3e/0x51
 [<c10b6a90>] ? proc_pid_cmdline+0x58/0xc8
 [<c10b75d0>] ? proc_info_read+0x44/0x8c
 [<c10b758c>] ? proc_single_show+0x59/0x59
 [<c1088e58>] ? vfs_read+0x75/0x9b
 [<c1088ebf>] ? sys_read+0x41/0x64
 [<c1304bdd>] ? syscall_call+0x7/0xb
udevd[5382]: starting version 171

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
