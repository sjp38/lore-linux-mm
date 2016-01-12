Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f175.google.com (mail-io0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 78DC14403D8
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 23:03:42 -0500 (EST)
Received: by mail-io0-f175.google.com with SMTP id 77so340014438ioc.2
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 20:03:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160112033708.GE6033@dastard>
References: <cover.1452549431.git.bcrl@kvack.org>
	<80934665e0dd2360e2583522c7c7569e5a92be0e.1452549431.git.bcrl@kvack.org>
	<20160112011128.GC6033@dastard>
	<CA+55aFxtvMqHgHmHCcszV_QKQ2BY0wzenmrvc6BYN+tLFxesMA@mail.gmail.com>
	<20160112022548.GD6033@dastard>
	<CA+55aFzxSrLhOyV3VtO=Cv_J+npD8ubEP74CCF+rdt=CRipzxA@mail.gmail.com>
	<20160112033708.GE6033@dastard>
Date: Mon, 11 Jan 2016 20:03:41 -0800
Message-ID: <CA+55aFyLb8scNSYb19rK4iT_Vx5=hKxqPwRHVnETzAhEev0aHw@mail.gmail.com>
Subject: Re: [PATCH 07/13] aio: enabled thread based async fsync
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Benjamin LaHaise <bcrl@kvack.org>, linux-aio@kvack.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Jan 11, 2016 at 7:37 PM, Dave Chinner <david@fromorbit.com> wrote:
>
> Yes, I heard you the first time, but you haven't acknowledged that
> the aio fsync interface is indeed different because it already
> exists. What's the problem with implementing an AIO call that we've
> advertised as supported for many years now that people are asking us
> to implement it?

Oh, I don't disagree with that. I think it should be exposed, my point
was that that too was not enough.

I don't see why you argue. You said "that's not enough". And I jjust
said that your expansion wasn't sufficient either, and that I think we
should strive to expand things even more.

And preferably not in some ad-hoc manner. Expand it to *everything* we can do.

> As for a generic async syscall interface, why not just add
> IOCB_CMD_SYSCALL that encodes the syscall number and parameters
> into the iovec structure and let the existing aio subsystem handle
> demultiplexing it and handing them off to threads/workqueues/etc?

That would likely be the simplest approach, yes.

There's a few arguments against it, though:

 - doing the indirect system call thing does end up being
architecture-specific, so now you do need the AIO code to call into
some arch wrapper.

   Not a huge deal, since the arch wrapper will be pretty simple (and
we can have a default one that just returns ENOSYS, so that we don't
have to synchronize all architectures)

 - the aio interface really is horrible crap. Really really.

   For example, the whole "send signal as a completion model" is so
f*cking broken that I really don't want to extend the aio interface
too much. I think it's unfixable.

So I really think we'd be *much* better off with a new interface
entirely - preferably one that allows the old aio interfaces to fall
out fairly naturally.

Ben mentioned lio_listio() as a reason for why he wanted to extend the
AIO interface, but I think it works the other way around: yes, we
should look at lio_listio(), but we should look at it mainly as a way
to ask ourselves: "can we implement a new aynchronous system call
submission model that would also make it possible to implement
lio_listio() as a user space wrapper around it".

For example, if we had an actual _good_ way to queue up things, you
could probably make that "struct sigevent" completion for lio_listio()
just be another asynchronous system call at the end of the list - a
system call that sends the completion signal.  And the aiocb_list[]
itself? Maybe those could just be done as normal (individual) aio
calls (so that you end up having the aiocb that you can wait on with
aio_suspend() etc).

But then people who do *not* want the crazy aiocb, and do *not* want
some SIGIO or whatever, could just fire off asynchronous system calls
without that cruddy interface.

So my argument is really that I think it would be better to at least
look into maybe creating something less crapulent, and striving to
make it easy to make the old legacy interfaces be just wrappers around
a more capable model.

And hey, it may be that in the end nobody cares enough, and the right
thing (or at least the prudent thing) to do is to just pile the crap
on deeper and higher, and just add a single IOCB_CMD_SYSCALL
indirection entry.

So I'm not dismissing that as a solution - I just don't think it's a
particularly clean one.

It does have the advantage of likely being a fairly simple hack. But
it smells like a hack.

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
