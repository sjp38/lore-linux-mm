Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id D2E446B02EE
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 23:19:39 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id x86so241044933ioe.5
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 20:19:39 -0700 (PDT)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id g6si2910237ita.93.2017.04.25.20.19.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Apr 2017 20:19:39 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 2/2] mm: skip HWPoisoned pages when onlining pages
Date: Wed, 26 Apr 2017 03:13:04 +0000
Message-ID: <20170426031255.GB11619@hori1.linux.bs1.fc.nec.co.jp>
References: <1493130472-22843-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1493130472-22843-3-git-send-email-ldufour@linux.vnet.ibm.com>
 <1493172615.4828.3.camel@gmail.com>
In-Reply-To: <1493172615.4828.3.camel@gmail.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <5F9BC3A5C64D4D4B9C9278E6DB4B01F7@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On Wed, Apr 26, 2017 at 12:10:15PM +1000, Balbir Singh wrote:
> On Tue, 2017-04-25 at 16:27 +0200, Laurent Dufour wrote:
> > The commit b023f46813cd ("memory-hotplug: skip HWPoisoned page when
> > offlining pages") skip the HWPoisoned pages when offlining pages, but
> > this should be skipped when onlining the pages too.
> >
> > Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> > ---
> >  mm/memory_hotplug.c | 4 ++++
> >  1 file changed, 4 insertions(+)
> >
> > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> > index 6fa7208bcd56..741ddb50e7d2 100644
> > --- a/mm/memory_hotplug.c
> > +++ b/mm/memory_hotplug.c
> > @@ -942,6 +942,10 @@ static int online_pages_range(unsigned long start_=
pfn, unsigned long nr_pages,
> >  	if (PageReserved(pfn_to_page(start_pfn)))
> >  		for (i =3D 0; i < nr_pages; i++) {
> >  			page =3D pfn_to_page(start_pfn + i);
> > +			if (PageHWPoison(page)) {
> > +				ClearPageReserved(page);
>
> Why do we clear page reserved? Also if the page is marked PageHWPoison, i=
t
> was never offlined to begin with? Or do you expect this to be set on newl=
y
> hotplugged memory? Also don't we need to skip the entire pageblock?

If I read correctly, to "skip HWPoiosned page" in commit b023f46813cd means
that we skip the page status check for hwpoisoned pages *not* to prevent
memory offlining for memblocks with hwpoisoned pages. That means that
hwpoisoned pages can be offlined.

And another reason to clear PageReserved is that we could reuse the
hwpoisoned page after onlining back with replacing the broken DIMM.
In this usecase, we first do unpoisoning to clear PageHWPoison,
but it doesn't work if PageReserved is set. My simple testing shows
the BUG below in unpoisoning (without the ClearPageReserved):

  Unpoison: Software-unpoisoned page 0x18000
  BUG: Bad page state in process page-types  pfn:18000
  page:ffffda5440600000 count:0 mapcount:0 mapping:          (null) index:0=
x70006b599
  flags: 0x1fffc00004081a(error|uptodate|dirty|reserved|swapbacked)
  raw: 001fffc00004081a 0000000000000000 000000070006b599 00000000ffffffff
  raw: dead000000000100 dead000000000200 0000000000000000 0000000000000000
  page dumped because: PAGE_FLAGS_CHECK_AT_FREE flag(s) set
  bad because of flags: 0x800(reserved)

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
