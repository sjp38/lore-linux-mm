Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j4HNTImD034898
	for <linux-mm@kvack.org>; Tue, 17 May 2005 19:29:18 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4HNTInP188398
	for <linux-mm@kvack.org>; Tue, 17 May 2005 17:29:18 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j4HNTHqp006607
	for <linux-mm@kvack.org>; Tue, 17 May 2005 17:29:18 -0600
Message-ID: <428A7E48.6060909@us.ibm.com>
Date: Tue, 17 May 2005 16:29:12 -0700
From: Matthew Dobson <colpatch@us.ibm.com>
MIME-Version: 1.0
Subject: Re: NUMA aware slab allocator V2
References: <Pine.LNX.4.58.0505110816020.22655@schroedinger.engr.sgi.com>	<20050512000444.641f44a9.akpm@osdl.org>	<Pine.LNX.4.58.0505121252390.32276@schroedinger.engr.sgi.com> <20050513000648.7d341710.akpm@osdl.org>
In-Reply-To: <20050513000648.7d341710.akpm@osdl.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Lameter <clameter@engr.sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, shai@scalex86.org
List-ID: <linux-mm.kvack.org>

Excuse for the week-late response...

Andrew Morton wrote:
> Christoph Lameter <clameter@engr.sgi.com> wrote:
> 
>> Could we boot the box without quiet so that we can get better debug
>> messages?
> 
> 
> It didn't produce anything interesting.  For some reason the console output
> stops when start_kernel() runs console_init() (I guess it all comes out
> later) so the machine is running blind when we run kmem_cache_init(). 
> Irritating.  I just moved the console_init() call to happen later on.
> 
> It's going BUG() in kmem_cache_init()->set_up_list3s->is_node_online
> because for some reason the !CONFIG_NUMA ppc build has MAX_NUMNODES=16,
> even though there's only one node.
> 
> Doing
> 
> #define is_node_online(node) node_online(node)

As Dave Hansen mentioned elsewhere in this thread, there is no need to
define this is_node_online() macro, as node_online() does EXACTLY the same
thing (minus the BUG() which is probably overkill).


> unconditionally fixes that up (your patch shuld be using
> for_each_online_node() everywhere?) but it oopses later - I think it's the
> first time kmem_cache_alloc() is called.

Christoph should replace all the for (i = 0; i < MAX_NUMNODES; i++) loops
with for_each_node(i) and the one loop that does this:
for (i = 0; i < MAX_NUMNODES; i++) {
	if (!node_online(i))
		continue;
(or something similar) with for_each_online_node(i)

Also, there is a similar loop for CPUs which should be replaced with
for_each_online_cpu(i).

These for_each_FOO macros are cleaner and less likely to break in the
future, since we can simply modify the one definition if the way to
itterate over nodes/cpus changes, rather than auditing 100 open coded
implementations and trying to determine the intent of the loop's author.

-Matt
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
