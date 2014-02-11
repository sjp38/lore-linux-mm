Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id BD8C96B0036
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 10:27:22 -0500 (EST)
Received: by mail-wi0-f179.google.com with SMTP id hn9so4474738wib.12
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 07:27:22 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id lm2si9842899wjb.40.2014.02.11.07.27.19
        for <linux-mm@kvack.org>;
        Tue, 11 Feb 2014 07:27:20 -0800 (PST)
Date: Tue, 11 Feb 2014 10:27:01 -0500
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [PATCH 4/4] hugetlb: hugepagesnid=: add 1G huge page support
Message-ID: <20140211102701.6114576b@redhat.com>
In-Reply-To: <20140210153032.ac9325938264a3894dc83f8b@linux-foundation.org>
References: <1392053268-29239-1-git-send-email-lcapitulino@redhat.com>
	<1392053268-29239-5-git-send-email-lcapitulino@redhat.com>
	<20140210153032.ac9325938264a3894dc83f8b@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mtosatti@redhat.com, mgorman@suse.de, aarcange@redhat.com, andi@firstfloor.org, riel@redhat.com

On Mon, 10 Feb 2014 15:30:32 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Mon, 10 Feb 2014 12:27:48 -0500 Luiz Capitulino <lcapitulino@redhat.com> wrote:
> 
> > 
> > ...
> >
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -2051,6 +2051,29 @@ void __init hugetlb_add_hstate(unsigned order)
> >  	parsed_hstate = h;
> >  }
> >  
> > +static void __init hugetlb_hstate_alloc_pages_nid(struct hstate *h,
> > +						int nid,
> > +						unsigned long nr_pages)
> > +{
> > +	struct huge_bootmem_page *m;
> > +	unsigned long i;
> > +	void *addr;
> > +
> > +	for (i = 0; i < nr_pages; i++) {
> > +		addr = memblock_virt_alloc_nid_nopanic(
> > +				huge_page_size(h), huge_page_size(h),
> > +				0, BOOTMEM_ALLOC_ACCESSIBLE, nid);
> > +		if (!addr)
> > +			break;
> > +		m = addr;
> > +		BUG_ON((unsigned long)virt_to_phys(m) & (huge_page_size(h) - 1));
> 
> IS_ALIGNED()?
> 
> > +		list_add(&m->list, &huge_boot_pages);
> > +		m->hstate = h;
> > +	}
> > +
> > +	h->max_huge_pages += i;
> > +}
> > +
> >  void __init hugetlb_add_nrpages_nid(unsigned order, unsigned long nid,
> >  				unsigned long nr_pages)
> >  {
> 
> Please cc Yinghai Lu <yinghai@kernel.org> on these patches - he
> understands memblock well and is a strong reviewer.

Will do for v2, with your comments addressed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
