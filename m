Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A8C3A8D003B
	for <linux-mm@kvack.org>; Wed,  6 Apr 2011 11:43:53 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id p36FhpIh000581
	for <linux-mm@kvack.org>; Wed, 6 Apr 2011 08:43:51 -0700
Received: from iyb26 (iyb26.prod.google.com [10.241.49.90])
	by wpaz5.hot.corp.google.com with ESMTP id p36FhZZI025277
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 6 Apr 2011 08:43:50 -0700
Received: by iyb26 with SMTP id 26so1664641iyb.26
        for <linux-mm@kvack.org>; Wed, 06 Apr 2011 08:43:50 -0700 (PDT)
Date: Wed, 6 Apr 2011 08:43:43 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: fix possible cause of a page_mapped BUG
In-Reply-To: <BANLkTi=tavhpytcSV+nKaXJzw19Bo3W9XQ@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1104060837590.4909@sister.anvils>
References: <alpine.LSU.2.00.1102232136020.2239@sister.anvils> <AANLkTi==MQV=_qq1HaCxGLRu8DdT6FYddqzBkzp1TQs7@mail.gmail.com> <AANLkTimv66fV1+JDqSAxRwddvy_kggCuhoJLMTpMTtJM@mail.gmail.com> <alpine.LSU.2.00.1103182158200.18771@sister.anvils>
 <BANLkTinoNMudwkcOOgU5d+imPUfZhDbWWQ@mail.gmail.com> <AANLkTimfArmB7judMW7Qd4ATtVaR=yTf_-0DBRAfCJ7w@mail.gmail.com> <BANLkTi=Limr3NUaG7RLoQLv5TuEDmm7Rqg@mail.gmail.com> <BANLkTi=UZcocVk_16MbbV432g9a3nDFauA@mail.gmail.com> <BANLkTi=KTdLRC_hRvxfpFoMSbz=vOjpObw@mail.gmail.com>
 <BANLkTindeX9-ECPjgd_V62ZbXCd7iEG9_w@mail.gmail.com> <BANLkTikcZK+AQvwe2ED=b0dLZ0hqg0B95w@mail.gmail.com> <BANLkTimV1f1YDTWZUU9uvAtCO_fp6EKH9Q@mail.gmail.com> <BANLkTi=tavhpytcSV+nKaXJzw19Bo3W9XQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-1940525975-1302104641=:4909"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, =?ISO-8859-2?Q?Robert_=A6wi=EAcki?= <robert@swiecki.net>, Andrew Morton <akpm@linux-foundation.org>, Miklos Szeredi <miklos@szeredi.hu>, Michel Lespinasse <walken@google.com>, "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-1940525975-1302104641=:4909
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Wed, 6 Apr 2011, Linus Torvalds wrote:
> On Wed, Apr 6, 2011 at 7:47 AM, Hugh Dickins <hughd@google.com> wrote:
> >>
> >> I dunno. But that odd negative pg_off thing makes me think there is
> >> some overflow issue (ie HEAP_INDEX being pg_off + size ends up
> >> fluctuating between really big and really small). So I'd suspect THAT
> >> as the main reason.
> >
> > Yes, one of the vmas is such that the end offset (pgoff of next page
> > after) would be 0, and for the other it would be 16. =A0There's sure to
> > be places, inside the prio_tree code and outside it, where we rely
> > upon pgoff not wrapping around - wrap should be prevented by original
> > validation of arguments.
>=20
> Well, we _do_ validate them in do_mmap_pgoff(), which is the main
> routine for all the mmap() system calls, and the main way to get a new
> mapping.
>=20
> There are other ways, like do_brk(), but afaik that always sets
> vm_pgoff to the virtual address (shifted), so again the new mapping
> should be fine.
>=20
> So when a new mapping is created, it should all be ok.
>=20
> But I think mremap() may end up expanding it without doing the same
> overflow check.
>=20
> Do you see any other way to get this situation? Does the vma dump give
> you any hint about where it came from?
>=20
> Robert - here's a (UNTESTED!) patch to make mremap() be a bit more
> careful about vm_pgoff when growing a mapping. Does it make any
> difference?

I'd come to the same conclusion: the original page_mapped BUG has itself
suggested that mremap() is getting used.

I was about to send you my own UNTESTED patch: let me append it anyway,
I think it is more correct than yours (it's the offset of vm_end we need
to worry about, and there's the funny old_len,new_len stuff).  See what
you think - sorry, I'm going out now.

Hugh

--- 2.6.38/mm/mremap.c=092011-03-14 18:20:32.000000000 -0700
+++ linux/mm/mremap.c=092011-04-06 08:31:46.000000000 -0700
@@ -282,6 +282,12 @@ static struct vm_area_struct *vma_to_res
 =09=09=09goto Efault;
 =09}
=20
+=09if (vma->vm_file && new_len > old_len) {
+=09=09pgoff_t endoff =3D linear_page_index(vma, vma->vm_end);
+=09=09if (endoff + ((new_len - old_len) >> PAGE_SHIFT) < endoff)
+=09=09=09goto Eoverflow;
+=09}
+
 =09if (vma->vm_flags & VM_LOCKED) {
 =09=09unsigned long locked, lock_limit;
 =09=09locked =3D mm->locked_vm << PAGE_SHIFT;
@@ -311,6 +317,8 @@ Enomem:
 =09return ERR_PTR(-ENOMEM);
 Eagain:
 =09return ERR_PTR(-EAGAIN);
+Eoverflow:
+=09return ERR_PTR(-EOVERFLOW);
 }
=20
 static unsigned long mremap_to(unsigned long addr,
--8323584-1940525975-1302104641=:4909--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
