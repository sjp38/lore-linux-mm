Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f181.google.com (mail-io0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id C1FB16B0005
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 16:57:07 -0500 (EST)
Received: by mail-io0-f181.google.com with SMTP id g73so35424712ioe.3
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 13:57:07 -0800 (PST)
Date: Thu, 21 Jan 2016 08:57:03 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 07/13] aio: enabled thread based async fsync
Message-ID: <20160120215703.GY6033@dastard>
References: <CA+55aFxtvMqHgHmHCcszV_QKQ2BY0wzenmrvc6BYN+tLFxesMA@mail.gmail.com>
 <20160112022548.GD6033@dastard>
 <CA+55aFzxSrLhOyV3VtO=Cv_J+npD8ubEP74CCF+rdt=CRipzxA@mail.gmail.com>
 <20160112033708.GE6033@dastard>
 <CA+55aFyLb8scNSYb19rK4iT_Vx5=hKxqPwRHVnETzAhEev0aHw@mail.gmail.com>
 <CA+55aFxCM-xWVR4jC=q2wSk+-WC1Xuf+nZLoud8JwKZopnR_dQ@mail.gmail.com>
 <20160115202131.GH6330@kvack.org>
 <CA+55aFzRo3yztEBBvJ4CMCvVHAo6qEDhTHTc_LGyqmxbcFyNYw@mail.gmail.com>
 <20160120195957.GV6033@dastard>
 <CA+55aFx4PzugV+wOKRqMEwo8XJ1QxP8r+s-mvn6H064FROnKdQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFx4PzugV+wOKRqMEwo8XJ1QxP8r+s-mvn6H064FROnKdQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Benjamin LaHaise <bcrl@kvack.org>, linux-aio@kvack.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Jan 20, 2016 at 12:29:32PM -0800, Linus Torvalds wrote:
> On Wed, Jan 20, 2016 at 11:59 AM, Dave Chinner <david@fromorbit.com> wrote:
> >>
> >> Are there other users outside of Solace? It would be good to get comments..
> >
> > I know of quite a few storage/db products that use AIO. The most
> > recent high profile project that have been reporting issues with AIO
> > on XFS is http://www.scylladb.com/. That project is architected
> > around non-blocking AIO for scalability reasons...
> 
> I was more wondering about the new interfaces, making sure that the
> feature set actually matches what people want to do..

Well, they have mentioned that openat() can block, as will the first
operation after open that requires reading the file extent map from
disk. There are some ways of hacking around this (e.g. running
FIEMAP with a zero extent count or ext4's special extent prefetch
ioctl in a separate thread to prefetch the extent list into memory
before IO is required) so I suspect we may actually need some
interfaces that don't current exist at all....

> That said, I also agree that it would be interesting to hear what the
> performance impact is for existing performance-sensitive users. Could
> we make that "aio_may_use_threads()" case be unconditional, making
> things simpler?

That would make things a lot simpler in the kernel and AIO
submission a lot more predictable/deterministic for userspace. I'd
suggest that, at minimum, it should be the default behaviour...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
