Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 987986B0003
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 03:54:28 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id y11so375678wmd.5
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 00:54:28 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 17si9379388wry.292.2018.02.14.00.54.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Feb 2018 00:54:27 -0800 (PST)
Date: Wed, 14 Feb 2018 09:54:25 +0100
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 00/31 v2] PTI support for x86_32
Message-ID: <20180214085425.GA12779@kroah.com>
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
 <CALCETrUF61fqjXKG=kwf83JWpw=kgL16UvKowezDVwVA1=YVAw@mail.gmail.com>
 <20180209191112.55zyjf4njum75brd@suse.de>
 <20180210091543.ynypx4y3koz44g7y@angband.pl>
 <CA+55aFwdLZjDcfhj4Ps=dUfd7ifkoYxW0FoH_JKjhXJYzxUSZQ@mail.gmail.com>
 <20180211105909.53bv5q363u7jgrsc@angband.pl>
 <6FB16384-7597-474E-91A1-1AF09201CEAC@gmail.com>
 <20180213085429.GB10278@kroah.com>
 <CA+55aFzLR2DbGnAKQwg79Ob9dpkOM1Z7bxkjyPBSp3Zdxmk5eQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzLR2DbGnAKQwg79Ob9dpkOM1Z7bxkjyPBSp3Zdxmk5eQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lorenzo Colitti <lorenzo@google.com>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mark D Rustad <mrustad@gmail.com>, Adam Borowski <kilobyte@angband.pl>, Joerg Roedel <jroedel@suse.de>, Andy Lutomirski <luto@kernel.org>, Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>

On Tue, Feb 13, 2018 at 09:25:34AM -0800, Linus Torvalds wrote:
> On Tue, Feb 13, 2018 at 12:54 AM, Greg KH <gregkh@linuxfoundation.org> wrote:
> > On Sun, Feb 11, 2018 at 09:40:41AM -0800, Mark D Rustad wrote:
> >>
> >> ISTR that iscsi doesn't work when running a 64-bit kernel with a
> >> 32-bit userspace. I remember someone offered kernel patches to fix it,
> >> but I think they were rejected. I haven't messed with that stuff in
> >> many years, so perhaps the userspace side now has accommodation for
> >> it. It might be something to check on.
> >
> > IPSEC doesn't work with a 64bit kernel and 32bit userspace right now.
> >
> > Back in 2015 someone started to work on that, and properly marked that
> > the kernel could not handle this with commit 74005991b78a ("xfrm: Do not
> > parse 32bits compiled xfrm netlink msg on 64bits host")
> >
> > This is starting to be hit by some Android systems that are moving
> > (yeah, slowly) to 4.4 :(
> 
> Does anybody have test-programs/harnesses for this?

Lorenzo (now on the To: line), is the one that I think is looking into
this, and should have some sort of test for it.  Lorenzo?

> This is an area I care deeply about: I really want people to not have
> any excuses for not upgrading to a 64-bit kernel.  It used to be
> autofs (I actually added that whole "packetized pipe" model just to
> make automount "just w ork" even though the stupid protocol used a
> pipe to send command packets that had different layout on 32-bit and
> 64-bit).
> 
> See commit 64f371bc3107 ("autofs: make the autofsv5 packet file
> descriptor use a packetized pipe") for some discussion of that
> particular saga.
> 
> Some drm people used to run 32-bit kernels because of compat worries,
> and that would have been a disaster. They got very good about not
> having compat issues.
> 
> So let's try to fix the iscsi and ipsec issues. Not that anybody sane
> should use that overly complex ipsec thing, and I think we should
> strive to merge WireGuard and get people moved over to that instead,
> but I haven't heard anything from davem about it since I last asked..
> I have some hope that it's slowly happening.

WireGuard is still being worked on, it needs some crypto library changes
that should be coming soon, but will probably be 6 months out at the
earliest to get merged.  There are still lots of people using IPSEC :(

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
