Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B04D76B0200
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 22:42:58 -0400 (EDT)
Message-ID: <4BC3DA2B.3070605@redhat.com>
Date: Mon, 12 Apr 2010 22:42:51 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH]vmscan: handle underflow for get_scan_ratio
References: <20100409142057.be0ce5af.akpm@linux-foundation.org> <4BBF9B34.5040909@redhat.com> <20100413102641.4A18.A69D9226@jp.fujitsu.com>
In-Reply-To: <20100413102641.4A18.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shaohua.li@intel.com>, "Wu, Fengguang" <fengguang.wu@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 04/12/2010 09:30 PM, KOSAKI Motohiro wrote:
>> On 04/09/2010 05:20 PM, Andrew Morton wrote:
>>
>>> Come to that, it's not obvious that we need this in 2.6.34 either.  What
>>> is the user-visible impact here?
>>
>> I suspect very little impact, especially during workloads
>> where we can just reclaim clean page cache at DEF_PRIORITY.
>> FWIW, the patch looks good to me, so:
>>
>> Acked-by: Rik van Riel<riel@redhat.com>
>>
>
> I'm surprised this ack a bit. Rik, do you have any improvement plan about
> streaming io detection logic?
> I think the patch have a slightly marginal benefit, it help to<1% scan
> ratio case. but it have big regression, it cause streaming io (e.g. backup
> operation) makes tons swap.

How?  From the description I believe it took 16GB in
a zone before we start scanning anon pages when
reclaiming at DEF_PRIORITY?

Would that casue a problem?

> So, I thought we sould do either,
> 1) drop this one
> 2) merge to change stream io detection logic improvement at first, and
>     merge this one at second.

We may need better streaming IO detection, anyway.

I have noticed that while heavy sequential reads are fine,
the virtual machines on my desktop system do a lot of whole
block writes.  Presumably, a lot of those writes are to the
same blocks, over and over again.

This causes the blocks to be promoted to the active file
list, which ends up growing the active file list to the
point where things from the working set get evicted.

All for file pages that may only get WRITTEN to by the
guests, because the guests cache their own copy whenever
they need to read them!

I'll have to check the page cache code to see if it
keeps frequently written pages as accessed.  We may be
better off evicting frequently written pages, and
keeping our cache space for data that is read...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
