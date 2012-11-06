Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id A4D776B004D
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 08:54:10 -0500 (EST)
Date: Tue, 6 Nov 2012 08:54:02 -0500
From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH] tmpfs: fix shmem_getpage_gfp VM_BUG_ON
Message-ID: <20121106135402.GA3543@redhat.com>
References: <20121025023738.GA27001@redhat.com>
 <alpine.LNX.2.00.1210242121410.1697@eggly.anvils>
 <20121101191052.GA5884@redhat.com>
 <alpine.LNX.2.00.1211011546090.19377@eggly.anvils>
 <20121101232030.GA25519@redhat.com>
 <alpine.LNX.2.00.1211011627120.19567@eggly.anvils>
 <20121102014336.GA1727@redhat.com>
 <alpine.LNX.2.00.1211021606580.11106@eggly.anvils>
 <alpine.LNX.2.00.1211051729590.963@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1211051729590.963@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Nov 05, 2012 at 05:32:41PM -0800, Hugh Dickins wrote:

 > -			/* We already confirmed swap, and make no allocation */
 > -			VM_BUG_ON(error);
 > +			/*
 > +			 * We already confirmed swap under page lock, and make
 > +			 * no memory allocation here, so usually no possibility
 > +			 * of error; but free_swap_and_cache() only trylocks a
 > +			 * page, so it is just possible that the entry has been
 > +			 * truncated or holepunched since swap was confirmed.
 > +			 * shmem_undo_range() will have done some of the
 > +			 * unaccounting, now delete_from_swap_cache() will do
 > +			 * the rest (including mem_cgroup_uncharge_swapcache).
 > +			 * Reset swap.val? No, leave it so "failed" goes back to
 > +			 * "repeat": reading a hole and writing should succeed.
 > +			 */
 > +			if (error) {
 > +				VM_BUG_ON(error != -ENOENT);
 > +				delete_from_swap_cache(page);
 > +			}
 >  		}

I ran with this overnight, and still hit the (new!) VM_BUG_ON

Perhaps we should print out what 'error' was too ?  I'll rebuild with that..

------------[ cut here ]------------
WARNING: at mm/shmem.c:1151 shmem_getpage_gfp+0xa5c/0xa70()
Hardware name: 2012 Client Platform
Modules linked in: fuse ipt_ULOG scsi_transport_iscsi binfmt_misc dn_rtmsg nfnetlink nfc caif_socket caif af_802154 phonet af_rxrpc can llc2 pppoe pppox ppp_generic slhc irda crc_ccitt rds af_key decnet rose x25 atm netrom appletalk ipx p8023 p8022 psnap llc ax25 lockd sunrpc bluetooth rfkill ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables gspca_ov519 gspca_main videodev kvm_intel usb_debug kvm crc32c_intel ghash_clmulni_intel microcode pcspkr i2c_i801 e1000e uinput i915 video i2c_algo_bit drm_kms_helper drm i2c_core
Pid: 21798, comm: trinity-child4 Not tainted 3.7.0-rc4+ #54
Call Trace:
 [<ffffffff8107105f>] warn_slowpath_common+0x7f/0xc0
 [<ffffffff810710ba>] warn_slowpath_null+0x1a/0x20
 [<ffffffff8119050c>] shmem_getpage_gfp+0xa5c/0xa70
 [<ffffffff8118fd4e>] ? shmem_getpage_gfp+0x29e/0xa70
 [<ffffffff81190f5f>] shmem_fault+0x4f/0xa0
 [<ffffffff8119f4a1>] __do_fault+0x71/0x5c0
 [<ffffffff810e1b26>] ? __lock_acquire+0x306/0x1ba0
 [<ffffffff810b7059>] ? local_clock+0x89/0xa0
 [<ffffffff811a2877>] handle_pte_fault+0x97/0xae0
 [<ffffffff816d1969>] ? sub_preempt_count+0x79/0xd0
 [<ffffffff8136dbfe>] ? delay_tsc+0xae/0x120
 [<ffffffff8136dae8>] ? __const_udelay+0x28/0x30
 [<ffffffff811a4b49>] handle_mm_fault+0x289/0x350
 [<ffffffff816d121e>] __do_page_fault+0x18e/0x530
 [<ffffffff811f2e70>] ? getname_flags.part.32+0x30/0x150
 [<ffffffff811f2e70>] ? getname_flags.part.32+0x30/0x150
 [<ffffffff811c9c5c>] ? set_track+0x8c/0x1a0
 [<ffffffff816c3dd8>] ? __slab_alloc+0x531/0x59e
 [<ffffffff810e471d>] ? trace_hardirqs_on_caller+0x15d/0x1e0
 [<ffffffff8112d469>] ? rcu_user_exit+0xc9/0xf0
 [<ffffffff816d15eb>] do_page_fault+0x2b/0x50
 [<ffffffff816cdcb8>] page_fault+0x28/0x30
 [<ffffffff81388e2c>] ? strncpy_from_user+0x6c/0x120
 [<ffffffff811f2ec6>] getname_flags.part.32+0x86/0x150
 [<ffffffff811f2fca>] getname+0x3a/0x60
 [<ffffffff811f7aa4>] sys_symlinkat+0x24/0x90
 [<ffffffff816d5f25>] ? tracesys+0x7e/0xe6
 [<ffffffff816d5f88>] tracesys+0xe1/0xe6
---[ end trace 4ba438264ea16e97 ]---



	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
