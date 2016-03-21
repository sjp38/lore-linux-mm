Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1564E6B0005
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 09:45:21 -0400 (EDT)
Received: by mail-wm0-f51.google.com with SMTP id r129so51122111wmr.1
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 06:45:21 -0700 (PDT)
Received: from mail-wm0-x22a.google.com (mail-wm0-x22a.google.com. [2a00:1450:400c:c09::22a])
        by mx.google.com with ESMTPS id in5si13298704wjb.155.2016.03.21.06.45.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Mar 2016 06:45:20 -0700 (PDT)
Received: by mail-wm0-x22a.google.com with SMTP id l68so152214185wml.0
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 06:45:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <15565.1458436494@turing-police.cc.vt.edu>
References: <7300.1458333684@turing-police.cc.vt.edu>
	<CAG_fn=WKjdcUSi5JoiAPrmRCLEL-SWyGHCOYOZiZQ_fnFDvydQ@mail.gmail.com>
	<15565.1458436494@turing-police.cc.vt.edu>
Date: Mon, 21 Mar 2016 14:45:18 +0100
Message-ID: <CAG_fn=VMU=gGMkhpiYPc11HyQL7FqD=iyOj74b46WWQOFFFcsg@mail.gmail.com>
Subject: Re: KASAN overhead?
From: Alexander Potapenko <glider@google.com>
Content-Type: multipart/mixed; boundary=001a1130c848b448b7052e8f4e32
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Cc: Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>

--001a1130c848b448b7052e8f4e32
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Sun, Mar 20, 2016 at 2:14 AM,  <Valdis.Kletnieks@vt.edu> wrote:
> On Sat, 19 Mar 2016 13:13:59 +0100, Alexander Potapenko said:
>
>> Which GCC version were you using? Are you sure it didn't accidentally
>> enable the outline instrumentation (e.g. if the compiler is too old)?
>
>  gcc --version
> gcc (GCC) 6.0.0 20160311 (Red Hat 6.0.0-0.16)
>
> * Fri Mar 11 2016 Jakub Jelinek <jakub@redhat.com> 6.0.0-0.15
> - update from the trunk
>
> Doesn't get much newer than that.. :) (Hmm.. possibly *too* new?)
Fine,this one should be new enough.
>> > and saw an *amazing* slowdown.
>> Have you tried earlier KASAN versions? Is this a recent regression?
>
> First time I'd tried it, so no comparison point..
>
>> Was KASAN reporting anything between these lines? Sometimes a recurring
>> warning slows everything down.
>
> Nope, it didn't report a single thing.
>
>> How did it behave after the startup? Was it still slow?
>
> After seeing how long it took to get to a single-user prompt, I didn't
> investigate further. It took 126 seconds to get here:
>
> [  126.937247] audit: type=3D1327 audit(1458268293.617:100): proctitle=3D=
"/usr/sbin/sulogin"
>
> compared to the more usual:
>
> [   29.249260] audit: type=3D1327 audit(1458326938.276:100): proctitle=3D=
"/usr/sbin/sulogin"
>
> (In both cases, there's a 10-12 second pause for entering a LUKS
> passphrase, so we're looking at about 110 seconds with KASAN versus
> about 17-18 without.)
>
>> Which machine were you using? Was it a real device or a VM?
>
> Running native on a Dell Latitude laptop....
>
> (Based on the fact that you're asking questions rather than just saying
> it's expected behavior, I'm guessing I've once again managed to find
> a corner case of some sort.  I'm more than happy to troubleshoot, if
> you can provide hints of what to try...)

On my machine the kernel startup times with and without KASAN are
mostly similar (8.4 vs. 6.2 seconds), but I don't think the startup
times actually reflect anything.
First, they depend heavily on the kernel configuration, and second,
the percentage of time spent in the kernel during startup is greater
than that during normal operation.
With the attached benchmark (which is far from being ideal, but may
give some idea about the slowdown) I'm seeing the slowdown factor of
around 2.5x, which is more realistic.


--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

--001a1130c848b448b7052e8f4e32
Content-Type: text/x-csrc; charset=US-ASCII; name="bench_pipes.c"
Content-Disposition: attachment; filename="bench_pipes.c"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_im21o5xd1

I2luY2x1ZGUgPHVuaXN0ZC5oPgojaW5jbHVkZSA8c3lzL3R5cGVzLmg+CiNpbmNsdWRlIDxzdGRs
aWIuaD4KI2luY2x1ZGUgPHN0ZGlvLmg+CiNpbmNsdWRlIDxlcnJuby5oPgojaW5jbHVkZSA8cHRo
cmVhZC5oPgoKCnN0YXRpYyBpbnQgbnBpcGVzID0gMTsKc3RhdGljIGludCBuaXRlcnMgPSAxOwoK
CnZvaWQgKmRvX3BpcGVzKHZvaWQqIHVudXNlZCk7CgppbnQgbWFpbihpbnQgYXJnYywgY2hhciAq
KmFyZ3YpIHsKCWludCBudGhyZWFkcyA9IDE7CglwdGhyZWFkX3QgKnRocmVhZHM7CglwdGhyZWFk
X2F0dHJfdCBhdHRyOwoJaW50IHJjID0gMDsKCWludCBpOwoJaWYgKGFyZ2MgPCAyKSB7CgkJcHJp
bnRmKCJVc2FnZTogJXMgPG5waXBlcz4gPG5pdGVycz4gPG50aHJlYWRzPlxuIiwgYXJndlswXSk7
CgkJcmV0dXJuIDE7Cgl9CglucGlwZXMgPSBhdG9pKGFyZ3ZbMV0pOwoJaWYgKGFyZ2MgPj0gMykg
CgkJbml0ZXJzID0gYXRvaShhcmd2WzJdKTsKCWlmIChhcmdjID49IDQpCgkJbnRocmVhZHMgPSBh
dG9pKGFyZ3ZbM10pOwoJCglwdGhyZWFkX2F0dHJfaW5pdCgmYXR0cik7CglwdGhyZWFkX2F0dHJf
c2V0ZGV0YWNoc3RhdGUoJmF0dHIsIFBUSFJFQURfQ1JFQVRFX0pPSU5BQkxFKTsKCXRocmVhZHMg
PSBtYWxsb2Moc2l6ZW9mKHB0aHJlYWRfdCkgKiBudGhyZWFkcyk7Cglmb3IgKGkgPSAwOyBpIDwg
bnRocmVhZHM7IGkrKykgewoJCXJjID0gcHRocmVhZF9jcmVhdGUoJnRocmVhZHNbaV0sICZhdHRy
LCAmZG9fcGlwZXMsIE5VTEwpOwoJCWlmIChyYykgewoJCQlwcmludGYoIkNvdWxkbid0IHN0YXJ0
IHRocmVhZC4gZXJyb3IgJWRcbiIsIHJjKTsKCQkJcmV0dXJuIC0xOwkKCQl9Cgl9CglwdGhyZWFk
X2F0dHJfZGVzdHJveSgmYXR0cik7Cglmb3IgKGkgPSAwOyBpIDwgbnRocmVhZHM7IGkrKykgewoJ
CXJjID0gcHRocmVhZF9qb2luKHRocmVhZHNbaV0sIE5VTEwpOwoJCWlmIChyYykgewoJCQlwcmlu
dGYoIkNvdWxkbid0IGpvaW4gdGhyZWFkLiBlcnJvciAlZFxuIiwgcmMpOwoJCQlyZXR1cm4gLTE7
CQoJCX0KCX0KCWZyZWUodGhyZWFkcyk7CglwdGhyZWFkX2V4aXQoTlVMTCk7Cn0KCnZvaWQgKmRv
X3BpcGVzKHZvaWQqIHVudXNlZCkgewoJaW50KiBwaXBlczsKCWludCBpLGo7CgljaGFyIGMgPSAn
YSc7CglwaXBlcyA9IG1hbGxvYyhzaXplb2YoaW50KSAqIG5waXBlcyAqIDIpOwoJZm9yIChqID0g
MDsgaiA8IG5pdGVyczsgKytqKSB7CgkJZm9yIChpID0gMDsgaSA8IG5waXBlczsgKytpKSB7CgkJ
CWlmIChwaXBlKCZwaXBlc1tpICogMl0pKSB7CgkJCQlwZXJyb3IoIkNvdWxkbid0IG9wZW4gcGlw
ZSIpOwoJCQkJZnJlZShwaXBlcyk7CgkJCQlleGl0KC0xKTsKCQkJfQoJCS8vCXdyaXRlKHBpcGVz
W2kgKiAyICsgMV0sICZjLCAxKTsKCQl9CgkJZm9yIChpID0gMDsgaSA8IG5waXBlczsgKytpKSB7
CgkJLy8JcmVhZChwaXBlc1tpICogMl0sICZjLCAxKTsKCQkJY2xvc2UocGlwZXNbaSAqIDJdKTsK
CQkJY2xvc2UocGlwZXNbaSAqIDIgKyAxXSk7CgkJfQoJfQoJZnJlZShwaXBlcyk7CglwdGhyZWFk
X2V4aXQodW51c2VkKTsKfQo=
--001a1130c848b448b7052e8f4e32--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
