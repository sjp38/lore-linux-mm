Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 35BA86B0047
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 01:32:47 -0500 (EST)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id mBJ6YAfG004583
	for <linux-mm@kvack.org>; Thu, 18 Dec 2008 23:34:10 -0700
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mBJ6YrPf231802
	for <linux-mm@kvack.org>; Thu, 18 Dec 2008 23:34:53 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mBJ6YrM1024348
	for <linux-mm@kvack.org>; Thu, 18 Dec 2008 23:34:53 -0700
Subject: Re: [rfc][patch 1/2] mnt_want_write speedup 1
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20081219061937.GA16268@wotan.suse.de>
References: <20081219061937.GA16268@wotan.suse.de>
Content-Type: text/plain
Date: Thu, 18 Dec 2008 22:34:52 -0800
Message-Id: <1229668492.17206.594.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2008-12-19 at 07:19 +0100, Nick Piggin wrote:
> Hi. Fun, chasing down performance regressions.... I wonder what people think
> about these patches? Is it OK to bloat struct vfsmount? Any races?

Very cool stuff, Nick.  I especially like how much it simplifies things
and removes *SO* much code.

Bloating the vfsmount was one of the things that really, really tried to
avoid.  When I start to think about the SGI machines, it gets me really
worried.  I went to a lot of trouble to make sure that the per-vfsmount
memory overhead didn't scale with the number of cpus.

> This could
> be made even faster if mnt_make_readonly could tolerate a really high latency
> synchronize_rcu()... can it?)

Yes, I think it can tolerate it.  There's a lot of work to do, and we
already have to go touch all the other per-cpu objects.  There also
tends to be writeout when this happens, so I don't think a few seconds,
even, will be noticed.

> This patch speeds up lmbench lat_mmap test by about 8%. lat_mmap is set up
> basically to mmap a 64MB file on tmpfs, fault in its pages, then unmap it.
> A microbenchmark yes, but it exercises some important paths in the mm.

Do you know where the overhead actually came from?  Was it the
spinlocks?  Was removing all the atomic ops what really helped?

I'll take a more in-depth look at your code tomorrow and see if I see
any races.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
