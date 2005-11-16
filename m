Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e31.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id jAGG5E5g029030
	for <linux-mm@kvack.org>; Wed, 16 Nov 2005 11:05:14 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jAGG51Ia061976
	for <linux-mm@kvack.org>; Wed, 16 Nov 2005 09:05:01 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id jAGG5Dx5022347
	for <linux-mm@kvack.org>; Wed, 16 Nov 2005 09:05:14 -0700
Subject: Re: [RFC] sys_punchhole()
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <1131686314.2833.0.camel@laptopd505.fenrus.org>
References: <1131664994.25354.36.camel@localhost.localdomain>
	 <1131686314.2833.0.camel@laptopd505.fenrus.org>
Content-Type: text/plain
Date: Wed, 16 Nov 2005 08:05:06 -0800
Message-Id: <1132157106.24066.61.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjan@infradead.org>
Cc: akpm@osdl.org, andrea@suse.de, hugh@veritas.com, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2005-11-11 at 06:18 +0100, Arjan van de Ven wrote:
> On Thu, 2005-11-10 at 15:23 -0800, Badari Pulavarty wrote:
> > 
> > We discussed this in madvise(REMOVE) thread - to add support 
> > for sys_punchhole(fd, offset, len) to complete the functionality
> > (in the future).
> 
> in the past always this was said to be "really hard" in linux locking
> wise, esp. the locking with respect to truncate...
> 
> did you find a solution to this problem ?

I have been thinking about some of the race condition we might run into.
Its hard to think all of them, when I really don't have any code to play
with :(

Anyway, I think race against truncate is fine. We hold i_alloc_sem -
which should serialize against truncates. This should also serialize
against DIO. Holding i_sem should take care of writers.

One concern I can think of is, racing with read(2). While we are
thrashing pagecache and calling filesystem to free up the blocks - 
a read(2) could read old disk block and give old data (since it won't
find it in pagecache). This could become a security hole :(

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
