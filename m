Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f181.google.com (mail-vc0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id ED0216B008C
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 04:58:45 -0400 (EDT)
Received: by mail-vc0-f181.google.com with SMTP id id10so517390vcb.12
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 01:58:45 -0700 (PDT)
Received: from mail-ve0-x236.google.com (mail-ve0-x236.google.com [2607:f8b0:400c:c01::236])
        by mx.google.com with ESMTPS id ui2si280792vdc.64.2014.04.08.01.58.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 08 Apr 2014 01:58:44 -0700 (PDT)
Received: by mail-ve0-f182.google.com with SMTP id jw12so482455veb.41
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 01:58:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1404042358030.12542@eggly.anvils>
References: <1396235259-2394-1-git-send-email-bob.liu@oracle.com>
	<alpine.LSU.2.11.1404042358030.12542@eggly.anvils>
Date: Tue, 8 Apr 2014 16:58:44 +0800
Message-ID: <CAA_GA1fj=OXeK44NYPt205TqB8OKxOeevOpDorMoytZJebXA=Q@mail.gmail.com>
Subject: Re: [PATCH] mm: rmap: don't try to add an unevictable page to lru list
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Bob Liu <bob.liu@oracle.com>

On Sat, Apr 5, 2014 at 5:04 PM, Hugh Dickins <hughd@google.com> wrote:
> On Mon, 31 Mar 2014, Bob Liu wrote:
>
>> VM_BUG_ON_PAGE(PageActive(page) && PageUnevictable(page), page) in
>> lru_cache_add() was triggered during migrate_misplaced_transhuge_page.
>>
>> kernel BUG at mm/swap.c:609!
>> [<ffffffff8127f311>] lru_cache_add+0x21/0x60
>> [<ffffffff812adaec>] page_add_new_anon_rmap+0x1ec/0x210
>> [<ffffffff812db8ec>] migrate_misplaced_transhuge_page+0x55c/0x830
>>
>> The root cause is the checking mlocked_vma_newpage() in
>> page_add_new_anon_rmap() is not enough to decide whether a page is unevictable.
>>
>> migrate_misplaced_transhuge_page():
>>       => migrate_page_copy()
>>               => SetPageUnevictable(newpage)
>>
>>       => page_add_new_anon_rmap(newpage)
>>               => mlocked_vma_newpage(vma, newpage) <--This check is not enough
>>                       => SetPageActive(newpage)
>>                       => lru_cache_add(newpage)
>>                               => VM_BUG_ON_PAGE()
>>
>> From vmscan.c:
>>  * Reasons page might not be evictable:
>>  * (1) page's mapping marked unevictable
>>  * (2) page is part of an mlocked VMA
>>
>> But page_add_new_anon_rmap() only checks reason (2), we may hit this
>> VM_BUG_ON_PAGE() if PageUnevictable(old_page) was originally set by reason (1).
>
> But (1) always reports evictable on an anon page, doesn't it?
>
>>
>> Reported-by: Sasha Levin <sasha.levin@oracle.com>
>> Signed-off-by: Bob Liu <bob.liu@oracle.com>
>
> I can't quite assert NAK, but I suspect this is not the proper fix.
>
> Initially I was uncomfortable with it for largely aesthetic reasons.
> page_add_new_anon_rmap() is a cut-some-corners fast-path collection of
> rmap and lru stuff for the common case, the first time a page is added.
>
> If what it does is not suitable for the unusual case of page migration,
> then we should not clutter it up with additional tests, but adjust
> migration to use the slower page_add_anon_rmap() instead.
>
> Or, if there turns out to be some really good reason to stick with
> page_add_new_anon_rmap(), add an inline comment to explain why this
> additional !PageUnevictable test (never needed before) is needed now.
>
> Note that the call from migrate_misplaced_transhuge_page() is the
> only use of page_add_new_anon_rmap() in mm/migrate.c: I think it's a
> mistake, and should use page_add_anon_rmap() plus putback_lru_page()
> like elsewhere in migrate.c.
>
> Beware, I've not written, let alone tested, a patch to do so: maybe
> more is needed.  In particular, it's unclear whether Mel intended the
> SetPageActive that comes bundled up in page_add_new_anon_rmap(), when
> normally migration just transfers PageActive state from old to new.
>
> I went through a phase of thinking your patch is downright wrong,
> that in the racy case it puts a recently-become-evictable page back
> to the unevictable lru.  Currently I believe I was wrong about that,
> the page lock (on old page) or mmap_sem preventing that possibility.
>
> (Yet now I'm wavering again: if down_write mmap_sem is needed to
> munlock() the vma, and migrate_misplaced_transhuge_page() is only
> migrating a singly-mapped THP under down_read mmap_sem, how could
> VM_LOCKED have changed during the migration?  I've lost sight of

I think you are right, I'll do more investigation about why this BUG
was triggered.

-- 
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
