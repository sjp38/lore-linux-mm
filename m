Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 47E9E6B0005
	for <linux-mm@kvack.org>; Wed,  6 Feb 2013 22:08:21 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 6 Feb 2013 22:08:20 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id E377D38C801D
	for <linux-mm@kvack.org>; Wed,  6 Feb 2013 22:08:17 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1738HiQ332390
	for <linux-mm@kvack.org>; Wed, 6 Feb 2013 22:08:17 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1738GUi015512
	for <linux-mm@kvack.org>; Thu, 7 Feb 2013 01:08:17 -0200
Message-ID: <51131A9E.3010208@linux.vnet.ibm.com>
Date: Wed, 06 Feb 2013 21:08:14 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCHv3 5/6] zswap: add to mm/
References: <1359409767-30092-1-git-send-email-sjenning@linux.vnet.ibm.com> <1359409767-30092-6-git-send-email-sjenning@linux.vnet.ibm.com> <20130129062756.GH4752@blaptop> <51080658.7060709@linux.vnet.ibm.com> <a06fbc6b-8731-4bfe-82ff-05e8d14d8595@default>
In-Reply-To: <a06fbc6b-8731-4bfe-82ff-05e8d14d8595@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 02/06/2013 05:47 PM, Dan Magenheimer wrote:
>> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
>> Subject: Re: [PATCHv3 5/6] zswap: add to mm/
>>
>> On 01/29/2013 12:27 AM, Minchan Kim wrote:
>>> First feeling is it's simple and nice approach.
>>> Although we have some problems to decide policy, it could solve by later patch
>>> so I hope we make basic infrasture more solid by lots of comment.
>>
>> Thanks very much for the review!
>>>
>>> Another question.
>>>
>>> What's the benefit of using mempool for zsmalloc?
>>> As you know, zsmalloc doesn't use mempool as default.
>>> I guess you see some benefit. if so, zram could be changed.
>>> If we can change zsmalloc's default scheme to use mempool,
>>> all of customer of zsmalloc could be enhanced, too.
>>
>> In the case of zswap, through experimentation, I found that adding a
>> mempool behind the zsmalloc pool added some elasticity to the pool.
>> Fewer stores failed if we kept a small reserve of pages around instead
>> of having to go back to the buddy allocator who, under memory
>> pressure, is more likely to reject our request.
>>
>> I don't see this situation being applicable to all zsmalloc users
>> however.  I don't think we want incorporate it directly into zsmalloc
>> for now.  The ability to register custom page alloc/free functions at
>> pool creation time allows users to do something special, like back
>> with a mempool, if they want to do that.
> 
> (sorry, still catching up on backlog after being gone last week)
> 
> IIUC, by using mempool, you are essentially setting aside a
> special cache of pageframes that only zswap can use (or other
> users of mempool, I don't know what other subsystems use it).
> So one would expect that fewer stores would fail if more
> pageframes are available to zswap, the same as if you had
> increased zswap_max_pool_percent by some small fraction.

Yes this is correct.

> 
> But by setting those pageframes aside, you are keeping them from
> general use, which may be a use with a higher priority as determined
> by the mm system.
> 
> This seems wrong to me.  Should every subsystem hide a bunch of
> pageframes away in case it might need them?

Well, like you said, any user of mempool does this.  There were two
reasons for using it in this way in zswap:

(1) pages allocations and frees happen very frequently and going to
the buddy allocator every time for these operations is more expensive.
 Especially the free-then-alloc pattern.  Its faster to free to a
mempool (if it is below its minimum) then get that page right back,
than free to the buddy allocator and (try to) get that page back.

(2) the bursty nature of swap writeback leads to a large number of
failures if there isn't some pool of pages ready to accept them,
especially for workloads with bursty memory demands.  The workload
suddenly requests a lot of memory, the system starts swapping, zswap
asks for pages but the buddy allocator is already swamped by requests
from the workload which isn't yet being throttled by direct reclaim.
The zswap allocations all fail and pages race by into the swap device.
 Having a mempool allows for a little buffer.  By the time the buffer
is used up, hopefully the workload is being throttled and the system
is more balanced.

Thanks,
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
