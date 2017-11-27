Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 023D26B0253
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 03:29:15 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id g73so35238122ioj.0
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 00:29:14 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 200sor4746609itf.108.2017.11.27.00.29.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Nov 2017 00:29:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171127082112.b7elnzy24qiqze46@dhcp22.suse.cz>
References: <CALOAHbB05YJvVPRE0VsEDj+U7Wqv64XoGOQtpDP1a50mbpYXGg@mail.gmail.com>
 <201711261142.EIE82842.LFOtSHOFVOFJQM@I-love.SAKURA.ne.jp>
 <CALOAHbCov=Dd7bYjL6+abiVu_WgT1ZmFN_TfLTs8A1jfw8=bOQ@mail.gmail.com>
 <201711261703.HDI52138.JSFVOFOtHLMOFQ@I-love.SAKURA.ne.jp>
 <CALOAHbAgh0egRJk7ME_YBzon9ED9jL94vi4aw19bbpZVuUA+aQ@mail.gmail.com>
 <201711261938.BCD34864.QLVFOSJFHOtOFM@I-love.SAKURA.ne.jp>
 <CALOAHbCVoy=5U0_7wg9nZR+sa8buG41BAE4KDnr2Fb4tYqhaXw@mail.gmail.com> <20171127082112.b7elnzy24qiqze46@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Mon, 27 Nov 2017 16:29:13 +0800
Message-ID: <CALOAHbDZ_rxHYyb8K01Ecd7FBRXO4Bp5_BsPYXAvAOYXMw34Rw@mail.gmail.com>
Subject: Re: [PATCH] mm: print a warning once the vm dirtiness settings is illogical
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Linux MM <linux-mm@kvack.org>, fcicq@fcicq.net

2017-11-27 16:21 GMT+08:00 Michal Hocko <mhocko@suse.com>:
> On Mon 27-11-17 16:06:50, Yafang Shao wrote:
>> +cc fcicq
> [...]
>> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
>> index 8a15511..6c5c018 100644
>> --- a/mm/page-writeback.c
>> +++ b/mm/page-writeback.c
>> @@ -377,7 +377,16 @@ static unsigned long global_dirtyable_memory(void)
>>     if (!vm_highmem_is_dirtyable)
>>         x -= highmem_dirtyable_memory(x);
>>
>> -   return x + 1;   /* Ensure that we never return 0 */
>> +   /*
>> +    * - Why 100 ?
>> +    * - Because the return value will be used by dirty ratio and
>> +    *   dirty background ratio to calculate dirty thresh and bg thresh,
>> +    *   so if the return value is two small, the thresh value maybe
>> +    *   calculated to 0.
>> +    *   As the max value of ratio is 100, so the return value is added
>> +    *   by 100 here.
>> +    */
>> +   return x + 100;
>
> No. We should just revert 0f6d24f87856 ("mm/page-writeback.c: print a
> warning if the vm dirtiness settings are illogical") because it is of a
> dubious value and it causes problems. I am not even sure why it got
> merged. It doesn't have any ack or review and I remember objecting to
> the patch previously as pointless.
> --

It is reviewed and merged by Andrew.

>From Andrew:
> I think this means that a script which alters both dirty_bytes and
dirty_background_bytes must alter dirty_background_bytes first if they
are being decreased and must alter dirty_bytes first if they are being
increased.  Or something like that.

It will help us to find the error if we don't change these values like this.

Thanks
Yafang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
