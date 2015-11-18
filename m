Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id D5D276B0038
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 12:32:30 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so51092824pac.3
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 09:32:30 -0800 (PST)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id hq4si5738066pbb.89.2015.11.18.09.32.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Nov 2015 09:32:29 -0800 (PST)
Received: by pacej9 with SMTP id ej9so51055846pac.2
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 09:32:29 -0800 (PST)
Message-ID: <564CB62B.4070501@linaro.org>
Date: Wed, 18 Nov 2015 09:32:27 -0800
From: "Shi, Yang" <yang.shi@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCH] writeback: initialize m_dirty to avoid compile warning
References: <1447439201-32009-1-git-send-email-yang.shi@linaro.org> <20151117153855.99d2acd0568d146c29defda5@linux-foundation.org> <9389290.7xT8jb43sX@wuerfel>
In-Reply-To: <9389290.7xT8jb43sX@wuerfel>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>, linaro-kernel@lists.linaro.org
Cc: Andrew Morton <akpm@linux-foundation.org>, tj@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11/18/2015 1:53 AM, Arnd Bergmann wrote:
> On Tuesday 17 November 2015 15:38:55 Andrew Morton wrote:
>> On Fri, 13 Nov 2015 10:26:41 -0800 Yang Shi <yang.shi@linaro.org> wrote:
>>
>>> When building kernel with gcc 5.2, the below warning is raised:
>>>
>>> mm/page-writeback.c: In function 'balance_dirty_pages.isra.10':
>>> mm/page-writeback.c:1545:17: warning: 'm_dirty' may be used uninitialized in this function [-Wmaybe-uninitialized]
>>>     unsigned long m_dirty, m_thresh, m_bg_thresh;
>>>
>>> The m_dirty{thresh, bg_thresh} are initialized in the block of "if (mdtc)",
>>> so if mdts is null, they won't be initialized before being used.
>>> Initialize m_dirty to zero, also initialize m_thresh and m_bg_thresh to keep
>>> consistency.
>>>
>>> They are used later by if condition:
>>> !mdtc || m_dirty <= dirty_freerun_ceiling(m_thresh, m_bg_thresh)
>>>
>>> If mdtc is null, dirty_freerun_ceiling will not be called at all, so the
>>> initialization will not change any behavior other than just ceasing the compile
>>> warning.
>>
>> Geeze I hate that warning.  gcc really could be a bit smarter about it
>> and this is such a case.
>>
>>> --- a/mm/page-writeback.c
>>> +++ b/mm/page-writeback.c
>>> @@ -1542,7 +1542,7 @@ static void balance_dirty_pages(struct address_space *mapping,
>>>        for (;;) {
>>>                unsigned long now = jiffies;
>>>                unsigned long dirty, thresh, bg_thresh;
>>> -             unsigned long m_dirty, m_thresh, m_bg_thresh;
>>> +             unsigned long m_dirty = 0, m_thresh = 0, m_bg_thresh = 0;
>>>
>>>                /*
>>>                 * Unstable writes are a feature of certain networked
>>
>> Adding runtime overhead to suppress a compile-time warning is Just
>> Wrong.
>>
>> With gcc-4.4.4 the above patch actually reduces page-writeback.o's
>> .text by 36 bytes, lol.  With gcc-4.8.4 the patch saves 19 bytes.  No
>> idea what's going on there...
>
> I've done tons of build tests and never got the warning for the variables
> other than m_dirty, and that one also just with very few configurations
> (e.g. ARM omap2plus_defconfig).

Yes, I just got the warning for m_dirty too. Just initialize m_thresh 
and m_bg_thresh to keep consistency (not sure if it is necessary). And, 
I'm a little bit confused why gcc just reports m_dirty but ignore others.

>
> How about initializing only m_dirty but not the others?

Fine to me.

Thanks,
Yang

>
> 	Arnd
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
