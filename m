From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [LSF/MM TOPIC]swap improvements for fast SSD
Date: Tue, 19 Mar 2013 12:25:36 +0800
Message-ID: <44411.2792647958$1363667176@news.gmane.org>
References: <20130122065341.GA1850@kernel.org>
 <5142EC5A.4010509@gmail.com>
 <5146EEA5.4030003@oracle.com>
 <20130319012725.GA28880@kernel.org>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UHo7p-0008L9-Bh
	for glkm-linux-mm-2@m.gmane.org; Tue, 19 Mar 2013 05:26:13 +0100
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 10B7E6B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 00:25:46 -0400 (EDT)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 19 Mar 2013 14:23:43 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 139062CE8052
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 15:25:39 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2J4Cc8l262622
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 15:12:38 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2J4Pcvt004093
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 15:25:38 +1100
Content-Disposition: inline
In-Reply-To: <20130319012725.GA28880@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: Bob Liu <bob.liu@oracle.com>, Simon Jeons <simon.jeons@gmail.com>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, dan.magenheimer@oracle.com, sjenning@linux.vnet.ibm.com, rcj@linux.vnet.ibm.com

On Tue, Mar 19, 2013 at 09:27:25AM +0800, Shaohua Li wrote:
>On Mon, Mar 18, 2013 at 06:38:29PM +0800, Bob Liu wrote:
>> 
>> On 03/15/2013 05:39 PM, Simon Jeons wrote:
>> > On 01/22/2013 02:53 PM, Shaohua Li wrote:
>> >> Hi,
>> >>
>> >> Because of high density, low power and low price, flash storage (SSD)
>> >> is a good
>> >> candidate to partially replace DRAM. A quick answer for this is using
>> >> SSD as
>> >> swap. But Linux swap is designed for slow hard disk storage. There are
>> >> a lot of
>> >> challenges to efficiently use SSD for swap:
>> >>
>> >> 1. Lock contentions (swap_lock, anon_vma mutex, swap address space lock)
>> >> 2. TLB flush overhead. To reclaim one page, we need at least 2 TLB
>> >> flush. This
>> >> overhead is very high even in a normal 2-socket machine.
>> >> 3. Better swap IO pattern. Both direct and kswapd page reclaim can do
>> >> swap,
>> >> which makes swap IO pattern is interleave. Block layer isn't always
>> >> efficient
>> >> to do request merge. Such IO pattern also makes swap prefetch hard.
>> >> 4. Swap map scan overhead. Swap in-memory map scan scans an array,
>> >> which is
>> >> very inefficient, especially if swap storage is fast.
>> >> 5. SSD related optimization, mainly discard support
>> >> 6. Better swap prefetch algorithm. Besides item 3, sequentially
>> >> accessed pages
>> >> aren't always in LRU list adjacently, so page reclaim will not swap
>> >> such pages
>> >> in adjacent storage sectors. This makes swap prefetch hard.
>> >> 7. Alternative page reclaim policy to bias reclaiming anonymous page.
>> >> Currently reclaim anonymous page is considering harder than reclaim
>> >> file pages,
>> >> so we bias reclaiming file pages. If there are high speed swap
>> >> storage, we are
>> >> considering doing swap more aggressively.
>> >> 8. Huge page swap. Huge page swap can solve a lot of problems above,
>> >> but both
>> >> THP and hugetlbfs don't support swap.
>> > 
>> > Could you tell me in which workload hugetlb/thp pages can't swapout
>> > influence your performance? Is it worth?
>> > 
>> 
>> I'm also very interesting in this workload.
>> I think hugetlb/thp pages can be a potential user of zprojects like
>> zswap/zcache.
>> We can try to compress those pages before breaking them to normal pages.
>
>I don't have particular workload and don't have data for obvious reason. What I
>expected is swapout hugetlb/thp is to reduce some overheads (eg, tlb flush) and
>improve IO pattern.

Hi Shaohua and Bob,

I'm doing this work currently. :-)

Regards,
Wanpeng Li 

>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
