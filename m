Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 5A92A6B0031
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 14:44:18 -0400 (EDT)
Received: by mail-ig0-f178.google.com with SMTP id uq10so3246062igb.17
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 11:44:17 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e5si19213920igy.19.2014.07.15.11.44.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jul 2014 11:44:17 -0700 (PDT)
Date: Tue, 15 Jul 2014 14:43:58 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [patch 13/13] mm: memcontrol: rewrite uncharge API
Message-ID: <20140715184358.GA31550@nhori.bos.redhat.com>
References: <1403124045-24361-1-git-send-email-hannes@cmpxchg.org>
 <1403124045-24361-14-git-send-email-hannes@cmpxchg.org>
 <20140715155537.GA19454@nhori.bos.redhat.com>
 <20140715160735.GB29269@dhcp22.suse.cz>
 <20140715173439.GU29639@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140715173439.GU29639@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Jul 15, 2014 at 01:34:39PM -0400, Johannes Weiner wrote:
> On Tue, Jul 15, 2014 at 06:07:35PM +0200, Michal Hocko wrote:
> > On Tue 15-07-14 11:55:37, Naoya Horiguchi wrote:
> > > On Wed, Jun 18, 2014 at 04:40:45PM -0400, Johannes Weiner wrote:
> > > ...
> > > > diff --git a/mm/swap.c b/mm/swap.c
> > > > index a98f48626359..3074210f245d 100644
> > > > --- a/mm/swap.c
> > > > +++ b/mm/swap.c
> > > > @@ -62,6 +62,7 @@ static void __page_cache_release(struct page *page)
> > > >  		del_page_from_lru_list(page, lruvec, page_off_lru(page));
> > > >  		spin_unlock_irqrestore(&zone->lru_lock, flags);
> > > >  	}
> > > > +	mem_cgroup_uncharge(page);
> > > >  }
> > > >  
> > > >  static void __put_single_page(struct page *page)
> > > 
> > > This seems to cause a list breakage in hstate->hugepage_activelist
> > > when freeing a hugetlbfs page.
> > 
> > This looks like a fall out from
> > http://marc.info/?l=linux-mm&m=140475936311294&w=2
> > 
> > I didn't get to review this one but the easiest fix seems to be check
> > HugePage and do not call uncharge.
> 
> Yes, that makes sense.  I'm also moving the uncharge call into
> __put_single_page() and __put_compound_page() so that PageHuge(), a
> function call, only needs to be checked for compound pages.
> 
> > > For hugetlbfs, we uncharge in free_huge_page() which is called after
> > > __page_cache_release(), so I think that we don't have to uncharge here.
> > > 
> > > In my testing, moving mem_cgroup_uncharge() inside if (PageLRU) block
> > > fixed the problem, so if that works for you, could you fold the change
> > > into your patch?
> 
> Memcg pages that *do* need uncharging might not necessarily be on the
> LRU list.

OK.

> Does the following work for you?

Unfortunately, with this change I saw the following bug message when
stressing with hugepage migration.
move_to_new_page() is called by unmap_and_move_huge_page() too, so
we need some hugetlb related code around mem_cgroup_migrate().

[   76.753994] page:ffffea0000d18000 count:2 mapcount:0 mapping:ffff88003dc2c738 index:0x8
[   76.755171] page flags: 0x1fffff80004019(locked|uptodate|dirty|head)
[   76.756195] page dumped because: VM_BUG_ON_PAGE(PageCgroupUsed(pc))
[   76.758869] pc:ffff88003ebc6000 pc->flags:1 pc->mem_cgroup:ffff88011e19a800
[   76.760158] ------------[ cut here ]------------
[   76.760878] kernel BUG at /src/linux-dev/mm/memcontrol.c:2707!
[   76.761119] invalid opcode: 0000 [#1] SMP
[   76.761119] Modules linked in: bnep bluetooth ip6t_rpfilter cfg80211 ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 rfkill xt_conntrack ebtable_nat ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_mangle ip6table_security ip6table_raw ip6table_filter ip6_tables iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_security iptable_raw ppdev parport_pc parport serio_raw microcode i2c_piix4 virtio_balloon floppy pcspkr nfsd auth_rpcgss oid_registry nfs_acl lockd sunrpc virtio_blk virtio_net ata_generic pata_acpi
[   76.761119] CPU: 1 PID: 1536 Comm: mbind_fuzz Not tainted 3.15.0-140715-1353-00016-g8d61f2a989c8 #263
[   76.761119] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   76.761119] task: ffff88011d6e8000 ti: ffff8800bbd84000 task.ti: ffff8800bbd84000
[   76.761119] RIP: 0010:[<ffffffff811fee3b>]  [<ffffffff811fee3b>] commit_charge+0x28b/0x2b0
[   76.761119] RSP: 0018:ffff8800bbd87ce8  EFLAGS: 00010292
[   76.761119] RAX: 000000000000003f RBX: ffffea0000d18000 RCX: 0000000000000000
[   76.761119] RDX: 0000000000000001 RSI: ffff88007ec0d318 RDI: ffff88007ec0d318
[   76.761119] RBP: ffff8800bbd87d28 R08: 000000000000000a R09: 0000000000000000
[   76.761119] R10: 0000000000000000 R11: ffff8800bbd879be R12: ffff88011e19a800
[   76.761119] R13: 0000000000000000 R14: 0000000000000000 R15: ffff88003ebc6000
[   76.761119] FS:  00007f7441c3a740(0000) GS:ffff88007ec00000(0000) knlGS:0000000000000000
[   76.761119] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   76.761119] CR2: 00007ffffb5b8950 CR3: 000000003740e000 CR4: 00000000000006e0
[   76.761119] Stack:
[   76.761119]  0000000000000002 0000000000000001 00000200bbd87d28 ffffea0002b70000
[   76.761119]  ffffea0000d18000 0000000000000000 0000000000000001 0000000000000000
[   76.761119]  ffff8800bbd87d50 ffffffff81202380 ffffea0000d18000 ffffea0002b70000
[   76.761119] Call Trace:
[   76.761119]  [<ffffffff81202380>] mem_cgroup_migrate+0x100/0x1d0
[   76.761119]  [<ffffffff811f3e4d>] move_to_new_page+0xbd/0x110
[   76.761119]  [<ffffffff811f40d3>] unmap_and_move_huge_page+0x233/0x290
[   76.761119]  [<ffffffff811f477d>] migrate_pages+0xad/0x1e0
[   76.761119]  [<ffffffff811e43f0>] ? alloc_pages_vma+0x1a0/0x1a0
[   76.761119]  [<ffffffff811e4cea>] do_mbind+0x2ea/0x380
[   76.761119]  [<ffffffff811e4e1b>] SyS_mbind+0x9b/0xb0
[   76.761119]  [<ffffffff81742a12>] system_call_fastpath+0x16/0x1b
[   76.761119] Code: 13 45 19 c0 41 83 e0 02 48 c1 ea 06 83 e2 01 48 83 fa 01 41 83 d8 ff e9 30 ff ff ff 48 c7 c6 20 d0 a8 81 48 89 df e8 55 fb f9 ff <0f> 0b 48 c7 c6 f3 e2 a8 81 48 89 df e8 44 fb f9 ff 0f 0b 48 c7
[   76.761119] RIP  [<ffffffff811fee3b>] commit_charge+0x28b/0x2b0
[   76.761119]  RSP <ffff8800bbd87ce8>
[   76.801726] ---[ end trace ddfccaa1a6a58baa ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
