Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 667B36B0047
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 21:56:57 -0400 (EDT)
Received: by rv-out-0708.google.com with SMTP id k29so275308rvb.26
        for <linux-mm@kvack.org>; Wed, 11 Mar 2009 18:56:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090312105226.88df3f63.minchan.kim@barrios-desktop>
References: <20090311170207.1795cad9.akpm@linux-foundation.org>
	 <28c262360903111735s2b0c43a3pd48fcf8d55416ae3@mail.gmail.com>
	 <20090312100049.43A3.A69D9226@jp.fujitsu.com>
	 <20090312105226.88df3f63.minchan.kim@barrios-desktop>
Date: Thu, 12 Mar 2009 10:56:55 +0900
Message-ID: <44c63dc40903111856w3a2861f5k2c9f53523c92b7cf@mail.gmail.com>
Subject: Re: [PATCH] NOMMU: Pages allocated to a ramfs inode's pagecache may
	get wrongly discarded
From: Minchan Kim <barrioskmc@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, dhowells@redhat.com, torvalds@linux-foundation.org, peterz@infradead.org, Enrik.Berkhan@ge.com, uclinux-dev@uclinux.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@surriel.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

In the middle of writing the email, I seneded it by mistake.
Sorry for that.
Please, understand wrong patch title and changelog.
I think although i don't modify that, you can understand it, well.

So, I can't resend this until finising discussion. :)

On Thu, Mar 12, 2009 at 10:52 AM, Minchan Kim <minchan.kim@gmail.com> wrote=
:
> Hi, Kosaki-san.
>
> I think ramfs pages's unevictablility should not depend on CONFIG_UNEVICT=
ABLE_LRU.
> It would be better to remove dependency of CONFIG_UNEVICTABLE_LRU ?
>
>
> How about this ?
> It's just RFC. It's not tested.
>
> That's because we can't reclaim that pages regardless of whether there is=
 unevictable list or not
>
> From 487ce9577ea9c43b04ff340a1ba8c4030873e875 Mon Sep 17 00:00:00 2001
> From: MinChan Kim <minchan.kim@gmail.com>
> Date: Thu, 12 Mar 2009 10:35:37 +0900
> Subject: [PATCH] test
> =C2=A0Signed-off-by: MinChan Kim <minchan.kim@gmail.com>
>
> ---
> =C2=A0include/linux/pagemap.h | =C2=A0 =C2=A09 ---------
> =C2=A0include/linux/swap.h =C2=A0 =C2=A0| =C2=A0 =C2=A09 ++-------
> =C2=A02 files changed, 2 insertions(+), 16 deletions(-)
>
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index 4d27bf8..0cf024c 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -32,7 +32,6 @@ static inline void mapping_set_error(struct address_spa=
ce *mapping, int error)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0}
>
> -#ifdef CONFIG_UNEVICTABLE_LRU
> =C2=A0#define AS_UNEVICTABLE (__GFP_BITS_SHIFT + 2) =C2=A0/* e.g., ramdis=
k, SHM_LOCK */
>
> =C2=A0static inline void mapping_set_unevictable(struct address_space *ma=
pping)
> @@ -51,14 +50,6 @@ static inline int mapping_unevictable(struct address_s=
pace *mapping)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return test_bit(AS=
_UNEVICTABLE, &mapping->flags);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return !!mapping;
> =C2=A0}
> -#else
> -static inline void mapping_set_unevictable(struct address_space *mapping=
) { }
> -static inline void mapping_clear_unevictable(struct address_space *mappi=
ng) { }
> -static inline int mapping_unevictable(struct address_space *mapping)
> -{
> - =C2=A0 =C2=A0 =C2=A0 return 0;
> -}
> -#endif
>
> =C2=A0static inline gfp_t mapping_gfp_mask(struct address_space * mapping=
)
> =C2=A0{
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index a3af95b..18c639b 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -233,8 +233,9 @@ static inline int zone_reclaim(struct zone *z, gfp_t =
mask, unsigned int order)
> =C2=A0}
> =C2=A0#endif
>
> -#ifdef CONFIG_UNEVICTABLE_LRU
> =C2=A0extern int page_evictable(struct page *page, struct vm_area_struct =
*vma);
> +
> +#ifdef CONFIG_UNEVICTABLE_LRU
> =C2=A0extern void scan_mapping_unevictable_pages(struct address_space *);
>
> =C2=A0extern unsigned long scan_unevictable_pages;
> @@ -243,12 +244,6 @@ extern int scan_unevictable_handler(struct ctl_table=
 *, int, struct file *,
> =C2=A0extern int scan_unevictable_register_node(struct node *node);
> =C2=A0extern void scan_unevictable_unregister_node(struct node *node);
> =C2=A0#else
> -static inline int page_evictable(struct page *page,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 struct vm_area_struct *vma)
> -{
> - =C2=A0 =C2=A0 =C2=A0 return 1;
> -}
> -
> =C2=A0static inline void scan_mapping_unevictable_pages(struct address_sp=
ace *mapping)
> =C2=A0{
> =C2=A0}
> --
> 1.5.4.3
>
>
>
>> On Thu, 12 Mar 2009 10:04:41 +0900 (JST)
>> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
>>
>> Hi
>>
>> > >> Page reclaim shouldn't be even attempting to reclaim or write back
>> > >> ramfs pagecache pages - reclaim can't possibly do anything with the=
se
>> > >> pages!
>> > >>
>> > >> Arguably those pages shouldn't be on the LRU at all, but we haven't
>> > >> done that yet.
>> > >>
>> > >> Now, my problem is that I can't 100% be sure that we _ever_ impleme=
nted
>> > >> this properly. ?I _think_ we did, in which case we later broke it. =
?If
>> > >> we've always been (stupidly) trying to pageout these pages then OK,=
 I
>> > >> guess your patch is a suitable 2.6.29 stopgap.
>> > >
>> > > OK, I can't find any code anywhere in which we excluded ramfs pages
>> > > from consideration by page reclaim. ?How dumb.
>> >
>> > The ramfs =C2=A0considers it in just CONFIG_UNEVICTABLE_LRU case
>> > It that case, ramfs_get_inode calls mapping_set_unevictable.
>> > So, =C2=A0page reclaim can exclude ramfs pages by page_evictable.
>> > It's problem .
>>
>> Currently, CONFIG_UNEVICTABLE_LRU can't use on nommu machine
>> because nobody of vmscan folk havbe nommu machine.
>>
>> Yes, it is very stupid reason. _very_ welcome to tester! :)
>>
>>
>>
>> David, Could you please try following patch if you have NOMMU machine?
>> it is straightforward porting to nommu.
>>
>>
>> =3D=3D
>> Subject: [PATCH] remove to depend on MMU from CONFIG_UNEVICTABLE_LRU
>>
>> logically, CONFIG_UNEVICTABLE_LRU doesn't depend on MMU.
>> but current code does by mistake. fix it.
>>
>>
>> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> ---
>> =C2=A0mm/Kconfig | =C2=A0 =C2=A01 -
>> =C2=A0mm/nommu.c | =C2=A0 24 ++++++++++++++++++++++++
>> =C2=A02 files changed, 24 insertions(+), 1 deletion(-)
>>
>> Index: b/mm/Kconfig
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> --- a/mm/Kconfig =C2=A0 =C2=A0 =C2=A02008-12-28 20:55:23.000000000 +0900
>> +++ b/mm/Kconfig =C2=A0 =C2=A0 =C2=A02008-12-28 21:24:08.000000000 +0900
>> @@ -212,7 +212,6 @@ config VIRT_TO_BUS
>> =C2=A0config UNEVICTABLE_LRU
>> =C2=A0 =C2=A0 =C2=A0 bool "Add LRU list to track non-evictable pages"
>> =C2=A0 =C2=A0 =C2=A0 default y
>> - =C2=A0 =C2=A0 depends on MMU
>> =C2=A0 =C2=A0 =C2=A0 help
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 Keeps unevictable pages off of the active an=
d inactive pageout
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 lists, so kswapd will not waste CPU time or =
have its balancing
>> Index: b/mm/nommu.c
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> --- a/mm/nommu.c =C2=A0 =C2=A0 =C2=A02008-12-25 08:26:37.000000000 +0900
>> +++ b/mm/nommu.c =C2=A0 =C2=A0 =C2=A02008-12-28 21:29:36.000000000 +0900
>> @@ -1521,3 +1521,27 @@ int access_process_vm(struct task_struct
>> =C2=A0 =C2=A0 =C2=A0 mmput(mm);
>> =C2=A0 =C2=A0 =C2=A0 return len;
>> =C2=A0}
>> +
>> +/*
>> + * =C2=A0LRU accounting for clear_page_mlock()
>> + */
>> +void __clear_page_mlock(struct page *page)
>> +{
>> + =C2=A0 =C2=A0 VM_BUG_ON(!PageLocked(page));
>> +
>> + =C2=A0 =C2=A0 if (!page->mapping) { =C2=A0 /* truncated ? */
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 dec_zone_page_state(page, NR_MLOCK);
>> + =C2=A0 =C2=A0 count_vm_event(UNEVICTABLE_PGCLEARED);
>> + =C2=A0 =C2=A0 if (!isolate_lru_page(page)) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 putback_lru_page(page);
>> + =C2=A0 =C2=A0 } else {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* We lost the race. th=
e page already moved to evictable list.
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (PageUnevictable(page))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
count_vm_event(UNEVICTABLE_PGSTRANDED);
>> + =C2=A0 =C2=A0 }
>> +}
>>
>>
>>
>>
>
>
> --
> Kinds Regards
> Minchan Kim
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =C2=A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>



--=20
Thanks,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
