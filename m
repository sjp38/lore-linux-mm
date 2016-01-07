Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id B43B9828DE
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 17:13:15 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id cy9so269915040pac.0
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 14:13:15 -0800 (PST)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id sf3si11568247pac.58.2016.01.07.14.13.14
        for <linux-mm@kvack.org>;
        Thu, 07 Jan 2016 14:13:14 -0800 (PST)
Subject: Re: [PATCH 31/31] x86, pkeys: execute-only support
References: <20160107000104.1A105322@viggo.jf.intel.com>
 <20160107000148.ED5D13DF@viggo.jf.intel.com>
 <CALCETrUUS=jHCwmeQ5iUeTAq15PAGZO8Js57ZBLKPM6oEDz3Qg@mail.gmail.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <568EE2F7.5000902@sr71.net>
Date: Thu, 7 Jan 2016 14:13:11 -0800
MIME-Version: 1.0
In-Reply-To: <CALCETrUUS=jHCwmeQ5iUeTAq15PAGZO8Js57ZBLKPM6oEDz3Qg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@google.com>

On 01/07/2016 01:10 PM, Andy Lutomirski wrote:
> On Wed, Jan 6, 2016 at 4:01 PM, Dave Hansen <dave@sr71.net> wrote:
>> From: Dave Hansen <dave.hansen@linux.intel.com>
>> Protection keys provide new page-based protection in hardware.
>> But, they have an interesting attribute: they only affect data
>> accesses and never affect instruction fetches.  That means that
>> if we set up some memory which is set as "access-disabled" via
>> protection keys, we can still execute from it.
>> could lose the bits in PKRU that enforce execute-only
>> permissions.  To avoid this, we suggest avoiding ever calling
>> mmap() or mprotect() when the PKRU value is expected to be
>> stable.
> 
> This may be a bit unfortunate for people who call mmap from signal
> handlers.  Admittedly, the failure mode isn't that bad.

mmap() isn't in the list of async-signal-safe functions, so it's bad
already.

> Out of curiosity, do you have timing information for WRPKRU and
> RDPKRU?  If they're fast and if anyone ever implements my deferred
> xstate restore idea, then the performance issue goes away and we can
> stop caring about whether PKRU is in the init state.

I don't have timing information that I can share.  From my perspective,
they're pretty fast, *not* like an MSR write or something.  I think
they're fast enough to use in the context switch path.  I'd say PKRU is
in XSAVE for consistency more than for performance.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
