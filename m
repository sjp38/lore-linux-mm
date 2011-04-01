Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A63228D0040
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 12:44:11 -0400 (EDT)
Received: from mail-iw0-f169.google.com (mail-iw0-f169.google.com [209.85.214.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.14.2/Debian-2build1) with ESMTP id p31Ghemr029827
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Fri, 1 Apr 2011 09:43:41 -0700
Received: by iwg8 with SMTP id 8so5248918iwg.14
        for <linux-mm@kvack.org>; Fri, 01 Apr 2011 09:43:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTim3x=1n+F7yD-euY0=RhmyXViUamg@mail.gmail.com>
References: <alpine.LSU.2.00.1102232136020.2239@sister.anvils>
 <AANLkTi==MQV=_qq1HaCxGLRu8DdT6FYddqzBkzp1TQs7@mail.gmail.com>
 <AANLkTimv66fV1+JDqSAxRwddvy_kggCuhoJLMTpMTtJM@mail.gmail.com>
 <alpine.LSU.2.00.1103182158200.18771@sister.anvils> <BANLkTinoNMudwkcOOgU5d+imPUfZhDbWWQ@mail.gmail.com>
 <AANLkTimfArmB7judMW7Qd4ATtVaR=yTf_-0DBRAfCJ7w@mail.gmail.com> <BANLkTim3x=1n+F7yD-euY0=RhmyXViUamg@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 1 Apr 2011 09:35:41 -0700
Message-ID: <AANLkTik4q8N9vYUibSZfepUmhYoREo2dbH5NFZAHuOFb@mail.gmail.com>
Subject: Re: [PATCH] mm: fix possible cause of a page_mapped BUG
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?Um9iZXJ0IMWad2nEmWNraQ==?= <robert@swiecki.net>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Miklos Szeredi <miklos@szeredi.hu>, Michel Lespinasse <walken@google.com>, "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>

On Fri, Apr 1, 2011 at 9:21 AM, Robert =C5=9Awi=C4=99cki <robert@swiecki.ne=
t> wrote:
>
> Is it possible to turn it off via config flags? Looking into
> arch/x86/include/asm/bug.h it seems it's unconditional (as in "it
> always manifests itself somehow") and I have
> CONFIG_DEBUG_BUGVERBOSE=3Dy.

Ok, if you have CONFIG_DEBUG_BUGVERBOSE then, you do have the bug-table.

Maybe it's just kdb that is broken, and doesn't print it. I wouldn't
be surprised. It's not the first time I've seen debugging features
that just make debugging a mess.

> Anything that could help you debugging this? Uploading kernel image
> (unfortunately I've overwritten this one), dumping more kgdb data?

So in this case kgdb just dropped the most important data on the floor.

But if you have kdb active next time, print out the vma/old contents
in that function that has the BUG() in it.

> I must admit I'm not up-to-date with current linux kernel debugging
> techniques. The kernel config is here:
> http://alt.swiecki.net/linux_kernel/ise-test-2.6.38-kernel-config.txt
>
> For now I'll compile with -O0 -fno-inline (are you sure you'd like -Os?)

Oh, don't do that. -O0 makes the code totally unreadable (the compiler
just does _stupid_ things, making the asm code look so horrible that
you can't match it up against anything sane), and -fno-inline isn't
worth the pain either.

-Os is much better than those.

But in this case, just getting the filename and line number would have
made the thing moot anyway - without kdb it _should_ have said
something clear like

   kernel BUG at %s:%u!

where %s:%u is the filename and line number.

                          Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
