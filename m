Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 351DE6B02B0
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 06:10:08 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id j13so804140wmh.3
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 03:10:08 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u8si82882wme.216.2018.02.22.03.10.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Feb 2018 03:10:06 -0800 (PST)
Date: Thu, 22 Feb 2018 12:10:03 +0100
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 00/31 v2] PTI support for x86_32
Message-ID: <20180222111003.GB22572@kroah.com>
References: <20180209191112.55zyjf4njum75brd@suse.de>
 <20180210091543.ynypx4y3koz44g7y@angband.pl>
 <CA+55aFwdLZjDcfhj4Ps=dUfd7ifkoYxW0FoH_JKjhXJYzxUSZQ@mail.gmail.com>
 <20180211105909.53bv5q363u7jgrsc@angband.pl>
 <6FB16384-7597-474E-91A1-1AF09201CEAC@gmail.com>
 <20180213085429.GB10278@kroah.com>
 <CA+55aFzLR2DbGnAKQwg79Ob9dpkOM1Z7bxkjyPBSp3Zdxmk5eQ@mail.gmail.com>
 <20180214085425.GA12779@kroah.com>
 <CAKD1Yr2mgYZ7uFCQsQ9M5YMGX1LuhO0CQR6tLvQM=dND4RBrbQ@mail.gmail.com>
 <CAK8P3a2iFfrH5B8sha7GMEPN-pv995X_1b6-Bo4h=wBLGhhUPg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAK8P3a2iFfrH5B8sha7GMEPN-pv995X_1b6-Bo4h=wBLGhhUPg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Lorenzo Colitti <lorenzo@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Mark D Rustad <mrustad@gmail.com>, Adam Borowski <kilobyte@angband.pl>, Joerg Roedel <jroedel@suse.de>, Andy Lutomirski <luto@kernel.org>, Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, Florian Westphal <fw@strlen.de>

On Wed, Feb 21, 2018 at 05:59:34PM +0100, Arnd Bergmann wrote:
> On Wed, Feb 21, 2018 at 11:26 AM, Lorenzo Colitti <lorenzo@google.com> wrote:
> > On Wed, Feb 14, 2018 at 5:54 PM, Greg KH <gregkh@linuxfoundation.org> wrote:
> >> > > IPSEC doesn't work with a 64bit kernel and 32bit userspace right now.
> >> > >
> >> > > Back in 2015 someone started to work on that, and properly marked that
> >> > > the kernel could not handle this with commit 74005991b78a ("xfrm: Do not
> >> > > parse 32bits compiled xfrm netlink msg on 64bits host")
> >> > >
> >> > > This is starting to be hit by some Android systems that are moving
> >> > > (yeah, slowly) to 4.4 :(
> >> >
> >> > Does anybody have test-programs/harnesses for this?
> >>
> >> Lorenzo (now on the To: line), is the one that I think is looking into
> >> this, and should have some sort of test for it.  Lorenzo?
> >
> > Sorry for the late reply here. The issue is that the xfrm uapi structs
> > don't specify padding at the end, so they're a different size on
> > 32-bit and 64-bit archs. This by itself would be fine, as the kernel
> > could just ignore the (lack of) padding. But some of these structs
> > contain others (e.g., xfrm_userspi_info contains xfrm_usersa_info),
> > and in that case the whole layout after the contained struct is
> > different.
> 
> So this is x86 specific then and it already works correctly on all
> other architectures (especially arm64 Android), right?

Why is this an x86-specific issue?  I think people have noticed this
with ARM systems given that the original bug report I saw was for an
ARM Android-based system that had a 64bit kernel and 32bit userspace.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
