Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id D44D56B0033
	for <linux-mm@kvack.org>; Fri, 29 Dec 2017 11:30:42 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id t65so30376419pfe.22
        for <linux-mm@kvack.org>; Fri, 29 Dec 2017 08:30:42 -0800 (PST)
Received: from BJEXCAS004.didichuxing.com (mx1.didichuxing.com. [111.202.154.82])
        by mx.google.com with ESMTPS id d132si25670570pgc.187.2017.12.29.08.30.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 29 Dec 2017 08:30:39 -0800 (PST)
Date: Sat, 30 Dec 2017 00:30:32 +0800
From: weiping zhang <zhangweiping@didichuxing.com>
Subject: Re: Regression with a0747a859ef6 ("bdi: add error handle for
 bdi_debug_register")
Message-ID: <20171229163021.GA9150@bogon.didichuxing.com>
References: <CAA70yB496Nuy2FM5idxLZthBwOVbhtsZ4VtXNJ_9mj2cvNC4kA@mail.gmail.com>
 <20171221153631.GA2300@wolff.to>
 <CAA70yB6nD7CiDZUpVPy7cGhi7ooQ5SPkrcXPDKqSYD2ezLrGHA@mail.gmail.com>
 <20171221164221.GA23680@wolff.to>
 <14f04d43-728a-953f-e07c-e7f9d5e3392d@kernel.dk>
 <20171221181531.GA21050@wolff.to>
 <20171221231603.GA15702@wolff.to>
 <20171222045318.GA4505@wolff.to>
 <CAA70yB5y1uLvtvEFLsE2C_ALLvSqEZ6XKA=zoPeSaH_eSAVL4w@mail.gmail.com>
 <20171222140423.GA23107@wolff.to>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20171222140423.GA23107@wolff.to>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bruno Wolff III <bruno@wolff.to>
Cc: Shaohua Li <shli@kernel.org>, Jens Axboe <axboe@kernel.dk>, Laura Abbott <labbott@redhat.com>, Jan Kara <jack@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, weiping zhang <zwp10758@gmail.com>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, regressions@leemhuis.info, linux-block@vger.kernel.org

On Fri, Dec 22, 2017 at 08:04:23AM -0600, Bruno Wolff III wrote:
> On Fri, Dec 22, 2017 at 21:20:10 +0800,
>  weiping zhang <zwp10758@gmail.com> wrote:
> >2017-12-22 12:53 GMT+08:00 Bruno Wolff III <bruno@wolff.to>:
> >>On Thu, Dec 21, 2017 at 17:16:03 -0600,
> >> Bruno Wolff III <bruno@wolff.to> wrote:
> >>>
> >>>
> >>>Enforcing mode alone isn't enough as I tested that one one machine at home
> >>>and it didn't trigger the problem. I'll try another machine late tonight.
> >>
> >>
> >>I got the problem to occur on my i686 machine when booting in enforcing
> >>mode. This machine uses raid 1 vua mdraid which may or may not be a factor
> >>in this problem. The boot log has a trace at the end and might be helpful,
> >>so I'm attaching it here.
> >Hi Bruno,
> >I can reproduce this issue in my QEMU test VM easily, just add an soft
> >RAID1, always trigger
> >that warning, I'll debug it later.
> 
> Great. When you have a fix, I can test it.
This issue can trigger easily in Centos7.3 + kernel-4.15-rc3, if meet two factors:
1. SELINUX in enforceing mode
2. mdadm try to create new gendisk.

if disable SELINUX or let it in permissive mode, issue disappear.
As Jens has revert that commit, it seems boot normally, actually
there is no diretory created under /sys/kernel/debug/bdi/, though
has no effect on disk workflow.

As James said before, "debugfs files should be treated as optional",
so kernel give warning here is enough.

So, we may solve this issue in two ways:
1. Add proper SELINUX policy that give permission to mdadm for debugfs.
2. Split mdadm into 2 part, Firstly, user proccess mdadm trigger a kwork,
secondly kwork will create gendisk)and mdadm wait it done, Like
following: 

diff --git a/drivers/md/md.c b/drivers/md/md.c
index 4e4dee0..86ead5a 100644
--- a/drivers/md/md.c
+++ b/drivers/md/md.c
@@ -90,6 +90,7 @@
 EXPORT_SYMBOL(md_cluster_mod);
 
 static DECLARE_WAIT_QUEUE_HEAD(resync_wait);
+static struct workqueue_struct *md_probe_wq;
 static struct workqueue_struct *md_wq;
 static struct workqueue_struct *md_misc_wq;
 
@@ -5367,10 +5368,27 @@ static int md_alloc(dev_t dev, char *name)
 	return error;
 }
 
+static void md_probe_work_fn(struct work_struct *ws)
+{
+	struct md_probe_work *mpw = container_of(ws, struct md_probe_work,
+					work);
+	md_alloc(mpw->dev, NULL);
+	mpw->done = 1;
+	wake_up(&mpw->wait);
+}
+
 static struct kobject *md_probe(dev_t dev, int *part, void *data)
 {
-	if (create_on_open)
-		md_alloc(dev, NULL);
+	struct md_probe_work mpw;
+
+	if (create_on_open) {
+		init_waitqueue_head(&mpw.wait);
+		mpw.dev = dev;
+		mpw.done = 0;
+		INIT_WORK(&mpw.work, md_probe_work_fn);
+		queue_work(md_probe_wq, &mpw.work);
+		wait_event(mpw.wait, mpw.done);
+	}
 	return NULL;
 }
 
@@ -9023,9 +9041,13 @@ static int __init md_init(void)
 {
 	int ret = -ENOMEM;
 
+	md_probe_wq = alloc_workqueue("md_probe", 0, 0);
+	if (!md_probe_wq)
+		goto err_wq;
+
 	md_wq = alloc_workqueue("md", WQ_MEM_RECLAIM, 0);
 	if (!md_wq)
-		goto err_wq;
+		goto err_probe_wq;
 
 	md_misc_wq = alloc_workqueue("md_misc", 0, 0);
 	if (!md_misc_wq)
@@ -9055,6 +9077,8 @@ static int __init md_init(void)
 	destroy_workqueue(md_misc_wq);
 err_misc_wq:
 	destroy_workqueue(md_wq);
+err_probe_wq:
+	destroy_workqueue(md_probe_wq);
 err_wq:
 	return ret;
 }
@@ -9311,6 +9335,7 @@ static __exit void md_exit(void)
 	}
 	destroy_workqueue(md_misc_wq);
 	destroy_workqueue(md_wq);
+	destroy_workqueue(md_probe_wq);
 }
 
 subsys_initcall(md_init);
diff --git a/drivers/md/md.h b/drivers/md/md.h
index 7d6bcf0..3953896 100644
--- a/drivers/md/md.h
+++ b/drivers/md/md.h
@@ -487,6 +487,13 @@ enum recovery_flags {
 	MD_RECOVERY_ERROR,	/* sync-action interrupted because io-error */
 };
 
+struct md_probe_work {
+	struct work_struct work;
+	wait_queue_head_t wait;
+	dev_t dev;
+	int done;
+};
+
 static inline int __must_check mddev_lock(struct mddev *mddev)
 {
 	return mutex_lock_interruptible(&mddev->reconfig_mutex);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
