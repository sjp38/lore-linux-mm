Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8ECCF6B0003
	for <linux-mm@kvack.org>; Tue, 29 May 2018 12:18:25 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id 6-v6so13960877itl.6
        for <linux-mm@kvack.org>; Tue, 29 May 2018 09:18:25 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id l73-v6si13845614ita.55.2018.05.29.09.18.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 May 2018 09:18:24 -0700 (PDT)
Subject: Re: [PATCH] kmemleak: don't use __GFP_NOFAIL
References: <CA+7wUswp_Sr=hHqi1bwRZ3FE2wY5ozZWZ8Z1BgrFnSAmijUKjA@mail.gmail.com>
 <20180528083451.GE1517@dhcp22.suse.cz>
 <f054219d-6daa-68b1-0c60-0acd9ad8c5ab@i-love.sakura.ne.jp>
 <20180528132410.GD27180@dhcp22.suse.cz>
 <201805290605.DGF87549.LOVFMFJQSOHtFO@I-love.SAKURA.ne.jp>
 <1126233373.5118805.1527600426174.JavaMail.zimbra@redhat.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <f3d58cbd-29ca-7a23-69e0-59690b9cd4fb@i-love.sakura.ne.jp>
Date: Tue, 29 May 2018 22:46:59 +0900
MIME-Version: 1.0
In-Reply-To: <1126233373.5118805.1527600426174.JavaMail.zimbra@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chunyu Hu <chuhu@redhat.com>
Cc: mhocko@suse.com, malat@debian.org, dvyukov@google.com, linux-mm@kvack.org, catalin marinas <catalin.marinas@arm.com>

On 2018/05/29 22:27, Chunyu Hu wrote:
>>> I am not really familiar with the kmemleak code but the expectation that
>>> you can make a forward progress in an unknown allocation context seems
>>> broken to me. Why kmemleak cannot pre-allocate a pool of object_cache
>>> and refill it from a reasonably strong contexts (e.g. in a sleepable
>>> context)?
>>
>> Or, we can undo the original allocation if the kmemleak allocation failed?
> 
> If so, you are making kmemleak a fault injection trigger. But the original
> purpose for adding GFP_NOFAIL[2] is just for making kmemleak avoid fault injection.
> (discussion in [1])

I don't think that applying fault injection to kmemleak allocations is bad
(except that fault injection messages might be noisy).

> 
> I'm trying with per task way for fault injection, and did some tries. In my 
> try, I removed this from NOFAIL kmemleak and kmemleak survived with the per
> task fault injection helper (disable/enable of task). Maybe I can send another
> RFC for the api. 

You could carry __GFP_NO_FAULT_INJECTION using per "struct task_struct" flag.

But I think that undoing the original allocation if the kmemleak allocation failed
has an advantage that it does not disable kmemleak when the system is under memory
pressure (i.e. about to invoke the OOM killer); allowing us to test memory pressure
conditions.
