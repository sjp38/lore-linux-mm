Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 334916B0032
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 19:22:27 -0400 (EDT)
Date: Wed, 14 Aug 2013 16:22:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 00/20] mm, hugetlb: remove a
 hugetlb_instantiation_mutex
Message-Id: <20130814162225.5f1107bd44b11df41703b3d6@linux-foundation.org>
In-Reply-To: <1376040398-11212-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1376040398-11212-1-git-send-email-iamjoonsoo.kim@lge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>

On Fri,  9 Aug 2013 18:26:18 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:

> Without a hugetlb_instantiation_mutex, if parallel fault occur, we can
> fail to allocate a hugepage, because many threads dequeue a hugepage
> to handle a fault of same address. This makes reserved pool shortage
> just for a little while and this cause faulting thread to get a SIGBUS
> signal, although there are enough hugepages.
> 
> To solve this problem, we already have a nice solution, that is,
> a hugetlb_instantiation_mutex. This blocks other threads to dive into
> a fault handler. This solve the problem clearly, but it introduce
> performance degradation, because it serialize all fault handling.
>     
> Now, I try to remove a hugetlb_instantiation_mutex to get rid of
> performance problem reported by Davidlohr Bueso [1].
> 
> This patchset consist of 4 parts roughly.
> 
> Part 1. (1-6) Random fix and clean-up. Enhancing error handling.
> 	
> 	These can be merged into mainline separately.
> 
> Part 2. (7-9) Protect region tracking via it's own spinlock, instead of
> 	the hugetlb_instantiation_mutex.
> 	
> 	Breaking dependency on the hugetlb_instantiation_mutex for
> 	tracking a region is also needed by other approaches like as
> 	'table mutexes', so these can be merged into mainline separately.
> 
> Part 3. (10-13) Clean-up.
> 	
> 	IMO, these make code really simple, so these are worth to go into
> 	mainline separately, regardless success of my approach.
> 
> Part 4. (14-20) Remove a hugetlb_instantiation_mutex.
> 	
> 	Almost patches are just for clean-up to error handling path.
> 	In patch 19, retry approach is implemented that if faulted thread
> 	failed to allocate a hugepage, it continue to run a fault handler
> 	until there is no concurrent thread having a hugepage. This causes
> 	threads who want to get a last hugepage to be serialized, so
> 	threads don't get a SIGBUS if enough hugepage exist.
> 	In patch 20, remove a hugetlb_instantiation_mutex.

I grabbed the first six easy ones.  I'm getting a bit cross-eyed from
all the reviewing lately so I'll wait and see if someone else takes an
interest in the other patches, sorry.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
