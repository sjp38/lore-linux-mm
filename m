Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 4A4F16B0007
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 10:08:05 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 4 Feb 2013 10:08:03 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 4CC4E6E805E
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 10:07:58 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r14F7x4v301932
	for <linux-mm@kvack.org>; Mon, 4 Feb 2013 10:07:59 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r14F7wL5025250
	for <linux-mm@kvack.org>; Mon, 4 Feb 2013 13:07:59 -0200
Message-ID: <510FCECC.6020703@linux.vnet.ibm.com>
Date: Mon, 04 Feb 2013 09:07:56 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCHv4 0/7] zswap: compressed swap caching
References: <1359495627-30285-1-git-send-email-sjenning@linux.vnet.ibm.com> <1359682784.3574.2.camel@kernel> <510BDB8F.5000104@linux.vnet.ibm.com> <1359939818.9366.1.camel@kernel.cn.ibm.com>
In-Reply-To: <1359939818.9366.1.camel@kernel.cn.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 02/03/2013 07:03 PM, Simon Jeons wrote:
> On Fri, 2013-02-01 at 09:13 -0600, Seth Jennings wrote:
>> On 01/31/2013 07:39 PM, Simon Jeons wrote:
>>> Hi Seth,
>>> On Tue, 2013-01-29 at 15:40 -0600, Seth Jennings wrote:
>> <snip>
>>>> Performance, Kernel Building:
>>>>
>>>> Setup
>>>> ========
>>>> Gentoo w/ kernel v3.7-rc7
>>>> Quad-core i5-2500 @ 3.3GHz
>>>> 512MB DDR3 1600MHz (limited with mem=512m on boot)
>>>> Filesystem and swap on 80GB HDD (about 58MB/s with hdparm -t)
>>>> majflt are major page faults reported by the time command
>>>> pswpin/out is the delta of pswpin/out from /proc/vmstat before and after
>>>> then make -jN
>>>>
>>>> Summary
>>>> ========
>>>> * Zswap reduces I/O and improves performance at all swap pressure levels.
>>>>
>>>> * Under heavy swaping at 24 threads, zswap reduced I/O by 76%, saving
>>>>   over 1.5GB of I/O, and cut runtime in half.
>>>
>>> How to get your benchmark?
>>
>> It's just kernel building.  So "make" :)
>>
>> I intentionally choose this workload so people wouldn't have to jump
>> through hoops to replicate the results.
> 
> Since there already have zram which can handle anonymous pages
> compression, why need zswap? What's the difference of design between
> zram and zswap? 

zram is implemented is a virtual block device.  It interfaces with the
block device layer, not the swap code.  In fact, zram can be used as a
generic compressed RAM disk, not only for compressed swap.  One can
think of it as a RAM disk + compression.

So zram is the actual swap device while zswap is a caching layer above
the swap device.  zswap is not the swap device itself like zram.

Hope this clears up the difference :)

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
