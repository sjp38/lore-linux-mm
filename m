Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id D70456B0005
	for <linux-mm@kvack.org>; Wed, 23 May 2018 05:35:40 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z69-v6so598419wrb.20
        for <linux-mm@kvack.org>; Wed, 23 May 2018 02:35:40 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u10-v6si5776823edm.124.2018.05.23.02.35.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 23 May 2018 02:35:39 -0700 (PDT)
Date: Wed, 23 May 2018 11:35:37 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 06/11] filesystem-dax: perform
 __dax_invalidate_mapping_entry() under the page lock
Message-ID: <20180523093537.duw6jlglcx7fnutw@quack2.suse.cz>
References: <152699997165.24093.12194490924829406111.stgit@dwillia2-desk3.amr.corp.intel.com>
 <152700000355.24093.14726378287214432782.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <152700000355.24093.14726378287214432782.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, tony.luck@intel.com

On Tue 22-05-18 07:40:03, Dan Williams wrote:
> Hold the page lock while invalidating mapping entries to prevent races
> between rmap using the address_space and the filesystem freeing the
> address_space.
> 
> This is more complicated than the simple description implies because
> dev_pagemap pages that fsdax uses do not have any concept of page size.
> Size information is stored in the radix and can only be safely read
> while holding the xa_lock. Since lock_page() can not be taken while
> holding xa_lock, drop xa_lock and speculatively lock all the associated
> pages. Once all the pages are locked re-take the xa_lock and revalidate
> that the radix entry did not change.
> 
> Cc: Jan Kara <jack@suse.cz>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: Matthew Wilcox <mawilcox@microsoft.com>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

IMO this is too ugly to live. The combination of entry locks in the radix
tree and page locks is just too big mess. And from a quick look I don't see
a reason why we could not use entry locks to protect rmap code as well -
when you have PFN for which you need to walk rmap, you can grab
rcu_read_lock(), then you can safely look at page->mapping, grab xa_lock,
verify the radix tree points where it should and grab entry lock. I agree
it's a bit complicated but for memory failure I think it is fine.

Or we could talk about switching everything to page locks instead of entry
locks but that isn't trivial either as we need something to serialized page
faults on even before we go into the filesystem and allocate blocks for the
fault...
								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
