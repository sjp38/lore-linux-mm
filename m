Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3B8BA8E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 13:13:55 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id f18so460316wrt.1
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 10:13:55 -0800 (PST)
Received: from bhuna.collabora.co.uk (bhuna.collabora.co.uk. [2a00:1098:0:82:1000:25:2eeb:e3e3])
        by mx.google.com with ESMTPS id j65si5439852wmj.102.2019.01.07.10.13.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 07 Jan 2019 10:13:53 -0800 (PST)
Date: Mon, 7 Jan 2019 13:13:55 -0500
From: =?utf-8?B?R2HDq2w=?= PORTAY <gael.portay@collabora.com>
Subject: Re: [usb-storage] Re: cma: deadlock using usb-storage and fs
Message-ID: <20190107181355.qqbdc6pguq4w3z6u@archlinux.localdomain>
References: <20181216222117.v5bzdfdvtulv2t54@archlinux.localdomain>
 <Pine.LNX.4.44L0.1812171038300.1630-100000@iolanthe.rowland.org>
 <20181217182922.bogbrhjm6ubnswqw@archlinux.localdomain>
 <c3ab7935-8d8d-27a0-99a7-0dab51244a42@redhat.com>
 <593e3757-6f50-22bc-d5a9-ea5819b9a63d@oracle.com>
 <da35de2c-b8ad-9b01-b582-8f1f8061e8e1@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <da35de2c-b8ad-9b01-b582-8f1f8061e8e1@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, Alan Stern <stern@rowland.harvard.edu>, linux-mm@kvack.org, usb-storage@lists.one-eyed-alien.net

Laura,

On Tue, Dec 18, 2018 at 01:14:42PM -0800, Laura Abbott wrote:
> On 12/18/18 11:42 AM, Mike Kravetz wrote:
> > On 12/17/18 1:57 PM, Laura Abbott wrote:
> > > On 12/17/18 10:29 AM, Ga�l PORTAY wrote:
> > > 
> > > Last time I looked at this, we needed the cma_mutex for serialization
> > > so unless we want to rework that, I think we need to not use CMA in the
> > > writeback case (i.e. GFP_IO).

I followed what you suggested and add gfpflags_allow_writeback that
tests against the __GFP_IO flag:

static inline bool gfpflags_allow_writeback(const gfp_t gfp_flags)
{
	return !!(gfp_flags & __GFP_IO);
}

And then not to go for CMA in the case of writeback in function
__dma_alloc:

-	cma = allowblock ? dev_get_cma_area(dev) : false;
+	allowwriteback = gfpflags_allow_writeback(gfp);
+	cma = (allowblock && !allowwriteback) ? dev_get_cma_area(dev) : false;

This workaround fixes the issue I faced (I have prepared a patch).

> > I am wondering if we still need to hold the cma_mutex while calling
> > alloc_contig_range().  Looking back at the history, it appears that
> > the reason for holding the mutex was to prevent two threads from operating
> > on the same pageblock.
> > 
> > Commit 2c7452a075d4 ("mm/page_isolation.c: make start_isolate_page_range()
> > fail if already isolated") will cause alloc_contig_range to return EBUSY
> > if two callers are attempting to operate on the same pageblock.  This was
> > added because memory hotplug as well as gigantac page allocation call
> > alloc_contig_range and could conflict with each other or cma.   cma_alloc
> > has logic to retry if EBUSY is returned.  Although, IIUC it assumes the
> > EBUSY is the result of specific pages being busy as opposed to someone
> > else operating on the pageblock.  Therefore, the retry logic to 'try a
> > different set of pages' is not what one  would/should attempt in the case
> > someone else is operating on the pageblock.
> > 
> > Would it be possible or make sense to remove the mutex and retry when
> > EBUSY?  Or, am I missing some other reason for holding the mutex.
> > 
> 
> I had forgotten that start_isolate_page_range had been updated to
> return -EBUSY. It looks like we would need to update
> the callback for migrate_pages in __alloc_contig_migrate_range
> since alloc_migrate_target by default will use __GFP_IO.
> So I _think_ if we update that to honor GFP_NOIO we could
> remove the mutex assuming the rest of migrate_pages honors
> it properly.
> 

I have also removed the mutex (start_isolate_page_range retunrs -EBUSY),
and it worked (in my case).

But I did not do the proper magic because I am not sure of what should
be done and how: -EBUSY is not handled and __GFP_NOIO is not honored. 

Regards,
Gael
