Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 54E776B0036
	for <linux-mm@kvack.org>; Fri, 18 Jul 2014 11:14:51 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id n3so1049588wiv.5
        for <linux-mm@kvack.org>; Fri, 18 Jul 2014 08:14:50 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id cd10si11893349wjc.14.2014.07.18.08.14.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 18 Jul 2014 08:14:49 -0700 (PDT)
Date: Fri, 18 Jul 2014 11:14:46 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: About refault distance
Message-ID: <20140718151446.GI29639@cmpxchg.org>
References: <BA6F50564D52C24884F9840E07E32DEC17D58E35@CDSMSX102.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BA6F50564D52C24884F9840E07E32DEC17D58E35@CDSMSX102.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Zhang, Tianfei" <tianfei.zhang@intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Jul 16, 2014 at 01:53:55AM +0000, Zhang, Tianfei wrote:
> Hi Johannes,
> 
> May I ask you a question about refault distance?
> 
> Is it supposed the distance of the first and second time to access the a faulted page cache is the same? In reality how about the
> ratio will be the same?
> 
>             Refault Distance1 = Refault Distance2
> 
> On the first refault, We supposed that:
>             Refault Distance = A
>             NR_INACTIVE_FILE = B
>             NR_ACTIVE_FILE = C
> 
> *                  fault page add to inactive list tail
>                     The Refault Distance  = A
>                           |
>  *                   B     |        |            C
> *              +--------------+   |            +-------------+
> *   reclaim <- |   inactive   | <-+-- demotion |    active   | <--+
> *              +--------------+                +-------------+    |
> *                     |                                           |
> *                     +-------------- promotion ------------------+
> 
> 
> Why we use A <= C to add faulted page to ACTIVE LIST?
> 
> Your patch is want to solve "A workload is thrashing when its pages are frequently used
> but they are evicted from the inactive list every time before another access would have
> promoted them to the active list." ?
> 
> so when a First Refault page add to INACTIVE LIST, it is a Distance B before eviction.
> So I am confuse the condition on workingset_refault().

The reuse distance of a page is B + A.  B + C is the available memory
overall.  When a page refaults, we want to compare its reuse distance
to overall memory to see if it is eligible for activation (= accessed
twice while in memory).  That check would be A + B <= B + C.  But we
can simply drop B on both sides and get A <= C.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
