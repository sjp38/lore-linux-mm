Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id C786A6B0071
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 11:18:34 -0400 (EDT)
Received: by wibgn9 with SMTP id gn9so90146809wib.1
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 08:18:34 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id x1si11108456wif.79.2015.03.26.08.18.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Mar 2015 08:18:33 -0700 (PDT)
Date: Thu, 26 Mar 2015 11:18:30 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 07/12] mm: page_alloc: inline should_alloc_retry()
Message-ID: <20150326151830.GD23973@cmpxchg.org>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
 <1427264236-17249-8-git-send-email-hannes@cmpxchg.org>
 <20150326141128.GL15257@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150326141128.GL15257@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>

On Thu, Mar 26, 2015 at 03:11:28PM +0100, Michal Hocko wrote:
> On Wed 25-03-15 02:17:11, Johannes Weiner wrote:
> > The should_alloc_retry() function was meant to encapsulate retry
> > conditions of the allocator slowpath, but there are still checks
> > remaining in the main function, and much of how the retrying is
> > performed also depends on the OOM killer progress.  The physical
> > separation of those conditions make the code hard to follow.
> > 
> > Inline the should_alloc_retry() checks.  Notes:
> > 
> > - The __GFP_NOFAIL check is already done in __alloc_pages_may_oom(),
> >   replace it with looping on OOM killer progress
> > 
> > - The pm_suspended_storage() check is meant to skip the OOM killer
> >   when reclaim has no IO available, move to __alloc_pages_may_oom()
> > 
> > - The order < PAGE_ALLOC_COSTLY order is re-united with its original
> >   counterpart of checking whether reclaim actually made any progress
> 
> it should be order <= PAGE_ALLOC_COSTLY

Oops, thanks for catching that.  I'll fix it in v2.

> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> The resulting code looks much better and logical.
> 
> After the COSTLY check is fixed.
> Acked-by: Michal Hocko <mhocko@suse.cz>

Thank you

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
