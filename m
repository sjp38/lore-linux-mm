Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f49.google.com (mail-oi0-f49.google.com [209.85.218.49])
	by kanga.kvack.org (Postfix) with ESMTP id 2FA58828E1
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 17:59:44 -0500 (EST)
Received: by mail-oi0-f49.google.com with SMTP id k206so82987705oia.1
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 14:59:44 -0800 (PST)
Received: from mail-ob0-x22a.google.com (mail-ob0-x22a.google.com. [2607:f8b0:4003:c01::22a])
        by mx.google.com with ESMTPS id n19si29799474oeu.85.2016.01.12.14.59.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jan 2016 14:59:43 -0800 (PST)
Received: by mail-ob0-x22a.google.com with SMTP id ba1so449802293obb.3
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 14:59:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFyLb8scNSYb19rK4iT_Vx5=hKxqPwRHVnETzAhEev0aHw@mail.gmail.com>
References: <cover.1452549431.git.bcrl@kvack.org> <80934665e0dd2360e2583522c7c7569e5a92be0e.1452549431.git.bcrl@kvack.org>
 <20160112011128.GC6033@dastard> <CA+55aFxtvMqHgHmHCcszV_QKQ2BY0wzenmrvc6BYN+tLFxesMA@mail.gmail.com>
 <20160112022548.GD6033@dastard> <CA+55aFzxSrLhOyV3VtO=Cv_J+npD8ubEP74CCF+rdt=CRipzxA@mail.gmail.com>
 <20160112033708.GE6033@dastard> <CA+55aFyLb8scNSYb19rK4iT_Vx5=hKxqPwRHVnETzAhEev0aHw@mail.gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 12 Jan 2016 14:59:23 -0800
Message-ID: <CALCETrV0ABY5zZoCNQip0jJOd3gun15v-=s1V+ubm2E7NZDGtA@mail.gmail.com>
Subject: Re: [PATCH 07/13] aio: enabled thread based async fsync
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Benjamin LaHaise <bcrl@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-aio@kvack.org, linux-mm <linux-mm@kvack.org>

On Jan 11, 2016 8:04 PM, "Linus Torvalds" <torvalds@linux-foundation.org> wrote:
>
> On Mon, Jan 11, 2016 at 7:37 PM, Dave Chinner <david@fromorbit.com> wrote:
> >
> > Yes, I heard you the first time, but you haven't acknowledged that
> > the aio fsync interface is indeed different because it already
> > exists. What's the problem with implementing an AIO call that we've
> > advertised as supported for many years now that people are asking us
> > to implement it?
>
> Oh, I don't disagree with that. I think it should be exposed, my point
> was that that too was not enough.
>
> I don't see why you argue. You said "that's not enough". And I jjust
> said that your expansion wasn't sufficient either, and that I think we
> should strive to expand things even more.
>
> And preferably not in some ad-hoc manner. Expand it to *everything* we can do.
>
> > As for a generic async syscall interface, why not just add
> > IOCB_CMD_SYSCALL that encodes the syscall number and parameters
> > into the iovec structure and let the existing aio subsystem handle
> > demultiplexing it and handing them off to threads/workqueues/etc?
>
> That would likely be the simplest approach, yes.
>
> There's a few arguments against it, though:
>
>  - doing the indirect system call thing does end up being
> architecture-specific, so now you do need the AIO code to call into
> some arch wrapper.

How many arches *can* do it?  As of 4.4, x86_32 can, but x86_64 can't
yet.  We'd also need a whitelist of acceptable indirect syscalls (e.g.
exit is bad).  And we have to worry about things that depend on the mm
or creds.

It would be extra nice if we could avoid switch_mm for things that
don't need it (fsync) and only do it for things like read that do.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
