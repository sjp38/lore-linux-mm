Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 20B736B0078
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 11:04:05 -0500 (EST)
Received: by pxi29 with SMTP id 29so2100571pxi.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2010 08:04:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100223154016.GC29762@cmpxchg.org>
References: <1266868150-25984-1-git-send-email-hannes@cmpxchg.org>
	 <1266868150-25984-2-git-send-email-hannes@cmpxchg.org>
	 <1266932303.2723.13.camel@barrios-desktop>
	 <20100223142158.GA29762@cmpxchg.org>
	 <1266936254.2723.33.camel@barrios-desktop>
	 <20100223154016.GC29762@cmpxchg.org>
Date: Wed, 24 Feb 2010 01:04:02 +0900
Message-ID: <28c262361002230804h53574e2aje619aeff558efa77@mail.gmail.com>
Subject: Re: [patch 1/3] vmscan: factor out page reference checks
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 24, 2010 at 12:40 AM, Johannes Weiner <hannes@cmpxchg.org> wrot=
e:
> Hello Minchan,
>
> On Tue, Feb 23, 2010 at 11:44:14PM +0900, Minchan Kim wrote:
>> On Tue, 2010-02-23 at 15:21 +0100, Johannes Weiner wrote:
>> > Hello Minchan,
>> >
>> > On Tue, Feb 23, 2010 at 10:38:23PM +0900, Minchan Kim wrote:
>>
>> <snip>
>>
>> > > >
>> > > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (PageDi=
rty(page)) {
>> > > > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 if (sc->order <=3D PAGE_ALLOC_COSTLY_ORDER && referenced)
>> > > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 if (references =3D=3D PAGEREF_RECLAIM_CLEAN)
>> > >
>> > > How equal PAGEREF_RECLAIM_CLEAN and sc->order <=3D PAGE_ALLOC_COSTLY=
_ORDER
>> > > && referenced by semantic?
>> >
>> > It is encoded in page_check_references(). =C2=A0When
>> > =C2=A0 =C2=A0 sc->order <=3D PAGE_ALLOC_COSTLY_ORDER && referenced
>> > it returns PAGEREF_RECLAIM_CLEAN.
>> >
>> > So
>> >
>> > =C2=A0 =C2=A0 - PageDirty() && order < COSTLY && referenced
>> > =C2=A0 =C2=A0 + PageDirty() && references =3D=3D PAGEREF_RECLAIM_CLEAN
>> >
>> > is an equivalent transformation. =C2=A0Does this answer your question?
>>
>> Hmm. I knew it. My point was PAGEREF_RECLAIM_CLEAN seems to be a little
>> awkward. I thought PAGEREF_RECLAIM_CLEAN means if the page was clean, it
>> can be reclaimed.
>
> But you were thinking right, it is exactly what it means! =C2=A0If
> the state is PAGEREF_RECLAIM_CLEAN, reclaim the page if it is clean:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (PageDirty(page)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (references =3D=
=3D PAGEREF_RECLAIM_CLEAN)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0goto keep_locked; =C2=A0 =C2=A0 =C2=A0 /* do not reclaim */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0...
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
>> I think it would be better to rename it with represent "Although it's
>> referenced page recently, we can reclaim it if VM try to reclaim high
>> order page".
>
> I changed it to PAGEREF_RECLAIM_LUMPY and PAGEREF_RECLAIM, but I felt
> it made it worse. =C2=A0It's awkward that we have to communicate that sta=
te
> at all, maybe it would be better to do
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (PageDirty(page) && referenced_page)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return PAGEREF_KEE=
P;
>
> in page_check_references()? =C2=A0But doing PageDirty() twice is also kin=
da
> lame.
>
> I don't know. =C2=A0Can we leave it like that for now?

I hope as it is if we don't have any better idea and you don't feel it stro=
ng.
But let's listen to other's opinion. maybe they have a good idea.

Thanks, Hannes.



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
