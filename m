Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id 8F0CB6B0254
	for <linux-mm@kvack.org>; Mon, 13 Jul 2015 09:23:45 -0400 (EDT)
Received: by qgep37 with SMTP id p37so63845494qge.1
        for <linux-mm@kvack.org>; Mon, 13 Jul 2015 06:23:45 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 102si20783934qgk.119.2015.07.13.06.23.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jul 2015 06:23:44 -0700 (PDT)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH 06/10] mm: Add vmf_insert_pfn_pmd()
References: <1436560165-8943-1-git-send-email-matthew.r.wilcox@intel.com>
	<1436560165-8943-7-git-send-email-matthew.r.wilcox@intel.com>
Date: Mon, 13 Jul 2015 09:23:41 -0400
In-Reply-To: <1436560165-8943-7-git-send-email-matthew.r.wilcox@intel.com>
	(Matthew Wilcox's message of "Fri, 10 Jul 2015 16:29:21 -0400")
Message-ID: <x49r3oc6vj6.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>

Matthew Wilcox <matthew.r.wilcox@intel.com> writes:

> +static int insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
> +		pmd_t *pmd, unsigned long pfn, pgprot_t prot, bool write)
> +{
> +	struct mm_struct *mm = vma->vm_mm;
> +	pmd_t entry;
> +	spinlock_t *ptl;
> +
> +	ptl = pmd_lock(mm, pmd);
> +	if (pmd_none(*pmd)) {
> +		entry = pmd_mkhuge(pfn_pmd(pfn, prot));
> +		if (write) {
> +			entry = pmd_mkyoung(pmd_mkdirty(entry));
> +			entry = maybe_pmd_mkwrite(entry, vma);
> +		}
> +		set_pmd_at(mm, addr, pmd, entry);
> +		update_mmu_cache_pmd(vma, addr, pmd);
> +	}
> +	spin_unlock(ptl);
> +	return VM_FAULT_NOPAGE;
> +}

What's the point of the return value?

Cheers,
Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
