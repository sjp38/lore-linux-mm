Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 477CDC48BD4
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 14:12:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C2AE7208E3
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 14:12:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="xavP6AcF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C2AE7208E3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4E0966B0003; Tue, 25 Jun 2019 10:12:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 46AEC8E0003; Tue, 25 Jun 2019 10:12:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 333708E0002; Tue, 25 Jun 2019 10:12:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id EECAF6B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 10:12:30 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id s5so25741492eda.10
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 07:12:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=bzh4y8yBq1d8sGVGWQWCvIcSY6SCvqb9cYfV13WkiBs=;
        b=lRgdIg5wqDNhy9UouJwDAITE8znvYoJjXPdNxZdc2JLnE1s9OfpupCyIt7IEJ4FE68
         qTW/uAe9INLmF/Fj8qmNYrbYAQaxPbBkVYnKS8m06m0k3b3D4WGqMesBnuIhmCzNaqNH
         4WZW4jmy6MdMgehkCOzy9aDGjmFrVQNZ8MbpKNEWpX5J5fo3JYBzyuyiZ9e0Qt9K0S87
         xMrIR3tsbZd+y4nOHaP1Vf52bl9bwQk01GEx76D9WzHbNj+uf6/VKYwSQ2M2pmUrtlr+
         Xbk9nc4a3xV7JOaJyKxyFjzgNpWpnlAo4F85Gxi7brMOX+5BvCzIeYaeZzMsDplFqIy6
         ojTw==
X-Gm-Message-State: APjAAAU0s5C6p69OJ0kck+XT+KM79+kbeHx1HRfrnxr/urIuZhFOVto4
	sbtNUnvZZWDVqb+jEuM44uRGBvuYQUVVF6KID1atGOL7uo16wFeBFJTKiule/dG2jwPaMKImBsQ
	CvtzIxCzb4jnATKN00s6drT2+UtdXD9X4KSahVTx2xLQFVgCRXzhPciCpByQOWELXfg==
X-Received: by 2002:a05:6402:6cb:: with SMTP id n11mr57773995edy.101.1561471950346;
        Tue, 25 Jun 2019 07:12:30 -0700 (PDT)
X-Received: by 2002:a05:6402:6cb:: with SMTP id n11mr57773891edy.101.1561471949399;
        Tue, 25 Jun 2019 07:12:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561471949; cv=none;
        d=google.com; s=arc-20160816;
        b=ge7PSuIXP/byqp0uikPWaCNitpR8N0WFqj7MBir0dS8VLn/FdBgisXB0ooyz7iLAEA
         Hcr7LjEIzXrOBhy3UNIyrNC2QfaUVysPfwEoXZlxEXi6TBnHMtlYMKi2LdrAJJITI2h/
         cBrBv4LBVvhIJH8e5T6iu2kZ4QzMstcT8KgS6ByDPGPPzCvdlLRmsfTYedAE847qM3XY
         y181aZs7mBONBuxU5uJW6XcpKnIVBWNPFW1AqUUYWTBg0iW6oI1ec7QFIjfvYN3Ffvzd
         Lld9f009/4IC7gBVo67Y34dhTujVwT6kFb+XexSC0BZQQdjB67YCP6tKktdxsNfCwhfQ
         RR5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=bzh4y8yBq1d8sGVGWQWCvIcSY6SCvqb9cYfV13WkiBs=;
        b=PiRFnhhETA/Vdi8LHSmH0xxNiUs9ba7ehPtAicrW1PHomglnb2BQ9TeVlp06gXzFZX
         R7S7sYzgE5AWcUImsBgPIqQvS+XkAj4U5y/F041hvs8l/GY04UIWRGPMlj3PLogc/bql
         MwSnWOvQARb8GhcEzKsZpj8T/7z3XNxCbqZ1pAWtnApjNtv6Z3TmH+yQGUcevdrjv8jw
         WeLkKa1q1hD3Ql75iy3ystcYbawaCMJ7fvJm3wFzIWjYF2bFKs1hvS4pHHDNvAZJZSyG
         gSuH+0uDeo72TBn8m0m7loFa1S4aAW9dgzjQ/9n80y99XtRbXW7m0wZsWJInWDK7a8QN
         HQFg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=xavP6AcF;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f25sor12695365eda.21.2019.06.25.07.12.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Jun 2019 07:12:29 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=xavP6AcF;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=bzh4y8yBq1d8sGVGWQWCvIcSY6SCvqb9cYfV13WkiBs=;
        b=xavP6AcFos+5/gcLgj61V0TWhwz9+eOCREwBhIQVoDR1sKB2lBYWWjCsjvGJ5n0ZCw
         Cb8scU3SYjKO+FVx406DZPkdjElR8Xe2ZQHS0+hszoILaSrcu9Dk1hdrRlUPrTb91G7o
         ORy7uHSasTkO9tjdrMZQMyeT0i18KVbuIbt8zuA663Kp2OIwu5NGo+QrJmh45/YR2ptH
         6I47LE7pqQuMo2/6lssvmmJcsYJhR4wfW+rF7rxr29kWTiWSdzgX3ChftN0PnRYFPC50
         cGWQaGUfLKMhg33vGnTlMbe1SM23fp4JeaRmaeqQfHfsgpz4gvjWoKFAQavLo3BiCmSw
         JPbQ==
X-Google-Smtp-Source: APXvYqydwuza2WtDltoJlD3oalpA05dOhtFG6u5qgxI0LShBzURhmqG0ZYZ/ZoXYFHw6apws5HNAPw==
X-Received: by 2002:a50:90fa:: with SMTP id d55mr123415871eda.210.1561471948947;
        Tue, 25 Jun 2019 07:12:28 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id q21sm944001ejo.76.2019.06.25.07.12.27
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 07:12:28 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 3634D1043B9; Tue, 25 Jun 2019 17:12:28 +0300 (+03)
Date: Tue, 25 Jun 2019 17:12:28 +0300
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
Message-ID: <20190625141228.j7w5j6jubxrd5ivr@box>
References: <20190623054829.4018117-1-songliubraving@fb.com>
 <20190623054829.4018117-6-songliubraving@fb.com>
 <20190624131934.m6gbktixyykw65ws@box>
 <24FB1072-E355-4F9D-855F-337C855C9AF9@fb.com>
 <20190625103404.3ypizksnpopcgwdk@box>
 <77DBF8A2-DF3D-4635-A5E6-66D80A8BFA50@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <77DBF8A2-DF3D-4635-A5E6-66D80A8BFA50@fb.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 25, 2019 at 12:33:03PM +0000, Song Liu wrote:
> 
> 
> > On Jun 25, 2019, at 3:34 AM, Kirill A. Shutemov <kirill@shutemov.name> wrote:
> > 
> > On Mon, Jun 24, 2019 at 02:25:42PM +0000, Song Liu wrote:
> >> 
> >> 
> >>> On Jun 24, 2019, at 6:19 AM, Kirill A. Shutemov <kirill@shutemov.name> wrote:
> >>> 
> >>> On Sat, Jun 22, 2019 at 10:48:28PM -0700, Song Liu wrote:
> >>>> khugepaged needs exclusive mmap_sem to access page table. When it fails
> >>>> to lock mmap_sem, the page will fault in as pte-mapped THP. As the page
> >>>> is already a THP, khugepaged will not handle this pmd again.
> >>>> 
> >>>> This patch enables the khugepaged to retry retract_page_tables().
> >>>> 
> >>>> A new flag AS_COLLAPSE_PMD is introduced to show the address_space may
> >>>> contain pte-mapped THPs. When khugepaged fails to trylock the mmap_sem,
> >>>> it sets AS_COLLAPSE_PMD. Then, at a later time, khugepaged will retry
> >>>> compound pages in this address_space.
> >>>> 
> >>>> Since collapse may happen at an later time, some pages may already fault
> >>>> in. To handle these pages properly, it is necessary to prepare the pmd
> >>>> before collapsing. prepare_pmd_for_collapse() is introduced to prepare
> >>>> the pmd by removing rmap, adjusting refcount and mm_counter.
> >>>> 
> >>>> prepare_pmd_for_collapse() also double checks whether all ptes in this
> >>>> pmd are mapping to the same THP. This is necessary because some subpage
> >>>> of the THP may be replaced, for example by uprobe. In such cases, it
> >>>> is not possible to collapse the pmd, so we fall back.
> >>>> 
> >>>> Signed-off-by: Song Liu <songliubraving@fb.com>
> >>>> ---
> >>>> include/linux/pagemap.h |  1 +
> >>>> mm/khugepaged.c         | 69 +++++++++++++++++++++++++++++++++++------
> >>>> 2 files changed, 60 insertions(+), 10 deletions(-)
> >>>> 
> >>>> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> >>>> index 9ec3544baee2..eac881de2a46 100644
> >>>> --- a/include/linux/pagemap.h
> >>>> +++ b/include/linux/pagemap.h
> >>>> @@ -29,6 +29,7 @@ enum mapping_flags {
> >>>> 	AS_EXITING	= 4, 	/* final truncate in progress */
> >>>> 	/* writeback related tags are not used */
> >>>> 	AS_NO_WRITEBACK_TAGS = 5,
> >>>> +	AS_COLLAPSE_PMD = 6,	/* try collapse pmd for THP */
> >>>> };
> >>>> 
> >>>> /**
> >>>> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> >>>> index a4f90a1b06f5..9b980327fd9b 100644
> >>>> --- a/mm/khugepaged.c
> >>>> +++ b/mm/khugepaged.c
> >>>> @@ -1254,7 +1254,47 @@ static void collect_mm_slot(struct mm_slot *mm_slot)
> >>>> }
> >>>> 
> >>>> #if defined(CONFIG_SHMEM) && defined(CONFIG_TRANSPARENT_HUGE_PAGECACHE)
> >>>> -static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff)
> >>>> +
> >>>> +/* return whether the pmd is ready for collapse */
> >>>> +bool prepare_pmd_for_collapse(struct vm_area_struct *vma, pgoff_t pgoff,
> >>>> +			      struct page *hpage, pmd_t *pmd)
> >>>> +{
> >>>> +	unsigned long haddr = page_address_in_vma(hpage, vma);
> >>>> +	unsigned long addr;
> >>>> +	int i, count = 0;
> >>>> +
> >>>> +	/* step 1: check all mapped PTEs are to this huge page */
> >>>> +	for (i = 0, addr = haddr; i < HPAGE_PMD_NR; i++, addr += PAGE_SIZE) {
> >>>> +		pte_t *pte = pte_offset_map(pmd, addr);
> >>>> +
> >>>> +		if (pte_none(*pte))
> >>>> +			continue;
> >>>> +
> >>>> +		if (hpage + i != vm_normal_page(vma, addr, *pte))
> >>>> +			return false;
> >>>> +		count++;
> >>>> +	}
> >>>> +
> >>>> +	/* step 2: adjust rmap */
> >>>> +	for (i = 0, addr = haddr; i < HPAGE_PMD_NR; i++, addr += PAGE_SIZE) {
> >>>> +		pte_t *pte = pte_offset_map(pmd, addr);
> >>>> +		struct page *page;
> >>>> +
> >>>> +		if (pte_none(*pte))
> >>>> +			continue;
> >>>> +		page = vm_normal_page(vma, addr, *pte);
> >>>> +		page_remove_rmap(page, false);
> >>>> +	}
> >>>> +
> >>>> +	/* step 3: set proper refcount and mm_counters. */
> >>>> +	page_ref_sub(hpage, count);
> >>>> +	add_mm_counter(vma->vm_mm, mm_counter_file(hpage), -count);
> >>>> +	return true;
> >>>> +}
> >>>> +
> >>>> +extern pid_t sysctl_dump_pt_pid;
> >>>> +static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff,
> >>>> +				struct page *hpage)
> >>>> {
> >>>> 	struct vm_area_struct *vma;
> >>>> 	unsigned long addr;
> >>>> @@ -1273,21 +1313,21 @@ static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff)
> >>>> 		pmd = mm_find_pmd(vma->vm_mm, addr);
> >>>> 		if (!pmd)
> >>>> 			continue;
> >>>> -		/*
> >>>> -		 * We need exclusive mmap_sem to retract page table.
> >>>> -		 * If trylock fails we would end up with pte-mapped THP after
> >>>> -		 * re-fault. Not ideal, but it's more important to not disturb
> >>>> -		 * the system too much.
> >>>> -		 */
> >>>> 		if (down_write_trylock(&vma->vm_mm->mmap_sem)) {
> >>>> 			spinlock_t *ptl = pmd_lock(vma->vm_mm, pmd);
> >>>> -			/* assume page table is clear */
> >>>> +
> >>>> +			if (!prepare_pmd_for_collapse(vma, pgoff, hpage, pmd)) {
> >>>> +				spin_unlock(ptl);
> >>>> +				up_write(&vma->vm_mm->mmap_sem);
> >>>> +				continue;
> >>>> +			}
> >>>> 			_pmd = pmdp_collapse_flush(vma, addr, pmd);
> >>>> 			spin_unlock(ptl);
> >>>> 			up_write(&vma->vm_mm->mmap_sem);
> >>>> 			mm_dec_nr_ptes(vma->vm_mm);
> >>>> 			pte_free(vma->vm_mm, pmd_pgtable(_pmd));
> >>>> -		}
> >>>> +		} else
> >>>> +			set_bit(AS_COLLAPSE_PMD, &mapping->flags);
> >>>> 	}
> >>>> 	i_mmap_unlock_write(mapping);
> >>>> }
> >>>> @@ -1561,7 +1601,7 @@ static void collapse_file(struct mm_struct *mm,
> >>>> 		/*
> >>>> 		 * Remove pte page tables, so we can re-fault the page as huge.
> >>>> 		 */
> >>>> -		retract_page_tables(mapping, start);
> >>>> +		retract_page_tables(mapping, start, new_page);
> >>>> 		*hpage = NULL;
> >>>> 
> >>>> 		khugepaged_pages_collapsed++;
> >>>> @@ -1622,6 +1662,7 @@ static void khugepaged_scan_file(struct mm_struct *mm,
> >>>> 	int present, swap;
> >>>> 	int node = NUMA_NO_NODE;
> >>>> 	int result = SCAN_SUCCEED;
> >>>> +	bool collapse_pmd = false;
> >>>> 
> >>>> 	present = 0;
> >>>> 	swap = 0;
> >>>> @@ -1640,6 +1681,14 @@ static void khugepaged_scan_file(struct mm_struct *mm,
> >>>> 		}
> >>>> 
> >>>> 		if (PageTransCompound(page)) {
> >>>> +			if (collapse_pmd ||
> >>>> +			    test_and_clear_bit(AS_COLLAPSE_PMD,
> >>>> +					       &mapping->flags)) {
> >>> 
> >>> Who said it's the only PMD range that's subject to collapse? The bit has
> >>> to be per-PMD, not per-mapping.
> >> 
> >> I didn't assume this is the only PMD range that subject to collapse. 
> >> So once we found AS_COLLAPSE_PMD, it will continue scan the whole mapping:
> >> retract_page_tables(), then continue. 
> > 
> > I still don't get it.
> > 
> > Assume we have two ranges that subject to collapse. khugepaged_scan_file()
> > sees and clears AS_COLLAPSE_PMD. Tries to collapse the first range, fails
> > and set the bit again. khugepaged_scan_file() sees the second range,
> > clears the bit, but this time collapse is successful: the bit is still not
> > set, but it should be.
> 
> Yeah, you are right. Current logic only covers multiple THPs within single
> call of khugepaged_scan_file(). I missed the case you just described. 
> 
> What do you think about the first 4 patches of set and the other set? If 
> these patches look good, how about we get them in first? I will work on 
> proper fix (or re-design) for 5/6 and 6/6 in the meanwhile. 

You can use

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

for the first 4 patches.

-- 
 Kirill A. Shutemov

