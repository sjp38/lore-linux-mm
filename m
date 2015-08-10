Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com [209.85.218.46])
	by kanga.kvack.org (Postfix) with ESMTP id 627FB6B0253
	for <linux-mm@kvack.org>; Sun,  9 Aug 2015 22:10:41 -0400 (EDT)
Received: by oihn130 with SMTP id n130so81252763oih.2
        for <linux-mm@kvack.org>; Sun, 09 Aug 2015 19:10:41 -0700 (PDT)
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com. [209.85.214.170])
        by mx.google.com with ESMTPS id xf6si13211296oeb.51.2015.08.09.19.10.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Aug 2015 19:10:40 -0700 (PDT)
Received: by obbhe7 with SMTP id he7so17839643obb.0
        for <linux-mm@kvack.org>; Sun, 09 Aug 2015 19:10:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <55C7D02A.9060905@zonque.org>
References: <CANq1E4SnYq_pZMWYcafB9GmB_O77tbVLPT0=0d6LGQVpvThTrw@mail.gmail.com>
 <CALCETrWE-oYRq+AzRxxcz03AK0pAzgKJtmxAuNwQu+p5S0msBw@mail.gmail.com>
 <CANq1E4Rek3HXCDU_13OGfRShS7Z0g+fxcTp5C1V3oKC4HgkD_A@mail.gmail.com>
 <CALCETrUaSgdaq4_mr3GG-ekLwGXkQR5MoRLSj9Wu2dTXDYUp1g@mail.gmail.com>
 <CANq1E4SkUWWXuksJnWzXd5KStZx-T6q6+WWTHdrQz_WiMry4Cw@mail.gmail.com>
 <CALCETrXcqOFedk8r-jHK-deRwfum29JHspALE6JUi2gzbo-dhg@mail.gmail.com>
 <55C3A403.8020202@zonque.org> <CALCETrVr04ZdXHLZXLp_Y+m68Db5Mmh_Wnu6prNCfCqgWm0QzA@mail.gmail.com>
 <55C4C35A.4070306@zonque.org> <CA+55aFxDLt-5+=xXeYG4nJKMb8L_iD9FmwTZ2VuughBku-mW3g@mail.gmail.com>
 <20150809190027.GA24185@kroah.com> <55C7D02A.9060905@zonque.org>
From: Andy Lutomirski <luto@amacapital.net>
Date: Sun, 9 Aug 2015 19:10:20 -0700
Message-ID: <CALCETrUA6o04QYhvSZjtVUs9p1A+ASndEv0C8X6D+Fg5uudo9A@mail.gmail.com>
Subject: Re: kdbus: to merge or not to merge?
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Mack <daniel@zonque.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tom Gundersen <teg@jklm.no>, "Kalle A. Sandstrom" <ksandstr@iki.fi>, Borislav Petkov <bp@alien8.de>, One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, Havoc Pennington <havoc.pennington@gmail.com>, Djalal Harouni <tixxdz@opendz.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Eric W. Biederman" <ebiederm@xmission.com>, cee1 <fykcee1@gmail.com>, David Herrmann <dh.herrmann@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Sun, Aug 9, 2015 at 3:11 PM, Daniel Mack <daniel@zonque.org> wrote:
>
> Internally, the connection pool is simply a shmem backed file. From the
> context of the HELLO ioctl, we are calling into shmem_file_setup(), so
> the file is eventually owned by the task which created the bus task
> connecting to the bus. One reason why we do the shmem file allocation in
> the kernel and on behalf of a the userspace task is that we clear the
> VM_MAYWRITE bit to prevent the task from writing to the pool through its
> mapped buffer. We also do not set VM_NORESERVE, so the entire buffer is
> pre-accounted for the task that created the connection.

I don't have access to the system I've been using for testing right
now, but I wonder how the kdbus pool stack up against the entire rest
of memory allocations for the average desktop process.

>
> The pool implementation uses an r/b tree to organize the buffer into
> slices. Those slices can be kept by userspace as long as the parsing
> implementation needs to have access to them. When finished, the slices
> are freed. A simple ring buffer cannot cope with the gaps that emerge by
> that.
>
> When a connection buffer is written to, it is done from the context of
> another task which calls into the kdbus code through one of the ioctls.
> The memcg implementation should hence charge the task that acts as
> writer, which is maybe not ideal but can be changed easily with some
> addition to the internal APIs. We omitted it for the current version,
> which is non-intrusive with regards to other kernel subsystems.
>

This has at least the following weakness.  I can very easily get
systemd to write to my shmem-backed pool: simply subscribe to one of
its broadcasts.  If I cause such a write to be very slow
(intentionally or otherwise), then PID 1 blocks.

If you change the memcg code to charge me instead of PID 1 (as it
should IMO), then the problem gets worse.

> The kdbus implementation is actually comparable to two tasks X and Y
> which both have their own buffer file open and mmap()ed, and they both
> pass their FD to the other side. If X now writes to Y's file, and that
> is causing a page fault, X is accounted for it, correct?

If PID 1 accepted a memfd from me (even a properly sealed one) and
wrote to it, I would wonder whether it were actually a good idea.

Does this scheme have any actual measurable advantage over the
traditional model of a small non-paged buffer in the kernel (i.e. the
way sockets work) with explicit userspace memfd use as appropriate?

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
