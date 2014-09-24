Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 297E96B0037
	for <linux-mm@kvack.org>; Tue, 23 Sep 2014 22:25:25 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id v10so5774157pde.22
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 19:25:24 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id xj1si23609377pbc.210.2014.09.23.19.25.23
        for <linux-mm@kvack.org>;
        Tue, 23 Sep 2014 19:25:24 -0700 (PDT)
Date: Wed, 24 Sep 2014 10:27:29 +0800
From: Wanpeng Li <wanpeng.li@linux.intel.com>
Subject: Re: [PATCH v4] kvm: Fix page ageing bugs
Message-ID: <20140924022729.GA2889@kernel>
Reply-To: Wanpeng Li <wanpeng.li@linux.intel.com>
References: <1411410865-3603-1-git-send-email-andreslc@google.com>
 <1411422882-16245-1-git-send-email-andreslc@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1411422882-16245-1-git-send-email-andreslc@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andres Lagar-Cavilla <andreslc@google.com>
Cc: Gleb Natapov <gleb@kernel.org>, Radim Krcmar <rkrcmar@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Peter Feiner <pfeiner@google.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Andres,
On Mon, Sep 22, 2014 at 02:54:42PM -0700, Andres Lagar-Cavilla wrote:
>1. We were calling clear_flush_young_notify in unmap_one, but we are
>within an mmu notifier invalidate range scope. The spte exists no more
>(due to range_start) and the accessed bit info has already been
>propagated (due to kvm_pfn_set_accessed). Simply call
>clear_flush_young.
>
>2. We clear_flush_young on a primary MMU PMD, but this may be mapped
>as a collection of PTEs by the secondary MMU (e.g. during log-dirty).
>This required expanding the interface of the clear_flush_young mmu
>notifier, so a lot of code has been trivially touched.
>
>3. In the absence of shadow_accessed_mask (e.g. EPT A bit), we emulate
>the access bit by blowing the spte. This requires proper synchronizing
>with MMU notifier consumers, like every other removal of spte's does.
>
[...]
>---
>+	BUG_ON(!shadow_accessed_mask);
> 
> 	for (sptep = rmap_get_first(*rmapp, &iter); sptep;
> 	     sptep = rmap_get_next(&iter)) {
>+		struct kvm_mmu_page *sp;
>+		gfn_t gfn;
> 		BUG_ON(!is_shadow_present_pte(*sptep));
>+		/* From spte to gfn. */
>+		sp = page_header(__pa(sptep));
>+		gfn = kvm_mmu_page_get_gfn(sp, sptep - sp->spt);
> 
> 		if (*sptep & shadow_accessed_mask) {
> 			young = 1;
> 			clear_bit((ffs(shadow_accessed_mask) - 1),
> 				 (unsigned long *)sptep);
> 		}
>+		trace_kvm_age_page(gfn, slot, young);

IIUC, all the rmapps in this for loop are against the same gfn which
results in the above trace point dump the message duplicated.

Regards,
Wanpeng Li 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
