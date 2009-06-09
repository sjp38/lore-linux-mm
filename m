Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 0EDEA6B004D
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 09:22:21 -0400 (EDT)
Received: by qw-out-1920.google.com with SMTP id 4so2769754qwk.44
        for <linux-mm@kvack.org>; Tue, 09 Jun 2009 07:01:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090609130058.GA25007@shadowen.org>
References: <20090609181505.4083a213.kamezawa.hiroyu@jp.fujitsu.com>
	 <28c262360906090300s13f4ee09mcc9622c1e477eaad@mail.gmail.com>
	 <e8f208a7c6bec1818947c24658dc1561.squirrel@webmail-b.css.fujitsu.com>
	 <28c262360906090430p21125c51g10cfdc377a78d07b@mail.gmail.com>
	 <7ca0521d9b798ef8b56212e5b17ea713.squirrel@webmail-b.css.fujitsu.com>
	 <28c262360906090507u75f5b594o71906777a91efa1@mail.gmail.com>
	 <20090609130058.GA25007@shadowen.org>
Date: Tue, 9 Jun 2009 23:01:26 +0900
Message-ID: <28c262360906090701v35af80b7j3f8317d96fa2d23@mail.gmail.com>
Subject: Re: [BUGFIX][PATCH] fix wrong lru rotate back at lumpty reclaim
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andy Whitcroft <apw@canonical.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, riel@redhat.com
List-ID: <linux-mm.kvack.org>

Hi, Andy.

On Tue, Jun 9, 2009 at 10:00 PM, Andy Whitcroft<apw@canonical.com> wrote:
> On Tue, Jun 09, 2009 at 09:07:16PM +0900, Minchan Kim wrote:
>> 2009/6/9 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>:
>> > Minchan Kim wrote:
>> >
>> >> I mean follow as
>> >> =C2=A0908 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
>> >> =C2=A0909 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* Attempt to take all pag=
es in the order aligned region
>> >> =C2=A0910 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* surrounding the tag pag=
e. =C2=A0Only take those pages of
>> >> =C2=A0911 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* the same active state a=
s that tag page. =C2=A0We may safely
>> >> =C2=A0912 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* round the target page p=
fn down to the requested order
>> >> =C2=A0913 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* as the mem_map is guare=
nteed valid out to MAX_ORDER,
>> >> =C2=A0914 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* where that page is in a=
 different zone we will detect
>> >> =C2=A0915 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* it from its zone id and=
 abort this block scan.
>> >> =C2=A0916 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> >> =C2=A0917 =C2=A0 =C2=A0 =C2=A0 =C2=A0 zone_id =3D page_zone_id(page);
>> >>
>> > But what this code really do is.
>> > =3D=3D
>> > 931 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 /* Check that we have not crossed a zone
>> > boundary. */
>> > =C2=A0932 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 if (unlikely(page_zone_id(cursor_page) !=3D
>> > zone_id))
>> > =C2=A0933 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 continue;
>> > =3D=3D
>> > continue. I think this should be "break"
>> > I wonder what "This block scan" means is "scanning this aligned block"=
.
>>
>> It is to find first page in same zone with target page when we have
>> crossed a zone.
>> so it shouldn't stop due to that.
>>
>> I think 'abort' means stopping only the page.
>> If it is right, it would be better to change follow as.
>> "and continue scanning next page"
>>
>> Let's Cced Andy Whitcroft.
>>
>> > But I think the whoe code is not written as commented.
>> >
>> >>
>> >>>> If I understand it properly , don't we add goto phrase ?
>> >>>>
>> >>> No.
>> >>
>> >> If it is so, the break also is meaningless.
>> >>
>> > yes. I'll remove it. But need to add "exit from for loop" logic again.
>> >
>> > I'm sorry that the wrong logic of this loop was out of my sight.
>> > I'll review and rewrite this part all, tomorrow.
>>
>> Yes. I will review tomorrow, too. :)
>
> The comment is not the best wording. =C2=A0The point here is that we need=
 to
> round down in order to safely scan the free blocks as they are only
> marked at the start. =C2=A0In rounding down however we may move back into=
 the
> previous zone as zones are not necessarily MAX_ORDER aligned. =C2=A0We wa=
nt
> to ignore the bit before our zone starts and that check moves us on to
> the next page. =C2=A0It should be noted that this occurs rarely, ie. only
> when we touch the start of a zone and only then where the zone
> boundaries are not MAX_ORDER aligned.

Thanks for kind explanation.

I think this thread's issue is the 'break' following as.

...
                        cursor_page =3D pfn_to_page(pfn);

                        /* Check that we have not crossed a zone boundary. =
*/
                        if (unlikely(page_zone_id(cursor_page) !=3D zone_id=
))
                                continue;
                        switch (__isolate_lru_page(cursor_page, mode, file)=
) {
                        case 0:
                                list_move(&cursor_page->lru, dst);
                                nr_taken++;
                                scan++;
                                break;

                        case -EBUSY:
                                /* else it is being freed elsewhere */
                                list_move(&cursor_page->lru, src);
                        default:
                                break;  /* ! on LRU or wrong list */
<=3D=3D=3D=3D=3D=3D HERE
                        }
                }
        }
...

I think you meant that if we met not lru pages, it should stop scanning.
That's because we have in trouble with high order page allocation.
So, if we fail to allocate contiguous page frame, scanning isn't a
point any more.

But that break can't stop loop. It is in switch case. so if we want to
break in loop really, we have to use goto phrase.
What do you think about it ?

> -apw
>



--=20
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
