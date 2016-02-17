Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id 3A0D06B0253
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 17:18:06 -0500 (EST)
Received: by mail-ob0-f174.google.com with SMTP id xk3so37710623obc.2
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 14:18:06 -0800 (PST)
Received: from mail-ob0-x230.google.com (mail-ob0-x230.google.com. [2607:f8b0:4003:c01::230])
        by mx.google.com with ESMTPS id u2si4205090oev.32.2016.02.17.14.18.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Feb 2016 14:18:05 -0800 (PST)
Received: by mail-ob0-x230.google.com with SMTP id jq7so37444882obb.0
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 14:18:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAGXu5j+L6W17wkKNdheUQQ01bJE4ZXLDiG=5JBaNWju2j9NB2Q@mail.gmail.com>
References: <20160212210152.9CAD15B0@viggo.jf.intel.com> <20160212210240.CB4BB5CA@viggo.jf.intel.com>
 <CAGXu5j+L6W17wkKNdheUQQ01bJE4ZXLDiG=5JBaNWju2j9NB2Q@mail.gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 17 Feb 2016 14:17:45 -0800
Message-ID: <CALCETrVUifty6QuXo67zt9DuxsgUPTqzFbaKGS0qXd75jAb35Q@mail.gmail.com>
Subject: Re: [PATCH 33/33] x86, pkeys: execute-only support
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@google.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, X86 ML <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave@sr71.net>

On Feb 17, 2016 1:27 PM, "Kees Cook" <keescook@google.com> wrote:
>
> On Fri, Feb 12, 2016 at 1:02 PM, Dave Hansen <dave@sr71.net> wrote:
> >
> > From: Dave Hansen <dave.hansen@linux.intel.com>
> >
> > Protection keys provide new page-based protection in hardware.
> > But, they have an interesting attribute: they only affect data
> > accesses and never affect instruction fetches.  That means that
> > if we set up some memory which is set as "access-disabled" via
> > protection keys, we can still execute from it.
> >
> > This patch uses protection keys to set up mappings to do just that.
> > If a user calls:
> >
> >         mmap(..., PROT_EXEC);
> > or
> >         mprotect(ptr, sz, PROT_EXEC);
> >
> > (note PROT_EXEC-only without PROT_READ/WRITE), the kernel will
> > notice this, and set a special protection key on the memory.  It
> > also sets the appropriate bits in the Protection Keys User Rights
> > (PKRU) register so that the memory becomes unreadable and
> > unwritable.
> >
> > I haven't found any userspace that does this today.  With this
> > facility in place, we expect userspace to move to use it
> > eventually.  Userspace _could_ start doing this today.  Any
> > PROT_EXEC calls get converted to PROT_READ inside the kernel, and
> > would transparently be upgraded to "true" PROT_EXEC with this
> > code.  IOW, userspace never has to do any PROT_EXEC runtime
> > detection.
>
> Random thought while skimming email:
>
> Is there a way to detect this feature's availability without userspace
> having to set up a segv handler and attempting to read a
> PROT_EXEC-only region? (i.e. cpu flag for protection keys, or a way to
> check the protection to see if PROT_READ got added automatically,
> etc?)
>

We could add an HWCAP.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
