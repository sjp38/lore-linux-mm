Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E90AE6B004F
	for <linux-mm@kvack.org>; Tue, 26 May 2009 10:30:12 -0400 (EDT)
From: Nikanth Karthikesan <knikanth@suse.de>
Subject: Re: [PATCH] Fix build warning and avoid checking for mem != null twice
Date: Tue, 26 May 2009 20:02:00 +0530
References: <200905261844.33864.knikanth@suse.de> <20090526133050.GS4858@balbir.in.ibm.com>
In-Reply-To: <20090526133050.GS4858@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200905262002.00708.knikanth@suse.de>
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Tuesday 26 May 2009 19:00:50 Balbir Singh wrote:
> * Nikanth Karthikesan <knikanth@suse.de> [2009-05-26 18:44:32]:
> > Fix build warning, "mem_cgroup_is_obsolete defined but not used" when
> > CONFIG_DEBUG_VM is not set. Also avoid checking for !mem twice.
> >
> > Signed-off-by: Nikanth Karthikesan <knikanth@suse.de>
>
> I thought we fixed this, could you check the latest mmotm please!

I am unable to find this in mmotm. Also the !mem check can be avoided even in
the VM_BUG_ON as we check for it just before that. If it is not fixed already,
please take this else ignore.

Thanks
Nikanth

Fix build warning, "mem_cgroup_is_obsolete defined but not used" when
CONFIG_DEBUG_VM is not set. Also avoid checking for !mem again and again.

Signed-off-by: Nikanth Karthikesan <knikanth@suse.de>
Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>

---

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 01c2d8f..d253846 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -314,14 +314,6 @@ static struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
 	return mem;
 }
 
-static bool mem_cgroup_is_obsolete(struct mem_cgroup *mem)
-{
-	if (!mem)
-		return true;
-	return css_is_removed(&mem->css);
-}
-
-
 /*
  * Call callback function against all cgroup under hierarchy tree.
  */
@@ -932,7 +924,7 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 	if (unlikely(!mem))
 		return 0;
 
-	VM_BUG_ON(!mem || mem_cgroup_is_obsolete(mem));
+	VM_BUG_ON(css_is_removed(&mem->css));
 
 	while (1) {
 		int ret;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
