Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id A4E9C8E0014
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 01:11:12 -0500 (EST)
Received: by mail-yb1-f200.google.com with SMTP id 7-v6so2467545ybi.19
        for <linux-mm@kvack.org>; Thu, 13 Dec 2018 22:11:12 -0800 (PST)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id 184si2250964ybr.453.2018.12.13.22.11.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Dec 2018 22:11:11 -0800 (PST)
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
References: <20181205014441.GA3045@redhat.com>
 <59ca5c4b-fd5b-1fc6-f891-c7986d91908e@nvidia.com>
 <7b4733be-13d3-c790-ff1b-ac51b505e9a6@nvidia.com>
 <20181207191620.GD3293@redhat.com>
 <3c4d46c0-aced-f96f-1bf3-725d02f11b60@nvidia.com>
 <20181208022445.GA7024@redhat.com> <20181210102846.GC29289@quack2.suse.cz>
 <20181212150319.GA3432@redhat.com> <20181212214641.GB29416@dastard>
 <20181212215931.GG5037@redhat.com> <20181213005119.GD29416@dastard>
 <05a68829-6e6d-b766-11b4-99e1ba4bc87b@nvidia.com>
 <CAPcyv4jyG3YTtghyr04wws_hcSBAmPBpnCm0tFcKgz9VwrV=ow@mail.gmail.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <01cf4e0c-b2d6-225a-3ee9-ef0f7e53684d@nvidia.com>
Date: Thu, 13 Dec 2018 22:11:09 -0800
MIME-Version: 1.0
In-Reply-To: <CAPcyv4jyG3YTtghyr04wws_hcSBAmPBpnCm0tFcKgz9VwrV=ow@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: david <david@fromorbit.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis  <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe" <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On 12/13/18 9:21 PM, Dan Williams wrote:
> On Thu, Dec 13, 2018 at 7:53 PM John Hubbard <jhubbard@nvidia.com> wrote:
>>
>> On 12/12/18 4:51 PM, Dave Chinner wrote:
>>> On Wed, Dec 12, 2018 at 04:59:31PM -0500, Jerome Glisse wrote:
>>>> On Thu, Dec 13, 2018 at 08:46:41AM +1100, Dave Chinner wrote:
>>>>> On Wed, Dec 12, 2018 at 10:03:20AM -0500, Jerome Glisse wrote:
>>>>>> On Mon, Dec 10, 2018 at 11:28:46AM +0100, Jan Kara wrote:
>>>>>>> On Fri 07-12-18 21:24:46, Jerome Glisse wrote:
>>>>>>> So this approach doesn't look like a win to me over using counter in struct
>>>>>>> page and I'd rather try looking into squeezing HMM public page usage of
>>>>>>> struct page so that we can fit that gup counter there as well. I know that
>>>>>>> it may be easier said than done...
>>>>>>
>>
>> Agreed. After all the discussion this week, I'm thinking that the original idea
>> of a per-struct-page counter is better. Fortunately, we can do the moral equivalent
>> of that, unless I'm overlooking something: Jerome had another proposal that he
>> described, off-list, for doing that counting, and his idea avoids the problem of
>> finding space in struct page. (And in fact, when I responded yesterday, I initially
>> thought that's where he was going with this.)
>>
>> So how about this hybrid solution:
>>
>> 1. Stay with the basic RFC approach of using a per-page counter, but actually
>> store the counter(s) in the mappings instead of the struct page. We can use
>> !PageAnon and page_mapping to look up all the mappings, stash the dma_pinned_count
>> there. So the total pinned count is scattered across mappings. Probably still need
>> a PageDmaPinned bit.
> 
> How do you safely look at page->mapping from the get_user_pages_fast()
> path? You'll be racing invalidation disconnecting the page from the
> mapping.
> 

I don't have an answer for that, so maybe the page->mapping idea is dead already. 

So in that case, there is still one more way to do all of this, which is to
combine ZONE_DEVICE, HMM, and gup/dma information in a per-page struct, and get
there via basically page->private, more or less like this:

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 5ed8f6292a53..13f651bb5cc1 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -67,6 +67,13 @@ struct hmm;
 #define _struct_page_alignment
 #endif
 
+struct page_aux {
+       struct dev_pagemap *pgmap;
+       unsigned long hmm_data;
+       unsigned long private;
+       atomic_t dma_pinned_count;
+};
+
 struct page {
        unsigned long flags;            /* Atomic flags, some possibly
                                         * updated asynchronously */
@@ -149,11 +156,13 @@ struct page {
                        spinlock_t ptl;
 #endif
                };
-               struct {        /* ZONE_DEVICE pages */
+               struct {        /* ZONE_DEVICE, HMM or get_user_pages() pages */
                        /** @pgmap: Points to the hosting device page map. */
-                       struct dev_pagemap *pgmap;
-                       unsigned long hmm_data;
-                       unsigned long _zd_pad_1;        /* uses mapping */
+                       unsigned long _zd_pad_1;        /* LRU */
+                       unsigned long _zd_pad_2;        /* LRU */
+                       unsigned long _zd_pad_3;        /* mapping */
+                       unsigned long _zd_pad_4;        /* index */
+                       struct page_aux *aux;           /* private */
                };
 
                /** @rcu_head: You can use this to free a page by RCU. */

...is there any appetite for that approach?

-- 
thanks,
John Hubbard
NVIDIA
