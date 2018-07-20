Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id B3E2D6B000D
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 08:29:12 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id az8-v6so7284095plb.15
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 05:29:12 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e8-v6sor562025plk.26.2018.07.20.05.29.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Jul 2018 05:29:11 -0700 (PDT)
Date: Fri, 20 Jul 2018 15:29:07 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv5 06/19] mm/khugepaged: Handle encrypted pages
Message-ID: <20180720122907.xsxihg56ambynwk2@kshutemo-mobl1>
References: <20180717112029.42378-1-kirill.shutemov@linux.intel.com>
 <20180717112029.42378-7-kirill.shutemov@linux.intel.com>
 <ad4c704f-fdda-7e75-60ec-3fbc8a4bb0ba@intel.com>
 <20180719085901.ebdciqkjpx6hy4xt@kshutemo-mobl1>
 <bc6074f3-dd71-8b6f-5a1f-d3770ac4990b@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bc6074f3-dd71-8b6f-5a1f-d3770ac4990b@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jul 19, 2018 at 07:13:39AM -0700, Dave Hansen wrote:
> On 07/19/2018 01:59 AM, Kirill A. Shutemov wrote:
> > On Wed, Jul 18, 2018 at 04:11:57PM -0700, Dave Hansen wrote:
> >> On 07/17/2018 04:20 AM, Kirill A. Shutemov wrote:
> >>> khugepaged allocates page in advance, before we found a VMA for
> >>> collapse. We don't yet know which KeyID to use for the allocation.
> >>
> >> That's not really true.  We have the VMA and the address in the caller
> >> (khugepaged_scan_pmd()), but we drop the lock and have to revalidate the
> >> VMA.
> > 
> > For !NUMA we allocate the page in khugepaged_do_scan(), well before we
> > know VMA.
> 
> Ahh, thanks for clarifying.  That's some more very good information
> about the design and progression of your patch that belongs in the
> changelog.

Okay.

> >>> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> >>> index 5ae34097aed1..d116f4ebb622 100644
> >>> --- a/mm/khugepaged.c
> >>> +++ b/mm/khugepaged.c
> >>> @@ -1056,6 +1056,16 @@ static void collapse_huge_page(struct mm_struct *mm,
> >>>  	 */
> >>>  	anon_vma_unlock_write(vma->anon_vma);
> >>>  
> >>> +	/*
> >>> +	 * At this point new_page is allocated as non-encrypted.
> >>> +	 * If VMA's KeyID is non-zero, we need to prepare it to be encrypted
> >>> +	 * before coping data.
> >>> +	 */
> >>> +	if (vma_keyid(vma)) {
> >>> +		prep_encrypted_page(new_page, HPAGE_PMD_ORDER,
> >>> +				vma_keyid(vma), false);
> >>> +	}
> >>
> >> I guess this isn't horribly problematic now, but if we ever keep pools
> >> of preassigned-keyids, this won't work any more.
> > 
> > I don't get this. What pools of preassigned-keyids are you talking about?
> 
> My point was that if we ever teach the allocator or something _near_ the
> allocator to keep pools of pre-zeroed and/or pre-cache-cleared pages,
> this approach will need to get changed otherwise we will double-prep pages.

It shouldn't be a problem here. It's pretty slow path. We often wait
memory to be compacted before page for khugepaged gets allocated.
Double-prep shouldn't have visible impact.

> My overall concern with prep_encrypted_page() in this patch set is that
> it's inserted pretty ad-hoc.  It seems easy to miss spots where it
> should be.  I'm also unsure of the failure mode and anything we've done
> to ensure that if we get this wrong, we scream clearly and loudly about
> what happened.  Do we do something like that?

I have debugging patch that puts BUG_ONs around set_pte_at() to check if
the page's keyid matches VMA's keyid. But that's not very systematic.
We would need something better than this.

-- 
 Kirill A. Shutemov
