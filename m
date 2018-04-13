Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 869E06B0005
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 07:09:55 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k18so4722012wri.9
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 04:09:55 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y5si104324ede.235.2018.04.13.04.09.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Apr 2018 04:09:54 -0700 (PDT)
Date: Fri, 13 Apr 2018 13:09:49 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: vmalloc: Remove double execution of vunmap_page_range
Message-ID: <20180413110949.GA17670@dhcp22.suse.cz>
References: <1523611019-17679-1-git-send-email-cpandya@codeaurora.org>
 <a623e12b-bb5e-58fa-c026-de9ea53c5bd9@linux.vnet.ibm.com>
 <8da9f826-2a3d-e618-e512-4fc8d45c16f2@codeaurora.org>
 <bbef0a92-f81b-5ba8-c5c1-d8c08444955b@linux.vnet.ibm.com>
 <fa104cc6-c32a-9081-280f-2e03e4279f65@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fa104cc6-c32a-9081-280f-2e03e4279f65@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chintan Pandya <cpandya@codeaurora.org>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, vbabka@suse.cz, labbott@redhat.com, catalin.marinas@arm.com, hannes@cmpxchg.org, f.fainelli@gmail.com, xieyisheng1@huawei.com, ard.biesheuvel@linaro.org, richard.weiyang@gmail.com, byungchul.park@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 13-04-18 16:15:26, Chintan Pandya wrote:
> 
> 
> On 4/13/2018 4:10 PM, Anshuman Khandual wrote:
> > On 04/13/2018 03:47 PM, Chintan Pandya wrote:
> > > 
> > > 
> > > On 4/13/2018 3:29 PM, Anshuman Khandual wrote:
> > > > On 04/13/2018 02:46 PM, Chintan Pandya wrote:
> > > > > Unmap legs do call vunmap_page_range() irrespective of
> > > > > debug_pagealloc_enabled() is enabled or not. So, remove
> > > > > redundant check and optional vunmap_page_range() routines.
> > > > 
> > > > vunmap_page_range() tears down the page table entries and does
> > > > not really flush related TLB entries normally unless page alloc
> > > > debug is enabled where it wants to make sure no stale mapping is
> > > > still around for debug purpose. Deferring TLB flush improves
> > > > performance. This patch will force TLB flush during each page
> > > > table tear down and hence not desirable.
> > > > 
> > > Deferred TLB invalidation will surely improve performance. But force
> > > flush can help in detecting invalid access right then and there. I
> > 
> > Deferred TLB invalidation was a choice made some time ago with the
> > commit db64fe02258f1507e ("mm: rewrite vmap layer") as these vmalloc
> > mappings wont be used other than inside the kernel and TLB gets
> > flushed when they are reused. This way it can still avail the benefit
> > of deferred TLB flushing without exposing itself to invalid accesses.
> > 
> > > chose later. May be I should have clean up the vmap tear down code
> > > as well where it actually does the TLB invalidation.
> > > 
> > > Or make TLB invalidation in free_unmap_vmap_area() be dependent upon
> > > debug_pagealloc_enabled().
> > 
> > Immediate TLB invalidation needs to be dependent on debug_pagealloc_
> > enabled() and should be done only for debug purpose. Contrary to that
> > is not desirable.
> > 
> Okay. I will raise v2 for that.

More importantly. Your changelog absolutely lacks the _why_ part. It
just states what the code does which is not all that hard to read from
the diff. It is usually much more important to present _why_ the patch
is an improvement and worth merging.
-- 
Michal Hocko
SUSE Labs
