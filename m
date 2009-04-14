Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5C17E5F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 08:02:47 -0400 (EDT)
Received: by rv-out-0708.google.com with SMTP id f25so2039012rvb.26
        for <linux-mm@kvack.org>; Tue, 14 Apr 2009 05:02:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <200904141925.46012.nickpiggin@yahoo.com.au>
References: <20090414151204.C647.A69D9226@jp.fujitsu.com>
	 <20090414151554.C64A.A69D9226@jp.fujitsu.com>
	 <200904141925.46012.nickpiggin@yahoo.com.au>
Date: Tue, 14 Apr 2009 21:02:47 +0900
Message-ID: <2f11576a0904140502h295faf33qcea9a39ff7f230a5@mail.gmail.com>
Subject: Re: [RFC][PATCH v3 1/6] mm: Don't unmap gup()ed page
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Andrea Arcangeli <aarcange@redhat.com>, Jeff Moyer <jmoyer@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

> On Tuesday 14 April 2009 16:16:52 KOSAKI Motohiro wrote:
>
>> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> Sugessted-by: Linus Torvalds <torvalds@osdl.org>
>
> "Suggested-by:" ;)

Agghh, thanks.


>> @@ -547,7 +549,13 @@ int reuse_swap_page(struct page *page)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 SetPageDirty(page);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 }
>> - =A0 =A0 return count =3D=3D 1;
>> +
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* If we can re-use the swap page _and_ the end
>> + =A0 =A0 =A0* result has only one user (the mapping), then
>> + =A0 =A0 =A0* we reuse the whole page
>> + =A0 =A0 =A0*/
>> + =A0 =A0 return count + page_count(page) =3D=3D 2;
>> =A0}
>
> I guess this patch does work to close the read-side race, but I slightly =
don't
> like using page_count for things like this. page_count can be temporarily
> raised for reasons other than access through their user mapping. Swapcach=
e,
> page reclaim, LRU pagevecs, concurrent do_wp_page, etc.

Yes, that's trade-off.
your early decow also can misjudge and make unnecessary copy.



>> =A0 =A0 =A0 /*
>> + =A0 =A0 =A0* Don't pull an anonymous page out from under get_user_page=
s.
>> + =A0 =A0 =A0* GUP carefully breaks COW and raises page count (while hol=
ding
>> + =A0 =A0 =A0* pte_lock, as we have here) to make sure that the page
>> + =A0 =A0 =A0* cannot be freed. =A0If we unmap that page here, a user wr=
ite
>> + =A0 =A0 =A0* access to the virtual address will bring back the page, b=
ut
>> + =A0 =A0 =A0* its raised count will (ironically) be taken to mean it's =
not
>> + =A0 =A0 =A0* an exclusive swap page, do_wp_page will replace it by a c=
opy
>> + =A0 =A0 =A0* page, and the user never get to see the data GUP was hold=
ing
>> + =A0 =A0 =A0* the original page for.
>> + =A0 =A0 =A0*
>> + =A0 =A0 =A0* This test is also useful for when swapoff (unuse_process)=
 has
>> + =A0 =A0 =A0* to drop page lock: its reference to the page stops existi=
ng
>> + =A0 =A0 =A0* ptes from being unmapped, so swapoff can make progress.
>> + =A0 =A0 =A0*/
>> + =A0 =A0 if (PageSwapCache(page) &&
>> + =A0 =A0 =A0 =A0 page_count(page) !=3D page_mapcount(page) + 2) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 ret =3D SWAP_FAIL;
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out_unmap;
>> + =A0 =A0 }
>
> I guess it does add another constraint to the VM, ie. not allowed to
> unmap an anonymous page with elevated refcount. Maybe not a big deal
> now, but I think it is enough that it should be noted. If you squint,
> this could actually be more complex/intrusive to the wider VM than my
> copy on fork (which is basically exactly like a manual do_wp_page at
> fork time).

I agree this code effect widely kernel activity.
but actually, in past days, the kernel did the same behavior. then
almost core code is
page_count checking safe.

but Yes, we need to afraid newer code don't works with this code...


> And.... I don't think this is safe against a concurrent gup_fast()
> (which helps my point).

Could you please explain more detail ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
