Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id B86EB6B005C
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 08:34:39 -0500 (EST)
Message-ID: <4F0D8FCE.7080202@redhat.com>
Date: Wed, 11 Jan 2012 08:34:06 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm 2/2] mm: kswapd carefully invoke compaction
References: <20120109213156.0ff47ee5@annuminas.surriel.com> <20120109213357.148e7927@annuminas.surriel.com> <CAHGf_=rj=aDVGWXqdq7fh_LrCFnug_mPNuuE=YdXaWpvwyjfzg@mail.gmail.com>
In-Reply-To: <CAHGf_=rj=aDVGWXqdq7fh_LrCFnug_mPNuuE=YdXaWpvwyjfzg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: linux-mm@kvack.org, aarcange@redhat.com, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, akpm@linux-foundation.org, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com

On 01/11/2012 02:25 AM, KOSAKI Motohiro wrote:
>> With CONFIG_COMPACTION enabled, kswapd does not try to free
>> contiguous free pages, even when it is woken for a higher order
>> request.
>>
>> This could be bad for eg. jumbo frame network allocations, which
>> are done from interrupt context and cannot compact memory themselves.
>> Higher than before allocation failure rates in the network receive
>> path have been observed in kernels with compaction enabled.
>>
>> Teach kswapd to defragment the memory zones in a node, but only
>> if required and compaction is not deferred in a zone.
>>
>> Signed-off-by: Rik van Riel<riel@redhat.com>
>
> I agree with we need asynchronous defragmentations feature. But, do we
> really need to use kswapd for compaction? While kswapd take a
> compaction work, it can't work to make free memory.

I believe we do need some background compaction, especially
to help allocations from network interrupts.

If you believe the compaction is better done from some
other thread, I guess we could do that, but truthfully, if
kswapd spends a lot of time doing compaction, I made a
mistake somewhere :)

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
