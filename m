Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 049386B0032
	for <linux-mm@kvack.org>; Mon,  9 Feb 2015 02:14:20 -0500 (EST)
Received: by labgf13 with SMTP id gf13so11510776lab.3
        for <linux-mm@kvack.org>; Sun, 08 Feb 2015 23:14:19 -0800 (PST)
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com. [209.85.215.41])
        by mx.google.com with ESMTPS id s10si8205951lae.47.2015.02.08.23.14.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 Feb 2015 23:14:18 -0800 (PST)
Received: by lamq1 with SMTP id q1so11478870lam.5
        for <linux-mm@kvack.org>; Sun, 08 Feb 2015 23:14:17 -0800 (PST)
MIME-Version: 1.0
Date: Mon, 9 Feb 2015 11:14:17 +0400
Message-ID: <CALYGNiMhifrNm5jv499Y6BcM0mYkHUgPBP5a5p7-Gc7ue_jqjw@mail.gmail.com>
Subject: BUG: stuck on mmap_sem in 3.18.6
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Python was running under ptrace-based sandbox "sydbox" used exherbo
chroot. Kernel: 3.18.6 + my patch "mm: prevent endless growth of
anon_vma hierarchy" (patch seems stable).

[ 4674.087780] INFO: task python:25873 blocked for more than 120 seconds.
[ 4674.087793]       Tainted: G     U         3.18.6-zurg+ #158
[ 4674.087797] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[ 4674.087801] python          D ffff88041e2d2000 14176 25873  25630 0x00000102
[ 4674.087817]  ffff880286247b68 0000000000000086 ffff8803d5fe6b40
0000000000012000
[ 4674.087824]  ffff880286247fd8 0000000000012000 ffff88040c16eb40
ffff8803d5fe6b40
[ 4674.087830]  0000000300000003 ffff8803d5fe6b40 ffff880362888e78
ffff880362888e60
[ 4674.087836] Call Trace:
[ 4674.087854]  [<ffffffff81696be9>] schedule+0x29/0x70
[ 4674.087865]  [<ffffffff81699815>] rwsem_down_write_failed+0x1d5/0x2f0
[ 4674.087873]  [<ffffffff812d4c73>] call_rwsem_down_write_failed+0x13/0x20
[ 4674.087881]  [<ffffffff816990c1>] ? down_write+0x31/0x50
[ 4674.087891]  [<ffffffff811f3b44>] do_coredump+0x144/0xee0
[ 4674.087900]  [<ffffffff810b66f7>] ? pick_next_task_fair+0x397/0x450
[ 4674.087909]  [<ffffffff810026a6>] ? __switch_to+0x1d6/0x5f0
[ 4674.087915]  [<ffffffff816966e6>] ? __schedule+0x3a6/0x880
[ 4674.087924]  [<ffffffff81690000>] ? klist_remove+0x40/0xd0
[ 4674.087932]  [<ffffffff81093988>] get_signal+0x298/0x6b0
[ 4674.087940]  [<ffffffff81003588>] do_signal+0x28/0xbb0
[ 4674.087946]  [<ffffffff8109276d>] ? do_send_sig_info+0x5d/0x80
[ 4674.087955]  [<ffffffff81004179>] do_notify_resume+0x69/0xb0
[ 4674.087963]  [<ffffffff8169b028>] int_signal+0x12/0x17

Maybe this guy did something wrong?

[ 5153.460186] INFO: task khugepaged:262 blocked for more than 120 seconds.
[ 5153.460198]       Tainted: G     U         3.18.6-zurg+ #158
[ 5153.460201] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[ 5153.460206] khugepaged      D ffff88041e292000 14496   262      2 0x00000000
[ 5153.460220]  ffff88040b99bcb0 0000000000000046 ffff88040b994a40
0000000000012000
[ 5153.460227]  ffff88040b99bfd8 0000000000012000 ffff88040c16e300
ffff88040b994a40
[ 5153.460233]  ffffffff810d5c1b ffff88040b994a40 ffff880362888e60
ffffffffffffffff
[ 5153.460240] Call Trace:
[ 5153.460255]  [<ffffffff810d5c1b>] ? lock_timer_base.isra.41+0x2b/0x50
[ 5153.460264]  [<ffffffff81696be9>] schedule+0x29/0x70
[ 5153.460272]  [<ffffffff81699a05>] rwsem_down_read_failed+0xd5/0x120
[ 5153.460280]  [<ffffffff812d4c44>] call_rwsem_down_read_failed+0x14/0x30
[ 5153.460287]  [<ffffffff81699084>] ? down_read+0x24/0x30
[ 5153.460297]  [<ffffffff81191221>] khugepaged+0x381/0x13f0
[ 5153.460309]  [<ffffffff810bb400>] ? abort_exclusive_wait+0xb0/0xb0
[ 5153.460316]  [<ffffffff81190ea0>] ? maybe_pmd_mkwrite+0x30/0x30
[ 5153.460325]  [<ffffffff810a217b>] kthread+0xdb/0x100
[ 5153.460332]  [<ffffffff810a20a0>] ? kthread_create_on_node+0x170/0x170
[ 5153.460340]  [<ffffffff8169acfc>] ret_from_fork+0x7c/0xb0
[ 5153.460347]  [<ffffffff810a20a0>] ? kthread_create_on_node+0x170/0x170

and a lot of ps stuck in /proc/*/cmdline (this thing should be killable)

[ 5153.460713] INFO: task ps:26686 blocked for more than 120 seconds.
[ 5153.460716]       Tainted: G     U         3.18.6-zurg+ #158
[ 5153.460718] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[ 5153.460721] ps              D ffff88041e2d2000 14272 26686  26676 0x00000000
[ 5153.460730]  ffff8802a991bc10 0000000000000086 ffff88040bb30000
0000000000012000
[ 5153.460736]  ffff8802a991bfd8 0000000000012000 ffff88040c16eb40
ffff88040bb30000
[ 5153.460741]  ffff880385d29100 ffff88040bb30000 ffff880362888e60
ffffffffffffffff
[ 5153.460747] Call Trace:
[ 5153.460753]  [<ffffffff81696be9>] schedule+0x29/0x70
[ 5153.460760]  [<ffffffff81699a05>] rwsem_down_read_failed+0xd5/0x120
[ 5153.460765]  [<ffffffff811bb7d1>] ? single_open+0x61/0xb0
[ 5153.460770]  [<ffffffff812d4c44>] call_rwsem_down_read_failed+0x14/0x30
[ 5153.460777]  [<ffffffff81699084>] ? down_read+0x24/0x30
[ 5153.460784]  [<ffffffff8116cae2>] __access_remote_vm+0x42/0x2e0
[ 5153.460791]  [<ffffffff811aebea>] ? dput+0x2a/0x1b0
[ 5153.460799]  [<ffffffff811724f0>] access_process_vm+0x50/0x70
[ 5153.460806]  [<ffffffff8115f8dc>] get_cmdline+0x5c/0x100
[ 5153.460812]  [<ffffffff811f877b>] proc_pid_cmdline+0x2b/0x50
[ 5153.460817]  [<ffffffff811f8e24>] proc_single_show+0x54/0xa0
[ 5153.460822]  [<ffffffff811bb45d>] seq_read+0xcd/0x3b0
[ 5153.460828]  [<ffffffff811981d8>] vfs_read+0x98/0x160
[ 5153.460833]  [<ffffffff81198ca6>] SyS_read+0x46/0xb0
[ 5153.460841]  [<ffffffff8169adad>] system_call_fastpath+0x16/0x1b


[ 5187.935448] SysRq : Show Blocked State
[ 5187.935462]   task                        PC stack   pid father
[ 5187.935474] khugepaged      D ffff88041e292000 14496   262      2 0x00000000
[ 5187.935489]  ffff88040b99bcb0 0000000000000046 ffff88040b994a40
0000000000012000
[ 5187.935496]  ffff88040b99bfd8 0000000000012000 ffff88040c16e300
ffff88040b994a40
[ 5187.935502]  ffffffff810d5c1b ffff88040b994a40 ffff880362888e60
ffffffffffffffff
[ 5187.935508] Call Trace:
[ 5187.935524]  [<ffffffff810d5c1b>] ? lock_timer_base.isra.41+0x2b/0x50
[ 5187.935533]  [<ffffffff81696be9>] schedule+0x29/0x70
[ 5187.935541]  [<ffffffff81699a05>] rwsem_down_read_failed+0xd5/0x120
[ 5187.935549]  [<ffffffff812d4c44>] call_rwsem_down_read_failed+0x14/0x30
[ 5187.935556]  [<ffffffff81699084>] ? down_read+0x24/0x30
[ 5187.935566]  [<ffffffff81191221>] khugepaged+0x381/0x13f0
[ 5187.935578]  [<ffffffff810bb400>] ? abort_exclusive_wait+0xb0/0xb0
[ 5187.935585]  [<ffffffff81190ea0>] ? maybe_pmd_mkwrite+0x30/0x30
[ 5187.935593]  [<ffffffff810a217b>] kthread+0xdb/0x100
[ 5187.935601]  [<ffffffff810a20a0>] ? kthread_create_on_node+0x170/0x170
[ 5187.935609]  [<ffffffff8169acfc>] ret_from_fork+0x7c/0xb0
[ 5187.935615]  [<ffffffff810a20a0>] ? kthread_create_on_node+0x170/0x170
[ 5187.935688] python          D ffff88041e2d2000 14176 25873  25630 0x00000102
[ 5187.935699]  ffff880286247b68 0000000000000086 ffff8803d5fe6b40
0000000000012000
[ 5187.935705]  ffff880286247fd8 0000000000012000 ffff88040c16eb40
ffff8803d5fe6b40
[ 5187.935711]  0000000300000003 ffff8803d5fe6b40 ffff880362888e78
ffff880362888e60
[ 5187.935717] Call Trace:
[ 5187.935724]  [<ffffffff81696be9>] schedule+0x29/0x70
[ 5187.935731]  [<ffffffff81699815>] rwsem_down_write_failed+0x1d5/0x2f0
[ 5187.935737]  [<ffffffff812d4c73>] call_rwsem_down_write_failed+0x13/0x20
[ 5187.935744]  [<ffffffff816990c1>] ? down_write+0x31/0x50
[ 5187.935754]  [<ffffffff811f3b44>] do_coredump+0x144/0xee0
[ 5187.935761]  [<ffffffff810b66f7>] ? pick_next_task_fair+0x397/0x450
[ 5187.935770]  [<ffffffff810026a6>] ? __switch_to+0x1d6/0x5f0
[ 5187.935777]  [<ffffffff816966e6>] ? __schedule+0x3a6/0x880
[ 5187.935786]  [<ffffffff81690000>] ? klist_remove+0x40/0xd0
[ 5187.935794]  [<ffffffff81093988>] get_signal+0x298/0x6b0
[ 5187.935802]  [<ffffffff81003588>] do_signal+0x28/0xbb0
[ 5187.935807]  [<ffffffff8109276d>] ? do_send_sig_info+0x5d/0x80
[ 5187.935816]  [<ffffffff81004179>] do_notify_resume+0x69/0xb0
[ 5187.935824]  [<ffffffff8169b028>] int_signal+0x12/0x17
[ 5187.935834] ps              D ffff88041e212000 14272 26669   3799 0x00000000
[ 5187.935844]  ffff8802a98bbc10 0000000000000082 ffff8803e138ca40
0000000000012000
[ 5187.935850]  ffff8802a98bbfd8 0000000000012000 ffffffff81c18500
ffff8803e138ca40
[ 5187.935855]  ffff8800c9bb5400 ffff8803e138ca40 ffff880362888e60
ffffffffffffffff
[ 5187.935861] Call Trace:
[ 5187.935868]  [<ffffffff81696be9>] schedule+0x29/0x70
[ 5187.935874]  [<ffffffff81699a05>] rwsem_down_read_failed+0xd5/0x120
[ 5187.935881]  [<ffffffff811bb7d1>] ? single_open+0x61/0xb0
[ 5187.935887]  [<ffffffff812d4c44>] call_rwsem_down_read_failed+0x14/0x30
[ 5187.935894]  [<ffffffff81699084>] ? down_read+0x24/0x30
[ 5187.935903]  [<ffffffff8116cae2>] __access_remote_vm+0x42/0x2e0
[ 5187.935912]  [<ffffffff811aebea>] ? dput+0x2a/0x1b0
[ 5187.935920]  [<ffffffff811724f0>] access_process_vm+0x50/0x70
[ 5187.935929]  [<ffffffff8115f8dc>] get_cmdline+0x5c/0x100
[ 5187.935935]  [<ffffffff811f877b>] proc_pid_cmdline+0x2b/0x50
[ 5187.935941]  [<ffffffff811f8e24>] proc_single_show+0x54/0xa0
[ 5187.935947]  [<ffffffff811bb45d>] seq_read+0xcd/0x3b0
[ 5187.935953]  [<ffffffff811981d8>] vfs_read+0x98/0x160
[ 5187.935959]  [<ffffffff81198ca6>] SyS_read+0x46/0xb0
[ 5187.935966]  [<ffffffff8169adad>] system_call_fastpath+0x16/0x1b
[ 5187.935999] ps              D ffff88041e2d2000 14272 26686  26676 0x00000000
[ 5187.936010]  ffff8802a991bc10 0000000000000086 ffff88040bb30000
0000000000012000
[ 5187.936015]  ffff8802a991bfd8 0000000000012000 ffff88040c16eb40
ffff88040bb30000
[ 5187.936021]  ffff880385d29100 ffff88040bb30000 ffff880362888e60
ffffffffffffffff
[ 5187.936026] Call Trace:
[ 5187.936033]  [<ffffffff81696be9>] schedule+0x29/0x70
[ 5187.936040]  [<ffffffff81699a05>] rwsem_down_read_failed+0xd5/0x120
[ 5187.936046]  [<ffffffff811bb7d1>] ? single_open+0x61/0xb0
[ 5187.936052]  [<ffffffff812d4c44>] call_rwsem_down_read_failed+0x14/0x30
[ 5187.936079]  [<ffffffff81699084>] ? down_read+0x24/0x30
[ 5187.936099]  [<ffffffff8116cae2>] __access_remote_vm+0x42/0x2e0
[ 5187.936106]  [<ffffffff811aebea>] ? dput+0x2a/0x1b0
[ 5187.936114]  [<ffffffff811724f0>] access_process_vm+0x50/0x70
[ 5187.936121]  [<ffffffff8115f8dc>] get_cmdline+0x5c/0x100
[ 5187.936127]  [<ffffffff811f877b>] proc_pid_cmdline+0x2b/0x50
[ 5187.936132]  [<ffffffff811f8e24>] proc_single_show+0x54/0xa0
[ 5187.936138]  [<ffffffff811bb45d>] seq_read+0xcd/0x3b0
[ 5187.936143]  [<ffffffff811981d8>] vfs_read+0x98/0x160
[ 5187.936149]  [<ffffffff81198ca6>] SyS_read+0x46/0xb0
[ 5187.936156]  [<ffffffff8169adad>] system_call_fastpath+0x16/0x1b
[ 5187.936160] ps              D ffff88041e292000 14288 26726  26704 0x00000004
[ 5187.936170]  ffff8802a98abc10 0000000000000086 ffff8800d5f5f380
0000000000012000
[ 5187.936175]  ffff8802a98abfd8 0000000000012000 ffff88040c16e300
ffff8800d5f5f380
[ 5187.936181]  ffff8803d5c3f400 ffff8800d5f5f380 ffff880362888e60
ffffffffffffffff
[ 5187.936186] Call Trace:
[ 5187.936192]  [<ffffffff81696be9>] schedule+0x29/0x70
[ 5187.936199]  [<ffffffff81699a05>] rwsem_down_read_failed+0xd5/0x120
[ 5187.936204]  [<ffffffff811bb7d1>] ? single_open+0x61/0xb0
[ 5187.936209]  [<ffffffff812d4c44>] call_rwsem_down_read_failed+0x14/0x30
[ 5187.936216]  [<ffffffff81699084>] ? down_read+0x24/0x30
[ 5187.936223]  [<ffffffff8116cae2>] __access_remote_vm+0x42/0x2e0
[ 5187.936230]  [<ffffffff811aebea>] ? dput+0x2a/0x1b0
[ 5187.936238]  [<ffffffff811724f0>] access_process_vm+0x50/0x70
[ 5187.936245]  [<ffffffff8115f8dc>] get_cmdline+0x5c/0x100
[ 5187.936250]  [<ffffffff811f877b>] proc_pid_cmdline+0x2b/0x50
[ 5187.936256]  [<ffffffff811f8e24>] proc_single_show+0x54/0xa0
[ 5187.936261]  [<ffffffff811bb45d>] seq_read+0xcd/0x3b0
[ 5187.936266]  [<ffffffff811981d8>] vfs_read+0x98/0x160
[ 5187.936272]  [<ffffffff81198ca6>] SyS_read+0x46/0xb0
[ 5187.936279]  [<ffffffff8169adad>] system_call_fastpath+0x16/0x1b
[ 5187.936284] ps              D ffff88041e252000 14280 26765  26752 0x00000004
[ 5187.936293]  ffff8800c9a6fc10 0000000000000086 ffff8803708edac0
0000000000012000
[ 5187.936298]  ffff8800c9a6ffd8 0000000000012000 ffff88040c16dac0
ffff8803708edac0
[ 5187.936303]  ffff8803e7bd1800 ffff8803708edac0 ffff880362888e60
ffffffffffffffff
[ 5187.936309] Call Trace:
[ 5187.936315]  [<ffffffff81696be9>] schedule+0x29/0x70
[ 5187.936321]  [<ffffffff81699a05>] rwsem_down_read_failed+0xd5/0x120
[ 5187.936326]  [<ffffffff811bb7d1>] ? single_open+0x61/0xb0
[ 5187.936332]  [<ffffffff812d4c44>] call_rwsem_down_read_failed+0x14/0x30
[ 5187.936338]  [<ffffffff81699084>] ? down_read+0x24/0x30
[ 5187.936345]  [<ffffffff8116cae2>] __access_remote_vm+0x42/0x2e0
[ 5187.936352]  [<ffffffff811aebea>] ? dput+0x2a/0x1b0
[ 5187.936360]  [<ffffffff811724f0>] access_process_vm+0x50/0x70
[ 5187.936367]  [<ffffffff8115f8dc>] get_cmdline+0x5c/0x100
[ 5187.936372]  [<ffffffff811f877b>] proc_pid_cmdline+0x2b/0x50
[ 5187.936378]  [<ffffffff811f8e24>] proc_single_show+0x54/0xa0
[ 5187.936383]  [<ffffffff811bb45d>] seq_read+0xcd/0x3b0
[ 5187.936388]  [<ffffffff811981d8>] vfs_read+0x98/0x160
[ 5187.936394]  [<ffffffff81198ca6>] SyS_read+0x46/0xb0
[ 5187.936401]  [<ffffffff8169adad>] system_call_fastpath+0x16/0x1b
[ 5187.936405] ps              D ffff88041e292000 14280 26782  26772 0x00000000
[ 5187.936414]  ffff8800b26f3c10 0000000000000082 ffff8803708e9080
0000000000012000
[ 5187.936420]  ffff8800b26f3fd8 0000000000012000 ffff88040c16e300
ffff8803708e9080
[ 5187.936425]  ffff8803d5c3ee00 ffff8803708e9080 ffff880362888e60
ffffffffffffffff
[ 5187.936430] Call Trace:
[ 5187.936437]  [<ffffffff81696be9>] schedule+0x29/0x70
[ 5187.936443]  [<ffffffff81699a05>] rwsem_down_read_failed+0xd5/0x120
[ 5187.936448]  [<ffffffff811bb7d1>] ? single_open+0x61/0xb0
[ 5187.936454]  [<ffffffff812d4c44>] call_rwsem_down_read_failed+0x14/0x30
[ 5187.936460]  [<ffffffff81699084>] ? down_read+0x24/0x30
[ 5187.936467]  [<ffffffff8116cae2>] __access_remote_vm+0x42/0x2e0
[ 5187.936474]  [<ffffffff811aebea>] ? dput+0x2a/0x1b0
[ 5187.936482]  [<ffffffff811724f0>] access_process_vm+0x50/0x70
[ 5187.936489]  [<ffffffff8115f8dc>] get_cmdline+0x5c/0x100
[ 5187.936494]  [<ffffffff811f877b>] proc_pid_cmdline+0x2b/0x50
[ 5187.936500]  [<ffffffff811f8e24>] proc_single_show+0x54/0xa0
[ 5187.936505]  [<ffffffff811bb45d>] seq_read+0xcd/0x3b0
[ 5187.936510]  [<ffffffff811981d8>] vfs_read+0x98/0x160
[ 5187.936516]  [<ffffffff81198ca6>] SyS_read+0x46/0xb0
[ 5187.936523]  [<ffffffff8169adad>] system_call_fastpath+0x16/0x1b
[ 5187.936527] ps              D ffff88041e2d2000 14280 26795  26783 0x00000000
[ 5187.936536]  ffff8802a9b8fc10 0000000000000086 ffff8803e13c6300
0000000000012000
[ 5187.936541]  ffff8802a9b8ffd8 0000000000012000 ffff88040c16eb40
ffff8803e13c6300
[ 5187.936547]  ffff8803e7bd1b00 ffff8803e13c6300 ffff880362888e60
ffffffffffffffff
[ 5187.936552] Call Trace:
[ 5187.936558]  [<ffffffff81696be9>] schedule+0x29/0x70
[ 5187.936565]  [<ffffffff81699a05>] rwsem_down_read_failed+0xd5/0x120
[ 5187.936570]  [<ffffffff811bb7d1>] ? single_open+0x61/0xb0
[ 5187.936575]  [<ffffffff812d4c44>] call_rwsem_down_read_failed+0x14/0x30
[ 5187.936582]  [<ffffffff81699084>] ? down_read+0x24/0x30
[ 5187.936588]  [<ffffffff8116cae2>] __access_remote_vm+0x42/0x2e0
[ 5187.936596]  [<ffffffff811aebea>] ? dput+0x2a/0x1b0
[ 5187.936603]  [<ffffffff811724f0>] access_process_vm+0x50/0x70
[ 5187.936610]  [<ffffffff8115f8dc>] get_cmdline+0x5c/0x100
[ 5187.936616]  [<ffffffff811f877b>] proc_pid_cmdline+0x2b/0x50
[ 5187.936621]  [<ffffffff811f8e24>] proc_single_show+0x54/0xa0
[ 5187.936626]  [<ffffffff811bb45d>] seq_read+0xcd/0x3b0
[ 5187.936632]  [<ffffffff811981d8>] vfs_read+0x98/0x160
[ 5187.936637]  [<ffffffff81198ca6>] SyS_read+0x46/0xb0
[ 5187.936644]  [<ffffffff8169adad>] system_call_fastpath+0x16/0x1b
[ 5187.936648] pidof           D ffff88041e212000 14288 26808  26798 0x00000004
[ 5187.936658]  ffff8802a9b67c10 0000000000000082 ffff8800d5f58000
0000000000012000
[ 5187.936663]  ffff8802a9b67fd8 0000000000012000 ffffffff81c18500
ffff8800d5f58000
[ 5187.936669]  ffff880000320700 ffff8800d5f58000 ffff880362888e60
ffffffffffffffff
[ 5187.936674] Call Trace:
[ 5187.936680]  [<ffffffff81696be9>] schedule+0x29/0x70
[ 5187.936687]  [<ffffffff81699a05>] rwsem_down_read_failed+0xd5/0x120
[ 5187.936692]  [<ffffffff811bb7d1>] ? single_open+0x61/0xb0
[ 5187.936697]  [<ffffffff812d4c44>] call_rwsem_down_read_failed+0x14/0x30
[ 5187.936704]  [<ffffffff81699084>] ? down_read+0x24/0x30
[ 5187.936710]  [<ffffffff8116cae2>] __access_remote_vm+0x42/0x2e0
[ 5187.936718]  [<ffffffff811724f0>] access_process_vm+0x50/0x70
[ 5187.936725]  [<ffffffff8115f8dc>] get_cmdline+0x5c/0x100
[ 5187.936731]  [<ffffffff811f877b>] proc_pid_cmdline+0x2b/0x50
[ 5187.936751]  [<ffffffff811f8e24>] proc_single_show+0x54/0xa0
[ 5187.936771]  [<ffffffff811bb45d>] seq_read+0xcd/0x3b0
[ 5187.936776]  [<ffffffff811981d8>] vfs_read+0x98/0x160
[ 5187.936782]  [<ffffffff81198ca6>] SyS_read+0x46/0xb0
[ 5187.936789]  [<ffffffff8169adad>] system_call_fastpath+0x16/0x1b

Looks like mmap_sem is locked for read:

  mmap_sem = {
    count = 0xffffffff00000001,
    wait_list = {
      next = 0xffff880286247ba8,
      prev = 0xffff8802a9a3fc40
    },
    wait_lock = {
      raw_lock = {
        {
          head_tail = 0xa0a,
          tickets = {
            head = 0xa,
            tail = 0xa
          }
        }
      }
    },
    osq = {
      tail = {
        counter = 0x0
      }
    },
    owner = 0x0
  },




crash> vm -m 25873
PID: 25873  TASK: ffff8803d5fe6b40  CPU: 3   COMMAND: "python"
struct mm_struct {
  mmap = 0xffff88034789d630,
  mm_rb = {
    rb_node = 0xffff88034789de90
  },
  vmacache_seqnum = 16,
  get_unmapped_area = 0xffffffff81009cb0 <arch_get_unmapped_area_topdown>,
  mmap_base = 140658574835712,
  mmap_legacy_base = 47602925838336,
  task_size = 140737488351232,
  highest_vm_end = 140735317192704,
  pgd = 0xffff880385fa8000,
  mm_users = {
    counter = 17
  },
  mm_count = {
    counter = 2
  },
  nr_ptes = {
    counter = 19
  },
  map_count = 38,
  page_table_lock = {
    {
      rlock = {
        raw_lock = {
          {
            head_tail = 63479,
            tickets = {
              head = 247 '\367',
              tail = 247 '\367'
            }
          }
        }
      }
    }
  },
  mmap_sem = {
    count = -4294967295,
    wait_list = {
      next = 0xffff880286247ba8,
      prev = 0xffff8802a9a3fc40
    },
    wait_lock = {
      raw_lock = {
        {
          head_tail = 2570,
          tickets = {
            head = 10 '\n',
            tail = 10 '\n'
          }
        }
      }
    },
    osq = {
      tail = {
        counter = 0
      }
    },
    owner = 0x0
  },
  mmlist = {
    next = 0xffff880362888e88,
    prev = 0xffff880362888e88
  },
  hiwater_rss = 1568,
  hiwater_vm = 5064,
  total_vm = 7182,
  locked_vm = 0,
  pinned_vm = 0,
  shared_vm = 4432,
  exec_vm = 1248,
  stack_vm = 2049,
  def_flags = 0,
  start_code = 4194304,
  end_code = 4197980,
  start_data = 6295552,
  end_data = 6296256,
  start_brk = 25419776,
  brk = 26329088,
  start_stack = 140735316677648,
  arg_start = 140735316687680,
  arg_end = 140735316687834,
  env_start = 140735316687834,
  env_end = 140735316705197,
  saved_auxv = {33, 140735317184512, 16, 3219913727, 6, 4096, 17, 100,
3, 4194368, 4, 56, 5, 8, 7, 140658572595200, 8, 0, 9, 4197157, 11,
103, 12, 103, 13, 443, 14, 443, 23, 0, 25, 140735316680617, 31,
140735316705197, 15, 140735316680633, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
  rss_stat = {
    count = {{
        counter = 942
      }, {
        counter = 2779
      }, {
        counter = 0
      }}
  },
  binfmt = 0xffffffff81c699e0 <elf_format>,
  cpu_vm_mask_var = {{
      bits = {0}
    }},
  context = {
    ldt = 0x0,
    size = 0,
    ia32_compat = 0,
    lock = {
      count = {
        counter = 1
      },
      wait_lock = {
        {
          rlock = {
            raw_lock = {
              {
                head_tail = 0,
                tickets = {
                  head = 0 '\000',
                  tail = 0 '\000'
                }
              }
            }
          }
        }
      },
      wait_list = {
        next = 0xffff8803628890e8,
        prev = 0xffff8803628890e8
      },
      owner = 0x0,
      osq = {
        tail = {
          counter = 0
        }
      }
    },
    vdso = 0x7fff7e969000
  },
  flags = 131277,
  core_state = 0x0,
  ioctx_lock = {
    {
      rlock = {
        raw_lock = {
          {
            head_tail = 0,
            tickets = {
              head = 0 '\000',
              tail = 0 '\000'
            }
          }
        }
      }
    }
  },
  ioctx_table = 0x0,
  exe_file = 0xffff8800c9802100,
  mmu_notifier_mm = 0x0,
  tlb_flush_pending = false,
  uprobes_state = {
    xol_area = 0x0
  }
}
crash> task 25873
PID: 25873  TASK: ffff8803d5fe6b40  CPU: 3   COMMAND: "python"
struct task_struct {
  state = 2,
  stack = 0xffff880286244000,
  usage = {
    counter = 10
  },
  flags = 4219904,
  ptrace = 0,
  wake_entry = {
    next = 0x0
  },
  on_cpu = 0,
  last_wakee = 0xffff8803e138c200,
  wakee_flips = 73,
  wakee_flip_decay_ts = 4299225608,
  wake_cpu = 3,
  on_rq = 0,
  prio = 120,
  static_prio = 120,
  normal_prio = 120,
  rt_priority = 0,
  sched_class = 0xffffffff81815900 <print_fmt_sched_switch+256>,
  se = {
    load = {
      weight = 1024,
      inv_weight = 4194304
    },
    run_node = {
      __rb_parent_color = 1,
      rb_right = 0x0,
      rb_left = 0x0
    },
    group_node = {
      next = 0xffff8803d5fe6bd0,
      prev = 0xffff8803d5fe6bd0
    },
    on_rq = 0,
    exec_start = 4553221849241,
    sum_exec_runtime = 32524243,
    vruntime = 3182965965951,
    prev_sum_exec_runtime = 32521714,
    nr_migrations = 2,
    statistics = {
      wait_start = 0,
      wait_max = 544641,
      wait_count = 283,
      wait_sum = 2603230,
      iowait_count = 0,
      iowait_sum = 0,
      sleep_start = 0,
      sleep_max = 0,
      sum_sleep_runtime = 0,
      block_start = 4553221849241,
      block_max = 0,
      exec_max = 1000187,
      slice_max = 0,
      nr_migrations_cold = 0,
      nr_failed_migrations_affine = 0,
      nr_failed_migrations_running = 0,
      nr_failed_migrations_hot = 0,
      nr_forced_migrations = 0,
      nr_wakeups = 230,
      nr_wakeups_sync = 0,
      nr_wakeups_migrate = 0,
      nr_wakeups_local = 229,
      nr_wakeups_remote = 1,
      nr_wakeups_affine = 0,
      nr_wakeups_affine_attempts = 1,
      nr_wakeups_passive = 0,
      nr_wakeups_idle = 0
    },
    avg = {
      runnable_avg_sum = 21668,
      runnable_avg_period = 22496,
      last_runnable_update = 4553221849241,
      decay_count = 4342291,
      load_avg_contrib = 985
    }
  },
  rt = {
    run_list = {
      next = 0xffff8803d5fe6d08,
      prev = 0xffff8803d5fe6d08
    },
    timeout = 0,
    watchdog_stamp = 0,
    time_slice = 100,
    back = 0x0
  },
  dl = {
    rb_node = {
      __rb_parent_color = 18446612148789341496,
      rb_right = 0x0,
      rb_left = 0x0
    },
    dl_runtime = 0,
    dl_deadline = 0,
    dl_period = 0,
    dl_bw = 0,
    runtime = 0,
    deadline = 0,
    flags = 0,
    dl_throttled = 0,
    dl_new = 0,
    dl_boosted = 0,
    dl_yielded = 0,
    dl_timer = {
      node = {
        node = {
          __rb_parent_color = 18446612148789341592,
          rb_right = 0x0,
          rb_left = 0x0
        },
        expires = {
          tv64 = 0
        }
      },
      _softexpires = {
        tv64 = 0
      },
      function = 0x0,
      base = 0xffff88041e2cc8c0,
      state = 0
    }
  },
  preempt_notifiers = {
    first = 0x0
  },
  btrace_seq = 0,
  policy = 0,
  nr_cpus_allowed = 8,
  cpus_allowed = {
    bits = {255}
  },
  sched_info = {
    pcount = 281,
    run_delay = 2603230,
    last_arrival = 4553221846712,
    last_queued = 0
  },
  tasks = {
    next = 0xffff8803d5fe3458,
    prev = 0xffff8803b1fe82d8
  },
  pushable_tasks = {
    prio = 140,
    prio_list = {
      next = 0xffff8803d5fe6e30,
      prev = 0xffff8803d5fe6e30
    },
    node_list = {
      next = 0xffff8803d5fe6e40,
      prev = 0xffff8803d5fe6e40
    }
  },
  pushable_dl_tasks = {
    __rb_parent_color = 18446612148789341776,
    rb_right = 0x0,
    rb_left = 0x0
  },
  mm = 0xffff880362888e00,
  active_mm = 0xffff880362888e00,
  vmacache_seqnum = 16,
  vmacache = {0xffff88034789dc60, 0xffff880347b2e6e0, 0x0, 0xffff88034798c8f0},
  rss_stat = {
    events = 10,
    count = {0, 10, 0}
  },
  exit_state = 0,
  exit_code = 0,
  exit_signal = 17,
  pdeath_signal = 0,
  jobctl = 65536,
  personality = 0,
  in_execve = 0,
  in_iowait = 0,
  sched_reset_on_fork = 0,
  sched_contributes_to_load = 0,
  atomic_flags = 1,
  pid = 25873,
  tgid = 25873,
  real_parent = 0xffff8803b1fe8000,
  parent = 0xffff8803b1fe8000,
  children = {
    next = 0xffff8803d5fe6ef0,
    prev = 0xffff8803d5fe6ef0
  },
  sibling = {
    next = 0xffff8803b1fe83b0,
    prev = 0xffff8803b1fe83b0
  },
  group_leader = 0xffff8803d5fe6b40,
  ptraced = {
    next = 0xffff8803d5fe6f18,
    prev = 0xffff8803d5fe6f18
  },
  ptrace_entry = {
    next = 0xffff8803d5fe6f28,
    prev = 0xffff8803d5fe6f28
  },
  pids = {{
      node = {
        next = 0x0,
        pprev = 0xffff8803478a5b88
      },
      pid = 0xffff8803478a5b80
    }, {
      node = {
        next = 0xffff8803b1fe8410,
        pprev = 0xffff8803ee4afd90
      },
      pid = 0xffff8803ee4afd80
    }, {
      node = {
        next = 0xffff8803b1fe8428,
        pprev = 0xffff8803e7b85598
      },
      pid = 0xffff8803e7b85580
    }},
  thread_group = {
    next = 0xffff8803d5fe6f80,
    prev = 0xffff8803d5fe6f80
  },
  thread_node = {
    next = 0xffff880362888710,
    prev = 0xffff880362888710
  },
  vfork_done = 0x0,
  set_child_tid = 0x7f53d42569d0,
  clear_child_tid = 0x7feda06279d0,
  utime = 25000000,
  stime = 8000000,
  utimescaled = 25000000,
  stimescaled = 8000000,
  gtime = 0,
  prev_cputime = {
    utime = 0,
    stime = 0
  },
  vtime_seqlock = {
    seqcount = {
      sequence = 0
    },
    lock = {
      {
        rlock = {
          raw_lock = {
            {
              head_tail = 0,
              tickets = {
                head = 0 '\000',
                tail = 0 '\000'
              }
            }
          }
        }
      }
    }
  },
  vtime_snap = 0,
  vtime_snap_whence = VTIME_SLEEPING,
  nvcsw = 231,
  nivcsw = 50,
  start_time = 4559100753964,
  real_start_time = 4559100754077,
  min_flt = 2896,
  maj_flt = 0,
  cputime_expires = {
    utime = 0,
    stime = 0,
    sum_exec_runtime = 0
  },
  cpu_timers = {{
      next = 0xffff8803d5fe7050,
      prev = 0xffff8803d5fe7050
    }, {
      next = 0xffff8803d5fe7060,
      prev = 0xffff8803d5fe7060
    }, {
      next = 0xffff8803d5fe7070,
      prev = 0xffff8803d5fe7070
    }},
  real_cred = 0xffff88040afb06c0,
  cred = 0xffff88040afb06c0,
  comm = "python\000bash\000al\000",
  link_count = 0,
  total_link_count = 0,
  sysvsem = {
    undo_list = 0x0
  },
  sysvshm = {
    shm_clist = {
      next = 0xffff8803d5fe70b0,
      prev = 0xffff8803d5fe70b0
    }
  },
  last_switch_count = 281,
  thread = {
    tls_array = {{
        {
          {
            a = 0,
            b = 0
          },
          {
            limit0 = 0,
            base0 = 0,
            base1 = 0,
            type = 0,
            s = 0,
            dpl = 0,
            p = 0,
            limit = 0,
            avl = 0,
            l = 0,
            d = 0,
            g = 0,
            base2 = 0
          }
        }
      }, {
        {
          {
            a = 0,
            b = 0
          },
          {
            limit0 = 0,
            base0 = 0,
            base1 = 0,
            type = 0,
            s = 0,
            dpl = 0,
            p = 0,
            limit = 0,
            avl = 0,
            l = 0,
            d = 0,
            g = 0,
            base2 = 0
          }
        }
      }, {
        {
          {
            a = 0,
            b = 0
          },
          {
            limit0 = 0,
            base0 = 0,
            base1 = 0,
            type = 0,
            s = 0,
            dpl = 0,
            p = 0,
            limit = 0,
            avl = 0,
            l = 0,
            d = 0,
            g = 0,
            base2 = 0
          }
        }
      }},
    sp0 = 18446612143154692096,
    sp = 18446612143154690808,
    usersp = 25633912,
    es = 0,
    ds = 0,
    fsindex = 0,
    gsindex = 0,
    fs = 140658574784256,
    gs = 0,
    ptrace_bps = {0x0, 0x0, 0x0, 0x0},
    debugreg6 = 0,
    ptrace_dr7 = 0,
    cr2 = 140735308316664,
    trap_nr = 14,
    error_code = 6,
    fpu = {
      last_cpu = 3,
      has_fpu = 0,
      state = 0xffff8802862ba3c0
    },
    io_bitmap_ptr = 0x0,
    iopl = 0,
    io_bitmap_max = 0,
    fpu_counter = 25 '\031'
  },
  fs = 0xffff8803b1d8a280,
  files = 0xffff880385e50000,
  nsproxy = 0xffffffff81c3ab60 <init_nsproxy>,
  signal = 0xffff880362888700,
  sighand = 0xffff8803708a5280,
  blocked = {
    sig = {0}
  },
  real_blocked = {
    sig = {0}
  },
  saved_sigmask = {
    sig = {65536}
  },
  pending = {
    list = {
      next = 0xffff8803d5fe71c0,
      prev = 0xffff8803d5fe71c0
    },
    signal = {
      sig = {0}
    }
  },
  sas_ss_sp = 25627024,
  sas_ss_size = 8192,
  notifier = 0x0,
  notifier_data = 0x0,
  notifier_mask = 0x0,
  task_works = 0x0,
  audit_context = 0x0,
  seccomp = {
    mode = 2,
    filter = 0xffff880347846a40
  },
  parent_exec_id = 39,
  self_exec_id = 40,
  alloc_lock = {
    {
      rlock = {
        raw_lock = {
          {
            head_tail = 65535,
            tickets = {
              head = 255 '\377',
              tail = 255 '\377'
            }
          }
        }
      }
    }
  },
  pi_lock = {
    raw_lock = {
      {
        head_tail = 45746,
        tickets = {
          head = 178 '\262',
          tail = 178 '\262'
        }
      }
    }
  },
  pi_waiters = {
    rb_node = 0x0
  },
  pi_waiters_leftmost = 0x0,
  pi_blocked_on = 0x0,
  journal_info = 0x0,
  bio_list = 0x0,
  plug = 0x0,
  reclaim_state = 0x0,
  backing_dev_info = 0x0,
  io_context = 0x0,
  ptrace_message = 4,
  last_siginfo = 0x0,
  ioac = {<No data fields>},
  robust_list = 0x7feda06279e0,
  compat_robust_list = 0x0,
  pi_state_list = {
    next = 0xffff8803d5fe7298,
    prev = 0xffff8803d5fe7298
  },
  pi_state_cache = 0x0,
  perf_event_ctxp = {0x0, 0x0},
  perf_event_mutex = {
    count = {
      counter = 1
    },
    wait_lock = {
      {
        rlock = {
          raw_lock = {
            {
              head_tail = 0,
              tickets = {
                head = 0 '\000',
                tail = 0 '\000'
              }
            }
          }
        }
      }
    },
    wait_list = {
      next = 0xffff8803d5fe72c8,
      prev = 0xffff8803d5fe72c8
    },
    owner = 0x0,
    osq = {
      tail = {
        counter = 0
      }
    }
  },
  perf_event_list = {
    next = 0xffff8803d5fe72e8,
    prev = 0xffff8803d5fe72e8
  },
  rcu = {
    next = 0x0,
    func = 0x0
  },
  splice_pipe = 0x0,
  task_frag = {
    page = 0x0,
    offset = 0,
    size = 0
  },
  delays = 0xffff8803b1d8ae80,
  nr_dirtied = 0,
  nr_dirtied_pause = 32,
  dirty_paused_when = 0,
  timer_slack_ns = 50000,
  default_timer_slack_ns = 50000,
  curr_ret_stack = -1,
  ret_stack = 0x0,
  ftrace_timestamp = 0,
  trace_overrun = {
    counter = 0
  },
  tracing_graph_pause = {
    counter = 0
  },
  trace = 0,
  trace_recursion = 0,
  utask = 0x0
}

struct thread_info {
  task = 0xffff8803d5fe6b40,
  exec_domain = 0xffffffff81c2e6c0 <default_exec_domain>,
  flags = 258,
  status = 0,
  cpu = 3,
  saved_preempt_count = -2147483648,
  addr_limit = {
    seg = 140737488351232
  },
  restart_block = {
    fn = 0xffffffff81093ec0 <do_no_restart_syscall>,
    {
      futex = {
        uaddr = 0x0,
        val = 0,
        flags = 0,
        bitset = 0,
        time = 0,
        uaddr2 = 0x0
      },
      nanosleep = {
        clockid = 0,
        rmtp = 0x0,
        compat_rmtp = 0x0,
        expires = 0
      },
      poll = {
        ufds = 0x0,
        nfds = 0,
        has_timeout = 0,
        tv_sec = 0,
        tv_nsec = 0
      }
    }
  },
  sysenter_return = 0x0,
  sig_on_uaccess_error = 0,
  uaccess_err = 0
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
