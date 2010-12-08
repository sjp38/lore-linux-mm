Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A0B046B0087
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 18:58:25 -0500 (EST)
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id oB8NwNFs006073
	for <linux-mm@kvack.org>; Wed, 8 Dec 2010 15:58:23 -0800
Received: from qwh6 (qwh6.prod.google.com [10.241.194.198])
	by hpaq13.eem.corp.google.com with ESMTP id oB8NwLus023591
	for <linux-mm@kvack.org>; Wed, 8 Dec 2010 15:58:22 -0800
Received: by qwh6 with SMTP id 6so1949310qwh.35
        for <linux-mm@kvack.org>; Wed, 08 Dec 2010 15:58:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101208152740.ac449c3d.akpm@linux-foundation.org>
References: <1291335412-16231-1-git-send-email-walken@google.com>
	<1291335412-16231-2-git-send-email-walken@google.com>
	<20101208152740.ac449c3d.akpm@linux-foundation.org>
Date: Wed, 8 Dec 2010 15:58:21 -0800
Message-ID: <AANLkTikYZi0=c+yM1p8H18u+9WVbsQXjAinUWyNt7x+t@mail.gmail.com>
Subject: Re: [PATCH 1/6] mlock: only hold mmap_sem in shared mode when
 faulting in pages
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Nick Piggin <npiggin@kernel.dk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 8, 2010 at 3:27 PM, Andrew Morton <akpm@linux-foundation.org> w=
rote:
>> Currently mlock() holds mmap_sem in exclusive mode while the pages get
>> faulted in. In the case of a large mlock, this can potentially take a
>> very long time, during which various commands such as 'ps auxw' will
>> block. This makes sysadmins unhappy:
>>
>> real =A0 =A014m36.232s
>> user =A0 =A00m0.003s
>> sys =A0 =A0 0m0.015s
>>(output from 'time ps auxw' while a 20GB file was being mlocked without
>> being previously preloaded into page cache)
>
> The kernel holds down_write(mmap_sem) for 14m36s?

Yes...

[... patch snipped off ...]

> Am I correct in believing that we'll still hold down_read(mmap_sem) for
> a quarter hour?

Yes, patch 1/6 changes the long hold time to be in read mode instead
of write mode, which is only a band-aid. But, this prepares for patch
5/6, which releases mmap_sem whenever there is contention on it or
when blocking on disk reads.

> We don't need to hold mmap_sem at all while faulting in those pages,
> do we? =A0We could just do
>
> =A0 =A0 =A0 =A0for (addr =3D start, addr < end; addr +=3D PAGE_SIZE)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0get_user(x, addr);
>
> and voila. =A0If the pages are in cache and the ptes are set up then that
> will be *vastly* faster than the proposed code. =A0If the get_user()
> takes a minor fault then it'll be slower. =A0If it's a major fault then
> the difference probably doesn't matter much.

get_user wouldn't suffice if the page is already mapped in, as we need
to mark it as PageMlocked. Also, we need to skip IO and PFNMAP
regions. I don't think you can make things much simpler than what I
ended up with.

> But whatever. =A0Is this patchset a half-fix, and should we rather be
> looking for a full-fix?

I think the series fully fixes the mlock() and mlockall() cases, which
has been the more pressing use case for us.

Even then, there are still cases where we could still observe long
mmap_sem hold times - fundamentally, every place that calls
get_user_pages (or do_mmap, in the mlockall MCL_FUTURE case) with a
large page range may create such problems. From the looks of it, most
of these places wouldn't actually care if the mmap_sem got dropped in
the middle of the operation, but a general fix will have to involve
looking at all the call sites to be sure.

--=20
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
