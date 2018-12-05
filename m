Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id C12706B71AB
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 20:15:25 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id x7so13754492pll.23
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 17:15:25 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f11si18803996plr.341.2018.12.04.17.15.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Dec 2018 17:15:24 -0800 (PST)
Date: Tue, 4 Dec 2018 17:15:19 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181205011519.GV10377@bombadil.infradead.org>
References: <20181204001720.26138-1-jhubbard@nvidia.com>
 <20181204001720.26138-2-jhubbard@nvidia.com>
 <CAPcyv4h99JVHAS7Q7k3iPPUq+oc1NxHdyBHMjpgyesF1EjVfWA@mail.gmail.com>
 <a0adcf7c-5592-f003-abc5-a2645eb1d5df@nvidia.com>
 <CAPcyv4iNtamDAY9raab=iXhSZByecedBpnGybjLM+PuDMwq7SQ@mail.gmail.com>
 <3c91d335-921c-4704-d159-2975ff3a5f20@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3c91d335-921c-4704-d159-2975ff3a5f20@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Dan Williams <dan.j.williams@intel.com>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Tue, Dec 04, 2018 at 04:58:01PM -0800, John Hubbard wrote:
> On 12/4/18 3:03 PM, Dan Williams wrote:
> > Except the LRU fields are already in use for ZONE_DEVICE pages... how
> > does this proposal interact with those?
> 
> Very badly: page->pgmap and page->hmm_data both get corrupted. Is there an entire
> use case I'm missing: calling get_user_pages() on ZONE_DEVICE pages? Said another
> way: is it reasonable to disallow calling get_user_pages() on ZONE_DEVICE pages?
> 
> If we have to support get_user_pages() on ZONE_DEVICE pages, then the whole 
> LRU field approach is unusable.

We just need to rearrange ZONE_DEVICE pages.  Please excuse the whitespace
damage:

+++ b/include/linux/mm_types.h
@@ -151,10 +151,12 @@ struct page {
 #endif
                };
                struct {        /* ZONE_DEVICE pages */
+                       unsigned long _zd_pad_2;        /* LRU */
+                       unsigned long _zd_pad_3;        /* LRU */
+                       unsigned long _zd_pad_1;        /* uses mapping */
                        /** @pgmap: Points to the hosting device page map. */
                        struct dev_pagemap *pgmap;
                        unsigned long hmm_data;
-                       unsigned long _zd_pad_1;        /* uses mapping */
                };
 
                /** @rcu_head: You can use this to free a page by RCU. */

You don't use page->private or page->index, do you Dan?
