Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A726C31E40
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 13:07:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 52086216F4
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 13:07:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 52086216F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D23296B0003; Mon, 12 Aug 2019 09:07:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD4826B0005; Mon, 12 Aug 2019 09:07:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BC2286B0006; Mon, 12 Aug 2019 09:07:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0214.hostedemail.com [216.40.44.214])
	by kanga.kvack.org (Postfix) with ESMTP id 966546B0003
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 09:07:05 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 3979B1EE6
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 13:07:05 +0000 (UTC)
X-FDA: 75813801210.18.tub63_20a763df0eb31
X-HE-Tag: tub63_20a763df0eb31
X-Filterd-Recvd-Size: 4139
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf19.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 13:07:04 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id DDE87300895B;
	Mon, 12 Aug 2019 13:07:02 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.136])
	by smtp.corp.redhat.com (Postfix) with SMTP id 048676FDA5;
	Mon, 12 Aug 2019 13:07:00 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Mon, 12 Aug 2019 15:07:02 +0200 (CEST)
Date: Mon, 12 Aug 2019 15:06:59 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Song Liu <songliubraving@fb.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <matthew.wilcox@oracle.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Kernel Team <Kernel-team@fb.com>,
	William Kucharski <william.kucharski@oracle.com>,
	"srikar@linux.vnet.ibm.com" <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v12 5/6] khugepaged: enable collapse pmd for pte-mapped
 THP
Message-ID: <20190812130659.GA31560@redhat.com>
References: <20190807233729.3899352-1-songliubraving@fb.com>
 <20190807233729.3899352-6-songliubraving@fb.com>
 <20190808163303.GB7934@redhat.com>
 <770B3C29-CE8F-4228-8992-3C6E2B5487B6@fb.com>
 <20190809152404.GA21489@redhat.com>
 <3B09235E-5CF7-4982-B8E6-114C52196BE5@fb.com>
 <4D8B8397-5107-456B-91FC-4911F255AE11@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4D8B8397-5107-456B-91FC-4911F255AE11@fb.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Mon, 12 Aug 2019 13:07:03 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 08/09, Song Liu wrote:
>
> +void collapse_pte_mapped_thp(struct mm_struct *mm, unsigned long addr)
> +{
> +	unsigned long haddr = addr & HPAGE_PMD_MASK;
> +	struct vm_area_struct *vma = find_vma(mm, haddr);
> +	struct page *hpage = NULL;
> +	pmd_t *pmd, _pmd;
> +	spinlock_t *ptl;
> +	int count = 0;
> +	int i;
> +
> +	if (!vma || !vma->vm_file ||
> +	    vma->vm_start > haddr || vma->vm_end < haddr + HPAGE_PMD_SIZE)
> +		return;
> +
> +	/*
> +	 * This vm_flags may not have VM_HUGEPAGE if the page was not
> +	 * collapsed by this mm. But we can still collapse if the page is
> +	 * the valid THP. Add extra VM_HUGEPAGE so hugepage_vma_check()
> +	 * will not fail the vma for missing VM_HUGEPAGE
> +	 */
> +	if (!hugepage_vma_check(vma, vma->vm_flags | VM_HUGEPAGE))
> +		return;
> +
> +	pmd = mm_find_pmd(mm, haddr);
> +	if (!pmd)
> +		return;
> +
> +	/* step 1: check all mapped PTEs are to the right huge page */
> +	for (i = 0, addr = haddr; i < HPAGE_PMD_NR; i++, addr += PAGE_SIZE) {
> +		pte_t *pte = pte_offset_map(pmd, addr);
> +		struct page *page;
> +
> +		if (pte_none(*pte) || !pte_present(*pte))
> +			continue;

		if (!pte_present(*pte))
			return;

you can't simply flush pmd if this page is swapped out.

> +
> +		page = vm_normal_page(vma, addr, *pte);
> +
> +		if (!page || !PageCompound(page))
> +			return;
> +
> +		if (!hpage) {
> +			hpage = compound_head(page);
> +			/*
> +			 * The mapping of the THP should not change.
> +			 *
> +			 * Note that uprobe may change the page table,

Not only uprobe can cow the page. Debugger can do. Or mmap(PROT_WRITE, MAP_PRIVATE).

uprobe() is "special" because it a) it works with a foreign mm and b)
it can't stop the process which uses this mm. Otherwise it could simply
update the page returned by get_user_pages_remote(FOLL_FORCE), just we
would need to add FOLL_WRITE and if we do this we do not even need SPLIT,
that is why, say, __access_remote_vm() works without SPLIT.

Oleg.


