Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 72B8A6B005D
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 10:42:39 -0500 (EST)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Fri, 4 Jan 2013 08:42:38 -0700
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 571EE1FF001C
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 08:42:25 -0700 (MST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r04FgUd4255276
	for <linux-mm@kvack.org>; Fri, 4 Jan 2013 08:42:32 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r04FgT9w007958
	for <linux-mm@kvack.org>; Fri, 4 Jan 2013 08:42:29 -0700
Message-ID: <50E6F862.2030703@linux.vnet.ibm.com>
Date: Fri, 04 Jan 2013 09:42:26 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 7/8] zswap: add to mm/
References: <<1355262966-15281-1-git-send-email-sjenning@linux.vnet.ibm.com>> <<1355262966-15281-8-git-send-email-sjenning@linux.vnet.ibm.com>> <0e91c1e5-7a62-4b89-9473-09fff384a334@default> <50E32255.60901@linux.vnet.ibm.com> <26bb76b3-308e-404f-b2bf-3d19b28b393a@default> <50E4C1FA.4070701@linux.vnet.ibm.com> <640d712e-0217-456a-a2d1-d03dd7914a55@default>
In-Reply-To: <640d712e-0217-456a-a2d1-d03dd7914a55@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, Dave Hansen <dave@linux.vnet.ibm.com>

On 01/03/2013 04:33 PM, Dan Magenheimer wrote:
>> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
>>
>> However, once the flushing code was introduced and could free an entry
>> from the zswap_fs_store() path, it became necessary to add a per-entry
>> refcount to make sure that the entry isn't freed while another code
>> path was operating on it.
> 
> Hmmm... doesn't the refcount at least need to be an atomic_t?

An entry's refcount is only ever changed under the tree lock, so
making them atomic_t would be redundantly atomic.

I should add a comment to that effect though, including all elements
that are protected by the tree lock which include:
* the tree structure
* the lru list
* the per-entry refcounts

I'll put that change in the queue for v2.

> Also, how can you "free" any entry of an rbtree while another
> thread is walking the rbtree?  (Deleting an entry from an rbtree
> causes rebalancing... afaik there is no equivalent RCU
> implementation for rbtrees... not that RCU would necessarily
> work well for this anyway.)

This also can't happen since a thread must obtain the tree lock before
accessing or changing the tree.

Regarding RCU, I saw that some work had been done on RCU aware rbtree
functions but they weren't ready yet.

> BTW, in case it appears otherwise, I'm trying to be helpful, not
> critical.  In the end, I think we are in agreement that in-kernel
> compression is very important and that the frontswap (and/or
> cleancache) interface(s) are the right way to identify compressible
> data, and we are mostly arguing allocation and implementation details.

Yes. I'm always grateful for comments about the code :)  At the very
least, it rehashes the justifications for design decisions.

Thanks,
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
