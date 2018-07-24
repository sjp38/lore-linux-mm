Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id D69BC6B0006
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 10:17:53 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id d18-v6so2244686wrq.21
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 07:17:53 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 204-v6si1223343wmv.181.2018.07.24.07.17.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 07:17:52 -0700 (PDT)
Date: Tue, 24 Jul 2018 16:17:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: distinguish blockable mode for mmu notifiers
Message-ID: <20180724141747.GP28386@dhcp22.suse.cz>
References: <20180716115058.5559-1-mhocko@kernel.org>
 <20180720170902.d1137060c23802d55426aa03@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180720170902.d1137060c23802d55426aa03@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "David (ChunMing) Zhou" <David1.Zhou@amd.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Alex Deucher <alexander.deucher@amd.com>, David Airlie <airlied@linux.ie>, Jani Nikula <jani.nikula@linux.intel.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Felix Kuehling <felix.kuehling@amd.com>, kvm@vger.kernel.org, amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, linux-rdma@vger.kernel.org, xen-devel@lists.xenproject.org, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, David Rientjes <rientjes@google.com>, Leon Romanovsky <leonro@mellanox.com>

On Fri 20-07-18 17:09:02, Andrew Morton wrote:
[...]
> - Undocumented return value.
> 
> - comment "failed to reap part..." is misleading - sounds like it's
>   referring to something which happened in the past, is in fact
>   referring to something which might happen in the future.
> 
> - fails to call trace_finish_task_reaping() in one case
> 
> - code duplication.
> 
> - Increases mmap_sem hold time a little by moving
>   trace_finish_task_reaping() inside the locked region.  So sue me ;)
> 
> - Sharing the finish: path means that the trace event won't
>   distinguish between the two sources of finishing.
> 
> Please take a look?

oom_reap_task_mm should return false when __oom_reap_task_mm return
false. This is what my patch did but it seems this changed by
http://www.ozlabs.org/~akpm/mmotm/broken-out/mm-oom-remove-oom_lock-from-oom_reaper.patch
so that one should be fixed.

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 104ef4a01a55..88657e018714 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -565,7 +565,7 @@ static bool oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	/* failed to reap part of the address space. Try again later */
 	if (!__oom_reap_task_mm(mm)) {
 		up_read(&mm->mmap_sem);
-		return true;
+		return false;
 	}
 
 	pr_info("oom_reaper: reaped process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",


On top of that the proposed cleanup looks as follows:

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 88657e018714..4e185a282b3d 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -541,8 +541,16 @@ bool __oom_reap_task_mm(struct mm_struct *mm)
 	return ret;
 }
 
+/*
+ * Reaps the address space of the give task.
+ *
+ * Returns true on success and false if none or part of the address space
+ * has been reclaimed and the caller should retry later.
+ */
 static bool oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 {
+	bool ret = true;
+
 	if (!down_read_trylock(&mm->mmap_sem)) {
 		trace_skip_task_reaping(tsk->pid);
 		return false;
@@ -555,28 +563,28 @@ static bool oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	 * down_write();up_write() cycle in exit_mmap().
 	 */
 	if (test_bit(MMF_OOM_SKIP, &mm->flags)) {
-		up_read(&mm->mmap_sem);
 		trace_skip_task_reaping(tsk->pid);
-		return true;
+		goto out_unlock;
 	}
 
 	trace_start_task_reaping(tsk->pid);
 
 	/* failed to reap part of the address space. Try again later */
-	if (!__oom_reap_task_mm(mm)) {
-		up_read(&mm->mmap_sem);
-		return false;
-	}
+	ret = __oom_reap_task_mm(mm);
+	if (!ret)
+		goto out_finish;
 
 	pr_info("oom_reaper: reaped process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
 			task_pid_nr(tsk), tsk->comm,
 			K(get_mm_counter(mm, MM_ANONPAGES)),
 			K(get_mm_counter(mm, MM_FILEPAGES)),
 			K(get_mm_counter(mm, MM_SHMEMPAGES)));
+out_finish:
+	trace_finish_task_reaping(tsk->pid);
+out_unlock:
 	up_read(&mm->mmap_sem);
 
-	trace_finish_task_reaping(tsk->pid);
-	return true;
+	return ret;
 }
 
 #define MAX_OOM_REAP_RETRIES 10
-- 
Michal Hocko
SUSE Labs
