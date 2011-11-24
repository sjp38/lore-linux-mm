Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C64D46B0096
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 04:06:50 -0500 (EST)
Date: Thu, 24 Nov 2011 10:06:39 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 6/8] mm: memcg: remove unneeded checks from
 uncharge_page()
Message-ID: <20111124090639.GD6843@cmpxchg.org>
References: <1322062951-1756-1-git-send-email-hannes@cmpxchg.org>
 <1322062951-1756-7-git-send-email-hannes@cmpxchg.org>
 <20111124090619.895988e7.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111124090619.895988e7.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Nov 24, 2011 at 09:06:19AM +0900, KAMEZAWA Hiroyuki wrote:
> On Wed, 23 Nov 2011 16:42:29 +0100
> Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > From: Johannes Weiner <jweiner@redhat.com>
> > 
> > mem_cgroup_uncharge_page() is only called on either freshly allocated
> > pages without page->mapping or on rmapped PageAnon() pages.  There is
> > no need to check for a page->mapping that is not an anon_vma.
> > 
> > Signed-off-by: Johannes Weiner <jweiner@redhat.com>
> 
> For making our assumption clearer to readers of codes,
> VM_BUG_ON(page->mapping && !PageAnon(page)) please.

Yep, delta patch below.

> Anyway,
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Thanks!

---
From: Johannes Weiner <jweiner@redhat.com>
Subject: mm: memcg: remove unneeded checks from uncharge_page() fix

Document page state assumptions and catch if they are violated in
uncharge_page().

Signed-off-by: Johannes Weiner <jweiner@redhat.com>
---
 mm/memcontrol.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2f1fdc4..872dae1 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2992,6 +2992,7 @@ void mem_cgroup_uncharge_page(struct page *page)
 	/* early check. */
 	if (page_mapped(page))
 		return;
+	VM_BUG_ON(page->mapping && !PageAnon(page));
 	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_MAPPED);
 }
 
-- 
1.7.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
