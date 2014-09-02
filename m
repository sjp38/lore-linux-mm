Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f181.google.com (mail-yk0-f181.google.com [209.85.160.181])
	by kanga.kvack.org (Postfix) with ESMTP id 399E36B0036
	for <linux-mm@kvack.org>; Tue,  2 Sep 2014 10:57:30 -0400 (EDT)
Received: by mail-yk0-f181.google.com with SMTP id 131so4149792ykp.12
        for <linux-mm@kvack.org>; Tue, 02 Sep 2014 07:57:30 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id a49si7394794yha.130.2014.09.02.07.57.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 02 Sep 2014 07:57:29 -0700 (PDT)
Date: Tue, 2 Sep 2014 10:55:15 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: ext4 vs btrfs performance on SSD array
Message-ID: <20140902145515.GD6232@thunk.org>
References: <CAEp=YLgzsLbmEfGB5YKVcHP4CQ-_z1yxnZ0tpo7gjKZ2e1ma5g@mail.gmail.com>
 <20140902000822.GA20473@dastard>
 <20140902012222.GA21405@infradead.org>
 <20140902113104.GD5049@thunk.org>
 <20140902142024.GB19412@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140902142024.GB19412@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Nikolai Grigoriev <ngrigoriev@gmail.com>, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-raid@vger.kernel.org, linux-mm@kvack.org, Jens Axboe <axboe@kernel.dk>

On Tue, Sep 02, 2014 at 04:20:24PM +0200, Jan Kara wrote:
> On Tue 02-09-14 07:31:04, Ted Tso wrote:
> > >  - the very small max readahead size
> > 
> > For things like the readahead size, that's probably something that we
> > should autotune, based the time it takes to read N sectors.  i.e.,
> > start N relatively small, such as 128k, and then bump it up based on
> > how long it takes to do a sequential read of N sectors until it hits a
> > given tunable, which is specified in milliseconds instead of kilobytes.
>   Actually the amount of readahead we do is autotuned (based on hit rate).
> So I would keep the setting in sysfs as the maximum size adaptive readahead
> can ever read and we can bump it up. We can possibly add another feedback
> into the readahead code to tune actualy readahead size depending on device
> speed but we'd have to research exactly what algorithm would work best.

I do think we will need to add a time based cap when bump up the max
adaptive readahead; otherwise what could happen is that if we are
streaming off of a slow block device, the readhaead could easily grow
to the point where it starts affecting the latency of competing read
requests to the slow block device.

I suppose we could make the argument that it's not needed, because most of
situations where we might be using slow block devices, the streaming
reader will likely have exclusive use of the device, since no one
would be crazy enough to say, try to run a live CD-ROM image when USB
sticks are so cheap.  :-)

So maybe in practice it won't matter, but I think some kind of time
based cap would probably be a good idea.

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
