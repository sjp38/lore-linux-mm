Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 728F8C41514
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 13:46:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2989D21738
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 13:46:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="Wy+7lJEb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2989D21738
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A936C6B0003; Tue, 23 Jul 2019 09:46:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A45708E0003; Tue, 23 Jul 2019 09:46:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 933608E0002; Tue, 23 Jul 2019 09:46:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5C81C6B0003
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 09:46:51 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id g2so4730209pgj.2
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 06:46:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=NRUsmiPhuV/QvVA6HXpKfJ8yVBFuGtPyikAZnnW42UA=;
        b=KmEpH+bl27XqEgQdch1nmF7m9aoaGWSa3pRPhBjx+p9efnlVOJF1Ww45VbGGTSAvAj
         YqKGODhb4NzphvnHUozqFNA13rr2KHq7IpjRz5aW9REfXKVP7RcT46FTWGzQ2Dbbb+LQ
         sJE5xaKJLQWchvDdYQJYfJpLejgAyfiEyujF+jqYdAG+wdlj0E3xkmBzsQ9cxeBqbeK2
         cwSALWTmJN4S5n/BeCjTf44/hRn1CDpBLixGLM6AIj5t26EKAISzSpWmQOtE1TlRXh65
         W39xDdOA1vAeR0y26OJe/NRFAGGvofRFtRAthfA8W7sbAD8Lh3rALPu8KwmDJ+IgWgQk
         NXNg==
X-Gm-Message-State: APjAAAXaq4zmRt8shrvk8a8bJUI0IlbCuCATw0P8YtEitQyGVdpR/Zh5
	XPIpMOcZarDUjL81ZjU89gEL4tChCRKJKi323UOSNCPOICouda/pCHqcd3lHlCh7XXU3r0WHaq4
	kKBPyKSQwgBsXoqTFJqG/5FoAThM3Oxlfl9wVSzZ6NTF0JtSJIaM/r9hJBQaycCgXmA==
X-Received: by 2002:a63:d30f:: with SMTP id b15mr75908852pgg.341.1563889610917;
        Tue, 23 Jul 2019 06:46:50 -0700 (PDT)
X-Received: by 2002:a63:d30f:: with SMTP id b15mr75908792pgg.341.1563889609922;
        Tue, 23 Jul 2019 06:46:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563889609; cv=none;
        d=google.com; s=arc-20160816;
        b=DJlv5K8R38PoDk3NcV1lEtG9TbWqBtYnHiZ7LePiDlSkznT226/bcod1i2zRWW0hsc
         n30FQMQqv/nb9RKQJR8nW+zaxwzX0ZTkFPwEOzgX/UDghpckeu0JHC83f39k4HN6gcy6
         tiIHlyKxCqI4JKhCdlQYAJmqBzvUTzNrt0lbWXlFPEQeLzu/zrmGhau5EM7cFF8sB/BV
         Icq2PINfsknd9NdiquwTaSQukMs0LJLqfjfNHhU0VZ0VJtLLX0cnySYPdn0abwFJtsQw
         DZvRfl3IN7JmeALrPWrNGKxzr7mc8z9JREZDclZGUlLBNraE+3PUPEWdKNsxLa2PyYpv
         LdRA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=NRUsmiPhuV/QvVA6HXpKfJ8yVBFuGtPyikAZnnW42UA=;
        b=Jze2IT3YWFiIHH0hCZycDYgZ6dqjrGGir4SdodQV+7izFDpQMDbDXmwWTU96yOFZx3
         fBETzQV+UGihw6UKhq8x31mqd5EysOA+iyATw0WQe4Fn0zUqI9+b1x3BmgbFJUbyUZH7
         EqHl9lAXcL5fCBDK/3W3hKWhWFYCUKGIIT1SkPmsKe3vGx9V/8nZWZWaI8peFjOQZif1
         /zRqqT7QjPf4sTuL9r3EfCJArUQ69O5lo1Sh8xroIOL2Hq5gyVoFRnRVb6hwt4E3t/bg
         hfU5ZE3votpAvIq9raZWhJga48Vo6zzwqHyoBm66nu2xxt8aA7ocHAnoJYQapoCQcD61
         1mKg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=Wy+7lJEb;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v13sor23243187pgr.24.2019.07.23.06.46.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 06:46:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=Wy+7lJEb;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=NRUsmiPhuV/QvVA6HXpKfJ8yVBFuGtPyikAZnnW42UA=;
        b=Wy+7lJEbJnUjhN/3d+P/WkzU1TxZAAofTXa0jNrPbUFhz6K1ul+KMpHQtEmKZomqe5
         3bAVmyQF769rbi26y0OV9Yu5A3fWTY1p9OSV1amubIKbTK2awGPf0k/VMtr0ngExJpqi
         hp2UfL11M+B2k0FCpS7rbGZUunpaXsuyXnklE=
X-Google-Smtp-Source: APXvYqwwmqbXZiz1onTBdcqfPg4rDWuCGZVgSbPwSIq0EFIwyiYsez+oy6N4sdX5ac4dIxLz2Ae89Q==
X-Received: by 2002:a63:ee0c:: with SMTP id e12mr77677268pgi.184.1563889609265;
        Tue, 23 Jul 2019 06:46:49 -0700 (PDT)
Received: from localhost ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id o129sm7572519pfg.1.2019.07.23.06.46.48
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 06:46:48 -0700 (PDT)
Date: Tue, 23 Jul 2019 09:46:47 -0400
From: Joel Fernandes <joel@joelfernandes.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org,
	Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH RFC] mm/page_idle: simple idle page tracking for virtual
 memory
Message-ID: <20190723134647.GA104199@google.com>
References: <156388286599.2859.5353604441686895041.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <156388286599.2859.5353604441686895041.stgit@buzz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 02:54:26PM +0300, Konstantin Khlebnikov wrote:
> The page_idle tracking feature currently requires looking up the pagemap
> for a process followed by interacting with /sys/kernel/mm/page_idle.
> This is quite cumbersome and can be error-prone too. If between
> accessing the per-PID pagemap and the global page_idle bitmap, if
> something changes with the page then the information is not accurate.
> More over looking up PFN from pagemap in Android devices is not
> supported by unprivileged process and requires SYS_ADMIN and gives 0 for
> the PFN.
> 
> This patch adds simplified interface which works only with mapped pages:
> Run: "echo 6 > /proc/pid/clear_refs" to mark all mapped pages as idle.
> Pages that still idle are marked with bit 57 in /proc/pid/pagemap.
> Total size of idle pages is shown in /proc/pid/smaps (_rollup).
> 
> Piece of comment is stolen from Joel Fernandes <joel@joelfernandes.org>

This will not work well for the problem at hand, the heap profiler
(heapprofd) only wants to clear the idle flag for the heap memory area which
is what it is profiling. There is no reason to do it for all mapped pages.
Using the /proc/pid/page_idle in my patch, it can be done selectively for
particular memory areas.

I had previously thought of having an interface that accepts an address
range to set the idle flag, however that is also more complexity.

thanks,

 - Joel


> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> Link: https://lore.kernel.org/lkml/20190722213205.140845-1-joel@joelfernandes.org/
> ---
>  Documentation/admin-guide/mm/pagemap.rst |    3 ++-
>  Documentation/filesystems/proc.txt       |    3 +++
>  fs/proc/task_mmu.c                       |   33 ++++++++++++++++++++++++++++--
>  3 files changed, 36 insertions(+), 3 deletions(-)
> 
> diff --git a/Documentation/admin-guide/mm/pagemap.rst b/Documentation/admin-guide/mm/pagemap.rst
> index 340a5aee9b80..d7ee60287584 100644
> --- a/Documentation/admin-guide/mm/pagemap.rst
> +++ b/Documentation/admin-guide/mm/pagemap.rst
> @@ -21,7 +21,8 @@ There are four components to pagemap:
>      * Bit  55    pte is soft-dirty (see
>        :ref:`Documentation/admin-guide/mm/soft-dirty.rst <soft_dirty>`)
>      * Bit  56    page exclusively mapped (since 4.2)
> -    * Bits 57-60 zero
> +    * Bit  57    page is idle
> +    * Bits 58-60 zero
>      * Bit  61    page is file-page or shared-anon (since 3.5)
>      * Bit  62    page swapped
>      * Bit  63    page present
> diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
> index 99ca040e3f90..d222be8b4eb9 100644
> --- a/Documentation/filesystems/proc.txt
> +++ b/Documentation/filesystems/proc.txt
> @@ -574,6 +574,9 @@ To reset the peak resident set size ("high water mark") to the process's
>  current value:
>      > echo 5 > /proc/PID/clear_refs
>  
> +To mark all mapped pages as idle:
> +    > echo 6 > /proc/PID/clear_refs
> +
>  Any other value written to /proc/PID/clear_refs will have no effect.
>  
>  The /proc/pid/pagemap gives the PFN, which can be used to find the pageflags
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 731642e0f5a0..6da952574a1f 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -413,6 +413,7 @@ struct mem_size_stats {
>  	unsigned long private_clean;
>  	unsigned long private_dirty;
>  	unsigned long referenced;
> +	unsigned long idle;
>  	unsigned long anonymous;
>  	unsigned long lazyfree;
>  	unsigned long anonymous_thp;
> @@ -479,6 +480,10 @@ static void smaps_account(struct mem_size_stats *mss, struct page *page,
>  	if (young || page_is_young(page) || PageReferenced(page))
>  		mss->referenced += size;
>  
> +	/* Not accessed and still idle. */
> +	if (!young && page_is_idle(page))
> +		mss->idle += size;
> +
>  	/*
>  	 * Then accumulate quantities that may depend on sharing, or that may
>  	 * differ page-by-page.
> @@ -799,6 +804,9 @@ static void __show_smap(struct seq_file *m, const struct mem_size_stats *mss,
>  	SEQ_PUT_DEC(" kB\nPrivate_Clean:  ", mss->private_clean);
>  	SEQ_PUT_DEC(" kB\nPrivate_Dirty:  ", mss->private_dirty);
>  	SEQ_PUT_DEC(" kB\nReferenced:     ", mss->referenced);
> +#ifdef CONFIG_IDLE_PAGE_TRACKING
> +	SEQ_PUT_DEC(" kB\nIdle:           ", mss->idle);
> +#endif
>  	SEQ_PUT_DEC(" kB\nAnonymous:      ", mss->anonymous);
>  	SEQ_PUT_DEC(" kB\nLazyFree:       ", mss->lazyfree);
>  	SEQ_PUT_DEC(" kB\nAnonHugePages:  ", mss->anonymous_thp);
> @@ -969,6 +977,7 @@ enum clear_refs_types {
>  	CLEAR_REFS_MAPPED,
>  	CLEAR_REFS_SOFT_DIRTY,
>  	CLEAR_REFS_MM_HIWATER_RSS,
> +	CLEAR_REFS_SOFT_ACCESS,
>  	CLEAR_REFS_LAST,
>  };
>  
> @@ -1045,6 +1054,7 @@ static int clear_refs_pte_range(pmd_t *pmd, unsigned long addr,
>  	pte_t *pte, ptent;
>  	spinlock_t *ptl;
>  	struct page *page;
> +	int young;
>  
>  	ptl = pmd_trans_huge_lock(pmd, vma);
>  	if (ptl) {
> @@ -1058,8 +1068,16 @@ static int clear_refs_pte_range(pmd_t *pmd, unsigned long addr,
>  
>  		page = pmd_page(*pmd);
>  
> +		young = pmdp_test_and_clear_young(vma, addr, pmd);
> +
> +		if (cp->type == CLEAR_REFS_SOFT_ACCESS) {
> +			if (young)
> +				set_page_young(page);
> +			set_page_idle(page);
> +			goto out;
> +		}
> +
>  		/* Clear accessed and referenced bits. */
> -		pmdp_test_and_clear_young(vma, addr, pmd);
>  		test_and_clear_page_young(page);
>  		ClearPageReferenced(page);
>  out:
> @@ -1086,8 +1104,16 @@ static int clear_refs_pte_range(pmd_t *pmd, unsigned long addr,
>  		if (!page)
>  			continue;
>  
> +		young = ptep_test_and_clear_young(vma, addr, pte);
> +
> +		if (cp->type == CLEAR_REFS_SOFT_ACCESS) {
> +			if (young)
> +				set_page_young(page);
> +			set_page_idle(page);
> +			continue;
> +		}
> +
>  		/* Clear accessed and referenced bits. */
> -		ptep_test_and_clear_young(vma, addr, pte);
>  		test_and_clear_page_young(page);
>  		ClearPageReferenced(page);
>  	}
> @@ -1253,6 +1279,7 @@ struct pagemapread {
>  #define PM_PFRAME_MASK		GENMASK_ULL(PM_PFRAME_BITS - 1, 0)
>  #define PM_SOFT_DIRTY		BIT_ULL(55)
>  #define PM_MMAP_EXCLUSIVE	BIT_ULL(56)
> +#define PM_IDLE			BIT_ULL(57)
>  #define PM_FILE			BIT_ULL(61)
>  #define PM_SWAP			BIT_ULL(62)
>  #define PM_PRESENT		BIT_ULL(63)
> @@ -1326,6 +1353,8 @@ static pagemap_entry_t pte_to_pagemap_entry(struct pagemapread *pm,
>  		page = vm_normal_page(vma, addr, pte);
>  		if (pte_soft_dirty(pte))
>  			flags |= PM_SOFT_DIRTY;
> +		if (!pte_young(pte) && page && page_is_idle(page))
> +			flags |= PM_IDLE;
>  	} else if (is_swap_pte(pte)) {
>  		swp_entry_t entry;
>  		if (pte_swp_soft_dirty(pte))
> 

