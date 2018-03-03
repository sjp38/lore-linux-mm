Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id C0BAA6B0009
	for <linux-mm@kvack.org>; Sat,  3 Mar 2018 08:58:45 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id h82so3748776lfi.12
        for <linux-mm@kvack.org>; Sat, 03 Mar 2018 05:58:45 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 91sor2211359lfv.36.2018.03.03.05.58.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 03 Mar 2018 05:58:43 -0800 (PST)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [RFC PATCH] Randomization of address chosen by mmap.
From: Ilya Smith <blackzert@gmail.com>
In-Reply-To: <CA+DvKQKoo1U7T_iOOLhfEf9c+K1pzD068au+kGtx0RokFFNKHw@mail.gmail.com>
Date: Sat, 3 Mar 2018 16:58:40 +0300
Content-Transfer-Encoding: quoted-printable
Message-Id: <2CF957C6-53F2-4B00-920F-245BEF3CA1F6@gmail.com>
References: <20180227131338.3699-1-blackzert@gmail.com>
 <CAGXu5jKF7ysJqj57ZktrcVL4G2NWOFHCud8dtXFHLs=tvVLXnQ@mail.gmail.com>
 <55C92196-5398-4C19-B7A7-6C122CD78F32@gmail.com>
 <20180228183349.GA16336@bombadil.infradead.org>
 <CA+DvKQKoo1U7T_iOOLhfEf9c+K1pzD068au+kGtx0RokFFNKHw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Micay <danielmicay@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Jerome Glisse <jglisse@redhat.com>, Hugh Dickins <hughd@google.com>, Helge Deller <deller@gmx.de>, Andrea Arcangeli <aarcange@redhat.com>, Oleg Nesterov <oleg@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

Hello Daniel, thanks for sharing you experience!

> On 1 Mar 2018, at 00:02, Daniel Micay <danielmicay@gmail.com> wrote:
>=20
> I don't think it makes sense for the kernel to attempt mitigations to
> hide libraries. The best way to do that is in userspace, by having the
> linker reserve a large PROT_NONE region for mapping libraries (both at
> initialization and for dlopen) including a random gap to act as a
> separate ASLR base.
Why this is the best and what is the limit of this large region?
Let=E2=80=99s think out of the box.
What you say here means you made a separate memory region for libraries =
without=20
changing kernel. But the basic idea - you have a separate region for =
libraries=20
only. Probably you also want to have separate regions for any thread =
stack, for=20
mmaped files, shared memory, etc. This allows to protect memory regions =
of=20
different types from each other. It is impossible to implement this =
without=20
keeping the whole memory map. This map should be secure from any leak =
attack to=20
prevent ASLR bypass. The only one way to do it is to implement it in the =
kernel=20
and provide different syscalls like uselib or allocstack, etc. This one =
is=20
really hard in current kernel implementation.

My approach was to hide memory regions from attacker and from each =
other.

> If an attacker has library addresses, it's hard to
> see much point in hiding the other libraries from them.

In some cases attacker has only one leak for whole attack. And we should =
do the best
to make even this leak useless.

> It does make
> sense to keep them from knowing the location of any executable code if
> they leak non-library addresses. An isolated library region + gap is a
> feature we implemented in CopperheadOS and it works well, although we
> haven't ported it to Android 7.x or 8.x.
This one interesting to know and I would like to try to attack it, but =
it's out of the
scope of current conversation.

> I don't think the kernel can
> bring much / anything to the table for it. It's inherently the
> responsibility of libc to randomize the lower bits for secondary
> stacks too.

I think any bit of secondary stack should be randomized to provide =
attacker as
less information as we can.

> Fine-grained randomized mmap isn't going to be used if it causes
> unpredictable levels of fragmentation or has a high / unpredictable
> performance cost.

Lets pretend any chosen address is pure random and always satisfies =
request. At=20
some time we failed to mmap new chunk with size N. What does this means? =
This=20
means that all chunks with size of N are occupied and we even can=E2=80=99=
t find place=20
between them. Now lets count already allocated memory. Let=E2=80=99s =
pretend on all of=20
these occupied chunks lies one page minimum. So count of these pages is=20=

TASK_SIZE / N. Total bytes already allocated is PASGE_SIZE * TASK_SIZE / =
N. Now=20
we can calculate. TASK_SIZE is 2^48 bytes. PAGE_SIZE 4096. If N is 1MB,=20=

allocated memory minimum 1125899906842624, that is very big number. Ok. =
is N is=20
256 MB, we already consumed 4TB of memory. And this one is still ok. if =
N is=20
1GB we allocated 1GB and it looks like a problem. If we allocated 1GB of =
memory=20
we can=E2=80=99t mmap chunk size of 1GB. Sounds scary, but this is =
absolutely bad case=20
when we consume 1 page on 1GB chunk. In reality  this number would be =
much=20
bigger and random according this patch.

Here lets stop and think - if we know that application going to consume =
memory.=20
The question here would be can we protect it? Attacker will know he has =
a good=20
probability to guess address with read permissions. In this case ASLR =
may not=20
work at all. For such applications we can turn off address randomization =
or=20
decrease entropy level since it any way will not help much.

Would be good to know whats the performance costs you can see here. Can
you please tell?

> I don't think it makes sense to approach it
> aggressively in a way that people can't use. The OpenBSD randomized
> mmap is a fairly conservative implementation to avoid causing
> excessive fragmentation. I think they do a bit more than adding random
> gaps by switching between different 'pivots' but that isn't very high
> benefit. The main benefit is having random bits of unmapped space all
> over the heap when combined with their hardened allocator which
> heavily uses small mmap mappings and has a fair bit of malloc-level
> randomization (it's a bitmap / hash table based slab allocator using
> 4k regions with a page span cache and we use a port of it to Android
> with added hardening features but we're missing the fine-grained mmap
> rand it's meant to have underneath what it does itself).
>=20

So you think OpenBSD implementation even better? It seems like you like =
it
after all.

> The default vm.max_map_count =3D 65530 is also a major problem for =
doing
> fine-grained mmap randomization of any kind and there's the 32-bit
> reference count overflow issue on high memory machines with
> max_map_count * pid_max which isn't resolved yet.

I=E2=80=99ve read a thread about it. This one is what should be fixed =
anyway.

Thanks,
Ilya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
