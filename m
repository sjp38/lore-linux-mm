Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 698F96B000C
	for <linux-mm@kvack.org>; Mon,  1 Oct 2018 10:35:21 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 132-v6so15484837pga.18
        for <linux-mm@kvack.org>; Mon, 01 Oct 2018 07:35:21 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id n1-v6si12942113pld.429.2018.10.01.07.35.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Oct 2018 07:35:20 -0700 (PDT)
Subject: Re: [PATCH 3/4] infiniband/mm: convert to the new put_user_page()
 call
References: <20180928053949.5381-1-jhubbard@nvidia.com>
 <20180928053949.5381-3-jhubbard@nvidia.com> <20180928153922.GA17076@ziepe.ca>
 <36bc65a3-8c2a-87df-44fc-89a1891b86db@nvidia.com>
From: Dennis Dalessandro <dennis.dalessandro@intel.com>
Message-ID: <ed9cbf0a-acc9-1b26-a7fc-e8f89f577ce9@intel.com>
Date: Mon, 1 Oct 2018 10:35:02 -0400
MIME-Version: 1.0
In-Reply-To: <36bc65a3-8c2a-87df-44fc-89a1891b86db@nvidia.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>, Jason Gunthorpe <jgg@ziepe.ca>, john.hubbard@gmail.com
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Doug Ledford <dledford@redhat.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Christian Benvenuti <benve@cisco.com>

On 9/28/2018 11:12 PM, John Hubbard wrote:
> On 9/28/18 8:39 AM, Jason Gunthorpe wrote:
>> On Thu, Sep 27, 2018 at 10:39:47PM -0700, john.hubbard@gmail.com wrote:
>>> From: John Hubbard <jhubbard@nvidia.com>
> [...]
>>>
>>> diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/umem.c
>>> index a41792dbae1f..9430d697cb9f 100644
>>> +++ b/drivers/infiniband/core/umem.c
>>> @@ -60,7 +60,7 @@ static void __ib_umem_release(struct ib_device *dev, struct ib_umem *umem, int d
>>>   		page = sg_page(sg);
>>>   		if (!PageDirty(page) && umem->writable && dirty)
>>>   			set_page_dirty_lock(page);
>>> -		put_page(page);
>>> +		put_user_page(page);
>>
>> Would it make sense to have a release/put_user_pages_dirtied to absorb
>> the set_page_dity pattern too? I notice in this patch there is some
>> variety here, I wonder what is the right way?
>>
>> Also, I'm told this code here is a big performance bottleneck when the
>> number of pages becomes very long (think >> GB of memory), so having a
>> future path to use some kind of batching/threading sound great.
>>
> 
> Yes. And you asked for this the first time, too. Consistent! :) Sorry for
> being slow to pick it up. It looks like there are several patterns, and
> we have to support both set_page_dirty() and set_page_dirty_lock(). So
> the best combination looks to be adding a few variations of
> release_user_pages*(), but leaving put_user_page() alone, because it's
> the "do it yourself" basic one. Scatter-gather will be stuck with that.
> 
> Here's a differential patch with that, that shows a nice little cleanup in
> a couple of IB places, and as you point out, it also provides the hooks for
> performance upgrades (via batching) in the future.
> 
> Does this API look about right?

I'm on board with that and the changes to hfi1 and qib.

Reviewed-by: Dennis Dalessandro <dennis.dalessandro@intel.com>
