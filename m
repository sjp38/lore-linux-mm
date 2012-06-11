Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id C7C346B0082
	for <linux-mm@kvack.org>; Sun, 10 Jun 2012 23:28:32 -0400 (EDT)
Received: by obbwd18 with SMTP id wd18so8050335obb.14
        for <linux-mm@kvack.org>; Sun, 10 Jun 2012 20:28:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FD55EA4.1070806@kernel.org>
References: <1338982770-2856-1-git-send-email-hao.bigrat@gmail.com>
	<4FD55EA4.1070806@kernel.org>
Date: Mon, 11 Jun 2012 11:28:31 +0800
Message-ID: <CAFZ0FUVAdPkfpsz4p3GPiC9Yuk1DzgAB_dPPmc22niSkuOc+Vw@mail.gmail.com>
Subject: Re: [PATCH] mm: fix ununiform page status when writing new file with
 small buffer
From: Robin Dong <hao.bigrat@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, Robin Dong <sanbai@taobao.com>

2012/6/11 Minchan Kim <minchan@kernel.org>:
> On 06/06/2012 08:39 PM, Robin Dong wrote:
>
>> From: Robin Dong <sanbai@taobao.com>
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
>> The page 1~13th will be added to lru_add_pvecs in write_begin() and will=
 *NOT* be added to
>> active_list even they have be accessed twice because they are not PageLR=
U(page).
>
>> But when page 14th comes, all pages will be moved from lru_add_pvecs to =
active_list
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
^^^^
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
inactive list
>
>> (by __lru_cache_add() ) in first write_begin(), now page 14th *is* PageL=
RU(page) and after
>> second write_end() it will be in active_list.
>
>>
>> In Hadoop environment, we do comes to this situation: after writing a fi=
le, we find
>> out that only 14th, 28th, 42th... page are in active_list and others in =
inactive_list. Now
>> kswaped works, shrinks the inactive_list, the file only have 14th, 28th.=
..pages in memory,
>
> =A0 ^^^^^
> =A0kswapd
>
>> the readahead request size will be broken to only 52k (13*4k), system's =
performance falls
>> dramatically.
>
>
> Good catch!
>
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
>> Signed-off-by: Robin Dong <sanbai@taobao.com>
>
>
> Reviewed-by: Minchan Kim <minchan@kernel.org>
>
> Nitpick:
> Please comment in function as well as description.
> It will prevent some guy restore original code for the consistency with o=
ther pagevec_add call sites.
>
> Thanks.

Thanks for your suggestion, I will send the second version ASAP
>
> --
> Kind regards,
> Minchan Kim



--=20
--
Best Regard
Robin Dong

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
