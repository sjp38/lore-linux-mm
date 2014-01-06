Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 3B9236B0031
	for <linux-mm@kvack.org>; Sun,  5 Jan 2014 19:12:32 -0500 (EST)
Received: by mail-pb0-f42.google.com with SMTP id uo5so17945021pbc.1
        for <linux-mm@kvack.org>; Sun, 05 Jan 2014 16:12:31 -0800 (PST)
Received: from LGEMRELSE6Q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id ll1si34697635pab.318.2014.01.05.16.12.29
        for <linux-mm@kvack.org>;
        Sun, 05 Jan 2014 16:12:30 -0800 (PST)
Date: Mon, 6 Jan 2014 09:12:37 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3 03/14] mm, hugetlb: protect region tracking via newly
 introduced resv_map lock
Message-ID: <20140106001237.GA696@lge.com>
References: <1387349640-8071-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1387349640-8071-4-git-send-email-iamjoonsoo.kim@lge.com>
 <20131221135819.GB12407@voom.fritz.box>
 <20131223010517.GB19388@lge.com>
 <20131224120012.GH12407@voom.fritz.box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131224120012.GH12407@voom.fritz.box>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Gibson <david@gibson.dropbear.id.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>

On Tue, Dec 24, 2013 at 11:00:12PM +1100, David Gibson wrote:
> On Mon, Dec 23, 2013 at 10:05:17AM +0900, Joonsoo Kim wrote:
> > On Sun, Dec 22, 2013 at 12:58:19AM +1100, David Gibson wrote:
> > > On Wed, Dec 18, 2013 at 03:53:49PM +0900, Joonsoo Kim wrote:
> > > > There is a race condition if we map a same file on different processes.
> > > > Region tracking is protected by mmap_sem and hugetlb_instantiation_mutex.
> > > > When we do mmap, we don't grab a hugetlb_instantiation_mutex, but,
> > > > grab a mmap_sem. This doesn't prevent other process to modify region
> > > > structure, so it can be modified by two processes concurrently.
> > > > 
> > > > To solve this, I introduce a lock to resv_map and make region manipulation
> > > > function grab a lock before they do actual work. This makes region
> > > > tracking safe.
> > > 
> > > It's not clear to me if you're saying there is a list corruption race
> > > bug in the existing code, or only that there will be if the
> > > instantiation mutex goes away.
> > 
> > Hello,
> > 
> > The race exists in current code.
> > Currently, region tracking is protected by either down_write(&mm->mmap_sem) or
> > down_read(&mm->mmap_sem) + instantiation mutex. But if we map this hugetlbfs
> > file to two different processes, holding a mmap_sem doesn't have any impact on
> > the other process and concurrent access to data structure is possible.
> 
> Ouch.  In that case:
> 
> Acked-by: David Gibson <david@gibson.dropbear.id.au>
> 
> It would be really nice to add a testcase for this race to the
> libhugetlbfs testsuite.

Okay!
I will add it.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
