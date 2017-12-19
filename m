Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 79BC06B0253
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 16:36:48 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id h200so3191754itb.3
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 13:36:48 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a124sor1201337itg.111.2017.12.19.13.36.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Dec 2017 13:36:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171219132246.GD13680@bombadil.infradead.org>
References: <001a113e9ca8a3affd05609d7ccf@google.com> <6a50d160-56d0-29f9-cfed-6c9202140b43@I-love.SAKURA.ne.jp>
 <CAGXu5jKLBuQ8Ne6BjjPH+1SVw-Fj4ko5H04GHn-dxXYwoMEZtw@mail.gmail.com>
 <CACT4Y+a3h0hmGpfVaePX53QUQwBhN9BUyERp-5HySn74ee_Vxw@mail.gmail.com>
 <20171219083746.GR19604@eros> <20171219132246.GD13680@bombadil.infradead.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 19 Dec 2017 13:36:46 -0800
Message-ID: <CA+55aFwvMMg0Kt8z+tkgPREbX--Of0R5nr_wS4B64kFxiVVKmw@mail.gmail.com>
Subject: Re: BUG: bad usercopy in memdup_user
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Tobin C. Harding" <me@tobin.cc>, Dmitry Vyukov <dvyukov@google.com>, Kees Cook <keescook@chromium.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Linux-MM <linux-mm@kvack.org>, syzbot <bot+719398b443fd30155f92f2a888e749026c62b427@syzkaller.appspotmail.com>, David Windsor <dave@nullcore.net>, keun-o.park@darkmatter.ae, Laura Abbott <labbott@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Mark Rutland <mark.rutland@arm.com>, Ingo Molnar <mingo@kernel.org>, syzkaller-bugs@googlegroups.com, Will Deacon <will.deacon@arm.com>

On Tue, Dec 19, 2017 at 5:22 AM, Matthew Wilcox <willy@infradead.org> wrote:
>
> Could we have a way to know that the printed address is hashed and not just
> a pointer getting completely scrogged?  Perhaps prefix it with ... a hash!
> So this line would look like:

The problem with that is that it will break tools that parse things.

So no, it won't work.

When we find something like this, we should either remove it, fix the
permissions, or switch to %px.

In this case, there's obviously no permission issue: it's an error
report. So it's either "remove it, or switch to %px".

I'm personally not clear on whether the pointer really makes any sense
at all. But if it does, it should just be changed to %px, since it's a
bug report.

But honestly, what do people expect that the pointer value will
actually tell you if it is unhashed?

I suspect that an "offset and size within the kernel object" value
might make sense.  But what does the _pointer_ tell you?

I've noticed this with pretty much every report. People get upset
about the hashing, but don't seem to actually be able to ever tell
what the f*ck they would use the non-hashed pointer value for.

I've asked for this before: whenever somebody complains about the
hashing, you had better tell exactly what the unhashed value would
have given you, and how it would have helped debug the problem.

Because if you can't tell that, then dammit, then we should just
_remove_ the stupid %p.

Instead, people ask for "can I get everything unhashed" even when they
can't give a reason for it.

            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
