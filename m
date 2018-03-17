Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id D02DA6B0005
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 23:48:01 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id x139so7968236qkb.9
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 20:48:01 -0700 (PDT)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id r36si4787072qtk.286.2018.03.16.20.48.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 20:48:00 -0700 (PDT)
Subject: Re: [PATCH 03/14] mm/hmm: HMM should have a callback before MM is
 destroyed v2
From: John Hubbard <jhubbard@nvidia.com>
References: <20180316191414.3223-1-jglisse@redhat.com>
 <20180316191414.3223-4-jglisse@redhat.com>
 <7e87c1f9-5c1a-84fd-1f7f-55ffaaed8a66@nvidia.com>
Message-ID: <b0cd570b-dfe4-4b42-18bb-967d1dbddcb3@nvidia.com>
Date: Fri, 16 Mar 2018 20:47:58 -0700
MIME-Version: 1.0
In-Reply-To: <7e87c1f9-5c1a-84fd-1f7f-55ffaaed8a66@nvidia.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Ralph Campbell <rcampbell@nvidia.com>, stable@vger.kernel.org, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>

On 03/16/2018 07:36 PM, John Hubbard wrote:
> On 03/16/2018 12:14 PM, jglisse@redhat.com wrote:
>> From: Ralph Campbell <rcampbell@nvidia.com>
>>
> 
> <snip>
> 
>> +static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
>> +{
>> +	struct hmm *hmm = mm->hmm;
>> +	struct hmm_mirror *mirror;
>> +	struct hmm_mirror *mirror_next;
>> +
>> +	down_write(&hmm->mirrors_sem);
>> +	list_for_each_entry_safe(mirror, mirror_next, &hmm->mirrors, list) {
>> +		list_del_init(&mirror->list);
>> +		if (mirror->ops->release)
>> +			mirror->ops->release(mirror);
>> +	}
>> +	up_write(&hmm->mirrors_sem);
>> +}
>> +
> 
> OK, as for actual code review:
> 
> This part of the locking looks good. However, I think it can race against
> hmm_mirror_register(), because hmm_mirror_register() will just add a new 
> mirror regardless.
> 
> So:
> 
> thread 1                                      thread 2
> --------------                                -----------------
> hmm_release                                   hmm_mirror_register 
>     down_write(&hmm->mirrors_sem);                <blocked: waiting for sem>
>         // deletes all list items
>     up_write
>                                                   unblocked: adds new mirror
>                                               
> 
> ...so I think we need a way to back out of any pending hmm_mirror_register()
> calls, as part of the .release steps, right? It seems hard for the device driver,
> which could be inside of hmm_mirror_register(), to handle that. Especially considering
> that right now, hmm_mirror_register() will return success in this case--so
> there is no indication that anything is wrong.
> 
> Maybe hmm_mirror_register() could return an error (and not add to the mirror list),
> in such a situation, how's that sound?
> 

In other words, I think this would help (not tested yet beyond a quick compile,
but it's pretty simple):

diff --git a/mm/hmm.c b/mm/hmm.c
index 7ccca5478ea1..da39f8522dca 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -66,6 +66,7 @@ struct hmm {
        struct list_head        mirrors;
        struct mmu_notifier     mmu_notifier;
        struct rw_semaphore     mirrors_sem;
+       bool                    shutting_down;
 };
 
 /*
@@ -99,6 +100,7 @@ static struct hmm *hmm_register(struct mm_struct *mm)
        INIT_LIST_HEAD(&hmm->ranges);
        spin_lock_init(&hmm->lock);
        hmm->mm = mm;
+       hmm->shutting_down = false;
 
        /*
         * We should only get here if hold the mmap_sem in write mode ie on
@@ -167,6 +169,7 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
        struct hmm_mirror *mirror_next;
 
        down_write(&hmm->mirrors_sem);
+       hmm->shutting_down = true;
        list_for_each_entry_safe(mirror, mirror_next, &hmm->mirrors, list) {
                list_del_init(&mirror->list);
                if (mirror->ops->release)
@@ -227,6 +230,10 @@ int hmm_mirror_register(struct hmm_mirror *mirror, struct mm_struct *mm)
                return -ENOMEM;
 
        down_write(&mirror->hmm->mirrors_sem);
+       if (mirror->hmm->shutting_down) {
+               up_write(&mirror->hmm->mirrors_sem);
+               return -ESRCH;
+       }
        list_add(&mirror->list, &mirror->hmm->mirrors);
        up_write(&mirror->hmm->mirrors_sem);


thanks,
-- 
John Hubbard
NVIDIA
