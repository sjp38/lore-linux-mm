Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 399816B007E
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 09:36:52 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id d71so88548071ith.1
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 06:36:52 -0700 (PDT)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id 3si6107147pft.27.2016.06.16.06.36.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jun 2016 06:36:51 -0700 (PDT)
Received: by mail-pa0-x244.google.com with SMTP id hf6so3770055pac.2
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 06:36:51 -0700 (PDT)
Date: Thu, 16 Jun 2016 22:36:38 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH] ARM: mm: Speed up page list initialization during boot
Message-ID: <20160616133638.GA523@swordfish>
References: <004001d14158$114be8d0$33e3ba70$@samsung.com>
 <005101d14158$b50842c0$1f18c840$@samsung.com>
 <CAJFHJrpgHmcXBwuV5i4nH4SOL-OwrY2-+Fe7x9W2c6GWW=F7bg@mail.gmail.com>
 <20160102103722.GQ8644@n2100.arm.linux.org.uk>
 <002c01d1479f$49ea2970$ddbe7c50$@samsung.com>
 <20160616021813.GB658@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160616021813.GB658@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: 'Chirantan Ekbote' <chirantan@chromium.org>, Jungseung Lee <js07.lee@samsung.com>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, js07.lee@gmail.com, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (06/16/16 11:18), Sergey Senozhatsky wrote:
> On (01/05/16 18:56), Jungseung Lee wrote:
> [..]
> > > > >> #ifdef CONFIG_HIGHMEM
> > > > >> static inline void free_area_high(unsigned long pfn, unsigned long
> > > > >>end)  {
> > > > >>-      for (; pfn < end; pfn++)
> > > > >>-              free_highmem_page(pfn_to_page(pfn));
> > > > >>+      while (pfn < end) {
> > > > >>+              struct page *page = pfn_to_page(pfn);
> > > > >>+              unsigned long order = min(__ffs(pfn), MAX_ORDER - 1);
> > > > >>+              unsigned long nr_pages = 1 << order;
> > > > >>+              unsigned long rem = end - pfn;
> > > > >>+
> > > > >>+              if (nr_pages > rem) {
> > > > >>+                      order = __fls(rem);
> > > > >>+                      nr_pages = 1 << order;
> > > > >>+              }
> > > > >>+
> > > > >>+              __free_pages_bootmem(page, order);
> > > > >>+              totalram_pages += nr_pages;
> > > > >>+              totalhigh_pages += nr_pages;
> 
> +			page_zone(page)->managed_pages += nr_pages;  ???

ah, no. __free_pages_boot_core() seems to do it. sorry for the noise.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
