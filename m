Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1BBBB6B007E
	for <linux-mm@kvack.org>; Sat, 18 Jun 2016 15:09:58 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id nq2so11836844lbc.3
        for <linux-mm@kvack.org>; Sat, 18 Jun 2016 12:09:58 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id ip4si19326386wjb.126.2016.06.18.12.09.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 18 Jun 2016 12:09:56 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id r201so5061868wme.0
        for <linux-mm@kvack.org>; Sat, 18 Jun 2016 12:09:56 -0700 (PDT)
Date: Sat, 18 Jun 2016 22:09:51 +0300
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: Re: [PATCHv9-rebased2 01/37] mm, thp: make swapin readahead under
 down_read of mmap_sem
Message-ID: <20160618190951.GA11151@debian>
References: <04f701d1c797$1ebe6b80$5c3b4280$@alibaba-inc.com>
 <04f801d1c79b$b46744a0$1d35cde0$@alibaba-inc.com>
 <20160616100854.GB18137@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160616100854.GB18137@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jun 16, 2016 at 01:08:54PM +0300, Kirill A. Shutemov wrote:
> On Thu, Jun 16, 2016 at 02:52:52PM +0800, Hillf Danton wrote:
> > > 
> > > From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
> > > 
> > > Currently khugepaged makes swapin readahead under down_write.  This patch
> > > supplies to make swapin readahead under down_read instead of down_write.
> > > 
> > > The patch was tested with a test program that allocates 800MB of memory,
> > > writes to it, and then sleeps.  The system was forced to swap out all.
> > > Afterwards, the test program touches the area by writing, it skips a page
> > > in each 20 pages of the area.
> > > 
> > > Link: http://lkml.kernel.org/r/1464335964-6510-4-git-send-email-ebru.akagunduz@gmail.com
> > > Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
> > > Cc: Hugh Dickins <hughd@google.com>
> > > Cc: Rik van Riel <riel@redhat.com>
> > > Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > > Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > > Cc: Andrea Arcangeli <aarcange@redhat.com>
> > > Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > > Cc: Cyrill Gorcunov <gorcunov@openvz.org>
> > > Cc: Mel Gorman <mgorman@suse.de>
> > > Cc: David Rientjes <rientjes@google.com>
> > > Cc: Vlastimil Babka <vbabka@suse.cz>
> > > Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> > > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > > Cc: Michal Hocko <mhocko@suse.cz>
> > > Cc: Minchan Kim <minchan.kim@gmail.com>
> > > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > > ---
> > >  mm/huge_memory.c | 92 ++++++++++++++++++++++++++++++++++++++------------------
> > >  1 file changed, 63 insertions(+), 29 deletions(-)
> > > 
> > > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > > index f2bc57c45d2f..96dfe3f09bf6 100644
> > > --- a/mm/huge_memory.c
> > > +++ b/mm/huge_memory.c
> > > @@ -2378,6 +2378,35 @@ static bool hugepage_vma_check(struct vm_area_struct *vma)
> > >  }
> > > 
> > >  /*
> > > + * If mmap_sem temporarily dropped, revalidate vma
> > > + * before taking mmap_sem.
> > 
> > See below
> 
> > > @@ -2401,11 +2430,18 @@ static void __collapse_huge_page_swapin(struct mm_struct *mm,
> > >  			continue;
> > >  		swapped_in++;
> > >  		ret = do_swap_page(mm, vma, _address, pte, pmd,
> > > -				   FAULT_FLAG_ALLOW_RETRY|FAULT_FLAG_RETRY_NOWAIT,
> > > +				   FAULT_FLAG_ALLOW_RETRY,
> > 
> > Add a description in change log for it please.
> 
> Ebru, would you address it?
> 
This changelog really seems poor.
Is there a way to update only changelog of the commit?
I tried to use git rebase to amend commit, however
I could not rebase. This patch only needs better changelog.

I would like to update it as follows, if you would like to too:

"
Currently khugepaged makes swapin readahead under down_write.  This patch
supplies to make swapin readahead under down_read instead of down_write.

Along swapin, we can need to drop and re-take mmap_sem. Therefore we
have to be sure vma is consistent. This patch adds a helper function
to validate vma and also supplies that async swapin should not be
performed without waiting.

The patch was tested with a test program that allocates 800MB of memory,
writes to it, and then sleeps.  The system was forced to swap out all.
Afterwards, the test program touches the area by writing, it skips a page
in each 20 pages of the area.
"

Could you please suggest me a way to replace above changelog with the old?

> > >  				   pteval);
> > > +		/* do_swap_page returns VM_FAULT_RETRY with released mmap_sem */
> > > +		if (ret & VM_FAULT_RETRY) {
> > > +			down_read(&mm->mmap_sem);
> > > +			/* vma is no longer available, don't continue to swapin */
> > > +			if (hugepage_vma_revalidate(mm, vma, address))
> > > +				return false;
> > 
> > Revalidate vma _after_ acquiring mmap_sem, but the above comment says _before_.
> 
> Ditto.
> 
> > > +	if (!__collapse_huge_page_swapin(mm, vma, address, pmd)) {
> > > +		up_read(&mm->mmap_sem);
> > > +		goto out;
> > 
> > Jump out with mmap_sem released, 
> > 
> > > +	result = hugepage_vma_revalidate(mm, vma, address);
> > > +	if (result)
> > > +		goto out;
> > 
> > but jump out again with mmap_sem held.
> > 
> > They are cleaned up in subsequent darns?
> 
Yes, that is reported and fixed here:
http://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/commit/?id=fc7038a69cee6b817261f7cd805e9663fdc1075c

However, the above comment inconsistency still there.
I've added a fix patch:
