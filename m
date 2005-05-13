Date: Fri, 13 May 2005 00:06:48 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: NUMA aware slab allocator V2
Message-Id: <20050513000648.7d341710.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.58.0505121252390.32276@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.58.0505110816020.22655@schroedinger.engr.sgi.com>
	<20050512000444.641f44a9.akpm@osdl.org>
	<Pine.LNX.4.58.0505121252390.32276@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, shai@scalex86.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@engr.sgi.com> wrote:
>
>  Could we boot the box without quiet so that we can get better debug
>  messages?

It didn't produce anything interesting.  For some reason the console output
stops when start_kernel() runs console_init() (I guess it all comes out
later) so the machine is running blind when we run kmem_cache_init(). 
Irritating.  I just moved the console_init() call to happen later on.

It's going BUG() in kmem_cache_init()->set_up_list3s->is_node_online
because for some reason the !CONFIG_NUMA ppc build has MAX_NUMNODES=16,
even though there's only one node.

Doing

#define is_node_online(node) node_online(node)

unconditionally fixes that up (your patch shuld be using
for_each_online_node() everywhere?) but it oopses later - I think it's the
first time kmem_cache_alloc() is called.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
