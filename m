Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 964826B0007
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 09:24:01 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id a144so14364235qkb.3
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 06:24:01 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t45sor5466759qtg.11.2018.03.05.06.24.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Mar 2018 06:24:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <7FA6631B-951F-42F4-A7BF-8E5BB734D709@gmail.com>
References: <20180227131338.3699-1-blackzert@gmail.com> <CAGXu5jKF7ysJqj57ZktrcVL4G2NWOFHCud8dtXFHLs=tvVLXnQ@mail.gmail.com>
 <55C92196-5398-4C19-B7A7-6C122CD78F32@gmail.com> <20180228183349.GA16336@bombadil.infradead.org>
 <CA+DvKQKoo1U7T_iOOLhfEf9c+K1pzD068au+kGtx0RokFFNKHw@mail.gmail.com>
 <2CF957C6-53F2-4B00-920F-245BEF3CA1F6@gmail.com> <CA+DvKQ+mrnm4WX+3cBPuoSLFHmx2Zwz8=FsEx51fH-7yQMAd9w@mail.gmail.com>
 <20180304034704.GB20725@bombadil.infradead.org> <20180304205614.GC23816@bombadil.infradead.org>
 <7FA6631B-951F-42F4-A7BF-8E5BB734D709@gmail.com>
From: Daniel Micay <danielmicay@gmail.com>
Date: Mon, 5 Mar 2018 09:23:59 -0500
Message-ID: <CA+DvKQKHqVzk9u2GwSC+F2vF938DY4Heb+JexwOSZhfcFkuqcw@mail.gmail.com>
Subject: Re: [RFC PATCH] Randomization of address chosen by mmap.
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ilya Smith <blackzert@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Jerome Glisse <jglisse@redhat.com>, Hugh Dickins <hughd@google.com>, Helge Deller <deller@gmx.de>, Andrea Arcangeli <aarcange@redhat.com>, Oleg Nesterov <oleg@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On 5 March 2018 at 08:09, Ilya Smith <blackzert@gmail.com> wrote:
>
>> On 4 Mar 2018, at 23:56, Matthew Wilcox <willy@infradead.org> wrote:
>> Thinking about this more ...
>>
>> - When you call munmap, if you pass in the same (addr, length) that were
>>   used for mmap, then it should unmap the guard pages as well (that
>>   wasn't part of the patch, so it would have to be added)
>> - If 'addr' is higher than the mapped address, and length at least
>>   reaches the end of the mapping, then I would expect the guard pages to
>>   "move down" and be after the end of the newly-shortened mapping.
>> - If 'addr' is higher than the mapped address, and the length doesn't
>>   reach the end of the old mapping, we split the old mapping into two.
>>   I would expect the guard pages to apply to both mappings, insofar as
>>   they'll fit.  For an example, suppose we have a five-page mapping with
>>   two guard pages (MMMMMGG), and then we unmap the fourth page.  Now we
>>   have a three-page mapping with one guard page followed immediately
>>   by a one-page mapping with two guard pages (MMMGMGG).
>
> I=E2=80=99m analysing that approach and see much more problems:
> - each time you call mmap like this, you still  increase count of vmas as=
 my
> patch did
> - now feature vma_merge shouldn=E2=80=99t work at all, until MAP_FIXED is=
 set or
> PROT_GUARD(0)
> - the entropy you provide is like 16 bit, that is really not so hard to b=
rute
> - in your patch you don=E2=80=99t use vm_guard at address searching, I se=
e many roots
> of bugs here
> - if you unmap/remap one page inside region, field vma_guard will show he=
ad
> or tail pages for vma, not both; kernel don=E2=80=99t know how to handle =
it
> - user mode now choose entropy with PROT_GUARD macro, where did he gets i=
t?
> User mode shouldn=E2=80=99t be responsible for entropy at all

I didn't suggest this as the way of implementing fine-grained
randomization but rather a small starting point for hardening address
space layout further. I don't think it should be tied to a mmap flag
but rather something like a personality flag or a global sysctl. It
doesn't need to be random at all to be valuable, and it's just a first
step. It doesn't mean there can't be switches between random pivots
like OpenBSD mmap, etc. I'm not so sure that randomly switching around
is going to result in isolating things very well though.

The VMA count issue is at least something very predictable with a
performance cost only for kernel operations.

> I can=E2=80=99t understand what direction this conversation is going to. =
I was talking
> about weak implementation in Linux kernel but got many comments about ASL=
R
> should be implemented in user mode what is really weird to me.

That's not what I said. I was saying that splitting things into
regions based on the type of allocation works really well and allows
for high entropy bases, but that the kernel can't really do that right
now. It could split up code that starts as PROT_EXEC into a region but
that's generally not how libraries are mapped in so it won't know
until mprotect which is obviously too late. Unless it had some kind of
type key passed from userspace, it can't really do that.

> I think it is possible  to add GUARD pages into my implementations, but i=
nitially
> problem was about entropy of address choosing. I would like to resolve it=
 step by
> step.

Starting with fairly aggressive fragmentation of the address space is
going to be a really hard sell. The costs of a very spread out address
space in terms of TLB misses, etc. are unclear. Starting with enforced
gaps (1 page) and randomization for those wouldn't rule out having
finer-grained randomization, like randomly switching between different
regions. This needs to be cheap enough that people want to enable it,
and the goals need to be clearly spelled out. The goal needs to be
clearer than "more randomization =3D=3D good" and then accepting a high
performance cost for that.

I'm not dictating how things should be done, I don't have any say
about that. I'm just trying to discuss it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
