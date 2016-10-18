Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 61A286B0038
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 09:25:17 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id fn2so231631166pad.7
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 06:25:17 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id w20si32290871pgj.4.2016.10.18.06.25.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Oct 2016 06:25:16 -0700 (PDT)
Subject: Re: [Intel-gfx] [PATCH v4 2/2] drm/i915: Make GPU pages movable
References: <1459775891-32442-1-git-send-email-chris@chris-wilson.co.uk>
 <1459775891-32442-2-git-send-email-chris@chris-wilson.co.uk>
 <1476792301.3117.14.camel@linux.intel.com>
From: "Goel, Akash" <akash.goel@intel.com>
Message-ID: <c733c4d9-de93-9a9b-1236-793cc26c8833@intel.com>
Date: Tue, 18 Oct 2016 18:55:12 +0530
MIME-Version: 1.0
In-Reply-To: <1476792301.3117.14.camel@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Chris Wilson <chris@chris-wilson.co.uk>
Cc: intel-gfx@lists.freedesktop.org, akash.goel@intel.com, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Sourab Gupta <sourab.gupta@intel.com>



On 10/18/2016 5:35 PM, Joonas Lahtinen wrote:
> On ma, 2016-04-04 at 14:18 +0100, Chris Wilson wrote:
>> From: Akash Goel <akash.goel@intel.com>
>>
>> On a long run of more than 2-3 days, physical memory tends to get
>> fragmented severely, which considerably slows down the system. In such a
>> scenario, the shrinker is also unable to help as lack of memory is not
>> the actual problem, since it has been observed that there are enough free
>> pages of 0 order. This also manifests itself when an indiviual zone in
>> the mm runs out of pages and if we cannot migrate pages between zones,
>> the kernel hits an out-of-memory even though there are free pages (and
>> often all of swap) available.
>>
>> To address the issue of external fragementation, kernel does a compaction
>> (which involves migration of pages) but it's efficacy depends upon how
>> many pages are marked as MOVABLE, as only those pages can be migrated.
>>
>> Currently the backing pages for GFX buffers are allocated from shmemfs
>> with GFP_RECLAIMABLE flag, in units of 4KB pages.  In the case of limited
>> swap space, it may not be possible always to reclaim or swap-out pages of
>> all the inactive objects, to make way for free space allowing formation
>> of higher order groups of physically-contiguous pages on compaction.
>>
>> Just marking the GPU pages as MOVABLE will not suffice, as i915.ko has to
>> pin the pages if they are in use by GPU, which will prevent their
>> migration. So the migratepage callback in shmem is also hooked up to get
>> a notification when kernel initiates the page migration. On the
>> notification, i915.ko appropriately unpin the pages.  With this we can
>> effectively mark the GPU pages as MOVABLE and hence mitigate the
>> fragmentation problem.
>>
>> v2:
>>  - Rename the migration routine to gem_shrink_migratepage, move it to the
>>    shrinker file, and use the existing constructs (Chris)
>>  - To cleanup, add a new helper function to encapsulate all page migration
>>    skip conditions (Chris)
>>  - Add a new local helper function in shrinker file, for dropping the
>>    backing pages, and call the same from gem_shrink() also (Chris)
>>
>> v3:
>>  - Fix/invert the check on the return value of unsafe_drop_pages (Chris)
>>
>> v4:
>>  - Minor tidy
>>
>> Testcase: igt/gem_shrink
>> Bugzilla: (e.g.) https://bugs.freedesktop.org/show_bug.cgi?id=90254
>> Cc: Hugh Dickins <hughd@google.com>
>> Cc: linux-mm@kvack.org
>> Signed-off-by: Sourab Gupta <sourab.gupta@intel.com>
>> Signed-off-by: Akash Goel <akash.goel@intel.com>
>> Reviewed-by: Chris Wilson <chris@chris-wilson.co.uk>
>
> Could this patch be re-spinned on top of current nightly?
>
Sure will rebase it on top of nightly.

> After removing;
>
>> WARN(page_count(newpage) != 1, "Unexpected ref count for newpage\n")
>
> and
>
>> 	if (ret)
>> 		DRM_DEBUG_DRIVER("page=%p migration returned %d\n", page, ret);
>
> This is;
>
> Reviewed-by: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Thanks much for the review.
But there is a precursor patch also, there has been no traction on that.
[1/2] shmem: Support for registration of Driver/file owner specific ops
https://patchwork.freedesktop.org/patch/77935/

Best regards
Akash

>
> Regards, Joonas
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
