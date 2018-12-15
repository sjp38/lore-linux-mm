Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6425E8E021D
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 19:41:58 -0500 (EST)
Received: by mail-yb1-f200.google.com with SMTP id c76so4075589ybf.13
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 16:41:58 -0800 (PST)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id t63si3655149ywb.383.2018.12.14.16.41.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Dec 2018 16:41:56 -0800 (PST)
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
References: <20181212150319.GA3432@redhat.com>
 <20181212214641.GB29416@dastard> <20181212215931.GG5037@redhat.com>
 <20181213005119.GD29416@dastard>
 <05a68829-6e6d-b766-11b4-99e1ba4bc87b@nvidia.com>
 <CAPcyv4jyG3YTtghyr04wws_hcSBAmPBpnCm0tFcKgz9VwrV=ow@mail.gmail.com>
 <01cf4e0c-b2d6-225a-3ee9-ef0f7e53684d@nvidia.com>
 <CAPcyv4hrbA9H20bi+QMpKNi7r=egstt61MdQSD5Fb293W1btaw@mail.gmail.com>
 <20181214194843.GG10600@bombadil.infradead.org>
 <ed49a260-ffd5-613d-e48b-dfb4b550e8bb@intel.com>
 <20181214200311.GH10600@bombadil.infradead.org>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <2e9396f4-f0c8-8ae2-8044-cd4807d61bca@nvidia.com>
Date: Fri, 14 Dec 2018 16:41:54 -0800
MIME-Version: 1.0
In-Reply-To: <20181214200311.GH10600@bombadil.infradead.org>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Dave Hansen <dave.hansen@intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>, david <david@fromorbit.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Jan Kara <jack@suse.cz>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis  <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe" <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On 12/14/18 12:03 PM, Matthew Wilcox wrote:
> On Fri, Dec 14, 2018 at 11:53:31AM -0800, Dave Hansen wrote:
>> On 12/14/18 11:48 AM, Matthew Wilcox wrote:
>>> I think we can do better than a proxy object with bit 0 set.  I'd go
>>> for allocating something like this:
>>>
>>> struct dynamic_page {
>>> 	struct page;
>>> 	unsigned long vaddr;
>>> 	unsigned long pfn;
>>> 	...
>>> };
>>>
>>> and use a bit in struct page to indicate that this is a dynamic page.
>>
>> That might be fun.  We'd just need a fast/static and slow/dynamic path
>> in page_to_pfn()/pfn_to_page().  We'd also need some kind of auxiliary
>> pfn-to-page structure since we could not fit that^ structure in vmemmap[].
> 
> Yes; working on the pfn-to-page structure right now as it happens ...
> in the meantime, an XArray for it probably wouldn't be _too_ bad.
> 

OK, this looks great. And as Dan pointed out, we get a nice side effect of
type safety for the gup/dma call site conversion. After doing partial 
conversions, the need for type safety (some of the callers really are 
complex) really seems worth the extra work, so that's a big benefit.

Next steps: I want to go try this dynamic_page approach out right away. 
If there are pieces such as page_to_pfn and related, that are already in
progress, I'd definitely like to work on top of that. Also, any up front
advice or pitfalls to avoid is always welcome, of course. :)

thanks,
-- 
John Hubbard
NVIDIA
