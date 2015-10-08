Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id BEF8F6B0038
	for <linux-mm@kvack.org>; Thu,  8 Oct 2015 05:40:11 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so16703377wic.0
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 02:40:11 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id mw8si10389513wic.89.2015.10.08.02.40.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 08 Oct 2015 02:40:10 -0700 (PDT)
Subject: Re: can't oom-kill zap the victim's memory?
References: <201509290118.BCJ43256.tSFFFMOLHVOJOQ@I-love.SAKURA.ne.jp>
 <20151002123639.GA13914@dhcp22.suse.cz>
 <CA+55aFw=OLSdh-5Ut2vjy=4Yf1fTXqpzoDHdF7XnT5gDHs6sYA@mail.gmail.com>
 <20151005144404.GD7023@dhcp22.suse.cz> <5614AAC0.60002@suse.cz>
 <201510071943.DCJ01080.JOFOFFOtLSMQHV@I-love.SAKURA.ne.jp>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <561639F7.3080504@suse.cz>
Date: Thu, 8 Oct 2015 11:40:07 +0200
MIME-Version: 1.0
In-Reply-To: <201510071943.DCJ01080.JOFOFFOtLSMQHV@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, torvalds@linux-foundation.org, rientjes@google.com, oleg@redhat.com, kwalker@redhat.com, cl@linux.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, skozina@redhat.com

On 10/07/2015 12:43 PM, Tetsuo Handa wrote:
> Vlastimil Babka wrote:
>> On 5.10.2015 16:44, Michal Hocko wrote:
>>> So I can see basically only few ways out of this deadlock situation.
>>> Either we face the reality and allow small allocations (withtout
>>> __GFP_NOFAIL) to fail after all attempts to reclaim memory have failed
>>> (so after even OOM killer hasn't made any progress).
>>
>> Note that small allocations already *can* fail if they are done in the context
>> of a task selected as OOM victim (i.e. TIF_MEMDIE). And yeah I've seen a case
>> when they failed in a code that "handled" the allocation failure with a
>> BUG_ON(!page).
>>
> Did You hit a race described below?

I don't know, I don't even have direct evidence of TIF_MEMDIE being set, 
but OOMs were happening all over the place, and I haven't found another 
reason why the allocation would not be too-small-to-fail otherwise.

> http://lkml.kernel.org/r/201508272249.HDH81838.FtQOLMFFOVSJOH@I-love.SAKURA.ne.jp
>
> Where was the BUG_ON(!page) ? Maybe it is a candidate for adding __GFP_NOFAIL.

Yes, I suggested so:
http://marc.info/?l=linux-kernel&m=144181523115244&w=2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
