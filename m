Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id A7D756B0303
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 18:50:58 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id q10so122627347pgq.7
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 15:50:58 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id w12si28740684pfi.107.2016.11.15.15.50.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 15:50:57 -0800 (PST)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [kernel-hardening] Re: [PATCH] slab: Add POISON_POINTER_DELTA to ZERO_SIZE_PTR
In-Reply-To: <CAGXu5j+3pD7Ss_PBY9H_A6B5-Ers2wYqFJ1y4iryKzqc=jCxXg@mail.gmail.com>
References: <1479207422-6535-1-git-send-email-mpe@ellerman.id.au> <CAGXu5j+3pD7Ss_PBY9H_A6B5-Ers2wYqFJ1y4iryKzqc=jCxXg@mail.gmail.com>
Date: Wed, 16 Nov 2016 10:50:52 +1100
Message-ID: <87twb8xpyb.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

Kees Cook <keescook@chromium.org> writes:

> On Tue, Nov 15, 2016 at 2:57 AM, Michael Ellerman <mpe@ellerman.id.au> wrote:
>> POISON_POINTER_DELTA is defined in poison.h, and is intended to be used
>> to shift poison values so that they don't alias userspace.
>>
>> We should add it to ZERO_SIZE_PTR so that attackers can't use
>> ZERO_SIZE_PTR as a way to get a pointer to userspace.
>
> Ah, when dealing with a 0-sized malloc or similar?

Yeah as returned by a 0-sized kmalloc for example.

> Do you have pointers to exploits that rely on this?

Not real ones, it was used in the StringIPC challenge:

https://poppopret.org/2015/11/16/csaw-ctf-2015-kernel-exploitation-challenge/

Though that included the ability to seek to an arbitrary offset from the
zero size pointer, so this wouldn't have helped.

> Regardless, normally PAN/SMAP-like things should be sufficient to
> protect against this.

True. Not everyone has PAN/SMAP though :)

> Additionally, on everything but x86_64 and arm64, POISON_POINTER_DELTA
> == 0, if I'm reading correctly:

You are reading correctly. All 64-bit arches should be able to define it
to something though.

> Is the plan to add ILLEGAL_POINTER_VALUE for powerpc too?

Yep. I should have CC'ed you on the patch :)

> And either way, this patch, IIUC, will break the ZERO_OR_NULL_PTR()
> check, since suddenly all of userspace will match it. (Though maybe
> that's okay?)

Yeah I wasn't sure what to do with that.

I don't think it breaks it, but it does become a bit fishy because as
you say all of userspace (and more) will now match.

It should probably just become two separate tests, though that
potentially has issues with double evaluation of the argument. AFAICS
none of the callers pass an expression though.

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
