Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id B84626B0033
	for <linux-mm@kvack.org>; Tue, 11 Jun 2013 10:57:42 -0400 (EDT)
Date: Tue, 11 Jun 2013 09:57:42 -0500
From: Alex Thorlton <athorlton@sgi.com>
Subject: Re: [PATCH] Make transparent hugepages cpuset aware
Message-ID: <20130611145742.GB3411@sgi.com>
References: <1370881521-177821-1-git-send-email-athorlton@sgi.com>
 <20130611065518.3DEBCE0090@blue.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130611065518.3DEBCE0090@blue.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, linux-doc@vger.kernel.org, linux-mm@kvack.org

On Tue, Jun 11, 2013 at 09:55:18AM +0300, Kirill A. Shutemov wrote:
> Alex Thorlton wrote:
> > This patch adds the ability to control THPs on a per cpuset basis.  Please see
> > the additions to Documentation/cgroups/cpusets.txt for more information.
> > 
> > Signed-off-by: Alex Thorlton <athorlton@sgi.com>
> > Reviewed-by: Robin Holt <holt@sgi.com>
> > Cc: Li Zefan <lizefan@huawei.com>
> > Cc: Rob Landley <rob@landley.net>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Mel Gorman <mgorman@suse.de>
> > Cc: Rik van Riel <riel@redhat.com>
> > Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
> > Cc: David Rientjes <rientjes@google.com>
> > Cc: linux-doc@vger.kernel.org
> > Cc: linux-mm@kvack.org
> > ---
> >  Documentation/cgroups/cpusets.txt |  50 ++++++++++-
> >  include/linux/cpuset.h            |   5 ++
> >  include/linux/huge_mm.h           |  25 +++++-
> >  kernel/cpuset.c                   | 181 ++++++++++++++++++++++++++++++++++++++
> >  mm/huge_memory.c                  |   3 +
> >  5 files changed, 261 insertions(+), 3 deletions(-)
> > 
> > diff --git a/Documentation/cgroups/cpusets.txt b/Documentation/cgroups/cpusets.txt
> > index 12e01d4..b7b2c83 100644
> > --- a/Documentation/cgroups/cpusets.txt
> > +++ b/Documentation/cgroups/cpusets.txt
> > @@ -22,12 +22,14 @@ CONTENTS:
> >    1.6 What is memory spread ?
> >    1.7 What is sched_load_balance ?
> >    1.8 What is sched_relax_domain_level ?
> > -  1.9 How do I use cpusets ?
> > +  1.9 What is thp_enabled ?
> > +  1.10 How do I use cpusets ?
> >  2. Usage Examples and Syntax
> >    2.1 Basic Usage
> >    2.2 Adding/removing cpus
> >    2.3 Setting flags
> >    2.4 Attaching processes
> > +  2.5 Setting thp_enabled flags
> >  3. Questions
> >  4. Contact
> >  
> > @@ -581,7 +583,34 @@ If your situation is:
> >  then increasing 'sched_relax_domain_level' would benefit you.
> >  
> >  
> > -1.9 How do I use cpusets ?
> > +1.9 What is thp_enabled ?
> > +-----------------------
> > +
> > +The thp_enabled file contained within each cpuset controls how transparent
> > +hugepages are handled within that cpuset.
> > +
> > +The root cpuset's thp_enabled flags mirror the flags set in
> > +/sys/kernel/mm/transparent_hugepage/enabled.  The flags in the root cpuset can
> > +only be modified by changing /sys/kernel/mm/transparent_hugepage/enabled. The
> > +thp_enabled file for the root cpuset is read only.  These flags cause the
> > +root cpuset to behave as one might expect:
> > +
> > +- When set to always, THPs are used whenever practical
> > +- When set to madvise, THPs are used only on chunks of memory that have the
> > +  MADV_HUGEPAGE flag set
> > +- When set to never, THPs are never allowed for tasks in this cpuset
> > +
> > +The behavior of thp_enabled for children of the root cpuset is where things
> > +become a bit more interesting.  The child cpusets accept the same flags as the
> > +root, but also have a default flag, which, when set, causes a cpuset to use the
> > +behavior of its parent.  When a child cpuset is created, its default flag is
> > +always initially set.
> > +
> > +Since the flags on child cpusets are allowed to differ from the flags on their
> > +parents, we are able to enable THPs for tasks in specific cpusets, and disable
> > +them in others.
> 
> Should we have a way for parent cgroup can enforce child behaviour?
> Like a mask of allowed thp_enabled values children can choose.
> 

We don't have a use case for that particular scenario, so we didn't
include any such functionality.  Our main goal here was to allow 
cpusets to override the /sys/kernel/mm/transparent_hugepage/enabled 
setting.  If you have a use case for that scenario, then I think it
would be more suitable to add that functionality in a separate patch.

> > @@ -177,6 +177,29 @@ static inline struct page *compound_trans_head(struct page *page)
> >  	return page;
> >  }
> >  
> > +#ifdef CONFIG_CPUSETS
> > +extern int cpuset_thp_always(struct task_struct *p);
> > +extern int cpuset_thp_madvise(struct task_struct *p);
> > +
> > +static inline int transparent_hugepage_enabled(struct vm_area_struct *vma)
> > +{
> > +	if (cpuset_thp_always(current))
> > +		return 1;
> 
> Why do you ignore VM_NOHUGEPAGE?
> And !is_vma_temporary_stack(__vma) is still relevant.
> 

That was an oversight, on my part.  I've fixed it and will submit the
corrected patch shortly.  Thanks for pointing that out.

> > +	else if (cpuset_thp_madvise(current) &&
> > +		 ((vma)->vm_flags & VM_HUGEPAGE) &&
> > +		 !((vma)->vm_flags & VM_NOHUGEPAGE) &&
> > +		 !is_vma_temporary_stack(vma))
> > +		return 1;
> > +	else
> > +		return 0;
> > +}
> > +#else
> > +static inline int transparent_hugepage_enabled(struct vm_area_struct *vma)
> > +{
> > +	return _transparent_hugepage_enabled(vma);
> > +}
> > +#endif
> > +
> >  extern int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
> >  				unsigned long addr, pmd_t pmd, pmd_t *pmdp);
> >  
> 
> -- 
>  Kirill A. Shutemov

- Alex Thorlton

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
