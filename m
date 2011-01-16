Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 530BE8D0039
	for <linux-mm@kvack.org>; Sun, 16 Jan 2011 00:17:11 -0500 (EST)
Received: by fxm12 with SMTP id 12so4609951fxm.14
        for <linux-mm@kvack.org>; Sat, 15 Jan 2011 21:17:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1101141445070.5406@sister.anvils>
References: <1294997421-8971-1-git-send-email-b32955@freescale.com>
	<alpine.LSU.2.00.1101141445070.5406@sister.anvils>
Date: Sun, 16 Jan 2011 13:17:05 +0800
Message-ID: <AANLkTikV_u0+_hoonZn9aVUfDYLOr4xF38qjqgYOdQ4Z@mail.gmail.com>
Subject: Re: [PATCH] swap : check the return value of swap_readpage()
From: Huang Shijie <shijie8@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Huang Shijie <b32955@freescale.com>, akpm@linux-foundation.org, linux-mm@kvack.org, b20596@freescale.com
List-ID: <linux-mm.kvack.org>

>
>> If swap_readpage() returns -ENOMEM, the read_swap_cache_async()
>> still returns the `new_page` which has nothing. The caller will
>> do some wrong operations on the `new_page` such as copy.
>>
>
> But what's really wrong is not to be checking PageUptodate.
> Looks like swapoff's try_to_unuse() never checked it (I'm largely
> guilty of that), and my ksm_does_need_to_copy() would blindly copy
> (from a !PageUptodate to a PageUptodate), averting the PageUptodate
> check which comes later in do_swap_page().
>

yes.

 I noticed that your  ksm_does_need_to_copy()  does not check the
PageUptodate(), and
copy the data. Is it good you do so?


>
>> The patch fixs the problem.
>>
>
> It may fix a part of the problem, but - forgive me for saying! -
> your patch is not so beautiful that I want to push it as is.
>
> I'm more worried by the cases when the read gets an error and fails:
> we ought to be looking at what filemap.c does in it !PageUptodate case,
> and following a similar strategy (perhaps we shall want to distinguish
> the ENOMEM case, perhaps not: depends on the implementation).
>

IMHO, it's better to  distinguish the ENOMEN case as soon as possible.
Following the similar strategy in filemap.c only makes the situation more
complicated. Maybe I am not catching your meaning.


> Is this ENOMEM case something you noticed by looking at the source,
> or something that has hit you in practice? =C2=A0If the latter, then it's
> more urgent to fix it: but I'd be wondering how it comes about that
> bio's mempools have let you down, and even their GFP_KERNEL allocation
> is failing?
>
>

Do not worry :)   I just noticed it by reading the code.



>> Also remove the unlock_ page() in swap_readpage() in the wrong case
>> , since __delete_from_swap_cache() needs a locked page.
>
> That change is only required because we're not checking PageUptodate
> properly everywhere.
>

Thanks  a lot

Huang Shijie



> Hugh
>
>>
>> Signed-off-by: Huang Shijie <b32955@freescale.com>
>> ---
>> =C2=A0mm/page_io.c =C2=A0 =C2=A0| =C2=A0 =C2=A01 -
>> =C2=A0mm/swap_state.c | =C2=A0 12 +++++++-----
>> =C2=A02 files changed, 7 insertions(+), 6 deletions(-)
>>
>> diff --git a/mm/page_io.c b/mm/page_io.c
>> index 2dee975..5c759f2 100644
>> --- a/mm/page_io.c
>> +++ b/mm/page_io.c
>> @@ -124,7 +124,6 @@ int swap_readpage(struct page *page)
>> =C2=A0 =C2=A0 =C2=A0 VM_BUG_ON(PageUptodate(page));
>> =C2=A0 =C2=A0 =C2=A0 bio =3D get_swap_bio(GFP_KERNEL, page, end_swap_bio=
_read);
>> =C2=A0 =C2=A0 =C2=A0 if (bio =3D=3D NULL) {
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unlock_page(page);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D -ENOMEM;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;
>> =C2=A0 =C2=A0 =C2=A0 }
>> diff --git a/mm/swap_state.c b/mm/swap_state.c
>> index 5c8cfab..3bd7238 100644
>> --- a/mm/swap_state.c
>> +++ b/mm/swap_state.c
>> @@ -331,16 +331,18 @@ struct page *read_swap_cache_async(swp_entry_t ent=
ry, gfp_t gfp_mask,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __set_page_locked(new_p=
age);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 SetPageSwapBacked(new_p=
age);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 err =3D __add_to_swap_c=
ache(new_page, entry);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 radix_tree_preload_end();
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (likely(!err)) {
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
radix_tree_preload_end();
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 /*
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0* Initiate read into locked page and return.
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0*/
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
lru_cache_add_anon(new_page);
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
swap_readpage(new_page);
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
return new_page;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
err =3D swap_readpage(new_page);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
if (likely(!err)) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 lru_cache_add_anon(new_page);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 return new_page;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
}
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
__delete_from_swap_cache(new_page);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 radix_tree_preload_end();
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ClearPageSwapBacked(new=
_page);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __clear_page_locked(new=
_page);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
>> --
>> 1.7.3.2
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =C2=A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
