Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A54516B0071
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 11:07:21 -0500 (EST)
Received: by pwj10 with SMTP id 10so3607019pwj.6
        for <linux-mm@kvack.org>; Wed, 13 Jan 2010 08:07:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100113155503.GA2902@hack>
References: <3a3680031001130654q1928df60pde0e3706ea2461c@mail.gmail.com>
	 <20100113155503.GA2902@hack>
Date: Thu, 14 Jan 2010 00:07:19 +0800
Message-ID: <3a3680031001130807nafe1246u141438935fe5fab@mail.gmail.com>
Subject: Re: [PATCH 3/3] mm: remove function free_hot_page
From: Li Hong <lihong.hi@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: =?ISO-8859-1?Q?Am=E9rico_Wang?= <xiyou.wangcong@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
List-ID: <linux-mm.kvack.org>

I just think it is needless to add a simple wrap function here whether
it is inlined
or not.

-LH

2010/1/13 Am=E9rico Wang <xiyou.wangcong@gmail.com>:
> On Wed, Jan 13, 2010 at 10:54:50PM +0800, Li Hong wrote:
>>Now fuction 'free_hot_page' is just a wrap of ' free_hot_cold_page' with
>>parameter 'cold =3D 0'. After adding a clear comment for 'free_hot_cold_p=
age', it
>>is reasonable to remove a level of call.
>
> How? The compiler can certainly inline it.
>
>>
>>Signed-off-by: Li Hong <lihong.hi@gmail.com>
>>---
>> mm/page_alloc.c | =A0 =A08 ++------
>> mm/swap.c =A0 =A0 =A0 | =A0 =A02 +-
>> 2 files changed, 3 insertions(+), 7 deletions(-)
>>
>>diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>index 175dd36..c88e03d 100644
>>--- a/mm/page_alloc.c
>>+++ b/mm/page_alloc.c
>>@@ -1073,6 +1073,7 @@ void mark_free_pages(struct zone *zone)
>>
>> /*
>> =A0* Free a 0-order page
>>+ * cold =3D=3D 1 ? free a cold page : free a hot page
>> =A0*/
>> static void free_hot_cold_page(struct page *page, int cold)
>> {
>>@@ -1135,11 +1136,6 @@ out:
>> =A0 =A0 =A0 =A0put_cpu();
>> }
>>
>>-void free_hot_page(struct page *page)
>>-{
>>- =A0 =A0 =A0 free_hot_cold_page(page, 0);
>>-}
>>-
>> /*
>> =A0* split_page takes a non-compound higher-order page, and splits it in=
to
>> =A0* n (1<<order) sub-pages: page[0..n]
>>@@ -2014,7 +2010,7 @@ void __free_pages(struct page *page, unsigned int o=
rder)
>> {
>> =A0 =A0 =A0 =A0if (put_page_testzero(page)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (order =3D=3D 0)
>>- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_hot_page(page);
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_hot_cold_page(page, 0)=
;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0else
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__free_pages_ok(page, ord=
er);
>> =A0 =A0 =A0 =A0}
>>diff --git a/mm/swap.c b/mm/swap.c
>>index 308e57d..9036b89 100644
>>--- a/mm/swap.c
>>+++ b/mm/swap.c
>>@@ -55,7 +55,7 @@ static void __page_cache_release(struct page *page)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0del_page_from_lru(zone, page);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unlock_irqrestore(&zone->lru_lock, f=
lags);
>> =A0 =A0 =A0 =A0}
>>- =A0 =A0 =A0 free_hot_page(page);
>>+ =A0 =A0 =A0 free_hot_cold_page(page, 0);
>> }
>>
>> static void put_compound_page(struct page *page)
>>--
>>1.6.3.3
>>--
>>To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
>>the body of a message to majordomo@vger.kernel.org
>>More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>>Please read the FAQ at =A0http://www.tux.org/lkml/
>
> --
> Live like a child, think like the god.
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
