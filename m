Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 2B6976B004F
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 07:31:46 -0400 (EDT)
Received: by gxk28 with SMTP id 28so1155699gxk.14
        for <linux-mm@kvack.org>; Tue, 09 Jun 2009 05:07:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <7ca0521d9b798ef8b56212e5b17ea713.squirrel@webmail-b.css.fujitsu.com>
References: <20090609181505.4083a213.kamezawa.hiroyu@jp.fujitsu.com>
	 <28c262360906090300s13f4ee09mcc9622c1e477eaad@mail.gmail.com>
	 <e8f208a7c6bec1818947c24658dc1561.squirrel@webmail-b.css.fujitsu.com>
	 <28c262360906090430p21125c51g10cfdc377a78d07b@mail.gmail.com>
	 <7ca0521d9b798ef8b56212e5b17ea713.squirrel@webmail-b.css.fujitsu.com>
Date: Tue, 9 Jun 2009 21:07:16 +0900
Message-ID: <28c262360906090507u75f5b594o71906777a91efa1@mail.gmail.com>
Subject: Re: [BUGFIX][PATCH] fix wrong lru rotate back at lumpty reclaim
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andy Whitcroft <apw@canonical.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, riel@redhat.com
List-ID: <linux-mm.kvack.org>

2009/6/9 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>:
> Minchan Kim wrote:
>
>> I mean follow as
>> =C2=A0908 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
>> =C2=A0909 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* Attempt to take all pages =
in the order aligned region
>> =C2=A0910 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* surrounding the tag page. =
=C2=A0Only take those pages of
>> =C2=A0911 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* the same active state as t=
hat tag page. =C2=A0We may safely
>> =C2=A0912 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* round the target page pfn =
down to the requested order
>> =C2=A0913 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* as the mem_map is guarente=
ed valid out to MAX_ORDER,
>> =C2=A0914 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* where that page is in a di=
fferent zone we will detect
>> =C2=A0915 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* it from its zone id and ab=
ort this block scan.
>> =C2=A0916 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> =C2=A0917 =C2=A0 =C2=A0 =C2=A0 =C2=A0 zone_id =3D page_zone_id(page);
>>
> But what this code really do is.
> =3D=3D
> 931 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 /* Check that we have not crossed a zone
> boundary. */
> =C2=A0932 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 if (unlikely(page_zone_id(cursor_page) !=3D
> zone_id))
> =C2=A0933 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 continue;
> =3D=3D
> continue. I think this should be "break"
> I wonder what "This block scan" means is "scanning this aligned block".

It is to find first page in same zone with target page when we have
crossed a zone.
so it shouldn't stop due to that.

I think 'abort' means stopping only the page.
If it is right, it would be better to change follow as.
"and continue scanning next page"

Let's Cced Andy Whitcroft.

> But I think the whoe code is not written as commented.
>
>>
>>>> If I understand it properly , don't we add goto phrase ?
>>>>
>>> No.
>>
>> If it is so, the break also is meaningless.
>>
> yes. I'll remove it. But need to add "exit from for loop" logic again.
>
> I'm sorry that the wrong logic of this loop was out of my sight.
> I'll review and rewrite this part all, tomorrow.

Yes. I will review tomorrow, too. :)

> Thanks,
> -Kame
>
>



--=20
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
