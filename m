Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 343706B00B5
	for <linux-mm@kvack.org>; Fri, 12 Nov 2010 02:25:04 -0500 (EST)
Received: by iwn9 with SMTP id 9so3272469iwn.14
        for <linux-mm@kvack.org>; Thu, 11 Nov 2010 23:25:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101111220553.64911bfd.akpm@linux-foundation.org>
References: <20101111075455.GA10210@amd>
	<20101111220553.64911bfd.akpm@linux-foundation.org>
Date: Fri, 12 Nov 2010 16:25:01 +0900
Message-ID: <AANLkTim4UoqvpH4g2Xb+rTTuf6WKjW_c62N57GRcNDm4@mail.gmail.com>
Subject: Re: [patch] mm: find_get_pages_contig fixlet
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@kernel.dk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Nov 12, 2010 at 3:05 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Thu, 11 Nov 2010 18:54:55 +1100 Nick Piggin <npiggin@kernel.dk> wrote:
>
>> Testing ->mapping and ->index without a ref is not stable as the page
>> may have been reused at this point.
>>
>> Signed-off-by: Nick Piggin <npiggin@kernel.dk>
>> ---
>> =A0mm/filemap.c | =A0 13 ++++++++++---
>> =A01 file changed, 10 insertions(+), 3 deletions(-)
>>
>> Index: linux-2.6/mm/filemap.c
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> --- linux-2.6.orig/mm/filemap.c =A0 =A0 =A0 2010-11-11 18:51:51.00000000=
0 +1100
>> +++ linux-2.6/mm/filemap.c =A0 =A02010-11-11 18:51:52.000000000 +1100
>> @@ -835,9 +835,6 @@ unsigned find_get_pages_contig(struct ad
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (radix_tree_deref_retry(page))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto restart;
>>
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (page->mapping =3D=3D NULL || page->index !=
=3D index)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> -
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!page_cache_get_speculative(page))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto repeat;
>>
>> @@ -847,6 +844,16 @@ unsigned find_get_pages_contig(struct ad
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto repeat;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>>
>> + =A0 =A0 =A0 =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* must check mapping and index after taking=
 the ref.
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* otherwise we can get both false positives=
 and false
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* negatives, which is just confusing to the=
 caller.
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (page->mapping =3D=3D NULL || page->index !=
=3D index) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 page_cache_release(page);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> +
>
> Dumb question: if it's been "reused" then what prevents the page from
> having a non-NULL ->mapping and a matching index?

Maybe

                /* Has the page moved? */
                if (unlikely(page !=3D *((void **)pages[i]))) {
                        page_cache_release(page);
                        goto repeat;
                }

If the page have been reused for other mapping and same index, the
page would be removed from radix tree slot of current mapping.
So radix tree slot of current mapping doesn't have a same page pointer
any more.
If I am wrong, Please correct me.

>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
