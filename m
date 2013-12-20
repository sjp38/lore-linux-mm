Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 6558F6B0031
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 20:02:06 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id w10so1819583pde.6
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 17:02:06 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id j5si3845043pbs.181.2013.12.19.17.02.04
        for <linux-mm@kvack.org>;
        Thu, 19 Dec 2013 17:02:05 -0800 (PST)
Date: Thu, 19 Dec 2013 17:02:02 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 13/14] mm, hugetlb: retry if failed to allocate and
 there is concurrent user
Message-Id: <20131219170202.0df2d82a2adefa3ab616bdaa@linux-foundation.org>
In-Reply-To: <1387349640-8071-14-git-send-email-iamjoonsoo.kim@lge.com>
References: <1387349640-8071-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1387349640-8071-14-git-send-email-iamjoonsoo.kim@lge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>

On Wed, 18 Dec 2013 15:53:59 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:

> If parallel fault occur, we can fail to allocate a hugepage,
> because many threads dequeue a hugepage to handle a fault of same address.
> This makes reserved pool shortage just for a little while and this cause
> faulting thread who can get hugepages to get a SIGBUS signal.
> 
> To solve this problem, we already have a nice solution, that is,
> a hugetlb_instantiation_mutex. This blocks other threads to dive into
> a fault handler. This solve the problem clearly, but it introduce
> performance degradation, because it serialize all fault handling.
> 
> Now, I try to remove a hugetlb_instantiation_mutex to get rid of
> performance degradation.

So the whole point of the patch is to improve performance, but the
changelog doesn't include any performance measurements!

Please, run some quantitative tests and include a nice summary of the
results in the changelog.

This is terribly important, because if the performance benefit is
infinitesimally small or negative, the patch goes into the bit bucket ;)

> For achieving it, at first, we should ensure that
> no one get a SIGBUS if there are enough hugepages.
> 
> For this purpose, if we fail to allocate a new hugepage when there is
> concurrent user, we return just 0, instead of VM_FAULT_SIGBUS. With this,
> these threads defer to get a SIGBUS signal until there is no
> concurrent user, and so, we can ensure that no one get a SIGBUS if there
> are enough hugepages.

So if I'm understanding this correctly...  if N threads all generate a
fault against the same address, they will all dive in and allocate a
hugepage, will then do an enormous memcpy into that page and will then
attempt to instantiate the page in pagetables.  All threads except one
will lose the race and will free the page again!  This sounds terribly
inefficient; it would be useful to write a microbenchmark which
triggers this scenario so we can explore the impact.

I'm wondering if a better solution to all of this would be to make
hugetlb_instantiation_mutex an array of, say, 1024 mutexes and index it
with a hash of the faulting address.  That will 99.9% solve the
performance issue which you believe exists without introducing this new
performance issue?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
