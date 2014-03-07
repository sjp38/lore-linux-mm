Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 56CB76B0031
	for <linux-mm@kvack.org>; Fri,  7 Mar 2014 12:15:30 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id kl14so4424289pab.4
        for <linux-mm@kvack.org>; Fri, 07 Mar 2014 09:15:30 -0800 (PST)
Received: from blackbird.sr71.net ([2001:19d0:2:6:209:6bff:fe9a:902])
        by mx.google.com with ESMTP id m7si8953218pbl.63.2014.03.07.09.15.27
        for <linux-mm@kvack.org>;
        Fri, 07 Mar 2014 09:15:28 -0800 (PST)
Message-ID: <5319FEA1.50107@sr71.net>
Date: Fri, 07 Mar 2014 09:15:13 -0800
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH 6/7] x86: mm: set TLB flush tunable to sane value
References: <20140306004519.BBD70A1A@viggo.jf.intel.com>	 <20140306004529.5510B23D@viggo.jf.intel.com> <1394157304.2555.21.camel@buesod1.americas.hpqcorp.net>
In-Reply-To: <1394157304.2555.21.camel@buesod1.americas.hpqcorp.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, ak@linux.intel.com, kirill.shutemov@linux.intel.com, mgorman@suse.de, alex.shi@linaro.org, x86@kernel.org, linux-mm@kvack.org, dave.hansen@linux.intel.com

On 03/06/2014 05:55 PM, Davidlohr Bueso wrote:
> On Wed, 2014-03-05 at 16:45 -0800, Dave Hansen wrote:
>> From: Dave Hansen <dave.hansen@linux.intel.com>
>>
>> Now that we have some shiny new tracepoints, we can actually
>> figure out what the heck is going on.
>>
>> During a kernel compile, 60% of the flush_tlb_mm_range() calls
>> are for a single page.  It breaks down like this:
> 
> It would be interesting to see similar data for opposite workloads with
> more random access patterns. That's normally when things start getting
> fun in the tlb world.

First of all, thanks for testing.  It's much appreciated!

Any suggestions for opposite workloads?

I've seen this tunable have really heavy effects on ebizzy.  It fits
almost entirely within the itlb and if we are doing full flushes, it
eats the itlb and increases the misses about 10x.  Even putting this
tunable above 500 pages (which is pretty insane) didn't help it.

Things that thrash the TLB don't really care if someone invalidates
their TLB since they're thrashing it anyway.

I've had a really hard time finding workloads that _care_ or are
affected by small changes in this tunable.  That's one of the reasons I
tried to simplify it: it's just not worth the complexity.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
