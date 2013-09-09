Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 83B116B0031
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 04:22:42 -0400 (EDT)
Date: Mon, 9 Sep 2013 17:22:55 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3 06/20] mm, hugetlb: return a reserved page to a
 reserved pool if failed
Message-ID: <20130909082255.GD22390@lge.com>
References: <520c10eb.SqhfxPtrRlcvUrQR%akpm@linux-foundation.org>
 <1378444996-3426-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1378444996-3426-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>

On Fri, Sep 06, 2013 at 02:23:16PM +0900, Joonsoo Kim wrote:
> If we fail with a reserved page, just calling put_page() is not sufficient,
> because put_page() invoke free_huge_page() at last step and it doesn't
> know whether a page comes from a reserved pool or not. So it doesn't do
> anything related to reserved count. This makes reserve count lower
> than how we need, because reserve count already decrease in
> dequeue_huge_page_vma(). This patch fix this situation.
> 
> In this patch, PagePrivate() is used for tracking reservation.
> When resereved pages are dequeued from reserved pool, Private flag is
> assigned to the hugepage until properly mapped. On page returning process,
> if there is a hugepage with Private flag, it is considered as the one
> returned in certain error path, so that we should restore one
> reserve count back in order to preserve certain user's reserved hugepage.
> 
> Using Private flag is safe for the hugepage, because it doesn't use the
> LRU mechanism so that there is no other user of this page except us.
> Therefore we can use this flag safely.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
> Replenishing commit message only.

Hello, Andrew.

One fix is needed, so here are v4.
What I fix is mentioned in commit message.

----------------->8--------------------
