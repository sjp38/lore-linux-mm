Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 712646B02C3
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 20:54:48 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id l45so19138923ote.1
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 17:54:48 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id e185si1818436oif.86.2017.06.15.17.54.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Jun 2017 17:54:46 -0700 (PDT)
Message-Id: <201706160054.v5G0sY7c064781@www262.sakura.ne.jp>
Subject: Re: Re: [patch] mm, oom: prevent additional oom kills before memory is
 freed
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Fri, 16 Jun 2017 09:54:34 +0900
References: <alpine.DEB.2.10.1706151459530.64172@chino.kir.corp.google.com> <20170615221236.GB22341@dhcp22.suse.cz>
In-Reply-To: <20170615221236.GB22341@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Thu 15-06-17 15:03:17, David Rientjes wrote:
> > On Thu, 15 Jun 2017, Michal Hocko wrote:
> > 
> > > > Yes, quite a bit in testing.
> > > > 
> > > > One oom kill shows the system to be oom:
> > > > 
> > > > [22999.488705] Node 0 Normal free:90484kB min:90500kB ...
> > > > [22999.488711] Node 1 Normal free:91536kB min:91948kB ...
> > > > 
> > > > followed up by one or more unnecessary oom kills showing the oom killer 
> > > > racing with memory freeing of the victim:
> > > > 
> > > > [22999.510329] Node 0 Normal free:229588kB min:90500kB ...
> > > > [22999.510334] Node 1 Normal free:600036kB min:91948kB ...
> > > > 
> > > > The patch is absolutely required for us to prevent continuous oom killing 
> > > > of processes after a single process has been oom killed and its memory is 
> > > > in the process of being freed.
> > > 
> > > OK, could you play with the patch/idea suggested in
> > > http://lkml.kernel.org/r/20170615122031.GL1486@dhcp22.suse.cz?
> > > 
> > 
> > I cannot, I am trying to unblock a stable kernel release to my production 
> > that is obviously fixed with this patch and cannot experiment with 
> > uncompiled and untested patches that introduce otherwise unnecessary 
> > locking into the __mmput() path and is based on speculation rather than 
> > hard data that __mmput() for some reason stalls for the oom victim's mm.  
> > I was hoping that this fix could make it in time for 4.12 since 4.12 kills 
> > 1-4 processes unnecessarily for each oom condition and then can review any 
> > tested solution you may propose at a later time.
> 
> I am sorry but I have really hard to make the oom reaper a reliable way
> to stop all the potential oom lockups go away. I do not want to
> reintroduce another potential lockup now. I also do not see why any
> solution should be rushed into. I have proposed a way to go and unless
> it is clear that this is not a way forward then I simply do not agree
> with any partial workarounds or shortcuts.

And the patch you proposed is broken.

----------
[  161.846202] Out of memory: Kill process 6331 (a.out) score 999 or sacrifice child
[  161.850327] Killed process 6331 (a.out) total-vm:4172kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
[  161.858503] ------------[ cut here ]------------
[  161.861512] kernel BUG at mm/memory.c:1381!
[  161.864154] invalid opcode: 0000 [#1] SMP
[  161.866599] Modules linked in: nf_conntrack_netbios_ns nf_conntrack_broadcast ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_security ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_security iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables coretemp crct10dif_pclmul crc32_pclmul ghash_clmulni_intel vmw_balloon pcspkr ppdev shpchp parport_pc i2c_piix4 parport vmw_vmci xfs libcrc32c vmwgfx crc32c_intel drm_kms_helper serio_raw ttm drm e1000 mptspi scsi_transport_spi mptscsih mptbase ata_generic pata_acpi floppy
[  161.896811] CPU: 1 PID: 43 Comm: oom_reaper Not tainted 4.12.0-rc5+ #221
[  161.900458] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  161.905588] task: ffff937bb1c13200 task.stack: ffffa13cc0b94000
[  161.908876] RIP: 0010:unmap_page_range+0xa19/0xa60
[  161.911739] RSP: 0000:ffffa13cc0b97d08 EFLAGS: 00010282
[  161.914767] RAX: 0000000000000000 RBX: ffff937ba9e89300 RCX: 0000000000401000
[  161.918543] RDX: ffff937baf707440 RSI: ffff937baf707680 RDI: ffffa13cc0b97df0
[  161.922314] RBP: ffffa13cc0b97de0 R08: 0000000000000000 R09: 0000000000000000
[  161.926059] R10: 0000000000000000 R11: 000000001f1e8b15 R12: ffff937ba9e893c0
[  161.929789] R13: ffff937ba4198000 R14: ffff937baf707440 R15: ffff937ba9e89300
[  161.933509] FS:  0000000000000000(0000) GS:ffff937bb3800000(0000) knlGS:0000000000000000
[  161.937615] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  161.940774] CR2: 0000561fb93c1b00 CR3: 000000009ee11000 CR4: 00000000001406e0
[  161.944477] Call Trace:
[  161.946333]  ? __mutex_lock+0x574/0x950
[  161.948678]  ? __mutex_lock+0xce/0x950
[  161.950996]  ? __oom_reap_task_mm+0x49/0x170
[  161.953485]  __oom_reap_task_mm+0xd8/0x170
[  161.955893]  oom_reaper+0xac/0x1c0
[  161.957992]  ? remove_wait_queue+0x60/0x60
[  161.960688]  kthread+0x117/0x150
[  161.962719]  ? trace_event_raw_event_oom_score_adj_update+0xe0/0xe0
[  161.965920]  ? kthread_create_on_node+0x70/0x70
[  161.968417]  ret_from_fork+0x2a/0x40
[  161.970530] Code: 13 fb ff ff e9 25 fc ff ff 48 83 e8 01 e9 77 fc ff ff 48 83 e8 01 e9 62 fe ff ff e8 22 0a e6 ff 48 8b 7d 98 e8 09 ba ff ff 0f 0b <0f> 0b 48 83 e9 01 e9 a1 fb ff ff e8 03 a5 06 00 48 83 e9 01 e9 
[  161.979386] RIP: unmap_page_range+0xa19/0xa60 RSP: ffffa13cc0b97d08
[  161.982611] ---[ end trace ef2b349884b0aaa4 ]---
----------

Please carefully consider the reason why there is VM_BUG_ON() in __mmput(),
and clarify in your patch that what are possible side effects of racing
uprobe_clear_state()/exit_aio()/ksm_exit()/exit_mmap() etc. with
__oom_reap_task_mm() and clarify in your patch that there is no possibility
of waiting for direct/indirect memory allocation inside free_pgtables(),
in addition to fixing the bug above.

----------
	VM_BUG_ON(atomic_read(&mm->mm_users));

	uprobe_clear_state(mm);
	exit_aio(mm);
	ksm_exit(mm);
	khugepaged_exit(mm); /* must run before exit_mmap */
	exit_mmap(mm);
----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
