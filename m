Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 790878E0001
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 07:53:35 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id m197-v6so5715494oig.18
        for <linux-mm@kvack.org>; Thu, 13 Sep 2018 04:53:35 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id u30-v6si394647otb.374.2018.09.13.04.53.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Sep 2018 04:53:33 -0700 (PDT)
Subject: Re: [RFC PATCH 0/3] rework mmap-exit vs. oom_reaper handover
References: <1536382452-3443-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180910125513.311-1-mhocko@kernel.org>
 <70a92ca8-ca3e-2586-d52a-36c5ef6f7e43@i-love.sakura.ne.jp>
 <20180912075054.GZ10951@dhcp22.suse.cz>
 <20180912134203.GJ10951@dhcp22.suse.cz>
 <4ed2213e-c4ca-4ef2-2cc0-17b5c5447325@i-love.sakura.ne.jp>
 <20180913090950.GD20287@dhcp22.suse.cz>
 <c70a8b7c-d1d2-66de-d87e-13a4a410335b@i-love.sakura.ne.jp>
 <20180913113538.GE20287@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <0897639b-a1d9-2da1-0a1e-a3eeed799a0f@i-love.sakura.ne.jp>
Date: Thu, 13 Sep 2018 20:53:24 +0900
MIME-Version: 1.0
In-Reply-To: <20180913113538.GE20287@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>

On 2018/09/13 20:35, Michal Hocko wrote:
>> Next question.
>>
>>         /* Use -1 here to ensure all VMAs in the mm are unmapped */
>>         unmap_vmas(&tlb, vma, 0, -1);
>>
>> in exit_mmap() will now race with the OOM reaper. And unmap_vmas() will handle
>> VM_HUGETLB or VM_PFNMAP or VM_SHARED or !vma_is_anonymous() vmas, won't it?
>> Then, is it guaranteed to be safe if the OOM reaper raced with unmap_vmas() ?
> 
> I do not understand the question. unmap_vmas is basically MADV_DONTNEED
> and that doesn't require the exclusive mmap_sem lock so yes it should be
> safe those two to race (modulo bugs of course but I am not aware of any
> there).
>  

You need to verify that races we observed with VM_LOCKED can't happen
for VM_HUGETLB / VM_PFNMAP / VM_SHARED / !vma_is_anonymous() cases.

                for (vma = mm->mmap; vma; vma = vma->vm_next) {
                        if (!(vma->vm_flags & VM_LOCKED))
                                continue;
                        /*
                         * oom_reaper cannot handle mlocked vmas but we
                         * need to serialize it with munlock_vma_pages_all
                         * which clears VM_LOCKED, otherwise the oom reaper
                         * cannot reliably test it.
                         */
                        if (oom)
                                down_write(&mm->mmap_sem);

                        munlock_vma_pages_all(vma);

                        if (oom)
                                up_write(&mm->mmap_sem);
                }

Without enough comments, future changes might overlook the assumption.
