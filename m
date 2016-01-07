Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id 318AA828DE
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 16:11:05 -0500 (EST)
Received: by mail-ob0-f179.google.com with SMTP id xn1so63617368obc.2
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 13:11:05 -0800 (PST)
Received: from mail-oi0-x235.google.com (mail-oi0-x235.google.com. [2607:f8b0:4003:c06::235])
        by mx.google.com with ESMTPS id c15si772093oig.28.2016.01.07.13.11.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jan 2016 13:11:04 -0800 (PST)
Received: by mail-oi0-x235.google.com with SMTP id l9so294282831oia.2
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 13:11:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160107000148.ED5D13DF@viggo.jf.intel.com>
References: <20160107000104.1A105322@viggo.jf.intel.com> <20160107000148.ED5D13DF@viggo.jf.intel.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 7 Jan 2016 13:10:44 -0800
Message-ID: <CALCETrUUS=jHCwmeQ5iUeTAq15PAGZO8Js57ZBLKPM6oEDz3Qg@mail.gmail.com>
Subject: Re: [PATCH 31/31] x86, pkeys: execute-only support
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@google.com>

On Wed, Jan 6, 2016 at 4:01 PM, Dave Hansen <dave@sr71.net> wrote:
>
> From: Dave Hansen <dave.hansen@linux.intel.com>
>

> Protection keys provide new page-based protection in hardware.
> But, they have an interesting attribute: they only affect data
> accesses and never affect instruction fetches.  That means that
> if we set up some memory which is set as "access-disabled" via
> protection keys, we can still execute from it.
> could lose the bits in PKRU that enforce execute-only
> permissions.  To avoid this, we suggest avoiding ever calling
> mmap() or mprotect() when the PKRU value is expected to be
> stable.

s/stable/unstable/

This may be a bit unfortunate for people who call mmap from signal
handlers.  Admittedly, the failure mode isn't that bad.

Out of curiosity, do you have timing information for WRPKRU and
RDPKRU?  If they're fast and if anyone ever implements my deferred
xstate restore idea, then the performance issue goes away and we can
stop caring about whether PKRU is in the init state.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
