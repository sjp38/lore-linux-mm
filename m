Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 76C876B0003
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 10:14:46 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id f207-v6so2729334qke.22
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 07:14:46 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id y18-v6si2300335qva.42.2018.06.20.07.14.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jun 2018 07:14:44 -0700 (PDT)
Date: Wed, 20 Jun 2018 17:14:41 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [virtio-dev] Re: [PATCH v33 2/4] virtio-balloon:
 VIRTIO_BALLOON_F_FREE_PAGE_HINT
Message-ID: <20180620171320-mutt-send-email-mst@kernel.org>
References: <20180615144000-mutt-send-email-mst@kernel.org>
 <286AC319A985734F985F78AFA26841F7396A3D04@shsmsx102.ccr.corp.intel.com>
 <20180615171635-mutt-send-email-mst@kernel.org>
 <286AC319A985734F985F78AFA26841F7396A5CB0@shsmsx102.ccr.corp.intel.com>
 <20180618051637-mutt-send-email-mst@kernel.org>
 <286AC319A985734F985F78AFA26841F7396AA10C@shsmsx102.ccr.corp.intel.com>
 <20180619055449-mutt-send-email-mst@kernel.org>
 <5B28F371.9020308@intel.com>
 <20180619173256-mutt-send-email-mst@kernel.org>
 <286AC319A985734F985F78AFA26841F7396AE2EC@shsmsx102.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <286AC319A985734F985F78AFA26841F7396AE2EC@shsmsx102.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Wei W" <wei.w.wang@intel.com>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mhocko@kernel.org" <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu0@gmail.com" <quan.xu0@gmail.com>, "nilal@redhat.com" <nilal@redhat.com>, "riel@redhat.com" <riel@redhat.com>, "peterx@redhat.com" <peterx@redhat.com>

On Wed, Jun 20, 2018 at 09:11:39AM +0000, Wang, Wei W wrote:
> On Tuesday, June 19, 2018 10:43 PM, Michael S. Tsirk wrote:
> > On Tue, Jun 19, 2018 at 08:13:37PM +0800, Wei Wang wrote:
> > > On 06/19/2018 11:05 AM, Michael S. Tsirkin wrote:
> > > > On Tue, Jun 19, 2018 at 01:06:48AM +0000, Wang, Wei W wrote:
> > > > > On Monday, June 18, 2018 10:29 AM, Michael S. Tsirkin wrote:
> > > > > > On Sat, Jun 16, 2018 at 01:09:44AM +0000, Wang, Wei W wrote:
> > > > > > > Not necessarily, I think. We have min(4m_page_blocks / 512,
> > > > > > > 1024) above,
> > > > > > so the maximum memory that can be reported is 2TB. For larger
> > guests, e.g.
> > > > > > 4TB, the optimization can still offer 2TB free memory (better
> > > > > > than no optimization).
> > > > > >
> > > > > > Maybe it's better, maybe it isn't. It certainly muddies the waters even
> > more.
> > > > > > I'd rather we had a better plan. From that POV I like what
> > > > > > Matthew Wilcox suggested for this which is to steal the necessary # of
> > entries off the list.
> > > > > Actually what Matthew suggested doesn't make a difference here.
> > > > > That method always steal the first free page blocks, and sure can
> > > > > be changed to take more. But all these can be achieved via kmalloc
> > > > I'd do get_user_pages really. You don't want pages split, etc.
> > 
> > Oops sorry. I meant get_free_pages .
> 
> Yes, we can use __get_free_pages, and the max allocation is MAX_ORDER - 1, which can report up to 2TB free memory. 
> 
> "getting two pages isn't harder", do you mean passing two arrays (two allocations by get_free_pages(,MAX_ORDER -1)) to the mm API?

Yes, or generally a list of pages with as many as needed.


> Please see if the following logic aligns to what you think:
> 
>         uint32_t i, max_hints, hints_per_page, hints_per_array, total_arrays;
>         unsigned long *arrays;
>  
>      /*
>          * Each array size is MAX_ORDER_NR_PAGES. If one array is not enough to
>          * store all the hints, we need to allocate multiple arrays.
>          * max_hints: the max number of 4MB free page blocks
>          * hints_per_page: the number of hints each page can store
>          * hints_per_array: the number of hints an array can store
>          * total_arrays: the number of arrays we need
>          */
>         max_hints = totalram_pages / MAX_ORDER_NR_PAGES;
>         hints_per_page = PAGE_SIZE / sizeof(__le64);
>         hints_per_array = hints_per_page * MAX_ORDER_NR_PAGES;
>         total_arrays = max_hints /  hints_per_array +
>                        !!(max_hints % hints_per_array);
>         arrays = kmalloc(total_arrays * sizeof(unsigned long), GFP_KERNEL);
>         for (i = 0; i < total_arrays; i++) {
>                 arrays[i] = __get_free_pages(__GFP_ATOMIC | __GFP_NOMEMALLOC, MAX_ORDER - 1);
> 
>               if (!arrays[i])
>                       goto out;
>         }
> 
> 
> - the mm API needs to be changed to support storing hints to multiple separated arrays offered by the caller.
> 
> Best,
> Wei

Yes. And add an API to just count entries so we know how many arrays to allocate.

-- 
MST
