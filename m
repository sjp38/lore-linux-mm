Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 0A95D6B005A
	for <linux-mm@kvack.org>; Mon, 17 Sep 2012 19:22:49 -0400 (EDT)
Date: Mon, 17 Sep 2012 16:22:48 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: blk, mm: lockdep irq lock inversion in linux-next
Message-Id: <20120917162248.d998afe3.akpm@linux-foundation.org>
In-Reply-To: <5054878F.1030908@gmail.com>
References: <5054878F.1030908@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: axboe@kernel.dk, Tejun Heo <tj@kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>

On Sat, 15 Sep 2012 15:50:07 +0200
Sasha Levin <levinsasha928@gmail.com> wrote:

> Hi all,
> 
> While fuzzing with trinity within a KVM tools guest on a linux-next kernel, I
> got the lockdep warning at the bottom of this mail.
> 
> I've tried figuring out where it was introduced, but haven't found any sign that
> any of the code in that area changed recently, so I'm probably missing something...
> 
> 
> [ 157.966399] =========================================================
> [ 157.968523] [ INFO: possible irq lock inversion dependency detected ]
> [ 157.970029] 3.6.0-rc5-next-20120914-sasha-00001-g802bf6c-dirty #340 Tainted: G W
> [ 157.970029] ---------------------------------------------------------
> [ 157.970029] trinity-child38/6642 just changed the state of lock:
> [ 157.970029] (&(&mapping->tree_lock)->rlock){+.+...}, at: [<ffffffff8120cafc>]
> invalidate_inode_pages2_range+0x20c/0x3c0
> [ 157.970029] but this lock was taken by another, SOFTIRQ-safe lock in the past:
> [ 157.970029] (&(&new->queue_lock)->rlock){..-...}
> 
> [snippage]

gack, what a mess.  Thanks for the report.  AFAICT, what has happened is:

invalidate_complete_page2()
->spin_lock_irq(&mapping->tree_lock)
->clear_page_mlock()
  __clear_page_mlock()
  ->isolate_lru_page()
    ->spin_lock_irq(&zone->lru_lock)
    ->spin_unlock_irq(&zone->lru_lock)

whoops.  isolate_lru_page() just enabled local interrupts while we're
holding ->tree_lock, which is supposed to be an irq-save lock.  And in
a rather obscure way, lockdep caught it.

Problem is, I cannot find any recent change which might have triggered
this.

I don't know how repeatable this is for you (not very at all, I
suspect).  This?


From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm: isolate_lru_page(): don't enable local interrupts

isolate_lru_page() is called with local interrupts disabled, via

invalidate_complete_page2()
->spin_lock_irq(&mapping->tree_lock)
->clear_page_mlock()
  __clear_page_mlock()
  ->isolate_lru_page()

so it should not unconditionally enable local interrupts.

Sasha hit a lockdep warning when running Trinity as a result of this.

Reported-by: Sasha Levin <levinsasha928@gmail.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/vmscan.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff -puN mm/vmscan.c~mm-isolate_lru_page-dont-enable-local-interrupts mm/vmscan.c
--- a/mm/vmscan.c~mm-isolate_lru_page-dont-enable-local-interrupts
+++ a/mm/vmscan.c
@@ -1161,8 +1161,9 @@ int isolate_lru_page(struct page *page)
 	if (PageLRU(page)) {
 		struct zone *zone = page_zone(page);
 		struct lruvec *lruvec;
+		unsigned long flags;
 
-		spin_lock_irq(&zone->lru_lock);
+		spin_lock_irqsave(&zone->lru_lock, flags);
 		lruvec = mem_cgroup_page_lruvec(page, zone);
 		if (PageLRU(page)) {
 			int lru = page_lru(page);
@@ -1171,7 +1172,7 @@ int isolate_lru_page(struct page *page)
 			del_page_from_lru_list(page, lruvec, lru);
 			ret = 0;
 		}
-		spin_unlock_irq(&zone->lru_lock);
+		spin_unlock_irqrestore(&zone->lru_lock, flags);
 	}
 	return ret;
 }
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
