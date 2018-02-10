Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1EF726B0005
	for <linux-mm@kvack.org>; Sat, 10 Feb 2018 04:34:08 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id z3so1442412lfa.10
        for <linux-mm@kvack.org>; Sat, 10 Feb 2018 01:34:08 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y188sor1023020lfc.14.2018.02.10.01.34.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 10 Feb 2018 01:34:05 -0800 (PST)
Message-ID: <1518255240.31843.6.camel@gmail.com>
Subject: Re: freezing system for several second on high I/O [kernel 4.15]
From: mikhail <mikhail.v.gavrilov@gmail.com>
Date: Sat, 10 Feb 2018 14:34:00 +0500
In-Reply-To: <20180207065520.66f6gocvxlnxmkyv@destitution>
References: <1517337604.9211.13.camel@gmail.com>
	 <20180131022209.lmhespbauhqtqrxg@destitution>
	 <1517888875.7303.3.camel@gmail.com>
	 <20180206060840.kj2u6jjmkuk3vie6@destitution>
	 <CABXGCsOgcYyj8Xukn7Pi_M2qz2aJ1MJZTaxaSgYno7f_BtZH6w@mail.gmail.com>
	 <1517974845.4352.8.camel@gmail.com>
	 <20180207065520.66f6gocvxlnxmkyv@destitution>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: "linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, 2018-02-07 at 17:55 +1100, Dave Chinner wrote:
> On Wed, Feb 07, 2018 at 08:40:45AM +0500, mikhail wrote:
> > On Tue, 2018-02-06 at 12:12 +0500, Mikhail Gavrilov wrote:
> > > On 6 February 2018 at 11:08, Dave Chinner <david@fromorbit.com> wrote:
> > 
> > Yet another hung:
> > Trace report: https://dumps.sy24.ru/1/trace_report.txt.bz2 (9.4 MB)
> > dmesg:
> > [  369.374381] INFO: task TaskSchedulerFo:5624 blocked for more than 120 seconds.
> > [  369.374391]       Not tainted 4.15.0-rc4-amd-vega+ #9
> > [  369.374393] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> > [  369.374395] TaskSchedulerFo D11688  5624   3825 0x00000000
> > [  369.374400] Call Trace:
> > [  369.374407]  __schedule+0x2dc/0xba0
> > [  369.374410]  ? __lock_acquire+0x2d4/0x1350
> > [  369.374415]  ? __down+0x84/0x110
> > [  369.374417]  schedule+0x33/0x90
> > [  369.374419]  schedule_timeout+0x25a/0x5b0
> > [  369.374423]  ? mark_held_locks+0x5f/0x90
> > [  369.374425]  ? _raw_spin_unlock_irq+0x2c/0x40
> > [  369.374426]  ? __down+0x84/0x110
> > [  369.374429]  ? trace_hardirqs_on_caller+0xf4/0x190
> > [  369.374431]  ? __down+0x84/0x110
> > [  369.374433]  __down+0xac/0x110
> > [  369.374466]  ? _xfs_buf_find+0x263/0xac0 [xfs]
> > [  369.374470]  down+0x41/0x50
> > [  369.374472]  ? down+0x41/0x50
> > [  369.374490]  xfs_buf_lock+0x4e/0x270 [xfs]
> > [  369.374507]  _xfs_buf_find+0x263/0xac0 [xfs]
> > [  369.374528]  xfs_buf_get_map+0x29/0x490 [xfs]
> > [  369.374545]  xfs_buf_read_map+0x2b/0x300 [xfs]
> > [  369.374567]  xfs_trans_read_buf_map+0xc4/0x5d0 [xfs]
> > [  369.374585]  xfs_read_agi+0xaa/0x200 [xfs]
> > [  369.374605]  xfs_iunlink+0x4d/0x150 [xfs]
> > [  369.374609]  ? current_time+0x32/0x70
> > [  369.374629]  xfs_droplink+0x54/0x60 [xfs]
> > [  369.374654]  xfs_rename+0xb15/0xd10 [xfs]
> > [  369.374680]  xfs_vn_rename+0xd3/0x140 [xfs]
> > [  369.374687]  vfs_rename+0x476/0x960
> > [  369.374695]  SyS_rename+0x33f/0x390
> > [  369.374704]  entry_SYSCALL_64_fastpath+0x1f/0x96
> 
> Again, this is waiting on a lock....
> 
> > [  369.374707] RIP: 0033:0x7f01cf705137
> > [  369.374708] RSP: 002b:00007f01873e5608 EFLAGS: 00000202 ORIG_RAX: 0000000000000052
> > [  369.374710] RAX: ffffffffffffffda RBX: 0000000000000119 RCX: 00007f01cf705137
> > [  369.374711] RDX: 00007f01873e56dc RSI: 00003a5cd3540850 RDI: 00003a5cd7ea8000
> > [  369.374713] RBP: 00007f01873e6340 R08: 0000000000000000 R09: 00007f01873e54e0
> > [  369.374714] R10: 00007f01873e55f0 R11: 0000000000000202 R12: 00007f01873e6218
> > [  369.374715] R13: 00007f01873e6358 R14: 0000000000000000 R15: 00003a5cd8416000
> > [  369.374725] INFO: task disk_cache:0:3971 blocked for more than 120 seconds.
> > [  369.374727]       Not tainted 4.15.0-rc4-amd-vega+ #9
> > [  369.374729] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> > [  369.374731] disk_cache:0    D12432  3971   3903 0x00000000
> > [  369.374735] Call Trace:
> > [  369.374738]  __schedule+0x2dc/0xba0
> > [  369.374743]  ? wait_for_completion+0x10e/0x1a0
> > [  369.374745]  schedule+0x33/0x90
> > [  369.374747]  schedule_timeout+0x25a/0x5b0
> > [  369.374751]  ? mark_held_locks+0x5f/0x90
> > [  369.374753]  ? _raw_spin_unlock_irq+0x2c/0x40
> > [  369.374755]  ? wait_for_completion+0x10e/0x1a0
> > [  369.374757]  ? trace_hardirqs_on_caller+0xf4/0x190
> > [  369.374760]  ? wait_for_completion+0x10e/0x1a0
> > [  369.374762]  wait_for_completion+0x136/0x1a0
> > [  369.374765]  ? wake_up_q+0x80/0x80
> > [  369.374782]  ? _xfs_buf_read+0x23/0x30 [xfs]
> > [  369.374798]  xfs_buf_submit_wait+0xb2/0x530 [xfs]
> > [  369.374814]  _xfs_buf_read+0x23/0x30 [xfs]
> > [  369.374828]  xfs_buf_read_map+0x14b/0x300 [xfs]
> > [  369.374847]  ? xfs_trans_read_buf_map+0xc4/0x5d0 [xfs]
> > [  369.374867]  xfs_trans_read_buf_map+0xc4/0x5d0 [xfs]
> > [  369.374883]  xfs_da_read_buf+0xca/0x110 [xfs]
> > [  369.374901]  xfs_dir3_data_read+0x23/0x60 [xfs]
> > [  369.374916]  xfs_dir2_leaf_addname+0x335/0x8b0 [xfs]
> > [  369.374936]  xfs_dir_createname+0x17e/0x1d0 [xfs]
> > [  369.374956]  xfs_create+0x6ad/0x840 [xfs]
> > [  369.374981]  xfs_generic_create+0x1fa/0x2d0 [xfs]
> > [  369.375000]  xfs_vn_mknod+0x14/0x20 [xfs]
> > [  369.375016]  xfs_vn_create+0x13/0x20 [xfs]
> 
> That is held by this process, one it is waiting for IO completion.
> 
> There's nothing in the traces relating to this IO, because the trace
> only starts at 270s after boot, and this process has been waiting
> since submitting it's IO at 250s after boot. The traces tell me that
> IO is still running, but it only takes on IO to go missing for
> everything to have problems.
> 

This is happens because in manual
http://xfs.org/index.php/XFS_FAQ#Q:_What_information_should_I_include_when_reporting_a_problem.3F
was proposed first enter "# echo w > /proc/sysrq-trigger" and then "trace-cmd record -e xfs\*"
And first waiting on a lock always registered after entering "# echo w > /proc/sysrq-trigger" command.
Would be more correct if first was proposed to type "trace-cmd record -e xfs \ *", and then "# echo w> / proc / sysrq-
trigger".
The result is a new trace in which is nothing missed:
https://dumps.sy24.ru/5/trace_report.txt.bz2 (278 MB)

> And there's a lot more threads all waiting on IO completion, both
> data or metadata, so I'm not going to bother commenting further
> because filesystems don't hang like this by themselves.
> 
> i.e. This has all the hallmarks of something below the filesystem
> dropping IO completions, such as the hardware being broken. The
> filesystem is just the messenger....
> 

smartctl was said that my HDD is healthy:# smartctl --all /dev/sdb
smartctl 6.5 2016-05-07 r4318 [x86_64-linux-4.15.0-rc4-amd-vega+] (local build)
Copyright (C) 2002-16, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF INFORMATION SECTION ===
Model Family:     Seagate Constellation ES.3
Device Model:     ST4000NM0033-9ZM170
Serial Number:    Z1Z92B7W
LU WWN Device Id: 5 000c50 07bbbecba
Firmware Version: SN06
User Capacity:    4,000,787,030,016 bytes [4.00 TB]
Sector Size:      512 bytes logical/physical
Rotation Rate:    7200 rpm
Form Factor:      3.5 inches
Device is:        In smartctl database [for details use: -P show]
ATA Version is:   ACS-2 (minor revision not indicated)
SATA Version is:  SATA 3.0, 6.0 Gb/s (current: 6.0 Gb/s)
Local Time is:    Sat Feb 10 13:54:04 2018 +05
SMART support is: Available - device has SMART capability.
SMART support is: Enabled

=== START OF READ SMART DATA SECTION ===
SMART overall-health self-assessment test result: PASSED
See vendor-specific Attribute list for marginal Attributes.

General SMART Values:
Offline data collection status:  (0x82)	Offline data collection activity
					was completed without error.
					Auto Offline Data Collection: Enabled.
Self-test execution status:      (   0)	The previous self-test routine completed
					without error or no self-test has ever 
					been run.
Total time to complete Offline 
data collection: 		(  584) seconds.
Offline data collection
capabilities: 			 (0x7b) SMART execute Offline immediate.
					Auto Offline data collection on/off support.
					Suspend Offline collection upon new
					command.
					Offline surface scan supported.
					Self-test supported.
					Conveyance Self-test supported.
					Selective Self-test supported.
SMART capabilities:            (0x0003)	Saves SMART data before entering
					power-saving mode.
					Supports SMART auto save timer.
Error logging capability:        (0x01)	Error logging supported.
					General Purpose Logging supported.
Short self-test routine 
recommended polling time: 	 (   1) minutes.
Extended self-test routine
recommended polling time: 	 ( 479) minutes.
Conveyance self-test routine
recommended polling time: 	 (   2) minutes.
SCT capabilities: 	       (0x50bd)	SCT Status supported.
					SCT Error Recovery Control supported.
					SCT Feature Control supported.
					SCT Data Table supported.

SMART Attributes Data Structure revision number: 10
Vendor Specific SMART Attributes with Thresholds:
ID# ATTRIBUTE_NAME          FLAG     VALUE WORST THRESH TYPE      UPDATED  WHEN_FAILED RAW_VALUE
  1 Raw_Read_Error_Rate     0x000f   076   063   044    Pre-fail  Always       -       48212827
  3 Spin_Up_Time            0x0003   092   092   000    Pre-fail  Always       -       0
  4 Start_Stop_Count        0x0032   100   100   020    Old_age   Always       -       72
  5 Reallocated_Sector_Ct   0x0033   100   100   010    Pre-fail  Always       -       77
  7 Seek_Error_Rate         0x000f   093   060   030    Pre-fail  Always       -       2572806334
  9 Power_On_Hours          0x0032   079   079   000    Old_age   Always       -       18915
 10 Spin_Retry_Count        0x0013   100   100   097    Pre-fail  Always       -       0
 12 Power_Cycle_Count       0x0032   100   100   020    Old_age   Always       -       70
184 End-to-End_Error        0x0032   100   100   099    Old_age   Always       -       0
187 Reported_Uncorrect      0x0032   100   100   000    Old_age   Always       -       0
188 Command_Timeout         0x0032   100   099   000    Old_age   Always       -       65538
189 High_Fly_Writes         0x003a   059   059   000    Old_age   Always       -       41
190 Airflow_Temperature_Cel 0x0022   050   045   045    Old_age   Always   In_the_past 50 (Min/Max 44/54)
191 G-Sense_Error_Rate      0x0032   100   100   000    Old_age   Always       -       0
192 Power-Off_Retract_Count 0x0032   100   100   000    Old_age   Always       -       41
193 Load_Cycle_Count        0x0032   100   100   000    Old_age   Always       -       861
194 Temperature_Celsius     0x0022   050   055   000    Old_age   Always       -       50 (0 25 0 0 0)
195 Hardware_ECC_Recovered  0x001a   038   015   000    Old_age   Always       -       48212827
197 Current_Pending_Sector  0x0012   100   100   000    Old_age   Always       -       0
198 Offline_Uncorrectable   0x0010   100   100   000    Old_age   Offline      -       0
199 UDMA_CRC_Error_Count    0x003e   200   200   000    Old_age   Always       -       0

SMART Error Log Version: 1
No Errors Logged

SMART Self-test log structure revision number 1
Num  Test_Description    Status                  Remaining  LifeTime(hours)  LBA_of_first_error
# 1  Conveyance offline  Completed without error       00%     13431         -
# 2  Conveyance offline  Completed without error       00%     12505         -

SMART Selective self-test log data structure revision number 1
 SPAN  MIN_LBA  MAX_LBA  CURRENT_TEST_STATUS
    1        0        0  Not_testing
    2        0        0  Not_testing
    3        0        0  Not_testing
    4        0        0  Not_testing
    5        0        0  Not_testing
Selective self-test flags (0x0):
  After scanning selected spans, do NOT read-scan remainder of disk.
If Selective self-test is pending on power-up, resume after 0 minute delay.


Can you help me move in right direction?
I am understand that file system is not root cause here of locking.
But I am still wonder to know who was guilty here.
Which subsystem is behind file system?
Maybe you can suggest right mailing list for discussion this issue?


Thanks.

--
Best Regards,
Mikhail Gavrilov.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
