Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id D3B276B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 18:24:31 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id x62so5432389ioe.8
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 15:24:31 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n7sor1700588ith.88.2017.12.19.15.24.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Dec 2017 15:24:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171219214849.GU21978@ZenIV.linux.org.uk>
References: <001a113e9ca8a3affd05609d7ccf@google.com> <6a50d160-56d0-29f9-cfed-6c9202140b43@I-love.SAKURA.ne.jp>
 <CAGXu5jKLBuQ8Ne6BjjPH+1SVw-Fj4ko5H04GHn-dxXYwoMEZtw@mail.gmail.com>
 <CACT4Y+a3h0hmGpfVaePX53QUQwBhN9BUyERp-5HySn74ee_Vxw@mail.gmail.com>
 <20171219083746.GR19604@eros> <20171219132246.GD13680@bombadil.infradead.org>
 <CA+55aFwvMMg0Kt8z+tkgPREbX--Of0R5nr_wS4B64kFxiVVKmw@mail.gmail.com> <20171219214849.GU21978@ZenIV.linux.org.uk>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 19 Dec 2017 15:24:29 -0800
Message-ID: <CA+55aFw3ax7a3neTBiF=NnjM_uPAeGOz17xcT42Bg7McU1-WCA@mail.gmail.com>
Subject: Re: BUG: bad usercopy in memdup_user
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: Matthew Wilcox <willy@infradead.org>, "Tobin C. Harding" <me@tobin.cc>, Dmitry Vyukov <dvyukov@google.com>, Kees Cook <keescook@chromium.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Linux-MM <linux-mm@kvack.org>, syzbot <bot+719398b443fd30155f92f2a888e749026c62b427@syzkaller.appspotmail.com>, David Windsor <dave@nullcore.net>, keun-o.park@darkmatter.ae, Laura Abbott <labbott@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Mark Rutland <mark.rutland@arm.com>, Ingo Molnar <mingo@kernel.org>, syzkaller-bugs@googlegroups.com, Will Deacon <will.deacon@arm.com>

On Tue, Dec 19, 2017 at 1:48 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> On Tue, Dec 19, 2017 at 01:36:46PM -0800, Linus Torvalds wrote:
>
>> I suspect that an "offset and size within the kernel object" value
>> might make sense.  But what does the _pointer_ tell you?
>
> Well, for example seeing a 0xfffffffffffffff4 where a pointer to object
> must have been is a pretty strong hint to start looking for a way for
> that ERR_PTR(-ENOMEM) having ended up there...  Something like
> 0x6e69622f7273752f is almost certainly a misplaced "/usr/bin", i.e. a
> pathname overwriting whatever it ends up in, etc.  And yes, I have run
> into both of those in real life.

Sure. But that's for a faulting address when you have an invalid pointer.

That's not the case here at all.

Here, we've explicitly checked that it's a kernel pointer of some
particular type (in a slab cache in this case), and the pointer is
valid but shouldn't be copied to/from user space.

So it's not something like 0xfffffffffffffff4 or 0x6e69622f7273752f.
It's something like "in slab cache for size 1024".

So the pointer value isn't interesting. But the offset within the slab could be.

See? This is what I am talking about. People don't actually seem to
*think* about what the %p is. There seems to be very little critical
thinking about what should be printed out, and what is actually
useful.

The most common thing seems to be "I'm confused by a bad value".  But
that should *not* cause a mindless "let's not hash it" reaction.

It should cause actual thinking about the situation! Not about %p in
general, but very much about the situation of THAT PARTICULAR use of
%p.

That's what I'm looking for, and what I'm not seeing in these discussions.

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
