Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9RMWmiw031673
	for <linux-mm@kvack.org>; Thu, 27 Oct 2005 18:32:48 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9RMXmG1505020
	for <linux-mm@kvack.org>; Thu, 27 Oct 2005 16:33:48 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j9RMWlrX019168
	for <linux-mm@kvack.org>; Thu, 27 Oct 2005 16:32:48 -0600
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20051027135058.2f72e706.akpm@osdl.org>
References: <1130366995.23729.38.camel@localhost.localdomain>
	 <200510271038.52277.ak@suse.de> <20051027131725.GI5091@opteron.random>
	 <1130425212.23729.55.camel@localhost.localdomain>
	 <20051027151123.GO5091@opteron.random>
	 <20051027112054.10e945ae.akpm@osdl.org>
	 <20051027200434.GT5091@opteron.random>
	 <20051027135058.2f72e706.akpm@osdl.org>
Content-Type: text/plain
Date: Thu, 27 Oct 2005 15:32:17 -0700
Message-Id: <1130452337.23729.125.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Andrea Arcangeli <andrea@suse.de>, ak@suse.de, hugh@veritas.com, jdike@addtoit.com, dvhltc@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2005-10-27 at 13:50 -0700, Andrew Morton wrote:

> I think we need to restart this discussion.  Can we please have a
> *detailed* description of the problem?

Andrew,

Sorry for replying late, I am just relaxing and watching fun :)

Here are the reasons I believe our database folks wants this.
(I am not a database person, if you need more info I can go back
and ask them).

1) In most customer environments, they run multiple instances
of DB2 in the system (single OS) to serve different databases.
At the time of starting these instances, they size their buffers,
shared memory segments etc and hope to run with it. Depending
on the load & access patterns on different databases - they 
would like to grow and shrink their buffers. 

Currently, they are using /proc/meminfo to notice the memory
usages (and pressure - they want a better way and discussion
for another topic) and they want to release part of their
shared memory segments (drop them to floor and free up the
swap entires - since they already did whatever they need to
do with those).

So, I proposed madvise(DISCARD) functionality AND I care
about ONLY shared memory segments. (I don't remember they 
wanting this for mmap(), could be wrong - but I am definite
about file-backed mmap()s).

2) In virtualized environments, they want to react "nicely"
to changes in the memory configuration - by releasing the
portions of segments they don't need. (Its not a hotplug
remove - where hotplug is trying to free up a particular
memory region). They would like to size their resources
depending on memory add/remove events.

Does this help ?

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
