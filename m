Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 870B76B0031
	for <linux-mm@kvack.org>; Wed, 11 Sep 2013 20:20:26 -0400 (EDT)
Message-ID: <523108B7.7050101@sr71.net>
Date: Wed, 11 Sep 2013 17:20:07 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] mm: percpu pages: up batch size to fix arithmetic??
 errror
References: <20130911220859.EB8204BB@viggo.jf.intel.com> <5230F7DD.90905@linux.vnet.ibm.com> <5230FB0A.70901@linux.vnet.ibm.com>
In-Reply-To: <5230FB0A.70901@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux.com

BTW, in my little test, the median ->count was 10, and the mean was 45.

On 09/11/2013 04:21 PM, Cody P Schafer wrote:
> Also, we may want to consider shrinking pcp->high down from 6*pcp->batch
> given that the original "6*" choice was based upon ->batch actually
> being 1/4th of the average pageset size, where now it appears closer to
> being the average.

One other thing: we actually had a hot _and_ a cold pageset at that
point, and we now share one pageset for hot and cold pages.  After
looking at it for a bit today, I'm not sure how much the history
matters.  We probably need to take a fresh look at what we want.

Anybody disagree with this?

1. We want ->batch to be large enough that if all the CPUs in a zone
   are doing allocations constantly, there is very little contention on
   the zone_lock.
2. If ->high gets too large, we'll end up keeping too much memory in
   the pcp and __alloc_pages_direct_reclaim() will end up calling the
   (expensive drain_all_pages() too often).
3. We want ->high to approximate the size of the cache which is
   private to a given cpu.  But, that's complicated by the L3 caches
   and hyperthreading today.
4. ->high can be a _bit_ larger than the CPU cache without it being a
   real problem since not _all_ the pages being freed will be fully
   resident in the cache.  Some will be cold, some will only have a few
   of their cachelines resident.
5. A 0.75MB ->high seems a bit low for CPUs with 30MB of L3 cache on
   the socket (although 20 threads share that).

I'll take one of my big systems and run it with some various ->high
settings and see if it makes any difference.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
