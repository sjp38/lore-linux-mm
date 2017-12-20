Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id A951E6B0038
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 04:43:53 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id m134so5018465lfg.12
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 01:43:53 -0800 (PST)
Received: from smtp-out4.electric.net (smtp-out4.electric.net. [192.162.216.183])
        by mx.google.com with ESMTPS id n1si158498lfn.48.2017.12.20.01.43.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Dec 2017 01:43:51 -0800 (PST)
From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: BUG: bad usercopy in memdup_user
Date: Wed, 20 Dec 2017 09:44:00 +0000
Message-ID: <d6c8c26ba44847299c4db9136d60957d@AcuMS.aculab.com>
References: <001a113e9ca8a3affd05609d7ccf@google.com>
 <6a50d160-56d0-29f9-cfed-6c9202140b43@I-love.SAKURA.ne.jp>
 <CAGXu5jKLBuQ8Ne6BjjPH+1SVw-Fj4ko5H04GHn-dxXYwoMEZtw@mail.gmail.com>
 <CACT4Y+a3h0hmGpfVaePX53QUQwBhN9BUyERp-5HySn74ee_Vxw@mail.gmail.com>
 <20171219083746.GR19604@eros> <20171219132246.GD13680@bombadil.infradead.org>
 <CA+55aFwvMMg0Kt8z+tkgPREbX--Of0R5nr_wS4B64kFxiVVKmw@mail.gmail.com>
 <20171219214849.GU21978@ZenIV.linux.org.uk>
In-Reply-To: <20171219214849.GU21978@ZenIV.linux.org.uk>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Al Viro' <viro@ZenIV.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>, "Tobin C. Harding" <me@tobin.cc>, Dmitry Vyukov <dvyukov@google.com>, Kees Cook <keescook@chromium.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Linux-MM <linux-mm@kvack.org>, syzbot <bot+719398b443fd30155f92f2a888e749026c62b427@syzkaller.appspotmail.com>, David Windsor <dave@nullcore.net>, "keun-o.park@darkmatter.ae" <keun-o.park@darkmatter.ae>, Laura Abbott <labbott@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Mark Rutland <mark.rutland@arm.com>, Ingo
 Molnar <mingo@kernel.org>, "syzkaller-bugs@googlegroups.com" <syzkaller-bugs@googlegroups.com>, Will Deacon <will.deacon@arm.com>

From: Al Viro
> Sent: 19 December 2017 21:49
> > I suspect that an "offset and size within the kernel object" value
> > might make sense.  But what does the _pointer_ tell you?
>=20
> Well, for example seeing a 0xfffffffffffffff4 where a pointer to object
> must have been is a pretty strong hint to start looking for a way for
> that ERR_PTR(-ENOMEM) having ended up there...  Something like
> 0x6e69622f7273752f is almost certainly a misplaced "/usr/bin", i.e. a
> pathname overwriting whatever it ends up in, etc.  And yes, I have run
> into both of those in real life.
>=20
> Debugging the situation when crap value has ended up in place of a
> pointer is certainly a case where you do want to see what exactly has
> ended up in there...

I've certainly seen a lot of ascii in pointers (usually because the
previous item has overrun).
Although I suspect they'd appear in the fault frame - which hopefully
carries real addresses.

A compromise would be to hash the 'page' part of the address.
On 64bit systems this is probably about 32 bits.
It would still show whether pointers are user, kernel, vmalloc (etc)
but without giving away the actual value.
The page offset (12 bits) would show the alignment (etc).

Including a per-boot random number would make it harder to generate
'rainbow tables' to reverse the hash.

	David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
