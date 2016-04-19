Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4011F6B007E
	for <linux-mm@kvack.org>; Tue, 19 Apr 2016 01:54:34 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id q8so4419554lfe.3
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 22:54:34 -0700 (PDT)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id ez7si68802735wjd.197.2016.04.18.22.54.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Apr 2016 22:54:32 -0700 (PDT)
Received: by mail-wm0-x22f.google.com with SMTP id u206so10461497wme.1
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 22:54:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160418231551.GA18493@hori1.linux.bs1.fc.nec.co.jp>
References: <146097982568.15733.13924990169211134049.stgit@buzz>
	<20160418231551.GA18493@hori1.linux.bs1.fc.nec.co.jp>
Date: Tue, 19 Apr 2016 08:54:32 +0300
Message-ID: <CALYGNiMHihSgodPCOxMx4y-Nk8xuv8JD33-4GQzfMgk-_78xpQ@mail.gmail.com>
Subject: Re: [PATCH] mm/memory-failure: fix race with compound page split/merge
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Apr 19, 2016 at 2:15 AM, Naoya Horiguchi
<n-horiguchi@ah.jp.nec.com> wrote:
> # CCed Andrew,
>
> On Mon, Apr 18, 2016 at 02:43:45PM +0300, Konstantin Khlebnikov wrote:
>> Get_hwpoison_page() must recheck relation between head and tail pages.
>>
>> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
>
> Looks good to me. Without this recheck, the race causes kernel to pin
> an irrelevant page, and finally makes kernel crash for refcount mismcach...

Yep. I seen that a lot. Unfortunately that was in 3.18 branch and
it'll took several months to verify this fix.
This code and page reference counting overall have changed
significantly since then, so probably here is more bugs.
For example, I'm not sure about races with atomic set for page
reference counting,
I've found and removed couple in mellanox driver but there're more in
mm and net.

>
> Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>
>> ---
>>  mm/memory-failure.c |   10 +++++++++-
>>  1 file changed, 9 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
>> index 78f5f2641b91..ca5acee53b7a 100644
>> --- a/mm/memory-failure.c
>> +++ b/mm/memory-failure.c
>> @@ -888,7 +888,15 @@ int get_hwpoison_page(struct page *page)
>>               }
>>       }
>>
>> -     return get_page_unless_zero(head);
>> +     if (get_page_unless_zero(head)) {
>> +             if (head == compound_head(page))
>> +                     return 1;
>> +
>> +             pr_info("MCE: %#lx cannot catch tail\n", page_to_pfn(page));
>
> Recently Chen Yucong replaced the label "MCE:" with "Memory failure:",
> but the resolution is trivial, I think.
>
> Thanks,
> Naoya Horiguchi
>
>> +             put_page(head);
>> +     }
>> +
>> +     return 0;
>>  }
>>  EXPORT_SYMBOL_GPL(get_hwpoison_page);
>>
>>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a hrefmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
