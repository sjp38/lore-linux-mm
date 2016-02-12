Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f53.google.com (mail-lf0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id 40A716B0005
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 08:48:17 -0500 (EST)
Received: by mail-lf0-f53.google.com with SMTP id 78so51921420lfy.3
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 05:48:17 -0800 (PST)
Received: from mail-lf0-x231.google.com (mail-lf0-x231.google.com. [2a00:1450:4010:c07::231])
        by mx.google.com with ESMTPS id j1si6966516lfe.144.2016.02.12.05.48.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Feb 2016 05:48:15 -0800 (PST)
Received: by mail-lf0-x231.google.com with SMTP id m1so52189480lfg.0
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 05:48:14 -0800 (PST)
From: Dmitry Monakhov <dmonakhov@openvz.org>
Subject: Re: [PATCH] kvm: do not SetPageDirty from kvm_set_pfn_dirty for file mappings
In-Reply-To: <20160211181306.7864.44244.stgit@maxim-thinkpad>
References: <20160211181306.7864.44244.stgit@maxim-thinkpad>
Date: Fri, 12 Feb 2016 16:48:08 +0300
Message-ID: <87bn7mavl3.fsf@openvz.org>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxim Patlasov <mpatlasov@virtuozzo.com>, pbonzini@redhat.com
Cc: kvm@vger.kernel.org, linux-nvdimm@lists.01.org, gleb@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Maxim Patlasov <mpatlasov@virtuozzo.com> writes:

> The patch solves the following problem: file system specific routines
> involved in ordinary routine writeback process BUG_ON page_buffers()
> because a page goes to writeback without buffer-heads attached.
>
> The way how kvm_set_pfn_dirty calls SetPageDirty works only for anon
> mappings. For file mappings it is obviously incorrect - there page_mkwrite
> must be called. It's not easy to add page_mkwrite call to kvm_set_pfn_dir=
ty
> because there is no universal way to find vma by pfn. But actually
> SetPageDirty may be simply skipped in those cases. Below is a
> justification.
Confirm. I've hit that BUGON
[ 4442.219121] ------------[ cut here ]------------
[ 4442.219188] kernel BUG at fs/ext4/inode.c:2285!
[ 4442.219231] invalid opcode: 0000 [#1] SMP
[ 4442.219275] Modules linked in: vhost_net macvtap macvlan bnep
bluetooth rfkill fuse iptable_nat nf_nat_ipv4 nf_nat nf_conntrack_ipv4
nf_defrag_ipv4 xt_conntrack nf_conntrack xt_CHECKSUM iptable_mangle
ip6t_REJECT ipt_REJECT tun ebtable_filter ebtables 8021q garp mrp
ip6table_filter ip6_tables iptable_filter ip_tables dm_mirror
dm_region_hash dm_log iTCO_wdt iTCO_vendor_support intel_powerclamp
coretemp kvm_intel kvm crct10dif_pclmul crc32_pclmul crc32c_intel
ghash_clmulni_intel aesni_intel lrw gf128mul glue_helper ablk_helper
cryptd serio_raw pcspkr sb_edac edac_core mei_me i2c_i801 lpc_ich mei
mfd_core ipmi_si ipmi_msghandler ioatdma wmi shpchp dca dm_mod uinput
ext4 mbcache jbd2 sd_mod sr_mod cdrom crc_t10dif crct10dif_common
mgag200 syscopyarea sysfillrect sysimgblt i2c_algo_bit drm_kms_helper
[ 4442.220048]  isci ttm libsas ahci e1000e scsi_transport_sas drm
libahci libata ptp i2c_core pps_core ip6_vzprivnet ip6_vznetstat
pio_kaio pio_nfs pio_direct pfmt_raw pfmt_ploop1 ploop ip_vznetstat
ip_vzprivnet vziolimit vzevent vzlist vzstat vznetstat vznetdev vzmon
vzdev bridge stp llc
[ 4442.220357] CPU: 5 PID: 94 Comm: kworker/u18:1 ve: 0 Not tainted
3.10.0-229.7.2.vz7.9.17 #1 9.17
[ 4442.220431] Hardware name: DEPO Computers
X9DBL-3F/X9DBL-iF/X9DBL-3F/X9DBL-iF, BIOS 3.00 08/09/2013
[ 4442.220531] Workqueue: writeback bdi_writeback_workfn (flush-253:0)
[ 4442.220591] task: ffff8810514f8000 ti: ffff8810514f4000 task.ti:
ffff8810514f4000
[ 4442.220661] RIP: 0010:[<ffffffffa030e635>]  [<ffffffffa030e635>]
mpage_prepare_extent_to_map+0x2d5/0x2e0 [ext4]
[ 4442.220779] RSP: 0018:ffff8810514f7988  EFLAGS: 00010246
[ 4442.220833] RAX: 006006210002007d RBX: ffff8810514f79f8 RCX:
00000000001a9459
[ 4442.220894] RDX: 0000000000000000 RSI: 0000000000000000 RDI:
ffff88107ffc7ce8
[ 4442.220971] RBP: ffff8810514f7a60 R08: 0000000000000000 R09:
0000000000000000
[ 4442.221039] R10: 57fee94ceb2cd540 R11: ffff881051ef0608 R12:
000000000000338a
[ 4442.221106] R13: ffffffffffffffff R14: ffffea0040578440 R15:
ffff8810514f7b08
[ 4442.221175] FS:  0000000000000000(0000) GS:ffff88107fc80000(0000)
knlGS:0000000000000000
[ 4442.221250] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 4442.223468] CR2: 00000000083c0000 CR3: 000000000190a000 CR4:
00000000001427e0
[ 4442.225613] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
0000000000000000
[ 4442.227746] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
0000000000000400
[ 4442.229863] Stack:
[ 4442.231947]  ffff8810514f79c8 0000000000000000 ffff88102a9f0650
ffff8810514f7a30
[ 4442.234098]  00000000001a946d 000000000000000e 0000000000000000
ffffea0020249a00
[ 4442.236254]  ffffea0001d32980 ffffea00403c3680 ffffea00201a6e40
ffffea0040777dc0
[ 4442.238407] Call Trace:
[ 4442.240558]  [<ffffffffa0312a03>] ext4_writepages+0x463/0xd60 [ext4]
[ 4442.242742]  [<ffffffff81176538>] ? generic_writepages+0x58/0x80
[ 4442.244928]  [<ffffffff8117765e>] do_writepages+0x1e/0x40
[ 4442.247109]  [<ffffffff8120e31a>] __writeback_single_inode+0x7a/0x3d0
[ 4442.249308]  [<ffffffff8120f086>] writeback_sb_inodes+0x286/0x4a0
[ 4442.251513]  [<ffffffff8120f33f>] __writeback_inodes_wb+0x9f/0xd0
[ 4442.253709]  [<ffffffff8120f5d3>] wb_writeback+0x263/0x2f0
[ 4442.255893]  [<ffffffff811fde6c>] ? get_nr_inodes+0x4c/0x70
[ 4442.258099]  [<ffffffff812110cb>] bdi_writeback_workfn+0x2cb/0x460
[ 4442.260302]  [<ffffffff81091f2b>] process_one_work+0x17b/0x470
[ 4442.262496]  [<ffffffff81092cfb>] worker_thread+0x11b/0x400
[ 4442.264708]  [<ffffffff81092be0>] ? rescuer_thread+0x400/0x400
[ 4442.266913]  [<ffffffff8109a40f>] kthread+0xcf/0xe0
[ 4442.269127]  [<ffffffff8109a340>] ? create_kthread+0x60/0x60
[ 4442.271337]  [<ffffffff81612798>] ret_from_fork+0x58/0x90
[ 4442.273566]  [<ffffffff8109a340>] ? create_kthread+0x60/0x60
[ 4442.275792] Code: ff ff ff e8 ae b6 e6 e0 8b 85 40 ff ff ff eb c2 48
8d bd 50 ff ff ff e8 9a b6 e6 e0 eb 8c 4c 89 f7 e8 40 b3 e5 e0 e9 d5 fe
ff ff <0f> 0b 0f 0b e8 42 0e d6 e0 66 90 0f 1f 44 00 00 55 48 89 e5 41
[ 4442.280498] RIP  [<ffffffffa030e635>]
mpage_prepare_extent_to_map+0x2d5/0x2e0 [ext4]
[ 4442.282601]  RSP <ffff8810514f7988>
>
> When guest modifies the content of a page with file mapping, kernel kvm
> makes the page dirty by the following call-path:
>
> vmx_handle_exit ->
>  handle_ept_violation ->
>   __get_user_pages ->
>    page_mkwrite ->
>     SetPageDirty
>
> Since then, the page is dirty from both guest and host point of view. Then
> the host makes writeback and marks the page as write-protected. So any
> further write from the guest triggers call-path above again.
Please elaborate exact call-path which marks host-page.
>
> So, for file mappings, it's not possible to have new data written to a pa=
ge
> inside the guest w/o corresponding SetPageDirty on the host.
>
> This makes explicit SetPageDirty from kvm_set_pfn_dirty redundant.
>
> Signed-off-by: Maxim Patlasov <mpatlasov@virtuozzo.com>
> ---
>  virt/kvm/kvm_main.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
> index a11cfd2..5a7d3fa 100644
> --- a/virt/kvm/kvm_main.c
> +++ b/virt/kvm/kvm_main.c
> @@ -1582,7 +1582,8 @@ void kvm_set_pfn_dirty(kvm_pfn_t pfn)
>  	if (!kvm_is_reserved_pfn(pfn)) {
>  		struct page *page =3D pfn_to_page(pfn);
>=20=20
> -		if (!PageReserved(page))
> +		if (!PageReserved(page) &&
> +		    (!page->mapping || PageAnon(page)))
>  			SetPageDirty(page);
>  	}
>  }
>
> _______________________________________________
> Linux-nvdimm mailing list
> Linux-nvdimm@lists.01.org
> https://lists.01.org/mailman/listinfo/linux-nvdimm

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBCgAGBQJWveKYAAoJELhyPTmIL6kBd7wIAK/VnRoEvtTnThYeL/iTqWvT
P4pM/nsiTK4ew/zHFqE6LwpUsluDBpT81RZhDkmkZKhfeYewkKzWTRXmCNdaXyzL
T4RICx7du0HVsy7cRA/NjcPPyvnfHgoA0f60U+mhm4itA6vHkquVoGHx9xBMsmUS
FFfEPh5ptu0cdakeDhAUkmSxK9lEIHgIt9M0l1/PormjBPdIDMPHlMJerkqgBG97
bDKnORtmnuh+y8Ukft/xswj9xJ1kDM9q1wnQtp00XoAndszMyB7cFkO5pE3L+WsR
SZVL+LoUxxM24A9SsZ43CZyiDODhMg1bHxpWRvDAxN8fdnmKngtb9xZzZ8PCNUM=
=eI7O
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
