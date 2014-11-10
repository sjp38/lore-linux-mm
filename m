Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7B9DA280012
	for <linux-mm@kvack.org>; Mon, 10 Nov 2014 11:22:50 -0500 (EST)
Received: by mail-wg0-f51.google.com with SMTP id l18so9194586wgh.38
        for <linux-mm@kvack.org>; Mon, 10 Nov 2014 08:22:49 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s13si17648224wiv.4.2014.11.10.08.22.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 10 Nov 2014 08:22:49 -0800 (PST)
Date: Mon, 10 Nov 2014 16:22:45 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 10/10] mm/hugetlb: share the i_mmap_rwsem
Message-ID: <20141110162245.GZ21422@suse.de>
References: <1414697657-1678-1-git-send-email-dave@stgolabs.net>
 <1414697657-1678-11-git-send-email-dave@stgolabs.net>
 <alpine.LSU.2.11.1411032208390.15596@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1411032208390.15596@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Davidlohr Bueso <dave@stgolabs.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.cz>, akpm@linux-foundation.org, riel@redhat.com, peterz@infradead.org, mingo@kernel.org, linux-kernel@vger.kernel.org, dbueso@suse.de, linux-mm@kvack.org

On Mon, Nov 03, 2014 at 10:35:04PM -0800, Hugh Dickins wrote:
> On Thu, 30 Oct 2014, Davidlohr Bueso wrote:
> 
> > The i_mmap_rwsem protects shared pages against races
> > when doing the sharing and unsharing, ultimately
> > calling huge_pmd_share/unshare() for PMD pages --
> > it also needs it to avoid races when populating the pud
> > for pmd allocation when looking for a shareable pmd page
> > for hugetlb. Ultimately the interval tree remains intact.
> > 
> > Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
> > Acked-by: Kirill A. Shutemov <kirill.shutemov@intel.linux.com>
>                                                 linux.intel.com
> 
> I'm uncomfortable with this one: I'm certainly not prepared to Ack it;
> but that could easily be that I'm just not thinking hard enough - I'd
> rather leave the heavy thinking to someone else!
> 
> The fs/hugetlbfs/inode.c part of it should be okay, but the rest is
> iffy.  It gets into huge page table sharing territory, which is very
> tricky and surprising territory indeed (take a look at my
> __unmap_hugepage_range_final() comment, for one example).
> 
> You're right that the interval tree remains intact, but I've a feeling
> we end up using i_mmap_mutex for more exclusion than just that (rather
> like how huge_memory.c finds anon_vma lock useful for other exclusions).
> 
> I think Mel (already Cc'ed) and Michal (adding him) both have past
> experience with the shared page table (as do I, but I'm in denial).
> 

I dealt with it far in the past when it was still buried under arch/x86
and it was a whole pile of no fun. In this case I think there is little or
no value in trying to convert the lock for page table sharing. The benefit
is marginal (database initialisation maybe) while the potential for
surprises is high.

The __unmap_hugepage_range_final() concern is valid. If this is converted to
read then I am fairly sure that the bug fixed by commit d833352a4338 ("mm:
hugetlbfs: close race during teardown of hugetlbfs shared page tables")
gets reintroduced. We also potentially see races between huge_pmd_unshare
ref counting and huge_pmd_share as huge_pmd_unshare does a race-prone
check on refcount if it's not serialised by i_mmap_lock_write. On a rance,
it will leak pages which will be hard to detect.

Considering the upside of this particular conversion, I don't think it's
worth the loss of hair or will to live to try fix it up.

> I wonder if the huge shared page table would be a good next target
> for Kirill's removal of mm nastiness.  (Removing it wouldn't hurt
> Google for one: we have it "#if 0"ed out, though I forget why at
> this moment.)
> 

I think the only benefit was reducing TLB pressure on databases with
very large shared memory before 1G pages existed and when 2M TLB entries
were a very limited resource. I doubt it's been quantified on anything
resembling recent hardware. If it did get killed though, it would need a
spin through a database test that used the particular database software
that benefitted.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
