Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id C48FD6B025F
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 15:03:38 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id o124so19797318qke.9
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 12:03:38 -0700 (PDT)
Received: from mail-yw0-x234.google.com (mail-yw0-x234.google.com. [2607:f8b0:4002:c05::234])
        by mx.google.com with ESMTPS id i9si551787ybj.431.2017.08.08.12.03.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 12:03:37 -0700 (PDT)
Received: by mail-yw0-x234.google.com with SMTP id l82so27103261ywc.2
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 12:03:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1708080957470.25441@nuc-kabylake>
References: <20170804231002.20362-1-labbott@redhat.com> <alpine.DEB.2.20.1708070936400.17268@nuc-kabylake>
 <559096f0-bf1b-eff1-f0ce-33f53a4df255@redhat.com> <alpine.DEB.2.20.1708071302310.18681@nuc-kabylake>
 <e0fc8a0a-fa52-e644-1fc2-4e96082858e0@redhat.com> <CAGXu5jKsb+7NyKLemdkS4ENtxuQzbaDY2h2DnMEr+=qBqJAJqw@mail.gmail.com>
 <alpine.DEB.2.20.1708080957470.25441@nuc-kabylake>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 8 Aug 2017 12:03:35 -0700
Message-ID: <CAGXu5jJSWtYfRu368cPpyMExbippb8=XchR48Dxt8uM_tNSd6A@mail.gmail.com>
Subject: Re: [RFC][PATCH] mm/slub.c: Allow poisoning to use the fast path
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Laura Abbott <labbott@redhat.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>

On Tue, Aug 8, 2017 at 8:01 AM, Christopher Lameter <cl@linux.com> wrote:
>
> On Mon, 7 Aug 2017, Kees Cook wrote:
>>
>> To clarify, this is desirable to kill exploitation of
>> exposure-after-free flaws and some classes of use-after-free flaws,
>> since the contents will have be wiped out after a free. (Verification
>> of poison is nice, but is expensive compared to the benefit against
>> these exploits -- and notably doesn't protect against the other
>> use-after-free attacks where the contents are changed after the next
>> allocation, which would have passed the poison verification.)
>
> Well the only variable in the freed area that is in use by the allocator
> is the free pointer. This ensures that complete object is poisoned and the
> free pointer has a separate storage area right? So the size of the slab
> objects increase. In addition to more hotpath processing we also have
> increased object sizes.

I'll let Laura speak to that; this is mainly an implementation detail.
I think it would be fine to leave the free pointer written in-object
after poisoning.

> I am not familiar with the terminology here.

Sorry, my fault for not being more clear! More below...

> So exposure-after-free means that the contents of the object can be used
> after it was freed?

There's a few things mixed together, but mainly this is about removing
the idea of "uninitialized" memory contents. One example is just
simply a memory region getting reused immediately, but failing to
properly initialize it, so the old contents are still there, and they
get exposed in some way (for a recent example, see [1]), leaking
sensitive kernel contents that an attacker can use to extend another
attack (e.g. leaking the precise location of some other target in
kernel memory). A simple example could look like this:

userspace makes syscall
... some function call path ...
kfree($location);

userspace makes syscall
... other function ...
ptr = kmalloc(...); // ptr is $location now
... buggy logic that never writes to ptr contents ...
copy_to_user(user, ptr, ...); // contents of $location copied to userspace

> Contents are changed after allocation? Someone gets a pointer to the
> object and the mods it later?

The classic use-after-free attack isn't normally affected by cache
poisoning, since the attack pattern is:

userspace makes syscall
tracked_struct = kmalloc(...);
...
kfree(tracked_struct); // some bug causes an early free

userspace makes syscall
...
other_struct = kmalloc(...); // tracked_struct same as other_struct now
other_struct->fields = evil_from_userspace; // overwrite by attacker

userspace makes syscall
...
tracked_struct->function_pointer(...); // calls attacker-controlled function

In other words, between the kfree() and the use, it gets reallocated
and written to, but the old reference remains and operates on the
newly written contents (in this worst-case example, it's a function
pointer overwrite). What I meant by "some classes of use-after-free
flaws" was that in rare cases, the "written to" step isn't needed,
since the existing contents can be used as-is (i.e. like the
"exposure-after-free" example I showed first), but it differs in what
primitives it provides to an attacker since it's not "just" an
exposure, but results in an attacker having control over kernel
behavior due to unexpected contents in memory.

Similar things happen to stack variables (there are lots of stack
info-leak examples, and see my presentation[2] for a direct execution
control example due to "uninitialized" variables), but that is being
worked on separately (forced stack variable init, and forced stack
clearing). The fast-path poisoning-on-free effort here is to protect
the slab cache from these classes of flaws and attacks.

-Kees

[1] http://seclists.org/oss-sec/2017/q2/455
[2] https://outflux.net/slides/2011/defcon/kernel-exploitation.pdf

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
