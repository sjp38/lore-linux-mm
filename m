Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6CB3C6B0003
	for <linux-mm@kvack.org>; Sun, 17 Jun 2018 16:28:42 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id p12-v6so12471234qtg.5
        for <linux-mm@kvack.org>; Sun, 17 Jun 2018 13:28:42 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id g43-v6si6164282qvd.192.2018.06.17.13.28.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Jun 2018 13:28:41 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm: set PG_dma_pinned on get_user_pages*()
References: <20180617012510.20139-1-jhubbard@nvidia.com>
 <20180617012510.20139-3-jhubbard@nvidia.com>
 <CAPcyv4i=eky-QrPcLUEqjsASuRUrFEWqf79hWe0mU8xtz6Jk-w@mail.gmail.com>
 <20180617200432.krw36wrcwidb25cj@ziepe.ca>
 <CAPcyv4gayKk_zHDYAvntware12qMXWjnnL_FDJNUQsJS_zNfDw@mail.gmail.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <311eba48-60f1-b6cc-d001-5cc3ed4d76a9@nvidia.com>
Date: Sun, 17 Jun 2018 13:28:18 -0700
MIME-Version: 1.0
In-Reply-To: <CAPcyv4gayKk_zHDYAvntware12qMXWjnnL_FDJNUQsJS_zNfDw@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, Jason Gunthorpe <jgg@ziepe.ca>
Cc: john.hubbard@gmail.com, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jan Kara <jack@suse.cz>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, Christoph Hellwig <hch@lst.de>

On 06/17/2018 01:10 PM, Dan Williams wrote:
> On Sun, Jun 17, 2018 at 1:04 PM, Jason Gunthorpe <jgg@ziepe.ca> wrote:
>> On Sun, Jun 17, 2018 at 12:53:04PM -0700, Dan Williams wrote:
>>>> diff --git a/mm/rmap.c b/mm/rmap.c
>>>> index 6db729dc4c50..37576f0a4645 100644
>>>> +++ b/mm/rmap.c
>>>> @@ -1360,6 +1360,8 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>>>>                                 flags & TTU_SPLIT_FREEZE, page);
>>>>         }
>>>>
>>>> +       if (PageDmaPinned(page))
>>>> +               return false;
>>>>         /*
>>>>          * We have to assume the worse case ie pmd for invalidation. Note that
>>>>          * the page can not be free in this function as call of try_to_unmap()
>>>
>>> We have a similiar problem with DAX and the conclusion we came to is
>>> that it is not acceptable for userspace to arbitrarily block kernel
>>> actions. The conclusion there was: 'wait' if the DMA is transient, and
>>> 'revoke' if the DMA is long lived, or otherwise 'block' long-lived DMA
>>> if a revocation mechanism is not available.
>>
>> This might be the right answer for certain things, but it shouldn't be
>> the immediate reaction to everthing. There are many user APIs that
>> block kernel actions and hold kernel resources.
>>
>> IMHO, there should be an identifiable objection, eg is blocking going
>> to create a DOS, dead-lock, insecurity, etc?
> 
> I believe kernel behavior regression is a primary concern as now
> fallocate() and truncate() can randomly fail where they didn't before.
> 

Yes. However, my thinking was: get_user_pages() can become a way to indicate that 
these pages are going to be treated specially. In particular, the caller
does not really want or need to support certain file operations, while the
page is flagged this way.

If necessary, we could add a new API call. But either way, I think we could
reasonably document that "if you pin these pages (either via get_user_pages,
or some new, similar-looking API call), you can DMA to/from them, and safely
mark them as dirty when you're done, and the right things will happen. 
And in the interim, you can expect that the follow file system API calls
will not behave predictably: fallocate, truncate, ..."

Maybe in the near future, we can remove that last qualification, if we
find a more comprehensive design for this (as opposed to this cheap fix
I'm proposing here).
