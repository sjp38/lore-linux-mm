Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f51.google.com (mail-oi0-f51.google.com [209.85.218.51])
	by kanga.kvack.org (Postfix) with ESMTP id CD0126B0253
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 05:16:31 -0400 (EDT)
Received: by oihn130 with SMTP id n130so84877234oih.2
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 02:16:31 -0700 (PDT)
Received: from BLU004-OMC1S17.hotmail.com (blu004-omc1s17.hotmail.com. [65.55.116.28])
        by mx.google.com with ESMTPS id ru3si13957012obc.104.2015.08.10.02.16.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 10 Aug 2015 02:16:31 -0700 (PDT)
Message-ID: <BLU437-SMTP7349274677DC2936F6E47180700@phx.gbl>
Subject: Re: [PATCH 1/2] mm/hwpoison: fix fail to split THP w/ refcount held
References: <BLU436-SMTP188C7B16D46EEDEB4A9B9F980700@phx.gbl>
 <20150810081019.GA21282@hori1.linux.bs1.fc.nec.co.jp>
 <BLU436-SMTP6090BE1965823BCE9FBC4580700@phx.gbl>
 <20150810085047.GC21282@hori1.linux.bs1.fc.nec.co.jp>
From: Wanpeng Li <wanpeng.li@hotmail.com>
Date: Mon, 10 Aug 2015 17:15:14 +0800
MIME-Version: 1.0
In-Reply-To: <20150810085047.GC21282@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>



On 8/10/15 4:50 PM, Naoya Horiguchi wrote:
> On Mon, Aug 10, 2015 at 04:29:18PM +0800, Wanpeng Li wrote:
>> Hi Naoya,
>>
>> On 8/10/15 4:10 PM, Naoya Horiguchi wrote:
>>> On Mon, Aug 10, 2015 at 02:32:30PM +0800, Wanpeng Li wrote:
>>>> THP pages will get a refcount in madvise_hwpoison() w/ MF_COUNT_INCREASED
>>>> flag, however, the refcount is still held when fail to split THP pages.
>>>>
>>>> Fix it by reducing the refcount of THP pages when fail to split THP.
>>>>
>>>> Signed-off-by: Wanpeng Li <wanpeng.li@hotmail.com>
>>> It seems that the same conditional put_page() would be added to
>>> "soft offline: %#lx page already poisoned" branch too, right?
>> PageHWPoison() is just called before the soft_offline_page() in
>> madvise_hwpoion(). I think the PageHWPosion()
>> check in soft_offline_page() makes more sense for the other
>> soft_offline_page() callsites which don't have the
>> refcount held.
> What I am worried is a race like below:
>
>   CPU0                              CPU1
>
>   madvise_hwpoison
>   get_user_pages_fast
>   PageHWPoison check (false)
>                                     memory_failure
>                                     TestSetPageHWPoison
>   soft_offline_page
>   PageHWPoison check (true)
>   return -EBUSY (without put_page)

Indeed, there is a race even through it is rared happen.

>
> It's rare and madvise_hwpoison() is testing feature, so this never causes
> real problems in production systems, so it's not a big deal.
> My suggestion is maybe just for code correctness thing ...

Thanks for your proposal, I will add your suggestion in v2 and post out
after we have a uniform solution for patch 2/2. :)

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
