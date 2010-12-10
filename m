Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 61A366B0087
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 01:39:33 -0500 (EST)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id oBA6dUfT006583
	for <linux-mm@kvack.org>; Thu, 9 Dec 2010 22:39:30 -0800
Received: from qyk27 (qyk27.prod.google.com [10.241.83.155])
	by kpbe20.cbf.corp.google.com with ESMTP id oBA6dLJg015030
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 9 Dec 2010 22:39:29 -0800
Received: by qyk27 with SMTP id 27so2983741qyk.1
        for <linux-mm@kvack.org>; Thu, 09 Dec 2010 22:39:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <AANLkTinY0pcTcd+OxPLyvsJgHgh=cTaB1-8VbEA2tstb@mail.gmail.com>
References: <1291335412-16231-1-git-send-email-walken@google.com>
	<1291335412-16231-2-git-send-email-walken@google.com>
	<20101208152740.ac449c3d.akpm@linux-foundation.org>
	<AANLkTikYZi0=c+yM1p8H18u+9WVbsQXjAinUWyNt7x+t@mail.gmail.com>
	<AANLkTinY0pcTcd+OxPLyvsJgHgh=cTaB1-8VbEA2tstb@mail.gmail.com>
Date: Thu, 9 Dec 2010 22:39:29 -0800
Message-ID: <AANLkTikXx4MgdPYWYNVj8cMOSHTHJEUHqKZ_q-P4jFYp@mail.gmail.com>
Subject: Re: [PATCH 1/6] mlock: only hold mmap_sem in shared mode when
 faulting in pages
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Nick Piggin <npiggin@kernel.dk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 9, 2010 at 10:11 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Wednesday, December 8, 2010, Michel Lespinasse <walken@google.com> wrote:
>> Yes, patch 1/6 changes the long hold time to be in read mode instead
>> of write mode, which is only a band-aid. But, this prepares for patch
>> 5/6, which releases mmap_sem whenever there is contention on it or
>> when blocking on disk reads.
>
> I have to say that I'm not a huge fan of that horribly kludgy
> contention check case.
>
> The "move page-in to read-locked sequence" and the changes to
> get_user_pages look fine, but the contention thing is just disgusting.
> I'd really like to see some other approach if at all possible.

Are you OK with the part of patch 5/6 that drops mmap_sem when
blocking on disk ?

This by itself brings mmap_sem hold time down to a few seconds. Plus,
I could add something to limit the interval passed to
__mlock_vma_pages_range to a thousand pages or so, so that the hold
time would then be bounded by that constant.

I think rwsem_is_contended() actually sounds better than fiddling with
constants, but OTOH maybe the mlock use case is not significant enough
to justify introducing that new API.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
