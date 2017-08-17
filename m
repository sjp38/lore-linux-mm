Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9411D6B025F
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 17:44:18 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id o184so7434374qkc.0
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 14:44:18 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f31si3794034qtd.425.2017.08.17.14.44.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Aug 2017 14:44:17 -0700 (PDT)
Date: Thu, 17 Aug 2017 17:44:14 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM-v25 13/19] mm/migrate: new migrate mode MIGRATE_SYNC_NO_COPY
Message-ID: <20170817214414.GC2872@redhat.com>
References: <20170817000548.32038-1-jglisse@redhat.com>
 <20170817000548.32038-14-jglisse@redhat.com>
 <20170817141245.93cfb315cfc598ff86928639@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170817141245.93cfb315cfc598ff86928639@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>

On Thu, Aug 17, 2017 at 02:12:45PM -0700, Andrew Morton wrote:
> On Wed, 16 Aug 2017 20:05:42 -0400 J__r__me Glisse <jglisse@redhat.com> wrote:
> 
> > Introduce a new migration mode that allow to offload the copy to
> > a device DMA engine. This changes the workflow of migration and
> > not all address_space migratepage callback can support this. So
> > it needs to be tested in those cases.
> 
> Can you please expand on this?  What additional testing must be
> performed before we are able to merge this into mainline?
> 

No additional testing needed. I disable MIGRATE_SYNC_NO_COPY in all
problematic migratepage() callback and i added comment in those to
explain why (part of this patch). The commit message is unclear it
should say that any callback that wish to support this new mode need
to be aware of the difference in the migration flow from other mode.

Some of this callback do extra locking while copying (aio, zsmalloc,
balloon, ...) and for DMA to be effective you want to copy multiple
pages in one DMA operations. But in the problematic case you can not
easily hold the extra lock accross multiple call to this callback.

Usual flow is:

For each page {
 1 - lock page
 2 - call migratepage() callback
 3 - (extra locking in some migratepage() callback)
 4 - migrate page state (freeze refcount, update page cache, buffer
     head, ...)
 5 - copy page
 6 - (unlock any extra lock of migratepage() callback)
 7 - return from migratepage() callback
 8 - unlock page
}

The new mode MIGRATE_SYNC_NO_COPY:
 1 - lock multiple pages
For each page {
 2 - call migratepage() callback
 3 - abort in all problematic migratepage() callback
 4 - migrate page state (freeze refcount, update page cache, buffer
     head, ...)
} // finished all calls to migratepage() callback
 5 - DMA copy multiple pages
 6 - unlock all the pages

To support MIGRATE_SYNC_NO_COPY in the problematic case we would
need a new callback migratepages() (for instance) that deals with
multiple pages in one transaction.

Because the problematic cases are not important for current usage
i did not wanted to complexify this patchset even more for no good
reasons.

I hope this clarify, the commit message and comment in migrate.h
can probably use this extra description i just gave.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
