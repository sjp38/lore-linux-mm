Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8FBBD6B015B
	for <linux-mm@kvack.org>; Sat, 30 Oct 2010 08:48:43 -0400 (EDT)
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id o9UCmcj6014065
	for <linux-mm@kvack.org>; Sat, 30 Oct 2010 05:48:39 -0700
Received: from vws19 (vws19.prod.google.com [10.241.21.147])
	by kpbe13.cbf.corp.google.com with ESMTP id o9UCmaES019000
	for <linux-mm@kvack.org>; Sat, 30 Oct 2010 05:48:37 -0700
Received: by vws19 with SMTP id 19so1438172vws.26
        for <linux-mm@kvack.org>; Sat, 30 Oct 2010 05:48:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTik4NM5YOgh48bOWDQZuUKmEHLH6Ja10eOzn-_tj@mail.gmail.com>
References: <AANLkTik4NM5YOgh48bOWDQZuUKmEHLH6Ja10eOzn-_tj@mail.gmail.com>
Date: Sat, 30 Oct 2010 05:48:36 -0700
Message-ID: <AANLkTikrgUhVNqM0OmZAjA-YXn_WRNPpdtFWKB+H3iDR@mail.gmail.com>
Subject: Re: RFC: reviving mlock isolation dead code
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, Oct 30, 2010 at 3:16 AM, Michel Lespinasse <walken@google.com> wrot=
e:
> The following code at the bottom of try_to_unmap_one appears to be dead:
>
> =A0out_mlock:
> =A0 =A0 =A0 =A0pte_unmap_unlock(pte, ptl);
>
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * We need mmap_sem locking, Otherwise VM_LOCKED check mak=
es
> =A0 =A0 =A0 =A0 * unstable result and race. Plus, We can't wait here beca=
use
> =A0 =A0 =A0 =A0 * we now hold anon_vma->lock or mapping->i_mmap_lock.
> =A0 =A0 =A0 =A0 * if trylock failed, the page remain in evictable lru and=
 later
> =A0 =A0 =A0 =A0 * vmscan could retry to move the page to unevictable lru =
if the
> =A0 =A0 =A0 =A0 * page is actually mlocked.
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0if (down_read_trylock(&vma->vm_mm->mmap_sem)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (vma->vm_flags & VM_LOCKED) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mlock_vma_page(page);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D SWAP_MLOCK;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0up_read(&vma->vm_mm->mmap_sem);
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0return ret;

All right, not entirely dead - Documentation/vm/unevictable-lru.txt
actually explains this very well.

But still, the problem remains that lazy mlocking doesn't work while
mmap_sem is exclusively held by a long-running mlock().

> One approach I am considering would be to modify
> __mlock_vma_pages_range() and it call sites so the mmap sem is only
> read-owned while __mlock_vma_pages_range() runs. The mlock handling
> code in try_to_unmap_one() would then be able to acquire the
> mmap_sem() and help, as it is designed to do.

I'm still looking for any comments people might have about this :)

--=20
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
