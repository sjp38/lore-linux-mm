Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 715326B0034
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 20:25:29 -0400 (EDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 16 Aug 2013 10:14:34 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 98DA8357804E
	for <linux-mm@kvack.org>; Fri, 16 Aug 2013 10:25:24 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7G0PDBM4325776
	for <linux-mm@kvack.org>; Fri, 16 Aug 2013 10:25:13 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7G0POLI028502
	for <linux-mm@kvack.org>; Fri, 16 Aug 2013 10:25:24 +1000
Date: Fri, 16 Aug 2013 08:25:22 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: kswapd skips compaction if reclaim order drops to zero?
Message-ID: <20130816002522.GA13179@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <CAJd=RBBF2h_tRpbTV6OkxQOfkvKt=ebn_PbE8+r7JxAuaFZxFQ@mail.gmail.com>
 <20130815104727.GT2296@suse.de>
 <20130815134139.GC8437@gmail.com>
 <20130815135627.GX2296@suse.de>
 <20130815141004.GD8437@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130815141004.GD8437@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, Hillf Danton <dhillf@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

Hi Minchan,
On Thu, Aug 15, 2013 at 11:10:04PM +0900, Minchan Kim wrote:
>On Thu, Aug 15, 2013 at 02:56:27PM +0100, Mel Gorman wrote:
>> On Thu, Aug 15, 2013 at 10:41:39PM +0900, Minchan Kim wrote:
>> > Hey Mel,
>> > 
>> > On Thu, Aug 15, 2013 at 11:47:27AM +0100, Mel Gorman wrote:
>> > > On Thu, Aug 15, 2013 at 06:02:53PM +0800, Hillf Danton wrote:
>> > > > If the allocation order is not high, direct compaction does nothing.
>> > > > Can we skip compaction here if order drops to zero?
>> > > > 
>> > > 
>> > > If the allocation order is not high then
>> > > 
>> > > pgdat_needs_compaction == (order > 0) == false == no calling compact_pdatt
>> > > 
>> > > In the case where order is reset to 0 due to fragmentation then it does
>> > > call compact_pgdat but it does no work due to the cc->order check in
>> > > __compact_pgdat.
>> > > 
>> > 
>> > I am looking at mmotm-2013-08-07-16-55 but couldn't find cc->order
>> > check right before compact_zone in __comact_pgdat.
>> > Could you pinpoint code piece?
>> > 
>> 
>> Thanks, I screwed up as that check happens too late. However, it still
>> ends up not mattering because it does this
>> 
>> compact_pgdat
>>   -> __compact_pgdat
>>     -> compact_zone
>>       -> compaction_suitable
>> 
>> For order == 0, compaction_suitable will return either COMPACT_SKIPPED
>> (if the watermarks are not met) and COMPACT_PARTIAL otherwise. Either
>> way, compaction doesn't run.
>
>In compaction_suitable, it could pass first zone_watermark_ok
>but failed second zone_watermark_ok while fragindex is -1000
>so compaction could run.
>

I'm not sure why you said that second zone_watermark_ok failed while 
fragindex is -1000, actually they are the same check against order 0.

First:
watermark = low_wmark_pages(zone) + (2UL << order);
zone_watermark_ok(zone, 0, watermark, 0, 0);

Second:
fragindex == -1000 && zone_watermark_ok(zone, order, watermark, 0, 0)

Both COMPACT_SKIPPED and COMPACT_PARTIAL will fail compaction.

Regards,
Wanpeng Li 

>And we shouldn't depend on such coincidence.
>
>
>> 
>> -- 
>> Mel Gorman
>> SUSE Labs
>> 
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
>-- 
>Kind regards,
>Minchan Kim
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
