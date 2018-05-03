Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7FA946B0026
	for <linux-mm@kvack.org>; Thu,  3 May 2018 06:44:27 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b83so5483265wme.7
        for <linux-mm@kvack.org>; Thu, 03 May 2018 03:44:27 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id g2-v6si3125113edn.83.2018.05.03.03.44.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 May 2018 03:44:25 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w43AiLXN099353
	for <linux-mm@kvack.org>; Thu, 3 May 2018 06:44:24 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2hqyt4b3a4-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 03 May 2018 06:44:23 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <imbrenda@linux.vnet.ibm.com>;
	Thu, 3 May 2018 11:44:21 +0100
Date: Thu, 3 May 2018 12:44:15 +0200
From: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/ksm: ignore STABLE_FLAG of rmap_item->address in
 rmap_walk_ksm
In-Reply-To: <1525336488-25447-1-git-send-email-hejianet@gmail.com>
References: <1525336488-25447-1-git-send-email-hejianet@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Message-Id: <20180503124415.3f9d38aa@p-imbrenda.boeblingen.de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan@kernel.org>, Arvind Yadav <arvind.yadav.cs@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jia.he@hxt-semitech.com

On Thu,  3 May 2018 16:34:48 +0800
Jia He <hejianet@gmail.com> wrote:

> In our armv8a server(QDF2400), I noticed a WARN_ON caused by PAGE_SIZE
> unaligned for rmap_item->address.
> 
> --------------------------begin--------------------------------------
> [  410.853828] WARNING: CPU: 4 PID: 4641 at
> arch/arm64/kvm/../../../virt/kvm/arm/mmu.c:1826
> kvm_age_hva_handler+0xc0/0xc8
> [  410.864518] Modules linked in: vhost_net vhost tap xt_CHECKSUM
> ipt_MASQUERADE nf_nat_masquerade_ipv4 ip6t_rpfilter ipt_REJECT
> nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set
> nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat
> nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle
> ip6table_security ip6table_raw iptable_nat nf_conntrack_ipv4
> nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle
> iptable_security iptable_raw ebtable_filter ebtables ip6table_filter
> ip6_tables iptable_filter rpcrdma ib_isert iscsi_target_mod ib_iser
> libiscsi scsi_transport_iscsi ib_srpt target_core_mod ib_srp
> scsi_transport_srp ib_ipoib rdma_ucm ib_ucm ib_umad rdma_cm ib_cm
> iw_cm mlx5_ib vfat fat ib_uverbs dm_mirror dm_region_hash ib_core
> dm_log dm_mod crc32_ce ipmi_ssif sg nfsd [  410.935101]  auth_rpcgss
> nfs_acl lockd grace sunrpc ip_tables xfs libcrc32c mlx5_core ixgbe
> mlxfw devlink mdio ahci_platform libahci_platform qcom_emac libahci
> hdma hdma_mgmt i2c_qup [  410.951369] CPU: 4 PID: 4641 Comm: memhog
> Tainted: G        W 4.17.0-rc3+ #8
> [  410.959104] Hardware name: <snip for confidential issues>
> [  410.969791] pstate: 80400005 (Nzcv daif +PAN -UAO)
> [  410.974575] pc : kvm_age_hva_handler+0xc0/0xc8
> [  410.979012] lr : handle_hva_to_gpa+0xa8/0xe0
> [  410.983274] sp : ffff801761553290
> [  410.986581] x29: ffff801761553290 x28: 0000000000000000
> [  410.991888] x27: 0000000000000002 x26: 0000000000000000
> [  410.997195] x25: ffff801765430058 x24: ffff0000080b5608
> [  411.002501] x23: 0000000000000000 x22: ffff8017ccb84000
> [  411.007807] x21: 0000000003ff0000 x20: ffff8017ccb84000
> [  411.013113] x19: 000000000000fe00 x18: ffff000008fb3c08
> [  411.018419] x17: 0000000000000000 x16: 0060001645820bd3
> [  411.023725] x15: ffff80176aacbc08 x14: 0000000000000000
> [  411.029031] x13: 0000000000000040 x12: 0000000000000228
> [  411.034337] x11: 0000000000000000 x10: 0000000000000000
> [  411.039643] x9 : 0000000000000010 x8 : 0000000000000004
> [  411.044949] x7 : 0000000000000000 x6 : 00008017f0770000
> [  411.050255] x5 : 0000fffda59f0200 x4 : 0000000000000000
> [  411.055561] x3 : 0000000000000000 x2 : 000000000000fe00
> [  411.060867] x1 : 0000000003ff0000 x0 : 0000000020000000
> [  411.066173] Call trace:
> [  411.068614]  kvm_age_hva_handler+0xc0/0xc8
> [  411.072703]  handle_hva_to_gpa+0xa8/0xe0
> [  411.076619]  kvm_age_hva+0x4c/0xe8
> [  411.080014]  kvm_mmu_notifier_clear_flush_young+0x54/0x98
> [  411.085408]  __mmu_notifier_clear_flush_young+0x6c/0xa0
> [  411.090627]  page_referenced_one+0x154/0x1d8
> [  411.094890]  rmap_walk_ksm+0x12c/0x1d0
> [  411.098632]  rmap_walk+0x94/0xa0
> [  411.101854]  page_referenced+0x194/0x1b0
> [  411.105770]  shrink_page_list+0x674/0xc28
> [  411.109772]  shrink_inactive_list+0x26c/0x5b8
> [  411.114122]  shrink_node_memcg+0x35c/0x620
> [  411.118211]  shrink_node+0x100/0x430
> [  411.121778]  do_try_to_free_pages+0xe0/0x3a8
> [  411.126041]  try_to_free_pages+0xe4/0x230
> [  411.130045]  __alloc_pages_nodemask+0x564/0xdc0
> [  411.134569]  alloc_pages_vma+0x90/0x228
> [  411.138398]  do_anonymous_page+0xc8/0x4d0
> [  411.142400]  __handle_mm_fault+0x4a0/0x508
> [  411.146489]  handle_mm_fault+0xf8/0x1b0
> [  411.150321]  do_page_fault+0x218/0x4b8
> [  411.154064]  do_translation_fault+0x90/0xa0
> [  411.158239]  do_mem_abort+0x68/0xf0
> [  411.161721]  el0_da+0x24/0x28
> ---------------------------end---------------------------------------
> 
> In rmap_walk_ksm, the rmap_item->address might still have the
> STABLE_FLAG, then the start and end in handle_hva_to_gpa might not be
> PAGE_SIZE aligned. Thus it causes exceptions in handle_hva_to_gpa on
> arm64.
> 
> This patch fixes it by ignoring the low bits of rmap_item->address
> when doing rmap_walk_ksm.
> 
> Signed-off-by: jia.he@hxt-semitech.com
> ---
>  mm/ksm.c | 15 +++++++++++----
>  1 file changed, 11 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/ksm.c b/mm/ksm.c
> index e3cbf9a..3f0d980 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -199,6 +199,8 @@ struct rmap_item {
>  #define SEQNR_MASK	0x0ff	/* low bits of unstable tree
> seqnr */ #define UNSTABLE_FLAG	0x100	/* is a node of
> the unstable tree */ #define STABLE_FLAG	0x200	/* is
> listed from the stable tree */ +#define KSM_FLAG_MASK
> (SEQNR_MASK|UNSTABLE_FLAG|STABLE_FLAG)
> +				/* to mask all the flags */
> 
>  /* The stable and unstable tree heads */
>  static struct rb_root one_stable_tree[1] = { RB_ROOT };
> @@ -2570,10 +2572,13 @@ void rmap_walk_ksm(struct page *page, struct
> rmap_walk_control *rwc) anon_vma_lock_read(anon_vma);
>  		anon_vma_interval_tree_foreach(vmac,
> &anon_vma->rb_root, 0, ULONG_MAX) {
> +			unsigned long addr;
> +
>  			cond_resched();
>  			vma = vmac->vma;
> -			if (rmap_item->address < vma->vm_start ||
> -			    rmap_item->address >= vma->vm_end)
> +
> +			addr = rmap_item->address;

why not just: addr = rmap_item->address & ~KSM_FLAG_MASK;

> +			if (addr < vma->vm_start || addr >=
> vma->vm_end) continue;
>  			/*
>  			 * Initially we examine only the vma which
> covers this @@ -2587,8 +2592,10 @@ void rmap_walk_ksm(struct page
> *page, struct rmap_walk_control *rwc) if (rwc->invalid_vma &&
> rwc->invalid_vma(vma, rwc->arg)) continue;
> 
> -			if (!rwc->rmap_one(page, vma,
> -					rmap_item->address,
> rwc->arg)) {
> +			if (addr & STABLE_FLAG)
> +				addr &= ~KSM_FLAG_MASK;

then you would not need the IF above, and it would be more readable.

> +
> +			if (!rwc->rmap_one(page, vma, addr,
> rwc->arg)) { anon_vma_unlock_read(anon_vma);
>  				return;
>  			}


best regards,

Claudio Imbrenda
