Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4CAFF6B0005
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 22:18:15 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id fg1so63156291pad.1
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 19:18:15 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id l8si4351125pal.70.2016.06.15.19.18.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jun 2016 19:18:14 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id t190so2860015pfb.2
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 19:18:14 -0700 (PDT)
Date: Thu, 16 Jun 2016 11:18:13 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] ARM: mm: Speed up page list initialization during boot
Message-ID: <20160616021813.GB658@swordfish>
References: <004001d14158$114be8d0$33e3ba70$@samsung.com>
 <005101d14158$b50842c0$1f18c840$@samsung.com>
 <CAJFHJrpgHmcXBwuV5i4nH4SOL-OwrY2-+Fe7x9W2c6GWW=F7bg@mail.gmail.com>
 <20160102103722.GQ8644@n2100.arm.linux.org.uk>
 <002c01d1479f$49ea2970$ddbe7c50$@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <002c01d1479f$49ea2970$ddbe7c50$@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Chirantan Ekbote' <chirantan@chromium.org>
Cc: Jungseung Lee <js07.lee@samsung.com>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, js07.lee@gmail.com, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (01/05/16 18:56), Jungseung Lee wrote:
[..]
> > > >> #ifdef CONFIG_HIGHMEM
> > > >> static inline void free_area_high(unsigned long pfn, unsigned long
> > > >>end)  {
> > > >>-      for (; pfn < end; pfn++)
> > > >>-              free_highmem_page(pfn_to_page(pfn));
> > > >>+      while (pfn < end) {
> > > >>+              struct page *page = pfn_to_page(pfn);
> > > >>+              unsigned long order = min(__ffs(pfn), MAX_ORDER - 1);
> > > >>+              unsigned long nr_pages = 1 << order;
> > > >>+              unsigned long rem = end - pfn;
> > > >>+
> > > >>+              if (nr_pages > rem) {
> > > >>+                      order = __fls(rem);
> > > >>+                      nr_pages = 1 << order;
> > > >>+              }
> > > >>+
> > > >>+              __free_pages_bootmem(page, order);
> > > >>+              totalram_pages += nr_pages;
> > > >>+              totalhigh_pages += nr_pages;

+			page_zone(page)->managed_pages += nr_pages;  ???

> > > >>+              pfn += nr_pages;
> > > >>+      }
> > > >> }

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
