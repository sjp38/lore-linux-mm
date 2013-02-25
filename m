From: Sasha Levin <sasha.levin@oracle.com>
Subject: mm: BUG in mempolicy's sp_insert
Date: Mon, 25 Feb 2013 08:30:37 -0500
Message-ID: <512B677D.1040501@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Dave Jones <davej@redhat.com>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

Hi all,

While fuzzing with trinity inside a KVM tools guest running latest -next kernel,
I've stumbled on the following BUG:

[13551.830090] ------------[ cut here ]------------
[13551.830090] kernel BUG at mm/mempolicy.c:2187!
[13551.830090] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[13551.830090] Dumping ftrace buffer:
[13551.830090]    (ftrace buffer empty)
[13551.830090] Modules linked in:
[13551.830090] CPU 5
[13551.830090] Pid: 29310, comm: trinity Tainted: G        W    3.8.0-next-20130222-sasha-00042-gcbfe956 #995
[13551.830090] RIP: 0010:[<ffffffff812637b3>]  [<ffffffff812637b3>] sp_insert+0x33/0xb0
[13551.830090] RSP: 0018:ffff880087e03ca8  EFLAGS: 00010287
[13551.830090] RAX: ffff88009a7a77d0 RBX: ffff88009a7a7c38 RCX: 0000000000000000
[13551.830090] RDX: 0000000000000010 RSI: ffff88009a7a7c38 RDI: ffff88009a5473b0
[13551.830090] RBP: ffff880087e03cb8 R08: 0000000000000001 R09: 0000000000000001
[13551.830090] R10: 0000000000000000 R11: 0000000000000000 R12: ffff88009a5473b0
[13551.830090] R13: ffff88009a7a77d0 R14: 000000000000000f R15: 0000000000000000
[13551.830090] FS:  00007f1b28931700(0000) GS:ffff8800baa00000(0000) knlGS:0000000000000000
[13551.830090] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[13551.830090] CR2: 00000000001f1005 CR3: 000000009c0a3000 CR4: 00000000000406e0
[13551.830090] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[13551.830090] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[13551.830090] Process trinity (pid: 29310, threadinfo ffff880087e02000, task ffff880018038000)
[13551.830090] Stack:
[13551.830090]  0000000000000001 0000000000000001 ffff880087e03d18 ffffffff812642ab
[13551.830090]  ffff88009a547678 0000000000000000 ffff88009a5cfc20 ffff88009a5473b8
[13551.830090]  ffff88009a5476e0 000000000000000e ffff88009551c800 ffff88009a5473b0
[13551.830090] Call Trace:
[13551.830090]  [<ffffffff812642ab>] shared_policy_replace+0x13b/0x210
[13551.830090]  [<ffffffff81265436>] mpol_set_shared_policy+0x156/0x160
[13551.830090]  [<ffffffff8124c59a>] ? __split_vma+0x17a/0x210
[13551.830090]  [<ffffffff8122ee87>] shmem_set_policy+0x27/0x30
[13551.830090]  [<ffffffff812663e0>] mbind_range+0x1e0/0x260
[13551.830090]  [<ffffffff8126725a>] do_mbind+0x22a/0x330
[13551.830090]  [<ffffffff812673e9>] sys_mbind+0x89/0xb0
[13551.830090]  [<ffffffff84031fd0>] tracesys+0xdd/0xe2
[13551.830090] Code: c9 53 48 89 f3 48 83 ec 08 eb 2a 48 8b 50 18 48 39 53 18 73 06 48 8d 50 10 eb 17 48 8b 50 20 48 39 53 20 76
06 48 8d 50 08 eb 07 <0f> 0b 0f 1f 00 eb fe 48 89 c1 48 8b 02 48 85 c0 75 ce 48 89 0b
[13551.830090] RIP  [<ffffffff812637b3>] sp_insert+0x33/0xb0
[13551.830090]  RSP <ffff880087e03ca8>
[13552.663006] ---[ end trace 41967793cddea94b ]---


Thanks,
Sasha
