Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31520C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 07:40:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A50D020B1F
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 07:40:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="FGi86tdO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A50D020B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 47B186B0003; Tue,  6 Aug 2019 03:40:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3DC056B0005; Tue,  6 Aug 2019 03:40:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 208356B0006; Tue,  6 Aug 2019 03:40:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id C57566B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 03:40:11 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id n9so50944662pgq.4
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 00:40:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=12FyEF6K3MNvIzPnggkt1Z9WBuciGs/Z0ma8Zh3fqYQ=;
        b=mNf7htZpbbvp60TDDQh4WMLuZ19LmRYwITO9u5iGve2x8jyQOM0L+D8RaLYg7HpRuY
         8lrVPLeL1KrDAnCti1wm3rtC7xvR35m8d91Nir0NbGWOG2BUCkPyyHlaF5Pmic7aMZzD
         mjinYw68/IKiEdQbD0KLzHBN9YyMQGs0WImuNWccfVkp4MtphWuIQJDx6vc9o6Xm6PF6
         uayuV1KAWQZ5xqm1g0pzJJhEcoHli/5HW7w7xdqWQTsXBzMJdaXosTE2QRX9/CuocQSt
         YDaEogEtHcNbvmBVTQIUHpp0HphY1NvDsble8id8PnnDeqKzBUx8Txns2vNY1tYVlpGz
         pC1g==
X-Gm-Message-State: APjAAAUXZBSSMxZiwJ5JIuZy80MurD0CCOTiXoXfxY/iMn+Yb4Fxbc1y
	AHQ/gPMmxbmQ+ELWp47vgqNU8MUkxAb5UPg8BCqyr0fJ//lHWsawfWq+LN4TU+O9vVHFL4rpbaX
	ORKkmJPoiefTalZb5NGYHveKBFxVVPYzznbe39g8r38l2EcgmK3vRTdHaGJIrP//alA==
X-Received: by 2002:a17:90a:1c17:: with SMTP id s23mr1820097pjs.108.1565077211321;
        Tue, 06 Aug 2019 00:40:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx0d1Z4w/4Ihgi0nYddzEMnaW1TDBayKlhBKvCR4m8VSqmHRn1jSHq3v5mCChd8Mc7ehyAz
X-Received: by 2002:a17:90a:1c17:: with SMTP id s23mr1819953pjs.108.1565077209050;
        Tue, 06 Aug 2019 00:40:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565077209; cv=none;
        d=google.com; s=arc-20160816;
        b=G19bszV2v1sUdFMb3YQyBPxgtzokYBP3szX7TphvuVfB55Lxo7gmxFNMEUa3tdHHdZ
         6QI59BQsL0SBzqU3G8iM7fhXdJwz2N3IAhhZo7ogeDy17ufuDagCsAgPRNwo0IReMyVl
         JODQKz9OP5mAw+LRlCRGM9OsL/I8eqkBS+sgKIFZ5wcpt7ShQ4EsNU0IptCZ7AVjqKVX
         cMtd1xaBC1QUZmv8oLheccBQQoTIHAbxj3nsobWpas4r/GER5EaLTxELbWVd2FnOwwLf
         8f/m34qEnozFLnUmNUxP6gdWpEkPTpIDRCx/TH12HH+ykl+a33Yr2Asjpe9l9fLpZxXk
         SCKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=12FyEF6K3MNvIzPnggkt1Z9WBuciGs/Z0ma8Zh3fqYQ=;
        b=bHNE7ZhV/Wfg1BqQZDAnzVqf2XRJOiQu5KM5PxKXw13vus/d24jMfj8LaZj+34ZWEq
         jMEyCRoLIiTjQq/HJMYPXO+L22qoHBEW934d0aeOjwdttS0rKzyb+A7EBa8C7bAcFYME
         A8NT5blSgkD5gHnKDtuhfB5b+ATtAgamjWFPi926GqyOQoZFNOFMzMYW7f4+55ZbDvPt
         DChFf7Lz43BXzZaWMi1c4nnK3fXYjxS5SOpaLheO8ZVW2OrHxGH5043/mS6ACkN+tINI
         9XZM2yhFVojRmwajPDX6P6k+TWpzHmmYL698onDCQ0pl86vkLjJJ3smW/pwPLyasyLus
         fv3g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=FGi86tdO;
       spf=pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x24si55470858pfr.200.2019.08.06.00.40.08
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 00:40:09 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=FGi86tdO;
       spf=pass (google.com: best guess record for domain of batv+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+71fb6172ac18b852553b+5826+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=12FyEF6K3MNvIzPnggkt1Z9WBuciGs/Z0ma8Zh3fqYQ=; b=FGi86tdOIr54aLGpX5HHrQjLW
	QUteE4CmaVOQIE6H0gisziq2Nthcd3pGmV0ypPY07EHgKHA1JRaJ+rqOPs2wMMvd1yn1uAZfpu5UP
	X80GZzLfVzkrkhLQRWFn3briiDjVhhvK/n/mbEzYsmjTD+Ft5I4cwPhtC4RrbDsczV61ahpGDgipI
	ONxr1cqh5pnLVL9+uayBxrqLUORKn7G/pmyxmLk4aXc4E1uqv1LUFybH5PS1tZOgybh/SeqwdUWAs
	br9P998YpyHVDs9NOGxmIb54ikp6lLb74tbyhtgFZsR873BWlasfNonCUub2x4HfMrs3ZQdNbgx7W
	W8JufoxzQ==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1huu4f-0000aj-Bg; Tue, 06 Aug 2019 07:40:01 +0000
Date: Tue, 6 Aug 2019 00:40:01 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Thomas =?iso-8859-1?Q?Hellstr=F6m_=28VMware=29?= <thomas@shipmail.org>,
	Dave Airlie <airlied@gmail.com>,
	Thomas Hellstrom <thellstrom@vmware.com>,
	Daniel Vetter <daniel.vetter@ffwll.ch>,
	LKML <linux-kernel@vger.kernel.org>,
	dri-devel <dri-devel@lists.freedesktop.org>,
	Jerome Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Steven Price <steven.price@arm.com>, linux-mm@kvack.org
Subject: Re: drm pull for v5.3-rc1
Message-ID: <20190806074001.GA2147@infradead.org>
References: <CAPM=9tzJQ+26n_Df1eBPG1A=tXf4xNuVEjbG3aZj-aqYQ9nnAg@mail.gmail.com>
 <CAPM=9twvwhm318btWy_WkQxOcpRCzjpok52R8zPQxQrnQ8QzwQ@mail.gmail.com>
 <CAHk-=wjC3VX5hSeGRA1SCLjT+hewPbbG4vSJPFK7iy26z4QAyw@mail.gmail.com>
 <CAHk-=wiD6a189CXj-ugRzCxA9r1+siSCA0eP_eoZ_bk_bLTRMw@mail.gmail.com>
 <48890b55-afc5-ced8-5913-5a755ce6c1ab@shipmail.org>
 <CAHk-=whwcMLwcQZTmWgCnSn=LHpQG+EBbWevJEj5YTKMiE_-oQ@mail.gmail.com>
 <CAHk-=wghASUU7QmoibQK7XS09na7rDRrjSrWPwkGz=qLnGp_Xw@mail.gmail.com>
 <20190806073831.GA26668@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806073831.GA26668@infradead.org>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[adding the real linux-mm list now]

On Tue, Aug 06, 2019 at 12:38:31AM -0700, Christoph Hellwig wrote:
> On Mon, Jul 15, 2019 at 03:17:42PM -0700, Linus Torvalds wrote:
> > The attached patch does add more lines than it removes, but in most
> > cases it's actually a clear improvement.
> 
> Seems like no one took this up.  Below is a version which I think is
> slightly better by also moving the mm_walk structure initialization
> into the helpers, with an outcome of just a handful of added lines.
> 
> What I also noticed doing that is that a lot of walk_page_range users
> have a vma at hand and should probably use walk_vma_range.
> 
> But one thing I noticed is that we don't just have Thomas series that
> touches this area, but also the "Generic page walk and ptdump" one
> from Steven.  In addition various users of the functionality are under
> heavy development.
> 
> So I think we need to queue this up in an actual git tree that others
> can pull in, similar to the hmm model.
> 
> --
> From 67c1c6b56322bdd2937008e7fb79fb6f6e345dab Mon Sep 17 00:00:00 2001
> From: Christoph Hellwig <hch@lst.de>
> Date: Mon, 5 Aug 2019 11:10:44 +0300
> Subject: pagewalk: clean up the API
> 
> The mm_walk structure currently mixed data and code.  Split out the
> operations vectors into a new mm_walk_ops structure, and while we
> are changing the API also declare the mm_walk structure inside the
> walk_page_range and walk_page_vma functions.
> 
> Last but not least move all the declarations to a new pagewalk.h
> header so that doesn't pollute every user of mm.h.
> 
> Based on patch from Linus Torvalds.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  arch/openrisc/kernel/dma.c              |  23 +++--
>  arch/powerpc/mm/book3s64/subpage_prot.c |  12 +--
>  arch/s390/mm/gmap.c                     |  35 ++++---
>  fs/proc/task_mmu.c                      |  76 +++++++--------
>  include/linux/mm.h                      |  46 ---------
>  include/linux/pagewalk.h                |  66 +++++++++++++
>  mm/hmm.c                                |  42 +++------
>  mm/madvise.c                            |  42 +++------
>  mm/memcontrol.c                         |  25 +++--
>  mm/mempolicy.c                          |  17 ++--
>  mm/migrate.c                            |  16 ++--
>  mm/mincore.c                            |  17 ++--
>  mm/mprotect.c                           |  26 ++---
>  mm/pagewalk.c                           | 120 ++++++++++++++----------
>  14 files changed, 284 insertions(+), 279 deletions(-)
>  create mode 100644 include/linux/pagewalk.h
> 
> diff --git a/arch/openrisc/kernel/dma.c b/arch/openrisc/kernel/dma.c
> index b41a79fcdbd9..4d5b8bd1d795 100644
> --- a/arch/openrisc/kernel/dma.c
> +++ b/arch/openrisc/kernel/dma.c
> @@ -16,6 +16,7 @@
>   */
>  
>  #include <linux/dma-noncoherent.h>
> +#include <linux/pagewalk.h>
>  
>  #include <asm/cpuinfo.h>
>  #include <asm/spr_defs.h>
> @@ -43,6 +44,10 @@ page_set_nocache(pte_t *pte, unsigned long addr,
>  	return 0;
>  }
>  
> +static const struct mm_walk_ops set_nocache_walk_ops = {
> +	.pte_entry		= page_set_nocache,
> +};
> +
>  static int
>  page_clear_nocache(pte_t *pte, unsigned long addr,
>  		   unsigned long next, struct mm_walk *walk)
> @@ -58,6 +63,10 @@ page_clear_nocache(pte_t *pte, unsigned long addr,
>  	return 0;
>  }
>  
> +static const struct mm_walk_ops clear_nocache_walk_ops = {
> +	.pte_entry		= page_clear_nocache,
> +};
> +
>  /*
>   * Alloc "coherent" memory, which for OpenRISC means simply uncached.
>   *
> @@ -80,10 +89,6 @@ arch_dma_alloc(struct device *dev, size_t size, dma_addr_t *dma_handle,
>  {
>  	unsigned long va;
>  	void *page;
> -	struct mm_walk walk = {
> -		.pte_entry = page_set_nocache,
> -		.mm = &init_mm
> -	};
>  
>  	page = alloc_pages_exact(size, gfp | __GFP_ZERO);
>  	if (!page)
> @@ -98,7 +103,8 @@ arch_dma_alloc(struct device *dev, size_t size, dma_addr_t *dma_handle,
>  	 * We need to iterate through the pages, clearing the dcache for
>  	 * them and setting the cache-inhibit bit.
>  	 */
> -	if (walk_page_range(va, va + size, &walk)) {
> +	if (walk_page_range(&init_mm, va, va + size, &set_nocache_walk_ops,
> +			NULL)) {
>  		free_pages_exact(page, size);
>  		return NULL;
>  	}
> @@ -111,13 +117,10 @@ arch_dma_free(struct device *dev, size_t size, void *vaddr,
>  		dma_addr_t dma_handle, unsigned long attrs)
>  {
>  	unsigned long va = (unsigned long)vaddr;
> -	struct mm_walk walk = {
> -		.pte_entry = page_clear_nocache,
> -		.mm = &init_mm
> -	};
>  
>  	/* walk_page_range shouldn't be able to fail here */
> -	WARN_ON(walk_page_range(va, va + size, &walk));
> +	WARN_ON(walk_page_range(&init_mm, va, va + size,
> +			&clear_nocache_walk_ops, NULL));
>  
>  	free_pages_exact(vaddr, size);
>  }
> diff --git a/arch/powerpc/mm/book3s64/subpage_prot.c b/arch/powerpc/mm/book3s64/subpage_prot.c
> index 9ba07e55c489..2ef24a53f4c9 100644
> --- a/arch/powerpc/mm/book3s64/subpage_prot.c
> +++ b/arch/powerpc/mm/book3s64/subpage_prot.c
> @@ -7,7 +7,7 @@
>  #include <linux/kernel.h>
>  #include <linux/gfp.h>
>  #include <linux/types.h>
> -#include <linux/mm.h>
> +#include <linux/pagewalk.h>
>  #include <linux/hugetlb.h>
>  #include <linux/syscalls.h>
>  
> @@ -139,14 +139,14 @@ static int subpage_walk_pmd_entry(pmd_t *pmd, unsigned long addr,
>  	return 0;
>  }
>  
> +static const struct mm_walk_ops subpage_walk_ops = {
> +	.pmd_entry	= subpage_walk_pmd_entry,
> +};
> +
>  static void subpage_mark_vma_nohuge(struct mm_struct *mm, unsigned long addr,
>  				    unsigned long len)
>  {
>  	struct vm_area_struct *vma;
> -	struct mm_walk subpage_proto_walk = {
> -		.mm = mm,
> -		.pmd_entry = subpage_walk_pmd_entry,
> -	};
>  
>  	/*
>  	 * We don't try too hard, we just mark all the vma in that range
> @@ -163,7 +163,7 @@ static void subpage_mark_vma_nohuge(struct mm_struct *mm, unsigned long addr,
>  		if (vma->vm_start >= (addr + len))
>  			break;
>  		vma->vm_flags |= VM_NOHUGEPAGE;
> -		walk_page_vma(vma, &subpage_proto_walk);
> +		walk_page_vma(vma, &subpage_walk_ops, NULL);
>  		vma = vma->vm_next;
>  	}
>  }
> diff --git a/arch/s390/mm/gmap.c b/arch/s390/mm/gmap.c
> index 39c3a6e3d262..bd78d504fdad 100644
> --- a/arch/s390/mm/gmap.c
> +++ b/arch/s390/mm/gmap.c
> @@ -9,7 +9,7 @@
>   */
>  
>  #include <linux/kernel.h>
> -#include <linux/mm.h>
> +#include <linux/pagewalk.h>
>  #include <linux/swap.h>
>  #include <linux/smp.h>
>  #include <linux/spinlock.h>
> @@ -2521,13 +2521,9 @@ static int __zap_zero_pages(pmd_t *pmd, unsigned long start,
>  	return 0;
>  }
>  
> -static inline void zap_zero_pages(struct mm_struct *mm)
> -{
> -	struct mm_walk walk = { .pmd_entry = __zap_zero_pages };
> -
> -	walk.mm = mm;
> -	walk_page_range(0, TASK_SIZE, &walk);
> -}
> +static const struct mm_walk_ops zap_zero_walk_ops = {
> +	.pmd_entry	= __zap_zero_pages,
> +};
>  
>  /*
>   * switch on pgstes for its userspace process (for kvm)
> @@ -2546,7 +2542,7 @@ int s390_enable_sie(void)
>  	mm->context.has_pgste = 1;
>  	/* split thp mappings and disable thp for future mappings */
>  	thp_split_mm(mm);
> -	zap_zero_pages(mm);
> +	walk_page_range(mm, 0, TASK_SIZE, &zap_zero_walk_ops, NULL);
>  	up_write(&mm->mmap_sem);
>  	return 0;
>  }
> @@ -2589,12 +2585,13 @@ static int __s390_enable_skey_hugetlb(pte_t *pte, unsigned long addr,
>  	return 0;
>  }
>  
> +static const struct mm_walk_ops enable_skey_walk_ops = {
> +	.hugetlb_entry		= __s390_enable_skey_hugetlb,
> +	.pte_entry		= __s390_enable_skey_pte,
> +};
> +
>  int s390_enable_skey(void)
>  {
> -	struct mm_walk walk = {
> -		.hugetlb_entry = __s390_enable_skey_hugetlb,
> -		.pte_entry = __s390_enable_skey_pte,
> -	};
>  	struct mm_struct *mm = current->mm;
>  	struct vm_area_struct *vma;
>  	int rc = 0;
> @@ -2614,8 +2611,7 @@ int s390_enable_skey(void)
>  	}
>  	mm->def_flags &= ~VM_MERGEABLE;
>  
> -	walk.mm = mm;
> -	walk_page_range(0, TASK_SIZE, &walk);
> +	walk_page_range(mm, 0, TASK_SIZE, &enable_skey_walk_ops, NULL);
>  
>  out_up:
>  	up_write(&mm->mmap_sem);
> @@ -2633,13 +2629,14 @@ static int __s390_reset_cmma(pte_t *pte, unsigned long addr,
>  	return 0;
>  }
>  
> +static const struct mm_walk_ops reset_cmma_walk_ops = {
> +	.pte_entry		= __s390_reset_cmma,
> +};
> +
>  void s390_reset_cmma(struct mm_struct *mm)
>  {
> -	struct mm_walk walk = { .pte_entry = __s390_reset_cmma };
> -
>  	down_write(&mm->mmap_sem);
> -	walk.mm = mm;
> -	walk_page_range(0, TASK_SIZE, &walk);
> +	walk_page_range(mm, 0, TASK_SIZE, &reset_cmma_walk_ops, NULL);
>  	up_write(&mm->mmap_sem);
>  }
>  EXPORT_SYMBOL_GPL(s390_reset_cmma);
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 731642e0f5a0..005a98abf0a3 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -1,5 +1,5 @@
>  // SPDX-License-Identifier: GPL-2.0
> -#include <linux/mm.h>
> +#include <linux/pagewalk.h>
>  #include <linux/vmacache.h>
>  #include <linux/hugetlb.h>
>  #include <linux/huge_mm.h>
> @@ -729,21 +729,24 @@ static int smaps_hugetlb_range(pte_t *pte, unsigned long hmask,
>  	}
>  	return 0;
>  }
> +#else
> + #define smaps_hugetlb_range NULL
>  #endif /* HUGETLB_PAGE */
>  
> +static const struct mm_walk_ops smaps_walk_ops = {
> +	.pmd_entry		= smaps_pte_range,
> +	.hugetlb_entry		= smaps_hugetlb_range,
> +};
> +
> +static const struct mm_walk_ops smaps_shmem_walk_ops = {
> +	.pmd_entry		= smaps_pte_range,
> +	.hugetlb_entry		= smaps_hugetlb_range,
> +	.pte_hole		= smaps_pte_hole,
> +};
> +
>  static void smap_gather_stats(struct vm_area_struct *vma,
>  			     struct mem_size_stats *mss)
>  {
> -	struct mm_walk smaps_walk = {
> -		.pmd_entry = smaps_pte_range,
> -#ifdef CONFIG_HUGETLB_PAGE
> -		.hugetlb_entry = smaps_hugetlb_range,
> -#endif
> -		.mm = vma->vm_mm,
> -	};
> -
> -	smaps_walk.private = mss;
> -
>  #ifdef CONFIG_SHMEM
>  	/* In case of smaps_rollup, reset the value from previous vma */
>  	mss->check_shmem_swap = false;
> @@ -765,12 +768,13 @@ static void smap_gather_stats(struct vm_area_struct *vma,
>  			mss->swap += shmem_swapped;
>  		} else {
>  			mss->check_shmem_swap = true;
> -			smaps_walk.pte_hole = smaps_pte_hole;
> +			walk_page_vma(vma, &smaps_shmem_walk_ops, mss);
> +			return;
>  		}
>  	}
>  #endif
>  	/* mmap_sem is held in m_start */
> -	walk_page_vma(vma, &smaps_walk);
> +	walk_page_vma(vma, &smaps_walk_ops, mss);
>  }
>  
>  #define SEQ_PUT_DEC(str, val) \
> @@ -1118,6 +1122,11 @@ static int clear_refs_test_walk(unsigned long start, unsigned long end,
>  	return 0;
>  }
>  
> +static const struct mm_walk_ops clear_refs_walk_ops = {
> +	.pmd_entry		= clear_refs_pte_range,
> +	.test_walk		= clear_refs_test_walk,
> +};
> +
>  static ssize_t clear_refs_write(struct file *file, const char __user *buf,
>  				size_t count, loff_t *ppos)
>  {
> @@ -1151,12 +1160,6 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
>  		struct clear_refs_private cp = {
>  			.type = type,
>  		};
> -		struct mm_walk clear_refs_walk = {
> -			.pmd_entry = clear_refs_pte_range,
> -			.test_walk = clear_refs_test_walk,
> -			.mm = mm,
> -			.private = &cp,
> -		};
>  
>  		if (type == CLEAR_REFS_MM_HIWATER_RSS) {
>  			if (down_write_killable(&mm->mmap_sem)) {
> @@ -1217,7 +1220,8 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
>  						0, NULL, mm, 0, -1UL);
>  			mmu_notifier_invalidate_range_start(&range);
>  		}
> -		walk_page_range(0, mm->highest_vm_end, &clear_refs_walk);
> +		walk_page_range(mm, 0, mm->highest_vm_end, &clear_refs_walk_ops,
> +				&cp);
>  		if (type == CLEAR_REFS_SOFT_DIRTY)
>  			mmu_notifier_invalidate_range_end(&range);
>  		tlb_finish_mmu(&tlb, 0, -1);
> @@ -1489,8 +1493,16 @@ static int pagemap_hugetlb_range(pte_t *ptep, unsigned long hmask,
>  
>  	return err;
>  }
> +#else
> + #define pagemap_hugetlb_range NULL
>  #endif /* HUGETLB_PAGE */
>  
> +static const struct mm_walk_ops pagemap_ops = {
> +	.pmd_entry	= pagemap_pmd_range,
> +	.pte_hole	= pagemap_pte_hole,
> +	.hugetlb_entry	= pagemap_hugetlb_range,
> +};
> +
>  /*
>   * /proc/pid/pagemap - an array mapping virtual pages to pfns
>   *
> @@ -1522,7 +1534,6 @@ static ssize_t pagemap_read(struct file *file, char __user *buf,
>  {
>  	struct mm_struct *mm = file->private_data;
>  	struct pagemapread pm;
> -	struct mm_walk pagemap_walk = {};
>  	unsigned long src;
>  	unsigned long svpfn;
>  	unsigned long start_vaddr;
> @@ -1550,14 +1561,6 @@ static ssize_t pagemap_read(struct file *file, char __user *buf,
>  	if (!pm.buffer)
>  		goto out_mm;
>  
> -	pagemap_walk.pmd_entry = pagemap_pmd_range;
> -	pagemap_walk.pte_hole = pagemap_pte_hole;
> -#ifdef CONFIG_HUGETLB_PAGE
> -	pagemap_walk.hugetlb_entry = pagemap_hugetlb_range;
> -#endif
> -	pagemap_walk.mm = mm;
> -	pagemap_walk.private = &pm;
> -
>  	src = *ppos;
>  	svpfn = src / PM_ENTRY_BYTES;
>  	start_vaddr = svpfn << PAGE_SHIFT;
> @@ -1586,7 +1589,7 @@ static ssize_t pagemap_read(struct file *file, char __user *buf,
>  		ret = down_read_killable(&mm->mmap_sem);
>  		if (ret)
>  			goto out_free;
> -		ret = walk_page_range(start_vaddr, end, &pagemap_walk);
> +		ret = walk_page_range(mm, start_vaddr, end, &pagemap_ops, &pm);
>  		up_read(&mm->mmap_sem);
>  		start_vaddr = end;
>  
> @@ -1798,6 +1801,11 @@ static int gather_hugetlb_stats(pte_t *pte, unsigned long hmask,
>  }
>  #endif
>  
> +static const struct mm_walk_ops show_numa_ops = {
> +	.hugetlb_entry = gather_hugetlb_stats,
> +	.pmd_entry = gather_pte_stats,
> +};
> +
>  /*
>   * Display pages allocated per node and memory policy via /proc.
>   */
> @@ -1809,12 +1817,6 @@ static int show_numa_map(struct seq_file *m, void *v)
>  	struct numa_maps *md = &numa_priv->md;
>  	struct file *file = vma->vm_file;
>  	struct mm_struct *mm = vma->vm_mm;
> -	struct mm_walk walk = {
> -		.hugetlb_entry = gather_hugetlb_stats,
> -		.pmd_entry = gather_pte_stats,
> -		.private = md,
> -		.mm = mm,
> -	};
>  	struct mempolicy *pol;
>  	char buffer[64];
>  	int nid;
> @@ -1848,7 +1850,7 @@ static int show_numa_map(struct seq_file *m, void *v)
>  		seq_puts(m, " huge");
>  
>  	/* mmap_sem is held by m_start */
> -	walk_page_vma(vma, &walk);
> +	walk_page_vma(vma, &show_numa_ops, md);
>  
>  	if (!md->pages)
>  		goto out;
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 0334ca97c584..7cf955feb823 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1430,54 +1430,8 @@ void zap_page_range(struct vm_area_struct *vma, unsigned long address,
>  void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
>  		unsigned long start, unsigned long end);
>  
> -/**
> - * mm_walk - callbacks for walk_page_range
> - * @pud_entry: if set, called for each non-empty PUD (2nd-level) entry
> - *	       this handler should only handle pud_trans_huge() puds.
> - *	       the pmd_entry or pte_entry callbacks will be used for
> - *	       regular PUDs.
> - * @pmd_entry: if set, called for each non-empty PMD (3rd-level) entry
> - *	       this handler is required to be able to handle
> - *	       pmd_trans_huge() pmds.  They may simply choose to
> - *	       split_huge_page() instead of handling it explicitly.
> - * @pte_entry: if set, called for each non-empty PTE (4th-level) entry
> - * @pte_hole: if set, called for each hole at all levels
> - * @hugetlb_entry: if set, called for each hugetlb entry
> - * @test_walk: caller specific callback function to determine whether
> - *             we walk over the current vma or not. Returning 0
> - *             value means "do page table walk over the current vma,"
> - *             and a negative one means "abort current page table walk
> - *             right now." 1 means "skip the current vma."
> - * @mm:        mm_struct representing the target process of page table walk
> - * @vma:       vma currently walked (NULL if walking outside vmas)
> - * @private:   private data for callbacks' usage
> - *
> - * (see the comment on walk_page_range() for more details)
> - */
> -struct mm_walk {
> -	int (*pud_entry)(pud_t *pud, unsigned long addr,
> -			 unsigned long next, struct mm_walk *walk);
> -	int (*pmd_entry)(pmd_t *pmd, unsigned long addr,
> -			 unsigned long next, struct mm_walk *walk);
> -	int (*pte_entry)(pte_t *pte, unsigned long addr,
> -			 unsigned long next, struct mm_walk *walk);
> -	int (*pte_hole)(unsigned long addr, unsigned long next,
> -			struct mm_walk *walk);
> -	int (*hugetlb_entry)(pte_t *pte, unsigned long hmask,
> -			     unsigned long addr, unsigned long next,
> -			     struct mm_walk *walk);
> -	int (*test_walk)(unsigned long addr, unsigned long next,
> -			struct mm_walk *walk);
> -	struct mm_struct *mm;
> -	struct vm_area_struct *vma;
> -	void *private;
> -};
> -
>  struct mmu_notifier_range;
>  
> -int walk_page_range(unsigned long addr, unsigned long end,
> -		struct mm_walk *walk);
> -int walk_page_vma(struct vm_area_struct *vma, struct mm_walk *walk);
>  void free_pgd_range(struct mmu_gather *tlb, unsigned long addr,
>  		unsigned long end, unsigned long floor, unsigned long ceiling);
>  int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
> diff --git a/include/linux/pagewalk.h b/include/linux/pagewalk.h
> new file mode 100644
> index 000000000000..bddd9759bab9
> --- /dev/null
> +++ b/include/linux/pagewalk.h
> @@ -0,0 +1,66 @@
> +/* SPDX-License-Identifier: GPL-2.0 */
> +#ifndef _LINUX_PAGEWALK_H
> +#define _LINUX_PAGEWALK_H
> +
> +#include <linux/mm.h>
> +
> +struct mm_walk;
> +
> +/**
> + * mm_walk_ops - callbacks for walk_page_range
> + * @pud_entry:		if set, called for each non-empty PUD (2nd-level) entry
> + *			this handler should only handle pud_trans_huge() puds.
> + *			the pmd_entry or pte_entry callbacks will be used for
> + *			regular PUDs.
> + * @pmd_entry:		if set, called for each non-empty PMD (3rd-level) entry
> + *			this handler is required to be able to handle
> + *			pmd_trans_huge() pmds.  They may simply choose to
> + *			split_huge_page() instead of handling it explicitly.
> + * @pte_entry:		if set, called for each non-empty PTE (4th-level) entry
> + * @pte_hole:		if set, called for each hole at all levels
> + * @hugetlb_entry:	if set, called for each hugetlb entry
> + * @test_walk:		caller specific callback function to determine whether
> + *			we walk over the current vma or not. Returning 0 means
> + *			"do page table walk over the current vma", returning
> + *			a negative value means "abort current page table walk
> + *			right now" and returning 1 means "skip the current vma"
> + */
> +struct mm_walk_ops {
> +	int (*pud_entry)(pud_t *pud, unsigned long addr,
> +			 unsigned long next, struct mm_walk *walk);
> +	int (*pmd_entry)(pmd_t *pmd, unsigned long addr,
> +			 unsigned long next, struct mm_walk *walk);
> +	int (*pte_entry)(pte_t *pte, unsigned long addr,
> +			 unsigned long next, struct mm_walk *walk);
> +	int (*pte_hole)(unsigned long addr, unsigned long next,
> +			struct mm_walk *walk);
> +	int (*hugetlb_entry)(pte_t *pte, unsigned long hmask,
> +			     unsigned long addr, unsigned long next,
> +			     struct mm_walk *walk);
> +	int (*test_walk)(unsigned long addr, unsigned long next,
> +			struct mm_walk *walk);
> +};
> +
> +/**
> + * mm_walk - walk_page_range data
> + * @ops:	operation to call during the walk
> + * @mm:		mm_struct representing the target process of page table walk
> + * @vma:	vma currently walked (NULL if walking outside vmas)
> + * @private:	private data for callbacks' usage
> + *
> + * (see the comment on walk_page_range() for more details)
> + */
> +struct mm_walk {
> +	const struct mm_walk_ops *ops;
> +	struct mm_struct *mm;
> +	struct vm_area_struct *vma;
> +	void *private;
> +};
> +
> +int walk_page_range(struct mm_struct *mm, unsigned long start,
> +		unsigned long end, const struct mm_walk_ops *ops,
> +		void *private);
> +int walk_page_vma(struct vm_area_struct *vma, const struct mm_walk_ops *ops,
> +		void *private);
> +
> +#endif /* _LINUX_PAGEWALK_H */
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 16b6731a34db..37933f886dbe 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -8,7 +8,7 @@
>   * Refer to include/linux/hmm.h for information about heterogeneous memory
>   * management or HMM for short.
>   */
> -#include <linux/mm.h>
> +#include <linux/pagewalk.h>
>  #include <linux/hmm.h>
>  #include <linux/init.h>
>  #include <linux/rmap.h>
> @@ -941,6 +941,13 @@ void hmm_range_unregister(struct hmm_range *range)
>  }
>  EXPORT_SYMBOL(hmm_range_unregister);
>  
> +static const struct mm_walk_ops hmm_walk_ops = {
> +	.pud_entry	= hmm_vma_walk_pud,
> +	.pmd_entry	= hmm_vma_walk_pmd,
> +	.pte_hole	= hmm_vma_walk_hole,
> +	.hugetlb_entry	= hmm_vma_walk_hugetlb_entry,
> +};
> +
>  /*
>   * hmm_range_snapshot() - snapshot CPU page table for a range
>   * @range: range
> @@ -961,7 +968,6 @@ long hmm_range_snapshot(struct hmm_range *range)
>  	struct hmm_vma_walk hmm_vma_walk;
>  	struct hmm *hmm = range->hmm;
>  	struct vm_area_struct *vma;
> -	struct mm_walk mm_walk;
>  
>  	lockdep_assert_held(&hmm->mm->mmap_sem);
>  	do {
> @@ -999,20 +1005,10 @@ long hmm_range_snapshot(struct hmm_range *range)
>  		hmm_vma_walk.last = start;
>  		hmm_vma_walk.fault = false;
>  		hmm_vma_walk.range = range;
> -		mm_walk.private = &hmm_vma_walk;
> -		end = min(range->end, vma->vm_end);
>  
> -		mm_walk.vma = vma;
> -		mm_walk.mm = vma->vm_mm;
> -		mm_walk.pte_entry = NULL;
> -		mm_walk.test_walk = NULL;
> -		mm_walk.hugetlb_entry = NULL;
> -		mm_walk.pud_entry = hmm_vma_walk_pud;
> -		mm_walk.pmd_entry = hmm_vma_walk_pmd;
> -		mm_walk.pte_hole = hmm_vma_walk_hole;
> -		mm_walk.hugetlb_entry = hmm_vma_walk_hugetlb_entry;
> -
> -		walk_page_range(start, end, &mm_walk);
> +		end = min(range->end, vma->vm_end);
> +		walk_page_range(vma->vm_mm, start, end, &hmm_walk_ops,
> +				&hmm_vma_walk);
>  		start = end;
>  	} while (start < range->end);
>  
> @@ -1055,7 +1051,6 @@ long hmm_range_fault(struct hmm_range *range, bool block)
>  	struct hmm_vma_walk hmm_vma_walk;
>  	struct hmm *hmm = range->hmm;
>  	struct vm_area_struct *vma;
> -	struct mm_walk mm_walk;
>  	int ret;
>  
>  	lockdep_assert_held(&hmm->mm->mmap_sem);
> @@ -1096,21 +1091,14 @@ long hmm_range_fault(struct hmm_range *range, bool block)
>  		hmm_vma_walk.fault = true;
>  		hmm_vma_walk.block = block;
>  		hmm_vma_walk.range = range;
> -		mm_walk.private = &hmm_vma_walk;
>  		end = min(range->end, vma->vm_end);
>  
> -		mm_walk.vma = vma;
> -		mm_walk.mm = vma->vm_mm;
> -		mm_walk.pte_entry = NULL;
> -		mm_walk.test_walk = NULL;
> -		mm_walk.hugetlb_entry = NULL;
> -		mm_walk.pud_entry = hmm_vma_walk_pud;
> -		mm_walk.pmd_entry = hmm_vma_walk_pmd;
> -		mm_walk.pte_hole = hmm_vma_walk_hole;
> -		mm_walk.hugetlb_entry = hmm_vma_walk_hugetlb_entry;
> +		walk_page_range(vma->vm_mm, start, end, &hmm_walk_ops,
> +				&hmm_vma_walk);
>  
>  		do {
> -			ret = walk_page_range(start, end, &mm_walk);
> +			ret = walk_page_range(vma->vm_mm, start, end,
> +					&hmm_walk_ops, &hmm_vma_walk);
>  			start = hmm_vma_walk.last;
>  
>  			/* Keep trying while the range is valid. */
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 968df3aa069f..afe2b015ea58 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -20,6 +20,7 @@
>  #include <linux/file.h>
>  #include <linux/blkdev.h>
>  #include <linux/backing-dev.h>
> +#include <linux/pagewalk.h>
>  #include <linux/swap.h>
>  #include <linux/swapops.h>
>  #include <linux/shmem_fs.h>
> @@ -225,19 +226,9 @@ static int swapin_walk_pmd_entry(pmd_t *pmd, unsigned long start,
>  	return 0;
>  }
>  
> -static void force_swapin_readahead(struct vm_area_struct *vma,
> -		unsigned long start, unsigned long end)
> -{
> -	struct mm_walk walk = {
> -		.mm = vma->vm_mm,
> -		.pmd_entry = swapin_walk_pmd_entry,
> -		.private = vma,
> -	};
> -
> -	walk_page_range(start, end, &walk);
> -
> -	lru_add_drain();	/* Push any new pages onto the LRU now */
> -}
> +static const struct mm_walk_ops swapin_walk_ops = {
> +	.pmd_entry		= swapin_walk_pmd_entry,
> +};
>  
>  static void force_shm_swapin_readahead(struct vm_area_struct *vma,
>  		unsigned long start, unsigned long end,
> @@ -279,7 +270,8 @@ static long madvise_willneed(struct vm_area_struct *vma,
>  	*prev = vma;
>  #ifdef CONFIG_SWAP
>  	if (!file) {
> -		force_swapin_readahead(vma, start, end);
> +		walk_page_range(vma->vm_mm, start, end, &swapin_walk_ops, vma);
> +		lru_add_drain(); /* Push any new pages onto the LRU now */
>  		return 0;
>  	}
>  
> @@ -440,20 +432,9 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
>  	return 0;
>  }
>  
> -static void madvise_free_page_range(struct mmu_gather *tlb,
> -			     struct vm_area_struct *vma,
> -			     unsigned long addr, unsigned long end)
> -{
> -	struct mm_walk free_walk = {
> -		.pmd_entry = madvise_free_pte_range,
> -		.mm = vma->vm_mm,
> -		.private = tlb,
> -	};
> -
> -	tlb_start_vma(tlb, vma);
> -	walk_page_range(addr, end, &free_walk);
> -	tlb_end_vma(tlb, vma);
> -}
> +static const struct mm_walk_ops madvise_free_walk_ops = {
> +	.pmd_entry		= madvise_free_pte_range,
> +};
>  
>  static int madvise_free_single_vma(struct vm_area_struct *vma,
>  			unsigned long start_addr, unsigned long end_addr)
> @@ -480,7 +461,10 @@ static int madvise_free_single_vma(struct vm_area_struct *vma,
>  	update_hiwater_rss(mm);
>  
>  	mmu_notifier_invalidate_range_start(&range);
> -	madvise_free_page_range(&tlb, vma, range.start, range.end);
> +	tlb_start_vma(&tlb, vma);
> +	walk_page_range(vma->vm_mm, range.start, range.end,
> +			&madvise_free_walk_ops, &tlb);
> +	tlb_end_vma(&tlb, vma);
>  	mmu_notifier_invalidate_range_end(&range);
>  	tlb_finish_mmu(&tlb, range.start, range.end);
>  
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index cdbb7a84cb6e..5d159f9391ff 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -25,7 +25,7 @@
>  #include <linux/page_counter.h>
>  #include <linux/memcontrol.h>
>  #include <linux/cgroup.h>
> -#include <linux/mm.h>
> +#include <linux/pagewalk.h>
>  #include <linux/sched/mm.h>
>  #include <linux/shmem_fs.h>
>  #include <linux/hugetlb.h>
> @@ -5244,17 +5244,16 @@ static int mem_cgroup_count_precharge_pte_range(pmd_t *pmd,
>  	return 0;
>  }
>  
> +static const struct mm_walk_ops precharge_walk_ops = {
> +	.pmd_entry	= mem_cgroup_count_precharge_pte_range,
> +};
> +
>  static unsigned long mem_cgroup_count_precharge(struct mm_struct *mm)
>  {
>  	unsigned long precharge;
>  
> -	struct mm_walk mem_cgroup_count_precharge_walk = {
> -		.pmd_entry = mem_cgroup_count_precharge_pte_range,
> -		.mm = mm,
> -	};
>  	down_read(&mm->mmap_sem);
> -	walk_page_range(0, mm->highest_vm_end,
> -			&mem_cgroup_count_precharge_walk);
> +	walk_page_range(mm, 0, mm->highest_vm_end, &precharge_walk_ops, NULL);
>  	up_read(&mm->mmap_sem);
>  
>  	precharge = mc.precharge;
> @@ -5523,13 +5522,12 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
>  	return ret;
>  }
>  
> +static const struct mm_walk_ops charge_walk_ops = {
> +	.pmd_entry	= mem_cgroup_move_charge_pte_range,
> +};
> +
>  static void mem_cgroup_move_charge(void)
>  {
> -	struct mm_walk mem_cgroup_move_charge_walk = {
> -		.pmd_entry = mem_cgroup_move_charge_pte_range,
> -		.mm = mc.mm,
> -	};
> -
>  	lru_add_drain_all();
>  	/*
>  	 * Signal lock_page_memcg() to take the memcg's move_lock
> @@ -5555,7 +5553,8 @@ static void mem_cgroup_move_charge(void)
>  	 * When we have consumed all precharges and failed in doing
>  	 * additional charge, the page walk just aborts.
>  	 */
> -	walk_page_range(0, mc.mm->highest_vm_end, &mem_cgroup_move_charge_walk);
> +	walk_page_range(mc.mm, 0, mc.mm->highest_vm_end, &charge_walk_ops,
> +			NULL);
>  
>  	up_read(&mc.mm->mmap_sem);
>  	atomic_dec(&mc.from->moving_account);
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index f48693f75b37..6712bceae213 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -68,7 +68,7 @@
>  #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
>  
>  #include <linux/mempolicy.h>
> -#include <linux/mm.h>
> +#include <linux/pagewalk.h>
>  #include <linux/highmem.h>
>  #include <linux/hugetlb.h>
>  #include <linux/kernel.h>
> @@ -634,6 +634,12 @@ static int queue_pages_test_walk(unsigned long start, unsigned long end,
>  	return 1;
>  }
>  
> +static const struct mm_walk_ops queue_pages_walk_ops = {
> +	.hugetlb_entry		= queue_pages_hugetlb,
> +	.pmd_entry		= queue_pages_pte_range,
> +	.test_walk		= queue_pages_test_walk,
> +};
> +
>  /*
>   * Walk through page tables and collect pages to be migrated.
>   *
> @@ -652,15 +658,8 @@ queue_pages_range(struct mm_struct *mm, unsigned long start, unsigned long end,
>  		.nmask = nodes,
>  		.prev = NULL,
>  	};
> -	struct mm_walk queue_pages_walk = {
> -		.hugetlb_entry = queue_pages_hugetlb,
> -		.pmd_entry = queue_pages_pte_range,
> -		.test_walk = queue_pages_test_walk,
> -		.mm = mm,
> -		.private = &qp,
> -	};
>  
> -	return walk_page_range(start, end, &queue_pages_walk);
> +	return walk_page_range(mm, start, end, &queue_pages_walk_ops, &qp);
>  }
>  
>  /*
> diff --git a/mm/migrate.c b/mm/migrate.c
> index a42858d8e00b..75de4378dfcd 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -38,6 +38,7 @@
>  #include <linux/hugetlb.h>
>  #include <linux/hugetlb_cgroup.h>
>  #include <linux/gfp.h>
> +#include <linux/pagewalk.h>
>  #include <linux/pfn_t.h>
>  #include <linux/memremap.h>
>  #include <linux/userfaultfd_k.h>
> @@ -2329,6 +2330,11 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
>  	return 0;
>  }
>  
> +static const struct mm_walk_ops migrate_vma_walk_ops = {
> +	.pmd_entry		= migrate_vma_collect_pmd,
> +	.pte_hole		= migrate_vma_collect_hole,
> +};
> +
>  /*
>   * migrate_vma_collect() - collect pages over a range of virtual addresses
>   * @migrate: migrate struct containing all migration information
> @@ -2340,19 +2346,13 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
>  static void migrate_vma_collect(struct migrate_vma *migrate)
>  {
>  	struct mmu_notifier_range range;
> -	struct mm_walk mm_walk = {
> -		.pmd_entry = migrate_vma_collect_pmd,
> -		.pte_hole = migrate_vma_collect_hole,
> -		.vma = migrate->vma,
> -		.mm = migrate->vma->vm_mm,
> -		.private = migrate,
> -	};
>  
>  	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, 0, NULL, mm_walk.mm,
>  				migrate->start,
>  				migrate->end);
>  	mmu_notifier_invalidate_range_start(&range);
> -	walk_page_range(migrate->start, migrate->end, &mm_walk);
> +	walk_page_range(migrate->vma->vm_mm, migrate->start, migrate->end,
> +			&migrate_vma_walk_ops, migrate);
>  	mmu_notifier_invalidate_range_end(&range);
>  
>  	migrate->end = migrate->start + (migrate->npages << PAGE_SHIFT);
> diff --git a/mm/mincore.c b/mm/mincore.c
> index 4fe91d497436..f9a9dbe8cd33 100644
> --- a/mm/mincore.c
> +++ b/mm/mincore.c
> @@ -10,7 +10,7 @@
>   */
>  #include <linux/pagemap.h>
>  #include <linux/gfp.h>
> -#include <linux/mm.h>
> +#include <linux/pagewalk.h>
>  #include <linux/mman.h>
>  #include <linux/syscalls.h>
>  #include <linux/swap.h>
> @@ -193,6 +193,12 @@ static inline bool can_do_mincore(struct vm_area_struct *vma)
>  		inode_permission(file_inode(vma->vm_file), MAY_WRITE) == 0;
>  }
>  
> +static const struct mm_walk_ops mincore_walk_ops = {
> +	.pmd_entry		= mincore_pte_range,
> +	.pte_hole		= mincore_unmapped_range,
> +	.hugetlb_entry		= mincore_hugetlb,
> +};
> +
>  /*
>   * Do a chunk of "sys_mincore()". We've already checked
>   * all the arguments, we hold the mmap semaphore: we should
> @@ -203,12 +209,6 @@ static long do_mincore(unsigned long addr, unsigned long pages, unsigned char *v
>  	struct vm_area_struct *vma;
>  	unsigned long end;
>  	int err;
> -	struct mm_walk mincore_walk = {
> -		.pmd_entry = mincore_pte_range,
> -		.pte_hole = mincore_unmapped_range,
> -		.hugetlb_entry = mincore_hugetlb,
> -		.private = vec,
> -	};
>  
>  	vma = find_vma(current->mm, addr);
>  	if (!vma || addr < vma->vm_start)
> @@ -219,8 +219,7 @@ static long do_mincore(unsigned long addr, unsigned long pages, unsigned char *v
>  		memset(vec, 1, pages);
>  		return pages;
>  	}
> -	mincore_walk.mm = vma->vm_mm;
> -	err = walk_page_range(addr, end, &mincore_walk);
> +	err = walk_page_range(vma->vm_mm, addr, end, &mincore_walk_ops, vec);
>  	if (err < 0)
>  		return err;
>  	return (end - addr) >> PAGE_SHIFT;
> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index bf38dfbbb4b4..675e5d34a507 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -9,7 +9,7 @@
>   *  (C) Copyright 2002 Red Hat Inc, All Rights Reserved
>   */
>  
> -#include <linux/mm.h>
> +#include <linux/pagewalk.h>
>  #include <linux/hugetlb.h>
>  #include <linux/shm.h>
>  #include <linux/mman.h>
> @@ -329,20 +329,11 @@ static int prot_none_test(unsigned long addr, unsigned long next,
>  	return 0;
>  }
>  
> -static int prot_none_walk(struct vm_area_struct *vma, unsigned long start,
> -			   unsigned long end, unsigned long newflags)
> -{
> -	pgprot_t new_pgprot = vm_get_page_prot(newflags);
> -	struct mm_walk prot_none_walk = {
> -		.pte_entry = prot_none_pte_entry,
> -		.hugetlb_entry = prot_none_hugetlb_entry,
> -		.test_walk = prot_none_test,
> -		.mm = current->mm,
> -		.private = &new_pgprot,
> -	};
> -
> -	return walk_page_range(start, end, &prot_none_walk);
> -}
> +static const struct mm_walk_ops prot_none_walk_ops = {
> +	.pte_entry		= prot_none_pte_entry,
> +	.hugetlb_entry		= prot_none_hugetlb_entry,
> +	.test_walk		= prot_none_test,
> +};
>  
>  int
>  mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
> @@ -369,7 +360,10 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
>  	if (arch_has_pfn_modify_check() &&
>  	    (vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP)) &&
>  	    (newflags & (VM_READ|VM_WRITE|VM_EXEC)) == 0) {
> -		error = prot_none_walk(vma, start, end, newflags);
> +		pgprot_t new_pgprot = vm_get_page_prot(newflags);
> +
> +		error = walk_page_range(current->mm, start, end,
> +				&prot_none_walk_ops, &new_pgprot);
>  		if (error)
>  			return error;
>  	}
> diff --git a/mm/pagewalk.c b/mm/pagewalk.c
> index c3084ff2569d..0fc0733b94cf 100644
> --- a/mm/pagewalk.c
> +++ b/mm/pagewalk.c
> @@ -1,5 +1,5 @@
>  // SPDX-License-Identifier: GPL-2.0
> -#include <linux/mm.h>
> +#include <linux/pagewalk.h>
>  #include <linux/highmem.h>
>  #include <linux/sched.h>
>  #include <linux/hugetlb.h>
> @@ -9,10 +9,11 @@ static int walk_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
>  {
>  	pte_t *pte;
>  	int err = 0;
> +	const struct mm_walk_ops *ops = walk->ops;
>  
>  	pte = pte_offset_map(pmd, addr);
>  	for (;;) {
> -		err = walk->pte_entry(pte, addr, addr + PAGE_SIZE, walk);
> +		err = ops->pte_entry(pte, addr, addr + PAGE_SIZE, walk);
>  		if (err)
>  		       break;
>  		addr += PAGE_SIZE;
> @@ -30,6 +31,7 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
>  {
>  	pmd_t *pmd;
>  	unsigned long next;
> +	const struct mm_walk_ops *ops = walk->ops;
>  	int err = 0;
>  
>  	pmd = pmd_offset(pud, addr);
> @@ -37,8 +39,8 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
>  again:
>  		next = pmd_addr_end(addr, end);
>  		if (pmd_none(*pmd) || !walk->vma) {
> -			if (walk->pte_hole)
> -				err = walk->pte_hole(addr, next, walk);
> +			if (ops->pte_hole)
> +				err = ops->pte_hole(addr, next, walk);
>  			if (err)
>  				break;
>  			continue;
> @@ -47,8 +49,8 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
>  		 * This implies that each ->pmd_entry() handler
>  		 * needs to know about pmd_trans_huge() pmds
>  		 */
> -		if (walk->pmd_entry)
> -			err = walk->pmd_entry(pmd, addr, next, walk);
> +		if (ops->pmd_entry)
> +			err = ops->pmd_entry(pmd, addr, next, walk);
>  		if (err)
>  			break;
>  
> @@ -56,7 +58,7 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
>  		 * Check this here so we only break down trans_huge
>  		 * pages when we _need_ to
>  		 */
> -		if (!walk->pte_entry)
> +		if (!ops->pte_entry)
>  			continue;
>  
>  		split_huge_pmd(walk->vma, pmd, addr);
> @@ -75,6 +77,7 @@ static int walk_pud_range(p4d_t *p4d, unsigned long addr, unsigned long end,
>  {
>  	pud_t *pud;
>  	unsigned long next;
> +	const struct mm_walk_ops *ops = walk->ops;
>  	int err = 0;
>  
>  	pud = pud_offset(p4d, addr);
> @@ -82,18 +85,18 @@ static int walk_pud_range(p4d_t *p4d, unsigned long addr, unsigned long end,
>   again:
>  		next = pud_addr_end(addr, end);
>  		if (pud_none(*pud) || !walk->vma) {
> -			if (walk->pte_hole)
> -				err = walk->pte_hole(addr, next, walk);
> +			if (ops->pte_hole)
> +				err = ops->pte_hole(addr, next, walk);
>  			if (err)
>  				break;
>  			continue;
>  		}
>  
> -		if (walk->pud_entry) {
> +		if (ops->pud_entry) {
>  			spinlock_t *ptl = pud_trans_huge_lock(pud, walk->vma);
>  
>  			if (ptl) {
> -				err = walk->pud_entry(pud, addr, next, walk);
> +				err = ops->pud_entry(pud, addr, next, walk);
>  				spin_unlock(ptl);
>  				if (err)
>  					break;
> @@ -105,7 +108,7 @@ static int walk_pud_range(p4d_t *p4d, unsigned long addr, unsigned long end,
>  		if (pud_none(*pud))
>  			goto again;
>  
> -		if (walk->pmd_entry || walk->pte_entry)
> +		if (ops->pmd_entry || ops->pte_entry)
>  			err = walk_pmd_range(pud, addr, next, walk);
>  		if (err)
>  			break;
> @@ -119,19 +122,20 @@ static int walk_p4d_range(pgd_t *pgd, unsigned long addr, unsigned long end,
>  {
>  	p4d_t *p4d;
>  	unsigned long next;
> +	const struct mm_walk_ops *ops = walk->ops;
>  	int err = 0;
>  
>  	p4d = p4d_offset(pgd, addr);
>  	do {
>  		next = p4d_addr_end(addr, end);
>  		if (p4d_none_or_clear_bad(p4d)) {
> -			if (walk->pte_hole)
> -				err = walk->pte_hole(addr, next, walk);
> +			if (ops->pte_hole)
> +				err = ops->pte_hole(addr, next, walk);
>  			if (err)
>  				break;
>  			continue;
>  		}
> -		if (walk->pmd_entry || walk->pte_entry)
> +		if (ops->pmd_entry || ops->pte_entry)
>  			err = walk_pud_range(p4d, addr, next, walk);
>  		if (err)
>  			break;
> @@ -145,19 +149,20 @@ static int walk_pgd_range(unsigned long addr, unsigned long end,
>  {
>  	pgd_t *pgd;
>  	unsigned long next;
> +	const struct mm_walk_ops *ops = walk->ops;
>  	int err = 0;
>  
>  	pgd = pgd_offset(walk->mm, addr);
>  	do {
>  		next = pgd_addr_end(addr, end);
>  		if (pgd_none_or_clear_bad(pgd)) {
> -			if (walk->pte_hole)
> -				err = walk->pte_hole(addr, next, walk);
> +			if (ops->pte_hole)
> +				err = ops->pte_hole(addr, next, walk);
>  			if (err)
>  				break;
>  			continue;
>  		}
> -		if (walk->pmd_entry || walk->pte_entry)
> +		if (ops->pmd_entry || ops->pte_entry)
>  			err = walk_p4d_range(pgd, addr, next, walk);
>  		if (err)
>  			break;
> @@ -183,6 +188,7 @@ static int walk_hugetlb_range(unsigned long addr, unsigned long end,
>  	unsigned long hmask = huge_page_mask(h);
>  	unsigned long sz = huge_page_size(h);
>  	pte_t *pte;
> +	const struct mm_walk_ops *ops = walk->ops;
>  	int err = 0;
>  
>  	do {
> @@ -190,9 +196,9 @@ static int walk_hugetlb_range(unsigned long addr, unsigned long end,
>  		pte = huge_pte_offset(walk->mm, addr & hmask, sz);
>  
>  		if (pte)
> -			err = walk->hugetlb_entry(pte, hmask, addr, next, walk);
> -		else if (walk->pte_hole)
> -			err = walk->pte_hole(addr, next, walk);
> +			err = ops->hugetlb_entry(pte, hmask, addr, next, walk);
> +		else if (ops->pte_hole)
> +			err = ops->pte_hole(addr, next, walk);
>  
>  		if (err)
>  			break;
> @@ -220,9 +226,10 @@ static int walk_page_test(unsigned long start, unsigned long end,
>  			struct mm_walk *walk)
>  {
>  	struct vm_area_struct *vma = walk->vma;
> +	const struct mm_walk_ops *ops = walk->ops;
>  
> -	if (walk->test_walk)
> -		return walk->test_walk(start, end, walk);
> +	if (ops->test_walk)
> +		return ops->test_walk(start, end, walk);
>  
>  	/*
>  	 * vma(VM_PFNMAP) doesn't have any valid struct pages behind VM_PFNMAP
> @@ -234,8 +241,8 @@ static int walk_page_test(unsigned long start, unsigned long end,
>  	 */
>  	if (vma->vm_flags & VM_PFNMAP) {
>  		int err = 1;
> -		if (walk->pte_hole)
> -			err = walk->pte_hole(start, end, walk);
> +		if (ops->pte_hole)
> +			err = ops->pte_hole(start, end, walk);
>  		return err ? err : 1;
>  	}
>  	return 0;
> @@ -248,7 +255,8 @@ static int __walk_page_range(unsigned long start, unsigned long end,
>  	struct vm_area_struct *vma = walk->vma;
>  
>  	if (vma && is_vm_hugetlb_page(vma)) {
> -		if (walk->hugetlb_entry)
> +		const struct mm_walk_ops *ops = walk->ops;
> +		if (ops->hugetlb_entry)
>  			err = walk_hugetlb_range(start, end, walk);
>  	} else
>  		err = walk_pgd_range(start, end, walk);
> @@ -258,11 +266,13 @@ static int __walk_page_range(unsigned long start, unsigned long end,
>  
>  /**
>   * walk_page_range - walk page table with caller specific callbacks
> - * @start: start address of the virtual address range
> - * @end: end address of the virtual address range
> - * @walk: mm_walk structure defining the callbacks and the target address space
> + * @mm:		mm_struct representing the target process of page table walk
> + * @start:	start address of the virtual address range
> + * @end:	end address of the virtual address range
> + * @ops:	operation to call during the walk
> + * @private:	private data for callbacks' usage
>   *
> - * Recursively walk the page table tree of the process represented by @walk->mm
> + * Recursively walk the page table tree of the process represented by @mm
>   * within the virtual address range [@start, @end). During walking, we can do
>   * some caller-specific works for each entry, by setting up pmd_entry(),
>   * pte_entry(), and/or hugetlb_entry(). If you don't set up for some of these
> @@ -283,42 +293,48 @@ static int __walk_page_range(unsigned long start, unsigned long end,
>   *
>   * struct mm_walk keeps current values of some common data like vma and pmd,
>   * which are useful for the access from callbacks. If you want to pass some
> - * caller-specific data to callbacks, @walk->private should be helpful.
> + * caller-specific data to callbacks, @private should be helpful.
>   *
>   * Locking:
>   *   Callers of walk_page_range() and walk_page_vma() should hold
>   *   @walk->mm->mmap_sem, because these function traverse vma list and/or
>   *   access to vma's data.
>   */
> -int walk_page_range(unsigned long start, unsigned long end,
> -		    struct mm_walk *walk)
> +int walk_page_range(struct mm_struct *mm, unsigned long start,
> +		unsigned long end, const struct mm_walk_ops *ops,
> +		void *private)
>  {
>  	int err = 0;
>  	unsigned long next;
>  	struct vm_area_struct *vma;
> +	struct mm_walk walk = {
> +		.ops		= ops,
> +		.mm		= mm,
> +		.private	= private,
> +	};
>  
>  	if (start >= end)
>  		return -EINVAL;
>  
> -	if (!walk->mm)
> +	if (!walk.mm)
>  		return -EINVAL;
>  
> -	VM_BUG_ON_MM(!rwsem_is_locked(&walk->mm->mmap_sem), walk->mm);
> +	VM_BUG_ON_MM(!rwsem_is_locked(&walk.mm->mmap_sem), walk.mm);
>  
> -	vma = find_vma(walk->mm, start);
> +	vma = find_vma(walk.mm, start);
>  	do {
>  		if (!vma) { /* after the last vma */
> -			walk->vma = NULL;
> +			walk.vma = NULL;
>  			next = end;
>  		} else if (start < vma->vm_start) { /* outside vma */
> -			walk->vma = NULL;
> +			walk.vma = NULL;
>  			next = min(end, vma->vm_start);
>  		} else { /* inside vma */
> -			walk->vma = vma;
> +			walk.vma = vma;
>  			next = min(end, vma->vm_end);
>  			vma = vma->vm_next;
>  
> -			err = walk_page_test(start, next, walk);
> +			err = walk_page_test(start, next, &walk);
>  			if (err > 0) {
>  				/*
>  				 * positive return values are purely for
> @@ -331,28 +347,32 @@ int walk_page_range(unsigned long start, unsigned long end,
>  			if (err < 0)
>  				break;
>  		}
> -		if (walk->vma || walk->pte_hole)
> -			err = __walk_page_range(start, next, walk);
> +		if (walk.vma || walk.ops->pte_hole)
> +			err = __walk_page_range(start, next, &walk);
>  		if (err)
>  			break;
>  	} while (start = next, start < end);
>  	return err;
>  }
>  
> -int walk_page_vma(struct vm_area_struct *vma, struct mm_walk *walk)
> +int walk_page_vma(struct vm_area_struct *vma, const struct mm_walk_ops *ops,
> +		void *private)
>  {
> +	struct mm_walk walk = {
> +		.ops		= ops,
> +		.mm		= vma->vm_mm,
> +		.vma		= vma,
> +		.private	= private,
> +	};
>  	int err;
>  
> -	if (!walk->mm)
> -		return -EINVAL;
> -
> -	VM_BUG_ON(!rwsem_is_locked(&walk->mm->mmap_sem));
>  	VM_BUG_ON(!vma);
> -	walk->vma = vma;
> -	err = walk_page_test(vma->vm_start, vma->vm_end, walk);
> +	VM_BUG_ON(!rwsem_is_locked(&vma->vm_mm->mmap_sem));
> +
> +	err = walk_page_test(vma->vm_start, vma->vm_end, &walk);
>  	if (err > 0)
>  		return 0;
>  	if (err < 0)
>  		return err;
> -	return __walk_page_range(vma->vm_start, vma->vm_end, walk);
> +	return __walk_page_range(vma->vm_start, vma->vm_end, &walk);
>  }
> -- 
> 2.20.1
> 
---end quoted text---

