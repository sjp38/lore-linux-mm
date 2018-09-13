Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id C5A178E0001
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 07:20:29 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id e6-v6so7935036itc.7
        for <linux-mm@kvack.org>; Thu, 13 Sep 2018 04:20:29 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id m3-v6si2562186itg.125.2018.09.13.04.20.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Sep 2018 04:20:28 -0700 (PDT)
Subject: Re: [RFC PATCH 0/3] rework mmap-exit vs. oom_reaper handover
References: <1536382452-3443-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180910125513.311-1-mhocko@kernel.org>
 <70a92ca8-ca3e-2586-d52a-36c5ef6f7e43@i-love.sakura.ne.jp>
 <20180912075054.GZ10951@dhcp22.suse.cz>
 <20180912134203.GJ10951@dhcp22.suse.cz>
 <4ed2213e-c4ca-4ef2-2cc0-17b5c5447325@i-love.sakura.ne.jp>
 <20180913090950.GD20287@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <c70a8b7c-d1d2-66de-d87e-13a4a410335b@i-love.sakura.ne.jp>
Date: Thu, 13 Sep 2018 20:20:12 +0900
MIME-Version: 1.0
In-Reply-To: <20180913090950.GD20287@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>

On 2018/09/13 18:09, Michal Hocko wrote:
>> This is bad because architectures where hugetlb_free_pgd_range() does
>> more than free_pgd_range() need to check VM_HUGETLB flag for each "vma".
>> Thus, I think we need to keep the iteration.
> 
> Fair point. I have looked more closely and most of them simply redirect
> to free_pgd_range but ppc and sparc are doing some pretty involved
> tricks which we cannot really skip. So I will go and split
> free_pgtables into two phases and keep per vma loops. So this
> incremental update on top

Next question.

        /* Use -1 here to ensure all VMAs in the mm are unmapped */
        unmap_vmas(&tlb, vma, 0, -1);

in exit_mmap() will now race with the OOM reaper. And unmap_vmas() will handle
VM_HUGETLB or VM_PFNMAP or VM_SHARED or !vma_is_anonymous() vmas, won't it?
Then, is it guaranteed to be safe if the OOM reaper raced with unmap_vmas() ?



By the way, there is a potential bug in hugepd_free() in arch/powerpc/mm/hugetlbpage.c

        if (*batchp == NULL) {
                *batchp = (struct hugepd_freelist *)__get_free_page(GFP_ATOMIC);
                (*batchp)->index = 0;
        }

because GFP_ATOMIC allocation might fail if ALLOC_OOM allocations are in progress?
