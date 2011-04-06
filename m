Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 2F51E8D003B
	for <linux-mm@kvack.org>; Wed,  6 Apr 2011 12:00:17 -0400 (EDT)
Received: from mail-iw0-f169.google.com (mail-iw0-f169.google.com [209.85.214.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p36FxjRj012167
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Wed, 6 Apr 2011 08:59:45 -0700
Received: by iwg8 with SMTP id 8so2188264iwg.14
        for <linux-mm@kvack.org>; Wed, 06 Apr 2011 08:59:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1104060837590.4909@sister.anvils>
References: <alpine.LSU.2.00.1102232136020.2239@sister.anvils>
 <AANLkTi==MQV=_qq1HaCxGLRu8DdT6FYddqzBkzp1TQs7@mail.gmail.com>
 <AANLkTimv66fV1+JDqSAxRwddvy_kggCuhoJLMTpMTtJM@mail.gmail.com>
 <alpine.LSU.2.00.1103182158200.18771@sister.anvils> <BANLkTinoNMudwkcOOgU5d+imPUfZhDbWWQ@mail.gmail.com>
 <AANLkTimfArmB7judMW7Qd4ATtVaR=yTf_-0DBRAfCJ7w@mail.gmail.com>
 <BANLkTi=Limr3NUaG7RLoQLv5TuEDmm7Rqg@mail.gmail.com> <BANLkTi=UZcocVk_16MbbV432g9a3nDFauA@mail.gmail.com>
 <BANLkTi=KTdLRC_hRvxfpFoMSbz=vOjpObw@mail.gmail.com> <BANLkTindeX9-ECPjgd_V62ZbXCd7iEG9_w@mail.gmail.com>
 <BANLkTikcZK+AQvwe2ED=b0dLZ0hqg0B95w@mail.gmail.com> <BANLkTimV1f1YDTWZUU9uvAtCO_fp6EKH9Q@mail.gmail.com>
 <BANLkTi=tavhpytcSV+nKaXJzw19Bo3W9XQ@mail.gmail.com> <alpine.LSU.2.00.1104060837590.4909@sister.anvils>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 6 Apr 2011 08:59:19 -0700
Message-ID: <BANLkTi=-Zb+vrQuY6J+dAMsmz+cQDD-KUw@mail.gmail.com>
Subject: Re: [PATCH] mm: fix possible cause of a page_mapped BUG
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: =?UTF-8?B?Um9iZXJ0IMWad2nEmWNraQ==?= <robert@swiecki.net>, Andrew Morton <akpm@linux-foundation.org>, Miklos Szeredi <miklos@szeredi.hu>, Michel Lespinasse <walken@google.com>, "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>

On Wed, Apr 6, 2011 at 8:43 AM, Hugh Dickins <hughd@google.com> wrote:
>
> I was about to send you my own UNTESTED patch: let me append it anyway,
> I think it is more correct than yours (it's the offset of vm_end we need
> to worry about, and there's the funny old_len,new_len stuff).

Umm. That's what my patch did too. The

   pgoff =3D (addr - vma->vm_start) >> PAGE_SHIFT;

is the "offset of the pgoff" from the original mapping, then we do

   pgoff +=3D vma->vm_pgoff;

to get the pgoff of the new mapping, and then we do

   if (pgoff + (new_len >> PAGE_SHIFT) < pgoff)

to check that the new mapping is ok.

I think yours is equivalent, just a different (and odd - that
linear_page_index() thing will do lots of unnecessary shifts and
hugepage crap) way of writing it.

>=A0See what you think - sorry, I'm going out now.

I think _yours_ is conceptually buggy, because I think that test for
"vma->vm_file" is wrong.

Yes, new anonymous mappings set vm_pgoff to the virtual address, but
that's not true for mremap() moving them around, afaik.

Admittedly it's really hard to get to the overflow case, because the
address is shifted down, so even if you start out with an anonymous
mmap at a high address (to get a big vm_off), and then move it down
and expand it (to get a big size), I doubt you can possibly overflow.
But I still don't think that the test for vm_file is semantically
sensible, even if it might not _matter_.

But whatever. I suspect both our patches are practically doing the
same thing, and it would be interesting to hear if it actually fixes
the issue. Maybe there is some other way to mess up vm_pgoff that I
can't think of right now.

                                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
