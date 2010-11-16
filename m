Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A9A9C8D0080
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 01:51:08 -0500 (EST)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id oAG6p5I5010894
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 22:51:05 -0800
Received: from qyk33 (qyk33.prod.google.com [10.241.83.161])
	by wpaz1.hot.corp.google.com with ESMTP id oAG6oeYt002983
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 22:51:03 -0800
Received: by qyk33 with SMTP id 33so397645qyk.2
        for <linux-mm@kvack.org>; Mon, 15 Nov 2010 22:50:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1011151717130.10920@tigran.mtv.corp.google.com>
References: <20101109115540.BC3F.A69D9226@jp.fujitsu.com>
	<AANLkTinrtXrwgwUXNOaM_AGin2iEMqN2wWciMzJUPUyB@mail.gmail.com>
	<20101112142038.E002.A69D9226@jp.fujitsu.com>
	<alpine.LSU.2.00.1011151717130.10920@tigran.mtv.corp.google.com>
Date: Mon, 15 Nov 2010 22:50:59 -0800
Message-ID: <AANLkTin+16yDxGrRfbqw9OPnDDV8OgXr_nbZnXJEHK9w@mail.gmail.com>
Subject: Re: RFC: reviving mlock isolation dead code
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 15, 2010 at 5:44 PM, Hugh Dickins <hughd@google.com> wrote:
> On Sun, 14 Nov 2010, KOSAKI Motohiro wrote:
>> Michel Lespinasse <walken@google.com> wrote:
>> > ...
>> > The other mlock related issue I have is that it marks pages as dirty
>> > (if they are in a writable VMA), and causes writeback to work on them,
>> > even though the pages have not actually been modified. This looks like
>> > it would be solvable with a new get_user_pages flag for mlock use
>> > (breaking cow etc, but not writing to the pages just yet).
>>
>> To be honest, I haven't understand why current code does so. I dislike i=
t too. but
>> I'm not sure such change is safe or not. I hope another developer commen=
t you ;-)
>
> It's been that way for years, and the primary purpose is to do the COWs
> in advance, so we won't need to allocate new pages later to the locked
> area: the pages that may be needed are already locked down.

Thanks Hugh for posting your comments. I was aware of Suleiman's
proposal to always do a READ mode get_user_pages years ago, and I
could see that we'd need a new flag instead so we can break COW
without dirtying pages, but I hadn't thought about other issues.

> That justifies it for the private mapping case, but what of shared maps?
> There the justification is that the underlying file might be sparse, and
> we want to allocate blocks upfront for the locked area.
>
> Do we? =A0I dislike it also, as you both do. =A0It seems crazy to mark a
> vast number of pages as dirty when they're not.
>
> It makes sense to mark pte_dirty when we have a real write fault to a
> page, to save the mmu from making that pagetable transaction immediately
> after; but it does not make sense when the write (if any) may come
> minutes later - we'll just do a pointless write and clear dirty meanwhile=
