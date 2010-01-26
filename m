Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id DDC886B004D
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 03:21:01 -0500 (EST)
Received: by pxi5 with SMTP id 5so999544pxi.12
        for <linux-mm@kvack.org>; Tue, 26 Jan 2010 00:21:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100126155852.1D53.A69D9226@jp.fujitsu.com>
References: <cf18f8341001252256q65b90d76vfe3094a1bb5424e7@mail.gmail.com>
	 <20100126155852.1D53.A69D9226@jp.fujitsu.com>
Date: Tue, 26 Jan 2010 16:20:59 +0800
Message-ID: <cf18f8341001260020p44cec4abq24a354251c78dacb@mail.gmail.com>
Subject: Re: [PATCH] page_alloc: change bit ops 'or' to logical ops in
	free/new page check
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, hugh.dickins@tiscali.co.uk, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Tue, Jan 26, 2010 at 3:00 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> Using logical 'or' in =C2=A0function free_page_mlock() and
>> check_new_page() makes code clear and
>> sometimes more effective (Because it can ignore other condition
>> compare if the first condition
>> is already true).
>>
>> It's Nick's patch "mm: microopt conditions" changed it from logical
>> ops to bit ops.
>> Maybe I didn't consider something. If so, please let me know and just
>> ignore this patch.
>> Thanks!
>
> I think current code is intentional. On modern cpu, bit-or is faster than
> logical or.

Hmm, but if use logical ops it can be optimized by the compiler.
In this situation, eg, if page_mapcount(page) is true, then other compareti=
on
including atomic_read() willn't be called anymore.
If use bit ops, atomic_read() and other comparetion will still be called.

I am not sure whether cpu and compiler will optimize it like the
logical bit ops.
If there will, the current code is intertional, else i think the
logical ops is better.
thanks!

-       if (unlikely(page_mapcount(page) |
-               (page->mapping !=3D NULL)  |
-               (atomic_read(&page->_count) !=3D 0) |
+       if (unlikely(page_mapcount(page) ||
+               (page->mapping !=3D NULL)  ||
+               (atomic_read(&page->_count) !=3D 0) ||
               (page->flags & PAGE_FLAGS_CHECK_AT_FREE))) {


>
> Do you have opposite benchmark number result?
>

I haven't now :-).  I will test it when I have enough time.

>
>>
>> Signed-off-by: Bob Liu <lliubbo@gmail.com>
>> ---
>>
>> diff --git mm/page_alloc.c mm/page_alloc.c
>> index 05ae4e0..91ece14 100644
>> --- mm/page_alloc.c
>> +++ mm/page_alloc.c
>> @@ -500,9 +500,9 @@ static inline void free_page_mlock(struct page *page=
)
>>
>> =C2=A0static inline int free_pages_check(struct page *page)
>> =C2=A0{
>> - =C2=A0 =C2=A0 =C2=A0 if (unlikely(page_mapcount(page) |
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (page->mapping !=3D N=
ULL) =C2=A0|
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (atomic_read(&page->_=
count) !=3D 0) |
>> + =C2=A0 =C2=A0 =C2=A0 if (unlikely(page_mapcount(page) ||
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (page->mapping !=3D N=
ULL) =C2=A0||
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (atomic_read(&page->_=
count) !=3D 0) ||
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (page->flags & P=
AGE_FLAGS_CHECK_AT_FREE))) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 bad_page(page);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 1;
>> @@ -671,9 +671,9 @@ static inline void expand(struct zone *zone, struct =
page *pa
>> =C2=A0 */
>> =C2=A0static inline int check_new_page(struct page *page)
>> =C2=A0{
>> - =C2=A0 =C2=A0 =C2=A0 if (unlikely(page_mapcount(page) |
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (page->mapping !=3D N=
ULL) =C2=A0|
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (atomic_read(&page->_=
count) !=3D 0) =C2=A0|
>> + =C2=A0 =C2=A0 =C2=A0 if (unlikely(page_mapcount(page) ||
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (page->mapping !=3D N=
ULL) =C2=A0||
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (atomic_read(&page->_=
count) !=3D 0) =C2=A0||
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (page->flags & P=
AGE_FLAGS_CHECK_AT_PREP))) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 bad_page(page);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 1;
>>

--=20
Regards,
-Bob Liu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
