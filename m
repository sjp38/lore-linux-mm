Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5B4546B0005
	for <linux-mm@kvack.org>; Thu, 31 May 2018 17:39:33 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id b25-v6so13296321pfn.10
        for <linux-mm@kvack.org>; Thu, 31 May 2018 14:39:33 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u5-v6sor5386623pgc.15.2018.05.31.14.39.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 31 May 2018 14:39:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHH2K0afVpVyMw+_J48pg9ngj9oovBEPBFd3kfCcCfyV7xxF0w@mail.gmail.com>
References: <20180531193420.26087-1-ikalvachev@gmail.com> <CAHH2K0afVpVyMw+_J48pg9ngj9oovBEPBFd3kfCcCfyV7xxF0w@mail.gmail.com>
From: Ivan Kalvachev <ikalvachev@gmail.com>
Date: Fri, 1 Jun 2018 00:39:31 +0300
Message-ID: <CABA=pqc8tuLGc4OTGymj5wN3ypisMM60mgOLpy2OXxmfteoJFg@mail.gmail.com>
Subject: Re: [PATCH] mm: fix kswap excessive pressure after wrong condition transfer
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Linux MM <linux-mm@kvack.org>

On 5/31/18, Greg Thelen <gthelen@google.com> wrote:
> On Thu, May 31, 2018 at 12:34 PM Ivan Kalvachev <ikalvachev@gmail.com>
> wrote:
>>
>> Fixes commit 69d763fc6d3aee787a3e8c8c35092b4f4960fa5d
>> (mm: pin address_space before dereferencing it while isolating an LRU
>> page)
>>
>> working code:
>>
>>     mapping = page_mapping(page);
>>     if (mapping && !mapping->a_ops->migratepage)
>>         return ret;
>>
>> buggy code:
>>
>>     if (!trylock_page(page))
>>         return ret;
>>
>>     mapping = page_mapping(page);
>>     migrate_dirty = mapping && mapping->a_ops->migratepage;
>>     unlock_page(page);
>>     if (!migrate_dirty)
>>         return ret;
>>
>> The problem is that !(a && b) = (!a || !b) while the old code was (a &&
>> !b).
>> The commit message of the buggy commit explains the need for
>> locking/unlocking
>> around the check but does not give any reason for the change of the
>> condition.
>> It seems to be an unintended change.
>>
>> The result of that change is noticeable under swap pressure.
>> Big memory consumers like browsers would have a lot of pages swapped out,
>> even pages that are been used actively, causing the process to repeatedly
>> block for second or longer. At the same time there would be gigabytes of
>> unused free memory (sometimes half of the total RAM).
>> The buffers/cache would also be at minimum size.
>>
>> Fixes: 69d763fc6d3a ("mm: pin address_space before dereferencing it while
>> isolating an LRU page")
>> Signed-off-by: Ivan Kalvachev <ikalvachev@gmail.com>
>> ---
>>  mm/vmscan.c | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 9b697323a88c..83df26078d13 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -1418,9 +1418,9 @@ int __isolate_lru_page(struct page *page,
>> isolate_mode_t mode)
>>                                 return ret;
>>
>>                         mapping = page_mapping(page);
>> -                       migrate_dirty = mapping &&
>> mapping->a_ops->migratepage;
>> +                       migrate_dirty = mapping &&
>> !mapping->a_ops->migratepage;
>>                         unlock_page(page);
>> -                       if (!migrate_dirty)
>> +                       if (migrate_dirty)
>>                                 return ret;
>>                 }
>>         }
>> --
>> 2.17.1
>
> This looks like yesterday's https://lkml.org/lkml/2018/5/30/1158
>

Yes, it seems to be the same problem.
It also have better technical description.

Such let down.
It took me so much time to bisect the issue...

Well, I hope that the fix will get into 4.17 release in time.


On 5/31/18, Greg Thelen <gthelen@google.com> wrote:
> On Thu, May 31, 2018 at 12:34 PM Ivan Kalvachev <ikalvachev@gmail.com>
> wrote:
>>
>> Fixes commit 69d763fc6d3aee787a3e8c8c35092b4f4960fa5d
>> (mm: pin address_space before dereferencing it while isolating an LRU
>> page)
>>
>> working code:
>>
>>     mapping = page_mapping(page);
>>     if (mapping && !mapping->a_ops->migratepage)
>>         return ret;
>>
>> buggy code:
>>
>>     if (!trylock_page(page))
>>         return ret;
>>
>>     mapping = page_mapping(page);
>>     migrate_dirty = mapping && mapping->a_ops->migratepage;
>>     unlock_page(page);
>>     if (!migrate_dirty)
>>         return ret;
>>
>> The problem is that !(a && b) = (!a || !b) while the old code was (a &&
>> !b).
>> The commit message of the buggy commit explains the need for
>> locking/unlocking
>> around the check but does not give any reason for the change of the
>> condition.
>> It seems to be an unintended change.
>>
>> The result of that change is noticeable under swap pressure.
>> Big memory consumers like browsers would have a lot of pages swapped out,
>> even pages that are been used actively, causing the process to repeatedly
>> block for second or longer. At the same time there would be gigabytes of
>> unused free memory (sometimes half of the total RAM).
>> The buffers/cache would also be at minimum size.
>>
>> Fixes: 69d763fc6d3a ("mm: pin address_space before dereferencing it while
>> isolating an LRU page")
>> Signed-off-by: Ivan Kalvachev <ikalvachev@gmail.com>
>> ---
>>  mm/vmscan.c | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 9b697323a88c..83df26078d13 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -1418,9 +1418,9 @@ int __isolate_lru_page(struct page *page,
>> isolate_mode_t mode)
>>                                 return ret;
>>
>>                         mapping = page_mapping(page);
>> -                       migrate_dirty = mapping &&
>> mapping->a_ops->migratepage;
>> +                       migrate_dirty = mapping &&
>> !mapping->a_ops->migratepage;
>>                         unlock_page(page);
>> -                       if (!migrate_dirty)
>> +                       if (migrate_dirty)
>>                                 return ret;
>>                 }
>>         }
>> --
>> 2.17.1
>
> This looks like yesterday's https://lkml.org/lkml/2018/5/30/1158
>
