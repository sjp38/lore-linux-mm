Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4F4786B0271
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 18:04:03 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id g13so14182579wrh.19
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 15:04:03 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f5si3914513wmg.258.2018.01.17.15.04.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jan 2018 15:04:02 -0800 (PST)
Date: Wed, 17 Jan 2018 15:03:59 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 2/2] mm: skip HWPoisoned pages when onlining pages
Message-Id: <20180117150359.655bb93d8f1d663a2cd48c33@linux-foundation.org>
In-Reply-To: <20170428063048.GA9399@dhcp22.suse.cz>
References: <1493130472-22843-1-git-send-email-ldufour@linux.vnet.ibm.com>
	<1493130472-22843-3-git-send-email-ldufour@linux.vnet.ibm.com>
	<1493172615.4828.3.camel@gmail.com>
	<20170426031255.GB11619@hori1.linux.bs1.fc.nec.co.jp>
	<20170428063048.GA9399@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Balbir Singh <bsingharora@gmail.com>, Laurent Dufour <ldufour@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Wen Congyang <wency@cn.fujitsu.com>

On Fri, 28 Apr 2017 08:30:48 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> On Wed 26-04-17 03:13:04, Naoya Horiguchi wrote:
> > On Wed, Apr 26, 2017 at 12:10:15PM +1000, Balbir Singh wrote:
> > > On Tue, 2017-04-25 at 16:27 +0200, Laurent Dufour wrote:
> > > > The commit b023f46813cd ("memory-hotplug: skip HWPoisoned page when
> > > > offlining pages") skip the HWPoisoned pages when offlining pages, but
> > > > this should be skipped when onlining the pages too.
> > > >
> > > > Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> > > > ---
> > > >  mm/memory_hotplug.c | 4 ++++
> > > >  1 file changed, 4 insertions(+)
> > > >
> > > > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> > > > index 6fa7208bcd56..741ddb50e7d2 100644
> > > > --- a/mm/memory_hotplug.c
> > > > +++ b/mm/memory_hotplug.c
> > > > @@ -942,6 +942,10 @@ static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
> > > >  	if (PageReserved(pfn_to_page(start_pfn)))
> > > >  		for (i = 0; i < nr_pages; i++) {
> > > >  			page = pfn_to_page(start_pfn + i);
> > > > +			if (PageHWPoison(page)) {
> > > > +				ClearPageReserved(page);
> > >
> > > Why do we clear page reserved? Also if the page is marked PageHWPoison, it
> > > was never offlined to begin with? Or do you expect this to be set on newly
> > > hotplugged memory? Also don't we need to skip the entire pageblock?
> > 
> > If I read correctly, to "skip HWPoiosned page" in commit b023f46813cd means
> > that we skip the page status check for hwpoisoned pages *not* to prevent
> > memory offlining for memblocks with hwpoisoned pages. That means that
> > hwpoisoned pages can be offlined.
> 
> Is this patch actually correct? I am trying to wrap my head around it
> but it smells like it tries to avoid the problem rather than fix it
> properly. I might be wrong here of course but to me it sounds like
> poisoned page should simply be offlined and keep its poison state all
> the time. If the memory is hot-removed and added again we have lost the
> struct page along with the state which is the expected behavior. If it
> is still broken we will re-poison it.
> 
> Anyway a patch to skip over poisoned pages during online makes perfect
> sense to me. The PageReserved fiddling around much less so.
> 
> Or am I missing something. Let's CC Wen Congyang for the clarification
> here.

Wen Congyang appears to have disappeared and this fix isn't yet
finalized.  Can we all please revisit it and have a think about
Michal's questions?

Thanks.


From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: mm: skip HWPoisoned pages when onlining pages

b023f46813cd ("memory-hotplug: skip HWPoisoned page when offlining pages")
skipped the HWPoisoned pages when offlining pages, but this should be
skipped when onlining the pages too.

n-horiguchi@ah.jp.nec.com said:

: If I read correctly, to "skip HWPoiosned page" in commit b023f46813cd
: means that we skip the page status check for hwpoisoned pages *not* to
: prevent memory offlining for memblocks with hwpoisoned pages.  That
: means that hwpoisoned pages can be offlined.
: 
: And another reason to clear PageReserved is that we could reuse the
: hwpoisoned page after onlining back with replacing the broken DIMM.  In
: this usecase, we first do unpoisoning to clear PageHWPoison, but it
: doesn't work if PageReserved is set.  My simple testing shows the BUG
: below in unpoisoning (without the ClearPageReserved):
: 
:   Unpoison: Software-unpoisoned page 0x18000
:   BUG: Bad page state in process page-types  pfn:18000
:   page:ffffda5440600000 count:0 mapcount:0 mapping:          (null) index:0x70006b599
:   flags: 0x1fffc00004081a(error|uptodate|dirty|reserved|swapbacked)
:   raw: 001fffc00004081a 0000000000000000 000000070006b599 00000000ffffffff
:   raw: dead000000000100 dead000000000200 0000000000000000 0000000000000000
:   page dumped because: PAGE_FLAGS_CHECK_AT_FREE flag(s) set
:   bad because of flags: 0x800(reserved)

Link: http://lkml.kernel.org/r/1493130472-22843-3-git-send-email-ldufour@linux.vnet.ibm.com
Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrey Vagin <avagin@openvz.org>
Cc: Glauber Costa <glommer@openvz.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Balbir Singh <bsingharora@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/memory_hotplug.c |    4 ++++
 1 file changed, 4 insertions(+)

diff -puN mm/memory_hotplug.c~mm-skip-hwpoisoned-pages-when-onlining-pages mm/memory_hotplug.c
--- a/mm/memory_hotplug.c~mm-skip-hwpoisoned-pages-when-onlining-pages
+++ a/mm/memory_hotplug.c
@@ -696,6 +696,10 @@ static int online_pages_range(unsigned l
 	if (PageReserved(pfn_to_page(start_pfn)))
 		for (i = 0; i < nr_pages; i++) {
 			page = pfn_to_page(start_pfn + i);
+			if (PageHWPoison(page)) {
+				ClearPageReserved(page);
+				continue;
+			}
 			(*online_page_callback)(page);
 			onlined_pages++;
 		}
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
