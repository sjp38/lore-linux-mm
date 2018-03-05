Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 52D1D6B0006
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 14:27:37 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id p87so5402317lfg.8
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 11:27:37 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n7sor2932520lfn.2.2018.03.05.11.27.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Mar 2018 11:27:35 -0800 (PST)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [RFC PATCH] Randomization of address chosen by mmap.
From: Ilya Smith <blackzert@gmail.com>
In-Reply-To: <20180305162343.GA8230@bombadil.infradead.org>
Date: Mon, 5 Mar 2018 22:27:32 +0300
Content-Transfer-Encoding: quoted-printable
Message-Id: <EC4E37F1-C2B8-4112-8EAD-FF072602DD08@gmail.com>
References: <20180227131338.3699-1-blackzert@gmail.com>
 <CAGXu5jKF7ysJqj57ZktrcVL4G2NWOFHCud8dtXFHLs=tvVLXnQ@mail.gmail.com>
 <55C92196-5398-4C19-B7A7-6C122CD78F32@gmail.com>
 <20180228183349.GA16336@bombadil.infradead.org>
 <CA+DvKQKoo1U7T_iOOLhfEf9c+K1pzD068au+kGtx0RokFFNKHw@mail.gmail.com>
 <2CF957C6-53F2-4B00-920F-245BEF3CA1F6@gmail.com>
 <CA+DvKQ+mrnm4WX+3cBPuoSLFHmx2Zwz8=FsEx51fH-7yQMAd9w@mail.gmail.com>
 <20180304034704.GB20725@bombadil.infradead.org>
 <20180304205614.GC23816@bombadil.infradead.org>
 <7FA6631B-951F-42F4-A7BF-8E5BB734D709@gmail.com>
 <20180305162343.GA8230@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Daniel Micay <danielmicay@gmail.com>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Jerome Glisse <jglisse@redhat.com>, Hugh Dickins <hughd@google.com>, Helge Deller <deller@gmx.de>, Andrea Arcangeli <aarcange@redhat.com>, Oleg Nesterov <oleg@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>




> On 5 Mar 2018, at 19:23, Matthew Wilcox <willy@infradead.org> wrote:
>=20
> On Mon, Mar 05, 2018 at 04:09:31PM +0300, Ilya Smith wrote:
>>=20
>> I=E2=80=99m analysing that approach and see much more problems:
>> - each time you call mmap like this, you still  increase count of =
vmas as my=20
>> patch did
>=20
> Umm ... yes, each time you call mmap, you get a VMA.  I'm not sure why
> that's a problem with my patch.  I was trying to solve the problem =
Daniel
> pointed out, that mapping a guard region after each mmap cost twice as
> many VMAs, and it solves that problem.
>=20
The issue was in VMAs count as Daniel mentioned.=20
The more count, the harder walk tree. I think this is fine

>> - the entropy you provide is like 16 bit, that is really not so hard =
to brute
>=20
> It's 16 bits per mapping.  I think that'll make enough attacks harder
> to be worthwhile.

Well yes, its ok, sorry. I just would like to have 32 bit entropy =
maximum some day :)

>> - in your patch you don=E2=80=99t use vm_guard at address searching, =
I see many roots=20
>> of bugs here
>=20
> Don't need to.  vm_end includes the guard pages.
>=20
>> - if you unmap/remap one page inside region, field vma_guard will =
show head=20
>> or tail pages for vma, not both; kernel don=E2=80=99t know how to =
handle it
>=20
> There are no head pages.  The guard pages are only placed after the =
real end.
>=20

Ok, we have MG where G =3D vm_guard, right? so when you do vm_split,=20
you may come to situation - m1g1m2G, how to handle it? I mean when M is=20=

split with only one page inside this region. How to handle it?

>> - user mode now choose entropy with PROT_GUARD macro, where did he =
gets it?=20
>> User mode shouldn=E2=80=99t be responsible for entropy at all
>=20
> I can't agree with that.  The user has plenty of opportunities to get
> randomness; from /dev/random is the easiest, but you could also do =
timing
> attacks on your own cachelines, for example.

I think the usual case to use randomization for any mmap or not use it =
at all=20
for whole process. So here I think would be nice to have some variable=20=

changeable with sysctl (root only) and ioctl (for greedy processes).

Well, let me summary:
My approach chose random gap inside gap range with following strings:

+	addr =3D get_random_long() % ((high - low) >> PAGE_SHIFT);
+	addr =3D low + (addr << PAGE_SHIFT);

Could be improved limiting maximum possible entropy in this shift.
To prevent situation when attacker may massage allocations and=20
predict chosen address, I randomly choose memory region. I=E2=80=99m =
still
like my idea, but not going to push it anymore, since you have yours =
now.

Your idea just provide random non-mappable and non-accessable offset
from best-fit region. This consumes memory (1GB gap if random value=20
is 0xffff). But it works and should work faster and should resolve the =
issue. =20

My point was that current implementation need to be changed and you
have your own approach for that. :)
Lets keep mine in the mind till better times (or worse?) ;)
Will you finish your approach and upstream it?

Best regards,
Ilya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
