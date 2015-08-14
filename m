Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f50.google.com (mail-oi0-f50.google.com [209.85.218.50])
	by kanga.kvack.org (Postfix) with ESMTP id 713656B0038
	for <linux-mm@kvack.org>; Fri, 14 Aug 2015 05:01:41 -0400 (EDT)
Received: by oiew67 with SMTP id w67so22160890oie.2
        for <linux-mm@kvack.org>; Fri, 14 Aug 2015 02:01:41 -0700 (PDT)
Received: from BLU004-OMC1S33.hotmail.com (blu004-omc1s33.hotmail.com. [65.55.116.44])
        by mx.google.com with ESMTPS id yr17si3758752obc.2.2015.08.14.02.01.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 14 Aug 2015 02:01:40 -0700 (PDT)
Message-ID: <BLU436-SMTP2235CDFEDA4DEB534BF8C85807C0@phx.gbl>
Subject: Re: [PATCH] mm/hwpoison: fix race between soft_offline_page and
 unpoison_memory
References: <BLU436-SMTP256072767311DFB0FD3AE1B807D0@phx.gbl>
 <20150813085332.GA30163@hori1.linux.bs1.fc.nec.co.jp>
 <BLU437-SMTP1006340696EDBC91961809807D0@phx.gbl>
 <20150813100407.GA2993@hori1.linux.bs1.fc.nec.co.jp>
 <BLU436-SMTP1366B3FB4A3904EBDAE6BF9807D0@phx.gbl>
 <20150814041939.GA9951@hori1.linux.bs1.fc.nec.co.jp>
 <BLU436-SMTP110412F310BD1723C6F1C3E807C0@phx.gbl>
 <20150814072649.GA31021@hori1.linux.bs1.fc.nec.co.jp>
 <BLU437-SMTP24AA9CF28EF66D040D079B807C0@phx.gbl>
 <BLU436-SMTP11907D46F39F24F62D7E440807C0@phx.gbl>
 <20150814083818.GB6956@hori1.linux.bs1.fc.nec.co.jp>
From: Wanpeng Li <wanpeng.li@hotmail.com>
Date: Fri, 14 Aug 2015 17:01:34 +0800
MIME-Version: 1.0
In-Reply-To: <20150814083818.GB6956@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 8/14/15 4:38 PM, Naoya Horiguchi wrote:
> On Fri, Aug 14, 2015 at 03:59:21PM +0800, Wanpeng Li wrote:
>> On 8/14/15 3:54 PM, Wanpeng Li wrote:
>>> [...]
>>>> OK, then I rethink of handling the race in unpoison_memory().
>>>>
>>>> Currently properly contained/hwpoisoned pages should have page refcount 1
>>>> (when the memory error hits LRU pages or hugetlb pages) or refcount 0
>>>> (when the memory error hits the buddy page.) And current unpoison_memory()
>>>> implicitly assumes this because otherwise the unpoisoned page has no place
>>>> to go and it's just leaked.
>>>> So to avoid the kernel panic, adding prechecks of refcount and mapcount
>>>> to limit the page to unpoison for only unpoisonable pages looks OK to me.
>>>> The page under soft offlining always has refcount >=2 and/or mapcount > 0,
>>>> so such pages should be filtered out.
>>>>
>>>> Here's a patch. In my testing (run soft offline stress testing then repeat
>>>> unpoisoning in background,) the reported (or similar) bug doesn't happen.
>>>> Can I have your comments?
>>> As page_action() prints out page maybe still referenced by some users,
>>> however, PageHWPoison has already set. So you will leak many poison pages.
>>>
>> Anyway, the bug is still there.
>>
>> [  944.387559] BUG: Bad page state in process expr  pfn:591e3
>> [  944.393053] page:ffffea00016478c0 count:-1 mapcount:0 mapping:
>> (null) index:0x2
>> [  944.401147] flags: 0x1fffff80000000()
>> [  944.404819] page dumped because: nonzero _count
> Hmm, no luck :(
>
> To investigate more, I'd like to test the exactly same kernel as yours, so
> could you share the kernel info (.config and base kernel and what patches
> you applied)? or pushing your tree somewhere like github?
> # if you like, sending to me privately is fine.
>
> I think that I tested v4.2-rc6 + <your recent 7 hwpoison patches> +
> "mm/hwpoison: fix race between soft_offline_page and unpoison_memory",
> but I experienced some conflict in applying your patches for some reason,
> so it might happen that we are testing on different kernels.

I don't have special config and tree, the latest mmotm has already
merged my recent 8 hwpoison patches, you can test based on it.

Regards,
Wanpeng Li

>
> Mine is here:
>   https://github.com/Naoya-Horiguchi/linux v4.2-rc6/fix_race_soft_offline_unpoison
>
> Thanks,
> Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
