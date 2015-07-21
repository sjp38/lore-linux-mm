Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id 58B446B028B
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 04:39:59 -0400 (EDT)
Received: by laem6 with SMTP id m6so112878242lae.0
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 01:39:58 -0700 (PDT)
Received: from mail-lb0-x22c.google.com (mail-lb0-x22c.google.com. [2a00:1450:4010:c04::22c])
        by mx.google.com with ESMTPS id ax10si20186023lbc.94.2015.07.21.01.39.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jul 2015 01:39:57 -0700 (PDT)
Received: by lbbzr7 with SMTP id zr7so110995714lbb.1
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 01:39:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150721081149.GC4490@hori1.linux.bs1.fc.nec.co.jp>
References: <20150714152516.29844.69929.stgit@buzz>
	<20150714153747.29844.13543.stgit@buzz>
	<20150721081149.GC4490@hori1.linux.bs1.fc.nec.co.jp>
Date: Tue, 21 Jul 2015 11:39:56 +0300
Message-ID: <CALYGNiNHooR0eqH7rYfzOj65_97H6EeF34Bfbgh50JK+k4yN7w@mail.gmail.com>
Subject: Re: [PATCH v4 4/5] pagemap: hide physical addresses from
 non-privileged users
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Mark Williamson <mwilliamson@undo-software.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>

On Tue, Jul 21, 2015 at 11:11 AM, Naoya Horiguchi
<n-horiguchi@ah.jp.nec.com> wrote:
> On Tue, Jul 14, 2015 at 06:37:47PM +0300, Konstantin Khlebnikov wrote:
>> This patch makes pagemap readable for normal users and hides physical
>> addresses from them. For some use-cases PFN isn't required at all.
>>
>> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
>> Fixes: ab676b7d6fbf ("pagemap: do not leak physical addresses to non-privileged userspace")
>> Link: http://lkml.kernel.org/r/1425935472-17949-1-git-send-email-kirill@shutemov.name
>> ---
>>  fs/proc/task_mmu.c |   25 ++++++++++++++-----------
>>  1 file changed, 14 insertions(+), 11 deletions(-)
>>
>> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
>> index 040721fa405a..3a5d338ea219 100644
>> --- a/fs/proc/task_mmu.c
>> +++ b/fs/proc/task_mmu.c
>> @@ -937,6 +937,7 @@ typedef struct {
>>  struct pagemapread {
>>       int pos, len;           /* units: PM_ENTRY_BYTES, not bytes */
>>       pagemap_entry_t *buffer;
>> +     bool show_pfn;
>>  };
>>
>>  #define PAGEMAP_WALK_SIZE    (PMD_SIZE)
>> @@ -1013,7 +1014,8 @@ static pagemap_entry_t pte_to_pagemap_entry(struct pagemapread *pm,
>>       struct page *page = NULL;
>>
>>       if (pte_present(pte)) {
>> -             frame = pte_pfn(pte);
>> +             if (pm->show_pfn)
>> +                     frame = pte_pfn(pte);
>>               flags |= PM_PRESENT;
>>               page = vm_normal_page(vma, addr, pte);
>>               if (pte_soft_dirty(pte))
>
> Don't you need the same if (pm->show_pfn) check in is_swap_pte path, too?
> (although I don't think that it can be exploited by row hammer attack ...)

Yeah, but I see no reason for that.
Probably except swap on ramdrive, but this too weird =)

>
> Thanks,
> Naoya Horiguchi
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
