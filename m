Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id D01F98E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 22:44:20 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id y135-v6so4942172oie.11
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 19:44:20 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id r62-v6si2057900oib.84.2018.09.12.19.44.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 19:44:19 -0700 (PDT)
Subject: Re: [RFC PATCH 0/3] rework mmap-exit vs. oom_reaper handover
References: <1536382452-3443-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180910125513.311-1-mhocko@kernel.org>
 <70a92ca8-ca3e-2586-d52a-36c5ef6f7e43@i-love.sakura.ne.jp>
 <20180912075054.GZ10951@dhcp22.suse.cz>
 <20180912134203.GJ10951@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <4ed2213e-c4ca-4ef2-2cc0-17b5c5447325@i-love.sakura.ne.jp>
Date: Thu, 13 Sep 2018 11:44:03 +0900
MIME-Version: 1.0
In-Reply-To: <20180912134203.GJ10951@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>

On 2018/09/12 22:42, Michal Hocko wrote:
> On Wed 12-09-18 09:50:54, Michal Hocko wrote:
>> On Tue 11-09-18 23:01:57, Tetsuo Handa wrote:
>>> On 2018/09/10 21:55, Michal Hocko wrote:
>>>> This is a very coarse implementation of the idea I've had before.
>>>> Please note that I haven't tested it yet. It is mostly to show the
>>>> direction I would wish to go for.
>>>
>>> Hmm, this patchset does not allow me to boot. ;-)
>>>
>>>         free_pgd_range(&tlb, vma->vm_start, vma->vm_prev->vm_end,
>>>                         FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
>>>
>>> [    1.875675] sched_clock: Marking stable (1810466565, 65169393)->(1977240380, -101604422)
>>> [    1.877833] registered taskstats version 1
>>> [    1.877853] Loading compiled-in X.509 certificates
>>> [    1.878835] zswap: loaded using pool lzo/zbud
>>> [    1.880835] BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
>>
>> This is vm_prev == NULL. I thought we always have vm_prev as long as
>> this is not a single VMA in the address space. I will double check this.
> 
> So this is me misunderstanding the code. vm_next, vm_prev are not a full
> doubly linked list. The first entry doesn't really refer to the last
> entry. So the above cannot work at all. We can go around this in two
> ways. Either keep the iteration or use the following which should cover
> the full mapped range, unless I am missing something
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 64e8ccce5282..078295344a17 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -3105,7 +3105,7 @@ void exit_mmap(struct mm_struct *mm)
>  		up_write(&mm->mmap_sem);
>  	}
>  
> -	free_pgd_range(&tlb, vma->vm_start, vma->vm_prev->vm_end,
> +	free_pgd_range(&tlb, vma->vm_start, mm->highest_vm_end,
>  			FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
>  	tlb_finish_mmu(&tlb, 0, -1);
>  

This is bad because architectures where hugetlb_free_pgd_range() does
more than free_pgd_range() need to check VM_HUGETLB flag for each "vma".
Thus, I think we need to keep the iteration.
