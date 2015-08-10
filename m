Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 817AC6B0038
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 13:04:19 -0400 (EDT)
Received: by igbpg9 with SMTP id pg9so73599971igb.0
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 10:04:19 -0700 (PDT)
Received: from mail-io0-x22f.google.com (mail-io0-x22f.google.com. [2607:f8b0:4001:c06::22f])
        by mx.google.com with ESMTPS id i4si6072549igj.30.2015.08.10.10.04.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Aug 2015 10:04:18 -0700 (PDT)
Received: by ioii16 with SMTP id i16so175795922ioi.0
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 10:04:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <55C7D02A.9060905@zonque.org>
References: <CANq1E4SnYq_pZMWYcafB9GmB_O77tbVLPT0=0d6LGQVpvThTrw@mail.gmail.com>
	<CALCETrWE-oYRq+AzRxxcz03AK0pAzgKJtmxAuNwQu+p5S0msBw@mail.gmail.com>
	<CANq1E4Rek3HXCDU_13OGfRShS7Z0g+fxcTp5C1V3oKC4HgkD_A@mail.gmail.com>
	<CALCETrUaSgdaq4_mr3GG-ekLwGXkQR5MoRLSj9Wu2dTXDYUp1g@mail.gmail.com>
	<CANq1E4SkUWWXuksJnWzXd5KStZx-T6q6+WWTHdrQz_WiMry4Cw@mail.gmail.com>
	<CALCETrXcqOFedk8r-jHK-deRwfum29JHspALE6JUi2gzbo-dhg@mail.gmail.com>
	<55C3A403.8020202@zonque.org>
	<CALCETrVr04ZdXHLZXLp_Y+m68Db5Mmh_Wnu6prNCfCqgWm0QzA@mail.gmail.com>
	<55C4C35A.4070306@zonque.org>
	<CA+55aFxDLt-5+=xXeYG4nJKMb8L_iD9FmwTZ2VuughBku-mW3g@mail.gmail.com>
	<20150809190027.GA24185@kroah.com>
	<55C7D02A.9060905@zonque.org>
Date: Mon, 10 Aug 2015 10:04:18 -0700
Message-ID: <CA+55aFwU36z9A-R38tQfCtXdsN-GSsTCspKr6g3+AV13v185DA@mail.gmail.com>
Subject: Re: kdbus: to merge or not to merge?
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Mack <daniel@zonque.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Tom Gundersen <teg@jklm.no>, "Kalle A. Sandstrom" <ksandstr@iki.fi>, Borislav Petkov <bp@alien8.de>, One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, Havoc Pennington <havoc.pennington@gmail.com>, Djalal Harouni <tixxdz@opendz.org>, Andy Lutomirski <luto@amacapital.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Eric W. Biederman" <ebiederm@xmission.com>, cee1 <fykcee1@gmail.com>, David Herrmann <dh.herrmann@gmail.com>, linux-mm <linux-mm@kvack.org>

On Sun, Aug 9, 2015 at 3:11 PM, Daniel Mack <daniel@zonque.org> wrote:
>
> The kdbus implementation is actually comparable to two tasks X and Y
> which both have their own buffer file open and mmap()ed, and they both
> pass their FD to the other side. If X now writes to Y's file, and that
> is causing a page fault, X is accounted for it, correct?

No.

With shared memory, there's no particularly obvious accounting rules.
In particular, when somebody maps an already allocated page, it's
basically a no-op from a memory allocation standpoint.

The whole "this is equivalent to the user space deamon" argument is
bogus. Shared memory is very very different from just sending messages
(copying the buffers) and is generally much harder to get a handle on.
And thats' what you should be comparing to.

The old "communicate over a unix domain socket" had pretty clear
accounting rules, and while unix domain sockets have some horribly
nasty issues (most are about passing fd's around) that isn't one of
them.

Anyway, the real issue for me here is that Andy is reporting all these
actual real problems that happen in practice, and the developer
replies are dismissing them on totally irrelevant grounds ("this
should be equivalent to something entirely different that nobody ever
does" or "well, people could opt out, even if they didn't" yadda yadda
yadda).

For example, the whole "tasks X and Y communicate over shmem" is
irrelevant. Normally, when people write those kinds of applications,
they are just regular applications. If they have issues, nobody else
cares. Andy's concern is about one of X/Y being a system daemon and
tricking it into doing bad things ends up effectively killing the
system - whether the *kernel* is alive or not and did the right thing
is almost entirely immaterial.

So please. When Andy sends a bug report with a exploit that kills his
system, just stop responding with irrelevant theoretical arguments. It
is not appropriate.  Instead, acknowledge the problem and work on
fixing it, none of this "but but but it's all the same" crap.

                     Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
