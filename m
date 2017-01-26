Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 22A326B0260
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 20:50:12 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 194so291961104pgd.7
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 17:50:12 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id v75si34957pfj.50.2017.01.25.17.50.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 17:50:11 -0800 (PST)
Date: Wed, 25 Jan 2017 17:50:06 -0800
From: Shaohua Li <shli@kernel.org>
Subject: Re: [PATCH] mm: write protect MADV_FREE pages
Message-ID: <20170126015006.2ft2vi3evkkjxw7i@kernel.org>
References: <791151284cd6941296f08488b8cb7f1968175a0a.1485212872.git.shli@fb.com>
 <20170124023212.GA24523@bbox>
 <20170125171429.5vbqizijrhav522d@kernel.org>
 <20170125230909.GA20811@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170125230909.GA20811@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@surriel.com>, Mel Gorman <mgorman@techsingularity.net>

On Thu, Jan 26, 2017 at 08:09:09AM +0900, Minchan Kim wrote:
> Hello,
> 
> On Wed, Jan 25, 2017 at 09:15:19AM -0800, Shaohua Li wrote:
> > On Tue, Jan 24, 2017 at 11:32:12AM +0900, Minchan Kim wrote:
> > > Hi Shaohua,
> > > 
> > > On Mon, Jan 23, 2017 at 03:15:52PM -0800, Shaohua Li wrote:
> > > > The page reclaim has an assumption writting to a page with clean pte
> > > > should trigger a page fault, because there is a window between pte zero
> > > > and tlb flush where a new write could come. If the new write doesn't
> > > > trigger page fault, page reclaim will not notice it and think the page
> > > > is clean and reclaim it. The MADV_FREE pages don't comply with the rule
> > > > and the pte is just cleaned without writeprotect, so there will be no
> > > > pagefault for new write. This will cause data corruption.
> > > 
> > > It's hard to understand.
> > > Could you show me exact scenario seqence you have in mind?
> > Sorry for the delay, for some reason, I didn't receive the mail.
> > in try_to_unmap_one:
> > CPU 1:						CPU2:
> > 1. pteval = ptep_get_and_clear(mm, address, pte);
> > 2.						write to the address
> > 3. tlb flush
> > 
> > step 1 will get a clean pteval, step2 dirty it, but the unmap missed the dirty
> > bit so discard the page without pageout. step2 doesn't trigger a page fault,
> 
> I thought about that when Mel introduced deferred flush and concluded it
> should be no problem from theses discussion:
>  
> 1. https://lkml.org/lkml/2015/4/15/565
> 2. https://lkml.org/lkml/2015/4/16/136
> 
> So, shouldn't it make trap?
> 
> Ccing Mel.

Ah, don't know the cpu will refetch and trigger the fault. Thanks for the
clarification.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
