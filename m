Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 149766B72C9
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 00:53:08 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id k76so11917780oih.13
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 21:53:08 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t4sor9951935oie.171.2018.12.04.21.53.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Dec 2018 21:53:07 -0800 (PST)
MIME-Version: 1.0
References: <20181204001720.26138-1-jhubbard@nvidia.com> <20181204001720.26138-2-jhubbard@nvidia.com>
 <CAPcyv4h99JVHAS7Q7k3iPPUq+oc1NxHdyBHMjpgyesF1EjVfWA@mail.gmail.com>
 <a0adcf7c-5592-f003-abc5-a2645eb1d5df@nvidia.com> <CAPcyv4iNtamDAY9raab=iXhSZByecedBpnGybjLM+PuDMwq7SQ@mail.gmail.com>
 <3c91d335-921c-4704-d159-2975ff3a5f20@nvidia.com> <20181205011519.GV10377@bombadil.infradead.org>
In-Reply-To: <20181205011519.GV10377@bombadil.infradead.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 4 Dec 2018 21:52:54 -0800
Message-ID: <CAPcyv4iFi-gU8POphX=wHoMLFweC6D36PVf-yLmMqwUqD19bVw@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: John Hubbard <jhubbard@nvidia.com>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Tue, Dec 4, 2018 at 5:15 PM Matthew Wilcox <willy@infradead.org> wrote:
>
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

I don't use page->private, but page->index is used by the
memory-failure path to do an rmap.
