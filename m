Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 01AAC82F66
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 11:15:06 -0400 (EDT)
Received: by igxx6 with SMTP id x6so51082379igx.1
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 08:15:05 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id o201si11080470ioe.22.2015.09.24.08.15.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Sep 2015 08:15:05 -0700 (PDT)
Date: Thu, 24 Sep 2015 08:15:03 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 08/15] block, dax, pmem: reference counting infrastructure
Message-ID: <20150924151503.GF24375@infradead.org>
References: <20150923043737.36490.70547.stgit@dwillia2-desk3.jf.intel.com>
 <20150923044155.36490.2017.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150923044155.36490.2017.stgit@dwillia2-desk3.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Jens Axboe <axboe@kernel.dk>, linux-nvdimm@ml01.01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>

On Wed, Sep 23, 2015 at 12:41:55AM -0400, Dan Williams wrote:
> Enable DAX to use a reference count for keeping the virtual address
> returned by ->direct_access() valid for the duration of its usage in
> fs/dax.c, or otherwise hold off blk_cleanup_queue() while
> pmem_make_request is active.  The blk-mq code is already in a position
> to need low overhead referece counting for races against request_queue
> destruction (blk_cleanup_queue()).  Given DAX-enabled block drivers do
> not enable blk-mq, share the storage in 'struct request_queue' between
> the two implementations.

Can we just move the refcounting to common code with the same field
name, and even initialize it for non-mq, non-dax queues but just never
tage a reference there (for now)?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
