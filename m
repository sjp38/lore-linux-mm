Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id E4A406B0038
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 11:37:07 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id y10so1527081pdj.40
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 08:37:07 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id xr5si10706963pab.221.2014.10.27.08.37.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Oct 2014 08:37:06 -0700 (PDT)
Date: Mon, 27 Oct 2014 18:36:54 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH RESEND 2/4] cpuset: simplify cpuset_node_allowed API
Message-ID: <20141027153654.GF17258@esperanza>
References: <cover.1413804554.git.vdavydov@parallels.com>
 <c52e3c30a61d29da40b69b602c41c2d91868c3ae.1413804554.git.vdavydov@parallels.com>
 <20141027151806.GR4436@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20141027151806.GR4436@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Dan Carpenter <dan.carpenter@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Zefan Li <lizefan@huawei.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Tejun,

On Mon, Oct 27, 2014 at 11:18:06AM -0400, Tejun Heo wrote:
> On Mon, Oct 20, 2014 at 03:50:30PM +0400, Vladimir Davydov wrote:
> > Current cpuset API for checking if a zone/node is allowed to allocate
> > from looks rather awkward. We have hardwall and softwall versions of
> > cpuset_node_allowed with the softwall version doing literally the same
> > as the hardwall version if __GFP_HARDWALL is passed to it in gfp flags.
> > If it isn't, the softwall version may check the given node against the
> > enclosing hardwall cpuset, which it needs to take the callback lock to
> > do.
> > 
> > Such a distinction was introduced by commit 02a0e53d8227 ("cpuset:
> > rework cpuset_zone_allowed api"). Before, we had the only version with
> > the __GFP_HARDWALL flag determining its behavior. The purpose of the
> > commit was to avoid sleep-in-atomic bugs when someone would mistakenly
> > call the function without the __GFP_HARDWALL flag for an atomic
> > allocation. The suffixes introduced were intended to make the callers
> > think before using the function.
> > 
> > However, since the callback lock was converted from mutex to spinlock by
> > the previous patch, the softwall check function cannot sleep, and these
> > precautions are no longer necessary.
> > 
> > So let's simplify the API back to the single check.
> > 
> > Suggested-by: David Rientjes <rientjes@google.com>
> > Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> > Acked-by: Christoph Lameter <cl@linux.com>
> > Acked-by: Zefan Li <lizefan@huawei.com>
> 
> Applied 1-2 to cgroup/for-3.19-cpuset-api-simplification which
> contains only these two patches on top of v3.18-rc2 and will stay
> stable.  sl[au]b trees can pull it in or I can take the other two
> patches too.  Please let me know how the other two should be routed.

JFYI, Andrew merged all four patches in his mmotm tree.

FWIW, there's a typo in this patch recently found and fixed by Dan
Carpenter. The fix is below.

Thanks,
Vladimir

---
From: Dan Carpenter <dan.carpenter@oracle.com>

This will deadlock instead of unlocking.

Fixes: f73eae8d8384 ('cpuset: simplify cpuset_node_allowed API')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
Acked-by: Vladimir Davydov <vdavydov@parallels.com>

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 38f7433..4eaa203 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1992,7 +1992,7 @@ static int cpuset_css_online(struct cgroup_subsys_state *css)
 	spin_lock_irq(&callback_lock);
 	cs->mems_allowed = parent->mems_allowed;
 	cpumask_copy(cs->cpus_allowed, parent->cpus_allowed);
-	spin_lock_irq(&callback_lock);
+	spin_unlock_irq(&callback_lock);
 out_unlock:
 	mutex_unlock(&cpuset_mutex);
 	return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
