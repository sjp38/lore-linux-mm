Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 0F5776B0005
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 15:51:05 -0500 (EST)
Received: by mail-pf0-f169.google.com with SMTP id q63so35112395pfb.0
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 12:51:05 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d82si7853714pfj.173.2016.02.11.12.51.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Feb 2016 12:51:04 -0800 (PST)
Date: Thu, 11 Feb 2016 12:51:03 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 3/3] mm: increase scalability of global memory
 commitment accounting
Message-Id: <20160211125103.8a4fb0ffed593938321755d2@linux-foundation.org>
In-Reply-To: <1455150256.715.60.camel@schen9-desk2.jf.intel.com>
References: <1455115941-8261-1-git-send-email-aryabinin@virtuozzo.com>
	<1455115941-8261-3-git-send-email-aryabinin@virtuozzo.com>
	<1455127253.715.36.camel@schen9-desk2.jf.intel.com>
	<20160210132818.589451dbb5eafae3fdb4a7ec@linux-foundation.org>
	<1455150256.715.60.camel@schen9-desk2.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, Mel Gorman <mgorman@techsingularity.net>, Vladimir Davydov <vdavydov@virtuozzo.com>, Konstantin Khlebnikov <koct9i@gmail.com>

On Wed, 10 Feb 2016 16:24:16 -0800 Tim Chen <tim.c.chen@linux.intel.com> wrote:

> On Wed, 2016-02-10 at 13:28 -0800, Andrew Morton wrote:
> 
> > 
> > If a process is unmapping 4MB then it's pretty crazy for us to be
> > hitting the percpu_counter 32 separate times for that single operation.
> > 
> > Is there some way in which we can batch up the modifications within the
> > caller and update the counter less frequently?  Perhaps even in a
> > single hit?
> 
> I think the problem is the batch size is too small and we overflow
> the local counter into the global counter for 4M allocations.

That's one way of looking at the issue.  The other way (which I point
out above) is that we're calling vm_[un]_acct_memory too frequently
when mapping/unmapping 4M segments.

Exactly which mmap.c callsite is causing this issue?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
