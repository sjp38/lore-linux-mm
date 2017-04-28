Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 91AC86B02E1
	for <linux-mm@kvack.org>; Fri, 28 Apr 2017 02:30:52 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id j27so4949713wre.3
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 23:30:52 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v108si5129282wrb.289.2017.04.27.23.30.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Apr 2017 23:30:51 -0700 (PDT)
Date: Fri, 28 Apr 2017 08:30:48 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 2/2] mm: skip HWPoisoned pages when onlining pages
Message-ID: <20170428063048.GA9399@dhcp22.suse.cz>
References: <1493130472-22843-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1493130472-22843-3-git-send-email-ldufour@linux.vnet.ibm.com>
 <1493172615.4828.3.camel@gmail.com>
 <20170426031255.GB11619@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170426031255.GB11619@hori1.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Balbir Singh <bsingharora@gmail.com>, Laurent Dufour <ldufour@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Wen Congyang <wency@cn.fujitsu.com>

On Wed 26-04-17 03:13:04, Naoya Horiguchi wrote:
> On Wed, Apr 26, 2017 at 12:10:15PM +1000, Balbir Singh wrote:
> > On Tue, 2017-04-25 at 16:27 +0200, Laurent Dufour wrote:
> > > The commit b023f46813cd ("memory-hotplug: skip HWPoisoned page when
> > > offlining pages") skip the HWPoisoned pages when offlining pages, but
> > > this should be skipped when onlining the pages too.
> > >
> > > Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> > > ---
> > >  mm/memory_hotplug.c | 4 ++++
> > >  1 file changed, 4 insertions(+)
> > >
> > > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> > > index 6fa7208bcd56..741ddb50e7d2 100644
> > > --- a/mm/memory_hotplug.c
> > > +++ b/mm/memory_hotplug.c
> > > @@ -942,6 +942,10 @@ static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
> > >  	if (PageReserved(pfn_to_page(start_pfn)))
> > >  		for (i = 0; i < nr_pages; i++) {
> > >  			page = pfn_to_page(start_pfn + i);
> > > +			if (PageHWPoison(page)) {
> > > +				ClearPageReserved(page);
> >
> > Why do we clear page reserved? Also if the page is marked PageHWPoison, it
> > was never offlined to begin with? Or do you expect this to be set on newly
> > hotplugged memory? Also don't we need to skip the entire pageblock?
> 
> If I read correctly, to "skip HWPoiosned page" in commit b023f46813cd means
> that we skip the page status check for hwpoisoned pages *not* to prevent
> memory offlining for memblocks with hwpoisoned pages. That means that
> hwpoisoned pages can be offlined.

Is this patch actually correct? I am trying to wrap my head around it
but it smells like it tries to avoid the problem rather than fix it
properly. I might be wrong here of course but to me it sounds like
poisoned page should simply be offlined and keep its poison state all
the time. If the memory is hot-removed and added again we have lost the
struct page along with the state which is the expected behavior. If it
is still broken we will re-poison it.

Anyway a patch to skip over poisoned pages during online makes perfect
sense to me. The PageReserved fiddling around much less so.

Or am I missing something. Let's CC Wen Congyang for the clarification
here.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
