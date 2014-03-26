Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f180.google.com (mail-ve0-f180.google.com [209.85.128.180])
	by kanga.kvack.org (Postfix) with ESMTP id D415C6B0031
	for <linux-mm@kvack.org>; Wed, 26 Mar 2014 17:41:52 -0400 (EDT)
Received: by mail-ve0-f180.google.com with SMTP id jz11so3118981veb.11
        for <linux-mm@kvack.org>; Wed, 26 Mar 2014 14:41:52 -0700 (PDT)
Received: from mail-vc0-f175.google.com (mail-vc0-f175.google.com [209.85.220.175])
        by mx.google.com with ESMTPS id sc12si4852184veb.79.2014.03.26.14.41.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 26 Mar 2014 14:41:51 -0700 (PDT)
Received: by mail-vc0-f175.google.com with SMTP id lh14so3169998vcb.34
        for <linux-mm@kvack.org>; Wed, 26 Mar 2014 14:41:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140326191113.GF9066@alap3.anarazel.de>
References: <20140326191113.GF9066@alap3.anarazel.de>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 26 Mar 2014 14:41:31 -0700
Message-ID: <CALCETrUc1YvNc3EKb4ex579rCqBfF=84_h5bvbq49o62k2KpmA@mail.gmail.com>
Subject: Re: [Lsf] Postgresql performance problems with IO latency, especially
 during fsync()
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andres Freund <andres@anarazel.de>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, lsf@lists.linux-foundation.org, Wu Fengguang <fengguang.wu@intel.com>, rhaas@alap3.anarazel.de, andres@2ndquadrant.com

On Wed, Mar 26, 2014 at 12:11 PM, Andres Freund <andres@anarazel.de> wrote:
> Hi,
>
> At LSF/MM there was a slot about postgres' problems with the kernel. Our
> top#1 concern is frequent slow read()s that happen while another process
> calls fsync(), even though we'd be perfectly fine if that fsync() took
> ages.
> The "conclusion" of that part was that it'd be very useful to have a
> demonstration of the problem without needing a full blown postgres
> setup. I've quickly hacked something together, that seems to show the
> problem nicely.
>
> For a bit of context: lwn.net/SubscriberLink/591723/940134eb57fcc0b8/
> and the "IO Scheduling" bit in
> http://archives.postgresql.org/message-id/20140310101537.GC10663%40suse.de
>

For your amusement: running this program in KVM on a 2GB disk image
failed, but it caused the *host* to go out to lunch for several
seconds while failing.  In fact, it seems to have caused the host to
fall over so badly that the guest decided that the disk controller was
timing out.  The host is btrfs, and I think that btrfs is *really* bad
at this kind of workload.

Even using ext4 is no good.  I think that dm-crypt is dying under the
load.  So I won't test your program for real :/


[...]

> Possible solutions:
> * Add a fadvise(UNDIRTY), that doesn't stall on a full IO queue like
>   sync_file_range() does.
> * Make IO triggered by writeback regard IO priorities and add it to
>   schedulers other than CFQ
> * Add a tunable that allows limiting the amount of dirty memory before
>   writeback on a per process basis.
> * ...?

I thought the problem wasn't so much that priorities weren't respected
but that the fsync call fills up the queue, so everything starts
contending for the right to enqueue a new request.

Since fsync blocks until all of its IO finishes anyway, what if it
could just limit itself to a much smaller number of outstanding
requests?

I'm not sure I understand the request queue stuff, but here's an idea.
 The block core contains this little bit of code:

    /*
     * Only allow batching queuers to allocate up to 50% over the defined
     * limit of requests, otherwise we could have thousands of requests
     * allocated with any setting of ->nr_requests
     */
    if (rl->count[is_sync] >= (3 * q->nr_requests / 2))
        return NULL;

What if this changed to:

    /*
     * Only allow batching queuers to allocate up to 50% of the defined
     * limit of requests, so that non-batching queuers can get into the queue
     * and thus be scheduled properly.
     */
    if (rl->count[is_sync] >= (q->nr_requests + 3) / 4))
        return NULL;

I suspect that doing this right would take a bit more care than that,
but I wonder if this approach is any good.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
