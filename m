Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 537836B0012
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 10:48:30 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id p189so3240854qkc.5
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 07:48:30 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id o1si5595022qkl.119.2018.03.21.07.48.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 07:48:29 -0700 (PDT)
Date: Wed, 21 Mar 2018 10:48:27 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 10/15] mm/hmm: do not differentiate between empty entry
 or missing directory v2
Message-ID: <20180321144826.GA3214@redhat.com>
References: <20180320020038.3360-1-jglisse@redhat.com>
 <20180320020038.3360-11-jglisse@redhat.com>
 <4b0da5bb-4e44-798c-f4dd-cabc93cfeb99@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <4b0da5bb-4e44-798c-f4dd-cabc93cfeb99@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>

On Tue, Mar 20, 2018 at 10:24:34PM -0700, John Hubbard wrote:
> On 03/19/2018 07:00 PM, jglisse@redhat.com wrote:
> > From: Jerome Glisse <jglisse@redhat.com>
> > 
> > There is no point in differentiating between a range for which there
> > is not even a directory (and thus entries) and empty entry (pte_none()
> > or pmd_none() returns true).
> > 
> > Simply drop the distinction ie remove HMM_PFN_EMPTY flag and merge now
> > duplicate hmm_vma_walk_hole() and hmm_vma_walk_clear() functions.
> > 
> > Changed since v1:
> >   - Improved comments
> > 
> > Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> > Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
> > Cc: Ralph Campbell <rcampbell@nvidia.com>
> > Cc: Mark Hairgrove <mhairgrove@nvidia.com>
> > Cc: John Hubbard <jhubbard@nvidia.com>
> > ---
> >  include/linux/hmm.h |  8 +++-----
> >  mm/hmm.c            | 45 +++++++++++++++------------------------------
> >  2 files changed, 18 insertions(+), 35 deletions(-)
> > 
> > diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> > index 54d684fe3b90..cf283db22106 100644
> > --- a/include/linux/hmm.h
> > +++ b/include/linux/hmm.h
> > @@ -84,7 +84,6 @@ struct hmm;
> >   * HMM_PFN_VALID: pfn is valid. It has, at least, read permission.
> >   * HMM_PFN_WRITE: CPU page table has write permission set
> >   * HMM_PFN_ERROR: corresponding CPU page table entry points to poisoned memory
> > - * HMM_PFN_EMPTY: corresponding CPU page table entry is pte_none()
> >   * HMM_PFN_SPECIAL: corresponding CPU page table entry is special; i.e., the
> >   *      result of vm_insert_pfn() or vm_insert_page(). Therefore, it should not
> >   *      be mirrored by a device, because the entry will never have HMM_PFN_VALID
> > @@ -94,10 +93,9 @@ struct hmm;
> >  #define HMM_PFN_VALID (1 << 0)
> >  #define HMM_PFN_WRITE (1 << 1)
> >  #define HMM_PFN_ERROR (1 << 2)
> > -#define HMM_PFN_EMPTY (1 << 3)
> 
> Hi Jerome,
> 
> Nearly done with this one...see below for a bit more detail, but I think if we did this:
> 
>     #define HMM_PFN_EMPTY (0)
> 
> ...it would work out nicely.
> 
> > -#define HMM_PFN_SPECIAL (1 << 4)
> > -#define HMM_PFN_DEVICE_UNADDRESSABLE (1 << 5)
> > -#define HMM_PFN_SHIFT 6
> > +#define HMM_PFN_SPECIAL (1 << 3)
> > +#define HMM_PFN_DEVICE_UNADDRESSABLE (1 << 4)
> > +#define HMM_PFN_SHIFT 5
> >  
> 
> <snip>
> 
> > @@ -438,7 +423,7 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
> >  		pfns[i] = 0;
> >  
> >  		if (pte_none(pte)) {
> > -			pfns[i] = HMM_PFN_EMPTY;
> > +			pfns[i] = 0;
> 
> This works, but why not keep HMM_PFN_EMPTY, and just define it as zero?
> Symbols are better than raw numbers here.
> 

The last patch do that so i don't think it is worth respinning
just to make this intermediate state prettier.

Cheers,
Jerome
