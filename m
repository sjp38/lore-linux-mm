Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id DCBB86B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 10:19:08 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 56so536129wrx.5
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 07:19:08 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id o19si176743wro.99.2017.06.14.07.19.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 07:19:07 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5EEDnNK052932
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 10:19:06 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2b35c7wqc4-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 10:19:05 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Wed, 14 Jun 2017 15:19:02 +0100
Date: Wed, 14 Jun 2017 16:18:57 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH 3/3] mm, thp: Do not loose dirty bit in
 __split_huge_pmd_locked()
In-Reply-To: <20170614135143.25068-4-kirill.shutemov@linux.intel.com>
References: <20170614135143.25068-1-kirill.shutemov@linux.intel.com>
	<20170614135143.25068-4-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Message-Id: <20170614161857.69d54338@mschwideX1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Ralf Baechle <ralf@linux-mips.org>, "David S.
 Miller" <davem@davemloft.net>, Heiko Carstens <heiko.carstens@de.ibm.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 14 Jun 2017 16:51:43 +0300
"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> Until pmdp_invalidate() pmd entry is present and CPU can update it,
> setting dirty. Currently, we tranfer dirty bit to page too early and
> there is window when we can miss dirty bit.
> 
> Let's call SetPageDirty() after pmdp_invalidate().
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ...
> @@ -2046,6 +2043,14 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>  	 * pmd_populate.
>  	 */
>  	pmdp_invalidate(vma, haddr, pmd);
> +
> +	/*
> +	 * Transfer dirty bit to page after pmd invalidated, so CPU would not
> +	 * be able to set it under us.
> +	 */
> +	if (pmd_dirty(*pmd))
> +		SetPageDirty(page);
> +
>  	pmd_populate(mm, pmd, pgtable);
> 
>  	if (freeze) {

That won't work on s390. After pmdp_invalidate the pmd entry is gone,
it has been replaced with _SEGMENT_ENTRY_EMPTY. This includes the
dirty and referenced bits. The old scheme is

        entry = *pmd;
        pmdp_invalidate(vma, addr, pmd);
	if (pmd_dirty(entry))
		...

Could we change pmdp_invalidate to make it return the old pmd entry?
The pmdp_xchg_direct function already returns it, for s390 that would
be an easy change. The above code snippet would change like this:

	entry = pmdp_invalidate(vma, addr, pmd);
	if (pmd_dirty(entry))
		...

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
