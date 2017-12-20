Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id ACF0C6B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 23:05:24 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id b11so3896061itj.0
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 20:05:24 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r64sor1919569ith.26.2017.12.19.20.05.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Dec 2017 20:05:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171220035043.GA14980@bombadil.infradead.org>
References: <001a113e9ca8a3affd05609d7ccf@google.com> <6a50d160-56d0-29f9-cfed-6c9202140b43@I-love.SAKURA.ne.jp>
 <CAGXu5jKLBuQ8Ne6BjjPH+1SVw-Fj4ko5H04GHn-dxXYwoMEZtw@mail.gmail.com>
 <CACT4Y+a3h0hmGpfVaePX53QUQwBhN9BUyERp-5HySn74ee_Vxw@mail.gmail.com>
 <20171219083746.GR19604@eros> <20171219132246.GD13680@bombadil.infradead.org>
 <CA+55aFwvMMg0Kt8z+tkgPREbX--Of0R5nr_wS4B64kFxiVVKmw@mail.gmail.com>
 <20171219214849.GU21978@ZenIV.linux.org.uk> <20171220035043.GA14980@bombadil.infradead.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 19 Dec 2017 20:05:22 -0800
Message-ID: <CA+55aFw++4iFkodaEXSPpdvcSTvsggnJWpg-wVyFW54ay_ts8g@mail.gmail.com>
Subject: Re: BUG: bad usercopy in memdup_user
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, "Tobin C. Harding" <me@tobin.cc>, Dmitry Vyukov <dvyukov@google.com>, Kees Cook <keescook@chromium.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Linux-MM <linux-mm@kvack.org>, syzbot <bot+719398b443fd30155f92f2a888e749026c62b427@syzkaller.appspotmail.com>, David Windsor <dave@nullcore.net>, keun-o.park@darkmatter.ae, Laura Abbott <labbott@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Mark Rutland <mark.rutland@arm.com>, Ingo Molnar <mingo@kernel.org>, syzkaller-bugs@googlegroups.com, Will Deacon <will.deacon@arm.com>

On Tue, Dec 19, 2017 at 7:50 PM, Matthew Wilcox <willy@infradead.org> wrote:
> On Tue, Dec 19, 2017 at 09:48:49PM +0000, Al Viro wrote:
>> Well, for example seeing a 0xfffffffffffffff4 where a pointer to object
>> must have been is a pretty strong hint to start looking for a way for
>> that ERR_PTR(-ENOMEM) having ended up there...  Something like
>> 0x6e69622f7273752f is almost certainly a misplaced "/usr/bin", i.e. a
>> pathname overwriting whatever it ends up in, etc.  And yes, I have run
>> into both of those in real life.
>>
>> Debugging the situation when crap value has ended up in place of a
>> pointer is certainly a case where you do want to see what exactly has
>> ended up in there...
>
> Linus, how would you feel about printing ERR_PTRs without molestation?

Stop this stupidity already.

Guys, seriously. You're making idiotic arguments that have nothing to
do with reality.

If you actually have an invalid pointer that causes an oops (whether
it's an ERR_PTR or something like 0x6e69622f7273752f or something like
the list poison values etc),

  WE ALREADY PRINT OUT THE WHOLE UNHASHED POINTER VALUE

This "but but but some pointers are magic and shouldn't be hashed"
stuff is *garbage*. You're making shit up. You don't have a single
actual real-life example that you can point to that is relevant.

Again, I've seen those bad pointer oopses myself. Yes, the magic
values are relevant, and should be printed out.

BUT THEY ALREADY ARE PRINTED OUT.

Christ.

So let me repeat:

 - don't change %p behavior.

 - don't use "I was confused" as an argument. Yes, things changed, and
yes, it clearly caused confusion, but that is temporary and is not an
argument for making magic changes.

 - don't make up some garbage theoretical example: give a hard example
of output that actually didn't have enough information.

And yes, we'll just replace the %p with %px when that last situation
holds. Really. Really really.

But it needs to be a real example, not a "what if" that doesn't make sense.

Not some pet theory that doesn't hold water.

This whole "what if it was a poison pointer" argument is a _prime_
example of pure and utter garbage.

If we have an oops, and it was due a poison value or an err-pointer
that we dereferenced, we will *see* the poison value.

It will be right there in the register state.

It will be right there in the bad address.

It will be quite visible.

And yes, we had a few cases where the hashing actually did hide the
values, and I've been applying patches to turn those from %p to %px.

But it had better be actual real cases, and real thought out
situations. Not "let's just randomly pick values that we don't hash".

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
