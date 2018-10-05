Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9C43D6B0275
	for <linux-mm@kvack.org>; Fri,  5 Oct 2018 11:20:58 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id e197-v6so2510264ita.9
        for <linux-mm@kvack.org>; Fri, 05 Oct 2018 08:20:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h145-v6sor3332077iof.46.2018.10.05.08.20.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Oct 2018 08:20:57 -0700 (PDT)
Date: Fri, 5 Oct 2018 09:20:55 -0600
From: Jason Gunthorpe <jgg@ziepe.ca>
Subject: Re: [PATCH v2 3/3] infiniband/mm: convert to the new
 put_user_page[s]() calls
Message-ID: <20181005152055.GB20776@ziepe.ca>
References: <20181005040225.14292-1-jhubbard@nvidia.com>
 <20181005040225.14292-4-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181005040225.14292-4-jhubbard@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: john.hubbard@gmail.com
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>, Doug Ledford <dledford@redhat.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Christian Benvenuti <benve@cisco.com>

On Thu, Oct 04, 2018 at 09:02:25PM -0700, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 
> For code that retains pages via get_user_pages*(),
> release those pages via the new put_user_page(),
> instead of put_page().
> 
> This prepares for eventually fixing the problem described
> in [1], and is following a plan listed in [2], [3], [4].
> 
> [1] https://lwn.net/Articles/753027/ : "The Trouble with get_user_pages()"
> 
> [2] https://lkml.kernel.org/r/20180709080554.21931-1-jhubbard@nvidia.com
>     Proposed steps for fixing get_user_pages() + DMA problems.
> 
> [3]https://lkml.kernel.org/r/20180710082100.mkdwngdv5kkrcz6n@quack2.suse.cz
>     Bounce buffers (otherwise [2] is not really viable).
> 
> [4] https://lkml.kernel.org/r/20181003162115.GG24030@quack2.suse.cz
>     Follow-up discussions.
> 
> CC: Doug Ledford <dledford@redhat.com>
> CC: Jason Gunthorpe <jgg@ziepe.ca>
> CC: Mike Marciniszyn <mike.marciniszyn@intel.com>
> CC: Dennis Dalessandro <dennis.dalessandro@intel.com>
> CC: Christian Benvenuti <benve@cisco.com>
> 
> CC: linux-rdma@vger.kernel.org
> CC: linux-kernel@vger.kernel.org
> CC: linux-mm@kvack.org
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
>  drivers/infiniband/core/umem.c              |  2 +-
>  drivers/infiniband/core/umem_odp.c          |  2 +-
>  drivers/infiniband/hw/hfi1/user_pages.c     | 11 ++++-------
>  drivers/infiniband/hw/mthca/mthca_memfree.c |  6 +++---
>  drivers/infiniband/hw/qib/qib_user_pages.c  | 11 ++++-------
>  drivers/infiniband/hw/qib/qib_user_sdma.c   |  8 ++++----
>  drivers/infiniband/hw/usnic/usnic_uiom.c    |  2 +-
>  7 files changed, 18 insertions(+), 24 deletions(-)
> 
> diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/umem.c
> index a41792dbae1f..9430d697cb9f 100644
> +++ b/drivers/infiniband/core/umem.c
> @@ -60,7 +60,7 @@ static void __ib_umem_release(struct ib_device *dev, struct ib_umem *umem, int d
>  		page = sg_page(sg);
>  		if (!PageDirty(page) && umem->writable && dirty)
>  			set_page_dirty_lock(page);
> -		put_page(page);
> +		put_user_page(page);
>  	}

How about ?

if (umem->writable && dirty)
     put_user_pages_dirty_lock(&page, 1);
else
     put_user_page(page);

?

> diff --git a/drivers/infiniband/hw/hfi1/user_pages.c b/drivers/infiniband/hw/hfi1/user_pages.c
> index e341e6dcc388..99ccc0483711 100644
> +++ b/drivers/infiniband/hw/hfi1/user_pages.c
> @@ -121,13 +121,10 @@ int hfi1_acquire_user_pages(struct mm_struct *mm, unsigned long vaddr, size_t np
>  void hfi1_release_user_pages(struct mm_struct *mm, struct page **p,
>  			     size_t npages, bool dirty)
>  {
> -	size_t i;
> -
> -	for (i = 0; i < npages; i++) {
> -		if (dirty)
> -			set_page_dirty_lock(p[i]);
> -		put_page(p[i]);
> -	}
> +	if (dirty)
> +		put_user_pages_dirty_lock(p, npages);
> +	else
> +		put_user_pages(p, npages);

And I know Jan gave the feedback to remove the bool argument, but just
pointing out that quite possibly evey caller will wrapper it in an if
like this..

Jason
