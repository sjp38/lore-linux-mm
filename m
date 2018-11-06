Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 67ED36B029D
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 19:35:16 -0500 (EST)
Received: by mail-oi1-f197.google.com with SMTP id r68-v6so7699493oie.12
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 16:35:16 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d36si10115556otd.53.2018.11.05.16.35.15
        for <linux-mm@kvack.org>;
        Mon, 05 Nov 2018 16:35:15 -0800 (PST)
Date: Tue, 6 Nov 2018 00:35:10 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH] mm/thp: Correctly differentiate between mapped THP and
 PMD migration entry
Message-ID: <20181106003509.GA27283@brain-police>
References: <1539057538-27446-1-git-send-email-anshuman.khandual@arm.com>
 <7E8E6B14-D5C4-4A30-840D-A7AB046517FB@cs.rutgers.edu>
 <84509db4-13ce-fd53-e924-cc4288d493f7@arm.com>
 <1968F276-5D96-426B-823F-38F6A51FB465@cs.rutgers.edu>
 <5e0e772c-7eef-e75c-2921-e80d4fbe8324@arm.com>
 <2398C491-E1DA-4B3C-B60A-377A09A02F1A@cs.rutgers.edu>
 <20181017020930.GN30832@redhat.com>
 <9d9aaf03-617a-d383-7d59-8b98fdd3c1e7@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9d9aaf03-617a-d383-7d59-8b98fdd3c1e7@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Zi Yan <zi.yan@cs.rutgers.edu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, mhocko@suse.com, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Fri, Nov 02, 2018 at 11:45:00AM +0530, Anshuman Khandual wrote:
> On 10/17/2018 07:39 AM, Andrea Arcangeli wrote:
> > What we need to do during split is an invalidate of the huge TLB.
> > There's no pmd_trans_splitting anymore, so we only clear the present
> > bit in the PTE despite pmd_present still returns true (just like
> > PROT_NONE, nothing new in this respect). pmd_present never meant the
> 
> On arm64, the problem is that pmd_present() is tied with pte_present() which
> checks for PTE_VALID (also PTE_PROT_NONE) but which gets cleared during PTE
> invalidation. pmd_present() returns false just after the first step of PMD
> splitting. So pmd_present() needs to be decoupled from PTE_VALID which is
> same as PMD_SECT_VALID and instead should depend upon a pte bit which sticks
> around like PAGE_PSE as in case of x86. I am working towards a solution.

Could we not just go via a PROT_NONE mapping during the split, instead of
having to allocate a new software bit to treat these invalid ptes as
present?

Will
