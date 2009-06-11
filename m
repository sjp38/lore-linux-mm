Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 61BA86B004D
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 18:51:08 -0400 (EDT)
Received: by gxk28 with SMTP id 28so2977775gxk.14
        for <linux-mm@kvack.org>; Thu, 11 Jun 2009 15:52:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <28c262360906110218t6a3ed908g9a4fba7fa7dd7b22@mail.gmail.com>
References: <20090611165535.cf46bf29.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090611170018.c3758488.kamezawa.hiroyu@jp.fujitsu.com>
	 <28c262360906110218t6a3ed908g9a4fba7fa7dd7b22@mail.gmail.com>
Date: Fri, 12 Jun 2009 07:52:41 +0900
Message-ID: <28c262360906111552h774888a5l895085a8cf724579@mail.gmail.com>
Subject: Re: [PATCH 1/3] remove wrong rotation at lumpy reclaim
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, apw@canonical.com, riel@redhat.com, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

Otherwise, Looks good to me.
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

On Thu, Jun 11, 2009 at 6:18 PM, Minchan Kim<minchan.kim@gmail.com> wrote:
> On Thu, Jun 11, 2009 at 5:00 PM, KAMEZAWA
> Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>
>> At lumpy reclaim, a page failed to be taken by __isolate_lru_page() can
>> be pushed back to "src" list by list_move(). But the page may not be fro=
m
>> "src" list. And list_move() itself is unnecessary because the page is
>> not on top of LRU. Then, leave it as it is if __isolate_lru_page() fails=
.
>>
>> This patch doesn't change the logic as "we should exit loop or not" and
>> just fixes buggy list_move().
>>
>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> ---
>> =C2=A0mm/vmscan.c | =C2=A0 =C2=A09 +--------
>> =C2=A01 file changed, 1 insertion(+), 8 deletions(-)
>>
>> Index: lumpy-reclaim-trial/mm/vmscan.c
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> --- lumpy-reclaim-trial.orig/mm/vmscan.c
>> +++ lumpy-reclaim-trial/mm/vmscan.c
>> @@ -936,18 +936,11 @@ static unsigned long isolate_lru_pages(u
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0/* Check that we have not crossed a zone boundary. */
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0if (unlikely(page_zone_id(cursor_page) !=3D zone_id))
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0continue;
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 switch (__isolate_lru_page(cursor_page, mode, file)) {
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 case 0:
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 if (__isolate_lru_page(cursor_page, mode, file) =3D=3D 0) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0list_move(&cursor_page->lru, dst);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0nr_taken++;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0scan++;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0break;
>
> break ??
>
> Kinds regards,
> Minchan Kim
>



--=20
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
