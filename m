Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 292646B006A
	for <linux-mm@kvack.org>; Fri,  8 Oct 2010 16:06:24 -0400 (EDT)
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id o98K6LXM001832
	for <linux-mm@kvack.org>; Fri, 8 Oct 2010 13:06:21 -0700
Received: from qyk9 (qyk9.prod.google.com [10.241.83.137])
	by kpbe13.cbf.corp.google.com with ESMTP id o98K6JpQ003669
	for <linux-mm@kvack.org>; Fri, 8 Oct 2010 13:06:19 -0700
Received: by qyk9 with SMTP id 9so343376qyk.9
        for <linux-mm@kvack.org>; Fri, 08 Oct 2010 13:06:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4CAF1B90.3080703@redhat.com>
References: <1286265215-9025-1-git-send-email-walken@google.com>
	<1286265215-9025-3-git-send-email-walken@google.com>
	<4CAB628D.3030205@redhat.com>
	<AANLkTimdACZ9Xm01DM2+E64+T5XfLffrkFBhf7CJ286p@mail.gmail.com>
	<20101008043956.GA25662@google.com>
	<4CAF1B90.3080703@redhat.com>
Date: Fri, 8 Oct 2010 13:06:18 -0700
Message-ID: <AANLkTinWxTT=+m_fAudc080OUMwacSefnMbSMBFZgPMH@mail.gmail.com>
Subject: Re: [PATCH 2/3] Retry page fault when blocking on disk transfer.
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Ying Han <yinghan@google.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 8, 2010 at 6:24 AM, Rik van Riel <riel@redhat.com> wrote:
>> +static inline int lock_page_or_retry(struct page *page, struct mm_struc=
t
>> *mm,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0unsigned int flags)
>> +{
>> + =A0 =A0 =A0 if (trylock_page(page))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
>> + =A0 =A0 =A0 if (!(flags& =A0FAULT_FLAG_ALLOW_RETRY)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __lock_page(page);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
>> + =A0 =A0 =A0 }
>> +
>> + =A0 =A0 =A0 up_read(&mm->mmap_sem);
>> + =A0 =A0 =A0 wait_on_page_locked(page);
>> + =A0 =A0 =A0 return 0;
>> +}
>
> Wait a moment. =A0Your other patch 2/3 also has a
> lock_page_or_retry function. =A0That one is in
> filemap.c and takes slightly different arguments,
> to do essentially the same thing...
>
> +/*
> + * Lock the page, unless this would block and the caller indicated that =
it
> + * can handle a retry.
> + */
> +static int lock_page_or_retry(struct page *page,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct vm_area_=
struct *vma, struct vm_fault
> *vmf)
> +{
>
> Is there a way the two functions can be merged
> into one?

Yes, this would be easy to do.

The argument against it would be loss of inlining and, in the filemap
version, the need to reference vma and vmf fields to find out the mm
and flags values. We'd like to avoid doing that at least in the fast
path when trylock_page succeeds - though, now that I think about it,
both could be avoided with an inline function in a header returning
trylock_page(page) || _lock_page_or_retry(mm, flags)

Hmmm, this is actually quite similar to how other functions in
pagemap.h / filemap.c are done...
I'll send an updated series using this suggestion.

--=20
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
