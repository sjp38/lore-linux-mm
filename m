Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 722156B000A
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 15:30:33 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id p202so3326715lfe.3
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 12:30:33 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g21sor719715ljb.73.2018.03.02.12.30.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 02 Mar 2018 12:30:31 -0800 (PST)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [RFC PATCH] Randomization of address chosen by mmap.
From: Ilya Smith <blackzert@gmail.com>
In-Reply-To: <20180228183349.GA16336@bombadil.infradead.org>
Date: Fri, 2 Mar 2018 23:30:28 +0300
Content-Transfer-Encoding: quoted-printable
Message-Id: <C9D0E3BA-3AB9-4F0E-BDA5-32378E440986@gmail.com>
References: <20180227131338.3699-1-blackzert@gmail.com>
 <CAGXu5jKF7ysJqj57ZktrcVL4G2NWOFHCud8dtXFHLs=tvVLXnQ@mail.gmail.com>
 <55C92196-5398-4C19-B7A7-6C122CD78F32@gmail.com>
 <20180228183349.GA16336@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Jerome Glisse <jglisse@redhat.com>, Hugh Dickins <hughd@google.com>, Helge Deller <deller@gmx.de>, Andrea Arcangeli <aarcange@redhat.com>, Oleg Nesterov <oleg@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

> On 28 Feb 2018, at 21:33, Matthew Wilcox <willy@infradead.org> wrote:
>=20
> On Wed, Feb 28, 2018 at 08:13:00PM +0300, Ilya Smith wrote:
>>> It would be worth spelling out the "not recommended" bit some more
>>> too: this fragments the mmap space, which has some serious issues on
>>> smaller address spaces if you get into a situation where you cannot
>>> allocate a hole large enough between the other allocations.
>>>=20
>>=20
>> I=E2=80=99m agree, that's the point.
>=20
> Would it be worth randomising the address returned just ever so =
slightly?
> ie instead of allocating exactly the next address, put in a guard hole
> of (configurable, by default maybe) 1-15 pages?  Is that enough extra
> entropy to foil an interesting number of attacks, or do we need the =
full
> randomise-the-address-space approach in order to be useful?
>=20

This is a really good question. Lets think we choose address with =
random-length=20
guard hole. This length is limited by some configuration as you =
described. For=20
instance let it be 1MB. Now according to current implementation, we =
still may=20
fill this gap with small allocations with size less than 1MB. Attacker =
will=20
going to build attack base on this predictable behaviour - he jus need =
to spray=20
with 1 MB chunks (or less, with some expectation). This attack harder =
but not=20
impossible.

Now lets say we will increase this 1MB to 128MB. Attack is the same, =
successful=20
rate less and more regions needed. Now we increase this value to 48 bit =
entropy=20
and will get my patch (in some form ;))

I hope full randomise-the-address-space approach will work for a long =
time.

Thanks,
Ilya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
