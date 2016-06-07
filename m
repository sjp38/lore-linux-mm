Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8BD426B025F
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 08:50:16 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 4so25243445wmz.1
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 05:50:16 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id ft6si33164059wjb.177.2016.06.07.05.50.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jun 2016 05:50:15 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id r5so5772828wmr.0
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 05:50:15 -0700 (PDT)
Date: Tue, 7 Jun 2016 14:50:14 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] exit: clear TIF_MEMDIE after exit_task_work
Message-ID: <20160607125014.GL12305@dhcp22.suse.cz>
References: <1456765329-14890-1-git-send-email-vdavydov@virtuozzo.com>
 <20160301155212.GJ9461@dhcp22.suse.cz>
 <20160301175431-mutt-send-email-mst@redhat.com>
 <20160301160813.GM9461@dhcp22.suse.cz>
 <20160301182027-mutt-send-email-mst@redhat.com>
 <20160301163537.GO9461@dhcp22.suse.cz>
 <20160301184046-mutt-send-email-mst@redhat.com>
 <20160301171758.GP9461@dhcp22.suse.cz>
 <20160301191906-mutt-send-email-mst@redhat.com>
 <20160314163943.GE11400@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160314163943.GE11400@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 14-03-16 17:39:43, Michal Hocko wrote:
> On Tue 01-03-16 19:20:24, Michael S. Tsirkin wrote:
> > On Tue, Mar 01, 2016 at 06:17:58PM +0100, Michal Hocko wrote:
> [...]
> > > Sorry, I could have been more verbose... The code would have to make sure
> > > that the mm is still alive before calling g-u-p by
> > > atomic_inc_not_zero(&mm->mm_users) and fail if the user count dropped to
> > > 0 in the mean time. See how fs/proc/task_mmu.c does that (proc_mem_open
> > > + m_start + m_stop.
> > > 
> > > The biggest advanatage would be that the mm address space pin would be
> > > only for the particular operation. Not sure whether that is possible in
> > > the driver though. Anyway pinning the mm for a potentially unbounded
> > > amount of time doesn't sound too nice.
> > 
> > Hmm that would be another atomic on data path ...
> > I'd have to explore that.
> 
> Did you have any chance to look into this?

So this is my take to get rid of mm_users pinning for an unbounded
amount of time. This is even not compile tested. I am not sure how to
handle when the mm goes away while there are still work items pending.
It seems this is not handled current anyway and only shouts with a
warning so this shouldn't cause a new regression AFAICS. I am not
familiar with the vnet code at all so I might be missing many things,
though. Does the below sound even remotely reasonable to you Michael?
---
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 669fef1e2bb6..47a3e2c832ea 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -343,7 +343,12 @@ static int vhost_worker(void *data)
 
 		if (work) {
 			__set_current_state(TASK_RUNNING);
+			if (!mmget_not_zero(dev->mm)) {
+				pr_warn("vhost: device owner mm got released unexpectedly\n");
+				break;
+			}
 			work->fn(work);
+			mmput(dev->mm);
 			if (need_resched())
 				schedule();
 		} else
@@ -481,7 +486,16 @@ long vhost_dev_set_owner(struct vhost_dev *dev)
 	}
 
 	/* No owner, become one */
-	dev->mm = get_task_mm(current);
+	task_lock(current);
+	if (current->mm) {
+		dev->mm = current->mm;
+		atomic_inc(&curent->mm->mm_count);
+	}
+	task_unlock(current);
+	if (!dev->mm) {
+		err = -EINVAL;
+		goto err_mm;
+	}
 	worker = kthread_create(vhost_worker, dev, "vhost-%d", current->pid);
 	if (IS_ERR(worker)) {
 		err = PTR_ERR(worker);
@@ -505,7 +519,7 @@ long vhost_dev_set_owner(struct vhost_dev *dev)
 	dev->worker = NULL;
 err_worker:
 	if (dev->mm)
-		mmput(dev->mm);
+		mmdrop(dev->mm);
 	dev->mm = NULL;
 err_mm:
 	return err;
@@ -583,7 +597,7 @@ void vhost_dev_cleanup(struct vhost_dev *dev, bool locked)
 		dev->worker = NULL;
 	}
 	if (dev->mm)
-		mmput(dev->mm);
+		mmdrop(dev->mm);
 	dev->mm = NULL;
 }
 EXPORT_SYMBOL_GPL(vhost_dev_cleanup);
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
