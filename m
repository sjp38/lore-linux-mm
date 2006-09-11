Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate6.de.ibm.com (8.13.8/8.13.8) with ESMTP id k8B4Mru9129474
	for <linux-mm@kvack.org>; Mon, 11 Sep 2006 04:22:53 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8B4RPBD2850930
	for <linux-mm@kvack.org>; Mon, 11 Sep 2006 06:27:25 +0200
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8B4Mq3J001605
	for <linux-mm@kvack.org>; Mon, 11 Sep 2006 06:22:52 +0200
Date: Mon, 11 Sep 2006 06:22:01 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [patch 2/2] convert s390 page handling macros to functions v3
Message-ID: <20060911042201.GA8379@osiris.ibm.com>
References: <20060908111716.GA6913@osiris.boeblingen.de.ibm.com> <Pine.LNX.4.64.0609092248400.6762@scrub.home> <20060910130832.GB12084@osiris.ibm.com> <1157905518.26324.83.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1157905518.26324.83.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Roman Zippel <zippel@linux-m68k.org>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Sun, Sep 10, 2006 at 09:25:18AM -0700, Dave Hansen wrote:
> On Sun, 2006-09-10 at 15:08 +0200, Heiko Carstens wrote:
> > 
> > +static inline int page_test_and_clear_dirty(struct page *page)
> > +{
> > +       unsigned long physpage = __pa((page - mem_map) << PAGE_SHIFT);
> > +       int skey = page_get_storage_key(physpage); 
> 
> This has nothing to do with your patch at all, but why is 'page -
> mem_map' being open-coded here?

I just changed the defines to functions without thinking about this.. :)
 
> I see at least a couple of page_to_phys() definitions on some
> architectures.  This operation is done enough times that s390 could
> probably use the same treatment.

Yes, even s390 has page_to_phys() as well. But why is it in io.h? Seems
like this is inconsistent across architectures. Also in quite a few
architectures the define looks like this:

#define page_to_phys(page)	((page - mem_map) << PAGE_SHIFT)

A pair of braces is missing around page. Yet another possible subtle bug...

> It could at least use a page_to_pfn() instead of the 'page - mem_map'
> operation, right?

Yes, I will address that in a later patch. Shouldn't stop this one from
being merged, if there aren't any other objections.
Thanks for pointing this out!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
