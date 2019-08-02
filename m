Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8109DC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 16:21:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 460AB21726
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 16:21:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 460AB21726
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E05276B0006; Fri,  2 Aug 2019 12:21:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB5DC6B0008; Fri,  2 Aug 2019 12:21:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C7D2D6B000D; Fri,  2 Aug 2019 12:21:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id A7EB26B0006
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 12:21:40 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id x11so63919996qto.23
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 09:21:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=AReNG7RUQmfuq1B9QwsSuvwYDkxmJ5ibNpRZyFZZYNc=;
        b=mz2h1a5JkZIypNXtLzx18cmkvgHZ2AstAcrxWAei2fqL2EzU+1HVqwvttrTaN5VV/Q
         ctTINSegwtzVl7YNizmT2SbrhDgJTdEUQna9XTb2HozkyawyF/IHBrv1porY9utRqt/a
         TJQK1tg5B6v3AyBRF9YAgmNyixQcpQ6QdtPVQpOsCMDuPuy7qTkb9PT0YZ7TEG+4kWGz
         SEUR75kah2hnius5jvngCF8UMFfoQUAr52fvpxtlaS4umVlTzlvLDUZpOGjYdcx1pT6u
         N1Fsx3eCnUwAsX0xShgdqcAHWU0bU7UDNOOe0XX0pXdSSv8JR2Zw1QBcU9ju8o5Cqjec
         eDSw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWK5q3Kh7taGVqdn1JH5+SCcE+QiVpaWRZqua53KfBJdSKkzOKH
	UEEqAwxOU43aIZ1DRf0IGrisRtlKDEV/pI3kHofCY44YbGlixeIg+8mgAK2Yyp+eI0FFS5LmpwR
	oG2/iB/G45eDdFT6pAczlEz+il78waT9zZ6qaA5DLmVJSrqUfeExvd2/+yNBHH4R9qA==
X-Received: by 2002:ac8:323a:: with SMTP id x55mr93777112qta.211.1564762900458;
        Fri, 02 Aug 2019 09:21:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwd2nO6rLSCnE0ZskliqEE7XEB33GM3A8qNc9qWtvOWSUkHQVOWmZvPGlol5XSwPFFD41Dj
X-Received: by 2002:ac8:323a:: with SMTP id x55mr93777065qta.211.1564762899854;
        Fri, 02 Aug 2019 09:21:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564762899; cv=none;
        d=google.com; s=arc-20160816;
        b=iNGGtch6HFGTGMcZR3Led48BmgRfb9Vc+kPEzvm233PDtfb4kWiCOb4e4I6n9VOOUk
         NS9xaFRtHgRVLLWPmNCUtTn8QvRcHGSbmMbb5+HAJg0Mi7tGp+34tDdYfBigvnCagsMN
         zlCXWROXmP7xSD07aozCa4g3s1xIcczuodlH7E9XtK7RdEvtzeQ7HfkOfKd6pjrNRVlH
         011MhgjZzQHwZWPrX3O+tnrHrwK5wm50yIVCRWf7fLHXpZ1q8afYia2YrwPDYbrFxBtV
         6PcC8gxL6bENO9LPugEYJAMrSMrhxsBeo0/t64zwcOClGNQm6/GrFXm2m4O6fi+fWV1I
         AJnQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=AReNG7RUQmfuq1B9QwsSuvwYDkxmJ5ibNpRZyFZZYNc=;
        b=lMaNBbeOLTHH97XBWCdNt/02KJyJ20TOvR+F4YZQlWhAjfUQ238KHXg35IkC6BTHYL
         R1Qq6pQVwqsjUtsXI45/Vb8bE5N9i9uUSSct3PvYGWjEzay2O7Lc0MxJrrrZtPfG72Ep
         aleVsSQSUHO3VPBl7vEHGAb8q4f43wNVYsiw4I4neuevHnZnzXluP6+ISyfa9w1C/jqS
         C7ORX366MSs06eXVnQcMsokS75hXWoGWeRiGsrrvY8kRazi56J+OanMdaTFEcPFzaDa4
         Y3JEqtqKrygTXbCcGMFPTZHwR2rP5Usth0NeYYvdS5ZUQRe/XJIUPZUs3kHjYzAcP9Kb
         YPTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s26si46670438qta.169.2019.08.02.09.21.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 09:21:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0611230EA1B6;
	Fri,  2 Aug 2019 16:21:39 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.136])
	by smtp.corp.redhat.com (Postfix) with SMTP id 39FD910018F9;
	Fri,  2 Aug 2019 16:21:37 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Fri,  2 Aug 2019 18:21:38 +0200 (CEST)
Date: Fri, 2 Aug 2019 18:21:36 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Song Liu <songliubraving@fb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	akpm@linux-foundation.org, matthew.wilcox@oracle.com,
	kirill.shutemov@linux.intel.com, kernel-team@fb.com,
	william.kucharski@oracle.com, srikar@linux.vnet.ibm.com
Subject: Re: [PATCH v3 1/2] khugepaged: enable collapse pmd for pte-mapped THP
Message-ID: <20190802162136.GA2539@redhat.com>
References: <20190801184823.3184410-1-songliubraving@fb.com>
 <20190801184823.3184410-2-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190801184823.3184410-2-songliubraving@fb.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Fri, 02 Aug 2019 16:21:39 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 08/01, Song Liu wrote:
>
> +static int khugepaged_add_pte_mapped_thp(struct mm_struct *mm,
> +					 unsigned long addr)
> +{
> +	struct mm_slot *mm_slot;
> +	int ret = 0;
> +
> +	/* hold mmap_sem for khugepaged_test_exit() */
> +	VM_BUG_ON_MM(!rwsem_is_locked(&mm->mmap_sem), mm);
> +	VM_BUG_ON(addr & ~HPAGE_PMD_MASK);
> +
> +	if (unlikely(khugepaged_test_exit(mm)))
> +		return 0;
> +
> +	if (!test_bit(MMF_VM_HUGEPAGE, &mm->flags) &&
> +	    !test_bit(MMF_DISABLE_THP, &mm->flags)) {
> +		ret = __khugepaged_enter(mm);
> +		if (ret)
> +			return ret;
> +	}

see my reply to v2

> +void collapse_pte_mapped_thp(struct mm_struct *mm, unsigned long haddr)
> +{
> +	struct vm_area_struct *vma = find_vma(mm, haddr);
> +	pmd_t *pmd = mm_find_pmd(mm, haddr);
> +	struct page *hpage = NULL;
> +	unsigned long addr;
> +	spinlock_t *ptl;
> +	int count = 0;
> +	pmd_t _pmd;
> +	int i;
> +
> +	VM_BUG_ON(haddr & ~HPAGE_PMD_MASK);
> +
> +	if (!vma || !vma->vm_file || !pmd)
                    ^^^^^^^^^^^^^

I am not sure this is enough,

> +		return;
> +
> +	/* step 1: check all mapped PTEs are to the right huge page */
> +	for (i = 0, addr = haddr; i < HPAGE_PMD_NR; i++, addr += PAGE_SIZE) {
> +		pte_t *pte = pte_offset_map(pmd, addr);
> +		struct page *page;
> +
> +		if (pte_none(*pte))
> +			continue;
> +
> +		page = vm_normal_page(vma, addr, *pte);

Why can't vm_normal_page() return NULL? Again, we do not if this vm_file
is the same shmem_file() or something else.

And in fact I don't think it is safe to use vm_normal_page(vma, addr)
unless you know that vma includes this addr.

to be honest, I am not even sure that unconditional mm_find_pmd() is safe
if this "something else" is really special.

Oleg.

