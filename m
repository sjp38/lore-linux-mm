Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 846DE6B0037
	for <linux-mm@kvack.org>; Thu, 29 May 2014 03:19:28 -0400 (EDT)
Received: by mail-ie0-f181.google.com with SMTP id rp18so9379013iec.26
        for <linux-mm@kvack.org>; Thu, 29 May 2014 00:19:28 -0700 (PDT)
Received: from mail-ie0-x22f.google.com (mail-ie0-x22f.google.com [2607:f8b0:4001:c03::22f])
        by mx.google.com with ESMTPS id c19si308552igv.42.2014.05.29.00.19.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 29 May 2014 00:19:28 -0700 (PDT)
Received: by mail-ie0-f175.google.com with SMTP id y20so11312469ier.20
        for <linux-mm@kvack.org>; Thu, 29 May 2014 00:19:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140528160948.489fde6e0285885d13f7c656@linux-foundation.org>
References: <20140528075955.20300.22758.stgit@zurg>
	<20140528160948.489fde6e0285885d13f7c656@linux-foundation.org>
Date: Thu, 29 May 2014 11:19:27 +0400
Message-ID: <CALYGNiN4v4b_AJW10wVyy1XnapzwLk8Pod89sb3E-b3c81SoVw@mail.gmail.com>
Subject: Re: [PATCH] mm: dont call mmu_notifier_invalidate_page during munlock
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, May 29, 2014 at 3:09 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Wed, 28 May 2014 11:59:55 +0400 Konstantin Khlebnikov <koct9i@gmail.com> wrote:
>
>> try_to_munlock() searches other mlocked vmas, it never unmaps pages.
>> There is no reason for invalidation because ptes are left unchanged.
>>
>> ...
>>
>> --- a/mm/rmap.c
>> +++ b/mm/rmap.c
>> @@ -1225,7 +1225,7 @@ int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>>
>>  out_unmap:
>>       pte_unmap_unlock(pte, ptl);
>> -     if (ret != SWAP_FAIL)
>> +     if (ret != SWAP_FAIL && TTU_ACTION(flags) != TTU_MUNLOCK)
>>               mmu_notifier_invalidate_page(mm, address);
>>  out:
>>       return ret;
>
> The patch itself looks reasonable but there is no such thing as
> try_to_munlock().  I rewrote the changelog thusly:

Wait, what? I do have function with this name in my sources. It calls rmap_walk
with callback try_to_unmap_one and action TTU_MUNLOCK. This is the place
where TTU_MUNLOCK is used, I've mentioned it as entry point of this logic.

>
> : In its munmap mode, try_to_unmap_one() searches other mlocked vmas, it
> : never unmaps pages.  There is no reason for invalidation because ptes are
> : left unchanged.
>
> Also, the name try_to_unmap_one() is now pretty inaccurate/incomplete.
> Perhaps if someone is feeling enthusiastic they might think up a better
> name for the various try_to_unmap functions and see if we can
> appropriately document try_to_unmap_one().

I thought about moving mlock part out of try_to_unmap_one() into
separate function,
but normal unmap needs this part too...
Anyway I want to make try_to_unmap_one() static, this is internal function now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
