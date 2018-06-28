Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 41EAD6B000A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 22:43:07 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id j11-v6so3953221qtf.15
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 19:43:07 -0700 (PDT)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id f54-v6si5736552qvh.216.2018.06.27.19.43.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 19:43:06 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm: set PG_dma_pinned on get_user_pages*()
References: <CAPcyv4iacHYxGmyWokFrVsmxvLj7=phqp2i0tv8z6AT-mYuEEA@mail.gmail.com>
 <3898ef6b-2fa0-e852-a9ac-d904b47320d5@nvidia.com>
 <CAPcyv4iRBzmwWn_9zDvqdfVmTZL_Gn7uA_26A1T-kJib=84tvA@mail.gmail.com>
 <20180626134757.GY28965@dhcp22.suse.cz>
 <20180626164825.fz4m2lv6hydbdrds@quack2.suse.cz>
 <20180627113221.GO32348@dhcp22.suse.cz>
 <20180627115349.cu2k3ainqqdrrepz@quack2.suse.cz>
 <20180627115927.GQ32348@dhcp22.suse.cz>
 <20180627124255.np2a6rxy6rb6v7mm@quack2.suse.cz>
 <20180627145718.GB20171@ziepe.ca>
 <20180627170246.qfvucs72seqabaef@quack2.suse.cz>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <1f6e79c5-5801-16d2-18a6-66bd0712b5b8@nvidia.com>
Date: Wed, 27 Jun 2018 19:42:01 -0700
MIME-Version: 1.0
In-Reply-To: <20180627170246.qfvucs72seqabaef@quack2.suse.cz>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>
Cc: Michal Hocko <mhocko@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Christoph Hellwig <hch@lst.de>, John Hubbard <john.hubbard@gmail.com>, Matthew Wilcox <willy@infradead.org>, Christopher Lameter <cl@linux.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>

On 06/27/2018 10:02 AM, Jan Kara wrote:
> On Wed 27-06-18 08:57:18, Jason Gunthorpe wrote:
>> On Wed, Jun 27, 2018 at 02:42:55PM +0200, Jan Kara wrote:
>>> On Wed 27-06-18 13:59:27, Michal Hocko wrote:
>>>> On Wed 27-06-18 13:53:49, Jan Kara wrote:
>>>>> On Wed 27-06-18 13:32:21, Michal Hocko wrote:
>>>> [...]
>>>>>> Appart from that, do we really care about 32b here? Big DIO, IB users
>>>>>> seem to be 64b only AFAIU.
>>>>>
>>>>> IMO it is a bad habit to leave unpriviledged-user-triggerable oops in the
>>>>> kernel even for uncommon platforms...
>>>>
>>>> Absolutely agreed! I didn't mean to keep the blow up for 32b. I just
>>>> wanted to say that we can stay with a simple solution for 32b. I thought
>>>> the g-u-p-longterm has plugged the most obvious breakage already. But
>>>> maybe I just misunderstood.
>>>
>>> Most yes, but if you try hard enough, you can still trigger the oops e.g.
>>> with appropriately set up direct IO when racing with writeback / reclaim.
>>
>> gup longterm is only different from normal gup if you have DAX and few
>> people do, which really means it doesn't help at all.. AFAIK??
> 
> Right, what I wrote works only for DAX. For non-DAX situation g-u-p
> longterm does not currently help at all. Sorry for confusion.
> 

OK, I've got an early version of this up and running, reusing the page->lru
fields. I'll clean it up and do some heavier testing, and post as a PATCH v2.

One question though: I'm still vague on the best actions to take in the following
functions:

    page_mkclean_one
    try_to_unmap_one

At the moment, they are both just doing an evil little early-out:

	if (PageDmaPinned(page))
		return false;

...but we talked about maybe waiting for the condition to clear, instead? Thoughts?

And if so, does it sound reasonable to refactor wait_on_page_bit_common(),
so that it learns how to wait for a bit that, while inside struct page, is
not within page->flags?


thanks,
-- 
John Hubbard
NVIDIA
