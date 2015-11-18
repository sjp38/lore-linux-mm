Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id C6BA56B0038
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 13:27:35 -0500 (EST)
Received: by pacej9 with SMTP id ej9so52385725pac.2
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 10:27:35 -0800 (PST)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id or8si6014837pbc.63.2015.11.18.10.27.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Nov 2015 10:27:35 -0800 (PST)
Received: by pabfh17 with SMTP id fh17so54210343pab.0
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 10:27:34 -0800 (PST)
Message-ID: <564CC314.1090904@linaro.org>
Date: Wed, 18 Nov 2015 10:27:32 -0800
From: "Shi, Yang" <yang.shi@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCH] writeback: initialize m_dirty to avoid compile warning
References: <1447439201-32009-1-git-send-email-yang.shi@linaro.org> <20151117153855.99d2acd0568d146c29defda5@linux-foundation.org> <20151118181142.GC11496@mtj.duckdns.org>
In-Reply-To: <20151118181142.GC11496@mtj.duckdns.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org

On 11/18/2015 10:11 AM, Tejun Heo wrote:
> Hello,
>
> On Tue, Nov 17, 2015 at 03:38:55PM -0800, Andrew Morton wrote:
>>> --- a/mm/page-writeback.c
>>> +++ b/mm/page-writeback.c
>>> @@ -1542,7 +1542,7 @@ static void balance_dirty_pages(struct address_space *mapping,
>>>   	for (;;) {
>>>   		unsigned long now = jiffies;
>>>   		unsigned long dirty, thresh, bg_thresh;
>>> -		unsigned long m_dirty, m_thresh, m_bg_thresh;
>>> +		unsigned long m_dirty = 0, m_thresh = 0, m_bg_thresh = 0;
>>>
>>>   		/*
>>>   		 * Unstable writes are a feature of certain networked
>>
>> Adding runtime overhead to suppress a compile-time warning is Just
>> Wrong.
>>
>> With gcc-4.4.4 the above patch actually reduces page-writeback.o's
>> .text by 36 bytes, lol.  With gcc-4.8.4 the patch saves 19 bytes.  No
>> idea what's going on there...
>>
>>
>> And initializing locals in the above fashion can hide real bugs -
>> looky:
>
> This was the main reason the code was structured the way it is.  If
> cgroup writeback is not enabled, any derefs of mdtc variables should
> trigger warnings.  Ugh... I don't know.  Compiler really should be
> able to tell this much.

Thanks for the explanation. It sounds like a compiler problem.

If you think it is still good to cease the compile warning, maybe we 
could just assign it to an insane value as what Andrew suggested, maybe 
0xdeadbeef.

Thanks,
Yang

>
> Thanks.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
