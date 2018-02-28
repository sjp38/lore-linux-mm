Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 827326B0003
	for <linux-mm@kvack.org>; Wed, 28 Feb 2018 16:02:42 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id g13so3009964qtj.15
        for <linux-mm@kvack.org>; Wed, 28 Feb 2018 13:02:42 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e16sor1964800qtk.108.2018.02.28.13.02.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 28 Feb 2018 13:02:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180228183349.GA16336@bombadil.infradead.org>
References: <20180227131338.3699-1-blackzert@gmail.com> <CAGXu5jKF7ysJqj57ZktrcVL4G2NWOFHCud8dtXFHLs=tvVLXnQ@mail.gmail.com>
 <55C92196-5398-4C19-B7A7-6C122CD78F32@gmail.com> <20180228183349.GA16336@bombadil.infradead.org>
From: Daniel Micay <danielmicay@gmail.com>
Date: Wed, 28 Feb 2018 16:02:40 -0500
Message-ID: <CA+DvKQKoo1U7T_iOOLhfEf9c+K1pzD068au+kGtx0RokFFNKHw@mail.gmail.com>
Subject: Re: [RFC PATCH] Randomization of address chosen by mmap.
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Ilya Smith <blackzert@gmail.com>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Jerome Glisse <jglisse@redhat.com>, Hugh Dickins <hughd@google.com>, Helge Deller <deller@gmx.de>, Andrea Arcangeli <aarcange@redhat.com>, Oleg Nesterov <oleg@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

The option to add at least one guard page would be useful whether or
not it's tied to randomization. It's not feasible to do that in
userspace for mmap as a whole, only specific users of mmap like malloc
and it adds significant overhead vs. a kernel implementation. It could
optionally let you choose a minimum and maximum guard region size with
it picking random sizes if they're not equal. It's important for it to
be an enforced gap rather than something that can be filled in by
another allocation. It will obviously help a lot more when it's being
used with a hardened allocator designed to take advantage of this
rather than glibc malloc or jemalloc.

I don't think it makes sense for the kernel to attempt mitigations to
hide libraries. The best way to do that is in userspace, by having the
linker reserve a large PROT_NONE region for mapping libraries (both at
initialization and for dlopen) including a random gap to act as a
separate ASLR base. If an attacker has library addresses, it's hard to
see much point in hiding the other libraries from them. It does make
sense to keep them from knowing the location of any executable code if
they leak non-library addresses. An isolated library region + gap is a
feature we implemented in CopperheadOS and it works well, although we
haven't ported it to Android 7.x or 8.x. I don't think the kernel can
bring much / anything to the table for it. It's inherently the
responsibility of libc to randomize the lower bits for secondary
stacks too.

Fine-grained randomized mmap isn't going to be used if it causes
unpredictable levels of fragmentation or has a high / unpredictable
performance cost. I don't think it makes sense to approach it
aggressively in a way that people can't use. The OpenBSD randomized
mmap is a fairly conservative implementation to avoid causing
excessive fragmentation. I think they do a bit more than adding random
gaps by switching between different 'pivots' but that isn't very high
benefit. The main benefit is having random bits of unmapped space all
over the heap when combined with their hardened allocator which
heavily uses small mmap mappings and has a fair bit of malloc-level
randomization (it's a bitmap / hash table based slab allocator using
4k regions with a page span cache and we use a port of it to Android
with added hardening features but we're missing the fine-grained mmap
rand it's meant to have underneath what it does itself).

The default vm.max_map_count = 65530 is also a major problem for doing
fine-grained mmap randomization of any kind and there's the 32-bit
reference count overflow issue on high memory machines with
max_map_count * pid_max which isn't resolved yet.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
