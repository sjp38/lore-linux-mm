Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 5EE1F8D0001
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 00:07:14 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAE57BOU019516
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sun, 14 Nov 2010 14:07:12 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A05C745DE51
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 14:07:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 68EBB45DE6D
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 14:07:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 28F5D1DB803C
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 14:07:11 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C12091DB8038
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 14:07:10 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: RFC: reviving mlock isolation dead code
In-Reply-To: <AANLkTinrtXrwgwUXNOaM_AGin2iEMqN2wWciMzJUPUyB@mail.gmail.com>
References: <20101109115540.BC3F.A69D9226@jp.fujitsu.com> <AANLkTinrtXrwgwUXNOaM_AGin2iEMqN2wWciMzJUPUyB@mail.gmail.com>
Message-Id: <20101112142038.E002.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Date: Sun, 14 Nov 2010 14:07:10 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Michel Lespinasse <walken@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi

> My proposal would be as follows:
>=20
> sys_mlock
>        down_write(mmap_sem)
>        do_mlock()
>                for-each-vma
>                        turn on VM_LOCKED and merge/split vma
>        up_write(mmap_sem)
>        for (addr =3D start of mlock range; addr < end of mlock range;
> addr =3D next_addr)
>                down_read(mmap_sem)
>                find vma for addr
>                next_addr =3D end of the vma
>                if vma still has VM_LOCKED flag:
>                        next_addr =3D min(next_addr, addr + few pages)
>                        mlock a small batch of pages from that vma
> (from addr to next_addr)
>                up_read(mmap_sem)
>=20
> Since a large mlock() can take a long time and we don't want to hold
> mmap_sem for that long, we have to allow other threads to grab
> mmap_sem and deal with the concurrency issues.

Sound good.
Can you please consider to post actual patch?


> The races aren't actually too bad:
>=20
> * If some other thread creates new VM_LOCKED vmas within the mlock
> range while sys_mlock() is working: both threads will be trying to
> mlock_fixup the same page range at once. This is no big deal as
> __mlock_vma_pages_range already only needs mmap_sem held for read: the
> get_user_pages() part can safely proceed in parallel and the
> mlock_vma_page() part is protected by the page lock and won't do
> anything if the PageMlocked flag is already set.
>=20
> * If some other thread creates new non-VM_LOCKED vmas, or munlocks the
> same address ranges that mlock() is currently working on: the mlock()
> code needs to be careful here to not mlock the pages when the vmas
> don't have the VM_LOCKED flag anymore. From the user process point of
> view, things will look like if the mlock had completed first, followed
> by the munlock.

Yes, here is really key point. If user can't notice the race, it doesn't ex=
ist practically.


> The other mlock related issue I have is that it marks pages as dirty
> (if they are in a writable VMA), and causes writeback to work on them,
> even though the pages have not actually been modified. This looks like
> it would be solvable with a new get_user_pages flag for mlock use
> (breaking cow etc, but not writing to the pages just yet).

To be honest, I haven't understand why current code does so. I dislike it t=
oo. but
I'm not sure such change is safe or not. I hope another developer comment y=
ou ;-)




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
