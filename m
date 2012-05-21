Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id B4E9B6B0081
	for <linux-mm@kvack.org>; Mon, 21 May 2012 04:46:27 -0400 (EDT)
Message-ID: <4FBA00E1.2020103@kernel.org>
Date: Mon, 21 May 2012 17:46:25 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2] swap: improve swap I/O rate
References: <1336996709-8304-1-git-send-email-ehrhardt@linux.vnet.ibm.com> <4FB1E2A0.9050900@kernel.org> <4FB9F3FF.7030709@linux.vnet.ibm.com>
In-Reply-To: <4FB9F3FF.7030709@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, axboe@kernel.dk, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>

On 05/21/2012 04:51 PM, Christian Ehrhardt wrote:

> [...]
> 
>>> [missing patch #3]
>>> I tried to get a similar patch working for swap out in
>>> shrink_page_list. And
>>> it worked in functional terms, but the additional mergin was negligible.
>>
>>
>> I think we have already done it.
>> Look at shrink_mem_cgroup_zone which ends up calling shrink_page_list
>> so we already have applied
>> I/O plugging.
>>
> 
> I saw that code and it is part of the kernel I used to test my patches.
> But despite that code and my additional experiments of plug/unplug in
> shrink_page_list the effective I/O size of swap write stays at almost 4k.


I meant your plugging in shrink_page_list is redundant 

> 
> Thereby so far I can tell you that the plugs in shrink_page_list and
> shrink_mem_cgroup_zone aren't sufficient - at least for my case.


Yeb.

> You saw the blocktrace summaries in my first mail, an excerpt of a write
> submission stream looks like that:
> 
>  94,4   10      465     0.023520923   116  A   W 28868648 + 8 <- (94,5)
> 28868456
>  94,5   10      466     0.023521173   116  Q   W 28868648 + 8 [kswapd0]
>  94,5   10      467     0.023522048   116  G   W 28868648 + 8 [kswapd0]
>  94,5   10      468     0.023522235   116  P   N [kswapd0]
>  94,5   10      469     0.023759892   116  I   W 28868648 + 8 ( 237844)
> [kswapd0]
>  94,5   10      470     0.023760079   116  U   N [kswapd0] 1
>  94,5   10      471     0.023760360   116  D   W 28868648 + 8 ( 468)
> [kswapd0]
>  94,4   10      472     0.023891235   116  A   W 28868656 + 8 <- (94,5)
> 28868464
>  94,5   10      473     0.023891454   116  Q   W 28868656 + 8 [kswapd0]
>  94,5   10      474     0.023892110   116  G   W 28868656 + 8 [kswapd0]
>  94,5   10      475     0.023944610   116  I   W 28868656 + 8 ( 52500)
> [kswapd0]
>  94,5   10      476     0.023944735   116  U   N [kswapd0] 1
>  94,5   10      477     0.023944892   116  D   W 28868656 + 8 ( 282)
> [kswapd0]
>  94,5   16       19     0.024023192 16033  C   W 28868648 + 8 ( 262832) [0]
>  94,5   24       37     0.024196752 14526  C   W 28868656 + 8 ( 251860) [0]
> [...]
> 
> But we can split this discussion from my other two patches and I would
> be happy to provide my test environment for further tests if there are
> new suggestions/patches/...
> 
>>> Maybe the cond_resched triggers much mor often than I expected, I'm
>>> open for
>>> suggestions regarding improving the pagout I/O sizes as well.
>>
>>
>> We could enhance write out by batch like ext4_bio_write_page.
>>
> 
> Do you mean the changes brought by "bd2d0210 ext4: use bio layer instead
> of buffer layer in mpage_da_submit_io" ?


Yeb, I think it's helpful for your case but it's not trivial to implement it, IMHO.

> 
> 
> 



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
