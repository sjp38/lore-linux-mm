Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 573086B732E
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 08:49:25 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id u45-v6so7590779qte.12
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 05:49:25 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 29-v6sor769459qkw.114.2018.09.05.05.49.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Sep 2018 05:49:24 -0700 (PDT)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH] mm: hugepage: mark splitted page dirty when needed
Date: Wed, 05 Sep 2018 08:49:20 -0400
Message-ID: <BB56C67D-BDA0-4C14-B787-77504EC989C6@cs.rutgers.edu>
In-Reply-To: <20180905073037.GA23021@xz-x1>
References: <20180904075510.22338-1-peterx@redhat.com>
 <20180904080115.o2zj4mlo7yzjdqfl@kshutemo-mobl1>
 <D3B32B41-61D5-47B3-B1FC-77B0F71ADA47@cs.rutgers.edu>
 <20180905073037.GA23021@xz-x1>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_D3C5FC59-31AD-45DB-B1FA-4368F04176A4_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Xu <peterx@redhat.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Huang Ying <ying.huang@intel.com>, Dan Williams <dan.j.williams@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Souptick Joarder <jrdr.linux@gmail.com>, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_D3C5FC59-31AD-45DB-B1FA-4368F04176A4_=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 5 Sep 2018, at 3:30, Peter Xu wrote:

> On Tue, Sep 04, 2018 at 10:00:28AM -0400, Zi Yan wrote:
>> On 4 Sep 2018, at 4:01, Kirill A. Shutemov wrote:
>>
>>> On Tue, Sep 04, 2018 at 03:55:10PM +0800, Peter Xu wrote:
>>>> When splitting a huge page, we should set all small pages as dirty i=
f
>>>> the original huge page has the dirty bit set before.  Otherwise we'l=
l
>>>> lose the original dirty bit.
>>>
>>> We don't lose it. It got transfered to struct page flag:
>>>
>>> 	if (pmd_dirty(old_pmd))
>>> 		SetPageDirty(page);
>>>
>>
>> Plus, when split_huge_page_to_list() splits a THP, its subroutine __sp=
lit_huge_page()
>> propagates the dirty bit in the head page flag to all subpages in __sp=
lit_huge_page_tail().
>
> Hi, Kirill, Zi,
>
> Thanks for your responses!
>
> Though in my test the huge page seems to be splitted not by
> split_huge_page_to_list() but by explicit calls to
> change_protection().  The stack looks like this (again, this is a
> customized kernel, and I added an explicit dump_stack() there):
>
>   kernel:  dump_stack+0x5c/0x7b
>   kernel:  __split_huge_pmd+0x192/0xdc0
>   kernel:  ? update_load_avg+0x8b/0x550
>   kernel:  ? update_load_avg+0x8b/0x550
>   kernel:  ? account_entity_enqueue+0xc5/0xf0
>   kernel:  ? enqueue_entity+0x112/0x650
>   kernel:  change_protection+0x3a2/0xab0
>   kernel:  mwriteprotect_range+0xdd/0x110
>   kernel:  userfaultfd_ioctl+0x50b/0x1210
>   kernel:  ? do_futex+0x2cf/0xb20
>   kernel:  ? tty_write+0x1d2/0x2f0
>   kernel:  ? do_vfs_ioctl+0x9f/0x610
>   kernel:  do_vfs_ioctl+0x9f/0x610
>   kernel:  ? __x64_sys_futex+0x88/0x180
>   kernel:  ksys_ioctl+0x70/0x80
>   kernel:  __x64_sys_ioctl+0x16/0x20
>   kernel:  do_syscall_64+0x55/0x150
>   kernel:  entry_SYSCALL_64_after_hwframe+0x44/0xa9
>
> At the very time the userspace is sending an UFFDIO_WRITEPROTECT ioctl
> to kernel space, which is handled by mwriteprotect_range().  In case
> you'd like to refer to the kernel, it's basically this one from
> Andrea's (with very trivial changes):
>
>   https://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git userfau=
lt
>
> So... do we have two paths to split the huge pages separately?
>
> Another (possibly very naive) question is: could any of you hint me
> how the page dirty bit is finally applied to the PTEs?  These two
> dirty flags confused me for a few days already (the SetPageDirty() one
> which sets the page dirty flag, and the pte_mkdirty() which sets that
> onto the real PTEs).

change_protection() only causes splitting a PMD entry into multiple PTEs
but not the physical compound page, so my answer does not apply to your c=
ase.
It is unclear how the dirty bit makes your QEMU get a SIGBUS. I think you=

need to describe your problem with more details.

AFAIK, the PageDirty bit will not apply back to any PTEs. So for your cas=
e,
when reporting a page=E2=80=99s dirty bit information, some function in t=
he kernel only checks
the PTE=E2=80=99s dirty bit but not the dirty bit in the struct page flag=
s, which
might provide a wrong answer.


=E2=80=94
Best Regards,
Yan Zi

--=_MailMate_D3C5FC59-31AD-45DB-B1FA-4368F04176A4_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----

iQFKBAEBCgA0FiEEOXBxLIohamfZUwd5QYsvEZxOpswFAluP0NAWHHppLnlhbkBj
cy5ydXRnZXJzLmVkdQAKCRBBiy8RnE6mzE3uB/9vuqJDd3TOOk0HS/YAJqr/HaIL
u6LpAR+Kf1PvMoSlMgLsmhuoOu4U5uOyfD0ecFesX8UuR7kcVhqXfTDYPGiQTrhk
HpSFj/v9Y0mLFS6fYJuyhkFtrpR9fvsIuNqgdc/SLzUZgqcndj3glZHBg0BKa2pj
ZtHdln0J5m+H6GlJL68lIe4fITyuPVEkz/NW6TM0VXZIAvIRMn0krcmbgrunTayD
m8j5GYXy6HqCoXpBbvTDU/3/HRq4idVKRztY+B1gXfULPgqd5LNsTN7GlROqEM31
YUQfLO7sCWZ8QTNENg58N/xAhdbRwXpCX5xI/qOWM9v3sW/DTNG9ukRAueWV
=aUEN
-----END PGP SIGNATURE-----

--=_MailMate_D3C5FC59-31AD-45DB-B1FA-4368F04176A4_=--
