Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51844C48BD5
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 10:34:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EDDC8214DA
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 10:34:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="jj94sRMw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EDDC8214DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7CF3D6B0003; Tue, 25 Jun 2019 06:34:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 758DE8E0003; Tue, 25 Jun 2019 06:34:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F83A8E0002; Tue, 25 Jun 2019 06:34:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 071996B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 06:34:08 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id m23so24964280edr.7
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 03:34:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=dyBqPZUv3bZgPsIAy4Om+lWx9RTnalxJxxYyGRhb+b8=;
        b=nD9nGhVJ32lCVLXLgtrFX7tQ+AXcsZpO+itL/SWIFXCCioFA/i+aLj0+EmZ+25tzRk
         6tuVWrY5CxbR6mQlsxrQ6F1bOGuUo9vnzYlcZec16Se9zLPF4IY4ANAnmOD9JLrS30jx
         ePPZQZJCwD6LB024Jv47Ex/ipNm8c/vsDr8hfACK2VJ3HqdWKuVe0cNVaujyNCWOVq66
         dFP953AZtlY2y8bvfy2lvSzgk3QNBSm0ojCYZue4PkrHSN6oKVjYBkKU0lNQLZOQGw+g
         iYaS2EdJVQEM1o5hvfHzifjBPe2rcPT+AadMO+nlLxuEHJMO83bsPz+kZotGq/yRDYkn
         Mjaw==
X-Gm-Message-State: APjAAAX0xpjnosgPjKuKA97jyb7uiCjRERg9W3XuGz5AFnl+foZ1aeY3
	TTtUGP4/z9rEPkC6ValNxiovGW0Q6CnyXcBoKOA/ibL89666gOgRF5Yi+pcegG6u9xXxb24q9ky
	3U4BReWj+rLnH/XnoTg/WNfscvE09ZXR0zrFF2idWAVf+pKpIqRj0nx/cegKBiwFTHg==
X-Received: by 2002:a17:906:74e:: with SMTP id z14mr56303296ejb.310.1561458847546;
        Tue, 25 Jun 2019 03:34:07 -0700 (PDT)
X-Received: by 2002:a17:906:74e:: with SMTP id z14mr56303207ejb.310.1561458846336;
        Tue, 25 Jun 2019 03:34:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561458846; cv=none;
        d=google.com; s=arc-20160816;
        b=NvBQQ8IdQ/RMYIt4ZPZpFzzQulLNKKrVOP1x7GkzFU4yEOP9FU1YY9I9jzDS4GYoEu
         frB987T3ValJPMFPb4miNat3o1tIp7tkfiPVlh2orddEdl5WzbGX/XD6uNY1sffjEqxU
         irUnryc/y59POR8xT1ZqGiJoIxEZZEGiWVGT8SYCbiFGMz0X8bImoYq4Ymev+0RiFq1h
         rrB701d1Xhhme0SoHL9roa4mYMkMOXgWVUM7bmQTS14LOTNL83f78j6eliOPJUR+7xst
         8+pTz/pOvj8BQzDO+/4VTTElgX/3hmPx8q9r52BO6axKKHe5o9qx1b5GKdjFpWVPxazJ
         Mf1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=dyBqPZUv3bZgPsIAy4Om+lWx9RTnalxJxxYyGRhb+b8=;
        b=giOSjWLnG/m6E5DzH6c1PuuVqNKNqjBZAwqoX6NHt4hGfOpUusnTG+mTB94sgdZzPG
         mPPdYitmKGBD0Rs6eej825KfBvEiknANMEoQhjTo7PS3D2g3aFOVK6VcY4A9QMJGNF8I
         f9pQUpszLCpP5Nw6BydOxW7cCPUmrU9Ed/9JKJoVjXkQqKcnUCC/SpyhEXxmQgiBFkoa
         x/vCuD+PMED67WaDeC2nnIUOjVCaevBDYg2GaCfMhzUfA6j/NamFadZo4Csc4bXQWGNh
         Y5dbpqq5wlQrgZ9hK5Cf71N54L12/GqpCjvcZ0Y3SKiAhlX4Fx1igIW2TxGFgQ341HZP
         xRvg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=jj94sRMw;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z11sor12124457edx.29.2019.06.25.03.34.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Jun 2019 03:34:06 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=jj94sRMw;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=dyBqPZUv3bZgPsIAy4Om+lWx9RTnalxJxxYyGRhb+b8=;
        b=jj94sRMwxHfsAUNS77tobLmrGsmyHnW5hmCw63c/XJdcfJqexoIOOF1SPKsDIzlKvr
         gMc/BFnMfUq/q7qu4iMMNuV8IfU789WADipq1XSLPxVdfkKaDamkqc+MC8hvJ5S+fbGc
         XSPi2Kn84De96ySR3FL/EUPkoCILydnABHKQf5NtqzXdmKkM7G3XTxThRlHOmU9Hb390
         mhyGnb5ooPP/kpAwaow3xUyHJz+ULrH0/DljWQ3nf+wV3kJEFIkSOeLBHOBXv3yxkf7x
         n1TBMuh63pdl8/auIcnf22aAZXeipV13XS9+StRnXIlbnZhQI0Ab92aVOxqZHvy6EiGA
         sayA==
X-Google-Smtp-Source: APXvYqxmHgIO7ovcuIBSsktbpczJIULLinPwuuA04U070XZir6Fm6cu4yfD0Lej+nMiAzHFRA7CaiQ==
X-Received: by 2002:a50:eb8b:: with SMTP id y11mr104789190edr.154.1561458845918;
        Tue, 25 Jun 2019 03:34:05 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id b21sm1179003ejb.12.2019.06.25.03.34.04
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 03:34:05 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id D143D1043B9; Tue, 25 Jun 2019 13:34:04 +0300 (+03)
Date: Tue, 25 Jun 2019 13:34:04 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Song Liu <songliubraving@fb.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
	"matthew.wilcox@oracle.com" <matthew.wilcox@oracle.com>,
	"kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>,
	"peterz@infradead.org" <peterz@infradead.org>,
	"oleg@redhat.com" <oleg@redhat.com>,
	"rostedt@goodmis.org" <rostedt@goodmis.org>,
	Kernel Team <Kernel-team@fb.com>,
	"william.kucharski@oracle.com" <william.kucharski@oracle.com>
Subject: Re: [PATCH v6 5/6] khugepaged: enable collapse pmd for pte-mapped THP
Message-ID: <20190625103404.3ypizksnpopcgwdk@box>
References: <20190623054829.4018117-1-songliubraving@fb.com>
 <20190623054829.4018117-6-songliubraving@fb.com>
 <20190624131934.m6gbktixyykw65ws@box>
 <24FB1072-E355-4F9D-855F-337C855C9AF9@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <24FB1072-E355-4F9D-855F-337C855C9AF9@fb.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 02:25:42PM +0000, Song Liu wrote:
> 
> 
> > On Jun 24, 2019, at 6:19 AM, Kirill A. Shutemov <kirill@shutemov.name> wrote:
> > 
> > On Sat, Jun 22, 2019 at 10:48:28PM -0700, Song Liu wrote:
> >> khugepaged needs exclusive mmap_sem to access page table. When it fails
> >> to lock mmap_sem, the page will fault in as pte-mapped THP. As the page
> >> is already a THP, khugepaged will not handle this pmd again.
> >> 
> >> This patch enables the khugepaged to retry retract_page_tables().
> >> 
> >> A new flag AS_COLLAPSE_PMD is introduced to show the address_space may
> >> contain pte-mapped THPs. When khugepaged fails to trylock the mmap_sem,
> >> it sets AS_COLLAPSE_PMD. Then, at a later time, khugepaged will retry
> >> compound pages in this address_space.
> >> 
> >> Since collapse may happen at an later time, some pages may already fault
> >> in. To handle these pages properly, it is necessary to prepare the pmd
> >> before collapsing. prepare_pmd_for_collapse() is introduced to prepare
> >> the pmd by removing rmap, adjusting refcount and mm_counter.
> >> 
> >> prepare_pmd_for_collapse() also double checks whether all ptes in this
> >> pmd are mapping to the same THP. This is necessary because some subpage
> >> of the THP may be replaced, for example by uprobe. In such cases, it
> >> is not possible to collapse the pmd, so we fall back.
> >> 
> >> Signed-off-by: Song Liu <songliubraving@fb.com>
> >> ---
> >> include/linux/pagemap.h |  1 +
> >> mm/khugepaged.c         | 69 +++++++++++++++++++++++++++++++++++------
> >> 2 files changed, 60 insertions(+), 10 deletions(-)
> >> 
> >> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> >> index 9ec3544baee2..eac881de2a46 100644
> >> --- a/include/linux/pagemap.h
> >> +++ b/include/linux/pagemap.h
> >> @@ -29,6 +29,7 @@ enum mapping_flags {
> >> 	AS_EXITING	= 4, 	/* final truncate in progress */
> >> 	/* writeback related tags are not used */
> >> 	AS_NO_WRITEBACK_TAGS = 5,
> >> +	AS_COLLAPSE_PMD = 6,	/* try collapse pmd for THP */
> >> };
> >> 
> >> /**
> >> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> >> index a4f90a1b06f5..9b980327fd9b 100644
> >> --- a/mm/khugepaged.c
> >> +++ b/mm/khugepaged.c
> >> @@ -1254,7 +1254,47 @@ static void collect_mm_slot(struct mm_slot *mm_slot)
> >> }
> >> 
> >> #if defined(CONFIG_SHMEM) && defined(CONFIG_TRANSPARENT_HUGE_PAGECACHE)
> >> -static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff)
> >> +
> >> +/* return whether the pmd is ready for collapse */
> >> +bool prepare_pmd_for_collapse(struct vm_area_struct *vma, pgoff_t pgoff,
> >> +			      struct page *hpage, pmd_t *pmd)
> >> +{
> >> +	unsigned long haddr = page_address_in_vma(hpage, vma);
> >> +	unsigned long addr;
> >> +	int i, count = 0;
> >> +
> >> +	/* step 1: check all mapped PTEs are to this huge page */
> >> +	for (i = 0, addr = haddr; i < HPAGE_PMD_NR; i++, addr += PAGE_SIZE) {
> >> +		pte_t *pte = pte_offset_map(pmd, addr);
> >> +
> >> +		if (pte_none(*pte))
> >> +			continue;
> >> +
> >> +		if (hpage + i != vm_normal_page(vma, addr, *pte))
> >> +			return false;
> >> +		count++;
> >> +	}
> >> +
> >> +	/* step 2: adjust rmap */
> >> +	for (i = 0, addr = haddr; i < HPAGE_PMD_NR; i++, addr += PAGE_SIZE) {
> >> +		pte_t *pte = pte_offset_map(pmd, addr);
> >> +		struct page *page;
> >> +
> >> +		if (pte_none(*pte))
> >> +			continue;
> >> +		page = vm_normal_page(vma, addr, *pte);
> >> +		page_remove_rmap(page, false);
> >> +	}
> >> +
> >> +	/* step 3: set proper refcount and mm_counters. */
> >> +	page_ref_sub(hpage, count);
> >> +	add_mm_counter(vma->vm_mm, mm_counter_file(hpage), -count);
> >> +	return true;
> >> +}
> >> +
> >> +extern pid_t sysctl_dump_pt_pid;
> >> +static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff,
> >> +				struct page *hpage)
> >> {
> >> 	struct vm_area_struct *vma;
> >> 	unsigned long addr;
> >> @@ -1273,21 +1313,21 @@ static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff)
> >> 		pmd = mm_find_pmd(vma->vm_mm, addr);
> >> 		if (!pmd)
> >> 			continue;
> >> -		/*
> >> -		 * We need exclusive mmap_sem to retract page table.
> >> -		 * If trylock fails we would end up with pte-mapped THP after
> >> -		 * re-fault. Not ideal, but it's more important to not disturb
> >> -		 * the system too much.
> >> -		 */
> >> 		if (down_write_trylock(&vma->vm_mm->mmap_sem)) {
> >> 			spinlock_t *ptl = pmd_lock(vma->vm_mm, pmd);
> >> -			/* assume page table is clear */
> >> +
> >> +			if (!prepare_pmd_for_collapse(vma, pgoff, hpage, pmd)) {
> >> +				spin_unlock(ptl);
> >> +				up_write(&vma->vm_mm->mmap_sem);
> >> +				continue;
> >> +			}
> >> 			_pmd = pmdp_collapse_flush(vma, addr, pmd);
> >> 			spin_unlock(ptl);
> >> 			up_write(&vma->vm_mm->mmap_sem);
> >> 			mm_dec_nr_ptes(vma->vm_mm);
> >> 			pte_free(vma->vm_mm, pmd_pgtable(_pmd));
> >> -		}
> >> +		} else
> >> +			set_bit(AS_COLLAPSE_PMD, &mapping->flags);
> >> 	}
> >> 	i_mmap_unlock_write(mapping);
> >> }
> >> @@ -1561,7 +1601,7 @@ static void collapse_file(struct mm_struct *mm,
> >> 		/*
> >> 		 * Remove pte page tables, so we can re-fault the page as huge.
> >> 		 */
> >> -		retract_page_tables(mapping, start);
> >> +		retract_page_tables(mapping, start, new_page);
> >> 		*hpage = NULL;
> >> 
> >> 		khugepaged_pages_collapsed++;
> >> @@ -1622,6 +1662,7 @@ static void khugepaged_scan_file(struct mm_struct *mm,
> >> 	int present, swap;
> >> 	int node = NUMA_NO_NODE;
> >> 	int result = SCAN_SUCCEED;
> >> +	bool collapse_pmd = false;
> >> 
> >> 	present = 0;
> >> 	swap = 0;
> >> @@ -1640,6 +1681,14 @@ static void khugepaged_scan_file(struct mm_struct *mm,
> >> 		}
> >> 
> >> 		if (PageTransCompound(page)) {
> >> +			if (collapse_pmd ||
> >> +			    test_and_clear_bit(AS_COLLAPSE_PMD,
> >> +					       &mapping->flags)) {
> > 
> > Who said it's the only PMD range that's subject to collapse? The bit has
> > to be per-PMD, not per-mapping.
> 
> I didn't assume this is the only PMD range that subject to collapse. 
> So once we found AS_COLLAPSE_PMD, it will continue scan the whole mapping:
> retract_page_tables(), then continue. 

I still don't get it.

Assume we have two ranges that subject to collapse. khugepaged_scan_file()
sees and clears AS_COLLAPSE_PMD. Tries to collapse the first range, fails
and set the bit again. khugepaged_scan_file() sees the second range,
clears the bit, but this time collapse is successful: the bit is still not
set, but it should be.

> > I beleive we can store the bit in struct page of PTE page table, clearing
> > it if we've mapped anyting that doesn't belong to there from fault path.
> > 
> > And in general this calls for more substantial re-design for khugepaged:
> > we might want to split if into two different kernel threads. One works on
> > collapsing small pages into compound and the other changes virtual address
> > space to map the page as PMD.
> 
> I had almost same idea of splitting into two threads. Or ask one thread to 
> scan two lists: one for pages to collapse, the other for page tables to
> map as PMD. However, that does need substantial re-design. 
> 
> On the other hand, this patch is much simpler and does the work fine. It is
> not optimal, as it scans the whole mapping for opportunity in just one PMD 
> range. But the overhead is not in any hot path, so it just works. The extra 
> double check in prepare_pmd_for_collapse() makes sure it will not collapse 
> wrong pages into pmd mapped. 
> 
> Overall, I believe this is an accurate solution for the problem. We can 
> further improve it. But I really hope to do the improvements after these
> two patchsets get in. 

I don't think AS_COLLAPSE_PMD adds much value. I don't see it relieably
serving the purpose.

-- 
 Kirill A. Shutemov

