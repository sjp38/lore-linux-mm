Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 95EE66B0003
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 01:29:40 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id u8so3243807pfm.21
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 22:29:40 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id e92-v6si489920pld.736.2018.03.26.22.29.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Mar 2018 22:29:39 -0700 (PDT)
Subject: Re: [PATCH] mm: kmemleak: wait for scan completion before disabling
 free
References: <1522063429-18992-1-git-send-email-vinmenon@codeaurora.org>
 <20180326154421.obk7ikx3h5ko62o5@armageddon.cambridge.arm.com>
 <20180326122611.acbfe1bfe6f7c1792b42a3a7@linux-foundation.org>
From: Vinayak Menon <vinmenon@codeaurora.org>
Message-ID: <b3fa4377-edf8-10c4-c40a-45bb53096145@codeaurora.org>
Date: Tue, 27 Mar 2018 10:59:31 +0530
MIME-Version: 1.0
In-Reply-To: <20180326122611.acbfe1bfe6f7c1792b42a3a7@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-mm@kvack.org


On 3/27/2018 12:56 AM, Andrew Morton wrote:
> On Mon, 26 Mar 2018 16:44:21 +0100 Catalin Marinas <catalin.marinas@arm.com> wrote:
>
>> On Mon, Mar 26, 2018 at 04:53:49PM +0530, Vinayak Menon wrote:
>>> A crash is observed when kmemleak_scan accesses the
>>> object->pointer, likely due to the following race.
>>>
>>> TASK A             TASK B                     TASK C
>>> kmemleak_write
>>>  (with "scan" and
>>>  NOT "scan=on")
>>> kmemleak_scan()
>>>                    create_object
>>>                    kmem_cache_alloc fails
>>>                    kmemleak_disable
>>>                    kmemleak_do_cleanup
>>>                    kmemleak_free_enabled = 0
>>>                                               kfree
>>>                                               kmemleak_free bails out
>>>                                                (kmemleak_free_enabled is 0)
>>>                                               slub frees object->pointer
>>> update_checksum
>>> crash - object->pointer
>>>  freed (DEBUG_PAGEALLOC)
>>>
>>> kmemleak_do_cleanup waits for the scan thread to complete, but not for
>>> direct call to kmemleak_scan via kmemleak_write. So add a wait for
>>> kmemleak_scan completion before disabling kmemleak_free.
>>>
>>> Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
>> It looks fine to me. Maybe Andrew can pick it up.
>>
>> Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
> Well, the comment says:
>
> /*
>  * Stop the automatic memory scanning thread. This function must be called
>  * with the scan_mutex held.
>  */
> static void stop_scan_thread(void)
>
>
> So shouldn't we do it this way?

Earlier it was done the way you mentioned. But that was changed to fix a deadlock by

commit 5f369f374ba4889fe3c17883402db5ee8d254216
Author: Catalin Marinas <catalin.marinas@arm.com>
Date:A A  Wed Jun 24 16:58:31 2015 -0700

A A A  mm: kmemleak: do not acquire scan_mutex in kmemleak_do_cleanup()

Not able to see a reason why stop_scan_thread must be called with scan_mutex held. The comment needs a fix ?

>
> --- a/mm/kmemleak.c~mm-kmemleak-wait-for-scan-completion-before-disabling-free-fix
> +++ a/mm/kmemleak.c
> @@ -1919,9 +1919,9 @@ static void __kmemleak_do_cleanup(void)
>   */
>  static void kmemleak_do_cleanup(struct work_struct *work)
>  {
> +	mutex_lock(&scan_mutex);
>  	stop_scan_thread();
>  
> -	mutex_lock(&scan_mutex);
>  	/*
>  	 * Once it is made sure that kmemleak_scan has stopped, it is safe to no
>  	 * longer track object freeing. Ordering of the scan thread stopping and
> _
>
