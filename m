Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id A316B6B0003
	for <linux-mm@kvack.org>; Tue, 29 May 2018 09:27:08 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id j82-v6so6659432oiy.18
        for <linux-mm@kvack.org>; Tue, 29 May 2018 06:27:08 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o184-v6si11234427oih.369.2018.05.29.06.27.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 May 2018 06:27:07 -0700 (PDT)
Date: Tue, 29 May 2018 09:27:06 -0400 (EDT)
From: Chunyu Hu <chuhu@redhat.com>
Reply-To: Chunyu Hu <chuhu@redhat.com>
Message-ID: <1126233373.5118805.1527600426174.JavaMail.zimbra@redhat.com>
In-Reply-To: <201805290605.DGF87549.LOVFMFJQSOHtFO@I-love.SAKURA.ne.jp>
References: <CA+7wUswp_Sr=hHqi1bwRZ3FE2wY5ozZWZ8Z1BgrFnSAmijUKjA@mail.gmail.com> <20180528083451.GE1517@dhcp22.suse.cz> <f054219d-6daa-68b1-0c60-0acd9ad8c5ab@i-love.sakura.ne.jp> <20180528132410.GD27180@dhcp22.suse.cz> <201805290605.DGF87549.LOVFMFJQSOHtFO@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH] kmemleak: don't use __GFP_NOFAIL
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@suse.com, malat@debian.org, dvyukov@google.com, linux-mm@kvack.org, catalin marinas <catalin.marinas@arm.com>



----- Original Message -----
> From: "Tetsuo Handa" <penguin-kernel@I-love.SAKURA.ne.jp>
> To: mhocko@suse.com
> Cc: malat@debian.org, dvyukov@google.com, linux-mm@kvack.org, "catalin marinas" <catalin.marinas@arm.com>,
> chuhu@redhat.com
> Sent: Tuesday, May 29, 2018 5:05:45 AM
> Subject: Re: [PATCH] kmemleak: don't use __GFP_NOFAIL
> 
> Michal Hocko wrote:
> > I've found the previous report [1] finally. Adding Chunyu Hu to the CC
> > list. The report which triggered this one is [2]
> > 
> > [1]
> > http://lkml.kernel.org/r/1524243513-29118-1-git-send-email-chuhu@redhat.com
> > [2]
> > http://lkml.kernel.org/r/CA+7wUswp_Sr=hHqi1bwRZ3FE2wY5ozZWZ8Z1BgrFnSAmijUKjA@mail.gmail.com
> > 
> > I am not really familiar with the kmemleak code but the expectation that
> > you can make a forward progress in an unknown allocation context seems
> > broken to me. Why kmemleak cannot pre-allocate a pool of object_cache
> > and refill it from a reasonably strong contexts (e.g. in a sleepable
> > context)?
> 
> Or, we can undo the original allocation if the kmemleak allocation failed?

If so, you are making kmemleak a fault injection trigger. But the original
purpose for adding GFP_NOFAIL[2] is just for making kmemleak avoid fault injection.
(discussion in [1])

I'm trying with per task way for fault injection, and did some tries. In my 
try, I removed this from NOFAIL kmemleak and kmemleak survived with the per
task fault injection helper (disable/enable of task). Maybe I can send another
RFC for the api. 

> 
> kmalloc(size, gfp) {
>   ptr = do_kmalloc(size, gfp);
>   if (ptr) {
>     object = do_kmalloc(size, gfp_kmemleak_mask(gfp));
>     if (!object) {
>       kfree(ptr);
>       return NULL;
>     }
>     // Store information of ptr into object.
>   }
>   return ptr;
> }
> 

-- 
Regards,
Chunyu Hu
