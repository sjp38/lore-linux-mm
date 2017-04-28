Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id DEFB06B02E1
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 22:51:40 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e64so4843037pfd.3
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 19:51:40 -0700 (PDT)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id x12si4706466pfi.213.2017.04.27.19.51.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Apr 2017 19:51:40 -0700 (PDT)
Received: by mail-pg0-x241.google.com with SMTP id v1so3121796pgv.3
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 19:51:40 -0700 (PDT)
Message-ID: <1493347894.28002.3.camel@gmail.com>
Subject: Re: [PATCH v2 2/2] mm: skip HWPoisoned pages when onlining pages
From: Balbir Singh <bsingharora@gmail.com>
Date: Fri, 28 Apr 2017 12:51:34 +1000
In-Reply-To: <20170426031255.GB11619@hori1.linux.bs1.fc.nec.co.jp>
References: <1493130472-22843-1-git-send-email-ldufour@linux.vnet.ibm.com>
	 <1493130472-22843-3-git-send-email-ldufour@linux.vnet.ibm.com>
	 <1493172615.4828.3.camel@gmail.com>
	 <20170426031255.GB11619@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On Wed, 2017-04-26 at 03:13 +0000, Naoya Horiguchi wrote:
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
> 
> And another reason to clear PageReserved is that we could reuse the
> hwpoisoned page after onlining back with replacing the broken DIMM.
> In this usecase, we first do unpoisoning to clear PageHWPoison,
> but it doesn't work if PageReserved is set. My simple testing shows
> the BUG below in unpoisoning (without the ClearPageReserved):
>

Fair enough, thanks for the explanation

Balbir Singh. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
