Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id CB0526B0038
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 04:39:14 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id v10so12844241pde.33
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 01:39:14 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id ez9si292295pab.128.2014.09.11.01.39.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 11 Sep 2014 01:39:13 -0700 (PDT)
Received: by mail-pa0-f51.google.com with SMTP id kx10so9415114pab.24
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 01:39:13 -0700 (PDT)
Message-ID: <54115FAB.2050601@gmail.com>
Date: Thu, 11 Sep 2014 11:39:07 +0300
From: Boaz Harrosh <openosd@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/9] mm: Let sparse_{add,remove}_one_section receive a
 node_id
References: <1409173922-7484-1-git-send-email-ross.zwisler@linux.intel.com> <540F1EC6.4000504@plexistor.com> <540F20AB.4000404@plexistor.com> <540F48BA.2090304@intel.com> <541022DB.9090000@plexistor.com> <541077DF.1060609@intel.com> <5410899C.3030501@plexistor.com> <54109845.3050309@intel.com>
In-Reply-To: <54109845.3050309@intel.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Boaz Harrosh <boaz@plexistor.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@fb.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-nvdimm@lists.01.org, Toshi Kani <toshi.kani@hp.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>

On 09/10/2014 09:28 PM, Dave Hansen wrote:
<>
> 
> OK, so what happens when a page is truncated out of a file and this
> "last" block reference is dropped while a get_user_pages() still has a
> reference?
> 

I have a very simple plan for this scenario, as I said, hang these pages
with ref!=1 on a garbage list, and one of the clear threads can scan them
periodically and release them.

I have this test in place, currently what I do is just drop the block
and let it leak (that is, not be used any more) until a next mount where
this will be returned to free store. Yes stupid I know. But I have a big
fat message when this happens and I have not been able to reproduce it.
So I'm still waiting for this test case, I guess DAX protects me.

<>
> From my perspective, DAX is complicated, but it is necessary because we
> don't have a 'struct page'.  You're saying that even if we pay the cost
> of a 'struct page' for the memory, we still don't get the benefit of
> having it like getting rid of this DAX stuff?
> 

No DAX is still necessary because we map storage directly to app space,
and we still need it persistent. That is we can-not/need-not use an
in-ram radix tree but directly use on-storage btrees.
Regular VFS has this 2 tiers model, volatile-ram over persistent store.
DAX is an alternative VFS model where you have a single tier. the name
implies "Direct Access".

So this is nothing to do with page cost or "benefit". DAX is about a new
VFS model for new storage technologies.

And please be noted, the complexity you are talking about is just a learning
curve, on the developers side. Not a technological one. Actually if you
compare the two models, lets call them VFS-2t and VFS-1t, then you see that
DAX is an order of a magnitude simpler then the old model.

Life is hard and we do need the two models all at the same time, to support
all these different devices. So yes the complexity is added with the added
choice. But please do not confuse, DAX is not the complicated part. Having
a Choice is.

> Also, about not having a zone for these pages.  Do you intend to support
> 32-bit systems?  If so, I believe you will require the kmap() family of
> functions to map the pages in order to copy data in and out.  kmap()
> currently requires knowing the zone of the page.

No!!! This is strictly 64 bit. A 32bit system is able to have at maximum
3Gb of low-ram + storage.
DAX implies always mapped. That is, no re-mapping. So this rules out
more then a G of storage. Since that is a joke then No! 32bit is out.

You need to understand current HW std talks about DDR4 and there are
DDR3 samples flouting around. So this is strictly 64bit, even on
phones.


Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
