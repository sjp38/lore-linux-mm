Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id F3AB26B000A
	for <linux-mm@kvack.org>; Wed, 30 May 2018 05:35:39 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id k62-v6so6356785oiy.1
        for <linux-mm@kvack.org>; Wed, 30 May 2018 02:35:39 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o83-v6si11029076oif.364.2018.05.30.02.35.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 May 2018 02:35:38 -0700 (PDT)
Date: Wed, 30 May 2018 05:35:37 -0400 (EDT)
From: Chunyu Hu <chuhu@redhat.com>
Reply-To: Chunyu Hu <chuhu@redhat.com>
Message-ID: <1730157334.5467848.1527672937617.JavaMail.zimbra@redhat.com>
In-Reply-To: <f3d58cbd-29ca-7a23-69e0-59690b9cd4fb@i-love.sakura.ne.jp>
References: <CA+7wUswp_Sr=hHqi1bwRZ3FE2wY5ozZWZ8Z1BgrFnSAmijUKjA@mail.gmail.com> <20180528083451.GE1517@dhcp22.suse.cz> <f054219d-6daa-68b1-0c60-0acd9ad8c5ab@i-love.sakura.ne.jp> <20180528132410.GD27180@dhcp22.suse.cz> <201805290605.DGF87549.LOVFMFJQSOHtFO@I-love.SAKURA.ne.jp> <1126233373.5118805.1527600426174.JavaMail.zimbra@redhat.com> <f3d58cbd-29ca-7a23-69e0-59690b9cd4fb@i-love.sakura.ne.jp>
Subject: Re: [PATCH] kmemleak: don't use __GFP_NOFAIL
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: mhocko@suse.com, malat@debian.org, dvyukov@google.com, linux-mm@kvack.org, catalin marinas <catalin.marinas@arm.com>



----- Original Message -----
> From: "Tetsuo Handa" <penguin-kernel@i-love.sakura.ne.jp>
> To: "Chunyu Hu" <chuhu@redhat.com>
> Cc: mhocko@suse.com, malat@debian.org, dvyukov@google.com, linux-mm@kvack.org, "catalin marinas"
> <catalin.marinas@arm.com>
> Sent: Tuesday, May 29, 2018 9:46:59 PM
> Subject: Re: [PATCH] kmemleak: don't use __GFP_NOFAIL
> 
> On 2018/05/29 22:27, Chunyu Hu wrote:
> >>> I am not really familiar with the kmemleak code but the expectation that
> >>> you can make a forward progress in an unknown allocation context seems
> >>> broken to me. Why kmemleak cannot pre-allocate a pool of object_cache
> >>> and refill it from a reasonably strong contexts (e.g. in a sleepable
> >>> context)?
> >>
> >> Or, we can undo the original allocation if the kmemleak allocation failed?
> > 
> > If so, you are making kmemleak a fault injection trigger. But the original
> > purpose for adding GFP_NOFAIL[2] is just for making kmemleak avoid fault
> > injection.
> > (discussion in [1])
> 
> I don't think that applying fault injection to kmemleak allocations is bad
> (except that fault injection messages might be noisy).

Maybe we provide a way for user decide to apply fault inject to kmemleak or not 
is better, by adding another sys file in /sys/kernel/debug/failslab and the
fail_page_alloc.

> 
> > 
> > I'm trying with per task way for fault injection, and did some tries. In my
> > try, I removed this from NOFAIL kmemleak and kmemleak survived with the per
> > task fault injection helper (disable/enable of task). Maybe I can send
> > another
> > RFC for the api.
> 
> You could carry __GFP_NO_FAULT_INJECTION using per "struct task_struct" flag.

Thanks for this suggestion. 

I'm trying to reuse the make_it_fail field in task for fault injection. As adding
an extra memory alloc flag is not thought so good,  I think adding task flag
is either? 

> 
> But I think that undoing the original allocation if the kmemleak allocation
> failed
> has an advantage that it does not disable kmemleak when the system is under
> memory
> pressure (i.e. about to invoke the OOM killer); allowing us to test memory
> pressure
> conditions.

There should be benefit, this is redefining kmemleak's principle, currently it
won't affect other allocation directly, but if we free the other user's mem
alloc without thinking about the context seems also risk. 

> 
> 

-- 
Regards,
Chunyu Hu
