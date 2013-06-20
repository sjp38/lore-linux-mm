Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 77B1F6B0033
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 20:26:13 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 20 Jun 2013 05:51:15 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id B4C621258053
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 05:55:04 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5K0QCWQ32768026
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 05:56:13 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5K0Q4HF026634
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 10:26:05 +1000
Date: Thu, 20 Jun 2013 08:26:03 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] slub: do not put a slab to cpu partial list when
 cpu_partial is 0
Message-ID: <20130620002603.GA2640@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1371623635-26575-1-git-send-email-iamjoonsoo.kim@lge.com>
 <51c1652d.246e320a.4057.ffffed4fSMTPIN_ADDED_BROKEN@mx.google.com>
 <20130619085250.GC12231@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130619085250.GC12231@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jun 19, 2013 at 05:52:50PM +0900, Joonsoo Kim wrote:
>On Wed, Jun 19, 2013 at 04:00:32PM +0800, Wanpeng Li wrote:
>> On Wed, Jun 19, 2013 at 03:33:55PM +0900, Joonsoo Kim wrote:
>> >In free path, we don't check number of cpu_partial, so one slab can
>> >be linked in cpu partial list even if cpu_partial is 0. To prevent this,
>> >we should check number of cpu_partial in put_cpu_partial().
>> >
>> 
>> How about skip get_partial entirely? put_cpu_partial is called 
>> in two paths, one is during refill cpu partial lists in alloc 
>> slow path, the other is in free slow path. And cpu_partial is 0 
>> just in debug mode. 
>> 
>> - alloc slow path, there is unnecessary to call get_partial 
>>   since cpu partial lists won't be used in debug mode. 
>> - free slow patch, new.inuse won't be true in debug mode 
>>   which lead to put_cpu_partial won't be called.
>> 
>
>In debug mode, put_cpu_partial() can't be called already on both path.
>But, if we assign 0 to cpu_partial via sysfs, put_cpu_partial() will be called
>on free slow path. On alloc slow path, it can't be called, because following
>test in get_partial_node() is always failed.
>
>available > s->cpu_partial / 2

Is it always true? We can freeze slab from partial list, and 
s->cpu_partial is 0. 

Regards,
Wanpeng Li 

>
>Thanks.
>
>> Regards,
>> Wanpeng Li 
>> 
>> >Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>> >
>> >diff --git a/mm/slub.c b/mm/slub.c
>> >index 57707f0..7033b4f 100644
>> >--- a/mm/slub.c
>> >+++ b/mm/slub.c
>> >@@ -1955,6 +1955,9 @@ static void put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
>> > 	int pages;
>> > 	int pobjects;
>> >
>> >+	if (!s->cpu_partial)
>> >+		return;
>> >+
>> > 	do {
>> > 		pages = 0;
>> > 		pobjects = 0;
>> >-- 
>> >1.7.9.5
>> >
>> >--
>> >To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> >the body to majordomo@kvack.org.  For more info on Linux MM,
>> >see: http://www.linux-mm.org/ .
>> >Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>> 
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
