Message-ID: <442DE6AF.3060902@yahoo.com.au>
Date: Sat, 01 Apr 2006 12:34:23 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Avoid excessive time spend on concurrent slab shrinking
References: <Pine.LNX.4.64.0603311441400.8465@schroedinger.engr.sgi.com>	<20060331150120.21fad488.akpm@osdl.org>	<Pine.LNX.4.64.0603311507130.8617@schroedinger.engr.sgi.com>	<20060331153235.754deb0c.akpm@osdl.org>	<Pine.LNX.4.64.0603311541260.8948@schroedinger.engr.sgi.com>	<20060331160032.6e437226.akpm@osdl.org>	<Pine.LNX.4.64.0603311619590.9173@schroedinger.engr.sgi.com> <20060331172518.40a5b03d.akpm@osdl.org>
In-Reply-To: <20060331172518.40a5b03d.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, Nathan Scott <nathans@sgi.com>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

> c) go back to single-threading shrink_slab (or just shrink_icache_memory())
> 
>    For this one we'd need to understand which observations prompted Nick
>    to make shrinker_rwsem an rwsem?
> 

This was when I was looking for reasons why inode and dentry caches
would sometimes apparently explode on people and consume most of their
memory. One of the reasons was here, when slab caches did build up, and
multiple processes would start reclaim, scanning would skew away from
slab.

Considering the actual slab shrinkers are single threaded, I agree this
could cause more semaphore contention.

One thing we could do is ensure shrinker->nr gets incremented, but not
actually have more than one thread enter slab reclaim at once.

Or have the trylock&abort behaviour pushed down into the actual
shrinkers themselves, then at least we can get concurrent icache and
dcache scanning happening.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
