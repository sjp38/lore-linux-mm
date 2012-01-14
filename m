Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 20FC76B004F
	for <linux-mm@kvack.org>; Sat, 14 Jan 2012 12:10:50 -0500 (EST)
Received: by wgbds11 with SMTP id ds11so3619859wgb.26
        for <linux-mm@kvack.org>; Sat, 14 Jan 2012 09:10:48 -0800 (PST)
Message-ID: <1326561043.5287.24.camel@edumazet-laptop>
Subject: Re: Hung task when calling clone() due to netfilter/slab
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 14 Jan 2012 18:10:43 +0100
In-Reply-To: <1326558605.19951.7.camel@lappy>
References: <1326558605.19951.7.camel@lappy>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: Dave Jones <davej@redhat.com>, davem <davem@davemloft.net>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, kaber@trash.net, pablo@netfilter.org, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>

Le samedi 14 janvier 2012 A  18:30 +0200, Sasha Levin a A(C)crit :
> Hi All,
> 
> I've stumbled on the following oops when testing the trinity fuzzer using KVM tool, running on the latest -next kernel:
> 
> [ 3960.845373] INFO: task trinity:31661 blocked for more than 120 seconds.
> [ 3960.846757] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [ 3960.850245] trinity         D ffff880008e89610  4952 31661   2197 0x00000004
> [ 3960.855032]  ffff880008e39830 0000000000000086 ffff880008e39fd8 ffff880008e89610
> [ 3960.859289]  00000000001d3980 ffff880008e39fd8 ffff880008e38000 00000000001d3980
> [ 3960.862723]  00000000001d3980 00000000001d3980 ffff880008e39fd8 00000000001d3980
> [ 3960.866083] Call Trace:
> [ 3960.867332]  [<ffffffff825830ea>] schedule+0x3a/0x50
> [ 3960.869477]  [<ffffffff82581285>] schedule_timeout+0x245/0x2c0
> [ 3960.871996]  [<ffffffff811023ee>] ? mark_held_locks+0x6e/0x130
> [ 3960.875599]  [<ffffffff810ffb62>] ? lock_release_holdtime+0xb2/0x160
> [ 3960.879156]  [<ffffffff8258450b>] ? _raw_spin_unlock_irq+0x2b/0x70
> [ 3960.881682]  [<ffffffff810de041>] ? get_parent_ip+0x11/0x50
> [ 3960.883907]  [<ffffffff82583880>] wait_for_common+0x120/0x170
> [ 3960.886190]  [<ffffffff810dc930>] ? try_to_wake_up+0x320/0x320
> [ 3960.888570]  [<ffffffff82583978>] wait_for_completion+0x18/0x20
> [ 3960.890968]  [<ffffffff810c5595>] call_usermodehelper_exec+0x1b5/0x1d0
> [ 3960.893583]  [<ffffffff825837a4>] ? wait_for_common+0x44/0x170
> [ 3960.895907]  [<ffffffff8182aa58>] kobject_uevent_env+0x4e8/0x580
> [ 3960.898310]  [<ffffffff8182aafb>] kobject_uevent+0xb/0x10
> [ 3960.900577]  [<ffffffff811b59a1>] sysfs_slab_add+0xb1/0x210
> [ 3960.902830]  [<ffffffff811b74db>] kmem_cache_create+0xcb/0x2f0
> [ 3960.905704]  [<ffffffff8216c72d>] nf_conntrack_init+0x9d/0x380
> [ 3960.908797]  [<ffffffff8216d11f>] nf_conntrack_net_init+0xf/0x1a0
> [ 3960.911065]  [<ffffffff821195a2>] ops_init+0x42/0x180
> [ 3960.913192]  [<ffffffff8211974b>] setup_net+0x6b/0x100
> [ 3960.915308]  [<ffffffff82119ba6>] copy_net_ns+0x86/0x110
> [ 3960.917534]  [<ffffffff810d4049>] create_new_namespaces+0xd9/0x190
> [ 3960.920048]  [<ffffffff810d4224>] copy_namespaces+0x84/0xc0
> [ 3960.922326]  [<ffffffff810aa471>] copy_process+0xa21/0x1480
> [ 3960.924328]  [<ffffffff810d3d9e>] ? up_read+0x1e/0x40
> [ 3960.925327]  [<ffffffff810aaf83>] do_fork+0x73/0x340
> [ 3960.926273]  [<ffffffff811026dd>] ? trace_hardirqs_on+0xd/0x10
> [ 3960.927372]  [<ffffffff82581ea9>] ? mutex_unlock+0x9/0x10
> [ 3960.928422]  [<ffffffff812c4d13>] ? ext4_sync_file+0xa3/0x340
> [ 3960.929487]  [<ffffffff8258525d>] ? retint_swapgs+0x13/0x1b
> [ 3960.930520]  [<ffffffff810554b3>] sys_clone+0x23/0x30
> [ 3960.931475]  [<ffffffff82585ec3>] stub_clone+0x13/0x20
> [ 3960.932490]  [<ffffffff82585b39>] ? system_call_fastpath+0x16/0x1b
> [ 3960.933655] 2 locks held by trinity/31661:
> [ 3960.934413]  #0:  (net_mutex){+.+.+.}, at: [<ffffffff82119b9e>] copy_net_ns+0x7e/0x110
> [ 3960.936057]  #1:  (slub_lock){+.+.+.}, at: [<ffffffff811b7451>] kmem_cache_create+0x41/0x2f0
> [ 3960.937810] Kernel panic - not syncing: hung_task: blocked tasks
> 
> I had two trinity processes running, and both were stuck at clone() syscalls:
> 
> clone(clone_flags=0xcc2820ff, newsp=0xf3f270[page_0xff], parent_tid=0xf3f270[page_0xff], child_tid=0x400000, regs=0xf41290[page_allocs])
> clone(clone_flags=0x45706000, newsp=0xf3f270[page_0xff], parent_tid=0x7f9bf26f0000, child_tid=0xf3f270[page_0xff], regs=0xf41290[page_allocs])
> 
> This is the second time I got this oops, and both times it originated with clone calling up to the netfilter connection tracker code, so I don't think that it's coincidental that thats the origin.
> 

Apparently SLUB calls sysfs_slab_add() from kmem_cache_create() while
still holding slub_lock.

So if the task launched needs to "cat /proc/slabinfo" or anything
needing slub_lock, its a deadlock.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
