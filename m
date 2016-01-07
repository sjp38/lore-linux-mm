Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id EBDAF828DE
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 17:44:34 -0500 (EST)
Received: by mail-ob0-f181.google.com with SMTP id bx1so312669469obb.0
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 14:44:34 -0800 (PST)
Received: from mail-ob0-x22d.google.com (mail-ob0-x22d.google.com. [2607:f8b0:4003:c01::22d])
        by mx.google.com with ESMTPS id j6si17214145oem.25.2016.01.07.14.44.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jan 2016 14:44:34 -0800 (PST)
Received: by mail-ob0-x22d.google.com with SMTP id bx1so312669285obb.0
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 14:44:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <568EE2F7.5000902@sr71.net>
References: <20160107000104.1A105322@viggo.jf.intel.com> <20160107000148.ED5D13DF@viggo.jf.intel.com>
 <CALCETrUUS=jHCwmeQ5iUeTAq15PAGZO8Js57ZBLKPM6oEDz3Qg@mail.gmail.com> <568EE2F7.5000902@sr71.net>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 7 Jan 2016 14:44:14 -0800
Message-ID: <CALCETrUYA6osHAH-o55WYquCKf+41pF8UaY+LJjajw9v0TCONA@mail.gmail.com>
Subject: Re: [PATCH 31/31] x86, pkeys: execute-only support
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@google.com>

On Thu, Jan 7, 2016 at 2:13 PM, Dave Hansen <dave@sr71.net> wrote:
> On 01/07/2016 01:10 PM, Andy Lutomirski wrote:
>> On Wed, Jan 6, 2016 at 4:01 PM, Dave Hansen <dave@sr71.net> wrote:
>>> From: Dave Hansen <dave.hansen@linux.intel.com>
>>> Protection keys provide new page-based protection in hardware.
>>> But, they have an interesting attribute: they only affect data
>>> accesses and never affect instruction fetches.  That means that
>>> if we set up some memory which is set as "access-disabled" via
>>> protection keys, we can still execute from it.
>>> could lose the bits in PKRU that enforce execute-only
>>> permissions.  To avoid this, we suggest avoiding ever calling
>>> mmap() or mprotect() when the PKRU value is expected to be
>>> stable.
>>
>> This may be a bit unfortunate for people who call mmap from signal
>> handlers.  Admittedly, the failure mode isn't that bad.
>
> mmap() isn't in the list of async-signal-safe functions, so it's bad
> already.

mmap the POSIX function may not be, but mmap the syscall is just a
syscall.  Also, I'm moderately confident that there are synchronous
signals, too.  If not, there should be (e.g. raise with an unblocked
signal).

>
>> Out of curiosity, do you have timing information for WRPKRU and
>> RDPKRU?  If they're fast and if anyone ever implements my deferred
>> xstate restore idea, then the performance issue goes away and we can
>> stop caring about whether PKRU is in the init state.
>
> I don't have timing information that I can share.  From my perspective,
> they're pretty fast, *not* like an MSR write or something.  I think
> they're fast enough to use in the context switch path.  I'd say PKRU is
> in XSAVE for consistency more than for performance.
>

I'll play with this at some point.  Probably not until I get the right hardware.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
