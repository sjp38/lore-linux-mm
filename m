Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 9410A6B0038
	for <linux-mm@kvack.org>; Thu, 13 Aug 2015 04:54:56 -0400 (EDT)
Received: by pabyb7 with SMTP id yb7so33477162pab.0
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 01:54:56 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id zo4si2686944pbc.146.2015.08.13.01.54.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 13 Aug 2015 01:54:55 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm/hwpoison: fix race between soft_offline_page and
 unpoison_memory
Date: Thu, 13 Aug 2015 08:53:33 +0000
Message-ID: <20150813085332.GA30163@hori1.linux.bs1.fc.nec.co.jp>
References: <BLU436-SMTP256072767311DFB0FD3AE1B807D0@phx.gbl>
In-Reply-To: <BLU436-SMTP256072767311DFB0FD3AE1B807D0@phx.gbl>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <779E28A965418D4CB2DC722F06062381@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <wanpeng.li@hotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, Aug 13, 2015 at 03:09:07PM +0800, Wanpeng Li wrote:
> [   61.572584] BUG: Bad page state in process bash  pfn:97000
> [   61.578106] page:ffffea00025c0000 count:0 mapcount:1 mapping:         =
 (null) index:0x7f4fdbe00
> [   61.586803] flags: 0x1fffff80080048(uptodate|active|swapbacked)
> [   61.592809] page dumped because: PAGE_FLAGS_CHECK_AT_FREE flag(s) set
> [   61.599250] bad because of flags:
> [   61.602567] flags: 0x40(active)
> [   61.605746] Modules linked in: snd_hda_codec_hdmi i915 rpcsec_gss_krb5=
 nfsv4 dns_resolver bnep rfcomm nfsd bluetooth auth_rpcgss nfs_acl nfs rfki=
ll lockd grace sunrpc i2c_algo_bit drm_kms_helper snd_hda_codec_realtek snd=
_hda_codec_generic drm snd_hda_intel fscache snd_hda_codec x86_pkg_temp_the=
rmal coretemp kvm_intel snd_hda_core snd_hwdep kvm snd_pcm snd_seq_dummy sn=
d_seq_oss crct10dif_pclmul snd_seq_midi crc32_pclmul snd_seq_midi_event gha=
sh_clmulni_intel snd_rawmidi aesni_intel lrw gf128mul snd_seq glue_helper a=
blk_helper snd_seq_device cryptd fuse snd_timer dcdbas serio_raw mei_me par=
port_pc snd mei ppdev i2c_core video lp soundcore parport lpc_ich shpchp mf=
d_core ext4 mbcache jbd2 sd_mod e1000e ahci ptp libahci crc32c_intel libata=
 pps_core
> [   61.605827] CPU: 3 PID: 2211 Comm: bash Not tainted 4.2.0-rc5-mm1+ #45
> [   61.605829] Hardware name: Dell Inc. OptiPlex 7020/0F5C5X, BIOS A03 01=
/08/2015
> [   61.605832]  ffffffff818b3be8 ffff8800da373ad8 ffffffff8165ceb4 000000=
0001313ce1
> [   61.605837]  ffffea00025c0000 ffff8800da373b08 ffffffff8117bdd6 ffff88=
021edd4b00
> [   61.605842]  0000000000000001 001fffff80080048 0000000000000000 ffff88=
00da373b88
> [   61.605847] Call Trace:
> [   61.605858]  [<ffffffff8165ceb4>] dump_stack+0x48/0x5c
> [   61.605865]  [<ffffffff8117bdd6>] bad_page+0xe6/0x140
> [   61.605870]  [<ffffffff8117dfc9>] free_pages_prepare+0x2f9/0x320
> [   61.605876]  [<ffffffff811e817d>] ? uncharge_list+0xdd/0x100
> [   61.605882]  [<ffffffff8117ff20>] free_hot_cold_page+0x40/0x170
> [   61.605888]  [<ffffffff81185dd0>] __put_single_page+0x20/0x30
> [   61.605892]  [<ffffffff81186675>] put_page+0x25/0x40
> [   61.605897]  [<ffffffff811dc276>] unmap_and_move+0x1a6/0x1f0
> [   61.605908]  [<ffffffff811dc3c0>] migrate_pages+0x100/0x1d0
> [   61.605914]  [<ffffffff811eb710>] ? kill_procs+0x100/0x100
> [   61.605918]  [<ffffffff811764af>] ? unlock_page+0x6f/0x90
> [   61.605923]  [<ffffffff811ecf37>] __soft_offline_page+0x127/0x2a0
> [   61.605928]  [<ffffffff811ed156>] soft_offline_page+0xa6/0x200
>=20
> There is a race window between soft_offline_page() and unpoison_memory():
>=20
> 		CPU0 					CPU1
>=20
> soft_offline_page
> __soft_offline_page
> TestSetPageHWPoison  =20
> 					unpoison_memory
> 					PageHWPoison check (true)
> 					TestClearPageHWPoison
> 					put_page    -> release refcount held by get_hwpoison_page in unpoiso=
n_memory
> 					put_page    -> release refcount held by isolate_lru_page in __soft_o=
ffline_page
> migrate_pages
>=20
> The second put_page() releases refcount held by isolate_lru_page() which=
=20
> will lead to unmap_and_move() releases the last refcount of page and w/=20
> mapcount still 1 since try_to_unmap() is not called if there is only=20
> one user map the page. Anyway, the page refcount and mapcount will=20
> still mess if the page is mapped by multiple users. Commit (4491f712606:=
=20
> mm/memory-failure: set PageHWPoison before migrate_pages()) is introduced=
=20
> to avoid to reuse just successful migrated page, however, it also incurs=
=20
> this race window.
>=20
> Fix it by continue to use migratetype to guarantee the source page which=
=20
> is successful migration does not reused before PG_hwpoison is set.
>=20
> Signed-off-by: Wanpeng Li <wanpeng.li@hotmail.com>

Thank you for the report, Wanpeng.

I think that unpoison is used only in testing so this race never affects
our end-users/customers, so going back to this migratetype change stuff
looks unworthy to me.

If I read correctly, the old migratetype approach has a few problems:
  1) it doesn't fix the problem completely, because
     set_migratetype_isolate() can fail to set MIGRATE_ISOLATE to the
     target page if the pageblock of the page contains one or more
     unmovable pages (i.e. has_unmovable_pages() returns true).
  2) the original code changes migratetype to MIGRATE_ISOLATE forcibly,
     and sets it to MIGRATE_MOVABLE forcibly after soft offline, regardless
     of the original migratetype state, which could impact other subsystems
     like memory hotplug or compaction.

So in my opinion, the best option is to fix this within unpoison code,
but it might be hard because we don't know whether the target page is
under migration. The second option is to add a race check in the if (reason
=3D=3D MR_MEMORY_FAILURE) branch in unmap_and_move(), although this looks a=
d-hoc
and need testing. The third option is to leave it with some "FIXME" comment=
.

Thanks,
Naoya Horiguchi

> ---
>  include/linux/page-isolation.h |    5 +++++
>  mm/memory-failure.c            |   16 ++++++++++++----
>  mm/migrate.c                   |    3 +--
>  mm/page_isolation.c            |    4 ++--
>  4 files changed, 20 insertions(+), 8 deletions(-)
>=20
> diff --git a/include/linux/page-isolation.h b/include/linux/page-isolatio=
n.h
> index 047d647..ff5751e 100644
> --- a/include/linux/page-isolation.h
> +++ b/include/linux/page-isolation.h
> @@ -65,6 +65,11 @@ undo_isolate_page_range(unsigned long start_pfn, unsig=
ned long end_pfn,
>  int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
>  			bool skip_hwpoisoned_pages);
> =20
> +/*
> + *  Internal functions. Changes pageblock's migrate type.
> + */
> +int set_migratetype_isolate(struct page *page, bool skip_hwpoisoned_page=
s);
> +void unset_migratetype_isolate(struct page *page, unsigned migratetype);
>  struct page *alloc_migrate_target(struct page *page, unsigned long priva=
te,
>  				int **resultp);
> =20
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index eca613e..0ed3814 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1647,8 +1647,6 @@ static int __soft_offline_page(struct page *page, i=
nt flags)
>  		inc_zone_page_state(page, NR_ISOLATED_ANON +
>  					page_is_file_cache(page));
>  		list_add(&page->lru, &pagelist);
> -		if (!TestSetPageHWPoison(page))
> -			atomic_long_inc(&num_poisoned_pages);
>  		ret =3D migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
>  					MIGRATE_SYNC, MR_MEMORY_FAILURE);
>  		if (ret) {
> @@ -1663,8 +1661,9 @@ static int __soft_offline_page(struct page *page, i=
nt flags)
>  				pfn, ret, page->flags);
>  			if (ret > 0)
>  				ret =3D -EIO;
> -			if (TestClearPageHWPoison(page))
> -				atomic_long_dec(&num_poisoned_pages);
> +		} else {
> +			if (!TestSetPageHWPoison(page))
> +				atomic_long_inc(&num_poisoned_pages);
>  		}
>  	} else {
>  		pr_info("soft offline: %#lx: isolation failed: %d, page count %d, type=
 %lx\n",
> @@ -1715,6 +1714,14 @@ int soft_offline_page(struct page *page, int flags=
)
> =20
>  	get_online_mems();
> =20
> +	/*
> +	 * Isolate the page, so that it doesn't get reallocated if it
> +	 * was free. This flag should be kept set until the source page
> +	 * is freed and PG_hwpoison on it is set.
> +	 */
> +	if (get_pageblock_migratetype(page) !=3D MIGRATE_ISOLATE)
> +		set_migratetype_isolate(page, false);
> +
>  	ret =3D get_any_page(page, pfn, flags);
>  	put_online_mems();
>  	if (ret > 0) { /* for in-use pages */
> @@ -1733,5 +1740,6 @@ int soft_offline_page(struct page *page, int flags)
>  				atomic_long_inc(&num_poisoned_pages);
>  		}
>  	}
> +	unset_migratetype_isolate(page, MIGRATE_MOVABLE);
>  	return ret;
>  }
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 1f8369d..472baf5 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -880,8 +880,7 @@ static int __unmap_and_move(struct page *page, struct=
 page *newpage,
>  	/* Establish migration ptes or remove ptes */
>  	if (page_mapped(page)) {
>  		try_to_unmap(page,
> -			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS|
> -			TTU_IGNORE_HWPOISON);
> +			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
>  		page_was_mapped =3D 1;
>  	}
> =20
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index 4568fd5..654662a 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -9,7 +9,7 @@
>  #include <linux/hugetlb.h>
>  #include "internal.h"
> =20
> -static int set_migratetype_isolate(struct page *page,
> +int set_migratetype_isolate(struct page *page,
>  				bool skip_hwpoisoned_pages)
>  {
>  	struct zone *zone;
> @@ -73,7 +73,7 @@ out:
>  	return ret;
>  }
> =20
> -static void unset_migratetype_isolate(struct page *page, unsigned migrat=
etype)
> +void unset_migratetype_isolate(struct page *page, unsigned migratetype)
>  {
>  	struct zone *zone;
>  	unsigned long flags, nr_pages;
> --=20
> 1.7.1
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
