Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id C7B3F6B0120
	for <linux-mm@kvack.org>; Wed, 27 May 2015 01:51:22 -0400 (EDT)
Received: by pdfh10 with SMTP id h10so110947489pdf.3
        for <linux-mm@kvack.org>; Tue, 26 May 2015 22:51:22 -0700 (PDT)
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com. [202.81.31.146])
        by mx.google.com with ESMTPS id sf10si24255676pbc.111.2015.05.26.22.51.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Tue, 26 May 2015 22:51:21 -0700 (PDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 27 May 2015 15:51:15 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 8EF2E357804F
	for <linux-mm@kvack.org>; Wed, 27 May 2015 15:51:11 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t4R5p2AS64618608
	for <linux-mm@kvack.org>; Wed, 27 May 2015 15:51:10 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t4R5ocDU002056
	for <linux-mm@kvack.org>; Wed, 27 May 2015 15:50:39 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 05/36] HMM: introduce heterogeneous memory management v3.
In-Reply-To: <1432236705-4209-6-git-send-email-j.glisse@gmail.com>
References: <1432236705-4209-1-git-send-email-j.glisse@gmail.com> <1432236705-4209-6-git-send-email-j.glisse@gmail.com>
Date: Wed, 27 May 2015 11:20:05 +0530
Message-ID: <87twuylgc2.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: j.glisse@gmail.com, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Jatin Kumar <jakumar@nvidia.com>, linux-rdma@vger.kernel.org

j.glisse@gmail.com writes:

> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>
> This patch only introduce core HMM functions for registering a new
> mirror and stopping a mirror as well as HMM device registering and
> unregistering.
>
> The lifecycle of HMM object is handled differently then the one of
> mmu_notifier because unlike mmu_notifier there can be concurrent
> call from both mm code to HMM code and/or from device driver code
> to HMM code. Moreover lifetime of HMM can be uncorrelated from the
> lifetime of the process that is being mirror (GPU might take longer
> time to cleanup).
>

......

> +struct hmm_device_ops {
> +	/* release() - mirror must stop using the address space.
> +	 *
> +	 * @mirror: The mirror that link process address space with the device.
> +	 *
> +	 * When this is call, device driver must kill all device thread using

s/call/called, ?

> +	 * this mirror. Also, this callback is the last thing call by HMM and
> +	 * HMM will not access the mirror struct after this call (ie no more
> +	 * dereference of it so it is safe for the device driver to free it).
> +	 * It is call either from :
> +	 *   - mm dying (all process using this mm exiting).
> +	 *   - hmm_mirror_unregister() (if no other thread holds a reference)
> +	 *   - outcome of some device error reported by any of the device
> +	 *     callback against that mirror.
> +	 */
> +	void (*release)(struct hmm_mirror *mirror);
> +};
> +
> +
> +/* struct hmm - per mm_struct HMM states.
> + *
> + * @mm: The mm struct this hmm is associated with.
> + * @mirrors: List of all mirror for this mm (one per device).
> + * @vm_end: Last valid address for this mm (exclusive).
> + * @kref: Reference counter.
> + * @rwsem: Serialize the mirror list modifications.
> + * @mmu_notifier: The mmu_notifier of this mm.
> + * @rcu: For delayed cleanup call from mmu_notifier.release() callback.
> + *
> + * For each process address space (mm_struct) there is one and only one =
hmm
> + * struct. hmm functions will redispatch to each devices the change made=
 to
> + * the process address space.
> + *
> + * Device driver must not access this structure other than for getting t=
he
> + * mm pointer.
> + */

.....

>  #ifndef AT_VECTOR_SIZE_ARCH
>  #define AT_VECTOR_SIZE_ARCH 0
>  #endif
> @@ -451,6 +455,16 @@ struct mm_struct {
>  #ifdef CONFIG_MMU_NOTIFIER
>  	struct mmu_notifier_mm *mmu_notifier_mm;
>  #endif
> +#ifdef CONFIG_HMM
> +	/*
> +	 * hmm always register an mmu_notifier we rely on mmu notifier to keep
> +	 * refcount on mm struct as well as forbiding registering hmm on a
> +	 * dying mm
> +	 *
> +	 * This field is set with mmap_sem old in write mode.

s/old/held/ ?


> +	 */
> +	struct hmm *hmm;
> +#endif
>  #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
>  	pgtable_t pmd_huge_pte; /* protected by page_table_lock */
>  #endif
> diff --git a/kernel/fork.c b/kernel/fork.c
> index 0e0ae9a..4083be7 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -27,6 +27,7 @@
>  #include <linux/binfmts.h>
>  #include <linux/mman.h>
>  #include <linux/mmu_notifier.h>
> +#include <linux/hmm.h>
>  #include <linux/fs.h>
>  #include <linux/mm.h>
>  #include <linux/vmacache.h>
> @@ -597,6 +598,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm=
, struct task_struct *p)
>  	mm_init_aio(mm);
>  	mm_init_owner(mm, p);
>  	mmu_notifier_mm_init(mm);
> +	hmm_mm_init(mm);
>  	clear_tlb_flush_pending(mm);
>  #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
>  	mm->pmd_huge_pte =3D NULL;
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 52ffb86..189e48f 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -653,3 +653,18 @@ config DEFERRED_STRUCT_PAGE_INIT
>  	  when kswapd starts. This has a potential performance impact on
>  	  processes running early in the lifetime of the systemm until kswapd
>  	  finishes the initialisation.
> +
> +if STAGING
> +config HMM
> +	bool "Enable heterogeneous memory management (HMM)"
> +	depends on MMU
> +	select MMU_NOTIFIER
> +	select GENERIC_PAGE_TABLE

What is GENERIC_PAGE_TABLE ?

> +	default n
> +	help
> +	  Heterogeneous memory management provide infrastructure for a device
> +	  to mirror a process address space into an hardware mmu or into any
> +	  things supporting pagefault like event.
> +
> +	  If unsure, say N to disable hmm.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
