Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 139266B0033
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 08:02:58 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r202so8993635wmd.17
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 05:02:58 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id k57sor2700359wrf.39.2017.10.16.05.02.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Oct 2017 05:02:56 -0700 (PDT)
Subject: Re: [PATCH v9 0/6] MAP_DIRECT for DAX userspace flush
References: <150776922692.9144.16963640112710410217.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20171012142319.GA11254@lst.de>
 <CAPcyv4gTON__Ohop0B5R2gsKXC71bycTBozqGmF3WmwG9C6LVA@mail.gmail.com>
 <20171013065716.GB26461@lst.de>
 <CAPcyv4gaLBBefOU+8f7_ypYnCTjSMk+9nq8NfCqBHAE+NbUusw@mail.gmail.com>
 <20171013163822.GA17411@obsidianresearch.com>
 <CAPcyv4jDHp8z2VgVfyRK1WwMzixYVQnh54LZoPD57HB3yqSPPQ@mail.gmail.com>
 <20171013173145.GA18702@obsidianresearch.com>
 <CAPcyv4jZJRto1jwmNU--pqH_6dOVMyj=68ZwEjAmmkgX=mRk7w@mail.gmail.com>
 <20171014015752.GA25172@obsidianresearch.com>
From: Sagi Grimberg <sagi@grimberg.me>
Message-ID: <e29eb9ed-2d87-cde8-4efa-50de1fff0c04@grimberg.me>
Date: Mon, 16 Oct 2017 15:02:52 +0300
MIME-Version: 1.0
In-Reply-To: <20171014015752.GA25172@obsidianresearch.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, Dan Williams <dan.j.williams@intel.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "Darrick J. Wong" <darrick.wong@oracle.com>, Linux API <linux-api@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Dave Chinner <david@fromorbit.com>, linux-xfs@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Al Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>, Jeff Layton <jlayton@poochiereds.net>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@lst.de>


Hey folks, (chiming in very late here...)

>>> I think, if you want to build a uAPI for notification of MR lease
>>> break, then you need show how it fits into the above software model:
>>>   - How it can be hidden in a RDMA specific library
>>
>> So, here's a strawman can ibv_poll_cq() start returning ibv_wc_status
>> == IBV_WC_LOC_PROT_ERR when file coherency is lost. This would make
>> the solution generic across DAX and non-DAX. What's you're feeling for
>> how well applications are prepared to deal with that status return?
> 
> Stuffing an entry into the CQ is difficult. The CQ is in user memory
> and it is DMA'd from the HCA for several pieces of hardware, so the
> kernel can't just stuff something in there. It can be done
> with HW support by having the HCA DMA it via an exception path or
> something, but even then, you run into questions like CQ overflow and
> accounting issues since it is not ment for this.

But why should the kernel ever need to mangle the CQ? if a lease break
would deregister the MR the device is expected to generate remote
protection errors on its own.

And in that case, I think we need a query mechanism rather an event
mechanism so when the application starts seeing protection errors
it can query the relevant MR (I think most if not all devices have that
information in their internal completion queue entries).

> 
> So, you need a side channel of some kind, either in certain drivers or
> generically..
> 
>>>   - How lease break can be done hitlessly, so the library user never
>>>     needs to know it is happening or see failed/missed transfers

I agree that the application should not be aware of lease breakages, but
seeing failed transfers is perfectly acceptable given that an access
violation is happening (my assumption is that failed transfers are error
completions reported in the user completion queue). What we need to have
is a framework to help user-space to recover sanely, which is to query
what MR had the access violation, restore it, and re-establish the queue
pair.

>>
>> iommu redirect should be hit less and behave like the page cache case
>> where RDMA targets pages that are no longer part of the file.
> 
> Yes, if the iommu can be fenced properly it sounds doable.
> 
>>>   - Whatever fast path checking is needed does not kill performance
>>
>> What do you consider a fast path? I was assuming that memory
>> registration is a slow path, and iommu operations are asynchronous so
>> should not impact performance of ongoing operations beyond typical
>> iommu overhead.
> 
> ibv_poll_cq() and ibv_post_send() would be a fast path.
> 
> Where this struggled before is in creating a side channel you also now
> have to check that side channel, and checking it at high performance
> is quite hard.. Even quiecing things to be able to tear down the MR
> has performance implications on post send...

This is exactly why I think we should not have it, but instead give
building blocks to recover sanely from error completions...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
