Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 235DD6B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 17:16:32 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id u16so15262323pfh.7
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 14:16:32 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id n1si11739146pld.460.2017.12.19.14.16.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Dec 2017 14:16:31 -0800 (PST)
Date: Tue, 19 Dec 2017 14:16:25 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: BUG: bad usercopy in memdup_user
Message-ID: <20171219221625.GB22696@bombadil.infradead.org>
References: <001a113e9ca8a3affd05609d7ccf@google.com>
 <6a50d160-56d0-29f9-cfed-6c9202140b43@I-love.SAKURA.ne.jp>
 <CAGXu5jKLBuQ8Ne6BjjPH+1SVw-Fj4ko5H04GHn-dxXYwoMEZtw@mail.gmail.com>
 <CACT4Y+a3h0hmGpfVaePX53QUQwBhN9BUyERp-5HySn74ee_Vxw@mail.gmail.com>
 <20171219083746.GR19604@eros>
 <20171219132246.GD13680@bombadil.infradead.org>
 <CA+55aFwvMMg0Kt8z+tkgPREbX--Of0R5nr_wS4B64kFxiVVKmw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwvMMg0Kt8z+tkgPREbX--Of0R5nr_wS4B64kFxiVVKmw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Tobin C. Harding" <me@tobin.cc>, Dmitry Vyukov <dvyukov@google.com>, Kees Cook <keescook@chromium.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Linux-MM <linux-mm@kvack.org>, syzbot <bot+719398b443fd30155f92f2a888e749026c62b427@syzkaller.appspotmail.com>, David Windsor <dave@nullcore.net>, keun-o.park@darkmatter.ae, Laura Abbott <labbott@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Mark Rutland <mark.rutland@arm.com>, Ingo Molnar <mingo@kernel.org>, syzkaller-bugs@googlegroups.com, Will Deacon <will.deacon@arm.com>

On Tue, Dec 19, 2017 at 01:36:46PM -0800, Linus Torvalds wrote:
> On Tue, Dec 19, 2017 at 5:22 AM, Matthew Wilcox <willy@infradead.org> wrote:
> >
> > Could we have a way to know that the printed address is hashed and not just
> > a pointer getting completely scrogged?  Perhaps prefix it with ... a hash!
> > So this line would look like:
> 
> The problem with that is that it will break tools that parse things.

Yeah, but the problem is that until people know to expect hashes, it
breaks people.  I spent most of a day last week puzzling over a value
coming from a VM_BUG_ON that was explicitly tested for and couldn't
happen.

> When we find something like this, we should either remove it, fix the
> permissions, or switch to %px.

Right; I sent a patch to fix VM_BUG_ON earlier today after reading
this thread.

> But honestly, what do people expect that the pointer value will
> actually tell you if it is unhashed?

It would have been meaningful to me.  For a start, I would have seen
that the bottom two bits were clear, so this was actually a pointer and
not something masquerading as a pointer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
