Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 7B6196B0031
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 10:26:37 -0500 (EST)
Received: by mail-wi0-f173.google.com with SMTP id hn9so4472373wib.12
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 07:26:36 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id j6si9827072wje.154.2014.02.11.07.26.35
        for <linux-mm@kvack.org>;
        Tue, 11 Feb 2014 07:26:36 -0800 (PST)
Date: Tue, 11 Feb 2014 10:26:16 -0500
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [PATCH 3/4] hugetlb: add hugepagesnid= command-line option
Message-ID: <20140211102616.7a577766@redhat.com>
In-Reply-To: <20140210152729.737a5dca5db0ba7f9f9291ac@linux-foundation.org>
References: <1392053268-29239-1-git-send-email-lcapitulino@redhat.com>
	<1392053268-29239-4-git-send-email-lcapitulino@redhat.com>
	<20140210152729.737a5dca5db0ba7f9f9291ac@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mtosatti@redhat.com, mgorman@suse.de, aarcange@redhat.com, andi@firstfloor.org, riel@redhat.com

On Mon, 10 Feb 2014 15:27:29 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Mon, 10 Feb 2014 12:27:47 -0500 Luiz Capitulino <lcapitulino@redhat.com> wrote:
> 
> > From: Luiz capitulino <lcapitulino@redhat.com>
> > 
> > The HugeTLB command-line option hugepages= allow the user to specify
> > how many huge pages should be allocated at boot-time. On NUMA systems,
> > this option will try to automatically distribute the allocation equally
> > among nodes. For example, if you have a 2-node NUMA system and allocates
> > 200 huge pages, than hugepages= will try to allocate 100 huge pages from
> > node0 and 100 from node1.
> > 
> > The hugepagesnid= option introduced by this commit allows the user
> > to specify the nodes from which huge pages are allocated. For example,
> > if you have a 2-node NUMA system and want 300 2M huge pages to be
> > allocated from node1, you could do:
> > 
> >  hugepagesnid=1,300,2M
> > 
> > Or, say you want node0 to allocate 100 huge pages and node1 to
> > allocate 200 huge pages, you do:
> > 
> >  hugepagesnid=0,100,2M hugepagesnid=1,200,1M
> > 
> > This commit adds support only for 2M huge pages, next commit will
> > add support for 1G huge pages.
> > 
> > ...
> >
> > --- a/arch/x86/mm/hugetlbpage.c
> > +++ b/arch/x86/mm/hugetlbpage.c
> > @@ -188,4 +188,39 @@ static __init int setup_hugepagesz(char *opt)
> >  	return 1;
> >  }
> >  __setup("hugepagesz=", setup_hugepagesz);
> > +
> > +static __init int setup_hugepagesnid(char *opt)
> > +{
> > +	unsigned long order, ps, nid, nr_pages;
> > +	char size_str[3];
> > +
> > +	size_str[2] = '\0';
> > +	if (sscanf(opt, "%lu,%lu,%c%c",
> > +			&nid, &nr_pages, &size_str[0], &size_str[1]) < 4) {
> > +		printk(KERN_ERR "hugepagesnid: failed to parse arguments\n");
> > +			return 0;
> > +	}
> 
> This will blow up if passed size=16M.  We can expect that powerpc (at
> least) will want to copy (or generalise) this code.  It would be better
> to avoid such restrictions at the outset.
> 
> > +	if (!nr_pages) {
> > +		printk(KERN_ERR
> > +			"hugepagesnid: zero number of pages, ignoring\n");
> 
> The code contains rather a lot of these awkward wordwraps.  Try using
> pr_err() and you'll find the result quite pleasing!

Will make both changes.

> > +		return 0;
> > +	}
> > +
> > +	ps = memparse(size_str, NULL);
> > +	if (ps == PMD_SIZE) {
> > +		order = PMD_SHIFT - PAGE_SHIFT;
> > +	} else if (ps == PUD_SIZE && cpu_has_gbpages) {
> > +		order = PUD_SHIFT - PAGE_SHIFT;
> > +	} else {
> > +		printk(KERN_ERR "hugepagesnid: Unsupported page size %lu M\n",
> > +			ps >> 20);
> > +		return 0;
> > +	}
> > +
> > +	hugetlb_add_nrpages_nid(order, nid, nr_pages);
> > +	return 1;
> > +}
> > +__setup("hugepagesnid=", setup_hugepagesnid);
> > +
> >  #endif
> >
> > ...
> >
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -46,6 +46,7 @@ __initdata LIST_HEAD(huge_boot_pages);
> >  static struct hstate * __initdata parsed_hstate;
> >  static unsigned long __initdata default_hstate_max_huge_pages;
> >  static unsigned long __initdata default_hstate_size;
> > +static unsigned long __initdata boot_alloc_nodes[HUGE_MAX_HSTATE][MAX_NUMNODES];
> >  
> >  /*
> >   * Protects updates to hugepage_freelists, hugepage_activelist, nr_huge_pages,
> > @@ -1348,6 +1349,50 @@ static void __init hugetlb_hstate_alloc_pages(struct hstate *h)
> >  	h->max_huge_pages = i;
> >  }
> >  
> > +static unsigned long __init alloc_huge_pages_nid(struct hstate *h,
> > +						int nid,
> > +						unsigned long nr_pages)
> > +{
> > +	unsigned long i;
> > +	struct page *page;
> > +
> > +	for (i = 0; i < nr_pages; i++) {
> > +		page = alloc_fresh_huge_page_node(h, nid);
> > +		if (!page) {
> > +			count_vm_event(HTLB_BUDDY_PGALLOC_FAIL);
> > +			break;
> > +		}
> > +		count_vm_event(HTLB_BUDDY_PGALLOC);
> > +	}
> > +
> > +	return i;
> > +}
> > +
> > +static unsigned long __init alloc_huge_pages_nodes(struct hstate *h)
> > +{
> > +	unsigned long i, *entry, ret = 0;
> > +
> > +	for (i = 0; i < MAX_NUMNODES; i++) {
> > +		entry = &boot_alloc_nodes[hstate_index(h)][i];
> > +		if (*entry > 0)
> > +			ret += alloc_huge_pages_nid(h, i, *entry);
> > +	}
> > +
> > +	return ret;
> > +}
> > +
> > +static void __init hugetlb_init_hstates_nodes(void)
> > +{
> > +	struct hstate *h;
> > +	unsigned long ret;
> > +
> > +	for_each_hstate(h)
> > +		if (h->order < MAX_ORDER) {
> > +			ret = alloc_huge_pages_nodes(h);
> > +			h->max_huge_pages += ret;
> > +		}
> > +}
> 
> The patch adds code to mm/hugetlb.c which only x86 will use.  I guess
> that's OK medium-term if we expect other architectures will use it. 

Yes, we do.

> But if other architectures use it, setup_hugepagesnid() was in the wrong
> directory.

The page size parameter is arch-dependent. I can think of two options:

 1. Let setup_hugepagesnid() do all the work (which is what this series
    does). Not ideal, because will cause some code duplication when other
    archs implement it

 2. Use existing helpers, or add this one to mm/hugetlb.c:

     mm/parse_hugepagesnid_str(const char *str, int *ps, int *nid, int *nr_pages);

    To be called from arch-dependent code (eg. setup_hugepagesnid()). So,
    arch dependent calls parse_hugepagesnid_str(), do page size checks and
    calls hugetlb_add_nrpages_nid()

> Can I ask that you poke the ppc/arm/ia64/etc people, see whether they
> will adpot this?  Explaining the overall justification better in [patch
> 0/n] would help this discussion!

Absolutely.

> 
> >  static void __init hugetlb_init_hstates(void)
> >  {
> >  	struct hstate *h;
> > @@ -1966,6 +2011,7 @@ static int __init hugetlb_init(void)
> >  		default_hstate.max_huge_pages = default_hstate_max_huge_pages;
> >  
> >  	hugetlb_init_hstates();
> > +	hugetlb_init_hstates_nodes();
> >  	gather_bootmem_prealloc();
> >  	report_hugepages();
> >  
> > @@ -2005,6 +2051,37 @@ void __init hugetlb_add_hstate(unsigned order)
> >  	parsed_hstate = h;
> >  }
> >  
> > +void __init hugetlb_add_nrpages_nid(unsigned order, unsigned long nid,
> > +				unsigned long nr_pages)
> 
> Using an unsigned long for a NUMA node ID is overkill, surely.

OK.

> 
> > +{
> > +	struct hstate *h;
> > +	unsigned long *p;
> > +
> > +	if (parsed_hstate) {
> > +		printk(KERN_WARNING
> > +			"hugepagesnid: hugepagesz= specified, ignoring\n");
> > +		return;
> > +	}
> > +
> > +	for_each_hstate(h)
> > +		if (h->order == order)
> > +			break;
> > +
> > +	if (h->order != order) {
> > +		hugetlb_add_hstate(order);
> > +		parsed_hstate = NULL;
> > +	}
> > +
> > +	p = &boot_alloc_nodes[hstate_index(h)][nid];
> > +	if (*p != 0) {
> > +		printk(KERN_WARNING
> > +			"hugepagesnid: node %lu already specified, ignoring\n", nid);
> > +		return;
> > +	}
> > +
> > +	*p = nr_pages;
> > +}
> > +
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
