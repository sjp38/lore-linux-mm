Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 163EB6B0005
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 11:44:55 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id a4so38335573wme.1
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 08:44:55 -0800 (PST)
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com. [195.75.94.111])
        by mx.google.com with ESMTPS id e63si46832225wme.95.2016.02.24.08.44.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 24 Feb 2016 08:44:54 -0800 (PST)
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Wed, 24 Feb 2016 16:44:52 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 64B8A17D8042
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 16:45:10 +0000 (GMT)
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1OGimKM23658508
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 16:44:48 GMT
Received: from d06av01.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1OGilG6017673
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 09:44:48 -0700
Date: Wed, 24 Feb 2016 17:44:46 +0100
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: Re: [BUG] random kernel crashes after THP rework on s390 (maybe
 also on PowerPC and ARM)
Message-ID: <20160224174446.76095849@thinkpad>
In-Reply-To: <20160223193345.GC21820@node.shutemov.name>
References: <20160211192223.4b517057@thinkpad>
	<20160211190942.GA10244@node.shutemov.name>
	<20160211205702.24f0d17a@thinkpad>
	<20160212154116.GA15142@node.shutemov.name>
	<56BE00E7.1010303@de.ibm.com>
	<20160212181640.4eabb85f@thinkpad>
	<20160223103221.GA1418@node.shutemov.name>
	<20160223191907.25719a4d@thinkpad>
	<20160223193345.GC21820@node.shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>

On Tue, 23 Feb 2016 22:33:45 +0300
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Tue, Feb 23, 2016 at 07:19:07PM +0100, Gerald Schaefer wrote:
> > I'll check with Martin, maybe it is actually trivial, then we can
> > do a quick test it to rule that one out.
> 
> Oh. I found a bug in __split_huge_pmd_locked(). Although, not sure if it's
> _the_ bug.
> 
> pmdp_invalidate() is called for the wrong address :-/
> I guess that can be destructive on the architecture, right?

Thanks, that's it! We can no longer reproduce the crashes and calling
pmdp_invalidate() with a wrong address also perfectly explains the
memory corruption that I found in several dumps: 0x020 was ORed into
pte entries, which didn't make sense, and caused the list corruption
for example. 0x020 it is the invalid bit for pmd entries on s390 and
thus can be explained by this bug when a pte table lies before a pmd
table in memory.

> 
> Could you check this?
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 1c317b85ea7d..4246bc70e55a 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2865,7 +2865,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>  	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
>  	pmd_populate(mm, &_pmd, pgtable);
> 
> -	for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
> +	for (i = 0; i < HPAGE_PMD_NR; i++) {
>  		pte_t entry, *pte;
>  		/*
>  		 * Note that NUMA hinting access restrictions are not
> @@ -2886,9 +2886,9 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>  		}
>  		if (dirty)
>  			SetPageDirty(page + i);
> -		pte = pte_offset_map(&_pmd, haddr);
> +		pte = pte_offset_map(&_pmd, haddr + i * PAGE_SIZE);
>  		BUG_ON(!pte_none(*pte));
> -		set_pte_at(mm, haddr, pte, entry);
> +		set_pte_at(mm, haddr + i * PAGE_SIZE, pte, entry);
>  		atomic_inc(&page[i]._mapcount);
>  		pte_unmap(pte);
>  	}
> @@ -2938,7 +2938,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>  	pmd_populate(mm, pmd, pgtable);
> 
>  	if (freeze) {
> -		for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
> +		for (i = 0; i < HPAGE_PMD_NR; i++) {
>  			page_remove_rmap(page + i, false);
>  			put_page(page + i);
>  		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
