Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 552E76B000C
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 04:59:09 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c13-v6so3745181pfo.14
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 01:59:09 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z3-v6sor1834435plb.82.2018.07.19.01.59.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Jul 2018 01:59:08 -0700 (PDT)
Date: Thu, 19 Jul 2018 11:59:01 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv5 06/19] mm/khugepaged: Handle encrypted pages
Message-ID: <20180719085901.ebdciqkjpx6hy4xt@kshutemo-mobl1>
References: <20180717112029.42378-1-kirill.shutemov@linux.intel.com>
 <20180717112029.42378-7-kirill.shutemov@linux.intel.com>
 <ad4c704f-fdda-7e75-60ec-3fbc8a4bb0ba@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ad4c704f-fdda-7e75-60ec-3fbc8a4bb0ba@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jul 18, 2018 at 04:11:57PM -0700, Dave Hansen wrote:
> On 07/17/2018 04:20 AM, Kirill A. Shutemov wrote:
> > khugepaged allocates page in advance, before we found a VMA for
> > collapse. We don't yet know which KeyID to use for the allocation.
> 
> That's not really true.  We have the VMA and the address in the caller
> (khugepaged_scan_pmd()), but we drop the lock and have to revalidate the
> VMA.

For !NUMA we allocate the page in khugepaged_do_scan(), well before we
know VMA.

> 
> 
> > diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> > index 5ae34097aed1..d116f4ebb622 100644
> > --- a/mm/khugepaged.c
> > +++ b/mm/khugepaged.c
> > @@ -1056,6 +1056,16 @@ static void collapse_huge_page(struct mm_struct *mm,
> >  	 */
> >  	anon_vma_unlock_write(vma->anon_vma);
> >  
> > +	/*
> > +	 * At this point new_page is allocated as non-encrypted.
> > +	 * If VMA's KeyID is non-zero, we need to prepare it to be encrypted
> > +	 * before coping data.
> > +	 */
> > +	if (vma_keyid(vma)) {
> > +		prep_encrypted_page(new_page, HPAGE_PMD_ORDER,
> > +				vma_keyid(vma), false);
> > +	}
> 
> I guess this isn't horribly problematic now, but if we ever keep pools
> of preassigned-keyids, this won't work any more.

I don't get this. What pools of preassigned-keyids are you talking about?

-- 
 Kirill A. Shutemov
