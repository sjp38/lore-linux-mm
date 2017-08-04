Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5CA156B0719
	for <linux-mm@kvack.org>; Fri,  4 Aug 2017 03:42:16 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id x43so4868830wrb.9
        for <linux-mm@kvack.org>; Fri, 04 Aug 2017 00:42:16 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 33si3230675wrv.199.2017.08.04.00.42.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 04 Aug 2017 00:42:14 -0700 (PDT)
Date: Fri, 4 Aug 2017 09:42:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: fix potential data corruption when oom_reaper
 races with writer
Message-ID: <20170804074212.GA26029@dhcp22.suse.cz>
References: <20170803135902.31977-1-mhocko@kernel.org>
 <201708040646.v746kkhC024636@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201708040646.v746kkhC024636@www262.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Wenwei Tao <wenwei.tww@alibaba-inc.com>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>

On Fri 04-08-17 15:46:46, Tetsuo Handa wrote:
> Michal Hocko wrote:
> >                          So there is a race window when some threads
> > won't have fatal_signal_pending while the oom_reaper could start
> > unmapping the address space. generic_perform_write could then write
> > zero page to the page cache and corrupt data.
> 
> Oh, simple generic_perform_write() ?
> 
> > 
> > The race window is rather small and close to impossible to happen but it
> > would be better to have it covered.
> 
> OK, I confirmed that this problem is easily reproducible using below reproducer.

Yeah, I can imagine this could be triggered artificially. I am somehow
more skeptical about real life oom scenarios to trigger this though.
Anyway, thanks for your test case!
 
> Applying your patch seems to avoid this problem, but as far as I tested
> your patch seems to trivially trigger something lock related problem.
> Is your patch really safe?

> ----------
> [   58.539455] Out of memory: Kill process 1056 (a.out) score 603 or sacrifice child
> [   58.543943] Killed process 1056 (a.out) total-vm:4268108kB, anon-rss:2246048kB, file-rss:0kB, shmem-rss:0kB
> [   58.544245] a.out (1169) used greatest stack depth: 11664 bytes left
> [   58.557471] DEBUG_LOCKS_WARN_ON(depth <= 0)
> [   58.557480] ------------[ cut here ]------------
> [   58.564407] WARNING: CPU: 6 PID: 1339 at kernel/locking/lockdep.c:3617 lock_release+0x172/0x1e0
> [   58.569076] Modules linked in: nf_conntrack_netbios_ns nf_conntrack_broadcast ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter coretemp ppdev pcspkr vmw_balloon vmw_vmci shpchp sg i2c_piix4 parport_pc parport ip_tables xfs libcrc32c sr_mod sd_mod cdrom ata_generic pata_acpi serio_raw mptspi scsi_transport_spi mptscsih ahci e1000 libahci ata_piix mptbase libata
> [   58.599401] CPU: 6 PID: 1339 Comm: a.out Not tainted 4.13.0-rc3-next-20170803+ #142
> [   58.604126] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
> [   58.609790] task: ffff9d90df888040 task.stack: ffffa07084854000
> [   58.613944] RIP: 0010:lock_release+0x172/0x1e0
> [   58.617622] RSP: 0000:ffffa07084857e58 EFLAGS: 00010082
> [   58.621533] RAX: 000000000000001f RBX: ffff9d90df888040 RCX: 0000000000000000
> [   58.626074] RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffffffffa30d4ba4
> [   58.630572] RBP: ffffa07084857e98 R08: 0000000000000000 R09: 0000000000000001
> [   58.635016] R10: 0000000000000000 R11: 000000000000001f R12: ffffa07084857f58
> [   58.639694] R13: ffff9d90f60d6cd0 R14: 0000000000000000 R15: ffffffffa305cb6e
> [   58.644200] FS:  00007fb932730740(0000) GS:ffff9d90f9f80000(0000) knlGS:0000000000000000
> [   58.648989] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [   58.652903] CR2: 000000000040092f CR3: 0000000135229000 CR4: 00000000000606e0
> [   58.657280] Call Trace:
> [   58.659989]  up_read+0x1a/0x40
> [   58.662825]  __do_page_fault+0x28e/0x4c0
> [   58.665946]  do_page_fault+0x30/0x80
> [   58.668911]  page_fault+0x28/0x30

OK, I know what is going on here. The page fault must have returned with
VM_FAULT_RETRY when the caller drops mmap_sem. My patch overwrites the
this error code so the page fault path doesn't know that the lock is no
longer held and releases is unconditionally. This is a preexisting
problem introduced by 3f70dc38cec2 ("mm: make sure that kthreads will
not refault oom reaped memory"). I should have considered this option.

I believe the easiest way around this is the following patch
---
