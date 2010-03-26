Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E05B66B01AC
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 21:39:11 -0400 (EDT)
Received: by pwi2 with SMTP id 2so1169594pwi.14
        for <linux-mm@kvack.org>; Thu, 25 Mar 2010 18:39:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100326095825.69fd63a9.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100325092131.GK2024@csn.ul.ie>
	 <20100325184123.e3e3b009.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100325185200.6C8C.A69D9226@jp.fujitsu.com>
	 <20100325191229.8e3d2ba1.kamezawa.hiroyu@jp.fujitsu.com>
	 <1269530941.1814.21.camel@barrios-desktop>
	 <20100326095825.69fd63a9.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 26 Mar 2010 10:39:10 +0900
Message-ID: <28c262361003251839n4c346400ke4f5de3283322904@mail.gmail.com>
Subject: Re: [PATCH 02/11] mm,migration: Do not try to migrate unmapped
	anonymous pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 26, 2010 at 9:58 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 26 Mar 2010 00:29:01 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> Hi, Kame.
> <snip>
>
>> Which case do we have PageAnon && (page_mapcount =3D=3D 0) && PageSwapCa=
che ?
>> With looking over code which add_to_swap_cache, I found somewhere.
>>
>> 1) shrink_page_list
>> I think this case doesn't matter by isolate_lru_xxx.
>>
>> 2) shmem_swapin
>> It seems to be !PageAnon
>>
>> 3) shmem_writepage
>> It seems to be !PageAnon.
>>
>> 4) do_swap_page
>> page_add_anon_rmap increases _mapcount before setting page->mapping to a=
non_vma.
>> So It doesn't matter.
>
>>
>>
>> I think following codes in unmap_and_move seems to handle 3) case.
>>
>> ---
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* Corner case handling:
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* 1. When a new swap-cache page is rea=
d into, it is added to the LRU
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* and treated as swapcache but it has =
no rmap yet.
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 ...
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!page->mapping) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!PageAnon(pa=
ge) && page_has_private(page)) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ....
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto skip_unmap;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>>
>> ---
>>
>> Do we really check PageSwapCache in there?
>> Do I miss any case?
>>
>
> When a page is fully unmapped, page->mapping is not cleared.
>
> from rmap.c
> =3D=3D
> =C2=A0734 void page_remove_rmap(struct page *page)
> =C2=A0735 {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0....
> =C2=A0758 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
> =C2=A0759 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* It would be tidy to reset t=
he PageAnon mapping here,
> =C2=A0760 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* but that might overwrite a =
racing page_add_anon_rmap
> =C2=A0761 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* which increments mapcount a=
fter us but sets mapping
> =C2=A0762 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* before us: so leave the res=
et to free_hot_cold_page,
> =C2=A0763 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* and remember that it's only=
 reliable while mapped.
> =C2=A0764 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* Leaving it set also helps s=
wapoff to reinstate ptes
> =C2=A0765 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* faster for those pages stil=
l in swapcache.
> =C2=A0766 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> =C2=A0767 }
> =3D=3D
>
> What happens at memory reclaim is...
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0the first vmscan
> =C2=A0 =C2=A0 =C2=A0 =C2=A01. isolate a page from LRU.
> =C2=A0 =C2=A0 =C2=A0 =C2=A02. add_to_swap_cache it.
> =C2=A0 =C2=A0 =C2=A0 =C2=A03. try_to_unmap it
> =C2=A0 =C2=A0 =C2=A0 =C2=A04. pageout it (PG_reclaim && PG_writeback)
> =C2=A0 =C2=A0 =C2=A0 =C2=A05. move page to the tail of LRU.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.....<after some time>
> =C2=A0 =C2=A0 =C2=A0 =C2=A06. I/O ends and PG_writeback is cleared.
>
> Here, in above cycle, the page is not freed. Still in LRU list.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0next vmscan
> =C2=A0 =C2=A0 =C2=A0 =C2=A07. isolate a page from LRU.
> =C2=A0 =C2=A0 =C2=A0 =C2=A08. finds a unmapped clean SwapCache
> =C2=A0 =C2=A0 =C2=A0 =C2=A09. drop it.
>
> So, to _free_ unmapped SwapCache, sequence 7-9 should happen.
> If enough memory is freed by the first itelation of vmscan before I/O end=
,
> next vmscan doesn't happen. Then, we have "unmmaped clean Swapcache which=
 has
> anon_vma pointer on page->mapping" on LRU.

Thanks for open my eye. Kame. :)



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
