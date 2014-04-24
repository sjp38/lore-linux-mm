Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f169.google.com (mail-vc0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id 1979E6B0035
	for <linux-mm@kvack.org>; Wed, 23 Apr 2014 23:23:03 -0400 (EDT)
Received: by mail-vc0-f169.google.com with SMTP id im17so2231959vcb.14
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 20:23:02 -0700 (PDT)
Received: from mail-ve0-x236.google.com (mail-ve0-x236.google.com [2607:f8b0:400c:c01::236])
        by mx.google.com with ESMTPS id p8si657004vef.14.2014.04.23.20.23.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 23 Apr 2014 20:23:01 -0700 (PDT)
Received: by mail-ve0-f182.google.com with SMTP id jw12so2259986veb.13
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 20:23:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1404231957060.975@eggly.anvils>
References: <1396235259-2394-1-git-send-email-bob.liu@oracle.com>
	<alpine.LSU.2.11.1404042358030.12542@eggly.anvils>
	<CAA_GA1fj=OXeK44NYPt205TqB8OKxOeevOpDorMoytZJebXA=Q@mail.gmail.com>
	<alpine.LSU.2.11.1404231957060.975@eggly.anvils>
Date: Thu, 24 Apr 2014 11:23:01 +0800
Message-ID: <CAA_GA1f1nr4BLkbPM6rOFOYJA9-LJ5KFmDFa5bmW_FtRw2rijg@mail.gmail.com>
Subject: Re: [PATCH] mm: rmap: don't try to add an unevictable page to lru list
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Bob Liu <bob.liu@oracle.com>

On Thu, Apr 24, 2014 at 11:08 AM, Hugh Dickins <hughd@google.com> wrote:
> On Tue, 8 Apr 2014, Bob Liu wrote:
>> On Sat, Apr 5, 2014 at 5:04 PM, Hugh Dickins <hughd@google.com> wrote:
>> > On Mon, 31 Mar 2014, Bob Liu wrote:
>> >
>> >> VM_BUG_ON_PAGE(PageActive(page) && PageUnevictable(page), page) in
>> >> lru_cache_add() was triggered during migrate_misplaced_transhuge_page.
>> >>...
>> >> From vmscan.c:
>> >>  * Reasons page might not be evictable:
>> >>  * (1) page's mapping marked unevictable
>> >>  * (2) page is part of an mlocked VMA
>> >>
>> >> But page_add_new_anon_rmap() only checks reason (2), we may hit this
>> >> VM_BUG_ON_PAGE() if PageUnevictable(old_page) was originally set by reason (1).
>> >
>> > But (1) always reports evictable on an anon page, doesn't it?
>> >
>> >>
>> >> Reported-by: Sasha Levin <sasha.levin@oracle.com>
>> >> Signed-off-by: Bob Liu <bob.liu@oracle.com>
>> >
>> > I can't quite assert NAK, but I suspect this is not the proper fix.
> ...
>> >
>> > (Yet now I'm wavering again: if down_write mmap_sem is needed to
>> > munlock() the vma, and migrate_misplaced_transhuge_page() is only
>> > migrating a singly-mapped THP under down_read mmap_sem, how could
>> > VM_LOCKED have changed during the migration?  I've lost sight of
>>
>> I think you are right, I'll do more investigation about why this BUG
>> was triggered.
>
> Andrew, if Bob agrees, please drop
>
> mm-rmap-dont-try-to-add-an-unevictable-page-to-lru-list.patch
>

I agree!

> from mmotm now.  We have not heard any such report yet on 3.15-rc,

Yes, I can't reproduce it on 3.15-rc1 neither.

> and neither Bob nor I have yet come up with a convincing explanation
> for how it came about.  It's tempting to suppose it was a side-effect
> of something temporarily wrong on a 3.14-next, and now okay; but we'll
> learn more quickly whether that's so if mmotm stops working around it.
>

Agree! Thank you for taking look at this issue.

-- 
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
