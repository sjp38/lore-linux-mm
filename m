Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id DF1986B0003
	for <linux-mm@kvack.org>; Sun, 17 Jun 2018 18:20:14 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id o140-v6so12978004qke.12
        for <linux-mm@kvack.org>; Sun, 17 Jun 2018 15:20:14 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id w195-v6si11915645qka.252.2018.06.17.15.20.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Jun 2018 15:20:14 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm: set PG_dma_pinned on get_user_pages*()
References: <20180617012510.20139-1-jhubbard@nvidia.com>
 <20180617012510.20139-3-jhubbard@nvidia.com>
 <CAPcyv4i=eky-QrPcLUEqjsASuRUrFEWqf79hWe0mU8xtz6Jk-w@mail.gmail.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <817a7466-2abb-bc95-e7de-269420841c9b@nvidia.com>
Date: Sun, 17 Jun 2018 15:19:51 -0700
MIME-Version: 1.0
In-Reply-To: <CAPcyv4i=eky-QrPcLUEqjsASuRUrFEWqf79hWe0mU8xtz6Jk-w@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, john.hubbard@gmail.com
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Jan Kara <jack@suse.cz>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, Christoph Hellwig <hch@lst.de>

On 06/17/2018 12:53 PM, Dan Williams wrote:
> [..]
>> diff --git a/mm/rmap.c b/mm/rmap.c
>> index 6db729dc4c50..37576f0a4645 100644
>> --- a/mm/rmap.c
>> +++ b/mm/rmap.c
>> @@ -1360,6 +1360,8 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>>                                 flags & TTU_SPLIT_FREEZE, page);
>>         }
>>
>> +       if (PageDmaPinned(page))
>> +               return false;
>>         /*
>>          * We have to assume the worse case ie pmd for invalidation. Note that
>>          * the page can not be free in this function as call of try_to_unmap()
> 
> We have a similiar problem with DAX and the conclusion we came to is
> that it is not acceptable for userspace to arbitrarily block kernel
> actions. The conclusion there was: 'wait' if the DMA is transient, and
> 'revoke' if the DMA is long lived, or otherwise 'block' long-lived DMA
> if a revocation mechanism is not available.
> 

Dan, thanks...can you please say a few words (or point to the code) about the "revoke" part of
this design? And whether you think it could be applied here (instead of the unconditional
appproach I have above)?
