Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 44F6F8E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 09:17:28 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id r25-v6so870951edc.7
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 06:17:28 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s29-v6si1064483edd.58.2018.09.12.06.17.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 06:17:27 -0700 (PDT)
Date: Wed, 12 Sep 2018 15:17:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] memory_hotplug: Free pages as pageblock_order
Message-ID: <20180912131724.GH10951@dhcp22.suse.cz>
References: <1536744405-16752-1-git-send-email-arunks@codeaurora.org>
 <20180912103853.GC10951@dhcp22.suse.cz>
 <20180912125743.GB8537@350D>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180912125743.GB8537@350D>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Arun KS <arunks@codeaurora.org>, akpm@linux-foundation.org, dan.j.williams@intel.com, vbabka@suse.cz, pasha.tatashin@oracle.com, iamjoonsoo.kim@lge.com, osalvador@suse.de, malat@debian.org, gregkh@linuxfoundation.org, yasu.isimatu@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, arunks.linux@gmail.com, vinmenon@codeaurora.org

On Wed 12-09-18 22:57:43, Balbir Singh wrote:
> On Wed, Sep 12, 2018 at 12:38:53PM +0200, Michal Hocko wrote:
> > On Wed 12-09-18 14:56:45, Arun KS wrote:
> > > When free pages are done with pageblock_order, time spend on
> > > coalescing pages by buddy allocator can be reduced. With
> > > section size of 256MB, hot add latency of a single section
> > > shows improvement from 50-60 ms to less than 1 ms, hence
> > > improving the hot add latency by 60%.
> > 
> > Where does the improvement come from? You are still doing the same
> > amount of work except that the number of callbacks is lower. Is this the
> > real source of 60% improvement?
> >
> 
> It looks like only the first page of the pageblock is initialized, is
> some of the cost amortized in terms of doing one initialization for
> the page with order (order) and then relying on split_page and helpers
> to do the rest? Of course the number of callbacks reduce by a significant
> number as well.

Ohh, I have missed that part. Now when re-reading I can see the reason
for the perf improvement. It is most likely the higher order free which
ends up being much cheaper. This part makes some sense.

How much is this feasible is another question. Do not forget we have
those external providers of the online callback and those would need to
be updated as well.

Btw. the normal memmap init code path does the same per-page free as
well. If we really want to speed the hotplug path then I guess the init
one would see a bigger improvement and those two should be in sync.
 
> > > 
> > > If this looks okey, I'll modify users of set_online_page_callback
> > > and resend clean patch.
> > 
> > [...]
> > 
> > > +static int generic_online_pages(struct page *page, unsigned int order);
> > > +static online_pages_callback_t online_pages_callback = generic_online_pages;
> > > +
> > > +static int generic_online_pages(struct page *page, unsigned int order)
> > > +{
> > > +	unsigned long nr_pages = 1 << order;
> > > +	struct page *p = page;
> > > +	unsigned int loop;
> > > +
> > > +	for (loop = 0 ; loop < nr_pages ; loop++, p++) {
> > > +		__ClearPageReserved(p);
> > > +		set_page_count(p, 0);

btw. you want init_page_count here.
-- 
Michal Hocko
SUSE Labs
