Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id E5A006B00DD
	for <linux-mm@kvack.org>; Thu, 24 Oct 2013 20:35:28 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp16so3442431pbb.14
        for <linux-mm@kvack.org>; Thu, 24 Oct 2013 17:35:28 -0700 (PDT)
Received: from psmtp.com ([74.125.245.168])
        by mx.google.com with SMTP id ud7si3291661pac.323.2013.10.24.17.35.27
        for <linux-mm@kvack.org>;
        Thu, 24 Oct 2013 17:35:28 -0700 (PDT)
Message-ID: <5269BCCC.6090509@codeaurora.org>
Date: Thu, 24 Oct 2013 17:35:24 -0700
From: Olav Haugan <ohaugan@codeaurora.org>
MIME-Version: 1.0
Subject: Re: zram/zsmalloc issues in very low memory conditions
References: <526844E6.1080307@codeaurora.org> <52686FF4.5000303@oracle.com>
In-Reply-To: <52686FF4.5000303@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <bob.liu@oracle.com>
Cc: minchan@kernel.org, sjenning@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, semenzato@google.com

Hi Bob, Luigi,

On 10/23/2013 5:55 PM, Bob Liu wrote:
> 
> On 10/24/2013 05:51 AM, Olav Haugan wrote:
>> I am trying to use zram in very low memory conditions and I am having
>> some issues. zram is in the reclaim path. So if the system is very low
>> on memory the system is trying to reclaim pages by swapping out (in this
>> case to zram). However, since we are very low on memory zram fails to
>> get a page from zsmalloc and thus zram fails to store the page. We get
>> into a cycle where the system is low on memory so it tries to swap out
>> to get more memory but swap out fails because there is not enough memory
>> in the system! The major problem I am seeing is that there does not seem
>> to be a way for zram to tell the upper layers to stop swapping out
>> because the swap device is essentially "full" (since there is no more
>> memory available for zram pages). Has anyone thought about this issue
>> already and have ideas how to solve this or am I missing something and I
>> should not be seeing this issue?
>>
> 
> The same question as Luigi "What do you want the system to do at this
> point?"
> 
> If swap fails then OOM killer will be triggered, I don't think this will
> be a issue.

I definitely don't want OOM killer to run since OOM killer can kill
critical processes (this is on Android so we have Android LMK to handle
the killing in a more "safe" way). However, what I am seeing is that
when I run low on memory zram fails to swap out and returns error but
the swap subsystem just continues to try to swap out even when this
error occurs (it tries over and over again very rapidly causing the
kernel to be filled with error messages [at least two error messages per
failure btw]).

What I expected to happen is for the swap subsystem to stop trying to
swap out until memory is available to swap out. I guess this could be
handled several ways. Either 1) the swap subsystem, upon encountering an
error to swap out, backs off from trying to swap out for some time or 2)
zram informs the swap subsystem that the swap device is full.

Could this be handled by congestion control? However, I found the
following comment in the code in vmscan.c:

* If the page is swapcache, write it back even if that would
* block, for some throttling. This happens by accident, because
* swap_backing_dev_info is bust: it doesn't reflect the
* congestion state of the swapdevs.  Easy to fix, if needed.

However, how would one update the congested state of zram when it
becomes un-congested?

> By the way, could you take a try with zswap? Which can write pages to
> real swap device if compressed pool is full.

zswap might not be feasible in all cases if you only have flash as
backing storage.

>> I am also seeing a couple other issues that I was wondering whether
>> folks have already thought about:
>>
>> 2) zsmalloc fails when the page allocated is at physical address 0 (pfn
> 
> AFAIK, this will never happen.

I can easily get this to happen since I have memory starting at physical
address 0.

Thanks,

Olav Haugan

-- 
The Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
