Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 6FE729000BD
	for <linux-mm@kvack.org>; Thu, 15 Sep 2011 18:17:45 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p8FKv9NK020077
	for <linux-mm@kvack.org>; Thu, 15 Sep 2011 16:57:09 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8FMHirp272498
	for <linux-mm@kvack.org>; Thu, 15 Sep 2011 18:17:44 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8FMHhqI030437
	for <linux-mm@kvack.org>; Thu, 15 Sep 2011 18:17:43 -0400
Subject: Re: [PATCH v2 0/3] staging: zcache: xcfmalloc support
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <4E725109.3010609@linux.vnet.ibm.com>
References: <1315404547-20075-1-git-send-email-sjenning@linux.vnet.ibm.com>
	 <20110909203447.GB19127@kroah.com> <4E6ACE5B.9040401@vflare.org>
	 <4E6E18C6.8080900@linux.vnet.ibm.com> <4E6EB802.4070109@vflare.org>
	 <4E6F7DA7.9000706@linux.vnet.ibm.com>
	 <4E6FC8A1.8070902@vflare.org 4E72284B.2040907@linux.vnet.ibm.com>
	 <075c4e4c-a22d-47d1-ae98-31839df6e722@default>
	 <4E725109.3010609@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 15 Sep 2011 15:17:42 -0700
Message-ID: <1316125062.16137.80.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Greg KH <greg@kroah.com>, gregkh@suse.de, devel@driverdev.osuosl.org, cascardo@holoscopio.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, brking@linux.vnet.ibm.com, rcj@linux.vnet.ibm.com

On Thu, 2011-09-15 at 14:24 -0500, Seth Jennings wrote:
> How would you suggest that I measure xcfmalloc performance on a "very
> large set of workloads".  I guess another form of that question is: How
> did xvmalloc do this?

Well, it didn't have a competitor, so this probably wasn't done. :)

I'd like to see a microbenchmarky sort of thing.  Do a million (or 100
million, whatever) allocations, and time it for both allocators doing
the same thing.  You just need to do the *same* allocations for both.

It'd be interesting to see the shape of a graph if you did:

	for (i = 0; i < BIG_NUMBER; i++) 
		for (j = MIN_ALLOC; j < MAX_ALLOC; j += BLOCK_SIZE) 
			alloc(j);
			free();

... basically for both allocators.  Let's see how the graphs look.  You
could do it a lot of different ways: alloc all, then free all, or alloc
one free one, etc...  Maybe it will surprise us.  Maybe the page
allocator overhead will dominate _everything_, and we won't even see the
x*malloc() functions show up.

The other thing that's important is to think of cases like I described
that would cause either allocator to do extra splits/joins or be slow in
other ways.  I expect xcfmalloc() to be slowest when it is allocating
and has to break down a reserve page.  Let's say it does a bunch of ~3kb
allocations and has no pages on the freelists, it will:

	1. scan each of the 64 freelists heads (512 bytes of cache)
	2. split a 4k page
	3. reinsert the 1k remainder

Next time, it will:

	1. scan, and find the 1k bit
	2. continue scanning, eventually touching each freelist...
	3. split a 4k page
	4. reinsert the 2k remainder

It'll end up doing a scan/split/reinsert in 3/4 of the cases, I think.
The case of the freelists being quite empty will also be quite common
during times the pool is expanding.  I think xvmalloc() will have some
of the same problems, but let's see if it does in practice.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
