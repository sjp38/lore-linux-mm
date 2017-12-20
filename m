Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 069996B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 22:50:54 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id 61so8691861plz.1
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 19:50:53 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id n1si12072207plp.680.2017.12.19.19.50.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Dec 2017 19:50:52 -0800 (PST)
Date: Tue, 19 Dec 2017 19:50:43 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: BUG: bad usercopy in memdup_user
Message-ID: <20171220035043.GA14980@bombadil.infradead.org>
References: <001a113e9ca8a3affd05609d7ccf@google.com>
 <6a50d160-56d0-29f9-cfed-6c9202140b43@I-love.SAKURA.ne.jp>
 <CAGXu5jKLBuQ8Ne6BjjPH+1SVw-Fj4ko5H04GHn-dxXYwoMEZtw@mail.gmail.com>
 <CACT4Y+a3h0hmGpfVaePX53QUQwBhN9BUyERp-5HySn74ee_Vxw@mail.gmail.com>
 <20171219083746.GR19604@eros>
 <20171219132246.GD13680@bombadil.infradead.org>
 <CA+55aFwvMMg0Kt8z+tkgPREbX--Of0R5nr_wS4B64kFxiVVKmw@mail.gmail.com>
 <20171219214849.GU21978@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171219214849.GU21978@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "Tobin C. Harding" <me@tobin.cc>, Dmitry Vyukov <dvyukov@google.com>, Kees Cook <keescook@chromium.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Linux-MM <linux-mm@kvack.org>, syzbot <bot+719398b443fd30155f92f2a888e749026c62b427@syzkaller.appspotmail.com>, David Windsor <dave@nullcore.net>, keun-o.park@darkmatter.ae, Laura Abbott <labbott@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Mark Rutland <mark.rutland@arm.com>, Ingo Molnar <mingo@kernel.org>, syzkaller-bugs@googlegroups.com, Will Deacon <will.deacon@arm.com>

On Tue, Dec 19, 2017 at 09:48:49PM +0000, Al Viro wrote:
> Well, for example seeing a 0xfffffffffffffff4 where a pointer to object
> must have been is a pretty strong hint to start looking for a way for
> that ERR_PTR(-ENOMEM) having ended up there...  Something like
> 0x6e69622f7273752f is almost certainly a misplaced "/usr/bin", i.e. a
> pathname overwriting whatever it ends up in, etc.  And yes, I have run
> into both of those in real life.
> 
> Debugging the situation when crap value has ended up in place of a
> pointer is certainly a case where you do want to see what exactly has
> ended up in there...

Linus, how would you feel about printing ERR_PTRs without molestation?
It's not going to leak any information about the kernel address space
layout.  I'm a little less certain about trying to detect ASCII strings,
but I think this is an improvement.

diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index 01c3957b2de6..c80c60b4b3ef 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -1859,6 +1859,9 @@ char *pointer(const char *fmt, char *buf, char *end, void *ptr,
 		return string(buf, end, "(null)", spec);
 	}
 
+	if (IS_ERR(ptr))
+		return pointer_string(buf, end, ptr, spec);
+
 	switch (*fmt) {
 	case 'F':
 	case 'f':

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
