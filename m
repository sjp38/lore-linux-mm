Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5B1506B0007
	for <linux-mm@kvack.org>; Sun, 17 Jun 2018 17:54:32 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id d14-v6so12612360qtn.3
        for <linux-mm@kvack.org>; Sun, 17 Jun 2018 14:54:32 -0700 (PDT)
Received: from a9-46.smtp-out.amazonses.com (a9-46.smtp-out.amazonses.com. [54.240.9.46])
        by mx.google.com with ESMTPS id f25-v6si962157qkf.195.2018.06.17.14.54.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 17 Jun 2018 14:54:31 -0700 (PDT)
Date: Sun, 17 Jun 2018 21:54:31 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 0/2] mm: gup: don't unmap or drop filesystem buffers
In-Reply-To: <20180617012510.20139-1-jhubbard@nvidia.com>
Message-ID: <010001640fbe0dd8-f999e7f6-7b6e-4deb-b073-0c572006727d-000000@email.amazonses.com>
References: <20180617012510.20139-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: john.hubbard@gmail.com
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, John Hubbard <jhubbard@nvidia.com>

On Sat, 16 Jun 2018, john.hubbard@gmail.com wrote:

> I've come up with what I claim is a simple, robust fix, but...I'm
> presuming to burn a struct page flag, and limit it to 64-bit arches, in
> order to get there. Given that the problem is old (Jason Gunthorpe noted
> that RDMA has been living with this problem since 2005), I think it's
> worth it.
>
> Leaving the new page flag set "nearly forever" is not great, but on the
> other hand, once the page is actually freed, the flag does get cleared.
> It seems like an acceptable tradeoff, given that we only get one bit
> (and are lucky to even have that).

This is not robust. Multiple processes may register a page with the RDMA
subsystem. How do you decide when to clear the flag? I think you would
need an additional refcount for the number of times the page was
registered.

I still think the cleanest solution here is to require mmu notifier
callbacks and to not pin the page in the first place. If a NIC does not
support a hardware mmu then it can still simulate it in software by
holding off the ummapping the mmu notifier callback until any pending
operation is complete and then invalidate the mapping so that future
operations require a remapping (or refaulting).
