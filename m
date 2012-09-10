Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 1E5476B005D
	for <linux-mm@kvack.org>; Mon, 10 Sep 2012 10:50:17 -0400 (EDT)
Date: Mon, 10 Sep 2012 17:50:48 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v2 10/10] thp: implement refcounting for huge zero page
Message-ID: <20120910145048.GA23448@shutemov.name>
References: <1347282813-21935-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1347282813-21935-11-git-send-email-kirill.shutemov@linux.intel.com>
 <1347285759.1234.1645.camel@edumazet-glaptop>
 <20120910144438.GA31697@otc-wbsnb-06>
 <1347288487.1234.1692.camel@edumazet-glaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1347288487.1234.1692.camel@edumazet-glaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org

On Mon, Sep 10, 2012 at 04:48:07PM +0200, Eric Dumazet wrote:
> On Mon, 2012-09-10 at 17:44 +0300, Kirill A. Shutemov wrote:
> > On Mon, Sep 10, 2012 at 04:02:39PM +0200, Eric Dumazet wrote:
> > > On Mon, 2012-09-10 at 16:13 +0300, Kirill A. Shutemov wrote:
> > > > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > > > 
> > > > H. Peter Anvin doesn't like huge zero page which sticks in memory forever
> > > > after the first allocation. Here's implementation of lockless refcounting
> > > > for huge zero page.
> > > > 
> > > ...
> > > 
> > > > +static unsigned long get_huge_zero_page(void)
> > > > +{
> > > > +	struct page *zero_page;
> > > > +retry:
> > > > +	if (likely(atomic_inc_not_zero(&huge_zero_refcount)))
> > > > +		return ACCESS_ONCE(huge_zero_pfn);
> > > > +
> > > > +	zero_page = alloc_pages(GFP_TRANSHUGE | __GFP_ZERO, HPAGE_PMD_ORDER);
> > > > +	if (!zero_page)
> > > > +		return 0;
> > > > +	if (cmpxchg(&huge_zero_pfn, 0, page_to_pfn(zero_page))) {
> > > > +		__free_page(zero_page);
> > > > +		goto retry;
> > > > +	}
> > > 
> > > This might break if preemption can happen here ?
> > > 
> > > The second thread might loop forever because huge_zero_refcount is 0,
> > > and huge_zero_pfn not zero.
> > 
> > I fail to see why the second thread might loop forever. Long time yes, but
> > forever?
> > 
> > Yes, disabling preemption before alloc_pages() and enabling after
> > atomic_set() looks reasonable. Thanks.
> 
> If you have one online cpu, and the second thread is real time or
> something like that, it wont give cpu back to preempted thread.

Okay, I see. I'll update the patch.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
