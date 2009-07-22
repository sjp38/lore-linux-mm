Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 200C46B010A
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 08:37:14 -0400 (EDT)
Received: by gxk3 with SMTP id 3so238470gxk.14
        for <linux-mm@kvack.org>; Wed, 22 Jul 2009 05:37:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090722090719.GA1971@cmpxchg.org>
References: <1248166594-8859-1-git-send-email-hannes@cmpxchg.org>
	 <1248166594-8859-2-git-send-email-hannes@cmpxchg.org>
	 <28c262360907211852m7aa0fd6eic69e4ce29f09e5b8@mail.gmail.com>
	 <20090722090719.GA1971@cmpxchg.org>
Date: Wed, 22 Jul 2009 21:37:10 +0900
Message-ID: <28c262360907220537j28035086x82869da4fb819da3@mail.gmail.com>
Subject: Re: [patch 2/4] mm: introduce page_lru_type()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 22, 2009 at 6:07 PM, Johannes Weiner<hannes@cmpxchg.org> wrote:
> Hello Minchan,
>
> On Wed, Jul 22, 2009 at 10:52:21AM +0900, Minchan Kim wrote:
>> Hi.
>>
>> On Tue, Jul 21, 2009 at 5:56 PM, Johannes Weiner<hannes@cmpxchg.org> wro=
te:
>> > Instead of abusing page_is_file_cache() for LRU list index arithmetic,
>> > add another helper with a more appropriate name and convert the
>> > non-boolean users of page_is_file_cache() accordingly.
>> >
>> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
>> > ---
>> > =C2=A0include/linux/mm_inline.h | =C2=A0 19 +++++++++++++++++--
>> > =C2=A0mm/swap.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 | =C2=A0 =C2=A04 ++--
>> > =C2=A0mm/vmscan.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =
=C2=A0 =C2=A06 +++---
>> > =C2=A03 files changed, 22 insertions(+), 7 deletions(-)
>> >
>> > diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
>> > index 7fbb972..ec975f2 100644
>> > --- a/include/linux/mm_inline.h
>> > +++ b/include/linux/mm_inline.h
>> > @@ -60,6 +60,21 @@ del_page_from_lru(struct zone *zone, struct page *p=
age)
>> > =C2=A0}
>> >
>> > =C2=A0/**
>> > + * page_lru_type - which LRU list type should a page be on?
>> > + * @page: the page to test
>> > + *
>> > + * Used for LRU list index arithmetic.
>> > + *
>> > + * Returns the base LRU type - file or anon - @page should be on.
>> > + */
>> > +static enum lru_list page_lru_type(struct page *page)
>> > +{
>> > + =C2=A0 =C2=A0 =C2=A0 if (page_is_file_cache(page))
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return LRU_INACTIVE=
_FILE;
>> > + =C2=A0 =C2=A0 =C2=A0 return LRU_INACTIVE_ANON;
>> > +}
>>
>> page_lru_type function's semantics is general but this function only
>> considers INACTIVE case.
>> So we always have to check PageActive to know exact lru type.
>>
>> Why do we need double check(ex, page_lru_type and PageActive) to know
>> exact lru type ?
>>
>> It wouldn't be better to check it all at once ?
>
> page_lru() does that for you already.
>
> But look at the users of page_lru_type(), they know the active bit
> when they want to find out the base type, see check_move_unevictable
> e.g.

Yes. You already mentioned proper function name. :)

How about changing function name from page_lru_type to page_lru_base_type ?
it might be a nitpick. :)

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
