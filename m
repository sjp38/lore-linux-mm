Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 179C96B70CA
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 16:56:39 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id 68so15067790pfr.6
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 13:56:39 -0800 (PST)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id r196si16311503pgr.311.2018.12.04.13.56.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 13:56:37 -0800 (PST)
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
References: <20181204001720.26138-1-jhubbard@nvidia.com>
 <20181204001720.26138-2-jhubbard@nvidia.com>
 <CAPcyv4h99JVHAS7Q7k3iPPUq+oc1NxHdyBHMjpgyesF1EjVfWA@mail.gmail.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <a0adcf7c-5592-f003-abc5-a2645eb1d5df@nvidia.com>
Date: Tue, 4 Dec 2018 13:56:36 -0800
MIME-Version: 1.0
In-Reply-To: <CAPcyv4h99JVHAS7Q7k3iPPUq+oc1NxHdyBHMjpgyesF1EjVfWA@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, John Hubbard <john.hubbard@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On 12/4/18 12:28 PM, Dan Williams wrote:
> On Mon, Dec 3, 2018 at 4:17 PM <john.hubbard@gmail.com> wrote:
>>
>> From: John Hubbard <jhubbard@nvidia.com>
>>
>> Introduces put_user_page(), which simply calls put_page().
>> This provides a way to update all get_user_pages*() callers,
>> so that they call put_user_page(), instead of put_page().
>>
>> Also introduces put_user_pages(), and a few dirty/locked variations,
>> as a replacement for release_pages(), and also as a replacement
>> for open-coded loops that release multiple pages.
>> These may be used for subsequent performance improvements,
>> via batching of pages to be released.
>>
>> This is the first step of fixing the problem described in [1]. The steps
>> are:
>>
>> 1) (This patch): provide put_user_page*() routines, intended to be used
>>    for releasing pages that were pinned via get_user_pages*().
>>
>> 2) Convert all of the call sites for get_user_pages*(), to
>>    invoke put_user_page*(), instead of put_page(). This involves dozens of
>>    call sites, and will take some time.
>>
>> 3) After (2) is complete, use get_user_pages*() and put_user_page*() to
>>    implement tracking of these pages. This tracking will be separate from
>>    the existing struct page refcounting.
>>
>> 4) Use the tracking and identification of these pages, to implement
>>    special handling (especially in writeback paths) when the pages are
>>    backed by a filesystem. Again, [1] provides details as to why that is
>>    desirable.
> 
> I thought at Plumbers we talked about using a page bit to tag pages
> that have had their reference count elevated by get_user_pages()? That
> way there is no need to distinguish put_page() from put_user_page() it
> just happens internally to put_page(). At the conference Matthew was
> offering to free up a page bit for this purpose.
> 

...but then, upon further discussion in that same session, we realized that
that doesn't help. You need a reference count. Otherwise a random put_page
could affect your dma-pinned pages, etc, etc.

I was not able to actually find any place where a single additional page
bit would help our situation, which is why this still uses LRU fields for
both the two bits required (the RFC [1] still applies), and the dma_pinned_count.


[1] https://lore.kernel.org/r/20181110085041.10071-7-jhubbard@nvidia.com



>> [1] https://lwn.net/Articles/753027/ : "The Trouble with get_user_pages()"
>>
>> Reviewed-by: Jan Kara <jack@suse.cz>
> 
> Wish, you could have been there Jan. I'm missing why it's safe to
> assume that a single put_user_page() is paired with a get_user_page()?
> 

A put_user_page() per page, or a put_user_pages() for an array of pages. See
patch 0002 for several examples.

thanks,
-- 
John Hubbard
NVIDIA
