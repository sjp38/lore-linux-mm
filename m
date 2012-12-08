Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id D5EAA6B005D
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 19:44:19 -0500 (EST)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <john.stultz@linaro.org>;
	Fri, 7 Dec 2012 17:44:18 -0700
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 32F8C1FF0051
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 17:20:33 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qB80Kd8F214190
	for <linux-mm@kvack.org>; Fri, 7 Dec 2012 17:20:39 -0700
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qB80MaAJ027697
	for <linux-mm@kvack.org>; Fri, 7 Dec 2012 17:22:38 -0700
Message-ID: <50C287CE.5070404@linaro.org>
Date: Fri, 07 Dec 2012 16:20:30 -0800
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: [RFC v2] Support volatile range for anon vma
References: <1351560594-18366-1-git-send-email-minchan@kernel.org> <50AD739A.30804@linaro.org> <50B6E1F9.5010301@linaro.org> <20121204000042.GB20395@bbox> <50BD4A70.9060506@linaro.org> <20121204072207.GA9782@blaptop> <50BE4B64.6000003@linaro.org> <20121205070110.GC9782@blaptop>
In-Reply-To: <20121205070110.GC9782@blaptop>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On 12/04/2012 11:01 PM, Minchan Kim wrote:
> Hi John,
>
> On Tue, Dec 04, 2012 at 11:13:40AM -0800, John Stultz wrote:
>>
>> I don't think the problem is when vmas being marked VM_VOLATILE are
>> being merged, its that when we mark the vma as *non-volatile*, and
>> remove the VM_VOLATILE flag we merge the non-volatile vmas with
>> neighboring vmas. So preserving the purged flag during that merge is
>> important. Again, the example I used to trigger this was an
>> alternating pattern of volatile and non volatile vmas, then marking
>> the entire range non-volatile (though sometimes in two overlapping
>> passes).
> If I understand correctly, you mean following as.
>
> chunk1 = mmap(8M)
> chunk2 = chunk1 + 2M;
> chunk3 = chunk2 + 2M
> chunk4 = chunk3 + 2M
>
> madvise(chunk1, 2M, VOLATILE);
> madvise(chunk4, 2M, VOLATILE);
>
> /*
>   * V : volatile vma
>   * N : non volatile vma
>   * So Now vma is VNVN.
>   */
> And chunk4 is purged.
>
> int ret = madvise(chunk1, 8M, NOVOLATILE);
> ASSERT(ret == 1);
> /* And you expect VNVN->N ?*/
>
> Right?

Yes. That's exactly right.

> If so, why should non-volatile function semantic allow it which cross over
> non-volatile areas in a range? I would like to fail such case because
> in case of MADV_REMOVE, it fails in the middle of operation if it encounter
> VM_LOCKED.
>
> What do you think about it?
Right, so I think this issue is maybe a problematic part of the VMA 
based approach.  While marking an area as nonvolatile twice might not 
make a lot of sense, I think userland applications would not appreciate 
the constraint that madvise(VOLATILE/NONVOLATILE) calls be made in 
perfect pairs of identical sizes.

For instance, if a browser has rendered a web page, but the page is so 
large that only a sliding window/view of that page is visible at one 
time, it may want to mark the regions not currently in the view as 
volatile.   So it would be nice (albeit naive) for that application that 
when the view location changed, it would just mark the new region as 
non-volatile, and any region not in the current view as volatile.  This 
would be easier then trying to calculate the diff of the old view region 
boundaries vs the new and modifying only the ranges that changed. 
Granted, doing so might be more efficient, but I'm not sure we can be 
sure every similar case would be more efficient.

So in my mind, double-clearing a flag should be allowed (as well as 
double-setting), as well as allowing for setting/clearing overlapping 
regions.

Aside from if the behavior should be allowed or not, the error mode of 
madvise is problematic as well, since failures can happen mid way 
through the operation, leaving the vmas in the range specified 
inconsistent. Since usually its only advisory, such inconsistent states 
aren't really problematic, and repeating the last action is probably fine.

The problem with NOVOLATILE's  purged state, with vmas, is that if we 
hit an error mid-way through, its hard to figure out what the state of 
the pages are for the range specified. Some of them could have been 
purged and set to non-volatile, while some may not be purged, and still 
left volatile. You can't just repeat the last action and get a sane 
result (as we lose the purged flag state).

With my earlier fallocate implementations, I tried to avoid this by 
making any memory allocations that might be required before making any 
state changes, so there wasn't a chance for a partial failure from 
-ENOMEM.  (It was also simpler because in my own range management code 
there were only volatile ranges,  non-volatility was simply the absence 
of a volatile range. With vmas we have to manage both volatile and 
nonvolatile vmas).  I'm not sure how this could be done with the vma 
method other then by maybe reworking the merge/split logic, but I'm wary 
of mucking with that too much as I know its performance sensitive.

Your thoughts?  Am I just being too set in my way of thinking here?

thanks
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
