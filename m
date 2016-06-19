Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id ED2C06B0253
	for <linux-mm@kvack.org>; Sun, 19 Jun 2016 19:55:00 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id l5so302494715ioa.0
        for <linux-mm@kvack.org>; Sun, 19 Jun 2016 16:55:00 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id g27si29318860pfa.159.2016.06.19.16.55.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Jun 2016 16:55:00 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id i123so7204040pfg.3
        for <linux-mm@kvack.org>; Sun, 19 Jun 2016 16:55:00 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Date: Mon, 20 Jun 2016 08:54:50 +0900
Subject: Re: [PATCH] MADVISE_FREE, THP: Fix madvise_free_huge_pmd return
 value after splitting
Message-ID: <20160619235450.GA3194@blaptop>
References: <1466132640-18932-1-git-send-email-ying.huang@intel.com>
 <20160617053102.GA2374@bbox>
 <87inx7lsbg.fsf@yhuang-mobile.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87inx7lsbg.fsf@yhuang-mobile.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jun 17, 2016 at 08:59:31AM -0700, Huang, Ying wrote:
> Minchan Kim <minchan@kernel.org> writes:
> 
> > Hi,
> >
> > On Thu, Jun 16, 2016 at 08:03:54PM -0700, Huang, Ying wrote:
> >> From: Huang Ying <ying.huang@intel.com>
> >> 
> >> madvise_free_huge_pmd should return 0 if the fallback PTE operations are
> >> required.  In madvise_free_huge_pmd, if part pages of THP are discarded,
> >> the THP will be split and fallback PTE operations should be used if
> >> splitting succeeds.  But the original code will make fallback PTE
> >> operations skipped, after splitting succeeds.  Fix that via make
> >> madvise_free_huge_pmd return 0 after splitting successfully, so that the
> >> fallback PTE operations will be done.
> >
> > You're right. Thanks!
> >
> >> 
> >> Know issues: if my understanding were correct, return 1 from
> >> madvise_free_huge_pmd means the following processing for the PMD should
> >> be skipped, while return 0 means the following processing is still
> >> needed.  So the function should return 0 only if the THP is split
> >> successfully or the PMD is not trans huge.  But the pmd_trans_unstable
> >> after madvise_free_huge_pmd guarantee the following processing will be
> >> skipped for huge PMD.  So current code can run properly.  But if my
> >> understanding were correct, we can clean up return code of
> >> madvise_free_huge_pmd accordingly.
> >
> > I like your clean up. Just a minor comment below.
> >
> >> 
> >> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
> >> ---
> >>  mm/huge_memory.c | 7 +------
> >>  1 file changed, 1 insertion(+), 6 deletions(-)
> >> 
> >> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> >> index 2ad52d5..64dc95d 100644
> >> --- a/mm/huge_memory.c
> >> +++ b/mm/huge_memory.c
> >
> > First of all, let's change ret from int to bool.
> > And then, add description in the function entry.
> >
> > /*
> >  * Return true if we do MADV_FREE successfully on entire pmd page.
> >  * Otherwise, return false.
> >  */
> >
> > And do not set to 1 if it is huge_zero_pmd but just goto out to
> > return false.
> 
> Do you want to fold the cleanup with this patch or do that in another
> patch?

I prefer separating cleanup and bug fix so that we can send only bug
fix patch to stable tree.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
