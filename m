Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id BE9D06B0078
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 02:23:50 -0500 (EST)
Received: from d06nrmr1707.portsmouth.uk.ibm.com (d06nrmr1707.portsmouth.uk.ibm.com [9.149.39.225])
	by mtagate5.uk.ibm.com (8.13.1/8.13.1) with ESMTP id o1Q7NmBC013585
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 07:23:48 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1707.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o1Q7Nm7W1327252
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 07:23:48 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o1Q7NlOj018439
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 07:23:48 GMT
Message-ID: <4B8776FC.30409@linux.vnet.ibm.com>
Date: Fri, 26 Feb 2010 08:23:40 +0100
From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 05/15] readahead: limit readahead size for small memory
 systems
References: <20100224031001.026464755@intel.com> <20100224031054.307027163@intel.com> <4B869682.9010709@linux.vnet.ibm.com> <20100226022907.GA22226@localhost>
In-Reply-To: <20100226022907.GA22226@localhost>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jens.axboe@oracle.com>, Matt Mackall <mpm@selenic.com>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Clemens Ladisch <clemens@ladisch.de>, Olivier Galibert <galibert@pobox.com>, Vivek Goyal <vgoyal@redhat.com>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Unfortunately without a chance to measure this atm, this patch now looks 
really good to me.
Thanks for adapting it to a read-ahead only per mem limit.
Acked-by: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>


Wu Fengguang wrote:
> On Thu, Feb 25, 2010 at 11:25:54PM +0800, Christian Ehrhardt wrote:
>>
>> Wu Fengguang wrote:
>>  > When lifting the default readahead size from 128KB to 512KB,
>>  > make sure it won't add memory pressure to small memory systems.
>>  >
>>  > For read-ahead, the memory pressure is mainly readahead buffers consumed
>>  > by too many concurrent streams. The context readahead can adapt
>>  > readahead size to thrashing threshold well.  So in principle we don't
>>  > need to adapt the default _max_ read-ahead size to memory pressure.
>>  >
>>  > For read-around, the memory pressure is mainly read-around misses on
>>  > executables/libraries. Which could be reduced by scaling down
>>  > read-around size on fast "reclaim passes".
>>  >
>>  > This patch presents a straightforward solution: to limit default
>>  > readahead size proportional to available system memory, ie.
>>  >                 512MB mem => 512KB readahead size
>>  >                 128MB mem => 128KB readahead size
>>  >                  32MB mem =>  32KB readahead size (minimal)
>>  >
>>  > Strictly speaking, only read-around size has to be limited.  However we
>>  > don't bother to seperate read-around size from read-ahead size for now.
>>  >
>>  > CC: Matt Mackall <mpm@selenic.com>
>>  > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
>>
>> What I state here is for read ahead in a "multi iozone sequential" 
>> setup, I can't speak for real "read around" workloads.
>> So probably your table is fine to cover read-around+read-ahead in one 
>> number.
> 
> OK.
> 
>> I have tested 256MB mem systems with 512kb readahead quite a lot.
>> On those 512kb is still by far superior to smaller readaheads and I 
>> didn't see major trashing or memory pressure impact.
> 
> In fact I'd expect a 64MB box to also benefit from 512kb readahead :)
> 
>> Therefore I would recommend a table like:
>>                 >=256MB mem => 512KB readahead size
>>                   128MB mem => 128KB readahead size
>>                    32MB mem =>  32KB readahead size (minimal)
> 
> So, I'm fed up with compromising the read-ahead size with read-around
> size.
> 
> There is no good to introduce a read-around size to confuse the user
> though.  Instead, I'll introduce a read-around size limit _on top of_
> the readahead size. This will allow power users to adjust
> read-ahead/read-around size at the same time, while saving the low end
> from unnecessary memory pressure :) I made the assumption that low end
> users have no need to request a large read-around size.
> 
> Thanks,
> Fengguang
> ---
> readahead: limit read-ahead size for small memory systems
> 
> When lifting the default readahead size from 128KB to 512KB,
> make sure it won't add memory pressure to small memory systems.
> 
> For read-ahead, the memory pressure is mainly readahead buffers consumed
> by too many concurrent streams. The context readahead can adapt
> readahead size to thrashing threshold well.  So in principle we don't
> need to adapt the default _max_ read-ahead size to memory pressure.
> 
> For read-around, the memory pressure is mainly read-around misses on
> executables/libraries. Which could be reduced by scaling down
> read-around size on fast "reclaim passes".
> 
> This patch presents a straightforward solution: to limit default
> read-ahead size proportional to available system memory, ie.
>                 512MB mem => 512KB readahead size
>                 128MB mem => 128KB readahead size
>                  32MB mem =>  32KB readahead size
> 
> CC: Matt Mackall <mpm@selenic.com>
> CC: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  mm/filemap.c   |    2 +-
>  mm/readahead.c |   22 ++++++++++++++++++++++
>  2 files changed, 23 insertions(+), 1 deletion(-)
> 
> --- linux.orig/mm/filemap.c	2010-02-26 10:04:28.000000000 +0800
> +++ linux/mm/filemap.c	2010-02-26 10:08:33.000000000 +0800
> @@ -1431,7 +1431,7 @@ static void do_sync_mmap_readahead(struc
>  	/*
>  	 * mmap read-around
>  	 */
> -	ra_pages = max_sane_readahead(ra->ra_pages);
> +	ra_pages = min(ra->ra_pages, roundup_pow_of_two(totalram_pages / 1024));
>  	if (ra_pages) {
>  		ra->start = max_t(long, 0, offset - ra_pages/2);
>  		ra->size = ra_pages;

-- 

Grusse / regards, Christian Ehrhardt
IBM Linux Technology Center, System z Linux Performance

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
