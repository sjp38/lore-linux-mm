Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0B57A6B025E
	for <linux-mm@kvack.org>; Sun,  6 Nov 2016 09:09:09 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id y143so236342842oie.3
        for <linux-mm@kvack.org>; Sun, 06 Nov 2016 06:09:09 -0800 (PST)
Received: from gateway22.websitewelcome.com (gateway22.websitewelcome.com. [192.185.46.126])
        by mx.google.com with ESMTPS id 22si12611561oti.55.2016.11.06.06.09.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 06 Nov 2016 06:09:08 -0800 (PST)
Received: from cm5.websitewelcome.com (unknown [108.167.139.22])
	by gateway22.websitewelcome.com (Postfix) with ESMTP id 17784FA275423
	for <linux-mm@kvack.org>; Sun,  6 Nov 2016 08:06:01 -0600 (CST)
Message-ID: <b714bf30ee6577c5006f347b12b4f2fe.squirrel@webmail.raithlin.com>
In-Reply-To: <20161025211903.GD14023@dastard>
References: <1476826937-20665-1-git-send-email-sbates@raithlin.com>
    <CAPcyv4gJ_c-6s2BUjsu6okR1EF53R+KNuXnOc5jv0fuwJaa3cQ@mail.gmail.com>
    <20161019184814.GC16550@cgy1-donard.priv.deltatee.com>
    <20161020232239.GQ23194@dastard> <20161021095714.GA12209@infradead.org>
    <20161021111253.GQ14023@dastard>
    <20161025115043.GA14986@cgy1-donard.priv.deltatee.com>
    <20161025211903.GD14023@dastard>
Date: Sun, 6 Nov 2016 08:05:59 -0600
Subject: Re: [PATCH 0/3] iopmem : A block device for PCIe memory
From: "Stephen Bates" <sbates@raithlin.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Stephen Bates <sbates@raithlin.com>, Christoph Hellwig <hch@infradead.org>, Dan Williams <dan.j.williams@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, linux-rdma@vger.kernel.org, linux-block@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, jgunthorpe@obsidianresearch.com, haggaie@mellanox.com, Jens Axboe <axboe@fb.com>, Jonathan Corbet <corbet@lwn.net>, jim.macdonald@everspin.com, sbates@raithin.com, Logan Gunthorpe <logang@deltatee.com>, David Woodhouse <dwmw2@infradead.org>, "Raj, Ashok" <ashok.raj@intel.com>

On Tue, October 25, 2016 3:19 pm, Dave Chinner wrote:
> On Tue, Oct 25, 2016 at 05:50:43AM -0600, Stephen Bates wrote:
>>
>> Dave are you saying that even for local mappings of files on a DAX
>> capable system it is possible for the mappings to move on you unless the
>> FS supports locking?
>>
>
> Yes.
>
>
>> Does that not mean DAX on such FS is
>> inherently broken?
>
> No. DAX is accessed through a virtual mapping layer that abstracts
> the physical location from userspace applications.
>
> Example: think copy-on-write overwrites. It occurs atomically from
> the perspective of userspace and starts by invalidating any current
> mappings userspace has of that physical location. The location is changes,
> the data copied in, and then when the locks are released userspace can
> fault in a new page table mapping on the next access....

Dave

Thanks for the good input and for correcting some of my DAX
misconceptions! We will certainly be taking this into account as we
consider v1.

>
>>>> And at least for XFS we have such a mechanism :)  E.g. I have a
>>>> prototype of a pNFS layout that uses XFS+DAX to allow clients to do
>>>> RDMA directly to XFS files, with the same locking mechanism we use
>>>> for the current block and scsi layout in xfs_pnfs.c.
>>
>> Thanks for fixing this issue on XFS Christoph! I assume this problem
>> continues to exist on the other DAX capable FS?
>
> Yes, but it they implement the exportfs API that supplies this
> capability, they'll be able to use pNFS, too.
>
>> One more reason to consider a move to /dev/dax I guess ;-)...
>>
>
> That doesn't get rid of the need for sane access control arbitration
> across all machines that are directly accessing the storage. That's the
> problem pNFS solves, regardless of whether your direct access target is a
> filesystem, a block device or object storage...

Fair point. I am still hoping for a bit more discussion on the best choice
of user-space interface for this work. If/When that happens we will take
it into account when we look at spinning the patchset.


Stephen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
