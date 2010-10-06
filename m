Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5C7B06B0071
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 09:32:51 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o96DX9MQ014804
	for <linux-mm@kvack.org>; Wed, 6 Oct 2010 09:33:09 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o96DWmCB097420
	for <linux-mm@kvack.org>; Wed, 6 Oct 2010 09:32:48 -0400
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o96DWlpw010634
	for <linux-mm@kvack.org>; Wed, 6 Oct 2010 07:32:47 -0600
Date: Wed, 6 Oct 2010 19:02:44 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 08/10] memcg: add cgroupfs interface to memcg dirty limits
Message-ID: <20101006133244.GF4195@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1286175485-30643-1-git-send-email-gthelen@google.com>
 <1286175485-30643-9-git-send-email-gthelen@google.com>
 <20101006133024.GE4195@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20101006133024.GE4195@balbir.in.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

* Balbir Singh <balbir@linux.vnet.ibm.com> [2010-10-06 19:00:24]:

> * Greg Thelen <gthelen@google.com> [2010-10-03 23:58:03]:
> 
> > Add cgroupfs interface to memcg dirty page limits:
> >   Direct write-out is controlled with:
> >   - memory.dirty_ratio
> >   - memory.dirty_bytes
> > 
> >   Background write-out is controlled with:
> >   - memory.dirty_background_ratio
> >   - memory.dirty_background_bytes
> > 
> > Signed-off-by: Andrea Righi <arighi@develer.com>
> > Signed-off-by: Greg Thelen <gthelen@google.com>
> > ---
> 
> The added interface is not uniform with the rest of our write
> operations. Does the patch below help? I did a quick compile and run
> test.

here is a version with my signed-off-by


Make writes to memcg dirty tunables more uniform

From: Balbir Singh <balbir@linux.vnet.ibm.com>

We today support 'M', 'm', 'k', 'K', 'g' and 'G' suffixes for
general memcg writes. This patch provides the same functionality
for dirty tunables.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 mm/memcontrol.c |   47 +++++++++++++++++++++++++++++++++++++----------
 1 files changed, 37 insertions(+), 10 deletions(-)


diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2d45a0a..116fecd 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4323,6 +4323,41 @@ static u64 mem_cgroup_dirty_read(struct cgroup *cgrp, struct cftype *cft)
 }
 
 static int
+mem_cgroup_dirty_write_string(struct cgroup *cgrp, struct cftype *cft,
+				const char *buffer)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
+	int type = cft->private;
+	int ret = -EINVAL;
+	unsigned long long val;
+
+	if (cgrp->parent == NULL)
+		return ret;
+
+	switch (type) {
+	case MEM_CGROUP_DIRTY_BYTES:
+		/* This function does all necessary parse...reuse it */
+		ret = res_counter_memparse_write_strategy(buffer, &val);
+		if (ret)
+			break;
+		memcg->dirty_param.dirty_bytes = val;
+		memcg->dirty_param.dirty_ratio  = 0;
+		break;
+	case MEM_CGROUP_DIRTY_BACKGROUND_BYTES:
+		ret = res_counter_memparse_write_strategy(buffer, &val);
+		if (ret)
+			break;
+		memcg->dirty_param.dirty_background_bytes = val;
+		memcg->dirty_param.dirty_background_ratio = 0;
+		break;
+	default:
+		BUG();
+		break;
+	}
+	return ret;
+}
+
+static int
 mem_cgroup_dirty_write(struct cgroup *cgrp, struct cftype *cft, u64 val)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
@@ -4338,18 +4373,10 @@ mem_cgroup_dirty_write(struct cgroup *cgrp, struct cftype *cft, u64 val)
 		memcg->dirty_param.dirty_ratio = val;
 		memcg->dirty_param.dirty_bytes = 0;
 		break;
-	case MEM_CGROUP_DIRTY_BYTES:
-		memcg->dirty_param.dirty_bytes = val;
-		memcg->dirty_param.dirty_ratio  = 0;
-		break;
 	case MEM_CGROUP_DIRTY_BACKGROUND_RATIO:
 		memcg->dirty_param.dirty_background_ratio = val;
 		memcg->dirty_param.dirty_background_bytes = 0;
 		break;
-	case MEM_CGROUP_DIRTY_BACKGROUND_BYTES:
-		memcg->dirty_param.dirty_background_bytes = val;
-		memcg->dirty_param.dirty_background_ratio = 0;
-		break;
 	default:
 		BUG();
 		break;
@@ -4429,7 +4456,7 @@ static struct cftype mem_cgroup_files[] = {
 	{
 		.name = "dirty_bytes",
 		.read_u64 = mem_cgroup_dirty_read,
-		.write_u64 = mem_cgroup_dirty_write,
+		.write_string = mem_cgroup_dirty_write_string,
 		.private = MEM_CGROUP_DIRTY_BYTES,
 	},
 	{
@@ -4441,7 +4468,7 @@ static struct cftype mem_cgroup_files[] = {
 	{
 		.name = "dirty_background_bytes",
 		.read_u64 = mem_cgroup_dirty_read,
-		.write_u64 = mem_cgroup_dirty_write,
+		.write_string = mem_cgroup_dirty_write_string,
 		.private = MEM_CGROUP_DIRTY_BACKGROUND_BYTES,
 	},
 };

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
