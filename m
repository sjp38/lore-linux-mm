Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id F14EF6B0271
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 12:28:01 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id t24-v6so3479097eds.12
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 09:28:01 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y9-v6si1333912ejh.20.2018.10.03.09.28.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Oct 2018 09:28:00 -0700 (PDT)
Date: Wed, 3 Oct 2018 18:27:58 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 3/4] infiniband/mm: convert to the new put_user_page()
 call
Message-ID: <20181003162758.GI24030@quack2.suse.cz>
References: <20180928053949.5381-1-jhubbard@nvidia.com>
 <20180928053949.5381-3-jhubbard@nvidia.com>
 <20180928153922.GA17076@ziepe.ca>
 <36bc65a3-8c2a-87df-44fc-89a1891b86db@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <36bc65a3-8c2a-87df-44fc-89a1891b86db@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, john.hubbard@gmail.com, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Doug Ledford <dledford@redhat.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Christian Benvenuti <benve@cisco.com>

On Fri 28-09-18 20:12:33, John Hubbard wrote:
>  static inline void release_user_pages(struct page **pages,
> -                                     unsigned long npages)
> +                                     unsigned long npages,
> +                                     bool set_dirty)
>  {
> -       while (npages)
> -               put_user_page(pages[--npages]);
> +       if (set_dirty)
> +               release_user_pages_dirty(pages, npages);
> +       else
> +               release_user_pages_basic(pages, npages);
> +}

Is there a good reason to have this with set_dirty argument? Generally bool
arguments are not great for readability (or greppability for that matter).
Also in this case callers can just as easily do:
	if (set_dirty)
		release_user_pages_dirty(...);
	else
		release_user_pages(...);

And furthermore it makes the code author think more whether he needs
set_page_dirty() or set_page_dirty_lock(), rather than just passing 'true'
and hoping the function magically does the right thing for him.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
