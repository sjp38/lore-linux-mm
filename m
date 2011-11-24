Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 400A46B0096
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 04:04:19 -0500 (EST)
Date: Thu, 24 Nov 2011 10:04:09 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 5/8] mm: memcg: remove unneeded checks from
 newpage_charge()
Message-ID: <20111124090409.GC6843@cmpxchg.org>
References: <1322062951-1756-1-git-send-email-hannes@cmpxchg.org>
 <1322062951-1756-6-git-send-email-hannes@cmpxchg.org>
 <20111124090443.d3f720c5.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111124090443.d3f720c5.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Nov 24, 2011 at 09:04:43AM +0900, KAMEZAWA Hiroyuki wrote:
> On Wed, 23 Nov 2011 16:42:28 +0100
> Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > From: Johannes Weiner <jweiner@redhat.com>
> > 
> > All callsites pass in freshly allocated pages and a valid mm.  As a
> > result, all checks pertaining the page's mapcount, page->mapping or
> > the fallback to init_mm are unneeded.
> > 
> > Signed-off-by: Johannes Weiner <jweiner@redhat.com>
> 
> Hmm, it's true now. But for making clear our assumption to all readers of code,
> 
> could you add
> VM_BUG_ON(!mm || page_mapped(page) || (page->mapping && !PageAnon(page)) ?

Of course.  Please find the delta patch below.  I broke them up into
three separate checks to make the problem easier to find if the BUG
triggers.

> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Thank you.

---
From: Johannes Weiner <jweiner@redhat.com>
Subject: mm: memcg: remove unneeded checks from newpage_charge() fix

Document page state assumptions and catch if they are violated in
newpage_charge().

Signed-off-by: Johannes Weiner <jweiner@redhat.com>
---
 mm/memcontrol.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 0d10be4..f338018 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2679,6 +2679,9 @@ int mem_cgroup_newpage_charge(struct page *page,
 {
 	if (mem_cgroup_disabled())
 		return 0;
+	VM_BUG_ON(page_mapped(page));
+	VM_BUG_ON(page->mapping && !PageAnon(page));
+	VM_BUG_ON(!mm);
 	return mem_cgroup_charge_common(page, mm, gfp_mask,
 					MEM_CGROUP_CHARGE_TYPE_MAPPED);
 }
-- 
1.7.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
