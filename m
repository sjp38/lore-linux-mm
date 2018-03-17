Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id EE47C6B0005
	for <linux-mm@kvack.org>; Sat, 17 Mar 2018 00:39:02 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id n67so215776qkn.14
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 21:39:02 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id p13si2358762qtg.19.2018.03.16.21.39.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 21:39:02 -0700 (PDT)
Subject: Re: [PATCH 03/14] mm/hmm: HMM should have a callback before MM is
 destroyed v2
From: John Hubbard <jhubbard@nvidia.com>
References: <20180316191414.3223-1-jglisse@redhat.com>
 <20180316191414.3223-4-jglisse@redhat.com>
 <7e87c1f9-5c1a-84fd-1f7f-55ffaaed8a66@nvidia.com>
 <b0cd570b-dfe4-4b42-18bb-967d1dbddcb3@nvidia.com>
Message-ID: <b1406b15-858f-00a2-e2c1-a950d190f0e1@nvidia.com>
Date: Fri, 16 Mar 2018 21:39:00 -0700
MIME-Version: 1.0
In-Reply-To: <b0cd570b-dfe4-4b42-18bb-967d1dbddcb3@nvidia.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Ralph Campbell <rcampbell@nvidia.com>, stable@vger.kernel.org, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>

On 03/16/2018 08:47 PM, John Hubbard wrote:
> On 03/16/2018 07:36 PM, John Hubbard wrote:
>> On 03/16/2018 12:14 PM, jglisse@redhat.com wrote:
>>> From: Ralph Campbell <rcampbell@nvidia.com>
>>>
>>
>> <snip>
>>
>>> +static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
>>> +{
>>> +	struct hmm *hmm = mm->hmm;
>>> +	struct hmm_mirror *mirror;
>>> +	struct hmm_mirror *mirror_next;
>>> +
>>> +	down_write(&hmm->mirrors_sem);
>>> +	list_for_each_entry_safe(mirror, mirror_next, &hmm->mirrors, list) {
>>> +		list_del_init(&mirror->list);
>>> +		if (mirror->ops->release)
>>> +			mirror->ops->release(mirror);
>>> +	}
>>> +	up_write(&hmm->mirrors_sem);
>>> +}
>>> +
>>
>> OK, as for actual code review:
>>
>> This part of the locking looks good. However, I think it can race against
>> hmm_mirror_register(), because hmm_mirror_register() will just add a new 
>> mirror regardless.
>>
>> So:
>>
>> thread 1                                      thread 2
>> --------------                                -----------------
>> hmm_release                                   hmm_mirror_register 
>>     down_write(&hmm->mirrors_sem);                <blocked: waiting for sem>
>>         // deletes all list items
>>     up_write
>>                                                   unblocked: adds new mirror
>>                                               
>>

Mark Hairgrove just pointed out some more fun facts:

1. Because hmm_mirror_register() needs to be called with an mm that has a non-zero
refcount, you generally cannot get an hmm_release callback, so the above race should
not happen.

2. We looked around, and the code is missing a call to mmu_notifier_unregister().
That means that it is going to leak memory and not let the mm get released either.

Maybe having each mirror have its own mmu notifier callback is a possible way
to solve this.

thanks,
-- 
John Hubbard
NVIDIA
