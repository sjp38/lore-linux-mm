Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 727216B0033
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 03:13:12 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id d140so31968182wmd.4
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 00:13:12 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t7si24195304wrb.5.2017.01.17.00.13.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Jan 2017 00:13:11 -0800 (PST)
Subject: Re: getting oom/stalls for ltp test cpuset01 with latest/4.9 kernel
References: <CAFpQJXUq-JuEP=QPidy4p_=FN0rkH5Z-kfB4qBvsf6jMS87Edg@mail.gmail.com>
 <075075cc-3149-0df3-dd45-a81df1f1a506@suse.cz>
 <0ea1cfeb-7c4a-3a3e-9be9-967298ba303c@suse.cz>
 <CAFpQJXWD8pSaWUrkn5Rxy-hjTCvrczuf0F3TdZ8VHj4DSYpivg@mail.gmail.com>
 <20170111164616.GJ16365@dhcp22.suse.cz>
 <45ed555a-c6a3-fc8e-1e87-c347c8ed086b@suse.cz>
 <CAFpQJXUVRKXLUvM5PnpjT_UH+ac-0=caND43F882oP+Rm5gxUQ@mail.gmail.com>
 <89fec1bd-52b7-7861-2e02-a719c5631610@suse.cz>
 <CAFpQJXUq_O=UAhCb7fwq2txYxg_owO77rRdQFUjR0_Mj9p=3pA@mail.gmail.com>
 <a374d6b6-c299-b50d-d7e0-f85ac78525aa@suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <7c8ed170-ced9-aa6a-25e0-47cdc6d66eb2@suse.cz>
Date: Tue, 17 Jan 2017 09:13:09 +0100
MIME-Version: 1.0
In-Reply-To: <a374d6b6-c299-b50d-d7e0-f85ac78525aa@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganapatrao Kulkarni <gpkulkarni@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

On 01/16/2017 02:22 PM, Vlastimil Babka wrote:
>>>
>>>  no_zone:
>>> --
>>> 2.11.0
>>>
>>
>> this patch did not fix the issue.
>> issue still exists!
> 
> Hmm, that's unfortunate.
> 
>> i did bisect and this test passes in 4.4,4.5 and 4.6
>> test failing since 4.7-rc1
> 
> 4.7 would match the commit I was trying to fix. But I don't see other
> problems now. Could you bisect to a single commit then, to be sure? Thanks.

Ah, nevermind, I can reproduce the issue easily. After some more poking
I now think the bisect would lead to the OOM rework, but it would be a
red herring. Seems like this is an interaction between bind mempolicy
and cpuset and I see several potential bugs in that area. Which also
means there's a non-null nodemask and thus the code in the commit I
originally suspected (replacing NULL nodemask with cpuset's
mems_allowed) doesn't trigger at all here.

Thanks,
Vlastimil

>> thanks
>> Ganapat
>>>
>>>
>>>
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
