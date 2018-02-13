Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 467B66B0003
	for <linux-mm@kvack.org>; Tue, 13 Feb 2018 12:25:37 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id w125so9797423itf.0
        for <linux-mm@kvack.org>; Tue, 13 Feb 2018 09:25:37 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r188sor628839ith.79.2018.02.13.09.25.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Feb 2018 09:25:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180213085429.GB10278@kroah.com>
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
 <CALCETrUF61fqjXKG=kwf83JWpw=kgL16UvKowezDVwVA1=YVAw@mail.gmail.com>
 <20180209191112.55zyjf4njum75brd@suse.de> <20180210091543.ynypx4y3koz44g7y@angband.pl>
 <CA+55aFwdLZjDcfhj4Ps=dUfd7ifkoYxW0FoH_JKjhXJYzxUSZQ@mail.gmail.com>
 <20180211105909.53bv5q363u7jgrsc@angband.pl> <6FB16384-7597-474E-91A1-1AF09201CEAC@gmail.com>
 <20180213085429.GB10278@kroah.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 13 Feb 2018 09:25:34 -0800
Message-ID: <CA+55aFzLR2DbGnAKQwg79Ob9dpkOM1Z7bxkjyPBSp3Zdxmk5eQ@mail.gmail.com>
Subject: Re: [PATCH 00/31 v2] PTI support for x86_32
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: Mark D Rustad <mrustad@gmail.com>, Adam Borowski <kilobyte@angband.pl>, Joerg Roedel <jroedel@suse.de>, Andy Lutomirski <luto@kernel.org>, Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>

On Tue, Feb 13, 2018 at 12:54 AM, Greg KH <gregkh@linuxfoundation.org> wrote:
> On Sun, Feb 11, 2018 at 09:40:41AM -0800, Mark D Rustad wrote:
>>
>> ISTR that iscsi doesn't work when running a 64-bit kernel with a
>> 32-bit userspace. I remember someone offered kernel patches to fix it,
>> but I think they were rejected. I haven't messed with that stuff in
>> many years, so perhaps the userspace side now has accommodation for
>> it. It might be something to check on.
>
> IPSEC doesn't work with a 64bit kernel and 32bit userspace right now.
>
> Back in 2015 someone started to work on that, and properly marked that
> the kernel could not handle this with commit 74005991b78a ("xfrm: Do not
> parse 32bits compiled xfrm netlink msg on 64bits host")
>
> This is starting to be hit by some Android systems that are moving
> (yeah, slowly) to 4.4 :(

Does anybody have test-programs/harnesses for this?

This is an area I care deeply about: I really want people to not have
any excuses for not upgrading to a 64-bit kernel.  It used to be
autofs (I actually added that whole "packetized pipe" model just to
make automount "just w ork" even though the stupid protocol used a
pipe to send command packets that had different layout on 32-bit and
64-bit).

See commit 64f371bc3107 ("autofs: make the autofsv5 packet file
descriptor use a packetized pipe") for some discussion of that
particular saga.

Some drm people used to run 32-bit kernels because of compat worries,
and that would have been a disaster. They got very good about not
having compat issues.

So let's try to fix the iscsi and ipsec issues. Not that anybody sane
should use that overly complex ipsec thing, and I think we should
strive to merge WireGuard and get people moved over to that instead,
but I haven't heard anything from davem about it since I last asked..
I have some hope that it's slowly happening.

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
