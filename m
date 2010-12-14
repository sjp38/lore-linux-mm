Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0BD586B008A
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 20:26:58 -0500 (EST)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id oBE1QsCW027108
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 17:26:55 -0800
Received: from iwn6 (iwn6.prod.google.com [10.241.68.70])
	by wpaz5.hot.corp.google.com with ESMTP id oBE1Qrpa025636
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 17:26:53 -0800
Received: by iwn6 with SMTP id 6so168200iwn.15
        for <linux-mm@kvack.org>; Mon, 13 Dec 2010 17:26:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101213170526.3b010058.akpm@linux-foundation.org>
References: <1291335412-16231-1-git-send-email-walken@google.com>
	<1291335412-16231-2-git-send-email-walken@google.com>
	<20101208152740.ac449c3d.akpm@linux-foundation.org>
	<AANLkTikYZi0=c+yM1p8H18u+9WVbsQXjAinUWyNt7x+t@mail.gmail.com>
	<AANLkTinY0pcTcd+OxPLyvsJgHgh=cTaB1-8VbEA2tstb@mail.gmail.com>
	<20101214005140.GA29904@google.com>
	<20101213170526.3b010058.akpm@linux-foundation.org>
Date: Mon, 13 Dec 2010 17:26:27 -0800
Message-ID: <AANLkTin4-u8aA-KBA60xAmeBDg9BUvRp2sUieTkDcRhb@mail.gmail.com>
Subject: Re: [PATCH 1/6] mlock: only hold mmap_sem in shared mode when
 faulting in pages
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Nick Piggin <npiggin@kernel.dk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Dec 13, 2010 at 5:05 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Mon, 13 Dec 2010 16:51:40 -0800
> Michel Lespinasse <walken@google.com> wrote:
>> Andrew, should I amend my patches to remove the rwsem_is_contended() cod=
e ?
>> This would involve:
>> - remove rwsem-implement-rwsem_is_contended.patch and
>> =A0 x86-rwsem-more-precise-rwsem_is_contended-implementation.patch
>> - in mlock-do-not-hold-mmap_sem-for-extended-periods-of-time.patch,
>> =A0 drop the one hunk making use of rwsem_is_contended (rest of the patc=
h
>> =A0 would still work without it)
>
> I think I fixed all that up.

Thanks!

>> - optionally, follow up patch to limit batch size to a constant
>> =A0 in do_mlock_pages():
[... diff snipped ...]
>> I don't really prefer using a constant, but I'm not sure how else to mak=
e
>> Linus happy :)
>
> rwsem_is_contended() didn't seem so bad to me.
>
> Reading 1024 pages can still take a long time. =A0I can't immediately
> think of a better approach though.

Note that we're only concerned page cache hist here, as
__get_user_pages with non-NULL nonblocking argument will release
mmap_sem when blocking on disk. So time per page is somewhat constant
- we don't need to worry about disk seeks at least.

--=20
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
