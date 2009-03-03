Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 91FB66B0082
	for <linux-mm@kvack.org>; Tue,  3 Mar 2009 07:05:24 -0500 (EST)
Received: by wf-out-1314.google.com with SMTP id 28so2973413wfa.11
        for <linux-mm@kvack.org>; Tue, 03 Mar 2009 04:05:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20090302231628.GA7228@cmpxchg.org>
References: <20090302183148.a4dfcc22.minchan.kim@barrios-desktop>
	 <20090302142757.1cc014aa.akpm@linux-foundation.org>
	 <20090302231628.GA7228@cmpxchg.org>
Date: Tue, 3 Mar 2009 21:05:22 +0900
Message-ID: <28c262360903030405uf54660axebce0ee19e27f7c@mail.gmail.com>
Subject: Re: [PATCH] mmtom : add VM_BUG_ON in __get_free_pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi, Hannes.
Thanks for careful review.

On Tue, Mar 3, 2009 at 8:16 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> On Mon, Mar 02, 2009 at 02:27:57PM -0800, Andrew Morton wrote:
>> On Mon, 2 Mar 2009 18:31:48 +0900
>> MinChan Kim <minchan.kim@gmail.com> wrote:
>>
>> >
>> > The __get_free_pages is used in many place.
>> > Also, driver developers can use it freely due to export function.
>> > Some developers might use it to allocate high pages by mistake.
>> >
>> > The __get_free_pages can allocate high page using alloc_pages,
>> > but it can't return linear address for high page.
>> >
>> > Even worse, in this csse, caller can't free page which are there in hi=
gh zone.
>> > So, It would be better to add VM_BUG_ON.
>> >
>> > It's based on mmtom 2009-02-27-13-54.
>> >
>> > Signed-off-by: MinChan Kim <minchan.kim@gmail.com>
>> > ---
>> > =C2=A0mm/page_alloc.c | =C2=A0 =C2=A07 +++++++
>> > =C2=A01 files changed, 7 insertions(+), 0 deletions(-)
>> >
>> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> > index 8294107..381056b 100644
>> > --- a/mm/page_alloc.c
>> > +++ b/mm/page_alloc.c
>> > @@ -1681,6 +1681,13 @@ EXPORT_SYMBOL(__alloc_pages_internal);
>> > =C2=A0unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int orde=
r)
>> > =C2=A0{
>> > =C2=A0 =C2=A0 struct page * page;
>> > +
>> > + =C2=A0 /*
>> > + =C2=A0 =C2=A0* __get_free_pages() returns a 32-bit address, which ca=
nnot represent
>> > + =C2=A0 =C2=A0* a highmem page
>> > + =C2=A0 =C2=A0*/
>> > + =C2=A0 VM_BUG_ON((gfp_mask & __GFP_HIGHMEM) !=3D 0);
>> > +
>> > =C2=A0 =C2=A0 page =3D alloc_pages(gfp_mask, order);
>> > =C2=A0 =C2=A0 if (!page)
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 0;
>>
>> If someone calls __get_free_pages(__GFP_HIGHMEM) then page_address()
>> will reliably return NULL and the caller's code will oops.
>
> It will allocate a page, fail to translate it to a virtual address,
> return 0 and the caller will think allocation failed because it checks
> for the return value.
>
> But the highmem page is still allocated and now leaked, isn't it?

That was my point.

>> Yes, there's a decent (and increasing) risk that the developer won't be
>> testing the code on a highmem machine, but there are enough highmem
>> machines out there that the bug should be discovered pretty quickly.
>
> Another thing is that a device driver developer does not necessarily
> has CONFIG_DEBUG_VM set. =C2=A0Can we expect him to?

Hmm. I agree.
Even, Many embedded guys don't upload their driver source to mainline
for revewing and testing.
so, others who have high mem machine can't review and test driver code.
Of couse, It depends on their willing but it would be better to care them.

>> So I'm not sure that this test is worth the additional overhead to a
>> fairly frequently called function?
>
> Well, it's only done conditionally if you want to debug the thing
> anyway. =C2=A0But as mentioned above, maybe this isn't the right conditio=
n.
>
I added VM_DEUBG_ON as referencing get_zeroed_page without serious consider=
ing.
I agree with your opinion.
so, we have to change __get_free_page and get_zeroed_page.
Do you mean BUG_ON instead of VM_BUG_ON ?

Andrew, How about that ?
you think it is rather big overhead even if it's vm debug mode ?

--=20
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
