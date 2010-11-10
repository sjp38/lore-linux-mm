Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id DD2E16B004A
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 07:22:05 -0500 (EST)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id oAACM1MQ024426
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 04:22:01 -0800
Received: from qyk9 (qyk9.prod.google.com [10.241.83.137])
	by hpaq14.eem.corp.google.com with ESMTP id oAACLbJc008778
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 04:22:00 -0800
Received: by qyk9 with SMTP id 9so433142qyk.7
        for <linux-mm@kvack.org>; Wed, 10 Nov 2010 04:21:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101109115540.BC3F.A69D9226@jp.fujitsu.com>
References: <AANLkTik4NM5YOgh48bOWDQZuUKmEHLH6Ja10eOzn-_tj@mail.gmail.com>
	<20101101015311.6062.A69D9226@jp.fujitsu.com>
	<20101109115540.BC3F.A69D9226@jp.fujitsu.com>
Date: Wed, 10 Nov 2010 04:21:59 -0800
Message-ID: <AANLkTinrtXrwgwUXNOaM_AGin2iEMqN2wWciMzJUPUyB@mail.gmail.com>
Subject: Re: RFC: reviving mlock isolation dead code
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 8, 2010 at 8:34 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> While in airplane to come back from KS and LPC, I was thinking this issue=
. now I think
> we can solve this issue. can you please hear my idea?

I have been having similar thoughts over the past week. I'll try to
send a related patch set soon.

> Now, mlock has following call flow
>
> sys_mlock
> =A0 =A0 =A0 =A0down_write(mmap_sem)
> =A0 =A0 =A0 =A0do_mlock()
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0for-each-vma
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mlock_fixup()
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__mlock_vm=
a_pages_range()
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0__get_user_pages()
> =A0 =A0 =A0 =A0up_write(mmap_sem)
>
> Then, I'd propose two phase mlock. that said,
>
> sys_mlock
>        down_write(mmap_sem)
>        do_mlock()
>                for-each-vma
>                        turn on VM_LOCKED and merge/split vma
>        downgrade_write(mmap_sem)
>                for-each-vma
>                        mlock_fixup()
>                                __mlock_vma_pages_range()
>        up_read(mmap_sem)
>
> Usually, kernel developers strongly dislike two phase thing beucase it's =
slow. but at least
> _I_ think it's ok in this case. because mlock is really really slow sysca=
ll, it often take a few
> *miniture*. then, A few microsecond slower is not big matter.
>
> What do you think?

downgrade_write() would help, but only partially. If another thread
tries to acquire the mmap_sem for write, it will get queued for a long
time until mlock() completes - this may in itself be acceptable, but
the issue here is that additional readers like try_to_unmap_one()
won't be able to acquire the mmap_sem anymore. This is because the
rwsem code prevents new readers from entering once there is a queued
writer, in order to avoid starvation.

My proposal would be as follows:

sys_mlock
       down_write(mmap_sem)
       do_mlock()
               for-each-vma
                       turn on VM_LOCKED and merge/split vma
       up_write(mmap_sem)
       for (addr =3D start of mlock range; addr < end of mlock range;
addr =3D next_addr)
               down_read(mmap_sem)
               find vma for addr
               next_addr =3D end of the vma
               if vma still has VM_LOCKED flag:
                       next_addr =3D min(next_addr, addr + few pages)
                       mlock a small batch of pages from that vma
(from addr to next_addr)
               up_read(mmap_sem)

Since a large mlock() can take a long time and we don't want to hold
mmap_sem for that long, we have to allow other threads to grab
mmap_sem and deal with the concurrency issues.

The races aren't actually too bad:

* If some other thread creates new VM_LOCKED vmas within the mlock
range while sys_mlock() is working: both threads will be trying to
mlock_fixup the same page range at once. This is no big deal as
__mlock_vma_pages_range already only needs mmap_sem held for read: the
get_user_pages() part can safely proceed in parallel and the
mlock_vma_page() part is protected by the page lock and won't do
anything if the PageMlocked flag is already set.

* If some other thread creates new non-VM_LOCKED vmas, or munlocks the
same address ranges that mlock() is currently working on: the mlock()
code needs to be careful here to not mlock the pages when the vmas
don't have the VM_LOCKED flag anymore. From the user process point of
view, things will look like if the mlock had completed first, followed
by the munlock.

The other mlock related issue I have is that it marks pages as dirty
(if they are in a writable VMA), and causes writeback to work on them,
even though the pages have not actually been modified. This looks like
it would be solvable with a new get_user_pages flag for mlock use
(breaking cow etc, but not writing to the pages just yet).

--=20
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
