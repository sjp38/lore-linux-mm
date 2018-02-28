Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id A6DE16B0003
	for <linux-mm@kvack.org>; Wed, 28 Feb 2018 14:54:35 -0500 (EST)
Received: by mail-ua0-f199.google.com with SMTP id k4so2221188uad.13
        for <linux-mm@kvack.org>; Wed, 28 Feb 2018 11:54:35 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q81sor1012209vkd.211.2018.02.28.11.54.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 28 Feb 2018 11:54:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <55C92196-5398-4C19-B7A7-6C122CD78F32@gmail.com>
References: <20180227131338.3699-1-blackzert@gmail.com> <CAGXu5jKF7ysJqj57ZktrcVL4G2NWOFHCud8dtXFHLs=tvVLXnQ@mail.gmail.com>
 <55C92196-5398-4C19-B7A7-6C122CD78F32@gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 28 Feb 2018 11:54:32 -0800
Message-ID: <CAGXu5jLY4eX5BMU8-2HFr2myjSL717KE-m_SAQp1yeu=cg+w7g@mail.gmail.com>
Subject: Re: [RFC PATCH] Randomization of address chosen by mmap.
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ilya Smith <blackzert@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Jerome Glisse <jglisse@redhat.com>, Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@infradead.org>, Helge Deller <deller@gmx.de>, Andrea Arcangeli <aarcange@redhat.com>, Oleg Nesterov <oleg@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Wed, Feb 28, 2018 at 9:13 AM, Ilya Smith <blackzert@gmail.com> wrote:
>> On 27 Feb 2018, at 23:52, Kees Cook <keescook@chromium.org> wrote:
>> What are the two phases here? Could this second one get collapsed into
>> the first?
>>
>
> Let me explain.
> 1. we use current implementation to get larger address. Remember it as
> =E2=80=98right_vma=E2=80=99.
> 2. we walk tree from mm->mmap what is lowest vma.
> 3. we check if current vma gap satisfies length and low/high constrains
> 4. if so, we call random() to decide if we choose it. This how we randoml=
y choose vma and gap
> 5. we walk tree from lowest vma to highest and ignore subtrees with less =
gap.
> we do it until reach =E2=80=98right_vma=E2=80=99
>
> Once we found gap, we may randomly choose address inside it.
>
>>> +       addr =3D get_random_long() % ((high - low) >> PAGE_SHIFT);
>>> +       addr =3D low + (addr << PAGE_SHIFT);
>>> +       return addr;
>>>
>>
>> How large are the gaps intended to be? Looking at the gaps on
>> something like Xorg they differ a lot.
>
> Sorry, I can=E2=80=99t get clue. What's the context? You tried patch or w=
hats the case?

I was trying to understand the target entropy level, and I'm worried
it's a bit biased. For example, if the first allocation lands at 1/4th
of the memory space, the next allocation (IIUC) has a 50% chance of
falling on either side of it. If it goes on the small side, it then
has much less entropy than if it had gone on the other side. I think
this may be less entropy than choosing a random address and just
seeing if it fits or not. Dealing with collisions could be done either
by pushing the address until it doesn't collide or picking another
random address, etc. This is probably more expensive, though, since it
would need to walk the vma tree repeatedly. Anyway, I was ultimately
curious about your measured entropy and what alternatives you
considered.

-Kees

--=20
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
