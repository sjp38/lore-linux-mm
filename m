Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 223306B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 23:36:37 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id q3so3042585ioh.19
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 20:36:37 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a16sor1548256itc.124.2017.12.19.20.36.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Dec 2017 20:36:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFw++4iFkodaEXSPpdvcSTvsggnJWpg-wVyFW54ay_ts8g@mail.gmail.com>
References: <001a113e9ca8a3affd05609d7ccf@google.com> <6a50d160-56d0-29f9-cfed-6c9202140b43@I-love.SAKURA.ne.jp>
 <CAGXu5jKLBuQ8Ne6BjjPH+1SVw-Fj4ko5H04GHn-dxXYwoMEZtw@mail.gmail.com>
 <CACT4Y+a3h0hmGpfVaePX53QUQwBhN9BUyERp-5HySn74ee_Vxw@mail.gmail.com>
 <20171219083746.GR19604@eros> <20171219132246.GD13680@bombadil.infradead.org>
 <CA+55aFwvMMg0Kt8z+tkgPREbX--Of0R5nr_wS4B64kFxiVVKmw@mail.gmail.com>
 <20171219214849.GU21978@ZenIV.linux.org.uk> <20171220035043.GA14980@bombadil.infradead.org>
 <CA+55aFw++4iFkodaEXSPpdvcSTvsggnJWpg-wVyFW54ay_ts8g@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 19 Dec 2017 20:36:34 -0800
Message-ID: <CA+55aFypUZ0AwgzNoJy2xSG0m1vppMMC=mvGtUTAWVm_soZh_Q@mail.gmail.com>
Subject: Re: BUG: bad usercopy in memdup_user
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, "Tobin C. Harding" <me@tobin.cc>, Dmitry Vyukov <dvyukov@google.com>, Kees Cook <keescook@chromium.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Linux-MM <linux-mm@kvack.org>, syzbot <bot+719398b443fd30155f92f2a888e749026c62b427@syzkaller.appspotmail.com>, David Windsor <dave@nullcore.net>, keun-o.park@darkmatter.ae, Laura Abbott <labbott@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Mark Rutland <mark.rutland@arm.com>, Ingo Molnar <mingo@kernel.org>, syzkaller-bugs@googlegroups.com, Will Deacon <will.deacon@arm.com>

On Tue, Dec 19, 2017 at 8:05 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> And yes, we had a few cases where the hashing actually did hide the
> values, and I've been applying patches to turn those from %p to %px.

So far at least:

  10a7e9d84915 Do not hash userspace addresses in fault handlers
  85c3e4a5a185 mm/slab.c: do not hash pointers when debugging slab
  d81041820873 powerpc/xmon: Don't print hashed pointers in xmon
  328b4ed93b69 x86: don't hash faulting address in oops printout
  b7ad7ef742a9 remove task and stack pointer printout from oops dump
  6424f6bb4327 kasan: use %px to print addresses instead of %p

although that next-to-last case is a "remove %p" case rather than
"convert to %px".

And we'll probably hit a few more, I'm not at all claiming that we're
somehow "done". There's bound to be other cases people haven't noticed
yet (or haven't patched yet, like the usercopy case that Kees is
signed up to fix up).

But considering that we had something like 12k of those %p users, I
think a handful now (and maybe a few tens eventually) is worth the
pain and confusion.

I just want to make sure that the ones we _do_ convert we actually
spend the mental effort really looking at, and really asking "does it
make sense to convert this?"

Not just knee-jerking "oh, it's hashed, let's just unhash it".

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
