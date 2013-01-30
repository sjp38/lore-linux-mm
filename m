Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 3377C6B0005
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 01:57:06 -0500 (EST)
Date: Wed, 30 Jan 2013 01:57:05 -0500 (EST)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <561898288.11015388.1359529025256.JavaMail.root@redhat.com>
In-Reply-To: <1022938540.1925160.1357725053304.JavaMail.root@redhat.com>
Subject: Re: oom caused disk corruption on 3.7.1
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: stable@vger.kernel.org
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>



----- Original Message -----
> From: "CAI Qian" <caiqian@redhat.com>
> To: "linux-mm" kvack.org>
> Cc: stable@vger.kernel.org, "linux-kernel" vger.kernel.org>
> Sent: Wednesday, January 9, 2013 5:50:53 PM
> Subject: oom caused disk corruption on 3.7.1
> 
> While doing oom testing on a power7 system with swapping,
> it was swallowed a panic on v3.7.1 below. Without a swap device,
> it is running fine. v3.0 has the same problem.
This is weird that if turned on those options,
CONFIG_PCIEPORTBUS=y
CONFIG_PCIEAER=y

it turns out to be fine except some warnings which looks like
better than a panic.
INFO: task (tmpfiles):5456 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
(tmpfiles)      D 00003fff877fb508     0  5456      1 0x00000080
Call Trace:
[c00000001cf76a30] [c0000000010a2180] jiffies+0x0/0x80 (unreliable)
[c00000001cf76c00] [c000000000014960] .__switch_to+0x110/0x240
[c00000001cf76cb0] [c0000000006b1cc0] .__schedule+0x3c0/0x8b0
[c00000001cf76f30] [c0000000006affb4] .schedule_timeout+0x1e4/0x2d0
[c00000001cf77030] [c0000000006b23fc] .wait_for_common+0x18c/0x200
[c00000001cf77110] [c0000000002863a8] .xfs_buf_iowait+0x88/0x150
[c00000001cf771a0] [c000000000286700] .xfs_buf_read_map+0xd0/0x170
[c00000001cf77240] [c0000000002f4074] .xfs_trans_read_buf_map+0x204/0x570
[c00000001cf77300] [c0000000002c5940] .xfs_da_read_buf+0x100/0x250
[c00000001cf773f0] [c0000000002c7098] .xfs_da_node_lookup_int+0xc8/0x440
[c00000001cf774c0] [c0000000002d0c60] .xfs_dir2_node_lookup+0x70/0x1d0
[c00000001cf77570] [c0000000002c8fe4] .xfs_dir_lookup+0x214/0x230
[c00000001cf776a0] [c00000000029f068] .xfs_lookup+0xb8/0x1a0
[c00000001cf77760] [c000000000293f50] .xfs_vn_lookup+0x60/0xd0
[c00000001cf77800] [c0000000001db454] .lookup_real+0x44/0xa0
[c00000001cf77890] [c0000000001e16e8] .do_last+0xad8/0xe00
[c00000001cf779c0] [c0000000001e1afc] .path_openat+0xec/0x5f0
[c00000001cf77ae0] [c0000000001e2450] .do_filp_open+0x40/0xb0
[c00000001cf77c10] [c0000000001d6308] .open_exec+0x48/0x170
[c00000001cf77cc0] [c0000000001d7ae0] .do_execve_common.isra.19+0x240/0x4e0
[c00000001cf77da0] [c0000000001d8100] .SyS_execve+0x50/0x90
[c00000001cf77e30] [c0000000000097d4] syscall_exit+0x0/0x94
> 
> Test case is here,
> http://tinyurl.com/bzzmrb8
> 
> ...
> [  763.781571] Write-error on swap-device (253:0:7545984)
> [  763.781573] sd 0:0:1:0: rejecting I/O to offline device
> [  763.781574] Write-error on swap-device (253:0:7546240)
> [  763.781576] sd 0:0:1:0: rejecting I/O to offline device
> [  763.781577] Kernel panic - not syncing: Attempted to kill init!
> exitcode=0x0000000b
> [  763.781578] Write-error on swap-device (253:0:7546496)
> [  763.781579] Call Trace:
> [  763.781580] sd 0:0:1:0: rejecting I/O to offline device
> [  763.781590] [c0000002eac83870] [c000000000015884]
> .show_stack+0x74/0x1b0 (unreliable)
> [  763.781595] [c0000002eac83920] [c000000000721d28]
> .panic+0xe4/0x264
> [  763.781598] [c0000002eac839c0] [c0000000000886e4]
> .do_exit+0x954/0x960
> [  763.781601] [c0000002eac83ac0] [c0000000000889d4]
> .do_group_exit+0x54/0xf0
> [  763.781604] [c0000002eac83b50] [c00000000009be28]
> .get_signal_to_deliver+0x1f8/0x730
> [  763.781606] [c0000002eac83c60] [c000000000017924]
> .do_signal+0x54/0x320
> [  763.781608] [c0000002eac83da0] [c000000000017d74]
> .do_notify_resume+0xb4/0xd0
> [  763.781611] [c0000002eac83e30] [c000000000009e1c]
> .ret_from_except_lite+0x48/0x4c
> [  763.781612] Write-error on swap-device (253:0:7546752)
> [  763.781613] sd 0:0:1:0: rejecting I/O to offline device
> [  763.781615] Write-error on swap-device (253:0:7547008)
> [  763.781616] Sending IPI to other CPUs
> [  763.781616] sd 0:0:1:0: rejecting I/O to offline device
> [  763.781618] Write-error on swap-device (253:0:7547392)
> [  763.781619] sd 0:0:1:0: rejecting I/O to offline device
> [  763.781620] Write-error on swap-device (253:0:7547648)
> [  763.781622] sd 0:0:1:0: rejecting I/O to offline device
> [  763.781623] Write-error on swap-device (253:0:7547904)
> [  763.781625] sd 0:0:1:0: rejecting I/O to offline device
> [  763.781627] Write-error on swap-device (253:0:7548160)
> [  763.781628] sd 0:0:1:0: rejecting I/O to offline device
> [  763.781630] Write-error on swap-device (253:0:7548416)
> [  763.781631] sd 0:0:1:0: rejecting I/O to offline device
> [  763.781632] Write-error on swap-device (253:0:7548672)
> [  763.781634] sd 0:0:1:0: rejecting I/O to offline device
> [  763.781635] Write-error on swap-device (253:0:7548928)
> [  773.781972] ERROR: 1 cpu(s) not responding
> 
>       KERNEL: /boot/vmlinux-3.7.1+
>     DUMPFILE: /var/crash/127.0.0.1-2013.01.09-19:12:02/vmcore
>         CPUS: 28
>         DATE: Tue Jan  8 23:11:35 2013
>       UPTIME: 00:12:43
> LOAD AVERAGE: 5.88, 4.82, 2.51
>        TASKS: 278
>      RELEASE: 3.7.1+
>      VERSION: #0 SMP Tue Jan 8 06:59:49 EST 2013
>      MACHINE: ppc64  (3550 Mhz)
>       MEMORY: 12 GB
>        PANIC: "Kernel panic - not syncing: Attempted to kill init!
>        exitcode=0x0000000b"
>          PID: 1
>      COMMAND: "systemd"
>         TASK: c0000002eac00000  [THREAD_INFO: c0000002eac80000]
>          CPU: 18
>        STATE: TASK_INTERRUPTIBLE|TASK_UNINTERRUPTIBLE|TASK_TRACED
>        (PANIC)
> 
> crash> bt
> PID: 1      TASK: c0000002eac00000  CPU: 18  COMMAND: "systemd"
> 
>  R0:  c000000000721d34    R1:  c0000002eac83920    R2:
>   c000000001157098
>  R3:  c0000002eac83790    R4:  c0000002eac00000    R5:
>   0000000000000070
>  R6:  0000000000000000    R7:  c0000002fff584a0    R8:
>   0000000000000000
>  R9:  c0000002e7909000    R10: 0000000000000001    R11:
>  6578636570745f6c
>  R12: 0000000022004884    R13: c000000007f23f00    R14:
>  0000000000040006
>  R15: 00000000279b056c    R16: c0000002eac83ea0    R17:
>  c000000001398ab8
>  R18: c0000002eac00000    R19: c0000002eac00000    R20:
>  00000000003c0000
>  R21: c0000002eac00a14    R22: c0000000011b2080    R23:
>  c0000002eac83a30
>  R24: c000000018d90000    R25: 0000000000000140    R26:
>  0000000000106001
>  R27: c0000002eac83790    R28: c0000000013ba848    R29:
>  0000000000000000
>  R30: c0000000010d4d18    R31: c00000000101e4b0
>  NIP: c000000000721d34    MSR: 8000000000009032    OR3:
>  c0000002eac83920
>  CTR: 0000000000000000    LR:  c000000000721d34    XER:
>  0000000000000001
>  CCR: 0000000022004882    MQ:  3030303030303030    DAR:
>  0000000000000000
>  DSISR: c000000018d90000     Syscall Result: 0000000000000140
>  NIP [c000000000721d34] .panic
> 
>  #0 [c0000002eac83920] .panic at c000000000721d34
>  #1 [c0000002eac839c0] .do_exit at c0000000000886e4
>  #2 [c0000002eac83ac0] .do_group_exit at c0000000000889d4
>  #3 [c0000002eac83b50] .get_signal_to_deliver at c00000000009be28
>  #4 [c0000002eac83c60] .do_signal at c000000000017924
>  #5 [c0000002eac83da0] .do_notify_resume at c000000000017d74
>  #6 [c0000002eac83e30] .ret_from_except_lite at c000000000009e1c
> 
> CAI Qian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
