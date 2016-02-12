Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f182.google.com (mail-io0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id 52DDB6B0005
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 07:23:14 -0500 (EST)
Received: by mail-io0-f182.google.com with SMTP id g203so63935402iof.2
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 04:23:14 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id x83si5468170ioi.128.2016.02.12.04.23.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Feb 2016 04:23:13 -0800 (PST)
Subject: Re: [RFC PATCH 3/3] mm: increase scalability of global memory
 commitment accounting
References: <1455115941-8261-1-git-send-email-aryabinin@virtuozzo.com>
 <1455115941-8261-3-git-send-email-aryabinin@virtuozzo.com>
 <1455127253.715.36.camel@schen9-desk2.jf.intel.com>
 <20160210132818.589451dbb5eafae3fdb4a7ec@linux-foundation.org>
 <1455150256.715.60.camel@schen9-desk2.jf.intel.com>
 <20160211125103.8a4fb0ffed593938321755d2@linux-foundation.org>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <56BDCEF2.3030409@virtuozzo.com>
Date: Fri, 12 Feb 2016 15:24:18 +0300
MIME-Version: 1.0
In-Reply-To: <20160211125103.8a4fb0ffed593938321755d2@linux-foundation.org>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Tim Chen <tim.c.chen@linux.intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, Mel Gorman <mgorman@techsingularity.net>, Vladimir Davydov <vdavydov@virtuozzo.com>, Konstantin Khlebnikov <koct9i@gmail.com>

On 02/11/2016 11:51 PM, Andrew Morton wrote:
> On Wed, 10 Feb 2016 16:24:16 -0800 Tim Chen <tim.c.chen@linux.intel.com> wrote:
> 
>> On Wed, 2016-02-10 at 13:28 -0800, Andrew Morton wrote:
>>
>>>
>>> If a process is unmapping 4MB then it's pretty crazy for us to be
>>> hitting the percpu_counter 32 separate times for that single operation.
>>>
>>> Is there some way in which we can batch up the modifications within the
>>> caller and update the counter less frequently?  Perhaps even in a
>>> single hit?
>>
>> I think the problem is the batch size is too small and we overflow
>> the local counter into the global counter for 4M allocations.
> 
> That's one way of looking at the issue.  The other way (which I point
> out above) is that we're calling vm_[un]_acct_memory too frequently
> when mapping/unmapping 4M segments.
> 

We call it only once per mmap() or munmap(), so there is nothing to improve.

> Exactly which mmap.c callsite is causing this issue?
> 


mmap_region() (or do_brk()) ->
	security_vm_enough_memory() ->
		__vm_enough_memory() ->
			vm_acct_memory()

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
