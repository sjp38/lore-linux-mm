Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f49.google.com (mail-ee0-f49.google.com [74.125.83.49])
	by kanga.kvack.org (Postfix) with ESMTP id 4DA906B005C
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 14:50:02 -0400 (EDT)
Received: by mail-ee0-f49.google.com with SMTP id c41so260eek.36
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 11:50:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id z2si25086178eeo.184.2014.04.07.11.50.00
        for <linux-mm@kvack.org>;
        Mon, 07 Apr 2014 11:50:01 -0700 (PDT)
Date: Mon, 7 Apr 2014 14:49:35 -0400
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [PATCH 4/4] hugetlb: add support for gigantic page allocation
 at runtime
Message-ID: <20140407144935.259d4301@redhat.com>
In-Reply-To: <1396893509-x52fgnka@n-horiguchi@ah.jp.nec.com>
References: <1396462128-32626-1-git-send-email-lcapitulino@redhat.com>
	<1396462128-32626-5-git-send-email-lcapitulino@redhat.com>
	<1396893509-x52fgnka@n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mtosatti@redhat.com, aarcange@redhat.com, mgorman@suse.de, akpm@linux-foundation.org, andi@firstfloor.org, davidlohr@hp.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, riel@redhat.com

On Mon, 07 Apr 2014 13:58:29 -0400
Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> On Wed, Apr 02, 2014 at 02:08:48PM -0400, Luiz Capitulino wrote:
> > HugeTLB is limited to allocating hugepages whose size are less than
> > MAX_ORDER order. This is so because HugeTLB allocates hugepages via
> > the buddy allocator. Gigantic pages (that is, pages whose size is
> > greater than MAX_ORDER order) have to be allocated at boottime.
> > 
> > However, boottime allocation has at least two serious problems. First,
> > it doesn't support NUMA and second, gigantic pages allocated at
> > boottime can't be freed.
> > 
> > This commit solves both issues by adding support for allocating gigantic
> > pages during runtime. It works just like regular sized hugepages,
> > meaning that the interface in sysfs is the same, it supports NUMA,
> > and gigantic pages can be freed.
> > 
> > For example, on x86_64 gigantic pages are 1GB big. To allocate two 1G
> > gigantic pages on node 1, one can do:
> > 
> >  # echo 2 > \
> >    /sys/devices/system/node/node1/hugepages/hugepages-1048576kB/nr_hugepages
> > 
> > And to free them later:
> > 
> >  # echo 0 > \
> >    /sys/devices/system/node/node1/hugepages/hugepages-1048576kB/nr_hugepages
> > 
> > The one problem with gigantic page allocation at runtime is that it
> > can't be serviced by the buddy allocator. To overcome that problem, this
> > series scans all zones from a node looking for a large enough contiguous
> > region. When one is found, it's allocated by using CMA, that is, we call
> > alloc_contig_range() to do the actual allocation. For example, on x86_64
> > we scan all zones looking for a 1GB contiguous region. When one is found
> > it's allocated by alloc_contig_range().
> > 
> > One expected issue with that approach is that such gigantic contiguous
> > regions tend to vanish as time goes by. The best way to avoid this for
> > now is to make gigantic page allocations very early during boot, say
> > from a init script. Other possible optimization include using compaction,
> > which is supported by CMA but is not explicitly used by this commit.
> > 
> > It's also important to note the following:
> > 
> >  1. My target systems are x86_64 machines, so I have only tested 1GB
> >     pages allocation/release. I did try to make this arch indepedent
> >     and expect it to work on other archs but didn't try it myself
> > 
> >  2. I didn't add support for hugepage overcommit, that is allocating
> >     a gigantic page on demand when
> >    /proc/sys/vm/nr_overcommit_hugepages > 0. The reason is that I don't
> >    think it's reasonable to do the hard and long work required for
> >    allocating a gigantic page at fault time. But it should be simple
> >    to add this if wanted
> > 
> > Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>
> 
> I agree to the basic idea. One question below ...

Good to hear that.

> > ---
> >  arch/x86/include/asm/hugetlb.h |  10 +++
> >  mm/hugetlb.c                   | 177 ++++++++++++++++++++++++++++++++++++++---
> >  2 files changed, 176 insertions(+), 11 deletions(-)
> > 
> > diff --git a/arch/x86/include/asm/hugetlb.h b/arch/x86/include/asm/hugetlb.h
> > index a809121..2b262f7 100644
> > --- a/arch/x86/include/asm/hugetlb.h
> > +++ b/arch/x86/include/asm/hugetlb.h
> > @@ -91,6 +91,16 @@ static inline void arch_release_hugepage(struct page *page)
> >  {
> >  }
> >  
> > +static inline int arch_prepare_gigantic_page(struct page *page)
> > +{
> > +	return 0;
> > +}
> > +
> > +static inline void arch_release_gigantic_page(struct page *page)
> > +{
> > +}
> > +
> > +
> >  static inline void arch_clear_hugepage_flags(struct page *page)
> >  {
> >  }
> 
> These are defined only on arch/x86, but called in generic code.
> Does it cause build failure on other archs?

Hmm, probably. The problem here is that I'm unable to test this
code in other archs. So I think the best solution for the first
merge is to make the build of this feature conditional to x86_64?
Then the first person interested in making this work in other
archs add the generic code. Sounds reasonable?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
