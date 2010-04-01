Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 043646B01F0
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 00:44:32 -0400 (EDT)
Received: by pvg2 with SMTP id 2so209875pvg.14
        for <linux-mm@kvack.org>; Wed, 31 Mar 2010 21:44:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100401120123.f9f9e872.kamezawa.hiroyu@jp.fujitsu.com>
References: <1269940489-5776-1-git-send-email-mel@csn.ul.ie>
	 <1269940489-5776-15-git-send-email-mel@csn.ul.ie>
	 <20100331142623.62ac9175.kamezawa.hiroyu@jp.fujitsu.com>
	 <j2s28c262361003311943ke6d39007of3861743cef3733a@mail.gmail.com>
	 <20100401120123.f9f9e872.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 1 Apr 2010 13:44:29 +0900
Message-ID: <n2k28c262361003312144k3a1a725aj1eb22efe6d360118@mail.gmail.com>
Subject: Re: [PATCH 14/14] mm,migration: Allow the migration of PageSwapCache
	pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 1, 2010 at 12:01 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Thu, 1 Apr 2010 11:43:18 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> On Wed, Mar 31, 2010 at 2:26 PM, KAMEZAWA Hiroyuki =C2=A0 =C2=A0 =C2=A0 =
/*
>> >> diff --git a/mm/rmap.c b/mm/rmap.c
>> >> index af35b75..d5ea1f2 100644
>> >> --- a/mm/rmap.c
>> >> +++ b/mm/rmap.c
>> >> @@ -1394,9 +1394,11 @@ int rmap_walk(struct page *page, int (*rmap_on=
e)(struct page *,
>> >>
>> >> =C2=A0 =C2=A0 =C2=A0 if (unlikely(PageKsm(page)))
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return rmap_walk_ksm=
(page, rmap_one, arg);
>> >> - =C2=A0 =C2=A0 else if (PageAnon(page))
>> >> + =C2=A0 =C2=A0 else if (PageAnon(page)) {
>> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (PageSwapCache(page))
>> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 return SWAP_AGAIN;
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return rmap_walk_ano=
n(page, rmap_one, arg);
>> >
>> > SwapCache has a condition as (PageSwapCache(page) && page_mapped(page)=
 =3D=3D true.
>> >
>>
>> In case of tmpfs, page has swapcache but not mapped.
>>
>> > Please see do_swap_page(), PageSwapCache bit is cleared only when
>> >
>> > do_swap_page()...
>> > =C2=A0 =C2=A0 =C2=A0 swap_free(entry);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0if (vm_swap_full() || (vma->vm_flags & VM_L=
OCKED) || PageMlocked(page))
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0try_to_free_swa=
p(page);
>> >
>> > Then, PageSwapCache is cleared only when swap is freeable even if mapp=
ed.
>> >
>> > rmap_walk_anon() should be called and the check is not necessary.
>>
>> Frankly speaking, I don't understand what is Mel's problem, why he added
>> Swapcache check in rmap_walk, and why do you said we don't need it.
>>
>> Could you explain more detail if you don't mind?
>>
> I may miss something.
>
> unmap_and_move()
> =C2=A01. try_to_unmap(TTU_MIGRATION)
> =C2=A02. move_to_newpage
> =C2=A03. remove_migration_ptes
> =C2=A0 =C2=A0 =C2=A0 =C2=A0-> rmap_walk()
>
> Then, to map a page back we unmapped we call rmap_walk().
>
> Assume a SwapCache which is mapped, then, PageAnon(page) =3D=3D true.
>
> =C2=A0At 1. try_to_unmap() will rewrite pte with swp_entry of SwapCache.
> =C2=A0 =C2=A0 =C2=A0 mapcount goes to 0.
> =C2=A0At 2. SwapCache is copied to a new page.
> =C2=A0At 3. The new page is mapped back to the place. Now, newpage's mapc=
ount is 0.
> =C2=A0 =C2=A0 =C2=A0 Before patch, the new page is mapped back to all pte=
s.
> =C2=A0 =C2=A0 =C2=A0 After patch, the new page is not mapped back because=
 its mapcount is 0.
>
> I don't think shared SwapCache of anon is not an usual behavior, so, the =
logic
> before patch is more attractive.
>
> If SwapCache is not mapped before "1", we skip "1" and rmap_walk will do =
nothing
> because page->mapping is NULL.
>

Thanks. I agree. We don't need the check.
Then, my question is why Mel added the check in rmap_walk.
He mentioned some BUG trigger and fixed things after this patch.
What's it?
Is it really related to this logic?
I don't think so or we are missing something.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
