Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id F0B1F6B01E3
	for <linux-mm@kvack.org>; Wed, 21 Apr 2010 20:11:05 -0400 (EDT)
Received: by gwj15 with SMTP id 15so1547522gwj.14
        for <linux-mm@kvack.org>; Wed, 21 Apr 2010 17:11:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100422085943.3d908a4b.kamezawa.hiroyu@jp.fujitsu.com>
References: <1271797276-31358-1-git-send-email-mel@csn.ul.ie>
	 <1271797276-31358-5-git-send-email-mel@csn.ul.ie>
	 <alpine.DEB.2.00.1004210927550.4959@router.home>
	 <20100422085943.3d908a4b.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 22 Apr 2010 09:11:04 +0900
Message-ID: <t2l28c262361004211711v728b50e5h91e0b3bb94dcef4b@mail.gmail.com>
Subject: Re: [PATCH 04/14] mm,migration: Allow the migration of PageSwapCache
	pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 22, 2010 at 8:59 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Wed, 21 Apr 2010 09:30:20 -0500 (CDT)
> Christoph Lameter <cl@linux-foundation.org> wrote:
>
>> On Tue, 20 Apr 2010, Mel Gorman wrote:
>>
>> > @@ -520,10 +521,12 @@ static int move_to_new_page(struct page *newpage=
, struct page *page)
>> > =C2=A0 =C2=A0 else
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rc =3D fallback_migrate_page=
(mapping, newpage, page);
>> >
>> > - =C2=A0 if (!rc)
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 remove_migration_ptes(page, newpa=
ge);
>> > - =C2=A0 else
>> > + =C2=A0 if (rc) {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 newpage->mapping =3D NULL;
>> > + =C2=A0 } else {
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (remap_swapcache)
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 remov=
e_migration_ptes(page, newpage);
>> > + =C2=A0 }
>>
>> You are going to keep the migration ptes after the page has been unlocke=
d?
>> Or is remap_swapcache true if its not a swapcache page?
>>
>> Maybe you meant
>>
>> if (!remap_swapcache)
>>
>
> Ah....Can I confirm my understanding ?
>
> remap_swapcache =3D=3D true only when
> =C2=A0The old page was ANON && it is not mapped. && it is SwapCache.
>
> We do above check under lock_page(). So, this SwapCache is never mapped u=
ntil
> we release lock_page() on the old page. So, we don't use migration_pte in
> this case because try_to_unmap() do nothing and don't need to call
> remove_migration_pte().

Yes. so I thought what kinds of race happened.
Firstly I doubt fork and migration. but It isn't.
I can't understand how this bug happens.
Apparently, We have been missed something.
I will look into this further.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
