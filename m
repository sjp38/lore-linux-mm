Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 0E8436B0031
	for <linux-mm@kvack.org>; Mon, 10 Mar 2014 02:29:09 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id fb1so6855043pad.15
        for <linux-mm@kvack.org>; Sun, 09 Mar 2014 23:29:09 -0700 (PDT)
Received: from song.cn.fujitsu.com ([222.73.24.84])
        by mx.google.com with ESMTP id tm9si15731687pab.18.2014.03.09.23.29.06
        for <linux-mm@kvack.org>;
        Sun, 09 Mar 2014 23:29:09 -0700 (PDT)
Message-ID: <531D5B84.6080203@cn.fujitsu.com>
Date: Mon, 10 Mar 2014 14:28:20 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH][RFC] mm: warning message for vm_map_ram about vm size
References: <001a01cf3c1d$310716a0$931543e0$@lge.com> <20140310054743.GH14370@bbox>
In-Reply-To: <20140310054743.GH14370@bbox>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Gioh Kim <gioh.kim@lge.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Joonsoo Kim' <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, =?UTF-8?B?7J206rG07Zi4?= <gunho.lee@lge.com>, chanho.min@lge.com, Johannes Weiner <hannes@cmpxchg.org>

On 03/10/2014 01:47 PM, Minchan Kim wrote:
> Hi Giho,
>=20
> On Mon, Mar 10, 2014 at 01:57:07PM +0900, Gioh Kim wrote:
>> Hi,
>>
>> I have a failure of allocation of virtual memory on ARMv7 based platform.
>>
>> I called alloc=5Fpage()/vm=5Fmap=5Fram() for allocation/mapping pages.
>> Virtual memory space exhausting problem occurred.
>> I checked virtual memory space and found that there are too many 4MB chu=
nks.
>>
>> I thought that if just one page in the 4MB chunk lives long,=20
>> the entire chunk cannot be freed. Therefore new chunk is created again a=
nd again.
>>
>> In my opinion, the vm=5Fmap=5Fram() function should be used for temporar=
y mapping
>> and/or short term memory mapping. Otherwise virtual memory is wasted.
>>
>> I am not sure if my opinion is correct. If it is, please add some warnin=
g message
>> about the vm=5Fmap=5Fram().
>>
>>
>>
>> ---8<---
>>
>> Subject: [PATCH] mm: warning comment for vm=5Fmap=5Fram
>>
>> vm=5Fmap=5Fram can occur locking of virtual memory space
>> because if only one page lives long in one vmap=5Fblock,
>> it takes 4MB (1024-times more than one page) space.
>=20
> For clarification, vm=5Fmap=5Fram has fragment problem because it
> couldn't purge a chunk(ie, 4M address space) if there is a pinning
> object in that addresss space so it could consume all VMALLOC
> address space easily.
>=20
> We can fix the fragementaion problem with using vmap instead of
> vm=5Fmap=5Fram but it wouldn't a good solution because vmap is much
> slower than vm=5Fmap=5Fram for VMAP=5FMAX=5FALLOC below. In my x86 machin=
e,
> vm=5Fmap=5Fram is 5 times faster than vmap.
>=20
> AFAICR, some proprietary GPU driver uses that function heavily so
> performance would be really important so I want to stick to use
> vm=5Fmap=5Fram.
>=20
> Another option is that caller should separate long-life and short-life
> object and use vmap for long-life but vm=5Fmap=5Fram for short-life.
> But it's not a good solution because it's hard for allocator layer
> to detect it that how customer lives with the object.

Indeed. So at least the note comment should be added.

>=20
> So I thought to fix that problem with revert [1] and adding more
> logic to solve fragmentation problem and make bitmap search
> operation more efficient by caching the hole. It might handle
> fragmentation at the moment but it would make more IPI storm for
> TLB flushing as time goes by so that it would mitigate API itself
> so using for only temporal object is too limited but it's best at the
> moment. I am supporting your opinion.
>=20
> Let's add some notice message to user.
>=20
> [1] [3fcd76e8028, mm/vmalloc.c: remove dead code in vb=5Falloc]
>=20
>>
>> Change-Id: I6f5919848cf03788b5846b7d850d66e4d93ac39a
>> Signed-off-by: Gioh Kim <gioh.kim@lge.com>
>> ---
>>  mm/vmalloc.c |    4 ++++
>>  1 file changed, 4 insertions(+)
>>
>> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>> index 0fdf968..2de1d1b 100644
>> --- a/mm/vmalloc.c
>> +++ b/mm/vmalloc.c
>> @@ -1083,6 +1083,10 @@ EXPORT=5FSYMBOL(vm=5Funmap=5Fram);
>>   * @node: prefer to allocate data structures on this node
>>   * @prot: memory protection to use. PAGE=5FKERNEL for regular RAM
>>   *
>> + * This function should be used for TEMPORARY mapping. If just one page=
 lives i
>> + * long, it would occupy 4MB vm size permamently. 100 pages (just 400KB=
) could
>> + * takes 400MB with bad luck.
>> + *
>=20
>     If you use this function for below VMAP=5FMAX=5FALLOC pages, it could=
 be faster
>     than vmap so it's good but if you mix long-life and short-life object
>     with vm=5Fmap=5Fram, it could consume lots of address space by fragme=
ntation(
>     expecially, 32bit machine) so you could see failure in the end.
>     So, please use this function for short-life object.

Minchan's is better. So I suggest Giho post another patch with this comment
and take what Minchan said above to the commit log. And you can feel free to
add:

Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

Thanks.

>=20
>>   * Returns: a pointer to the address that has been mapped, or %NULL on =
failure
>>   */
>>  void *vm=5Fmap=5Fram(struct page **pages, unsigned int count, int node,=
 pgprot=5Ft prot)
>> --
>> 1.7.9.5
>>
>> Gioh Kim / =EA=B9=80 =EA=B8=B0 =EC=98=A4
>> Research Engineer
>> Advanced OS Technology Team
>> Software Platform R&D Lab.
>> Mobile: 82-10-7322-5548 =20
>> E-mail: gioh.kim@lge.com=20
>> 19, Yangjae-daero 11gil
>> Seocho-gu, Seoul 137-130, Korea
>>
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>=20


--=20
Thanks.
Zhang Yanfei
=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
