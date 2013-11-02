Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id BAC856B0035
	for <linux-mm@kvack.org>; Fri,  1 Nov 2013 21:00:03 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id rd3so4737919pab.14
        for <linux-mm@kvack.org>; Fri, 01 Nov 2013 18:00:03 -0700 (PDT)
Received: from psmtp.com ([74.125.245.181])
        by mx.google.com with SMTP id ba2si5090151pbc.358.2013.11.01.18.00.02
        for <linux-mm@kvack.org>;
        Fri, 01 Nov 2013 18:00:02 -0700 (PDT)
Message-ID: <52744E8F.3040405@codeaurora.org>
Date: Fri, 01 Nov 2013 17:59:59 -0700
From: Olav Haugan <ohaugan@codeaurora.org>
MIME-Version: 1.0
Subject: Re: zram/zsmalloc issues in very low memory conditions
References: <526844E6.1080307@codeaurora.org> <20131025091924.GA4970@gmail.com>
In-Reply-To: <20131025091924.GA4970@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: sjenning@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 10/25/2013 2:19 AM, Minchan Kim wrote:
> Hello,
> 
> I had no enough time to think over your great questions since I should enjoy
> in Edinburgh so if I miss something, Sorry!
> 
> On Wed, Oct 23, 2013 at 02:51:34PM -0700, Olav Haugan wrote:
>> I am trying to use zram in very low memory conditions and I am having
>> some issues. zram is in the reclaim path. So if the system is very low
>> on memory the system is trying to reclaim pages by swapping out (in this
>> case to zram). However, since we are very low on memory zram fails to
>> get a page from zsmalloc and thus zram fails to store the page. We get
>> into a cycle where the system is low on memory so it tries to swap out
>> to get more memory but swap out fails because there is not enough memory
>> in the system! The major problem I am seeing is that there does not seem
>> to be a way for zram to tell the upper layers to stop swapping out
> 
> True. The zram is block device so at a moment, I don't want to make zram
> swap-specific if it's possible.
> 
>> because the swap device is essentially "full" (since there is no more
>> memory available for zram pages). Has anyone thought about this issue
>> already and have ideas how to solve this or am I missing something and I
>> should not be seeing this issue?
> 
> It's true. We might need feedback loop and it shoudn't be specific for
> zram-swap. One think I can imagine is that we could move failed victim
> pages into LRU active list when the swapout failed so VM will have more
> weight for file pages than anon ones. For detail, you could see
> AOP_WRITEPAGE_ACTIVATE and get_scan_count for detail.
> 
> The problem is it's on fs layer while zram is on block layer so what I
> can think at a moment is follwing as
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 8ed1b77..c80b0b4 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -502,6 +502,8 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
>                 if (!PageWriteback(page)) {
>                         /* synchronous write or broken a_ops? */
>                         ClearPageReclaim(page);
> +                       if (PageError(page))
> +                               return PAGE_ACTIVATE;
>                 }
>                 trace_mm_vmscan_writepage(page, trace_reclaim_flags(page));
>                 inc_zone_page_state(page, NR_VMSCAN_WRITE);
> 
> 
> It doesn't prevent swapout at all but it should throttle pick up anonymous
> pages for reclaiming so file-backed pages will be preferred by VM so sometime,
> zsmalloc succeed to allocate a free page and swapout will resume again.

I tried the above suggestion but it does not seem to have any noticeable
impact. The system is still trying to swap out at a very high rate after
zram reported failure to swap out. The error logging is actually so much
that my system crashed due to excessive logging (we have a watchdog that
is not getting pet because the kernel is busy logging kernel messages).

There isn't anything that can be set to tell the fs layer to back off
completely for a while (congestion control)?


Olav Haugan

-- 
The Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
