Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 697546B034B
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 12:21:53 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id n130so2395447itg.1
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 09:21:53 -0800 (PST)
Received: from mail.zytor.com (terminus.zytor.com. [65.50.211.136])
        by mx.google.com with ESMTPS id e7si1779243ita.132.2018.02.07.09.21.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Feb 2018 09:21:52 -0800 (PST)
Date: Wed, 07 Feb 2018 09:13:57 -0800
In-Reply-To: <CA+55aFxJO7kDNp6wRnU58Z6-sPbK1SqdzpgLBTAe54mdPjnd=g@mail.gmail.com>
References: <20180207145913.2703-1-kirill.shutemov@linux.intel.com> <CA+55aFxJO7kDNp6wRnU58Z6-sPbK1SqdzpgLBTAe54mdPjnd=g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: [RFC 0/3] x86: Patchable constants
From: hpa@zytor.com
Message-ID: <5D7DF367-BFEF-49C5-93DF-5C19D887752A@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: the arch/x86 maintainers <x86@kernel.org>, Tom Lendacky <thomas.lendacky@amd.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On February 7, 2018 9:01:42 AM PST, Linus Torvalds <torvalds@linux-foundati=
on=2Eorg> wrote:
>On Wed, Feb 7, 2018 at 6:59 AM, Kirill A=2E Shutemov
><kirill=2Eshutemov@linux=2Eintel=2Ecom> wrote:
>> This patchset introduces concept of patchable constants: constant
>values
>> that can be adjusted at boot-time in response to system configuration
>or
>> user input (kernel command-line)=2E
>>
>> Patchable constants can replace variables that never changes at
>runtime
>> (only at boot-time), but used in very hot path=2E
>
>So I actually wanted something very close to this, but I think your
>approach is much too simplistic=2E
>
>You force all constants into a register, which means that the
>resulting code is always going to be very far from non-optimal=2E
>
>You also force a big "movabsq" instruction, which really is huge, and
>almost never needed=2E Together with the "use a register", it just makes
>for big code=2E
>
>What I wanted was something that can take things like a shift by a
>variable that is set once, and turn it into a shift by a boot-time
>constant=2E Which means that you literally end up patching the 8-bit
>immediate in the shift instruction itself=2E
>
>In particular, was looking at the dcache hashing code, and (to quote
>an old email of mine), what I wanted was to simplify the run-time
>constant part of this:
>
>=E2=94=82 mov $0x20,%ecx
>=E2=94=82 sub 0xaf8bd5(%rip),%ecx # ffffffff81d34600 <d_hash_shift>
>=E2=94=82 mov 0x8(%rsi),%r9
>=E2=94=82 add %r14d,%eax
>=E2=94=82 imul $0x9e370001,%eax,%eax
>=E2=94=82 shr %cl,%eax
>
>and it was the expression "32-d_hash_shift" that is really a constant,
>and that sequence of
>
>=E2=94=82 mov $0x20,%ecx
>=E2=94=82 sub 0xaf8bd5(%rip),%ecx # ffffffff81d34600 <d_hash_shift>
>=E2=94=82 shr %cl,%eax
>
>should be just a single
>
>=E2=94=82 shr $CONSTANT,%eax
>
>at runtime=2E
>
>Look - much smaller code, and register %rcx isn't used at all=2E And no
>D$ miss on loading that constant (that is a constant depending on
>boot-time setup only)=2E
>
>It's rather more complex, but it actually gives a much bigger win=2E The
>code itself will be much better, and smaller=2E
>
>The *infrastructure* for the code gets pretty hairy, though=2E
>
>The good news is that the patch already existed to at least _some_
>degree=2E Peter Anvin did it about 18 months ago=2E
>
>It was not really pursued all the way because it *is* a lot of extra
>complexity, and I think there was some other hold-up, but he did have
>skeleton code for the actual replacement=2E
>
>There was a thread on the x86 arch list with the subject line
>
>    Disgusting pseudo-self-modifying code idea: "variable constants"
>
>but I'm unable to actually find the patch=2E I know there was at least a
>vert early prototype=2E
>
>Adding hpa to the cc in the hope that he has some prototype code still
>laying around=2E=2E
>
>                Linus

I am currently working on it much more comprehensive set of patches for ex=
tremely this=2E I am already much further ahead and support most operations=
=2E
--=20
Sent from my Android device with K-9 Mail=2E Please excuse my brevity=2E

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
