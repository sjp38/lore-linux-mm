Received: from flecktone.americas.sgi.com (flecktone.americas.sgi.com [198.149.16.15])
	by omx1.americas.sgi.com (8.12.10/8.12.9/linux-outbound_gateway-1.1) with ESMTP id j37LB2xT010188
	for <linux-mm@kvack.org>; Thu, 7 Apr 2005 16:11:02 -0500
Date: Thu, 7 Apr 2005 16:11:01 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: Excessive memory trapped in pageset lists
Message-ID: <20050407211101.GA29069@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: clameter@sgi.com
List-ID: <linux-mm.kvack.org>

The zone structure has 2 lists in the per_cpu_pageset structure. 
These lists are used for quickly allocating & freeing pages:

        struct zone {
                ...
                struct per_cpu_pageset  pageset[NR_CPUS];
        }

        struct per_cpu_pageset {
                ...
                struct per_cpu_pages pcp[2];
        }

	struct per_cpu_pages {
		...
		struct list_head list;	// list head for free pages
	}

Since the lists are private to a cpu, no global locks are required to
allocate or free pages.  This is likely a performance win for many benchmarks.

However, memory in the lists is trapped, ie. not easily available
for allocation by any cpu except the owner of the list. In addition,
there is no "shaker" for this memory.


So how much memory can be in the lists.... Lots!

There is 1 zone per node (on SN). Each zone has 2 lists per cpu.
One list is for "hot" pages, the other is for "cold" pages.

On a big SN system there are 512p and 256 nodes:

        512cpus * 256zones * 2 lists/percpu/perzone = 256K lists

On any system with more than 256MB/node (ie, all SN systems), the hot list
will contain 4 to 24 pages.. The cold list will contain 0 - 4 pages.
Assuming worst case, on a 512p system with 256k lists, there can be
a lot of memory trapped in these lists.

   28 pages/node/cpu * 512 cpus * 256nodes * 16384 bytes/page = 60GB  (Yikes!!!)

In practice, there will be a lot less memory in the lists, but even a
lot less is still way too much.


I have a couple of ideas for fixing this but it looks like Christoph is
actively making changes in this area. Christoph do you want to address
this issue or should I wait for your patch to stabilize?

-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
