Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f178.google.com (mail-vc0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id DB80A6B0036
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 16:50:09 -0400 (EDT)
Received: by mail-vc0-f178.google.com with SMTP id la4so4738995vcb.37
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 13:50:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id bf17si5460488vdb.104.2014.07.15.13.50.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jul 2014 13:50:08 -0700 (PDT)
Date: Tue, 15 Jul 2014 16:49:53 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [patch 13/13] mm: memcontrol: rewrite uncharge API
Message-ID: <20140715204953.GA21016@nhori.bos.redhat.com>
References: <1403124045-24361-1-git-send-email-hannes@cmpxchg.org>
 <1403124045-24361-14-git-send-email-hannes@cmpxchg.org>
 <20140715155537.GA19454@nhori.bos.redhat.com>
 <20140715160735.GB29269@dhcp22.suse.cz>
 <20140715173439.GU29639@cmpxchg.org>
 <20140715184358.GA31550@nhori.bos.redhat.com>
 <20140715190454.GW29639@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140715190454.GW29639@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Jul 15, 2014 at 03:04:54PM -0400, Johannes Weiner wrote:
> On Tue, Jul 15, 2014 at 02:43:58PM -0400, Naoya Horiguchi wrote:
> > On Tue, Jul 15, 2014 at 01:34:39PM -0400, Johannes Weiner wrote:
> > > On Tue, Jul 15, 2014 at 06:07:35PM +0200, Michal Hocko wrote:
> > > > On Tue 15-07-14 11:55:37, Naoya Horiguchi wrote:
> > > > > On Wed, Jun 18, 2014 at 04:40:45PM -0400, Johannes Weiner wrote:
> > > > > ...
> > > > > > diff --git a/mm/swap.c b/mm/swap.c
> > > > > > index a98f48626359..3074210f245d 100644
> > > > > > --- a/mm/swap.c
> > > > > > +++ b/mm/swap.c
> > > > > > @@ -62,6 +62,7 @@ static void __page_cache_release(struct page *page)
> > > > > >  		del_page_from_lru_list(page, lruvec, page_off_lru(page));
> > > > > >  		spin_unlock_irqrestore(&zone->lru_lock, flags);
> > > > > >  	}
> > > > > > +	mem_cgroup_uncharge(page);
> > > > > >  }
> > > > > >  
> > > > > >  static void __put_single_page(struct page *page)
> > > > > 
> > > > > This seems to cause a list breakage in hstate->hugepage_activelist
> > > > > when freeing a hugetlbfs page.
> > > > 
> > > > This looks like a fall out from
> > > > http://marc.info/?l=linux-mm&m=140475936311294&w=2
> > > > 
> > > > I didn't get to review this one but the easiest fix seems to be check
> > > > HugePage and do not call uncharge.
> > > 
> > > Yes, that makes sense.  I'm also moving the uncharge call into
> > > __put_single_page() and __put_compound_page() so that PageHuge(), a
> > > function call, only needs to be checked for compound pages.
> > > 
> > > > > For hugetlbfs, we uncharge in free_huge_page() which is called after
> > > > > __page_cache_release(), so I think that we don't have to uncharge here.
> > > > > 
> > > > > In my testing, moving mem_cgroup_uncharge() inside if (PageLRU) block
> > > > > fixed the problem, so if that works for you, could you fold the change
> > > > > into your patch?
> > > 
> > > Memcg pages that *do* need uncharging might not necessarily be on the
> > > LRU list.
> > 
> > OK.
> > 
> > > Does the following work for you?
> > 
> > Unfortunately, with this change I saw the following bug message when
> > stressing with hugepage migration.
> > move_to_new_page() is called by unmap_and_move_huge_page() too, so
> > we need some hugetlb related code around mem_cgroup_migrate().
> 
> Can we just move hugetlb_cgroup_migrate() into move_to_new_page()?  It
> doesn't seem to be dependent of any page-specific state.
> 
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 7f5a42403fae..219da52d2f43 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -781,7 +781,10 @@ static int move_to_new_page(struct page *newpage, struct page *page,
>  		if (!PageAnon(newpage))
>  			newpage->mapping = NULL;
>  	} else {
> -		mem_cgroup_migrate(page, newpage, false);
> +		if (PageHuge(page))
> +			hugetlb_cgroup_migrate(hpage, new_hpage);

			hugetlb_cgroup_migrate(page, newpage);

to build successfully.

And yes, with this chanage the bug in move_to_new_page() is gone,
so we stepped one step further.

But I faced another bugs like below.

[   56.692744] BUG: Bad page state in process sysctl  pfn:71c00
[   56.693722] page:ffffea0001c70000 count:0 mapcount:0 mapping:          (null) index:0x8
[   56.695121] page flags: 0x5fffff80004008(uptodate|head)
[   56.695990] page dumped because: cgroup check failed
[   56.696816] pc:ffff88007eb9c000 pc->flags:7 pc->mem_cgroup:ffff8800be59a800
[   56.698059] Modules linked in: stap_6484a34ef9f0ebb4400874c66d0905ac__1496(O) bnep bluetooth ip6t_rpfilter ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 cfg80211 xt_conntrack rfk
ill ebtable_nat ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_mangle ip6table_security ip6table_raw ip6table_filter ip6_tables iptable_nat nf_conntrack_ipv4 nf_def
rag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_security iptable_raw ppdev microcode parport_pc serio_raw parport virtio_balloon pcspkr i2c_piix4 nfsd auth_rpcgss o
id_registry nfs_acl lockd sunrpc virtio_blk virtio_net ata_generic pata_acpi floppy
[   56.707416] CPU: 2 PID: 1872 Comm: sysctl Tainted: G    B      O  3.15.0-140715-1512-00017-gf1ab1502aa49 #264
[   56.709024] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   56.709810]  ffffffff81a8e0d5 ffff88003d787cb0 ffffffff8172d057 ffff88003d787cc8
[   56.711158]  ffffffff8172d08e ffffea0001c70000 ffff88003d787cf0 ffffffff8119e7a5
[   56.712344]  0000000000000000 000fffff80000000 ffffffff81a8e0d5 ffff88003d787d28
[   56.713551] Call Trace:
[   56.714088]  [<ffffffff8172d057>] __dump_stack+0x19/0x1b
[   56.714793]  [<ffffffff8172d08e>] dump_stack+0x35/0x46
[   56.715546]  [<ffffffff8119e7a5>] bad_page+0xd5/0x130
[   56.716369]  [<ffffffff8119e958>] free_pages_prepare+0x158/0x190
[   56.717222]  [<ffffffff8119edab>] __free_pages_ok+0x1b/0xb0
[   56.717960]  [<ffffffff8119f859>] __free_pages+0x29/0x50
[   56.718710]  [<ffffffff811dbce0>] update_and_free_page+0xd0/0x110
[   56.719575]  [<ffffffff811dd663>] free_pool_huge_page+0xd3/0xf0
[   56.720407]  [<ffffffff811dd7ec>] set_max_huge_pages+0x16c/0x1c0
[   56.721255]  [<ffffffff811dd968>] __nr_hugepages_store_common+0x128/0x1a0
[   56.722203]  [<ffffffff811ddb28>] hugetlb_sysctl_handler_common+0x98/0xb0
[   56.723147]  [<ffffffff811de56e>] hugetlb_sysctl_handler+0x1e/0x20
[   56.723962]  [<ffffffff8127a103>] proc_sys_call_handler+0xa3/0xb0
[   56.724805]  [<ffffffff8127a124>] proc_sys_write+0x14/0x20
[   56.725844]  [<ffffffff8120921a>] vfs_write+0xba/0x1e0
[   56.726792]  [<ffffffff81209d8d>] SyS_write+0x4d/0xc0
[   56.727596]  [<ffffffff81742a12>] system_call_fastpath+0x16/0x1b
[   58.894865] page:ffffea0001cf8000 count:2 mapcount:0 mapping:ffff88003d481278 index:0x1
[   58.896112] page flags: 0x5fffff80004809(locked|uptodate|private|head)
[   58.897148] page dumped because: VM_BUG_ON_PAGE(PageCgroupUsed(pc))
[   58.899325] pc:ffff88007ebbe000 pc->flags:7 pc->mem_cgroup:ffff8800be59a800
[   58.900359] ------------[ cut here ]------------
[   58.901016] kernel BUG at /src/linux-dev/mm/memcontrol.c:2707!
[   58.901331] invalid opcode: 0000 [#1] SMP
[   58.901331] Modules linked in: stap_6484a34ef9f0ebb4400874c66d0905ac__1496(O) bnep bluetooth ip6t_rpfilter ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 cfg80211 xt_conntrack rfkill ebtable_nat ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_mangle ip6table_security ip6table_raw ip6table_filter ip6_tables iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_security iptable_raw ppdev microcode parport_pc serio_raw parport virtio_balloon pcspkr i2c_piix4 nfsd auth_rpcgss oid_registry nfs_acl lockd sunrpc virtio_blk virtio_net ata_generic pata_acpi floppy
[   58.901331] CPU: 1 PID: 1918 Comm: mbind_fuzz Tainted: G    B      O  3.15.0-140715-1512-00017-gf1ab1502aa49 #264
[   58.901331] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   58.901331] task: ffff8800bd763b20 ti: ffff8800bd750000 task.ti: ffff8800bd750000
[   58.901331] RIP: 0010:[<ffffffff811fee3b>]  [<ffffffff811fee3b>] commit_charge+0x28b/0x2b0
[   58.901331] RSP: 0000:ffff8800bd753c38  EFLAGS: 00010296
[   58.901331] RAX: 000000000000003f RBX: ffffea0001cf8000 RCX: 0000000000000000
[   58.901331] RDX: 0000000000000001 RSI: ffff88007ec0d318 RDI: ffff88007ec0d318
[   58.901331] RBP: ffff8800bd753c78 R08: 000000000000000a R09: 0000000000000000
[   58.901331] R10: 0000000000000000 R11: ffff8800bd75390e R12: ffff8800be59a800
[   58.901331] R13: 0000000000000000 R14: 0000000000000000 R15: ffff88007ebbe000
[   58.901331] FS:  00007f9ce6fa0740(0000) GS:ffff88007ec00000(0000) knlGS:0000000000000000
[   58.901331] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   58.901331] CR2: 0000700004600000 CR3: 000000007c194000 CR4: 00000000000006e0
[   58.901331] Stack:
[   58.901331]  ffff8800be59a800 ffffea0001cf8000 000002003d481290 ffffea0001cf8000
[   58.901331]  ffff88003d481278 0000000000000000 ffff88003d481290 00000000000000d0
[   58.901331]  ffff8800bd753c90 ffffffff812020fc ffffea0001cf8000 ffff8800bd753cd8
[   58.901331] Call Trace:
[   58.901331]  [<ffffffff812020fc>] mem_cgroup_commit_charge+0x6c/0xf0
[   58.901331]  [<ffffffff81196c8c>] __add_to_page_cache_locked+0xec/0x1e0
[   58.901331]  [<ffffffff81196d91>] add_to_page_cache_locked+0x11/0x20
[   58.901331]  [<ffffffff811df425>] hugetlb_no_page+0x105/0x3b0
[   58.901331]  [<ffffffff8138f799>] ? __rb_insert_augmented+0xf9/0x1e0
[   58.901331]  [<ffffffff811e02f4>] hugetlb_fault+0x2c4/0x3c0
[   58.901331]  [<ffffffff811bd184>] ? vma_interval_tree_insert+0x84/0x90
[   58.901331]  [<ffffffff811c5d93>] __handle_mm_fault+0x303/0x340
[   58.901331]  [<ffffffff811c5e5f>] handle_mm_fault+0x8f/0x130
[   58.901331]  [<ffffffff8173d3f6>] __do_page_fault+0x176/0x520
[   58.901331]  [<ffffffff8132d993>] ? file_map_prot_check+0x63/0xd0
[   58.901331]  [<ffffffff811b46a9>] ? vm_mmap_pgoff+0x99/0xc0
[   58.901331]  [<ffffffff8173d7ac>] do_page_fault+0xc/0x10
[   58.901331]  [<ffffffff8173a122>] page_fault+0x22/0x30
[   58.901331] Code: 13 45 19 c0 41 83 e0 02 48 c1 ea 06 83 e2 01 48 83 fa 01 41 83 d8 ff e9 30 ff ff ff 48 c7 c6 20 d0 a8 81 48 89 df e8 55 fb f9 ff <0f> 0b 48 c7 c6 f3 e2 a8 81 48 89 df e8 44 fb f9 ff 0f 0b 48 c7
[   58.901331] RIP  [<ffffffff811fee3b>] commit_charge+0x28b/0x2b0
[   58.901331]  RSP <ffff8800bd753c38>
[   58.944251] ---[ end trace 2f1aecd49dae161f ]---

I feel that these 2 messages have the same cause (just appear differently).
__add_to_page_cache_locked() (and mem_cgroup_try_charge()) can be called
for hugetlb, while we avoid calling mem_cgroup_migrate()/mem_cgroup_uncharge()
for hugetlb. This seems to make page_cgroup of the hugepage inconsistent,
and results in the bad page bug ("page dumped because: cgroup check failed").
So maybe some more PageHuge check is necessary around the charging code.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
