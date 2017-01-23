Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6C4626B0033
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 15:11:03 -0500 (EST)
Received: by mail-ua0-f199.google.com with SMTP id j94so97332696uad.0
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 12:11:03 -0800 (PST)
Received: from mail-ua0-x229.google.com (mail-ua0-x229.google.com. [2607:f8b0:400c:c08::229])
        by mx.google.com with ESMTPS id k23si4506515uaa.75.2017.01.23.12.11.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jan 2017 12:11:02 -0800 (PST)
Received: by mail-ua0-x229.google.com with SMTP id 35so118606802uak.1
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 12:11:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <31033.1485168526@warthog.procyon.org.uk>
References: <CAGXu5j+nVMPk3TTxLr3_6Y=5vNM0=aD+13JM_Q5POts9M7kzuw@mail.gmail.com>
 <CALCETrVKDAzcS62wTjDOGuRUNec_a-=8iEa7QQ62V83Ce2nk=A@mail.gmail.com> <31033.1485168526@warthog.procyon.org.uk>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 23 Jan 2017 12:10:41 -0800
Message-ID: <CALCETrV5b4Z3MF51pQOPtp-BgMM4TYPLrXPHL+EfsWfm+CczkA@mail.gmail.com>
Subject: Re: [Ksummit-discuss] security-related TODO items?
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Howells <dhowells@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Kees Cook <keescook@chromium.org>, Josh Armour <jarmour@google.com>, Greg KH <gregkh@linuxfoundation.org>, "ksummit-discuss@lists.linuxfoundation.org" <ksummit-discuss@lists.linuxfoundation.org>

On Mon, Jan 23, 2017 at 2:48 AM, David Howells <dhowells@redhat.com> wrote:
> Andy Lutomirski <luto@amacapital.net> wrote:
>
>> This is not easy at all, but: how about rewriting execve() so that the
>> actual binary format parsers run in user mode?
>
> Sounds very chicken-and-egg-ish.  Issues you'd have:
>
>  (1) You'd need at least one pre-loader binary image built into the kernel
>      that you can map into userspace (you can't upcall to userspace to go get
>      it for your core binfmt).  This could appear as, say, /proc/preloader,
>      for the kernel to open and mmap.

No need for it to be visible at all.  I'm imagining the kernel making
a fresh mm_struct, directly mapping some text, running that text, and
then using the result as the mm_struct after execve.

>
>  (2) Where would the kernel put the executable image?  It would have to parse
>      the binary to find out where not to put it - otherwise the code might
>      have to relocate itself.

In vmlinux.

>
>  (3) How do you deal with address randomisation?

Non-issue, I think.

>
>  (4) You may have to start without a stack as the kernel wouldn't necessarily
>      know where to put it or how big it should be (see 6).  Or you might have
>      to relocate it, including all the pointers it contains.

The relocation part is indeed a bit nasty.

>
>  (5) Where should the kernel put arguments, environment and other parameters?
>      Currently, this presumes a stack, but see (4).

Hmm.

>
>  (6) NOMMU could be particularly tricky.  For ELF-FDPIC at least, the stack
>      size is set in the binary.  OTOH, you wouldn't have to relocate the
>      pre-loader - you'd just mmap it MAP_PRIVATE and execute in place.

For nommu, forget about it.

>
>  (7) When the kernel finds it's dealing with a script, it goes back through
>      the security calculation procedure again to deal with the interpreter.

The security calculation isn't what I'm worried about.  I'm worried
about the parser.

Anyway, I didn't say this would be easy :)

>
>> A minor one for x86: give binaries a way to opt out of the x86_64
>> vsyscall page.  I already did the hard part (in a branch), so all
>> that's really left is figuring out the ABI.
>
> munmap() it in the loader?

Hmm, *that's* an interesting thought.  You can't remove the VMA (it's
not a VMA) but maybe munmap() could be made to work anyway.  Hey mm
folks, just how weird would it be to let arch code special-case
unmapping of the gate pseudo-vma?

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
