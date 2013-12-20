Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id F38E66B0031
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 21:31:26 -0500 (EST)
Received: by mail-ie0-f181.google.com with SMTP id e14so2471413iej.12
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 18:31:26 -0800 (PST)
Received: from g4t0017.houston.hp.com (g4t0017.houston.hp.com. [15.201.24.20])
        by mx.google.com with ESMTPS id 9si6007264icd.67.2013.12.19.18.31.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 19 Dec 2013 18:31:25 -0800 (PST)
Message-ID: <1387506681.8363.55.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH v3 13/14] mm, hugetlb: retry if failed to allocate and
 there is concurrent user
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Thu, 19 Dec 2013 18:31:21 -0800
In-Reply-To: <20131219170202.0df2d82a2adefa3ab616bdaa@linux-foundation.org>
References: <1387349640-8071-1-git-send-email-iamjoonsoo.kim@lge.com>
	 <1387349640-8071-14-git-send-email-iamjoonsoo.kim@lge.com>
	 <20131219170202.0df2d82a2adefa3ab616bdaa@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar
 K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>

On Thu, 2013-12-19 at 17:02 -0800, Andrew Morton wrote:
> On Wed, 18 Dec 2013 15:53:59 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> 
> > If parallel fault occur, we can fail to allocate a hugepage,
> > because many threads dequeue a hugepage to handle a fault of same address.
> > This makes reserved pool shortage just for a little while and this cause
> > faulting thread who can get hugepages to get a SIGBUS signal.
> > 
> > To solve this problem, we already have a nice solution, that is,
> > a hugetlb_instantiation_mutex. This blocks other threads to dive into
> > a fault handler. This solve the problem clearly, but it introduce
> > performance degradation, because it serialize all fault handling.
> > 
> > Now, I try to remove a hugetlb_instantiation_mutex to get rid of
> > performance degradation.
> 
> So the whole point of the patch is to improve performance, but the
> changelog doesn't include any performance measurements!
> 
> Please, run some quantitative tests and include a nice summary of the
> results in the changelog.

I was actually spending this afternoon testing these patches with Oracle
(I haven't seen any issues so far) and unless Joonsoo already did so, I
want to run these by the libhugetlb test cases - I got side tracked by
futexes though :/

Please do consider that performance wise I haven't seen much in
particular. The thing is, I started dealing with this mutex once I
noticed it as the #1 hot lock in Oracle DB starts, but then once the
faults are done, it really goes away. So I wouldn't say that the mutex
is a bottleneck except for the first few minutes.

> 
> This is terribly important, because if the performance benefit is
> infinitesimally small or negative, the patch goes into the bit bucket ;)

Well, this mutex is infinitesimally ugly and needs to die (as long as
performance isn't hurt).

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
