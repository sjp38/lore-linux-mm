Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 55E506B0078
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 15:18:54 -0400 (EDT)
Date: Tue, 10 Sep 2013 15:18:26 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1378840706-f02wha3y-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20130910135129.GP22421@suse.de>
References: <1376025702-14818-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1376025702-14818-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20130910135129.GP22421@suse.de>
Subject: Re: [PATCH 1/9] migrate: make core migration code aware of hugepage
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Tue, Sep 10, 2013 at 02:51:30PM +0100, Mel Gorman wrote:
> On Fri, Aug 09, 2013 at 01:21:34AM -0400, Naoya Horiguchi wrote:
> > Before enabling each user of page migration to support hugepage,
> > this patch enables the list of pages for migration to link not only
> > LRU pages, but also hugepages. As a result, putback_movable_pages()
> > and migrate_pages() can handle both of LRU pages and hugepages.
> > 
> 
> LRU pages and *allocated* hugepages.

Right.

> On its own the patch looks ok but it's not obvious at this point what
> happens for pages that are on the hugetlbfs pool lists but not allocated
> by any process.

OK. I'll add comments about clarifying that. Now I'm preparing the next
patchset for migration of 1GB hugepages, so it's done in that series.

> They will fail to isolate because of the
> get_page_unless_zero() check. Maybe it's handled by a later patch.

The callers which determine the target pages with virtual address (like
mbind, migrate_pages) don't try to migrate hugepages in the hugetlbfs
pool. And the other callers which determine targets with physical address
(like memory hotplug and soft offline) have their own check not to migrate
free hugepages.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
