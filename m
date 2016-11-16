Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0C5416B0306
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 19:08:16 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id u144so11393668wmu.1
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 16:08:16 -0800 (PST)
Received: from mail-wm0-x22a.google.com (mail-wm0-x22a.google.com. [2a00:1450:400c:c09::22a])
        by mx.google.com with ESMTPS id f19si4633315wjq.287.2016.11.15.16.08.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 16:08:14 -0800 (PST)
Received: by mail-wm0-x22a.google.com with SMTP id t79so35407032wmt.0
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 16:08:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <87twb8xpyb.fsf@concordia.ellerman.id.au>
References: <1479207422-6535-1-git-send-email-mpe@ellerman.id.au>
 <CAGXu5j+3pD7Ss_PBY9H_A6B5-Ers2wYqFJ1y4iryKzqc=jCxXg@mail.gmail.com> <87twb8xpyb.fsf@concordia.ellerman.id.au>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 15 Nov 2016 16:08:13 -0800
Message-ID: <CAGXu5jKPWBsj=tYxv7BsPw3oWvtwkqaz5SefQXT4QoOjzMUo-Q@mail.gmail.com>
Subject: Re: [kernel-hardening] Re: [PATCH] slab: Add POISON_POINTER_DELTA to ZERO_SIZE_PTR
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Tue, Nov 15, 2016 at 3:50 PM, Michael Ellerman <mpe@ellerman.id.au> wrote:
> Kees Cook <keescook@chromium.org> writes:
>
>> On Tue, Nov 15, 2016 at 2:57 AM, Michael Ellerman <mpe@ellerman.id.au> wrote:
>>> POISON_POINTER_DELTA is defined in poison.h, and is intended to be used
>>> to shift poison values so that they don't alias userspace.
>>>
>>> We should add it to ZERO_SIZE_PTR so that attackers can't use
>>> ZERO_SIZE_PTR as a way to get a pointer to userspace.
>>
>> Ah, when dealing with a 0-sized malloc or similar?
>
> Yeah as returned by a 0-sized kmalloc for example.
>
>> Do you have pointers to exploits that rely on this?
>
> Not real ones, it was used in the StringIPC challenge:
>
> https://poppopret.org/2015/11/16/csaw-ctf-2015-kernel-exploitation-challenge/
>
> Though that included the ability to seek to an arbitrary offset from the
> zero size pointer, so this wouldn't have helped.
>
>> Regardless, normally PAN/SMAP-like things should be sufficient to
>> protect against this.
>
> True. Not everyone has PAN/SMAP though :)

Right, mostly just thinking out loud about the threat model and the
existing results.

>> Additionally, on everything but x86_64 and arm64, POISON_POINTER_DELTA
>> == 0, if I'm reading correctly:
>
> You are reading correctly. All 64-bit arches should be able to define it
> to something though.
>
>> Is the plan to add ILLEGAL_POINTER_VALUE for powerpc too?
>
> Yep. I should have CC'ed you on the patch :)

I suspected I was missing something. ;)

>> And either way, this patch, IIUC, will break the ZERO_OR_NULL_PTR()
>> check, since suddenly all of userspace will match it. (Though maybe
>> that's okay?)
>
> Yeah I wasn't sure what to do with that.

Yeah, though there are shockingly few callers of that macro. I think
building with HARDENED_USERCOPY would totally break the kernel,
though, since check_bogus_address() is looking at ZERO_OR_NULL even
for things destined for userspace.

> I don't think it breaks it, but it does become a bit fishy because as
> you say all of userspace (and more) will now match.
>
> It should probably just become two separate tests, though that
> potentially has issues with double evaluation of the argument. AFAICS
> none of the callers pass an expression though.

That shouldn't be a problem. I think we can use fancy magic like:

#define ZERO_OR_NULL_PTR(x) \
 ({ \
    unsigned long p = (unsigned long)(x); \
    (p == NULL || p == ZERO_SIZE_PTR); \
   })

Though this technically loses the check for values 1 through 15...

-Kees

-- 
Kees Cook
Nexus Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
