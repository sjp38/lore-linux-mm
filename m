Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C1BFC6B0038
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 17:56:43 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id f188so459732669pgc.1
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 14:56:43 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n34si26793254pld.250.2016.11.29.14.56.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 14:56:42 -0800 (PST)
Date: Tue, 29 Nov 2016 14:56:54 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 189181] New: BUG: unable to handle kernel NULL pointer
 dereference in mem_cgroup_node_nr_lru_pages
Message-Id: <20161129145654.c48bebbd684edcd6f64a03fe@linux-foundation.org>
In-Reply-To: <bug-189181-27@https.bugzilla.kernel.org/>
References: <bug-189181-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, marmarek@mimuw.edu.pl


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sat, 26 Nov 2016 15:10:16 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=189181
> 
>             Bug ID: 189181
>            Summary: BUG: unable to handle kernel NULL pointer dereference
>                     in mem_cgroup_node_nr_lru_pages
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 4.8.10
>           Hardware: Intel
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Slab Allocator
>           Assignee: akpm@linux-foundation.org
>           Reporter: marmarek@mimuw.edu.pl
>         Regression: No
> 
> Created attachment 245931
>   --> https://bugzilla.kernel.org/attachment.cgi?id=245931&action=edit
> Full console log
> 
> Shortly after system startup sometimes (about 1/30 times) I get this:
> 
> [   15.665196] BUG: unable to handle kernel NULL pointer dereference at
> 0000000000000400
> [   15.665213] IP: [<ffffffff8122d520>] mem_cgroup_node_nr_lru_pages+0x20/0x40
> [   15.665225] PGD 0 
> [   15.665230] Oops: 0000 [#1] SMP
> [   15.665235] Modules linked in: fuse xt_nat xen_netback xt_REDIRECT
> nf_nat_redirect ip6table_filter ip6_tables xt_conntrack ipt_MASQUERADE
> nf_nat_masquerade_ipv4 iptable_nat nf_conntrack_i
> pv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack intel_rapl
> x86_pkg_temp_thermal coretemp crct10dif_pclmul crc32_pclmul crc32c_intel
> ghash_clmulni_intel pcspkr dummy_hcd udc_core u2mfn(O) 
> xen_blkback xenfs xen_privcmd xen_blkfront
> [   15.665285] CPU: 0 PID: 60 Comm: kswapd0 Tainted: G           O   
> 4.8.10-12.pvops.qubes.x86_64 #1
> [   15.665292] task: ffff880011863b00 task.stack: ffff880011868000
> [   15.665297] RIP: e030:[<ffffffff8122d520>]  [<ffffffff8122d520>]
> mem_cgroup_node_nr_lru_pages+0x20/0x40
> [   15.665307] RSP: e02b:ffff88001186bc70  EFLAGS: 00010293
> [   15.665311] RAX: 0000000000000000 RBX: ffff88001186bd20 RCX:
> 0000000000000002
> [   15.665317] RDX: 000000000000000c RSI: 0000000000000000 RDI:
> 0000000000000000
> [   15.665322] RBP: ffff88001186bc70 R08: 28f5c28f5c28f5c3 R09:
> 0000000000000000
> [   15.665327] R10: 0000000000006c34 R11: 0000000000000333 R12:
> 00000000000001f6
> [   15.665332] R13: ffffffff81c6f6a0 R14: 0000000000000000 R15:
> 0000000000000000
> [   15.665343] FS:  0000000000000000(0000) GS:ffff880013c00000(0000)
> knlGS:ffff880013d00000
> [   15.665351] CS:  e033 DS: 0000 ES: 0000 CR0: 0000000080050033
> [   15.665358] CR2: 0000000000000400 CR3: 00000000122f2000 CR4:
> 0000000000042660
> [   15.665366] Stack:
> [   15.665371]  ffff88001186bc98 ffffffff811e0dda 00000000000002eb
> 0000000000000080
> [   15.665384]  ffffffff81c6f6a0 ffff88001186bd70 ffffffff811c36d9
> 0000000000000000
> [   15.665397]  ffff88001186bcb0 ffff88001186bcb0 ffff88001186bcc0
> 000000000000abc5
> [   15.665410] Call Trace:
> [   15.665419]  [<ffffffff811e0dda>] count_shadow_nodes+0x9a/0xa0
> [   15.665428]  [<ffffffff811c36d9>] shrink_slab.part.42+0x119/0x3e0
> [   15.666049]  [<ffffffff811c83ec>] shrink_node+0x22c/0x320
> [   15.666049]  [<ffffffff811c928c>] kswapd+0x32c/0x700
> [   15.666049]  [<ffffffff811c8f60>] ? mem_cgroup_shrink_node+0x180/0x180
> [   15.666049]  [<ffffffff810c1b08>] kthread+0xd8/0xf0
> [   15.666049]  [<ffffffff817a3abf>] ret_from_fork+0x1f/0x40
> [   15.666049]  [<ffffffff810c1a30>] ? kthread_create_on_node+0x190/0x190
> [   15.666049] Code: 66 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 3b 35 dd
> eb b1 00 55 48 89 e5 73 2c 89 d2 31 c9 31 c0 4c 63 ce 48 0f a3 ca 73 13 <4a> 8b
> b4 cf 00 04 00 00 41 89 c8 4a 03
>  84 c6 80 00 00 00 83 c1 
> [   15.666049] RIP  [<ffffffff8122d520>] mem_cgroup_node_nr_lru_pages+0x20/0x40
> [   15.666049]  RSP <ffff88001186bc70>
> [   15.666049] CR2: 0000000000000400
> [   15.666049] ---[ end trace 100494b9edbdfc4d ]---
> 
> After this, there is another "unable to handle kerneel paging request" I guess
> because of do_exit in kswapd0, then a lot of soft lockups and system is
> unusable (see full log attached).
> 
> This is running in PV domU on Xen 4.7.0 (the same also happens on Xen 4.6.3).
> Same happens on 4.8.7 too. Previously it was working on v4.4.31 without any
> problem.
> 
> -- 
> You are receiving this mail because:
> You are the assignee for the bug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
