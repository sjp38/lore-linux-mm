Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C363BC31E44
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 05:31:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 43EEE218A0
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 05:31:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ozlabs.org header.i=@ozlabs.org header.b="jkus+um0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 43EEE218A0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=ozlabs.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 907838E0003; Mon, 17 Jun 2019 01:31:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8910D8E0001; Mon, 17 Jun 2019 01:31:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 70B838E0003; Mon, 17 Jun 2019 01:31:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 348908E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 01:31:17 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id i27so1765373pfk.12
        for <linux-mm@kvack.org>; Sun, 16 Jun 2019 22:31:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=+p+ElvDOgYDG9n12k688bEmTg17K3rAfUiKpW4cHcJk=;
        b=JU1hwqmRjjxsVLbCWAGlyRzhtjnkAayGG+Tqp69AxBnsmN2vJKyNHX6x80M7dXEWnn
         WRK32tmpnnUMdy/izxNKS69wLzJfSkEO0oqJnupSpP7Uk/k97TDnM96/s7gi63jFluVb
         DKy/MD1yBF4YzuoEwJu+z4Ys8qXZrs8iGYZQEn38YwM7YzIPUs3iaZpEHT4Ih+KLcsNk
         4uFVbWaRWeYNhmQvH123xeQ1F6DeK7SAWNvtepu+49mETKTYY6D17huIVwUsaK5+wDuJ
         NR7ShamEnohzzaijvqe2Ek0KaoYJnSfoHk36tjsqs9De7H9+sKuHmDkO8rdnbV3b01Oc
         +e/Q==
X-Gm-Message-State: APjAAAUHZXU0oMXfiZqf839Ghb4pZu51e9t2AAQNfFlZ924YFMurQqfH
	sNQ4Yz0D6kmEckcHSbgMpBb5XBKBQHCzLUQuBZoN8nRbewYXg0TqcQI1cU4DLKAQwycGTa3cn5f
	W177Cc8DPMTNxZ3UZSdKh27xjphhh4Hnb7pQG/iuk3sIxuCUFjk/XFNSN4qjGBDdA/g==
X-Received: by 2002:a17:902:76c6:: with SMTP id j6mr81191197plt.263.1560749476562;
        Sun, 16 Jun 2019 22:31:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwZll6QNh1aAWkihZbvVwKXv6jNbS6Q7y34lKrpLg4oIeD6APwgtbUNBeHRZCs122cwBLNM
X-Received: by 2002:a17:902:76c6:: with SMTP id j6mr81191147plt.263.1560749475715;
        Sun, 16 Jun 2019 22:31:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560749475; cv=none;
        d=google.com; s=arc-20160816;
        b=OW0mPSQsbnu/SUTRhomV+IbkGGw15Z2ZpRdkzU6O8D08Qj6Ia72Rw/poVD1OJeIfvt
         ViBKTl0+N5Px2019HyOO48XZYo3UMKd3tU2/eN7OGz1tPG+hLyOr7RuJmIY8LfdA9XiP
         b+U8pJ6h32xqFzjJILantYY3SgZiFTZkHwS1N1BtEjSi10reBcZnt3Kq9h6w6/K0jZa/
         Wy9GO9eMcBEL8aHrsWU/uCUy33N/ko3DjEXoMCwkRRLbyioqhKXIyn9l5AswGutgdum4
         //OMRdE8sgDYF/jLaHUEC9/AMytE4v+DpZiKasEAj62awZWjqvqmbhqNC/e56BtFafIs
         rf0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=+p+ElvDOgYDG9n12k688bEmTg17K3rAfUiKpW4cHcJk=;
        b=gV+I4Kwe6pygR+g/DSmwUjX+gm0C1H1XBONaKlIuqkLLYN9TNeIf5cHrkH1wx7Sy2O
         mT4mw/Zie0uiWknlMs0mL+AivQi6ZGbFjTI6lcelgrylDsKJPkjDHy0l8wHB9Fq4iOFo
         0ib7koQvm0eEsHV7v6E2p4LagQQMwVRP0zt8CI2ulQtZxrL7BjmX+RDMvTPoN1ZjWl91
         mSPC1lgA1RoSnMAYKLFD+OKRMFnNuyNLDU3Mdd80dbQyDRx2ECwRy0KDac4sm8B/8a65
         73gSE7BUPj2KpWumFjIthSIzUNJ37l3QaW2NpCSvOfDms/ZF5cgPPNl5AghFTrXKMUvm
         cxNA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ozlabs.org header.s=201707 header.b=jkus+um0;
       spf=pass (google.com: domain of paulus@ozlabs.org designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=paulus@ozlabs.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ozlabs.org
Received: from ozlabs.org (bilbo.ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id u66si2538391pgb.219.2019.06.16.22.31.15
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 16 Jun 2019 22:31:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of paulus@ozlabs.org designates 2401:3900:2:1::2 as permitted sender) client-ip=2401:3900:2:1::2;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ozlabs.org header.s=201707 header.b=jkus+um0;
       spf=pass (google.com: domain of paulus@ozlabs.org designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=paulus@ozlabs.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ozlabs.org
Received: by ozlabs.org (Postfix, from userid 1003)
	id 45S0Dt5YTVz9sBr; Mon, 17 Jun 2019 15:31:10 +1000 (AEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=ozlabs.org; s=201707;
	t=1560749470; bh=lu5tLzpTIuP7SAD2hJCgjD6o3PI3Z3AU1ddnYIWPxKs=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=jkus+um0JDg502lcrULwMT3JKhnQCxDYvL7qOwOWZ1WFpyNd1hZxyFJLOns2jPmsl
	 VysoUfSO/kePG8qojBjl3TcsJPa5JcZIiEUBDMaT6oICWGPshkm2hSBiYmKJt9HKbx
	 wwlpXSkCRAaOEDm5UqgN4vHEPb4gqvQC+vP1+ksBbWaYgaJeYS7Mc6r1ndunkiZsxe
	 5OgJ9/RmlzDEe3ROWKbpS2faiI/XcoBZLC+oKQCTrUE4kfOqHZZB0e4+GhsvKU71/z
	 PH2e4QNgXGZKMP3MYxic8k8fJt3vijyhJwTraBJxMARt+DSCvsf5Mat6R6XxLyqj+b
	 i9geK5pcpAPuw==
Date: Mon, 17 Jun 2019 15:31:06 +1000
From: Paul Mackerras <paulus@ozlabs.org>
To: Bharata B Rao <bharata@linux.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org,
	linux-mm@kvack.org, paulus@au1.ibm.com,
	aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com,
	linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
	cclaudio@linux.ibm.com
Subject: Re: [PATCH v4 1/6] kvmppc: HMM backend driver to manage pages of
 secure guest
Message-ID: <20190617053106.lqwzibpsz4d2464z@oak.ozlabs.ibm.com>
References: <20190528064933.23119-1-bharata@linux.ibm.com>
 <20190528064933.23119-2-bharata@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190528064933.23119-2-bharata@linux.ibm.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 28, 2019 at 12:19:28PM +0530, Bharata B Rao wrote:
> HMM driver for KVM PPC to manage page transitions of
> secure guest via H_SVM_PAGE_IN and H_SVM_PAGE_OUT hcalls.
> 
> H_SVM_PAGE_IN: Move the content of a normal page to secure page
> H_SVM_PAGE_OUT: Move the content of a secure page to normal page

Comments below...

> @@ -4421,6 +4435,7 @@ static void kvmppc_core_free_memslot_hv(struct kvm_memory_slot *free,
>  					struct kvm_memory_slot *dont)
>  {
>  	if (!dont || free->arch.rmap != dont->arch.rmap) {
> +		kvmppc_hmm_release_pfns(free);

I don't think this is the right place to do this.  The memslot will
have no pages mapped by this time, because higher levels of code will
have called kvmppc_core_flush_memslot_hv() before calling this.
Releasing the pfns should be done in that function.

> diff --git a/arch/powerpc/kvm/book3s_hv_hmm.c b/arch/powerpc/kvm/book3s_hv_hmm.c
> new file mode 100644
> index 000000000000..713806003da3

...

> +#define KVMPPC_PFN_HMM		(0x1ULL << 61)
> +
> +static inline bool kvmppc_is_hmm_pfn(unsigned long pfn)
> +{
> +	return !!(pfn & KVMPPC_PFN_HMM);
> +}

Since you are putting in these values in the rmap entries, you need to
be careful about overlaps between these values and the other uses of
rmap entries.  The value you have chosen would be in the middle of the
LPID field for an rmap entry for a guest that has nested guests, and
in fact kvmhv_remove_nest_rmap_range() effectively assumes that a
non-zero rmap entry must be a list of L2 guest mappings.  (This is for
radix guests; HPT guests use the rmap entry differently, but I am
assuming that we will enforce that only radix guests can be secure
guests.)

Maybe it is true that the rmap entry will be non-zero only for those
guest pages which are not mapped on the host side, that is,
kvmppc_radix_flush_memslot() will see !pte_present(*ptep) for any page
of a secure guest where the rmap entry contains a HMM pfn.  If that is
so and is a deliberate part of the design, then I would like to see it
written down in comments and commit messages so it's clear to others
working on the code in future.

Suraj is working on support for nested HPT guests, which will involve
changing the rmap format to indicate more explicitly what sort of
entry each rmap entry is.  Please work with him to define a format for
your rmap entries that is clearly distinguishable from the others.

I think it is reasonable to say that a secure guest can't have nested
guests, at least for now, but then we should make sure to kill all
nested guests when a guest goes secure.

...

> +/*
> + * Move page from normal memory to secure memory.
> + */
> +unsigned long
> +kvmppc_h_svm_page_in(struct kvm *kvm, unsigned long gpa,
> +		     unsigned long flags, unsigned long page_shift)
> +{
> +	unsigned long addr, end;
> +	unsigned long src_pfn, dst_pfn;
> +	struct kvmppc_hmm_migrate_args args;
> +	struct vm_area_struct *vma;
> +	int srcu_idx;
> +	unsigned long gfn = gpa >> page_shift;
> +	struct kvm_memory_slot *slot;
> +	unsigned long *rmap;
> +	int ret = H_SUCCESS;
> +
> +	if (page_shift != PAGE_SHIFT)
> +		return H_P3;
> +
> +	srcu_idx = srcu_read_lock(&kvm->srcu);
> +	slot = gfn_to_memslot(kvm, gfn);
> +	rmap = &slot->arch.rmap[gfn - slot->base_gfn];
> +	addr = gfn_to_hva(kvm, gpa >> page_shift);
> +	srcu_read_unlock(&kvm->srcu, srcu_idx);

Shouldn't we keep the srcu read lock until we have finished working on
the page?

> +	if (kvm_is_error_hva(addr))
> +		return H_PARAMETER;
> +
> +	end = addr + (1UL << page_shift);
> +
> +	if (flags)
> +		return H_P2;
> +
> +	args.rmap = rmap;
> +	args.lpid = kvm->arch.lpid;
> +	args.gpa = gpa;
> +	args.page_shift = page_shift;
> +
> +	down_read(&kvm->mm->mmap_sem);
> +	vma = find_vma_intersection(kvm->mm, addr, end);
> +	if (!vma || vma->vm_start > addr || vma->vm_end < end) {
> +		ret = H_PARAMETER;
> +		goto out;
> +	}
> +	ret = migrate_vma(&kvmppc_hmm_migrate_ops, vma, addr, end,
> +			  &src_pfn, &dst_pfn, &args);
> +	if (ret < 0)
> +		ret = H_PARAMETER;
> +out:
> +	up_read(&kvm->mm->mmap_sem);
> +	return ret;
> +}

...

> +/*
> + * Move page from secure memory to normal memory.
> + */
> +unsigned long
> +kvmppc_h_svm_page_out(struct kvm *kvm, unsigned long gpa,
> +		      unsigned long flags, unsigned long page_shift)
> +{
> +	unsigned long addr, end;
> +	struct vm_area_struct *vma;
> +	unsigned long src_pfn, dst_pfn = 0;
> +	int srcu_idx;
> +	int ret = H_SUCCESS;
> +
> +	if (page_shift != PAGE_SHIFT)
> +		return H_P3;
> +
> +	if (flags)
> +		return H_P2;
> +
> +	srcu_idx = srcu_read_lock(&kvm->srcu);
> +	addr = gfn_to_hva(kvm, gpa >> page_shift);
> +	srcu_read_unlock(&kvm->srcu, srcu_idx);

and likewise here, shouldn't we unlock later, after the migrate_vma()
call perhaps?

> +	if (kvm_is_error_hva(addr))
> +		return H_PARAMETER;
> +
> +	end = addr + (1UL << page_shift);
> +
> +	down_read(&kvm->mm->mmap_sem);
> +	vma = find_vma_intersection(kvm->mm, addr, end);
> +	if (!vma || vma->vm_start > addr || vma->vm_end < end) {
> +		ret = H_PARAMETER;
> +		goto out;
> +	}
> +	ret = migrate_vma(&kvmppc_hmm_fault_migrate_ops, vma, addr, end,
> +			  &src_pfn, &dst_pfn, NULL);
> +	if (ret < 0)
> +		ret = H_PARAMETER;
> +out:
> +	up_read(&kvm->mm->mmap_sem);
> +	return ret;
> +}
> +

Paul.

