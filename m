Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 4607B6B005D
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 16:28:16 -0500 (EST)
Received: by mail-pb0-f52.google.com with SMTP id ro2so9454624pbb.39
        for <linux-mm@kvack.org>; Fri, 04 Jan 2013 13:28:15 -0800 (PST)
Date: Fri, 4 Jan 2013 13:28:09 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: thp: Acquire the anon_vma rwsem for lock during
 split
In-Reply-To: <20130104140815.GA26005@suse.de>
Message-ID: <alpine.LNX.2.00.1301041253280.4520@eggly.anvils>
References: <1621091901.34838094.1356409676820.JavaMail.root@redhat.com> <535932623.34838584.1356410331076.JavaMail.root@redhat.com> <20130103175737.GA3885@suse.de> <20130104140815.GA26005@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Zhouping Liu <zliu@redhat.com>, Alexander Beregalov <a.beregalov@gmail.com>, Hillf Danton <dhillf@gmail.com>, Alex Xu <alex_y_xu@yahoo.ca>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

I've added Alexander, Hillf and Alex to the Cc.

On Fri, 4 Jan 2013, Mel Gorman wrote:
> Zhouping, please test this patch.
> 
> Andrea and Hugh, any comments on whether this could be improved?

Your patch itself looks just right to me, no improvement required;
and it's easy to understand how the bug crept in, from a blanket
rwsem replacement of anon_vma mutex meeting the harmless-looking
anon_vma_interval_tree_foreach in __split_huge_page, which looked
as if it needed only the readlock provided by the usual method.

But I'd fight shy myself of trying to describe all the THP locking
conventions in the commit message: I haven't really tried to work
out just how right you've got all those details.

The actual race in question here was just two processes (one or both
forked) doing split_huge_page() on the same THPage at the same time,
wasn't it?  (Though of course we only see the backtrace from one of
them.)  Which would be very confusing, and no surprise that the
pmd_trans_splitting test ends up skipping pmds already updated by
the racing process, so the mapcount doesn't match what's expected.
Of course we need exclusive lock against that, which you give it.

> 
> ---8<---
> mm: thp: Acquire the anon_vma rwsem for lock during split

"write" rather than "lock"?

> 
> Zhouping Liu reported the following against 3.8-rc1 when running a mmap
> testcase from LTP.
> 
> [  588.143072] mapcount 0 page_mapcount 3
> [  588.147471] ------------[ cut here ]------------
> [  588.152856] kernel BUG at mm/huge_memory.c:1798!
> [  588.158125] invalid opcode: 0000 [#1] SMP
> [  588.162882] Modules linked in: ip6table_filter ip6_tables ebtable_nat ebtables bnep bluetooth rfkill iptable_mangle ipt_REJECT nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack iptable_filter
> +ip_tables be2iscsi iscsi_boot_sysfs bnx2i cnic uio cxgb4i cxgb4 cxgb3i cxgb3 mdio libcxgbi ib_iser rdma_cm ib_addr iw_cm ib_cm ib_sa ib_mad ib_core iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi vfat fat
> +dm_mirror dm_region_hash dm_log dm_mod cdc_ether iTCO_wdt i7core_edac coretemp usbnet iTCO_vendor_support mii crc32c_intel edac_core lpc_ich shpchp ioatdma mfd_core i2c_i801 pcspkr serio_raw bnx2 microcode dca
> +vhost_net tun macvtap macvlan kvm_intel kvm uinput mgag200 sr_mod cdrom i2c_algo_bit sd_mod drm_kms_helper crc_t10dif ata_generic pata_acpi ttm ata_piix drm libata i2c_core megaraid_sas
> 
> [  588.246517] CPU 1
> [  588.248636] Pid: 23217, comm: mmap10 Not tainted 3.8.0-rc1mainline+ #17 IBM IBM System x3400 M3 Server -[7379I08]-/69Y4356
> [  588.262171] RIP: 0010:[<ffffffff8118fac7>]  [<ffffffff8118fac7>] __split_huge_page+0x677/0x6d0
> [  588.272067] RSP: 0000:ffff88017a03fc08  EFLAGS: 00010293
> [  588.278235] RAX: 0000000000000003 RBX: ffff88027a6c22e0 RCX: 00000000000034d2
> [  588.286394] RDX: 000000000000748b RSI: 0000000000000046 RDI: 0000000000000246
> [  588.294216] RBP: ffff88017a03fcb8 R08: ffffffff819d2440 R09: 000000000000054a
> [  588.302441] R10: 0000000000aaaaaa R11: 00000000ffffffff R12: 0000000000000000
> [  588.310495] R13: 00007f4f11a00000 R14: ffff880179e96e00 R15: ffffea0005c08000
> [  588.318640] FS:  00007f4f11f4a740(0000) GS:ffff88017bc20000(0000) knlGS:0000000000000000
> [  588.327894] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  588.334569] CR2: 00000037e9ebb404 CR3: 000000017a436000 CR4: 00000000000007e0
> [  588.342718] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [  588.350861] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [  588.359134] Process mmap10 (pid: 23217, threadinfo ffff88017a03e000, task ffff880172dd32e0)
> [  588.368667] Stack:
> [  588.370960]  ffff88017a540ec8 ffff88017a03fc20 ffffffff816017b5 ffff88017a03fc88
> [  588.379566]  ffffffff812fa014 0000000000000000 ffff880279ebd5c0 00000000f4f11a4c
> [  588.388150]  00000007f4f11f49 00000007f4f11a00 ffff88017a540ef0 ffff88017a540ee8
> [  588.396711] Call Trace:
> [  588.455106]  [<ffffffff816017b5>] ? rwsem_down_read_failed+0x15/0x17
> [  588.518106]  [<ffffffff812fa014>] ? call_rwsem_down_read_failed+0x14/0x30
> [  588.580897]  [<ffffffff815ffc04>] ? down_read+0x24/0x2b
> [  588.642630]  [<ffffffff8118fb88>] split_huge_page+0x68/0xb0
> [  588.703814]  [<ffffffff81190ed4>] __split_huge_page_pmd+0x134/0x330
> [  588.766064]  [<ffffffff8104b997>] ? pte_alloc_one+0x37/0x50
> [  588.826460]  [<ffffffff81191121>] split_huge_page_pmd_mm+0x51/0x60
> [  588.887746]  [<ffffffff8119116b>] split_huge_page_address+0x3b/0x50
> [  588.948673]  [<ffffffff8119121c>] __vma_adjust_trans_huge+0x9c/0xf0
> [  589.008660]  [<ffffffff811650f4>] vma_adjust+0x684/0x750
> [  589.066328]  [<ffffffff811653ba>] __split_vma.isra.28+0x1fa/0x220
> [  589.123497]  [<ffffffff810135d1>] ? __switch_to+0x181/0x4a0
> [  589.180704]  [<ffffffff811661a9>] do_munmap+0xf9/0x420
> [  589.237461]  [<ffffffff8160026c>] ? __schedule+0x3cc/0x7b0
> [  589.294520]  [<ffffffff8116651e>] vm_munmap+0x4e/0x70
> [  589.350784]  [<ffffffff8116741b>] sys_munmap+0x2b/0x40
> [  589.406971]  [<ffffffff8160a159>] system_call_fastpath+0x16/0x1b
> 
> Alexander Beregalov reported a very similar bug and Hillf Danton identified

And Alex Xu.

> that commit 5a505085 (mm/rmap: Convert the struct anon_vma::mutex to an
> rwsem) and commit 4fc3f1d6 (mm/rmap, migration: Make rmap_walk_anon()
> and try_to_unmap_anon() more scalable) were likely the problem. Reverting
> these commits was reported to solve the problem.
> 
> Despite the reason for these commits, NUMA balancing is not the direct
> source of the problem. split_huge_page() expected the anon_vma lock to be
> exclusive to serialise the whole split operation. Ordinarily it is expected
> that the anon_vma lock would only be required when updating the avcs but
> THP also uses it. The locking requirements for THP are complex and there
> is some overlap but broadly speaking they include the following
> 
> 1. mmap_sem for read or write prevents THPs being created underneath
> 2. anon_vma is taken for write if collapsing a huge page
> 3. mm->page_table_lock should be taken when checking if pmd_trans_huge as
>    split_huge_page can run in parallel
> 4. wait_split_huge_page uses anon_vma taken for write mode to serialise
>    against other THP operations
> 5. compound_lock is used to serialise between
>    __split_huge_page_refcount() and gup
> 
> split_huge_page takes anon_vma for read but that does not serialise against
> parallel split_huge_page operations on the same page (rule 2). One process
> could be modifying the ref counts while the other modifies the page tables
> leading to counters not being reliable. This patch takes the anon_vma
> lock for write to serialise against parallel split_huge_page and parallel
> collapse operations as it is the most fine-grained lock available that
> protects against both.
> 
> Reported-by: Zhouping Liu <zliu@redhat.com>
> Reported-by: Alexander Beregalov <a.beregalov@gmail.com>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  mm/huge_memory.c |   15 +++++++++++++--
>  1 file changed, 13 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 9e894ed..6001ee6 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1819,9 +1819,19 @@ int split_huge_page(struct page *page)
>  
>  	BUG_ON(is_huge_zero_pfn(page_to_pfn(page)));
>  	BUG_ON(!PageAnon(page));
> -	anon_vma = page_lock_anon_vma_read(page);
> +
> +	/*
> +	 * The caller does not necessarily hold an mmap_sem that would prevent
> +	 * the anon_vma disappearing so we first we take a reference to it
> +	 * and then lock the anon_vma for write. This is similar to
> +	 * page_lock_anon_vma_read except the write lock is taken to serialise
> +	 * against parallel split or collapse operations.
> +	 */
> +	anon_vma = page_get_anon_vma(page);
>  	if (!anon_vma)
>  		goto out;
> +	anon_vma_lock_write(anon_vma);
> +
>  	ret = 0;
>  	if (!PageCompound(page))
>  		goto out_unlock;
> @@ -1832,7 +1842,8 @@ int split_huge_page(struct page *page)
>  
>  	BUG_ON(PageCompound(page));
>  out_unlock:
> -	page_unlock_anon_vma_read(anon_vma);
> +	anon_vma_unlock(anon_vma);
> +	put_anon_vma(anon_vma);
>  out:
>  	return ret;
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
