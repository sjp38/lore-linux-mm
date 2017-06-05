Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id AE0896B02C3
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 11:16:03 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id t9so96219850ywe.12
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 08:16:03 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id j1si4731193ywi.131.2017.06.05.08.16.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Jun 2017 08:16:02 -0700 (PDT)
Date: Mon, 5 Jun 2017 11:15:41 -0400
From: "Liam R. Howlett" <Liam.Howlett@Oracle.com>
Subject: Re: [PATCH] mm/hugetlb: Warn the user when issues arise on boot due
 to hugepages
Message-ID: <20170605151541.avidrotxpoiekoy5@oracle.com>
References: <20170603005413.10380-1-Liam.Howlett@Oracle.com>
 <20170605045725.GA9248@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170605045725.GA9248@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mike.kravetz@Oracle.com, n-horiguchi@ah.jp.nec.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, zhongjiang@huawei.com, aarcange@redhat.com, kirill.shutemov@linux.intel.com

* Michal Hocko <mhocko@suse.com> [170605 00:57]:
> On Fri 02-06-17 20:54:13, Liam R. Howlett wrote:
> > When the user specifies too many hugepages or an invalid
> > default_hugepagesz the communication to the user is implicit in the
> > allocation message.  This patch adds a warning when the desired page
> > count is not allocated and prints an error when the default_hugepagesz
> > is invalid on boot.
> 
> We do not warn when doing echo $NUM > nr_hugepages, so why should we
> behave any different during the boot?

During boot hugepages will allocate until there is a fraction of the
hugepage size left.  That is, we allocate until either the request is
satisfied or memory for the pages is exhausted.  When memory for the
pages is exhausted, it will most likely lead to the system failing with
the OOM manager not finding enough (or anything) to kill (unless you're
using really big hugepages in the order of 100s of MB or in the GBs).
The user will most likely see the OOM messages much later in the boot
sequence than the implicitly stated message.  Worse yet, you may even
get an OOM for each processor which causes many pages of OOMs on modern
systems.  Although these messages will be printed earlier than the OOM
messages, at least giving the user errors and warnings will highlight
the configuration as an issue.  I'm trying to point the user in the
right direction by providing a more robust statement of what is failing.

During the sysctl or echo command, the user can check the results much
easier than if the system hangs during boot and the scenario of having
nothing to OOM for kernel memory is highly unlikely.

Thanks,
Liam

>  
> > Signed-off-by: Liam R. Howlett <Liam.Howlett@Oracle.com>
> > ---
> >  mm/hugetlb.c | 15 ++++++++++++++-
> >  1 file changed, 14 insertions(+), 1 deletion(-)
> > 
> > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > index e5828875f7bb..6de30bbac23e 100644
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -70,6 +70,7 @@ struct mutex *hugetlb_fault_mutex_table ____cacheline_aligned_in_smp;
> >  
> >  /* Forward declaration */
> >  static int hugetlb_acct_memory(struct hstate *h, long delta);
> > +static char * __init memfmt(char *buf, unsigned long n);
> >  
> >  static inline void unlock_or_release_subpool(struct hugepage_subpool *spool)
> >  {
> > @@ -2189,7 +2190,14 @@ static void __init hugetlb_hstate_alloc_pages(struct hstate *h)
> >  					 &node_states[N_MEMORY]))
> >  			break;
> >  	}
> > -	h->max_huge_pages = i;
> > +	if (i < h->max_huge_pages) {
> > +		char buf[32];
> > +
> > +		memfmt(buf, huge_page_size(h)),
> > +		pr_warn("HugeTLB: allocating %lu of page size %s failed.  Only allocated %lu hugepages.\n",
> > +			h->max_huge_pages, buf, i);
> > +		h->max_huge_pages = i;
> > +	}
> >  }
> >  
> >  static void __init hugetlb_init_hstates(void)
> > @@ -2785,6 +2793,11 @@ static int __init hugetlb_init(void)
> >  		return 0;
> >  
> >  	if (!size_to_hstate(default_hstate_size)) {
> > +		if (default_hstate_size != 0) {
> > +			pr_err("HugeTLB: unsupported default_hugepagesz %lu. Reverting to %lu\n",
> > +			       default_hstate_size, HPAGE_SIZE);
> > +		}
> > +
> >  		default_hstate_size = HPAGE_SIZE;
> >  		if (!size_to_hstate(default_hstate_size))
> >  			hugetlb_add_hstate(HUGETLB_PAGE_ORDER);
> > -- 
> > 2.13.0.92.gcd65a7235
> > 
> 
> -- 
> Michal Hocko
> SUSE Labs
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
