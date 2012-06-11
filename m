Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 5DFE56B0116
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 06:57:15 -0400 (EDT)
Received: by obbwd18 with SMTP id wd18so8725437obb.14
        for <linux-mm@kvack.org>; Mon, 11 Jun 2012 03:57:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FD5CC71.4060002@gmail.com>
References: <1339411335-23326-1-git-send-email-hao.bigrat@gmail.com>
	<4FD5CC71.4060002@gmail.com>
Date: Mon, 11 Jun 2012 18:57:14 +0800
Message-ID: <CAFZ0FUU_bvvZQMPRwTmN5Zy55Q-mv6Cyk7GKrsivvRMiXmkTHA@mail.gmail.com>
Subject: Re: [PATCH v2] mm: fix ununiform page status when writing new file
 with small buffer
From: Robin Dong <hao.bigrat@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: linux-mm@kvack.org, Robin Dong <sanbai@taobao.com>

2012/6/11 KOSAKI Motohiro <kosaki.motohiro@gmail.com>:
> (6/11/12 6:42 AM), Robin Dong wrote:
>> From: Robin Dong<sanbai@taobao.com>
>>
>> When writing a new file with 2048 bytes buffer, such as write(fd, buffer=
, 2048), it will
>> call generic_perform_write() twice for every page:
>>
>> =A0 =A0 =A0 write_begin
>> =A0 =A0 =A0 mark_page_accessed(page)
>> =A0 =A0 =A0 write_end
>>
>> =A0 =A0 =A0 write_begin
>> =A0 =A0 =A0 mark_page_accessed(page)
>> =A0 =A0 =A0 write_end
>>
>> The page 1~13th will be added to lru-pvecs in write_begin() and will *NO=
T* be added to
>> active_list even they have be accessed twice because they are not PageLR=
U(page).
>> But when page 14th comes, all pages in lru-pvecs will be moved to inacti=
ve_list
>> (by __lru_cache_add() ) in first write_begin(), now page 14th *is* PageL=
RU(page).
>> And after second write_end() only page 14th =A0will be in active_list.
>>
>> In Hadoop environment, we do comes to this situation: after writing a fi=
le, we find
>> out that only 14th, 28th, 42th... page are in active_list and others in =
inactive_list. Now
>> kswapd works, shrinks the inactive_list, the file only have 14th, 28th..=
.pages in memory,
>> the readahead request size will be broken to only 52k (13*4k), system's =
performance falls
>> dramatically.
>>
>> This problem can also replay by below steps (the machine has 8G memory):
>>
>> =A0 =A0 =A0 1. dd if=3D/dev/zero of=3D/test/file.out bs=3D1024 count=3D1=
048576
>> =A0 =A0 =A0 2. cat another 7.5G file to /dev/null
>> =A0 =A0 =A0 3. vmtouch -m 1G -v /test/file.out, it will show:
>>
>> =A0 =A0 =A0 /test/file.out
>> =A0 =A0 =A0 [oooooooooooooooooooOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO=
O] 187847/262144
>>
>> =A0 =A0 =A0 the 'o' means same pages are in memory but same are not.
>>
>>
>> The solution for this problem is simple: the 14th page should be added t=
o lru_add_pvecs
>> before mark_page_accessed() just as other pages.
>>
>> Signed-off-by: Robin Dong<sanbai@taobao.com>
>> Reviewed-by: Minchan Kim<minchan@kernel.org>
>> ---
>> =A0 mm/swap.c | =A0 =A08 +++++++-
>> =A0 1 file changed, 7 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/swap.c b/mm/swap.c
>> index 4e7e2ec..08e83ad 100644
>> --- a/mm/swap.c
>> +++ b/mm/swap.c
>> @@ -394,13 +394,19 @@ void mark_page_accessed(struct page *page)
>> =A0 }
>> =A0 EXPORT_SYMBOL(mark_page_accessed);
>>
>> +/*
>> + * Check pagevec space before adding new page into as
>> + * it will prevent ununiform page status in
>> + * mark_page_accessed() after __lru_cache_add()
>> + */
>> =A0 void __lru_cache_add(struct page *page, enum lru_list lru)
>> =A0 {
>> =A0 =A0 =A0 struct pagevec *pvec =3D&get_cpu_var(lru_add_pvecs)[lru];
>>
>> =A0 =A0 =A0 page_cache_get(page);
>> - =A0 =A0 if (!pagevec_add(pvec, page))
>> + =A0 =A0 if (!pagevec_space(pvec))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 __pagevec_lru_add(pvec, lru);
>> + =A0 =A0 pagevec_add(pvec, page);
>> =A0 =A0 =A0 put_cpu_var(lru_add_pvecs);
>> =A0 }
>> =A0 EXPORT_SYMBOL(__lru_cache_add);
>
> No change from v1?
>

Adding function comment from Minchan Kim's suggestion.

I know that the best solution may be removing all pagevecs completely,
 as you say,
but removing pagevecs would be a very very long-term subject (I guess)  bec=
ause
many developers will argue it again and again before coming to compromise.
I don't think I have the power to make a so big change,
so...."hacking" the __lur_cache_add
would be a good solution recently, at least in many Hadoop Clusters  :)

--=20
--
Best Regard
Robin Dong

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
