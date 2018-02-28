Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8DAD86B0003
	for <linux-mm@kvack.org>; Wed, 28 Feb 2018 12:13:06 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id v123so973129lfa.4
        for <linux-mm@kvack.org>; Wed, 28 Feb 2018 09:13:06 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c24sor530718lja.78.2018.02.28.09.13.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 28 Feb 2018 09:13:04 -0800 (PST)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [RFC PATCH] Randomization of address chosen by mmap.
From: Ilya Smith <blackzert@gmail.com>
In-Reply-To: <CAGXu5jKF7ysJqj57ZktrcVL4G2NWOFHCud8dtXFHLs=tvVLXnQ@mail.gmail.com>
Date: Wed, 28 Feb 2018 20:13:00 +0300
Content-Transfer-Encoding: quoted-printable
Message-Id: <55C92196-5398-4C19-B7A7-6C122CD78F32@gmail.com>
References: <20180227131338.3699-1-blackzert@gmail.com>
 <CAGXu5jKF7ysJqj57ZktrcVL4G2NWOFHCud8dtXFHLs=tvVLXnQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Jerome Glisse <jglisse@redhat.com>, Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@infradead.org>, Helge Deller <deller@gmx.de>, Andrea Arcangeli <aarcange@redhat.com>, Oleg Nesterov <oleg@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

Hello Kees,

Thanks for your time spent on that!

> On 27 Feb 2018, at 23:52, Kees Cook <keescook@chromium.org> wrote:
>=20
> I'd like more details on the threat model here; if it's just a matter
> of .so loading order, I wonder if load order randomization would get a
> comparable level of uncertainty without the memory fragmentation,
> like:
> https://android-review.googlesource.com/c/platform/bionic/+/178130/2
> If glibc, for example, could do this too, it would go a long way to
> improving things. Obviously, it's not as extreme as loading stuff all
> over the place, but it seems like the effect for an attack would be
> similar. The search _area_ remains small, but the ordering wouldn't be
> deterministic any more.
>=20

I=E2=80=99m afraid library order randomization wouldn=E2=80=99t help =
much, there are several=20
cases described in chapter 2 here:=20
http://www.openwall.com/lists/oss-security/2018/02/27/5
when it is possible to bypass ASLR.=20

I=E2=80=99m agree library randomizaiton is a good improvement but after =
my patch
I think not much valuable. On my GitHub =
https://github.com/blackzert/aslur=20
I provided tests and will make them 'all in one=E2=80=99 chain later.

> It would be worth spelling out the "not recommended" bit some more
> too: this fragments the mmap space, which has some serious issues on
> smaller address spaces if you get into a situation where you cannot
> allocate a hole large enough between the other allocations.
>=20

I=E2=80=99m agree, that's the point.

>> vm_unmapped_area(struct vm_unmapped_area_info *info)
>> {
>> +       if (current->flags & PF_RANDOMIZE)
>> +               return unmapped_area_random(info);
>=20
> I think this will need a larger knob -- doing this by default is
> likely to break stuff, I'd imagine? Bikeshedding: I'm not sure if this
> should be setting "3" for /proc/sys/kernel/randomize_va_space, or a
> separate one like /proc/sys/mm/randomize_mmap_allocation.

I will improve it like you said. It looks like a better option.

>> +       // first lets find right border with unmapped_area_topdown
>=20
> Nit: kernel comments are /* */. (It's a good idea to run patches
> through scripts/checkpatch.pl first.)
>=20

Sorry, I will fix it. Thanks!


>> +                       if (!rb_parent(prev))
>> +                               return -ENOMEM;
>> +                       vma =3D rb_entry(rb_parent(prev),
>> +                                      struct vm_area_struct, vm_rb);
>> +                       if (prev =3D=3D vma->vm_rb.rb_right) {
>> +                               gap_start =3D vma->vm_prev ?
>> +                                       vm_end_gap(vma->vm_prev) : 0;
>> +                               goto check_current_down;
>> +                       }
>> +               }
>> +       }
>=20
> Everything from here up is identical to the existing
> unmapped_area_topdown(), yes? This likely needs to be refactored
> instead of copy/pasted, and adjust to handle both unmapped_area() and
> unmapped_area_topdown().
>=20

This part also keeps =E2=80=98right_vma' as a border. If it is ok, that =
combined version
 will return vma struct, I=E2=80=99ll do it.

>> +               /* Go back up the rbtree to find next candidate node =
*/
>> +               while (true) {
>> +                       struct rb_node *prev =3D &vma->vm_rb;
>> +
>> +                       if (!rb_parent(prev))
>> +                               BUG(); // this should not happen
>> +                       vma =3D rb_entry(rb_parent(prev),
>> +                                      struct vm_area_struct, vm_rb);
>> +                       if (prev =3D=3D vma->vm_rb.rb_left) {
>> +                               gap_start =3D =
vm_end_gap(vma->vm_prev);
>> +                               gap_end =3D vm_start_gap(vma);
>> +                               if (vma =3D=3D right_vma)
>=20
> mm/mmap.c: In function =E2=80=98unmapped_area_random=E2=80=99:
> mm/mmap.c:1939:8: warning: =E2=80=98vma=E2=80=99 may be used =
uninitialized in this
> function [-Wmaybe-uninitialized]
>     if (vma =3D=3D right_vma)
>        ^

Thanks, fixed!

>> +                                       break;
>> +                               goto check_current_up;
>> +                       }
>> +               }
>> +       }
>=20
> What are the two phases here? Could this second one get collapsed into
> the first?
>=20

Let me explain.=20
1. we use current implementation to get larger address. Remember it as=20=

=E2=80=98right_vma=E2=80=99.
2. we walk tree from mm->mmap what is lowest vma.
3. we check if current vma gap satisfies length and low/high constrains
4. if so, we call random() to decide if we choose it. This how we =
randomly choos
e vma and gap
5. we walk tree from lowest vma to highest and ignore subtrees with less =
gap.=20
we do it until reach =E2=80=98right_vma=E2=80=99

Once we found gap, we may randomly choose address inside it.

>> +       addr =3D get_random_long() % ((high - low) >> PAGE_SHIFT);
>> +       addr =3D low + (addr << PAGE_SHIFT);
>> +       return addr;
>>=20
>=20
> How large are the gaps intended to be? Looking at the gaps on
> something like Xorg they differ a lot.

Sorry, I can=E2=80=99t get clue. What's the context? You tried patch or =
whats the case?

Thanks,
Ilya



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
