Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 89BFF6B00F4
	for <linux-mm@kvack.org>; Mon, 14 May 2012 16:27:55 -0400 (EDT)
Date: Mon, 14 May 2012 16:26:34 -0400 (EDT)
Message-Id: <20120514.162634.1094732813264319951.davem@davemloft.net>
Subject: Re: [PATCH 01/12] netvm: Prevent a stream-specific deadlock
From: David Miller <davem@davemloft.net>
In-Reply-To: <20120514105604.GB29102@suse.de>
References: <1336658065-24851-2-git-send-email-mgorman@suse.de>
	<20120511.011034.557833140906762226.davem@davemloft.net>
	<20120514105604.GB29102@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, netdev@vger.kernel.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, Trond.Myklebust@netapp.com, neilb@suse.de, hch@infradead.org, a.p.zijlstra@chello.nl, michaelc@cs.wisc.edu, emunson@mgebm.net

From: Mel Gorman <mgorman@suse.de>
Date: Mon, 14 May 2012 11:56:04 +0100

> On Fri, May 11, 2012 at 01:10:34AM -0400, David Miller wrote:
>> From: Mel Gorman <mgorman@suse.de>
>> Date: Thu, 10 May 2012 14:54:14 +0100
>> 
>> > It could happen that all !SOCK_MEMALLOC sockets have buffered so
>> > much data that we're over the global rmem limit. This will prevent
>> > SOCK_MEMALLOC buffers from receiving data, which will prevent userspace
>> > from running, which is needed to reduce the buffered data.
>> > 
>> > Fix this by exempting the SOCK_MEMALLOC sockets from the rmem limit.
>> > 
>> > Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
>> > Signed-off-by: Mel Gorman <mgorman@suse.de>
>> 
>> This introduces an invariant which I am not so sure is enforced.
>> 
>> With this change it is absolutely required that once a socket
>> becomes SOCK_MEMALLOC it must never _ever_ lose that attribute.
>> 
> 
> This is effectively true. In the NFS case, the flag is cleared on
> swapoff after all the entries have been paged in. In the NBD case,
> SOCK_MEMALLOC is left set until the socket is destroyed. I'll update the
> changelog.

Bugs happen, you need to find a way to assert that nobody every does
this.  Because if a bug is introduced which makes this happen, it will
otherwise be very difficult to debug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
