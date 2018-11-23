Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 87B3F6B3159
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 10:21:39 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id n32-v6so5836227edc.17
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 07:21:39 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k21-v6si9181371ejp.31.2018.11.23.07.21.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 07:21:37 -0800 (PST)
Date: Fri, 23 Nov 2018 16:21:36 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 2/3] mm, thp, proc: report THP eligibility for each
 vma
Message-ID: <20181123152136.GA5827@dhcp22.suse.cz>
References: <20181120103515.25280-1-mhocko@kernel.org>
 <20181120103515.25280-3-mhocko@kernel.org>
 <73b55240-d36c-cf97-d7fd-85e2ae1e9309@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <73b55240-d36c-cf97-d7fd-85e2ae1e9309@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-api@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Alexey Dobriyan <adobriyan@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri 23-11-18 16:07:06, Vlastimil Babka wrote:
> On 11/20/18 11:35 AM, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > Userspace falls short when trying to find out whether a specific memory
> > range is eligible for THP. There are usecases that would like to know
> > that
> > http://lkml.kernel.org/r/alpine.DEB.2.21.1809251248450.50347@chino.kir.corp.google.com
> > : This is used to identify heap mappings that should be able to fault thp
> > : but do not, and they normally point to a low-on-memory or fragmentation
> > : issue.
> > 
> > The only way to deduce this now is to query for hg resp. nh flags and
> > confronting the state with the global setting. Except that there is
> > also PR_SET_THP_DISABLE that might change the picture. So the final
> > logic is not trivial. Moreover the eligibility of the vma depends on
> > the type of VMA as well. In the past we have supported only anononymous
> > memory VMAs but things have changed and shmem based vmas are supported
> > as well these days and the query logic gets even more complicated
> > because the eligibility depends on the mount option and another global
> > configuration knob.
> > 
> > Simplify the current state and report the THP eligibility in
> > /proc/<pid>/smaps for each existing vma. Reuse transparent_hugepage_enabled
> > for this purpose. The original implementation of this function assumes
> > that the caller knows that the vma itself is supported for THP so make
> > the core checks into __transparent_hugepage_enabled and use it for
> > existing callers. __show_smap just use the new transparent_hugepage_enabled
> > which also checks the vma support status (please note that this one has
> > to be out of line due to include dependency issues).
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> Not thrilled by this,

Any specific concern?

> but kernel is always better suited to report this,
> than userspace piecing it together from multiple sources, relying on
> possibly outdated knowledge of kernel implementation details...

yep.

> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks!

> A nitpick:
> 
> > ---
> >  Documentation/filesystems/proc.txt |  3 +++
> >  fs/proc/task_mmu.c                 |  2 ++
> >  include/linux/huge_mm.h            | 13 ++++++++++++-
> >  mm/huge_memory.c                   | 12 +++++++++++-
> >  mm/memory.c                        |  4 ++--
> >  5 files changed, 30 insertions(+), 4 deletions(-)
> > 
> > diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
> > index b1fda309f067..06562bab509a 100644
> > --- a/Documentation/filesystems/proc.txt
> > +++ b/Documentation/filesystems/proc.txt
> > @@ -425,6 +425,7 @@ SwapPss:               0 kB
> >  KernelPageSize:        4 kB
> >  MMUPageSize:           4 kB
> >  Locked:                0 kB
> > +THPeligible:           0
> 
> I would use THP_Eligible. There are already fields with underscore in smaps.

I do not feel strongly. I will wait for more comments and see whether
there is some consensus.

-- 
Michal Hocko
SUSE Labs
