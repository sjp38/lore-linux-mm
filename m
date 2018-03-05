Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id EA0396B0023
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 08:09:36 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id 102so5175638lft.15
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 05:09:36 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b86sor2874395lfl.32.2018.03.05.05.09.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Mar 2018 05:09:34 -0800 (PST)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [RFC PATCH] Randomization of address chosen by mmap.
From: Ilya Smith <blackzert@gmail.com>
In-Reply-To: <20180304205614.GC23816@bombadil.infradead.org>
Date: Mon, 5 Mar 2018 16:09:31 +0300
Content-Transfer-Encoding: quoted-printable
Message-Id: <7FA6631B-951F-42F4-A7BF-8E5BB734D709@gmail.com>
References: <20180227131338.3699-1-blackzert@gmail.com>
 <CAGXu5jKF7ysJqj57ZktrcVL4G2NWOFHCud8dtXFHLs=tvVLXnQ@mail.gmail.com>
 <55C92196-5398-4C19-B7A7-6C122CD78F32@gmail.com>
 <20180228183349.GA16336@bombadil.infradead.org>
 <CA+DvKQKoo1U7T_iOOLhfEf9c+K1pzD068au+kGtx0RokFFNKHw@mail.gmail.com>
 <2CF957C6-53F2-4B00-920F-245BEF3CA1F6@gmail.com>
 <CA+DvKQ+mrnm4WX+3cBPuoSLFHmx2Zwz8=FsEx51fH-7yQMAd9w@mail.gmail.com>
 <20180304034704.GB20725@bombadil.infradead.org>
 <20180304205614.GC23816@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Daniel Micay <danielmicay@gmail.com>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Jerome Glisse <jglisse@redhat.com>, Hugh Dickins <hughd@google.com>, Helge Deller <deller@gmx.de>, Andrea Arcangeli <aarcange@redhat.com>, Oleg Nesterov <oleg@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>


> On 4 Mar 2018, at 23:56, Matthew Wilcox <willy@infradead.org> wrote:
> Thinking about this more ...
>=20
> - When you call munmap, if you pass in the same (addr, length) that =
were
>   used for mmap, then it should unmap the guard pages as well (that
>   wasn't part of the patch, so it would have to be added)
> - If 'addr' is higher than the mapped address, and length at least
>   reaches the end of the mapping, then I would expect the guard pages =
to
>   "move down" and be after the end of the newly-shortened mapping.
> - If 'addr' is higher than the mapped address, and the length doesn't
>   reach the end of the old mapping, we split the old mapping into two.
>   I would expect the guard pages to apply to both mappings, insofar as
>   they'll fit.  For an example, suppose we have a five-page mapping =
with
>   two guard pages (MMMMMGG), and then we unmap the fourth page.  Now =
we
>   have a three-page mapping with one guard page followed immediately
>   by a one-page mapping with two guard pages (MMMGMGG).

I=E2=80=99m analysing that approach and see much more problems:
- each time you call mmap like this, you still  increase count of vmas =
as my=20
patch did
- now feature vma_merge shouldn=E2=80=99t work at all, until MAP_FIXED =
is set or
PROT_GUARD(0)
- the entropy you provide is like 16 bit, that is really not so hard to =
brute
- in your patch you don=E2=80=99t use vm_guard at address searching, I =
see many roots=20
of bugs here
- if you unmap/remap one page inside region, field vma_guard will show =
head=20
or tail pages for vma, not both; kernel don=E2=80=99t know how to handle =
it
- user mode now choose entropy with PROT_GUARD macro, where did he gets =
it?=20
User mode shouldn=E2=80=99t be responsible for entropy at all

I can=E2=80=99t understand what direction this conversation is going to. =
I was talking=20
about weak implementation in Linux kernel but got many comments about =
ASLR=20
should be implemented in user mode what is really weird to me.

I think it is possible  to add GUARD pages into my implementations, but =
initially=20
problem was about entropy of address choosing. I would like to resolve =
it step by
step.

Thanks,
Ilya=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
