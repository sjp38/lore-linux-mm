Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id D137582F7F
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 20:03:20 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so1031801wic.0
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 17:03:20 -0700 (PDT)
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com. [209.85.212.177])
        by mx.google.com with ESMTPS id wc12si908093wic.115.2015.09.24.17.03.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Sep 2015 17:03:18 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so1031300wic.0
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 17:03:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150924151503.GF24375@infradead.org>
References: <20150923043737.36490.70547.stgit@dwillia2-desk3.jf.intel.com>
	<20150923044155.36490.2017.stgit@dwillia2-desk3.jf.intel.com>
	<20150924151503.GF24375@infradead.org>
Date: Thu, 24 Sep 2015 17:03:18 -0700
Message-ID: <CAPcyv4g9TFnUK_=Nk+b3_QMX4nUiGN9RN1PnT2zwLv_NgLExLQ@mail.gmail.com>
Subject: Re: [PATCH 08/15] block, dax, pmem: reference counting infrastructure
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, linux-nvdimm <linux-nvdimm@ml01.01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Thu, Sep 24, 2015 at 8:15 AM, Christoph Hellwig <hch@infradead.org> wrote:
> On Wed, Sep 23, 2015 at 12:41:55AM -0400, Dan Williams wrote:
>> Enable DAX to use a reference count for keeping the virtual address
>> returned by ->direct_access() valid for the duration of its usage in
>> fs/dax.c, or otherwise hold off blk_cleanup_queue() while
>> pmem_make_request is active.  The blk-mq code is already in a position
>> to need low overhead referece counting for races against request_queue
>> destruction (blk_cleanup_queue()).  Given DAX-enabled block drivers do
>> not enable blk-mq, share the storage in 'struct request_queue' between
>> the two implementations.
>
> Can we just move the refcounting to common code with the same field
> name, and even initialize it for non-mq, non-dax queues but just never
> tage a reference there (for now)?

That makes sense to me, especially because drivers/nvdimm/blk.c is
broken in the same way as drivers/nvdimm/pmem.c and it would be
awkward to have it use blk_dax_get() / blk_dax_put().  The
percpu_refcount should be valid for all queues and it will only ever
be > 1 in the blk_mq and libnvdimm cases (for now).  Will fix.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
