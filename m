Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 30AFD6B0055
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 05:10:54 -0400 (EDT)
Received: by pzk26 with SMTP id 26so1144890pzk.12
        for <linux-mm@kvack.org>; Thu, 25 Jun 2009 02:11:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090623090630.f06b7b17.kamezawa.hiroyu@jp.fujitsu.com>
References: <20626261.51271245670323628.JavaMail.weblogic@epml20>
	 <20090622165236.GE3981@csn.ul.ie>
	 <20090623090630.f06b7b17.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 25 Jun 2009 18:11:12 +0900
Message-ID: <28c262360906250211p4f5d8b30q156a06d97ddb7da7@mail.gmail.com>
Subject: Re: Performance degradation seen after using one list for hot/cold
	pages.
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, NARAYANAN GOPALAKRISHNAN <narayanan.g@samsung.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cl@linux-foundation.org" <cl@linux-foundation.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 23, 2009 at 9:06 AM, KAMEZAWA
Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Mon, 22 Jun 2009 17:52:36 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
>
>> On Mon, Jun 22, 2009 at 11:32:03AM +0000, NARAYANAN GOPALAKRISHNAN wrote=
:
>> > Hi,
>> >
>> > We are running on VFAT.
>> > We are using iozone performance benchmarking tool (http://www.iozone.o=
rg/src/current/iozone3_326.tar) for testing.
>> >
>> > The parameters are
>> > /iozone -A -s10M -e -U /tmp -f /tmp/iozone_file
>> >
>> > Our block driver requires requests to be merged to get the best perfor=
mance.
>> > This was not happening due to non-contiguous pages in all kernels >=3D=
 2.6.25.
>> >
>>
>> Ok, by the looks of things, all the aio_read() requests are due to reada=
head
>> as opposed to explicit AIO =C2=A0requests from userspace. In this case, =
nothing
>> springs to mind that would avoid excessive requests for cold pages.
>>
>> It looks like the simpliest solution is to go with the patch I posted.
>> Does anyone see a better alternative that doesn't branch in rmqueue_bulk=
()
>> or add back the hot/cold PCP lists?
>>
> No objection. =C2=A0But 2 questions...
>
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0list_add(&page->lru, list);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0if (likely(cold =3D=3D 0))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0list_add(&page->lru, list);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0else
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0list_add_tail(&page->lru, lis=
t);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0set_page_private(page, migratetype);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0list =3D &page->lru;
>> =C2=A0 =C2=A0 =C2=A0}
>
> 1. if (likely(coild =3D=3D 0))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0"likely" is necessary ?
>
> 2. Why moving pointer "list" rather than following ?
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (cold)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0list_add(&page->lr=
u, list);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0else
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0list_add_tail(&pag=
e->lru, list);


I agree.
We can remove unnecessary list head moving forward.


--=20
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
