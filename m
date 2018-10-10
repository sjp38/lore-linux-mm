Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8B81D6B0005
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 17:19:27 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id n23-v6so5995289pfk.23
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 14:19:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m8-v6sor18813965pfj.14.2018.10.10.14.19.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Oct 2018 14:19:26 -0700 (PDT)
Date: Wed, 10 Oct 2018 14:19:24 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] mm: thp:  relax __GFP_THISNODE for MADV_HUGEPAGE
 mappings
In-Reply-To: <20181009230352.GE9307@redhat.com>
Message-ID: <alpine.DEB.2.21.1810101410530.53455@chino.kir.corp.google.com>
References: <20180925120326.24392-2-mhocko@kernel.org> <alpine.DEB.2.21.1810041302330.16935@chino.kir.corp.google.com> <20181005073854.GB6931@suse.de> <alpine.DEB.2.21.1810051320270.202739@chino.kir.corp.google.com> <20181005232155.GA2298@redhat.com>
 <alpine.DEB.2.21.1810081303060.221006@chino.kir.corp.google.com> <20181009094825.GC6931@suse.de> <20181009122745.GN8528@dhcp22.suse.cz> <20181009130034.GD6931@suse.de> <20181009142510.GU8528@dhcp22.suse.cz> <20181009230352.GE9307@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stable tree <stable@vger.kernel.org>

On Tue, 9 Oct 2018, Andrea Arcangeli wrote:

> I think "madvise vs mbind" is more an issue of "no-permission vs
> permission" required. And if the processes ends up swapping out all
> other process with their memory already allocated in the node, I think
> some permission is correct to be required, in which case an mbind
> looks a better fit. MPOL_PREFERRED also looks a first candidate for
> investigation as it's already not black and white and allows spillover
> and may already do the right thing in fact if set on top of
> MADV_HUGEPAGE.
> 

We would never want to thrash the local node for hugepages because there 
is no guarantee that any swapping is useful.  On COMPACT_SKIPPED due to 
low memory, we have very clear evidence that pageblocks are already 
sufficiently fragmented by unmovable pages such that compaction itself, 
even with abundant free memory, fails to free an entire pageblock due to 
the allocator's preference to fragment pageblocks of fallback migratetypes 
over returning remote free memory.

As I've stated, we do not want to reclaim pointlessly when compaction is 
unable to access the freed memory or there is no guarantee it can free an 
entire pageblock.  Doing so allows thrashing of the local node, or remote 
nodes if __GFP_THISNODE is removed, and the hugepage still cannot be 
allocated.  If this proposed mbind() that requires permissions is geared 
to me as the user, I'm afraid the details of what leads to the thrashing 
are not well understood because I certainly would never use this.
