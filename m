Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id CFA966B04C2
	for <linux-mm@kvack.org>; Thu,  4 Jan 2018 01:10:58 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id e12so430456pga.5
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 22:10:58 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a184si1649519pge.448.2018.01.03.22.10.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jan 2018 22:10:57 -0800 (PST)
Date: Thu, 4 Jan 2018 08:10:53 +0200
From: Leon Romanovsky <leon@kernel.org>
Subject: Re: Filesystem crashes due to pages without buffers
Message-ID: <20180104061053.GA10145@mtr-leonro.local>
References: <20180103100430.GE4911@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="8+OS07CeIgZ706fH"
Content-Disposition: inline
In-Reply-To: <20180103100430.GE4911@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>, RDMA mailing list <linux-rdma@vger.kernel.org>, Majd Dibbiny <majd@mellanox.com>


--8+OS07CeIgZ706fH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Jan 03, 2018 at 11:04:30AM +0100, Jan Kara wrote:
> Hello,
>
> Over the years I have seen so far unexplained crashed in filesystem's
> (ext4, xfs) writeback path due to dirty pages without buffers attached to
> them (see [1] and [2] for relatively recent reports). This was confusing as
> reclaim takes care not to strip buffers from a dirty page and both
> filesystems do add buffers to a page when it is first written to - in
> ->page_mkwrite() and ->write_begin callbacks.
>
> Recently I have come across a code path that is probably leading to this
> inconsistent state and I'd like to discuss how to best fix the problem
> because it's not obvious to me. Consider the following race:
>
> CPU1					CPU2
>
> addr = mmap(file1, MAP_SHARED, ...);
> fd2 = open(file2, O_DIRECT | O_RDONLY);
> read(fd2, addr, len)
>   do_direct_IO()
>     page = dio_get_page()
>       dio_refill_pages()
>         iov_iter_get_pages()
> 	  get_user_pages_fast()
>             - page fault
>               ->page_mkwrite()
>                 block_page_mkwrite()
>                   lock_page(page);
>                   - attaches buffers to page
>                   - makes sure blocks are allocated
>                   set_page_dirty(page)
>               - install writeable PTE
>               unlock_page(page);
>     submit_page_section(page)
>       - submits bio with 'page' as a buffer
> 					kswapd reclaims pages:
> 					...
> 					shrink_page_list()
> 					  trylock_page(page) - this is the
> 					    page CPU1 has just faulted in
> 					  try_to_unmap(page)
> 					  pageout(page);
> 					    clear_page_dirty_for_io(page);
> 					    ->writepage()
> 					  - let's assume page got written
> 					    out fast enough, alternatively
> 					    we could get to the same path as
> 					    soon as the page IO completes
> 					  if (page_has_private(page)) {
> 					    try_to_release_page(page)
> 					      - reclaims buffers from the
> 					        page
> 					   __remove_mapping(page)
> 					     - fails as DIO code still
> 					       holds page reference
> ...
>
> eventually read completes
>   dio_bio_complete(bio)
>     set_page_dirty_lock(page)
>       Bummer, we've just marked the page as dirty without having buffers.
>       Eventually writeback will find it and filesystem will complain...
>
> Am I missing something?
>
> The problem here is that filesystems fundamentally assume that a page can
> be written to only between ->write_begin - ->write_end (in this interval
> the page is locked), or between ->page_mkwrite - ->writepage and above is
> an example where this does not hold because when a page reference is
> acquired through get_user_pages(), page can get written to by the holder of
> the reference and dirtied even after it has been unmapped from page tables
> and ->writepage has been called. This is not only a cosmetic issue leading
> to assertion failure but it can also lead to data loss, data corruption, or
> other unpleasant surprises as filesystems assume page contents cannot be
> modified until either ->write_begin() or ->page_mkwrite gets called and
> those calls are serialized by proper locking with problematic operations
> such as hole punching etc.
>
> I'm not sure how to fix this problem. We could 'simulate' a writeable page
> fault in set_page_dirty_lock(). It is a bit ugly since we don't have a
> virtual address of the fault, don't hold mmap_sem, etc., possibly
> expensive, but it would make filesystems happy. Data stored by GUP user
> (e.g. read by DIO in the above case) could still get lost if someone e.g.
> punched hole under the buffer or otherwise messed with the underlying
> storage of the page while DIO was running but arguably users could expect
> such outcome.
>
> Another possible solution would be to make sure page is writeably mapped
> until GUP user drops its reference. That would be arguably cleaner but
> probably that would mean we have to track number of writeable GUP page
> references separately (no space space in struct page is a problem here) and
> block page_mkclean() until they are dropped. Also for long term GUP users
> like Infiniband or V4L we'd have to come up with some solution as we should
> not block page_mkclean() for so long.
>
> As a side note DAX needs some solution for GUP users as well. The problems
> are similar there in nature, just much easier to hit. So at least a
> solution for long-term GUP users can (and I strongly believe should) be
> shared between standard and DAX paths.
>
> Anybody has other ideas how to fix the problem or opinions on which
> solution would be better to use or some complications I have missed?
>

+RDMA

Hi Jan,

I don't have actual proposals how to fix, but wanted to mention that
we have a customer who experiences those failures in his setup.
In his case, it is reproducible in 100% of cases in approximately 2
minutes of run.

His application creates two memory regions with ib_umem_get(), one is
backed by ext4 and another is anonymous. Approximately after two minutes
of data traffic, he stops the system and calls to release those memory
regions with ib_umem_release()->__ib_umem_release()->set_page_dirty_lock().

A couple of seconds later, he hits the following BUG_ON.

[ 1411.545311] ------------[ cut here ]------------
[ 1411.545340] kernel BUG at fs/ext4/inode.c:2297!
[ 1411.545360] invalid opcode: 0000 [#1] SMP
[ 1411.545381] Modules linked in: xt_nat veth ipt_MASQUERADE
nf_nat_masquerade_ipv4 iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4
nf_nat_ipv4 xt_addrtype iptable_filter xt_conntrack nf_nat nf_conntrack
br_netfilter bridge stp llc overlay(T) rdma_ucm(OE) ib_ucm(OE)
rdma_cm(OE) iw_cm(OE) ib_ipoib(OE) ib_cm(OE) ib_uverbs(OE) ib_umad(OE)
mlx5_ib(OE) mlx5_core(OE) mlx4_en(OE) mlx4_ib(OE) ib_core(OE)
mlx4_core(OE) devlink mlx_compat(OE) intel_powerclamp coretemp
intel_rapl iosf_mbi kvm_intel vfat fat kvm irqbypass crc32_pclmul
ghash_clmulni_intel aesni_intel lrw gf128mul ext4 glue_helper
ablk_helper cryptd mbcache jbd2 iTCO_wdt iTCO_vendor_support mxm_wmi
pcspkr sb_edac edac_core i2c_i801 sg mei_me mei shpchp lpc_ich
ipmi_devintf ipmi_si ipmi_msghandler acpi_pad wmi acpi_power_meter
knem(OE) nfsd auth_rpcgss
[ 1411.545744] nfs_acl lockd grace sunrpc ip_tables xfs libcrc32c sd_mod
crc_t10dif crct10dif_generic ast drm_kms_helper crct10dif_pclmul
crct10dif_common syscopyarea sysfillrect crc32c_intel mpt3sas sysimgblt
fb_sys_fops ttm ahci raid_class libahci scsi_transport_sas igb drm
libata dca i2c_algo_bit ptp nvme i2c_core pps_core fjes dm_mirror
dm_region_hash dm_log dm_mod [last unloaded: devlink]
[ 1411.545926] CPU: 6 PID: 13195 Comm: node_runner_w8 Tainted: G W OE
------------ T 3.10.0-514.21.1.el7.debug_bz1368895.x86_64 #1
[ 1411.545975] Hardware name: Quanta Computer Inc D51BP-1U (dual 1G LoM)/S2BP-MB (dual 1G LoM), BIOS S2BP3B04 03/03/2016
[ 1411.546017] task: ffff881e4b323ec0 ti: ffff881e49bbc000 task.ti: ffff881e49bbc000
[ 1411.546047] RIP: 0010:[<ffffffffa07083e5>] [<ffffffffa07083e5>] mpage_prepare_extent_to_map+0x2d5/0x2e0 [ext4]
[ 1411.546103] RSP: 0018:ffff881e49bbfc10 EFLAGS: 00010246
[ 1411.546125] RAX: 001fffff0000003d RBX: ffff881e49bbfc68 RCX: 0000000000000170
[ 1411.546154] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff88207ff8dde8
[ 1411.546183] RBP: ffff881e49bbfce8 R08: 0000000000000000 R09: 0000000000000001
[ 1411.546212] R10: 57fe04c2df4f6680 R11: 0000000000000008 R12: 7ffffffffffffe9e
[ 1411.546240] R13: 000000000003ffff R14: ffffea0001449a00 R15: ffff881e49bbfd90
[ 1411.546270] FS: 00007f5dd5de7d40(0000) GS:ffff881fffb80000(0000) knlGS:0000000000000000
[ 1411.546302] CS: 0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1411.546325] CR2: 00007f5b0c5969c0 CR3: 0000001e5e6ae000 CR4: 00000000003407e0
[ 1411.546354] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1411.546383] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[ 1411.546412] Stack:
[ 1411.546421] ffff881e49bbfc50 0000000000000002 ffff881f07b00628 ffff881e49bbfcb8
[ 1411.546456] 000000000000017b 000000000000000e 0000000000000000 ffffea00794f6600
[ 1411.546490] ffffea00794f6640 ffffea00794f6680 ffffea0001449a00 ffffea00014499c0
[ 1411.546524] Call Trace:
[ 1411.546545] [<ffffffffa070c9ab>] ext4_writepages+0x45b/0xd60 [ext4]
[ 1411.546576] [<ffffffff8118d93e>] do_writepages+0x1e/0x40
[ 1411.546601] [<ffffffff811824f5>] __filemap_fdatawrite_range+0x65/0x80
[ 1411.546629] [<ffffffff81182641>] filemap_write_and_wait_range+0x41/0x90
[ 1411.546664] [<ffffffffa0703bba>] ext4_sync_file+0xba/0x320 [ext4]
[ 1411.546692] [<ffffffff8123028d>] vfs_fsync_range+0x1d/0x30
[ 1411.546717] [<ffffffff811ba89e>] SyS_msync+0x1fe/0x250
[ 1411.546741] [<ffffffff816974c9>] system_call_fastpath+0x16/0x1b
[ 1411.546765] Code: ff ff ff e8 2e 7e a8 e0 8b 85 40 ff ff ff eb c2 48
8d bd 50 ff ff ff e8 1a 7e a8 e0 eb 8c 4c 89 f7 e8 a0 81 a7 e0 e9 d5 fe
ff ff <0f> 0b 0f 0b e8 62 d6 97 e0 66 90 0f 1f 44 00 00 55 48 89 e5 41
[ 1411.548075] RIP [<ffffffffa07083e5>] mpage_prepare_extent_to_map+0x2d5/0x2e0 [ext4]
[ 1411.549292] RSP <ffff881e49bbfc10>
---here vmcore-dmesg got cut off----

Thanks

> 								Honza
>
> [1] https://www.spinics.net/lists/linux-xfs/msg10090.html
> [2] https://www.spinics.net/lists/linux-ext4/msg54377.html
>
> --
> Jan Kara <jack@suse.com>
> SUSE Labs, CR
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--8+OS07CeIgZ706fH
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlpNxW0ACgkQ5GN7iDZy
WKcwCQ/9FXq6iFv39IY5JdJ8VRWGbZVSmShwsUGp5K6ZZ554rMhigVV7w+5ieFVv
i2ipgYkHXW6RyfTTRQ/JNIkQGO9gAnn2OF0yHxtPgnJnR5GgqdT1JsTZG/vffEmt
VoVjD56XawF3pD6K3+Ma2/+aoAn9Mz9yDwtwwmFmTYaPTU1CBOf3FvFWbnlQ5Koe
U2NFWQRHly5kR8n0jmkWMnD7hyYgNEWDRk4xm0Ua6UJeiijvpDvKeHuaMKMlhBns
E8QXj/1uNwntqgvx46jEWw6qntkygOnMB8lPW7HXmEekDKR4lkkOBS3BkrQEQ0uk
afcjAj8G3duDCTmGkYxJcsTb9jhlBt2KjjzkC+CZ9sVfdIpUvRiTk5fFIZVTqBk1
Uhy/mpqlHlPlPJ9PuwWKf+3Rp3R2aucGh04jh9XmTavIg6rYc8tz782j2I1mMFG2
vJMBwZViTsFBoYU+efornSbQdB0qSKjCpOcw0DiRqXvnEPkhOTf3HsPJRkhiANIT
mnWXj8uKBJtVZywGOlwxNHCyeZTtlfGXqssFVDlRocqKdjhFGoHXpgKqIZQseMtY
EAr6iVehIUEvQHEIXGcMRUbLKUt6JKHoIaLZdBBEWu8zpUbWohtGMoLoTrdBEtaw
YoYW4Fo2I1XgZtCX/SKbhN99K/adHSFF7kiM0tuHooG+y1l45uY=
=nwWq
-----END PGP SIGNATURE-----

--8+OS07CeIgZ706fH--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
