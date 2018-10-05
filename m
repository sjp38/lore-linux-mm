Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id E9DFF6B000D
	for <linux-mm@kvack.org>; Fri,  5 Oct 2018 16:48:33 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id m16-v6so7754532ybp.13
        for <linux-mm@kvack.org>; Fri, 05 Oct 2018 13:48:33 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id k11-v6si2533199ybj.292.2018.10.05.13.48.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Oct 2018 13:48:32 -0700 (PDT)
Subject: Re: [PATCH v2 3/3] infiniband/mm: convert to the new
 put_user_page[s]() calls
References: <20181005040225.14292-1-jhubbard@nvidia.com>
 <20181005040225.14292-4-jhubbard@nvidia.com>
 <20181005152055.GB20776@ziepe.ca>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <a4402c75-8b6d-a09e-07be-864c678ccc4f@nvidia.com>
Date: Fri, 5 Oct 2018 13:48:28 -0700
MIME-Version: 1.0
In-Reply-To: <20181005152055.GB20776@ziepe.ca>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Gunthorpe <jgg@ziepe.ca>, john.hubbard@gmail.com
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Doug Ledford <dledford@redhat.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Christian Benvenuti <benve@cisco.com>

On 10/5/18 8:20 AM, Jason Gunthorpe wrote:
> On Thu, Oct 04, 2018 at 09:02:25PM -0700, john.hubbard@gmail.com wrote:
>> From: John Hubbard <jhubbard@nvidia.com>
>>
>> For code that retains pages via get_user_pages*(),
>> release those pages via the new put_user_page(),
>> instead of put_page().
>>
>> This prepares for eventually fixing the problem described
>> in [1], and is following a plan listed in [2], [3], [4].
>>
>> [1] https://lwn.net/Articles/753027/ : "The Trouble with get_user_pages()"
>>
>> [2] https://lkml.kernel.org/r/20180709080554.21931-1-jhubbard@nvidia.com
>>     Proposed steps for fixing get_user_pages() + DMA problems.
>>
>> [3]https://lkml.kernel.org/r/20180710082100.mkdwngdv5kkrcz6n@quack2.suse.cz
>>     Bounce buffers (otherwise [2] is not really viable).
>>
>> [4] https://lkml.kernel.org/r/20181003162115.GG24030@quack2.suse.cz
>>     Follow-up discussions.
>>
>> CC: Doug Ledford <dledford@redhat.com>
>> CC: Jason Gunthorpe <jgg@ziepe.ca>
>> CC: Mike Marciniszyn <mike.marciniszyn@intel.com>
>> CC: Dennis Dalessandro <dennis.dalessandro@intel.com>
>> CC: Christian Benvenuti <benve@cisco.com>
>>
>> CC: linux-rdma@vger.kernel.org
>> CC: linux-kernel@vger.kernel.org
>> CC: linux-mm@kvack.org
>> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
>>  drivers/infiniband/core/umem.c              |  2 +-
>>  drivers/infiniband/core/umem_odp.c          |  2 +-
>>  drivers/infiniband/hw/hfi1/user_pages.c     | 11 ++++-------
>>  drivers/infiniband/hw/mthca/mthca_memfree.c |  6 +++---
>>  drivers/infiniband/hw/qib/qib_user_pages.c  | 11 ++++-------
>>  drivers/infiniband/hw/qib/qib_user_sdma.c   |  8 ++++----
>>  drivers/infiniband/hw/usnic/usnic_uiom.c    |  2 +-
>>  7 files changed, 18 insertions(+), 24 deletions(-)
>>
>> diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/umem.c
>> index a41792dbae1f..9430d697cb9f 100644
>> +++ b/drivers/infiniband/core/umem.c
>> @@ -60,7 +60,7 @@ static void __ib_umem_release(struct ib_device *dev, struct ib_umem *umem, int d
>>  		page = sg_page(sg);
>>  		if (!PageDirty(page) && umem->writable && dirty)
>>  			set_page_dirty_lock(page);
>> -		put_page(page);
>> +		put_user_page(page);
>>  	}
> 
> How about ?
> 
> if (umem->writable && dirty)
>      put_user_pages_dirty_lock(&page, 1);
> else
>      put_user_page(page);
> 
> ?

OK, I'll make that change.

> 
>> diff --git a/drivers/infiniband/hw/hfi1/user_pages.c b/drivers/infiniband/hw/hfi1/user_pages.c
>> index e341e6dcc388..99ccc0483711 100644
>> +++ b/drivers/infiniband/hw/hfi1/user_pages.c
>> @@ -121,13 +121,10 @@ int hfi1_acquire_user_pages(struct mm_struct *mm, unsigned long vaddr, size_t np
>>  void hfi1_release_user_pages(struct mm_struct *mm, struct page **p,
>>  			     size_t npages, bool dirty)
>>  {
>> -	size_t i;
>> -
>> -	for (i = 0; i < npages; i++) {
>> -		if (dirty)
>> -			set_page_dirty_lock(p[i]);
>> -		put_page(p[i]);
>> -	}
>> +	if (dirty)
>> +		put_user_pages_dirty_lock(p, npages);
>> +	else
>> +		put_user_pages(p, npages);
> 
> And I know Jan gave the feedback to remove the bool argument, but just
> pointing out that quite possibly evey caller will wrapper it in an if
> like this..
> 

Yes, that attracted me, too. It's nice to write the "if" code once, instead of 
many times. But doing it efficiently requires using a bool argument (otherwise,
you end up with another "if" branch, to convert from bool to an enum or flag arg),
and that's generally avoided because no one wants to see code of the form:

   do_this(0, 1, 0, 1);
   do_this(1, 0, 0, 1);

, which, although hilarious, is still evil. haha. Anyway, maybe I'll leave it as-is
for now, to inject some hysteresis into this aspect of the review?


thanks,
-- 
John Hubbard
NVIDIA
