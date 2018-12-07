Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id DE8F48E0004
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 14:40:15 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id z68so4278189qkb.14
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 11:40:15 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 43si1128635qvn.177.2018.12.07.11.40.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Dec 2018 11:40:14 -0800 (PST)
Date: Fri, 7 Dec 2018 14:40:09 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181207194009.GF3293@redhat.com>
References: <CAPcyv4h99JVHAS7Q7k3iPPUq+oc1NxHdyBHMjpgyesF1EjVfWA@mail.gmail.com>
 <a0adcf7c-5592-f003-abc5-a2645eb1d5df@nvidia.com>
 <CAPcyv4iNtamDAY9raab=iXhSZByecedBpnGybjLM+PuDMwq7SQ@mail.gmail.com>
 <3c91d335-921c-4704-d159-2975ff3a5f20@nvidia.com>
 <20181205011519.GV10377@bombadil.infradead.org>
 <20181205014441.GA3045@redhat.com>
 <59ca5c4b-fd5b-1fc6-f891-c7986d91908e@nvidia.com>
 <7b4733be-13d3-c790-ff1b-ac51b505e9a6@nvidia.com>
 <20181207191620.GD3293@redhat.com>
 <CAPcyv4ig0Lg+6Abc+P9guOSdszk0B4LyHGh=wXf_kMzGs=5oww@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPcyv4ig0Lg+6Abc+P9guOSdszk0B4LyHGh=wXf_kMzGs=5oww@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Fri, Dec 07, 2018 at 11:26:34AM -0800, Dan Williams wrote:
> On Fri, Dec 7, 2018 at 11:16 AM Jerome Glisse <jglisse@redhat.com> wrote:
> >
> > On Thu, Dec 06, 2018 at 06:45:49PM -0800, John Hubbard wrote:
> > > On 12/4/18 5:57 PM, John Hubbard wrote:
> > > > On 12/4/18 5:44 PM, Jerome Glisse wrote:
> > > >> On Tue, Dec 04, 2018 at 05:15:19PM -0800, Matthew Wilcox wrote:
> > > >>> On Tue, Dec 04, 2018 at 04:58:01PM -0800, John Hubbard wrote:
> > > >>>> On 12/4/18 3:03 PM, Dan Williams wrote:
> > > >>>>> Except the LRU fields are already in use for ZONE_DEVICE pages... how
> > > >>>>> does this proposal interact with those?
> > > >>>>
> > > >>>> Very badly: page->pgmap and page->hmm_data both get corrupted. Is there an entire
> > > >>>> use case I'm missing: calling get_user_pages() on ZONE_DEVICE pages? Said another
> > > >>>> way: is it reasonable to disallow calling get_user_pages() on ZONE_DEVICE pages?
> > > >>>>
> > > >>>> If we have to support get_user_pages() on ZONE_DEVICE pages, then the whole
> > > >>>> LRU field approach is unusable.
> > > >>>
> > > >>> We just need to rearrange ZONE_DEVICE pages.  Please excuse the whitespace
> > > >>> damage:
> > > >>>
> > > >>> +++ b/include/linux/mm_types.h
> > > >>> @@ -151,10 +151,12 @@ struct page {
> > > >>>  #endif
> > > >>>                 };
> > > >>>                 struct {        /* ZONE_DEVICE pages */
> > > >>> +                       unsigned long _zd_pad_2;        /* LRU */
> > > >>> +                       unsigned long _zd_pad_3;        /* LRU */
> > > >>> +                       unsigned long _zd_pad_1;        /* uses mapping */
> > > >>>                         /** @pgmap: Points to the hosting device page map. */
> > > >>>                         struct dev_pagemap *pgmap;
> > > >>>                         unsigned long hmm_data;
> > > >>> -                       unsigned long _zd_pad_1;        /* uses mapping */
> > > >>>                 };
> > > >>>
> > > >>>                 /** @rcu_head: You can use this to free a page by RCU. */
> > > >>>
> > > >>> You don't use page->private or page->index, do you Dan?
> > > >>
> > > >> page->private and page->index are use by HMM DEVICE page.
> > > >>
> > > >
> > > > OK, so for the ZONE_DEVICE + HMM case, that leaves just one field remaining for
> > > > dma-pinned information. Which might work. To recap, we need:
> > > >
> > > > -- 1 bit for PageDmaPinned
> > > > -- 1 bit, if using LRU field(s), for PageDmaPinnedWasLru.
> > > > -- N bits for a reference count
> > > >
> > > > Those *could* be packed into a single 64-bit field, if really necessary.
> > > >
> > >
> > > ...actually, this needs to work on 32-bit systems, as well. And HMM is using a lot.
> > > However, it is still possible for this to work.
> > >
> > > Matthew, can I have that bit now please? I'm about out of options, and now it will actually
> > > solve the problem here.
> > >
> > > Given:
> > >
> > > 1) It's cheap to know if a page is ZONE_DEVICE, and ZONE_DEVICE means not on the LRU.
> > > That, in turn, means only 1 bit instead of 2 bits (in addition to a counter) is required,
> > > for that case.
> > >
> > > 2) There is an independent bit available (according to Matthew).
> > >
> > > 3) HMM uses 4 of the 5 struct page fields, so only one field is available for a counter
> > >    in that case.
> >
> > To expend on this, HMM private page are use for anonymous page
> > so the index and mapping fields have the value you expect for
> > such pages. Down the road i want also to support file backed
> > page with HMM private (mapping, private, index).
> >
> > For HMM public both anonymous and file back page are supported
> > today (HMM public is only useful on platform with something like
> > OpenCAPI, CCIX or NVlink ... so PowerPC for now).
> >
> > > 4) get_user_pages() must work on ZONE_DEVICE and HMM pages.
> >
> > get_user_pages() only need to work with HMM public page not the
> > private one as we can not allow _anyone_ to pin HMM private page.
> 
> How does HMM enforce that? Because the kernel should not allow *any*
> memory management facility to arbitrarily fail direct-I/O operations.
> That's why CONFIG_FS_DAX_LIMITED is a temporary / experimental hack
> for S390 and ZONE_DEVICE was invented to bypass that hack for X86 and
> any arch that plans to properly support DAX. I would classify any
> memory management that can't support direct-I/O in the same
> "experimental" category.

It does not fail direct-I/O GUP sees a swap entry for the private
memory and it behave just like if the page was swap to disk so i
am not introducing any new behavior.

With HMM page everything just work as you expect they would from
CPU point of view. It is just like swap.

Cheers,
J�r�me
