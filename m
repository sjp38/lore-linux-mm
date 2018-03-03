Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 158AC6B0003
	for <linux-mm@kvack.org>; Sat,  3 Mar 2018 16:00:48 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id r18so9202454qtn.17
        for <linux-mm@kvack.org>; Sat, 03 Mar 2018 13:00:48 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id g68sor7007919qkf.114.2018.03.03.13.00.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 03 Mar 2018 13:00:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <2CF957C6-53F2-4B00-920F-245BEF3CA1F6@gmail.com>
References: <20180227131338.3699-1-blackzert@gmail.com> <CAGXu5jKF7ysJqj57ZktrcVL4G2NWOFHCud8dtXFHLs=tvVLXnQ@mail.gmail.com>
 <55C92196-5398-4C19-B7A7-6C122CD78F32@gmail.com> <20180228183349.GA16336@bombadil.infradead.org>
 <CA+DvKQKoo1U7T_iOOLhfEf9c+K1pzD068au+kGtx0RokFFNKHw@mail.gmail.com> <2CF957C6-53F2-4B00-920F-245BEF3CA1F6@gmail.com>
From: Daniel Micay <danielmicay@gmail.com>
Date: Sat, 3 Mar 2018 16:00:45 -0500
Message-ID: <CA+DvKQ+mrnm4WX+3cBPuoSLFHmx2Zwz8=FsEx51fH-7yQMAd9w@mail.gmail.com>
Subject: Re: [RFC PATCH] Randomization of address chosen by mmap.
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ilya Smith <blackzert@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Jerome Glisse <jglisse@redhat.com>, Hugh Dickins <hughd@google.com>, Helge Deller <deller@gmx.de>, Andrea Arcangeli <aarcange@redhat.com>, Oleg Nesterov <oleg@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On 3 March 2018 at 08:58, Ilya Smith <blackzert@gmail.com> wrote:
> Hello Daniel, thanks for sharing you experience!
>
>> On 1 Mar 2018, at 00:02, Daniel Micay <danielmicay@gmail.com> wrote:
>>
>> I don't think it makes sense for the kernel to attempt mitigations to
>> hide libraries. The best way to do that is in userspace, by having the
>> linker reserve a large PROT_NONE region for mapping libraries (both at
>> initialization and for dlopen) including a random gap to act as a
>> separate ASLR base.
> Why this is the best and what is the limit of this large region?
> Let=E2=80=99s think out of the box.
> What you say here means you made a separate memory region for libraries w=
ithout
> changing kernel. But the basic idea - you have a separate region for libr=
aries
> only. Probably you also want to have separate regions for any thread stac=
k, for
> mmaped files, shared memory, etc. This allows to protect memory regions o=
f
> different types from each other. It is impossible to implement this witho=
ut
> keeping the whole memory map. This map should be secure from any leak att=
ack to
> prevent ASLR bypass. The only one way to do it is to implement it in the =
kernel
> and provide different syscalls like uselib or allocstack, etc. This one i=
s
> really hard in current kernel implementation.

There's the option of reserving PROT_NONE regions and managing memory
within them using a similar best-fit allocation scheme to get separate
random bases. The kernel could offer something like that but it's
already possible to do it for libc mmap usage within libc as we did
for libraries.

The kernel's help is needed to cover non-libc users of mmap, i.e. not
the linker, malloc, etc. It's not possible for libc to assume that
everything goes through the libc mmap/mremap/munmap wrappers and it
would be a mess so I'm not saying the kernel doesn't have a part to
play. I'm only saying it makes sense to look at the whole picture and
if something can be done better in libc or the linker, to do it there
instead. There isn't an API for dividing stuff up into regions, so it
has to be done in userspace right now and I think it works a lot
better when it's an option.

>
> My approach was to hide memory regions from attacker and from each other.
>
>> If an attacker has library addresses, it's hard to
>> see much point in hiding the other libraries from them.
>
> In some cases attacker has only one leak for whole attack. And we should =
do the best
> to make even this leak useless.
>
>> It does make
>> sense to keep them from knowing the location of any executable code if
>> they leak non-library addresses. An isolated library region + gap is a
>> feature we implemented in CopperheadOS and it works well, although we
>> haven't ported it to Android 7.x or 8.x.
> This one interesting to know and I would like to try to attack it, but it=
's out of the
> scope of current conversation.

I don't think it's out-of-scope. There are different approaches to
this kind of finer-grained randomization and they can be done
together.

>> I don't think the kernel can
>> bring much / anything to the table for it. It's inherently the
>> responsibility of libc to randomize the lower bits for secondary
>> stacks too.
>
> I think any bit of secondary stack should be randomized to provide attack=
er as
> less information as we can.

The issue is that the kernel is only providing a mapping so it can add
a random gap or randomize it in other ways but it's ultimately up to
libc and other userspace code to do randomization without those
mappings.

A malloc implementation is similarly going to request fairly large
mappings from the kernel to manage a bunch of stuff within them
itself. The kernel can't protect against stuff like heap spray attacks
very well all by itself. It definitely has a part to play in that but
is a small piece of it (unless the malloc impl actually manages
virtual memory regions itself, which is already done by
performance-oriented allocators for very different reasons).

>> Fine-grained randomized mmap isn't going to be used if it causes
>> unpredictable levels of fragmentation or has a high / unpredictable
>> performance cost.
>
> Lets pretend any chosen address is pure random and always satisfies reque=
st. At
> some time we failed to mmap new chunk with size N. What does this means? =
This
> means that all chunks with size of N are occupied and we even can=E2=80=
=99t find place
> between them. Now lets count already allocated memory. Let=E2=80=99s pret=
end on all of
> these occupied chunks lies one page minimum. So count of these pages is
> TASK_SIZE / N. Total bytes already allocated is PASGE_SIZE * TASK_SIZE / =
N. Now
> we can calculate. TASK_SIZE is 2^48 bytes. PAGE_SIZE 4096. If N is 1MB,
> allocated memory minimum 1125899906842624, that is very big number. Ok. i=
s N is
> 256 MB, we already consumed 4TB of memory. And this one is still ok. if N=
 is
> 1GB we allocated 1GB and it looks like a problem. If we allocated 1GB of =
memory
> we can=E2=80=99t mmap chunk size of 1GB. Sounds scary, but this is absolu=
tely bad case
> when we consume 1 page on 1GB chunk. In reality  this number would be muc=
h
> bigger and random according this patch.
>
> Here lets stop and think - if we know that application going to consume m=
emory.
> The question here would be can we protect it? Attacker will know he has a=
 good
> probability to guess address with read permissions. In this case ASLR may=
 not
> work at all. For such applications we can turn off address randomization =
or
> decrease entropy level since it any way will not help much.
>
> Would be good to know whats the performance costs you can see here. Can
> you please tell?

Fragmenting the virtual address space means having more TLB cache
misses, etc. Spreading out the mappings more also increases memory
usage and overhead for anything tied to the number of VMAs, which is
hopefully all O(log n) where it matters but O(log n) doesn't mean
increasing `n` is free.

>> I don't think it makes sense to approach it
>> aggressively in a way that people can't use. The OpenBSD randomized
>> mmap is a fairly conservative implementation to avoid causing
>> excessive fragmentation. I think they do a bit more than adding random
>> gaps by switching between different 'pivots' but that isn't very high
>> benefit. The main benefit is having random bits of unmapped space all
>> over the heap when combined with their hardened allocator which
>> heavily uses small mmap mappings and has a fair bit of malloc-level
>> randomization (it's a bitmap / hash table based slab allocator using
>> 4k regions with a page span cache and we use a port of it to Android
>> with added hardening features but we're missing the fine-grained mmap
>> rand it's meant to have underneath what it does itself).
>>
>
> So you think OpenBSD implementation even better? It seems like you like i=
t
> after all.

I think they found a good compromise between low fragmentation vs.
some security benefits.

The main thing I'd like to see is just the option to get a guarantee
of enforced gaps around mappings, without necessarily even having
randomization of the gap size. It's possible to add guard pages in
userspace but it adds overhead by doubling the number of system calls
to map memory (mmap PROT_NONE region, mprotect the inner portion to
PROT_READ|PROT_WRITE) and *everything* using mmap would need to
cooperate which is unrealistic.

>> The default vm.max_map_count =3D 65530 is also a major problem for doing
>> fine-grained mmap randomization of any kind and there's the 32-bit
>> reference count overflow issue on high memory machines with
>> max_map_count * pid_max which isn't resolved yet.
>
> I=E2=80=99ve read a thread about it. This one is what should be fixed any=
way.
>
> Thanks,
> Ilya
>

Yeah, the correctness issue should definitely be fixed. The default
value would *really* need to be raised if greatly increasing the
number of VMAs by not using a performance / low-fragmentation focused
best-fit algorithm without randomization or enforced gaps.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
