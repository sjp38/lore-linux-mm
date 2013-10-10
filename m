Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f206.google.com (mail-ob0-f206.google.com [209.85.214.206])
	by kanga.kvack.org (Postfix) with ESMTP id EA4B66B0031
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 10:22:43 -0400 (EDT)
Received: by mail-ob0-f206.google.com with SMTP id vb8so36085obc.1
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 07:22:43 -0700 (PDT)
Date: Wed, 9 Oct 2013 20:24:12 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: strange oom behaviour on 3.10
Message-ID: <20131010002412.GC856@cmpxchg.org>
References: <CAJ75kXYqNfWejMhykEqmby4Yvs1w+Tv+QxKHZF67j77HJnco5A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJ75kXYqNfWejMhykEqmby4Yvs1w+Tv+QxKHZF67j77HJnco5A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: William Dauchy <wdauchy@gmail.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org

Hi William,

On Wed, Oct 09, 2013 at 05:54:20PM +0200, William Dauchy wrote:
> Hi,
> 
> I have been through a strange issue with cgroups on v3.10.x.
> The oom is triggered for a cgroups wich has reached the memory limit.
> I'm getting several:
> 
> Task in /lxc/VM_A killed as a result of limit of /lxc/VM_A
> memory: usage 262144kB, limit 262144kB, failcnt 44742
> 
> which is quite normal.
> The last one is:
> Task in / killed as a result of limit of /lxc/VM_A
> memory: usage 128420kB, limit 262144kB, failcnt 44749
> 
> Why do I have a oom kill is this case since the memory usage is ok?

I suspect a task's OOM context is set up but not handled, so later on
when another task triggers an OOM the OOM killer is invoked on
whatever memcg that OOM context was pointing to.

> Why is it choosing a task in / instead of in /lxc/VM_A?

The memcg in the OOM context could have been freed and corrupted at
that point.

Can you try this patch on top of what you have right now?

---
 mm/memcontrol.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ba3051a..d60f560 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2706,6 +2706,9 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 	if (unlikely(task_in_memcg_oom(current)))
 		goto bypass;
 
+	if (gfp_mask & __GFP_NOFAIL)
+		oom = false;
+
 	/*
 	 * We always charge the cgroup the mm_struct belongs to.
 	 * The mm_struct's mem_cgroup changes on task migration if the
@@ -2803,10 +2806,10 @@ done:
 	*ptr = memcg;
 	return 0;
 nomem:
-	*ptr = NULL;
-	if (gfp_mask & __GFP_NOFAIL)
-		return 0;
-	return -ENOMEM;
+	if (!(gfp_mask & __GFP_NOFAIL)) {
+		*ptr = NULL;
+		return -ENOMEM;
+	}
 bypass:
 	*ptr = root_mem_cgroup;
 	return -EINTR;
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
