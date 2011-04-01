Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 192128D0040
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 12:21:29 -0400 (EDT)
Received: by eyd9 with SMTP id 9so1446323eyd.14
        for <linux-mm@kvack.org>; Fri, 01 Apr 2011 09:21:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTimfArmB7judMW7Qd4ATtVaR=yTf_-0DBRAfCJ7w@mail.gmail.com>
References: <alpine.LSU.2.00.1102232136020.2239@sister.anvils>
	<AANLkTi==MQV=_qq1HaCxGLRu8DdT6FYddqzBkzp1TQs7@mail.gmail.com>
	<AANLkTimv66fV1+JDqSAxRwddvy_kggCuhoJLMTpMTtJM@mail.gmail.com>
	<alpine.LSU.2.00.1103182158200.18771@sister.anvils>
	<BANLkTinoNMudwkcOOgU5d+imPUfZhDbWWQ@mail.gmail.com>
	<AANLkTimfArmB7judMW7Qd4ATtVaR=yTf_-0DBRAfCJ7w@mail.gmail.com>
Date: Fri, 1 Apr 2011 18:21:23 +0200
Message-ID: <BANLkTim3x=1n+F7yD-euY0=RhmyXViUamg@mail.gmail.com>
Subject: Re: [PATCH] mm: fix possible cause of a page_mapped BUG
From: =?UTF-8?B?Um9iZXJ0IMWad2nEmWNraQ==?= <robert@swiecki.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Miklos Szeredi <miklos@szeredi.hu>, Michel Lespinasse <walken@google.com>, "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>

On Fri, Apr 1, 2011 at 5:44 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Fri, Apr 1, 2011 at 7:34 AM, Robert =C5=9Awi=C4=99cki <robert@swiecki.=
net> wrote:
>>
>> Hey, I'll apply your patch and check it out. In the meantime I
>> triggered another Oops (NULL-ptr deref via sys_mprotect).
>>
>> The oops is here:
>>
>> http://alt.swiecki.net/linux_kernel/sys_mprotect-2.6.38.txt
>
> That's not a NULL pointer dereference. That's a BUG_ON().
>
> And for some reason you've turned off the BUG_ON() messages, saving
> some tiny amount of memory.

Is it possible to turn it off via config flags? Looking into
arch/x86/include/asm/bug.h it seems it's unconditional (as in "it
always manifests itself somehow") and I have
CONFIG_DEBUG_BUGVERBOSE=3Dy.

This BUG/Oopps was triggered before I applied Hugh's patch on a vanilla ker=
nel.

Anything that could help you debugging this? Uploading kernel image
(unfortunately I've overwritten this one), dumping more kgdb data? I
must admit I'm not up-to-date with current linux kernel debugging
techniques. The kernel config is here:
http://alt.swiecki.net/linux_kernel/ise-test-2.6.38-kernel-config.txt

For now I'll compile with -O0 -fno-inline (are you sure you'd like -Os?)

> Anyway, it looks like the first BUG_ON() in vma_prio_tree_add(), so it
> would be this one:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0BUG_ON(RADIX_INDEX(vma) !=3D RADIX_INDEX(old))=
;
>
> but it is possible that gcc has shuffled things around (so it _might_
> be the HEAP_INDEX() one). If you had CONFIG_DEBUG_BUGVERBOSE=3Dy, you'd
> get a filename and line number. One reason I hate -O2 in cases like
> this is that the basic block movement makes it way harder to actually
> debug things. I would suggest using -Os too (CONFIG_OPTIMIZE_FOR_SIZE
> or whatever it's called).
>
> Anyway, I do find it worrying. The vma code shouldn't be this fragile. =
=C2=A0Hugh?
>
> I do wonder what triggers this. Is it a huge-page vma? We seem to be
> lacking the check to see that mprotect() is on a hugepage boundary -
> and that seems bogus. Or am I missing some check? The new transparent
> hugepage support splits the page, but what if it's a _static_ hugepage
> thing?
>
> But why would that affect the radix_index thing? I have no idea. I'd
> like to blame the anon_vma rewrites last year, but I can't see why
> that should matter either. Again, hugepages had some special rules, I
> think (and that would explain why nobody normal sees this).
>
> Guys, please give this one a look.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0Linus
>



--=20
Robert =C5=9Awi=C4=99cki

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
