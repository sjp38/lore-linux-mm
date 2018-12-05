Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 395806B71C8
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 20:44:48 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id n68so18477235qkn.8
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 17:44:48 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o27si312678qto.166.2018.12.04.17.44.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 17:44:47 -0800 (PST)
Date: Tue, 4 Dec 2018 20:44:41 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181205014441.GA3045@redhat.com>
References: <20181204001720.26138-1-jhubbard@nvidia.com>
 <20181204001720.26138-2-jhubbard@nvidia.com>
 <CAPcyv4h99JVHAS7Q7k3iPPUq+oc1NxHdyBHMjpgyesF1EjVfWA@mail.gmail.com>
 <a0adcf7c-5592-f003-abc5-a2645eb1d5df@nvidia.com>
 <CAPcyv4iNtamDAY9raab=iXhSZByecedBpnGybjLM+PuDMwq7SQ@mail.gmail.com>
 <3c91d335-921c-4704-d159-2975ff3a5f20@nvidia.com>
 <20181205011519.GV10377@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181205011519.GV10377@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Tue, Dec 04, 2018 at 05:15:19PM -0800, Matthew Wilcox wrote:
> On Tue, Dec 04, 2018 at 04:58:01PM -0800, John Hubbard wrote:
> > On 12/4/18 3:03 PM, Dan Williams wrote:
> > > Except the LRU fields are already in use for ZONE_DEVICE pages... how
> > > does this proposal interact with those?
> > 
> > Very badly: page->pgmap and page->hmm_data both get corrupted. Is there an entire
> > use case I'm missing: calling get_user_pages() on ZONE_DEVICE pages? Said another
> > way: is it reasonable to disallow calling get_user_pages() on ZONE_DEVICE pages?
> > 
> > If we have to support get_user_pages() on ZONE_DEVICE pages, then the whole 
> > LRU field approach is unusable.
> 
> We just need to rearrange ZONE_DEVICE pages.  Please excuse the whitespace
> damage:
> 
> +++ b/include/linux/mm_types.h
> @@ -151,10 +151,12 @@ struct page {
>  #endif
>                 };
>                 struct {        /* ZONE_DEVICE pages */
> +                       unsigned long _zd_pad_2;        /* LRU */
> +                       unsigned long _zd_pad_3;        /* LRU */
> +                       unsigned long _zd_pad_1;        /* uses mapping */
>                         /** @pgmap: Points to the hosting device page map. */
>                         struct dev_pagemap *pgmap;
>                         unsigned long hmm_data;
> -                       unsigned long _zd_pad_1;        /* uses mapping */
>                 };
>  
>                 /** @rcu_head: You can use this to free a page by RCU. */
> 
> You don't use page->private or page->index, do you Dan?

page->private and page->index are use by HMM DEVICE page.

Cheers,
J�r�me
