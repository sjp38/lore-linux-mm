Return-Path: <SRS0=CHX8=XL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92673C49ED7
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 09:16:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5179620650
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 09:16:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="yNH4GN7L"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5179620650
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E2BF96B0005; Mon, 16 Sep 2019 05:16:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DDD396B0006; Mon, 16 Sep 2019 05:16:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CCB786B0007; Mon, 16 Sep 2019 05:16:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0051.hostedemail.com [216.40.44.51])
	by kanga.kvack.org (Postfix) with ESMTP id AD9516B0005
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 05:16:29 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 43F6F180AD802
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 09:16:29 +0000 (UTC)
X-FDA: 75940228098.03.loaf97_388ed5499f551
X-HE-Tag: loaf97_388ed5499f551
X-Filterd-Recvd-Size: 8146
Received: from mail-ed1-f66.google.com (mail-ed1-f66.google.com [209.85.208.66])
	by imf14.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 09:16:28 +0000 (UTC)
Received: by mail-ed1-f66.google.com with SMTP id p2so31189299edx.11
        for <linux-mm@kvack.org>; Mon, 16 Sep 2019 02:16:28 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=vBZCS9nU1fSH+kmSCYigm2Yq8YU/srN9xKPMLdxx9uA=;
        b=yNH4GN7LaJOP3yS9aV4fF11ma1PFEb7h83O4Jf9wGnCAwQ3sIB0HjqygkTPkLbIX4i
         fpzZFr9Ng8cKCy3x990mhweiHyLCASKWNlnkwpho9OSGlLFttD271s7WNCgaDENT5il7
         6LScrSQDK35mJXcuHW16ivhg6hD9hRDBcPp0a4CIxMBbCnau5Ijn3LRBS7HJ5NxH96Xm
         T9cm3x8hG9/hCBdsRQ4+RiD1j1PDzIzWfU5wGcU0clDw5lAiWT+qS+6kBai15OK2tuXI
         j3Vc+mNUlZL8X1pfK/Pp4igTpzakDaZNk//o1k0AcgB8w0tKGOglAuPzSFVBsTeTCHRF
         CQaQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=vBZCS9nU1fSH+kmSCYigm2Yq8YU/srN9xKPMLdxx9uA=;
        b=B6mRB/EDmufqRZhhdkOG3pduO5K7G6dilpwR/J/J15xV6hlqLw8VYv6flW4Wt3+euE
         DPFZw+icT9a0pGj8IoIzAM0hXjzU3CKUK/b5AmWkwaESZTPRXKrtnyzxv4Bb6kmeDU0s
         +j6LDFS/tqqs5ZJUFwYp7IzBHNMp5+hotzF2+oMmD0W17WXSwo00XtAcxFoBzDTfxYbV
         daLppOZrENBl0io5MXFZbaEsySvChJ14ImMorZcqGhxQyxLLBhrT0SM+pE1AgAF95abQ
         0jNxp/WsEG/A4OKMa2CslB4vdQezDN6EyDk/r48VMtt3sBbIuUbKTmx/ZIH8Bsp/FbGC
         g4Dw==
X-Gm-Message-State: APjAAAXw/0jH2WG+jBJH94kLdNX0uWcDYaBOxcNbrQPaLSN26t/Y1Vyz
	yrrrJXwG1iFmZgeFmdMN+Dl6Mw==
X-Google-Smtp-Source: APXvYqyGScQN03qDrXuVbBMNDdbJlq+zqcHgLnsomhbDkQ6dQ4qNnJhT5ZwIkawoSd3+haiCNIOt4w==
X-Received: by 2002:a50:87ca:: with SMTP id 10mr9263258edz.77.1568625387310;
        Mon, 16 Sep 2019 02:16:27 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id br15sm3577556ejb.2.2019.09.16.02.16.26
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Sep 2019 02:16:26 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 85A0A104174; Mon, 16 Sep 2019 12:16:28 +0300 (+03)
Date: Mon, 16 Sep 2019 12:16:28 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Jia He <justin.he@arm.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will@kernel.org>, Mark Rutland <mark.rutland@arm.com>,
	James Morse <james.morse@arm.com>, Marc Zyngier <maz@kernel.org>,
	Matthew Wilcox <willy@infradead.org>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, Punit Agrawal <punitagrawal@gmail.com>,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	Jun Yao <yaojun8558363@gmail.com>,
	Alex Van Brunt <avanbrunt@nvidia.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>, hejianet@gmail.com
Subject: Re: [PATCH v3 2/2] mm: fix double page fault on arm64 if PTE_AF is
 cleared
Message-ID: <20190916091628.bkuvd3g3ie3x6qav@box.shutemov.name>
References: <20190913163239.125108-1-justin.he@arm.com>
 <20190913163239.125108-3-justin.he@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190913163239.125108-3-justin.he@arm.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Sep 14, 2019 at 12:32:39AM +0800, Jia He wrote:
> When we tested pmdk unit test [1] vmmalloc_fork TEST1 in arm64 guest, there
> will be a double page fault in __copy_from_user_inatomic of cow_user_page.
> 
> Below call trace is from arm64 do_page_fault for debugging purpose
> [  110.016195] Call trace:
> [  110.016826]  do_page_fault+0x5a4/0x690
> [  110.017812]  do_mem_abort+0x50/0xb0
> [  110.018726]  el1_da+0x20/0xc4
> [  110.019492]  __arch_copy_from_user+0x180/0x280
> [  110.020646]  do_wp_page+0xb0/0x860
> [  110.021517]  __handle_mm_fault+0x994/0x1338
> [  110.022606]  handle_mm_fault+0xe8/0x180
> [  110.023584]  do_page_fault+0x240/0x690
> [  110.024535]  do_mem_abort+0x50/0xb0
> [  110.025423]  el0_da+0x20/0x24
> 
> The pte info before __copy_from_user_inatomic is (PTE_AF is cleared):
> [ffff9b007000] pgd=000000023d4f8003, pud=000000023da9b003, pmd=000000023d4b3003, pte=360000298607bd3
> 
> As told by Catalin: "On arm64 without hardware Access Flag, copying from
> user will fail because the pte is old and cannot be marked young. So we
> always end up with zeroed page after fork() + CoW for pfn mappings. we
> don't always have a hardware-managed access flag on arm64."
> 
> This patch fix it by calling pte_mkyoung. Also, the parameter is
> changed because vmf should be passed to cow_user_page()
> 
> [1] https://github.com/pmem/pmdk/tree/master/src/test/vmmalloc_fork
> 
> Reported-by: Yibo Cai <Yibo.Cai@arm.com>
> Signed-off-by: Jia He <justin.he@arm.com>
> ---
>  mm/memory.c | 30 +++++++++++++++++++++++++-----
>  1 file changed, 25 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index e2bb51b6242e..a64af6495f71 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -118,6 +118,13 @@ int randomize_va_space __read_mostly =
>  					2;
>  #endif
>  
> +#ifndef arch_faults_on_old_pte
> +static inline bool arch_faults_on_old_pte(void)
> +{
> +	return false;
> +}
> +#endif
> +
>  static int __init disable_randmaps(char *s)
>  {
>  	randomize_va_space = 0;
> @@ -2140,7 +2147,8 @@ static inline int pte_unmap_same(struct mm_struct *mm, pmd_t *pmd,
>  	return same;
>  }
>  
> -static inline void cow_user_page(struct page *dst, struct page *src, unsigned long va, struct vm_area_struct *vma)
> +static inline void cow_user_page(struct page *dst, struct page *src,
> +				struct vm_fault *vmf)
>  {
>  	debug_dma_assert_idle(src);
>  
> @@ -2152,20 +2160,32 @@ static inline void cow_user_page(struct page *dst, struct page *src, unsigned lo
>  	 */
>  	if (unlikely(!src)) {
>  		void *kaddr = kmap_atomic(dst);
> -		void __user *uaddr = (void __user *)(va & PAGE_MASK);
> +		void __user *uaddr = (void __user *)(vmf->address & PAGE_MASK);
> +		pte_t entry;
>  
>  		/*
>  		 * This really shouldn't fail, because the page is there
>  		 * in the page tables. But it might just be unreadable,
>  		 * in which case we just give up and fill the result with
> -		 * zeroes.
> +		 * zeroes. If PTE_AF is cleared on arm64, it might
> +		 * cause double page fault. So makes pte young here
>  		 */
> +		if (arch_faults_on_old_pte() && !pte_young(vmf->orig_pte)) {
> +			spin_lock(vmf->ptl);
> +			entry = pte_mkyoung(vmf->orig_pte);

Should't you re-validate that orig_pte after re-taking ptl? It can be
stale by now.

> +			if (ptep_set_access_flags(vmf->vma, vmf->address,
> +						  vmf->pte, entry, 0))
> +				update_mmu_cache(vmf->vma, vmf->address,
> +						 vmf->pte);
> +			spin_unlock(vmf->ptl);
> +		}
> +
>  		if (__copy_from_user_inatomic(kaddr, uaddr, PAGE_SIZE))
>  			clear_page(kaddr);
>  		kunmap_atomic(kaddr);
>  		flush_dcache_page(dst);
>  	} else
> -		copy_user_highpage(dst, src, va, vma);
> +		copy_user_highpage(dst, src, vmf->address, vmf->vma);
>  }
>  
>  static gfp_t __get_fault_gfp_mask(struct vm_area_struct *vma)
> @@ -2318,7 +2338,7 @@ static vm_fault_t wp_page_copy(struct vm_fault *vmf)
>  				vmf->address);
>  		if (!new_page)
>  			goto oom;
> -		cow_user_page(new_page, old_page, vmf->address, vma);
> +		cow_user_page(new_page, old_page, vmf);
>  	}
>  
>  	if (mem_cgroup_try_charge_delay(new_page, mm, GFP_KERNEL, &memcg, false))
> -- 
> 2.17.1
> 
> 

-- 
 Kirill A. Shutemov

