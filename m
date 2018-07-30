Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5517D6B0003
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 13:33:09 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id g12-v6so9387765ioh.5
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 10:33:09 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o192-v6sor62836ita.43.2018.07.30.10.33.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 30 Jul 2018 10:33:07 -0700 (PDT)
MIME-Version: 1.0
References: <CA+55aFxpFefwVdTGVML99PSFUqwpJXPx5LVCA3D=g2t2_QLNsA@mail.gmail.com>
 <CAMi1Hd0fJuAgP09_KkbjyGwszOXmxcPybKyBxP3U1y5JUqxxSw@mail.gmail.com> <20180730130134.yvn5tcmoavuxtwt5@kshutemo-mobl1>
In-Reply-To: <20180730130134.yvn5tcmoavuxtwt5@kshutemo-mobl1>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 30 Jul 2018 10:32:55 -0700
Message-ID: <CA+55aFwxwCPZs=h5wy-5PELwfBVuTETm+wuZB5cM2SDoXJi68g@mail.gmail.com>
Subject: Re: Linux 4.18-rc7
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@infradead.org>
Cc: Amit Pundir <amit.pundir@linaro.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, John Stultz <john.stultz@linaro.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, youling257@gmail.com

On Mon, Jul 30, 2018 at 6:01 AM Kirill A. Shutemov <kirill@shutemov.name> wrote:
>
> I think I missed vma_set_anonymous() somewhere, but I fail to see where.

Honestly, by now we just need to revert that commit.

It's not even clear that it was a good idea to begin with. The rest of
the commits were cleanups, this one was driven by a incorrect
VM_BUG_ON() that triggered, and that checked "vma_is_anonymous(vma)"
without any explanations of wht it should matter.

I think the biggest problem with vma_is_anonymous() may be its name,
not what it does.

What the code historically *did* (and what vma_is_anonymous() checks)
is not "is this anonymous", but rather "does this have any special
operations associated with it".

The two are similar. But people have grown opinions about exactly what
"anonymous" means. If we had named it just "no_vm_ops()", we wouldn't
have random crazy checks for "vma_is_anonymous()" in places where it
makes no sense.

So what I think we want a real explanation for is why people who use
"vma_is_anonymous()" care. Instead of trying to change its very
historical meaning, we should look at the users, and perhaps change
its name.

In this case, for example, I think the *real* problem was described by
commit 684283988f70 ("huge pagecache: mmap_sem is unlocked when
truncation splits pmd"), and the problem is that an existing check
that required that mmap_sem was held was changed to say "only for
anonymous mappings".

But the fact is, you can truncate mappings that don't have any ops just *fine*.

So maybe that original BUG() was entirely bogus to begin with, and it
shouldn't exist at all?

Or maybe the code should test "do I have a vm_file" instead of testing
"do I have vm_ops"?

What's the problem with just doing split_huge_pmd() there when it's a
pmd_trans_huge or pmd_devmap pmd? Why is that VM_BUG_ON_VMA() there in
the first place? Why are allegedly "anonymous" mappings so special
here for locking?

Adding a few more people to the cc, they were involved the last that
time VM_BUG_ON_VMA() was modified.

New people: see commit bfd40eaff5ab ("mm: fix vma_is_anonymous()
false-positives") for details. Right now I think it's getting
reverted, but the oops explanation in the commit is about that

            kernel BUG at mm/memory.c:1422!

which was/is debatable and seems to make no sense (and definitely is
still triggerable despite that commit 684283988f70 ("huge pagecache:
mmap_sem is unlocked when truncation splits pmd") that limited it a
bit - but I think it didn't limit it enough.

               Linus
