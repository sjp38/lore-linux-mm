Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 036176B0011
	for <linux-mm@kvack.org>; Wed,  4 May 2011 21:18:15 -0400 (EDT)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id p451ICXv028549
	for <linux-mm@kvack.org>; Wed, 4 May 2011 18:18:12 -0700
Received: from gyf1 (gyf1.prod.google.com [10.243.50.65])
	by hpaq6.eem.corp.google.com with ESMTP id p451IA3p005065
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 4 May 2011 18:18:11 -0700
Received: by gyf1 with SMTP id 1so844605gyf.34
        for <linux-mm@kvack.org>; Wed, 04 May 2011 18:18:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTim_QtaQLa9GV5hMZyCmW_WAz_Ucvg@mail.gmail.com>
References: <alpine.LSU.2.00.1102232136020.2239@sister.anvils>
	<AANLkTi==MQV=_qq1HaCxGLRu8DdT6FYddqzBkzp1TQs7@mail.gmail.com>
	<AANLkTimv66fV1+JDqSAxRwddvy_kggCuhoJLMTpMTtJM@mail.gmail.com>
	<alpine.LSU.2.00.1103182158200.18771@sister.anvils>
	<BANLkTinoNMudwkcOOgU5d+imPUfZhDbWWQ@mail.gmail.com>
	<AANLkTimfArmB7judMW7Qd4ATtVaR=yTf_-0DBRAfCJ7w@mail.gmail.com>
	<BANLkTi=Limr3NUaG7RLoQLv5TuEDmm7Rqg@mail.gmail.com>
	<BANLkTi=UZcocVk_16MbbV432g9a3nDFauA@mail.gmail.com>
	<BANLkTi=KTdLRC_hRvxfpFoMSbz=vOjpObw@mail.gmail.com>
	<BANLkTindeX9-ECPjgd_V62ZbXCd7iEG9_w@mail.gmail.com>
	<BANLkTikcZK+AQvwe2ED=b0dLZ0hqg0B95w@mail.gmail.com>
	<BANLkTimV1f1YDTWZUU9uvAtCO_fp6EKH9Q@mail.gmail.com>
	<BANLkTi=tavhpytcSV+nKaXJzw19Bo3W9XQ@mail.gmail.com>
	<alpine.LSU.2.00.1104060837590.4909@sister.anvils>
	<BANLkTi=-Zb+vrQuY6J+dAMsmz+cQDD-KUw@mail.gmail.com>
	<BANLkTim0MZfa8vFgHB3W6NsoPHp2jfirrA@mail.gmail.com>
	<BANLkTim-hyXpLj537asC__8exMo3o-WCLA@mail.gmail.com>
	<alpine.LSU.2.00.1104070718120.28555@sister.anvils>
	<BANLkTik_9YW5+64FHrzNy7kPz1FUWrw-rw@mail.gmail.com>
	<BANLkTiniyAN40p0q+2wxWsRZ5PJFn9zE0Q@mail.gmail.com>
	<BANLkTik6U21r91DYiUsz9A0P--=5QcsBrA@mail.gmail.com>
	<BANLkTim6ATGxTiMcfK5-03azgcWuT4wtJA@mail.gmail.com>
	<BANLkTiktvcBWsLKEk5iBYVEbPJS3i+U+hA@mail.gmail.com>
	<BANLkTikdM2kF=qOy4d4bZ_wfb5ykEdkZPQ@mail.gmail.com>
	<BANLkTikZ1szdH5HZdjKEEzG2+1VPusWEeg@mail.gmail.com>
	<BANLkTingV3eiHEco+36YyM4YTDHFHc9_jA@mail.gmail.com>
	<BANLkTi=D+oe_zyxA1Oj5S36F6Tk0J+26iQ@mail.gmail.com>
	<BANLkTim_QtaQLa9GV5hMZyCmW_WAz_Ucvg@mail.gmail.com>
Date: Wed, 4 May 2011 18:18:09 -0700
Message-ID: <BANLkTik-s3Gr6GDMN4L24wX2BK9n3okzQA@mail.gmail.com>
Subject: Re: [PATCH] mm: fix possible cause of a page_mapped BUG
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: =?UTF-8?B?Um9iZXJ0IMWad2nEmWNraQ==?= <robert@swiecki.net>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Miklos Szeredi <miklos@szeredi.hu>, "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>

On Wed, May 4, 2011 at 5:38 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>> A more conservative alternative could
>> be to enable the guard page special case under an new GUP flag, but
>> this loses much of the elegance of your original proposal...
>
> How about only doing that only for FOLL_MLOCK?

Sounds reasonable.

> Also, looking at mm/mlock.c, why _do_ we call get_user_pages() even if
> the vma isn't mlocked? That looks bogus. Since we have dropped the
> mm_semaphore, an unlock may have happened, and afaik we should *not*
> try to bring those pages back in at all. There's this whole comment
> about that in the caller ("__mlock_vma_pages_range() double checks the
> vma flags, so that it won't mlock pages if the vma was already
> munlocked."), but despite that it would actually call
> __get_user_pages() even if the VM_LOCKED bit had been cleared (it just
> wouldn't call it with the FOLL_MLOCK flag).

There are two reasons VM_LOCKED might be cleared in
__mlock_vma_pages_range(). It could be that one of the VM_SPECIAL
flags were set on the VMA, in which case mlock() won't set VM_LOCKED
but it still must make the pages present. Or, there is an munlock()
executing concurrently with mlock() - in that case, the conservative
thing to do is to give the same results as if the mlock() had
completed before the munlock(). That is, the mlock() would have broken
COW / made the pages present and the munlock() would have cleared the
VM_LOCKED and PageMlocked flags.

> UNTESTED! And maybe there was some really subtle reason to still call
> __get_user_pages() without that FOLL_MLOCK thing that I'm missing.

I think we want the mm/memory.c part of this proposal without the
mm/mlock.c part.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
