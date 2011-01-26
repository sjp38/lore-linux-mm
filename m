Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 668E76B0092
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 08:52:55 -0500 (EST)
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id p0QDqsU0002207
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 08:52:54 -0500
Date: Wed, 26 Jan 2011 14:52:52 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: mmotm 2011-01-25-15-47 uploaded
Message-ID: <20110126135252.GQ926@random.random>
References: <201101260021.p0Q0LxsS016458@imap1.linux-foundation.org>
 <200549051.160023.1296031555533.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200549051.160023.1296031555533.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Sender: owner-linux-mm@kvack.org
To: CAI Qian <caiqian@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Qian,

On Wed, Jan 26, 2011 at 03:45:55AM -0500, CAI Qian wrote:
> Andrea,
> 
> khugepaged hung during swapping there.
> 
> INFO: task khugepaged:276 blocked for more than 120 seconds.
> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> khugepaged      D ffff880fa0fd4610     0   276      2 0x00000000
>  ffff880fa07cfcc0 0000000000000046 ffff88201ffdac00 0000000000000000
>  0000000000014d40 ffff880fa0fd4080 ffff880fa0fd4610 ffff880fa07cffd8
>  ffff880fa0fd4618 0000000000014d40 ffff880fa07ce010 0000000000014d40
> Call Trace:
>  [<ffffffff814afeb5>] rwsem_down_failed_common+0xb5/0x140
>  [<ffffffff814aff53>] rwsem_down_write_failed+0x13/0x20
>  [<ffffffff812301a3>] call_rwsem_down_write_failed+0x13/0x20
>  [<ffffffff814af4d2>] ? down_write+0x32/0x40
>  [<ffffffff81146b4d>] khugepaged+0x8ad/0x1300
>  [<ffffffff8100a6f0>] ? __switch_to+0xd0/0x320
>  [<ffffffff811462a0>] ? khugepaged+0x0/0x1300
>  [<ffffffff810830f0>] ? autoremove_wake_function+0x0/0x40
>  [<ffffffff811462a0>] ? khugepaged+0x0/0x1300
>  [<ffffffff81082a56>] kthread+0x96/0xa0
>  [<ffffffff8100cdc4>] kernel_thread_helper+0x4/0x10
>  [<ffffffff810829c0>] ? kthread+0x0/0xa0
>  [<ffffffff8100cdc0>] ? kernel_thread_helper+0x0/0x10
> INFO: task pgrep:6039 blocked for more than 120 seconds.
> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> pgrep           D ffff887f606f1ab0     0  6039   6038 0x00000080
>  ffff8821e39c1ce0 0000000000000082 0000000000000246 0000000000000000
>  0000000000014d40 ffff887f606f1520 ffff887f606f1ab0 ffff8821e39c1fd8
>  ffff887f606f1ab8 0000000000014d40 ffff8821e39c0010 0000000000014d40
> Call Trace:
>  [<ffffffff814afeb5>] rwsem_down_failed_common+0xb5/0x140
>  [<ffffffff814aff75>] rwsem_down_read_failed+0x15/0x17
>  [<ffffffff81230174>] call_rwsem_down_read_failed+0x14/0x30
>  [<ffffffff814af504>] ? down_read+0x24/0x30
>  [<ffffffff8111f4dc>] access_process_vm+0x4c/0x200
>  [<ffffffff8113f3fe>] ? fallback_alloc+0x14e/0x270
>  [<ffffffff811afa4d>] proc_pid_cmdline+0x6d/0x120
>  [<ffffffff81137eba>] ? alloc_pages_current+0x9a/0x100
>  [<ffffffff811b037d>] proc_info_read+0xad/0xf0
>  [<ffffffff81154315>] vfs_read+0xc5/0x190
>  [<ffffffff811544e1>] sys_read+0x51/0x90
>  [<ffffffff8100bf82>] system_call_fastpath+0x16/0x1b

pgrep hung too, it's not just khugepaged hanging and it's not obvious
for now that khugepaged was guilty of forgetting an unlock, could be
the process deadlocked somewhere with the mmap_sem hold. Can you press
SYSRQ+T? Hopefully that will show the holder. Also is CONFIG_NUMA=y/n?

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
