Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id CFE4F900086
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 17:56:01 -0400 (EDT)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id p3ELtwMR000969
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 14:55:58 -0700
Received: from iye19 (iye19.prod.google.com [10.241.50.19])
	by kpbe19.cbf.corp.google.com with ESMTP id p3ELtgP8003501
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 14:55:56 -0700
Received: by iye19 with SMTP id 19so1815612iye.3
        for <linux-mm@kvack.org>; Thu, 14 Apr 2011 14:55:56 -0700 (PDT)
Date: Thu, 14 Apr 2011 14:55:50 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/3] make new alloc_pages_exact()
In-Reply-To: <20110414200140.CDE09A20@kernel>
Message-ID: <alpine.DEB.2.00.1104141455390.13286@chino.kir.corp.google.com>
References: <20110414200139.ABD98551@kernel> <20110414200140.CDE09A20@kernel>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Timur Tabi <timur@freescale.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>

On Thu, 14 Apr 2011, Dave Hansen wrote:

> 
> What I really wanted in the end was a highmem-capable
> alloc_pages_exact(), so here it is.  This function can be used to
> allocate unmapped (like highmem) non-power-of-two-sized areas of
> memory.  This is in constast to get_free_pages_exact() which can only
> allocate from lowmem.
> 
> My plan is to use this in the virtio_balloon driver to allocate large,
> oddly-sized contiguous areas.
> 
> The new __alloc_pages_exact() now takes a size in numbers of pages,
> and returns a 'struct page', which means it can now address
> highmem.  The (new) argument order mirrors alloc_pages() itself.
> 
> It's a bit unfortunate that this introduces __free_pages_exact()
> alongside free_pages_exact().  But that mess already exists with
> __free_pages() vs. free_pages_exact().  So, at worst, this mirrors the
> mess that we already have.
> 
> I'm also a bit worried that I've not put in something named
> alloc_pages_exact(), but that behaves differently than it did before
> this set.  I got all of the in-tree cases, but I'm a bit worried about
> stragglers elsewhere.  So, I'm calling this __alloc_pages_exact() for
> the moment.  We can take out the __ some day if it bothers people.
> 
> Note that the __get_free_pages() has a !GFP_HIGHMEM check.  Now that
> we are using alloc_pages_exact() instead of __get_free_pages() for
> get_free_pages_exact(), we had to add a new check in
> get_free_pages_exact().
> 
> This has been compile and boot tested, and I checked that
> 
> 	echo 2 > /sys/kernel/profiling
> 
> still works, since it uses get_free_pages_exact().
> 
> Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
