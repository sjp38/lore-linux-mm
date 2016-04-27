Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f71.google.com (mail-qg0-f71.google.com [209.85.192.71])
	by kanga.kvack.org (Postfix) with ESMTP id 333BF6B0005
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 11:00:01 -0400 (EDT)
Received: by mail-qg0-f71.google.com with SMTP id c103so77316689qge.1
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 08:00:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e46si2687614qgd.31.2016.04.27.08.00.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Apr 2016 08:00:00 -0700 (PDT)
Date: Wed, 27 Apr 2016 16:59:57 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/1] mm: thp: kvm: fix memory corruption in KVM with THP
 enabled
Message-ID: <20160427145957.GA9217@redhat.com>
References: <1461758686-27157-1-git-send-email-aarcange@redhat.com>
 <20160427135030.GB22035@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160427135030.GB22035@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, "Li, Liang Z" <liang.z.li@intel.com>, Amit Shah <amit.shah@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>

On Wed, Apr 27, 2016 at 04:50:30PM +0300, Kirill A. Shutemov wrote:
> I know nothing about kvm. How do you protect against pmd splitting between
> get_user_pages() and the check?

get_user_pages_fast() runs fully lockless and unpins the page right
away (we need a get_user_pages_fast without the FOLL_GET in fact to
avoid a totally useless atomic_inc/dec!).

Then we take a lock that is also taken by
mmu_notifier_invalidate_range_start. This way __split_huge_pmd will
block in mmu_notifier_invalidate_range_start if it tries to run again
(every other mmu notifier like mmu_notifier_invalidate_page will also
block).

Then after we serialized against __split_huge_pmd through the MMU
notifier KVM internal locking, we are able to tell if any mmu_notifier
invalidate happened in the region just before get_user_pages_fast()
was invoked, until we call PageCompoundTransMap and we actually map
the shadow pagetable into the compound page with hugepage
granularity (to allow real 2MB TLBs if guest also uses trans_huge_pmd
in the guest pagetables).

After the shadow pagetable is mapped, we drop the internal MMU
notifier lock and __split_huge_pmd mmu_notifier_invalidate_range_start
can continue and drop the shadow pagetable that we just mapped in the
above paragraph just before dropping the mmu notifier internal lock.

To be able to tell if any invalidate happened while
get_user_pages_fast was running and until we grab the lock again and
we start mapping the shadow pagtable we use:

	mmu_seq = vcpu->kvm->mmu_notifier_seq;
	smp_rmb();

	if (try_async_pf(vcpu, prefault, gfn, v, &pfn, write, &map_writable))
	    ^^^^^^^^^^^^ this is get_user_pages and does put_page on the page
	    		 and just returns the &pfn
	    		 this is why we need a get_user_pages_fast that won't
			 attempt to touch the page->_count at all! we can avoid
			 2 atomic ops for each secondary MMU fault that way
		return 0;

	spin_lock(&vcpu->kvm->mmu_lock);
	if (mmu_notifier_retry(vcpu->kvm, mmu_seq))
		goto out_unlock;
	... here we check PageTransCompoundMap(pfn_to_page(pfn)) and
	map a 4k or 2MB shadow pagetable on "pfn" ...


Note mmu_notifier_retry does the other side of the smp_rmb():

	smp_rmb();
	if (kvm->mmu_notifier_seq != mmu_seq)
		return 1;
	return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
