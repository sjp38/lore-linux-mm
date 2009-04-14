Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B2A475F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 09:39:18 -0400 (EDT)
Received: by wf-out-1314.google.com with SMTP id 25so2322815wfa.11
        for <linux-mm@kvack.org>; Tue, 14 Apr 2009 06:39:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <200904142225.10788.nickpiggin@yahoo.com.au>
References: <20090414151204.C647.A69D9226@jp.fujitsu.com>
	 <200904141925.46012.nickpiggin@yahoo.com.au>
	 <2f11576a0904140502h295faf33qcea9a39ff7f230a5@mail.gmail.com>
	 <200904142225.10788.nickpiggin@yahoo.com.au>
Date: Tue, 14 Apr 2009 22:39:54 +0900
Message-ID: <2f11576a0904140639l426e137ewdc46296cdb377dd@mail.gmail.com>
Subject: Re: [RFC][PATCH v3 1/6] mm: Don't unmap gup()ed page
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Andrea Arcangeli <aarcange@redhat.com>, Jeff Moyer <jmoyer@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

>> >> @@ -547,7 +549,13 @@ int reuse_swap_page(struct page *page)
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 SetPageDirty(page);
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> >> =A0 =A0 =A0 }
>> >> - =A0 =A0 return count =3D=3D 1;
>> >> +
>> >> + =A0 =A0 /*
>> >> + =A0 =A0 =A0* If we can re-use the swap page _and_ the end
>> >> + =A0 =A0 =A0* result has only one user (the mapping), then
>> >> + =A0 =A0 =A0* we reuse the whole page
>> >> + =A0 =A0 =A0*/
>> >> + =A0 =A0 return count + page_count(page) =3D=3D 2;
>> >> =A0}
>> >
>> > I guess this patch does work to close the read-side race, but I slight=
ly don't
>> > like using page_count for things like this. page_count can be temporar=
ily
>> > raised for reasons other than access through their user mapping. Swapc=
ache,
>> > page reclaim, LRU pagevecs, concurrent do_wp_page, etc.
>>
>> Yes, that's trade-off.
>> your early decow also can misjudge and make unnecessary copy.
>
> Yes indeed it can. Although it would only ever do so in case of pages
> that have had get_user_pages run against them previously, and not from
> random interactions from any other parts of the kernel.

Agreed.

> I would be interested, using an anon vma field as you say for keeping
> a gup count... it could potentially be used to avoid the extra copy.
> But hmm, I don't have much time to go down that path so long as the
> basic concept of my proposal is in question.

ok, I try to make it. thanks.

> + =A0 =A0 if (PageSwapCache(page) &&
> + =A0 =A0 =A0 =A0 page_count(page) !=3D page_mapcount(page) + 2) {
> + =A0 =A0 =A0 =A0 =A0 =A0 ret =3D SWAP_FAIL;
> + =A0 =A0 =A0 =A0 =A0 =A0 goto out_unmap;
> + =A0 =A0 }
>
> Now if another thread does a get_user_pages_fast after it passes this
> check, it can take a gup reference to the page which is now about to
> be unmapped. Then after it is unmapped, if a wp fault is caused on the
> page, then it will not be reused and thus you lose data as explained
> in your big comment.

Grrr, I lose. I've misunderstood get_user_pages_fast() also grab pte_lock.
I must think it again.

I guess you dislike get_user_page_fast() grab pte_lock too, right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
