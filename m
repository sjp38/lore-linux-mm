Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 13A4C6B0005
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 14:45:07 -0500 (EST)
Received: by mail-pf0-f178.google.com with SMTP id q63so34305950pfb.0
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 11:45:07 -0800 (PST)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id e69si14379271pfd.66.2016.02.11.11.45.06
        for <linux-mm@kvack.org>;
        Thu, 11 Feb 2016 11:45:06 -0800 (PST)
Subject: Re: [RFC PATCH 3/3] mm: increase scalability of global memory
 commitment accounting
References: <1455115941-8261-1-git-send-email-aryabinin@virtuozzo.com>
 <1455115941-8261-3-git-send-email-aryabinin@virtuozzo.com>
 <1455127253.715.36.camel@schen9-desk2.jf.intel.com>
 <20160210132818.589451dbb5eafae3fdb4a7ec@linux-foundation.org>
 <1455150256.715.60.camel@schen9-desk2.jf.intel.com>
 <56BC9281.6090505@virtuozzo.com>
 <1455214844.715.86.camel@schen9-desk2.jf.intel.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <56BCE4C0.8070200@sr71.net>
Date: Thu, 11 Feb 2016 11:45:04 -0800
MIME-Version: 1.0
In-Reply-To: <1455214844.715.86.camel@schen9-desk2.jf.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, Mel Gorman <mgorman@techsingularity.net>, Vladimir Davydov <vdavydov@virtuozzo.com>, Konstantin Khlebnikov <koct9i@gmail.com>

On 02/11/2016 10:20 AM, Tim Chen wrote:
> The brk1 test is also somewhat pathologic.  It
> does nothing but brk which is unlikely for real workload.
> So we have to be careful when we are tuning our system
> behavior for brk1 throughput. We'll need to make sure
> whatever changes we made don't impact other more useful
> workloads adversely.

Yeah, there are *so* many alternatives to using brk() or mmap()/munmap()
frequently.

glibc has tunables to tune how tightly coupled malloc()/free() are with
virtual space allocation.  Raising those can reduce the brk() frequency.

There are also other allocators that take much larger chunks of virtual
address space and then "free" memory with MADV_FREE instead of brk().  I
think jemalloc does this, for instance.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
