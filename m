Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 932F49000BD
	for <linux-mm@kvack.org>; Fri, 16 Sep 2011 13:37:01 -0400 (EDT)
Received: by vws7 with SMTP id 7so5036389vws.35
        for <linux-mm@kvack.org>; Fri, 16 Sep 2011 10:36:59 -0700 (PDT)
Message-ID: <4E738936.5000405@vflare.org>
Date: Fri, 16 Sep 2011 13:36:54 -0400
From: Nitin Gupta <ngupta@vflare.org>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/3] staging: zcache: xcfmalloc support
References: <1315404547-20075-1-git-send-email-sjenning@linux.vnet.ibm.com>  <20110909203447.GB19127@kroah.com> <4E6ACE5B.9040401@vflare.org>  <4E6E18C6.8080900@linux.vnet.ibm.com> <4E6EB802.4070109@vflare.org>  <4E6F7DA7.9000706@linux.vnet.ibm.com>  <4E6FC8A1.8070902@vflare.org 4E72284B.2040907@linux.vnet.ibm.com>  <075c4e4c-a22d-47d1-ae98-31839df6e722@default>  <4E725109.3010609@linux.vnet.ibm.com> <1316125062.16137.80.camel@nimitz>
In-Reply-To: <1316125062.16137.80.camel@nimitz>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Greg KH <greg@kroah.com>, gregkh@suse.de, devel@driverdev.osuosl.org, cascardo@holoscopio.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, brking@linux.vnet.ibm.com, rcj@linux.vnet.ibm.com

On 09/15/2011 06:17 PM, Dave Hansen wrote:

> On Thu, 2011-09-15 at 14:24 -0500, Seth Jennings wrote:
>> How would you suggest that I measure xcfmalloc performance on a "very
>> large set of workloads".  I guess another form of that question is: How
>> did xvmalloc do this?
> 
> Well, it didn't have a competitor, so this probably wasn't done. :)
>


A lot of testing was done for xvmalloc (and its predecessor, tlsf)
before it was integrated into zram:

http://code.google.com/p/compcache/wiki/AllocatorsComparison
http://code.google.com/p/compcache/wiki/xvMalloc
http://code.google.com/p/compcache/wiki/xvMallocPerformance

I think we can use the same set of testing tools. See:
http://code.google.com/p/compcache/source/browse/#hg%2Fsub-projects%2Ftesting

These tools do issue mix of alloc and frees each with some probability
which can be adjusted in code.

There is also a tool called "swap replay" which collects swap-out traces
and simulates the same behavior in userspace, allowing allocator testing
with "real world" traces. See:
http://code.google.com/p/compcache/wiki/SwapReplay

 
> I'd like to see a microbenchmarky sort of thing.  Do a million (or 100
> million, whatever) allocations, and time it for both allocators doing
> the same thing.  You just need to do the *same* allocations for both.
> 
> It'd be interesting to see the shape of a graph if you did:
> 
> 	for (i = 0; i < BIG_NUMBER; i++) 
> 		for (j = MIN_ALLOC; j < MAX_ALLOC; j += BLOCK_SIZE) 
> 			alloc(j);
> 			free();
> 
> ... basically for both allocators.  Let's see how the graphs look.  You
> could do it a lot of different ways: alloc all, then free all, or alloc
> one free one, etc...  Maybe it will surprise us.  Maybe the page
> allocator overhead will dominate _everything_, and we won't even see the
> x*malloc() functions show up.
> 
> The other thing that's important is to think of cases like I described
> that would cause either allocator to do extra splits/joins or be slow in
> other ways.  I expect xcfmalloc() to be slowest when it is allocating
> and has to break down a reserve page.  Let's say it does a bunch of ~3kb
> allocations and has no pages on the freelists, it will:
> 
> 	1. scan each of the 64 freelists heads (512 bytes of cache)
> 	2. split a 4k page
> 	3. reinsert the 1k remainder
> 
> Next time, it will:
> 
> 	1. scan, and find the 1k bit
> 	2. continue scanning, eventually touching each freelist...
> 	3. split a 4k page
> 	4. reinsert the 2k remainder
> 
> It'll end up doing a scan/split/reinsert in 3/4 of the cases, I think.
> The case of the freelists being quite empty will also be quite common
> during times the pool is expanding.  I think xvmalloc() will have some
> of the same problems, but let's see if it does in practice.
>



Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
