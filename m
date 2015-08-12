Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 220369003C7
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 05:13:46 -0400 (EDT)
Received: by igfj19 with SMTP id j19so9467312igf.1
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 02:13:45 -0700 (PDT)
Received: from BLU004-OMC1S35.hotmail.com (blu004-omc1s35.hotmail.com. [65.55.116.46])
        by mx.google.com with ESMTPS id f2si3481569igt.103.2015.08.12.02.13.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 12 Aug 2015 02:13:45 -0700 (PDT)
Message-ID: <BLU436-SMTP111993C22274095EC6F2FAE807E0@phx.gbl>
Subject: Re: [PATCH v2 5/5] mm/hwpoison: replace most of put_page in memory
 error handling by put_hwpoison_page
References: <1439206103-86829-1-git-send-email-wanpeng.li@hotmail.com>
 <BLU436-SMTP12740A47B6EBB7DF2F12A9280700@phx.gbl>
 <20150812085525.GD32192@hori1.linux.bs1.fc.nec.co.jp>
From: Wanpeng Li <wanpeng.li@hotmail.com>
Date: Wed, 12 Aug 2015 17:13:39 +0800
MIME-Version: 1.0
In-Reply-To: <20150812085525.GD32192@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 8/12/15 4:55 PM, Naoya Horiguchi wrote:
> On Mon, Aug 10, 2015 at 07:28:23PM +0800, Wanpeng Li wrote:
>> Replace most of put_page in memory error handling by put_hwpoison_page,
>> except the ones at the front of soft_offline_page since the page maybe
>> THP page and the get refcount in madvise_hwpoison is against the single
>> 4KB page instead of the logic in get_hwpoison_page.
>>
>> Signed-off-by: Wanpeng Li <wanpeng.li@hotmail.com>
> # Sorry for my late response.
>
> If I read correctly, get_user_pages_fast() (called by madvise_hwpoison)
> for a THP tail page takes a refcount from each of head and tail page.
> gup_huge_pmd() does this in the fast path, and get_page_foll() does this
> in the slow path (maybe via the following code path)
>
>   get_user_pages_unlocked
>     __get_user_pages_unlocked
>       __get_user_pages_locked
>         __get_user_pages
>           follow_page_mask
>             follow_trans_huge_pmd (with FOLL_GET set)
>               get_page_foll
>
> So this should be equivalent to what get_hwpoison_page() does for thp pages
> with regard to refcounting.
>
> And I'm expecting that a refcount taken by get_hwpoison_page() is released
> by put_hwpoison_page() even if the page's status is changed during error
> handling (the typical (or only?) case is successful thp split.)

Indeed. :-)

>
> So I think you can apply put_hwpoison_page() for 3 more callsites in
> mm/memory-failure.c.
>  - MF_MSG_POISONED_HUGE case

I have already done this in my patch.

>  - "soft offline: %#lx page already poisoned" case (you mentioned above)
>  - "soft offline: %#lx: failed to split THP" case (you mentioned above)

You are right, I will send a patch rebased on this one since they are
merged.

Regards,
Wanpeng Li

>
> Thanks,
> Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
