Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 549E16B0023
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 02:51:09 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id n15-v6so1089438plp.22
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 23:51:09 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id x10si2083921pgt.109.2018.03.27.23.51.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Mar 2018 23:51:08 -0700 (PDT)
Subject: Re: [PATCH] mm: kmemleak: wait for scan completion before disabling
 free
References: <1522063429-18992-1-git-send-email-vinmenon@codeaurora.org>
 <20180326154421.obk7ikx3h5ko62o5@armageddon.cambridge.arm.com>
 <20180326122611.acbfe1bfe6f7c1792b42a3a7@linux-foundation.org>
 <b3fa4377-edf8-10c4-c40a-45bb53096145@codeaurora.org>
 <20180327174927.o5lhb7yyl4gjkkxl@armageddon.cambridge.arm.com>
From: Vinayak Menon <vinmenon@codeaurora.org>
Message-ID: <1c6787e5-71f8-e135-8bfa-0d72bc2dd51a@codeaurora.org>
Date: Wed, 28 Mar 2018 12:21:01 +0530
MIME-Version: 1.0
In-Reply-To: <20180327174927.o5lhb7yyl4gjkkxl@armageddon.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On 3/27/2018 11:19 PM, Catalin Marinas wrote:
> On Tue, Mar 27, 2018 at 10:59:31AM +0530, Vinayak Menon wrote:
>> On 3/27/2018 12:56 AM, Andrew Morton wrote:
>>> On Mon, 26 Mar 2018 16:44:21 +0100 Catalin Marinas <catalin.marinas@arm.com> wrote:
>>>> On Mon, Mar 26, 2018 at 04:53:49PM +0530, Vinayak Menon wrote:
>>>>> A crash is observed when kmemleak_scan accesses the
>>>>> object->pointer, likely due to the following race.
>>>>>
>>>>> TASK A             TASK B                     TASK C
>>>>> kmemleak_write
>>>>>  (with "scan" and
>>>>>  NOT "scan=on")
>>>>> kmemleak_scan()
>>>>>                    create_object
>>>>>                    kmem_cache_alloc fails
>>>>>                    kmemleak_disable
>>>>>                    kmemleak_do_cleanup
>>>>>                    kmemleak_free_enabled = 0
>>>>>                                               kfree
>>>>>                                               kmemleak_free bails out
>>>>>                                                (kmemleak_free_enabled is 0)
>>>>>                                               slub frees object->pointer
>>>>> update_checksum
>>>>> crash - object->pointer
>>>>>  freed (DEBUG_PAGEALLOC)
>>>>>
>>>>> kmemleak_do_cleanup waits for the scan thread to complete, but not for
>>>>> direct call to kmemleak_scan via kmemleak_write. So add a wait for
>>>>> kmemleak_scan completion before disabling kmemleak_free.
>>>>>
>>>>> Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
>>>> It looks fine to me. Maybe Andrew can pick it up.
>>>>
>>>> Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
>>> Well, the comment says:
>>>
>>> /*
>>>  * Stop the automatic memory scanning thread. This function must be called
>>>  * with the scan_mutex held.
>>>  */
>>> static void stop_scan_thread(void)
>>>
>>>
>>> So shouldn't we do it this way?
>> Earlier it was done the way you mentioned. But that was changed to fix
>> a deadlock by
>>
>> commit 5f369f374ba4889fe3c17883402db5ee8d254216
>> Author: Catalin Marinas <catalin.marinas@arm.com>
>> Date:A A  Wed Jun 24 16:58:31 2015 -0700
>>
>> A A A  mm: kmemleak: do not acquire scan_mutex in kmemleak_do_cleanup()
>>
>> Not able to see a reason why stop_scan_thread must be called with
>> scan_mutex held. The comment needs a fix ?
> Indeed, the comment needs fixing as waiting on the mutex here may lead
> deadlock. Would you mind sending an updated patch? Feel free to keep my
> reviewed-by tag.

Sure. done.

>
> Thanks.
>
