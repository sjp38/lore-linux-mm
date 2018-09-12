Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 36D4C8E0003
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 06:33:15 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id d10-v6so1361063wrw.6
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 03:33:15 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b198-v6sor739896wme.27.2018.09.12.03.33.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Sep 2018 03:33:13 -0700 (PDT)
Date: Wed, 12 Sep 2018 13:33:11 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v2] mm: mprotect: check page dirty when change ptes
Message-ID: <20180912103311.iwytyuk4lgckad5a@kshutemo-mobl1>
References: <20180912064921.31015-1-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180912064921.31015-1-peterx@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Xu <peterx@redhat.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Khalid Aziz <khalid.aziz@oracle.com>, Thomas Gleixner <tglx@linutronix.de>, "David S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andi Kleen <ak@linux.intel.com>, Henry Willard <henry.willard@oracle.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Zi Yan <zi.yan@cs.rutgers.edu>, linux-mm@kvack.org

On Wed, Sep 12, 2018 at 02:49:21PM +0800, Peter Xu wrote:
> Add an extra check on page dirty bit in change_pte_range() since there
> might be case where PTE dirty bit is unset but it's actually dirtied.
> One example is when a huge PMD is splitted after written: the dirty bit
> will be set on the compound page however we won't have the dirty bit set
> on each of the small page PTEs.
> 
> I noticed this when debugging with a customized kernel that implemented
> userfaultfd write-protect.  In that case, the dirty bit will be critical
> since that's required for userspace to handle the write protect page
> fault (otherwise it'll get a SIGBUS with a loop of page faults).
> However it should still be good even for upstream Linux to cover more
> scenarios where we shouldn't need to do extra page faults on the small
> pages if the previous huge page is already written, so the dirty bit
> optimization path underneath can cover more.
> 
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: Mel Gorman <mgorman@techsingularity.net>
> CC: Khalid Aziz <khalid.aziz@oracle.com>
> CC: Thomas Gleixner <tglx@linutronix.de>
> CC: "David S. Miller" <davem@davemloft.net>
> CC: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> CC: Andi Kleen <ak@linux.intel.com>
> CC: Henry Willard <henry.willard@oracle.com>
> CC: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> CC: Andrea Arcangeli <aarcange@redhat.com>
> CC: Kirill A. Shutemov <kirill@shutemov.name>
> CC: Jerome Glisse <jglisse@redhat.com>
> CC: Zi Yan <zi.yan@cs.rutgers.edu>
> CC: linux-mm@kvack.org
> CC: linux-kernel@vger.kernel.org
> Signed-off-by: Peter Xu <peterx@redhat.com>
> ---
> v2:
> - checking the dirty bit when changing PTE entries rather than fixing up
>   the dirty bit when splitting the huge page PMD.
> - rebase to 4.19-rc3
> 
> Instead of keeping this in my local tree, I'm giving it another shot to
> see whether this could be acceptable for upstream since IMHO it should
> still benefit the upstream.  Thanks,
> ---
>  mm/mprotect.c | 11 +++++++++++
>  1 file changed, 11 insertions(+)
> 
> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index 6d331620b9e5..5fe752515161 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -115,6 +115,17 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
>  			if (preserve_write)
>  				ptent = pte_mk_savedwrite(ptent);
>  
> +                       /*
> +                        * The extra PageDirty() check will make sure
> +                        * we'll capture the dirty page even if the PTE
> +                        * dirty bit is unset.  One case is when the
> +                        * PTE is splitted from a huge PMD, in that
> +                        * case the dirty flag might only be set on the
> +                        * compound page instead of this PTE.
> +                        */
> +			if (PageDirty(pte_page(ptent)))
> +				ptent = pte_mkdirty(ptent);
> +

How do you protect against concurent clearing of PG_dirty?

You can end up with unaccounted dirty page.

NAK.

-- 
 Kirill A. Shutemov
