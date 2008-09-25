From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 3/12] memcg make root cgroup unlimited.
Date: Thu, 25 Sep 2008 15:15:43 +0900
Message-ID: <20080925151543.ba307898.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080925151124.25898d22.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755339AbYIYGLI@vger.kernel.org>
In-Reply-To: <20080925151124.25898d22.kamezawa.hiroyu@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <haveblue@us.ibm.com>, ryov@valinux.co.jp
List-Id: linux-mm.kvack.org

Make root cgroup of memory resource controller to have no limit.

By this, users cannot set limit to root group. This is for making root cgroup
as a kind of trash-can.

For accounting pages which has no owner, which are created by force_empty,
we need some cgroup with no_limit. A patch for rewriting force_empty will
will follow this one.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 Documentation/controllers/memory.txt |    4 ++++
 mm/memcontrol.c                      |    7 +++++++
 2 files changed, 11 insertions(+)

Index: mmotm-2.6.27-rc7+/mm/memcontrol.c
===================================================================
--- mmotm-2.6.27-rc7+.orig/mm/memcontrol.c
+++ mmotm-2.6.27-rc7+/mm/memcontrol.c
@@ -136,6 +136,9 @@ struct mem_cgroup {
 };
 static struct mem_cgroup init_mem_cgroup;
 
+#define is_root_cgroup(cgrp)	((cgrp) == &init_mem_cgroup)
+
+
 /*
  * We use the lower bit of the page->page_cgroup pointer as a bit spin
  * lock.  We need to ensure that page->page_cgroup is at least two
@@ -945,6 +948,10 @@ static int mem_cgroup_write(struct cgrou
 
 	switch (cft->private) {
 	case RES_LIMIT:
+		if (is_root_cgroup(memcg)) {
+			ret = -EINVAL;
+			break;
+		}
 		/* This function does all necessary parse...reuse it */
 		ret = res_counter_memparse_write_strategy(buffer, &val);
 		if (!ret)
Index: mmotm-2.6.27-rc7+/Documentation/controllers/memory.txt
===================================================================
--- mmotm-2.6.27-rc7+.orig/Documentation/controllers/memory.txt
+++ mmotm-2.6.27-rc7+/Documentation/controllers/memory.txt
@@ -121,6 +121,9 @@ The corresponding routines that remove a
 a page from Page Cache is used to decrement the accounting counters of the
 cgroup.
 
+The root cgroup is not allowed to be set limit but usage is accounted.
+For controlling usage of memory, you need to create a cgroup.
+
 2.3 Shared Page Accounting
 
 Shared pages are accounted on the basis of the first touch approach. The
@@ -172,6 +175,7 @@ We can alter the memory limit:
 
 NOTE: We can use a suffix (k, K, m, M, g or G) to indicate values in kilo,
 mega or gigabytes.
+Note: root cgroup is not able to be set limit.
 
 # cat /cgroups/0/memory.limit_in_bytes
 4194304
