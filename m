Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 4EF6F6B0032
	for <linux-mm@kvack.org>; Thu, 16 May 2013 11:30:41 -0400 (EDT)
Message-ID: <5194FB84.3000409@redhat.com>
Date: Thu, 16 May 2013 11:30:12 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv11 2/4] zbud: add to mm/
References: <1368448803-2089-1-git-send-email-sjenning@linux.vnet.ibm.com> <1368448803-2089-3-git-send-email-sjenning@linux.vnet.ibm.com> <3dfa0c20-ab39-4839-aaeb-46d51314afd4@default> <20130513205927.GA19183@medulla>
In-Reply-To: <20130513205927.GA19183@medulla>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 05/13/2013 04:59 PM, Seth Jennings wrote:
> On Mon, May 13, 2013 at 08:43:36AM -0700, Dan Magenheimer wrote:

>> The above appears to be a new addition to my original zbud design.
>> While it may appear to be a good idea for improving LRU-ness, I
>> suspect it may have unexpected side effects in that I think far
>> fewer "fat" zpages will be buddied, which will result in many more
>> unbuddied pages containing a single fat zpage, which means much worse
>> overall density on many workloads.
>
> Yes, I see what you are saying.  While I can't think of a workload that would
> cause this kind of allocation pattern in practice, I also don't have a way to
> measure the impact this first-fit fast path code has on density.
>
>>
>> This may not be apparent in kernbench or specjbb or any workload
>> where the vast majority of zpages compress to less than PAGE_SIZE/2,
>> but for a zsize distribution that is symmetric or "skews fat",
>> it may become very apparent.
>
> I'd personally think it should be kept because 1) it makes a fast allocation
> path and 2) improves LRU locality.  But, without numbers to demonstrate a
> performance improvements or impacts on density, I wouldn't be opposed to taking
> it out if it is a point of contention.
>
> Anyone else care to weigh in?

I have no idea how much the "LRU-ness" of the compressed swap
cache matters, since the entire thing will be full of not
recently used data.

I can certainly see Dan's point too, but there simply is not
enough data to measure this.

Would it be an idea to merge this patch, and then send a follow-up
patch that:
1) makes this optimization a (debugfs) tunable, and
2) exports statistics on how well pages are packing

That way we would be able to figure out which way should be the
default.

I'm giving the patch my Acked-by, because I want this code to
finally move forward.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
