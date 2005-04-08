Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e34.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j381Om5b056456
	for <linux-mm@kvack.org>; Thu, 7 Apr 2005 21:24:48 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay05.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j381OlNh185816
	for <linux-mm@kvack.org>; Thu, 7 Apr 2005 19:24:47 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j381Olbh002259
	for <linux-mm@kvack.org>; Thu, 7 Apr 2005 19:24:47 -0600
Subject: Re: Excessive memory trapped in pageset lists
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050407211101.GA29069@sgi.com>
References: <20050407211101.GA29069@sgi.com>
Content-Type: text/plain
Date: Thu, 07 Apr 2005 18:24:41 -0700
Message-Id: <1112923481.21749.88.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: linux-mm <linux-mm@kvack.org>, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, 2005-04-07 at 16:11 -0500, Jack Steiner wrote:
>    28 pages/node/cpu * 512 cpus * 256nodes * 16384 bytes/page = 60GB  (Yikes!!!)
...
> I have a couple of ideas for fixing this but it looks like Christoph is
> actively making changes in this area. Christoph do you want to address
> this issue or should I wait for your patch to stabilize?

What about only keeping the page lists populated for cpus which can
locally allocate from the zone?

	cpu_to_node(cpu) == page_nid(pfn_to_page(zone->zone_start_pfn)) 

There certainly aren't a lot of cases where frequent, persistent
single-page allocations are occurring off-node, unless a node is empty.
If you go to an off-node 'struct zone', you're probably bouncing so many
cachelines that you don't get any benefit from per-cpu-pages anyway.

Maybe there could be a per-cpu-pages miss rate that's required to occur
before the lists are even populated.  That would probably account better
for cases where nodes are disproportionately populated with memory.
This, along with the occasional flushing of the pages back into the
general allocator if the miss rate isn't satisfied should give some good
self-tuning behavior.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
