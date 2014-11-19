Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id D73F86B0038
	for <linux-mm@kvack.org>; Tue, 18 Nov 2014 19:55:12 -0500 (EST)
Received: by mail-wg0-f50.google.com with SMTP id k14so11164337wgh.9
        for <linux-mm@kvack.org>; Tue, 18 Nov 2014 16:55:12 -0800 (PST)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id lt13si98981wic.7.2014.11.18.16.55.12
        for <linux-mm@kvack.org>;
        Tue, 18 Nov 2014 16:55:12 -0800 (PST)
Date: Wed, 19 Nov 2014 02:54:55 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 06/19] mm: store mapcount for compound page separate
Message-ID: <20141119005455.GA32179@node.dhcp.inet.fi>
References: <1415198994-15252-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1415198994-15252-7-git-send-email-kirill.shutemov@linux.intel.com>
 <20141118084337.GA16714@hori1.linux.bs1.fc.nec.co.jp>
 <20141118095811.GA21774@node.dhcp.inet.fi>
 <20141118234145.GA4116@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141118234145.GA4116@hori1.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Nov 18, 2014 at 11:41:08PM +0000, Naoya Horiguchi wrote:
> > > > @@ -6632,10 +6637,12 @@ static void dump_page_flags(unsigned long flags)
> > > >  void dump_page_badflags(struct page *page, const char *reason,
> > > >  		unsigned long badflags)
> > > >  {
> > > > -	printk(KERN_ALERT
> > > > -	       "page:%p count:%d mapcount:%d mapping:%p index:%#lx\n",
> > > > +	pr_alert("page:%p count:%d mapcount:%d mapping:%p index:%#lx",
> > > >  		page, atomic_read(&page->_count), page_mapcount(page),
> > > >  		page->mapping, page->index);
> > > > +	if (PageCompound(page))
> > > 
> > > > +		printk(" compound_mapcount: %d", compound_mapcount(page));
> > > > +	printk("\n");
> > > 
> > > These two printk() should be pr_alert(), too?
> > 
> > No. It will split the line into several messages in dmesg.
> 
> This splitting is fine. I meant that these printk()s are for one series
> of message, so setting the same log level looks reasonable to me.

Hm. It seems what I really need to use there is pr_cont(). I didn't know
it exists. Thanks for hint ;)

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
