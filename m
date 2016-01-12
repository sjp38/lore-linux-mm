Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f176.google.com (mail-io0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id A3A69680F84
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 21:25:53 -0500 (EST)
Received: by mail-io0-f176.google.com with SMTP id 77so338230872ioc.2
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 18:25:53 -0800 (PST)
Date: Tue, 12 Jan 2016 13:25:48 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 07/13] aio: enabled thread based async fsync
Message-ID: <20160112022548.GD6033@dastard>
References: <cover.1452549431.git.bcrl@kvack.org>
 <80934665e0dd2360e2583522c7c7569e5a92be0e.1452549431.git.bcrl@kvack.org>
 <20160112011128.GC6033@dastard>
 <CA+55aFxtvMqHgHmHCcszV_QKQ2BY0wzenmrvc6BYN+tLFxesMA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFxtvMqHgHmHCcszV_QKQ2BY0wzenmrvc6BYN+tLFxesMA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Benjamin LaHaise <bcrl@kvack.org>, linux-aio@kvack.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Jan 11, 2016 at 05:20:42PM -0800, Linus Torvalds wrote:
> On Mon, Jan 11, 2016 at 5:11 PM, Dave Chinner <david@fromorbit.com> wrote:
> >
> > Insufficient. Needs the range to be passed through and call
> > vfs_fsync_range(), as I implemented here:
> 
> And I think that's insufficient *also*.
> 
> What you actually want is "sync_file_range()", with the full set of arguments.

That's a different interface. the aio fsync interface has been
exposed to userspace for years, we just haven't implemented it in
the kernel. That's a major difference to everything else being
proposed in this patch set, especially this one.

FYI sync_file_range() is definitely not a fsync/fdatasync
replacement as it does not guarantee data durability in any way.
i.e. you can call sync_file_range, have it wait for data to be
written, return to userspace, then lose power and lose the data that
sync_file_range said it wrote. That's because sync_file_range()
does not:

	a) write the metadata needed to reference the data to disk;
	   and
	b) flush volatile storage caches after data and metadata is
	   written.

Hence sync_file_range is useless to applications that need to
guarantee data durability. Not to mention that most AIO applications
use direct IO, and so have no use for fine grained control over page
cache writeback semantics. They only require a) and b) above, so
implementing the AIO fsync primitive is exactly what they want.

> Yes, really. Sometimes you want to start the writeback, sometimes you
> want to wait for it. Sometimes you want both.

Without durability guarantees such application level optimisations
are pretty much worthless.

> I think this only strengthens my "stop with the idiotic
> special-case-AIO magic already" argument.  If we want something more
> generic than the usual aio, then we should go all in. Not "let's make
> more limited special cases".

No, I don't think this specific case does, because the AIO fsync
interface already exists....

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
