Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id F2661680F80
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 22:37:14 -0500 (EST)
Received: by mail-ig0-f176.google.com with SMTP id z14so116436214igp.1
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 19:37:14 -0800 (PST)
Date: Tue, 12 Jan 2016 14:37:08 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 07/13] aio: enabled thread based async fsync
Message-ID: <20160112033708.GE6033@dastard>
References: <cover.1452549431.git.bcrl@kvack.org>
 <80934665e0dd2360e2583522c7c7569e5a92be0e.1452549431.git.bcrl@kvack.org>
 <20160112011128.GC6033@dastard>
 <CA+55aFxtvMqHgHmHCcszV_QKQ2BY0wzenmrvc6BYN+tLFxesMA@mail.gmail.com>
 <20160112022548.GD6033@dastard>
 <CA+55aFzxSrLhOyV3VtO=Cv_J+npD8ubEP74CCF+rdt=CRipzxA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzxSrLhOyV3VtO=Cv_J+npD8ubEP74CCF+rdt=CRipzxA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Benjamin LaHaise <bcrl@kvack.org>, linux-aio@kvack.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Jan 11, 2016 at 06:38:15PM -0800, Linus Torvalds wrote:
> On Mon, Jan 11, 2016 at 6:25 PM, Dave Chinner <david@fromorbit.com> wrote:
> >
> > That's a different interface.
> 
> So is openat. So is readahead.
>
> My point is that this idiotic "let's expose special cases" must end.
> It's broken. It inevitably only exposes a subset of what different
> people would want.
> 
> Making "aio_read()" and friends a special interface had historical
> reasons for it. But expanding willy-nilly on that model does not.

Yes, I heard you the first time, but you haven't acknowledged that
the aio fsync interface is indeed different because it already
exists. What's the problem with implementing an AIO call that we've
advertised as supported for many years now that people are asking us
to implement it?

As for a generic async syscall interface, why not just add
IOCB_CMD_SYSCALL that encodes the syscall number and parameters
into the iovec structure and let the existing aio subsystem handle
demultiplexing it and handing them off to threads/workqueues/etc?
That was we get contexts, events, signals, completions,
cancelations, etc from the existing infrastructure, and there's
really only a dispatch/collection layer that needs to be added?

If we then provide the userspace interface via the libaio library to
call the async syscalls with an AIO context handle, then there's
little more that needs to be done to support just about everything
as an async syscall...

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
