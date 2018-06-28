Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id D933B6B000A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 01:31:40 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k18-v6so2422559wrn.8
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 22:31:40 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id h66-v6si3258962wmg.128.2018.06.27.22.31.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 22:31:39 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5S5Ukea029998
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 01:31:38 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2jvskd8115-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 01:31:37 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 28 Jun 2018 06:31:36 +0100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: Freeing page table pages
Date: Thu, 28 Jun 2018 11:01:30 +0530
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Message-Id: <91ea4760-b793-2765-f59a-a09d730c0624@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Memory Management List <linux-mm@kvack.org>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

Hello,

Here is pagetable free function from x86 architecture (arch/x86/mm/init_64.c)

static void __meminit free_pagetable(struct page *page, int order)
{
	unsigned long magic;
	unsigned int nr_pages = 1 << order;

	/* bootmem page has reserved flag */
	if (PageReserved(page)) {
		__ClearPageReserved(page);

		magic = (unsigned long)page->freelist;
		if (magic == SECTION_INFO || magic == MIX_SECTION_INFO) {
			while (nr_pages--)
				put_page_bootmem(page++);
		} else
			while (nr_pages--)
				free_reserved_page(page++);
	} else
		free_pages((unsigned long)page_address(page), order);
}

Since all kernel pagetable pages allocated during boot from memblock should
have been marked with MIX_SECTION_INFO through the following function calls,
wondering in which case if (magic == SECTION_INFO || magic == MIX_SECTION_INFO)
will evaluate to be false and will directly call free_reserved_page() instead.

Inside register_page_bootmem_memmap() (arch/x86/mm/init_64.c)

get_page_bootmem(section_nr, pgd_page(*pgd), MIX_SECTION_INFO);
get_page_bootmem(section_nr, p4d_page(*p4d), MIX_SECTION_INFO);
get_page_bootmem(section_nr, pud_page(*pud), MIX_SECTION_INFO);
get_page_bootmem(section_nr, pte_page(*pte), SECTION_INFO);

- Anshuman
