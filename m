Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 58DA06B0032
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 08:52:59 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id fp1so25821843pdb.4
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 05:52:59 -0800 (PST)
Received: from BLU004-OMC2S36.hotmail.com (blu004-omc2s36.hotmail.com. [65.55.111.111])
        by mx.google.com with ESMTPS id v8si5947554pdn.49.2015.01.28.05.52.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 28 Jan 2015 05:52:58 -0800 (PST)
Message-ID: <BLU436-SMTP254C6829A217B25FECC255583330@phx.gbl>
Date: Wed, 28 Jan 2015 21:51:45 +0800
From: Zhang Yanfei <zhangyanfei.ok@hotmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3] mm: incorporate read-only pages into transparent huge
 pages
References: <1422380353-4407-1-git-send-email-ebru.akagunduz@gmail.com> <20150128002711.GY11755@redhat.com>
In-Reply-To: <20150128002711.GY11755@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kirill@shutemov.name, mhocko@suse.cz, mgorman@suse.de, rientjes@google.com, sasha.levin@oracle.com, hughd@google.com, hannes@cmpxchg.org, vbabka@suse.cz, linux-kernel@vger.kernel.org, riel@redhat.com, zhangyanfei.linux@aliyun.com

Hello

=E5=9C=A8 2015/1/28 8:27=2C Andrea Arcangeli =E5=86=99=E9=81=93:
> On Tue=2C Jan 27=2C 2015 at 07:39:13PM +0200=2C Ebru Akagunduz wrote:
>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>> index 817a875..17d6e59 100644
>> --- a/mm/huge_memory.c
>> +++ b/mm/huge_memory.c
>> @@ -2148=2C17 +2148=2C18 @@ static int __collapse_huge_page_isolate(stru=
ct vm_area_struct *vma=2C
>>  {
>>  	struct page *page=3B
>>  	pte_t *_pte=3B
>> -	int referenced =3D 0=2C none =3D 0=3B
>> +	int referenced =3D 0=2C none =3D 0=2C ro =3D 0=2C writable =3D 0=3B
> So your "writable" addition is enough and simpler/better than "ro"
> counting. Once "ro" is removed "writable" can actually start to make a
> difference (at the moment it does not).
>
> I'd suggest to remove "ro".
>
> The sysctl was there only to reduce the memory footprint but
> collapsing readonly swapcache won't reduce the memory footprint. So it
> may have been handy before but this new "writable" looks better now
> and keeping both doesn't help (keeping "ro" around prevents "writable"
> to make a difference).

Agreed.

>
>> @@ -2179=2C6 +2177=2C34 @@ static int __collapse_huge_page_isolate(struc=
t vm_area_struct *vma=2C
>>  		 */
>>  		if (!trylock_page(page))
>>  			goto out=3B
>> +
>> +		/*
>> +		 * cannot use mapcount: can't collapse if there's a gup pin.
>> +		 * The page must only be referenced by the scanned process
>> +		 * and page swap cache.
>> +		 */
>> +		if (page_count(page) !=3D 1 + !!PageSwapCache(page)) {
>> +			unlock_page(page)=3B
>> +			goto out=3B
>> +		}
>> +		if (!pte_write(pteval)) {
>> +			if (++ro > khugepaged_max_ptes_none) {
>> +				unlock_page(page)=3B
>> +				goto out=3B
>> +			}
>> +			if (PageSwapCache(page) && !reuse_swap_page(page)) {
>> +				unlock_page(page)=3B
>> +				goto out=3B
>> +			}
>> +			/*
>> +			 * Page is not in the swap cache=2C and page count is
>> +			 * one (see above). It can be collapsed into a THP.
>> +			 */
>> +			VM_BUG_ON(page_count(page) !=3D 1)=3B
> In an earlier email I commented on this suggestion you received during
> previous code review: the VM_BUG_ON is not ok because it can generate
> false positives.
>
> It's perfectly ok if page_count is not 1 if the page is isolated by
> another CPU (another cpu calling isolate_lru_page).
>
> The page_count check there is to ensure there are no gup-pins=2C and
> that is achieved during the check. The VM may still mangle the
> page_count and it's ok (the page count taken by the VM running in
> another CPU doesn't need to be transferred to the collapsed THP).
>
> In short=2C the check "page_count(page) !=3D 1 + !!PageSwapCache(page)"
> doesn't imply that the page_count cannot change. It only means at any
> given time there was no gup-pin at the very time of the check. It also
> means there were no other VM pin=2C but what we care about is only the
> gup-pin. The VM LRU pin can still be taken after the check and it's
> ok. The GUP pin cannot be taken because we stopped all gup so we're
> safe if the check passes.
>
> So you can simply delete the VM_BUG_ON=2C the earlier code there=2C was f=
ine.

So IMO=2C the comment should also be removed or changed as it may
mislead someone again later.

Thanks
Zhang

>
>> +		} else {
>> +			writable =3D 1=3B
>> +		}
>> +
> I suggest to make writable a bool and use writable =3D false to init=2C
> and writable =3D true above.
>
> When a value can only be 0|1 bool is better (it can be casted and
> takes the same memory as an int=2C it just allows the compiler to be
> more strict and the fact it makes the code more self explanatory).
>
>> +			if (++ro > khugepaged_max_ptes_none)
>> +				goto out_unmap=3B
> As mentioned above the ro counting can go=2C and we can keep only
> your new writable addition=2C as mentioned above.
>
> Thanks=2C
> Andrea
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
