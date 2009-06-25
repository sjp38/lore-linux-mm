Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 4CBB36B005C
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 10:34:17 -0400 (EDT)
Received: by gxk3 with SMTP id 3so1639750gxk.14
        for <linux-mm@kvack.org>; Thu, 25 Jun 2009 07:35:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4A438522.7040309@redhat.com>
References: <20090625183616.23b55b24.minchan.kim@barrios-desktop>
	 <4A438522.7040309@redhat.com>
Date: Thu, 25 Jun 2009 23:30:11 +0900
Message-ID: <28c262360906250730h7f8240c2mb1411ef147b239b2@mail.gmail.com>
Subject: Re: [PATCH] prevent to reclaim anon page of lumpy reclaim for no swap
	space
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Juna 25, 2009 at 11:09 PM, Rik van Riel<riel@redhat.com> wrote:
> Minchan Kim wrote:
>>
>> This patch prevent to reclaim anon page in case of no swap space.
>> VM already prevent to reclaim anon page in various place.
>> But it doesnt't prevent it for lumpy reclaim.
>>
>> It shuffles lru list unnecessary so that it is pointless.
>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>> ---
>> =C2=A0mm/vmscan.c | =C2=A0 =C2=A06 ++++++
>> =C2=A01 files changed, 6 insertions(+), 0 deletions(-)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 026f452..fb401fe 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -830,7 +830,13 @@ int __isolate_lru_page(struct page *page, int mode,
>> int file)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * When this function is being called for lum=
py reclaim, we
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * initially look into all LRU pages, active,=
 inactive and
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * unevictable; only give shrink_page_list ev=
ictable pages.
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* If we don't have enough swap space, recla=
iming of anon page
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* is pointless.
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
>> + =C2=A0 =C2=A0 =C2=A0 if (nr_swap_pages <=3D 0 && PageAnon(page))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return ret;
>> +
>
> Should that be something like this:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (nr_swap_pages <=3D 0 && (PageAnon(page) &&=
 !PageSwapCache(page)))
>
> We can still reclaim anonymous pages that already have
> a swap slot assigned to them.

Yes. I missed that.
Thanks for careful review. Rik. :)

>
> --
> All rights reversed.
>



--=20
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
