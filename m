Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id 609AC6B0031
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 07:17:36 -0500 (EST)
Received: by mail-qa0-f54.google.com with SMTP id f11so2874099qae.13
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 04:17:36 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id hi9si31401960qcb.15.2014.01.06.04.17.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jan 2014 04:17:35 -0800 (PST)
Date: Mon, 6 Jan 2014 13:17:19 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] sched/auto_group: fix consume memory even if add
 'noautogroup' in the cmdline
Message-ID: <20140106121719.GH31570@twins.programming.kicks-ass.net>
References: <1388139751-19632-1-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1388139751-19632-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Galbraith <bitbucket@online.de>

On Fri, Dec 27, 2013 at 06:22:31PM +0800, Wanpeng Li wrote:
> We have a server which have 200 CPUs and 8G memory, there is auto_group creation 

I'm hoping that is 8T, otherwise that's a severely under provisioned
system, that's a mere 40M per cpu, does that even work?

> which will almost consume 12MB memory even if add 'noautogroup' in the kernel 
> boot parameter. In addtion, SLUB per cpu partial caches freeing that is local to 
> a processor which requires the taking of locks at the price of more indeterminism 
> in the latency of the free. This patch fix it by check noautogroup earlier to avoid 
> free after unnecessary memory consumption.

That's just a bad changelog. It fails to explain the actual problem and
it babbles about unrelated things like SLUB details.

Also, I'm not entirely sure what the intention was of this code, I've so
far tried to ignore the entire autogroup fest... 

It looks like it creates and maintains the entire autogroup hierarchy,
such that if you at runtime enable the sysclt and move tasks 'back' to
the root cgroup you get the autogroup behaviour.

Was this intended? Mike?

This patch obviously breaks that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
