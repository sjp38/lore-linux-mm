Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 5B6706B0036
	for <linux-mm@kvack.org>; Wed, 29 Jan 2014 18:48:58 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id kx10so2413950pab.35
        for <linux-mm@kvack.org>; Wed, 29 Jan 2014 15:48:58 -0800 (PST)
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
        by mx.google.com with ESMTPS id k3si4233173pbb.264.2014.01.29.15.48.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 29 Jan 2014 15:48:57 -0800 (PST)
Received: by mail-pb0-f44.google.com with SMTP id rq2so2412644pbb.3
        for <linux-mm@kvack.org>; Wed, 29 Jan 2014 15:48:57 -0800 (PST)
From: Sebastian Capella <sebastian.capella@linaro.org>
Subject: [PATCH v4 2/2] PM / Hibernate: use name_to_dev_t to parse resume
Date: Wed, 29 Jan 2014 15:48:24 -0800
Message-Id: <1391039304-3172-3-git-send-email-sebastian.capella@linaro.org>
In-Reply-To: <1391039304-3172-1-git-send-email-sebastian.capella@linaro.org>
References: <1391039304-3172-1-git-send-email-sebastian.capella@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org
Cc: Sebastian Capella <sebastian.capella@linaro.org>, Pavel Machek <pavel@ucw.cz>, Len Brown <len.brown@intel.com>, "Rafael J. Wysocki" <rjw@sisk.pl>

Use the name_to_dev_t call to parse the device name echo'd to
to /sys/power/resume.  This imitates the method used in hibernate.c
in software_resume, and allows the resume partition to be specified
using other equivalent device formats as well.  By allowing
/sys/debug/resume to accept the same syntax as the resume=device
parameter, we can parse the resume=device in the init script and
use the resume device directly from the kernel command line.

Signed-off-by: Sebastian Capella <sebastian.capella@linaro.org>
Cc: Pavel Machek <pavel@ucw.cz>
Cc: Len Brown <len.brown@intel.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>
---
 kernel/power/hibernate.c |   33 +++++++++++++++++----------------
 1 file changed, 17 insertions(+), 16 deletions(-)

diff --git a/kernel/power/hibernate.c b/kernel/power/hibernate.c
index 37170d4..b4a3e0b 100644
--- a/kernel/power/hibernate.c
+++ b/kernel/power/hibernate.c
@@ -973,26 +973,27 @@ static ssize_t resume_show(struct kobject *kobj, struct kobj_attribute *attr,
 static ssize_t resume_store(struct kobject *kobj, struct kobj_attribute *attr,
 			    const char *buf, size_t n)
 {
-	unsigned int maj, min;
 	dev_t res;
-	int ret = -EINVAL;
+	char *name = kstrimdup(buf, GFP_KERNEL);
 
-	if (sscanf(buf, "%u:%u", &maj, &min) != 2)
-		goto out;
+	if (name == NULL)
+		return -ENOMEM;
 
-	res = MKDEV(maj,min);
-	if (maj != MAJOR(res) || min != MINOR(res))
-		goto out;
+	res = name_to_dev_t(name);
 
-	lock_system_sleep();
-	swsusp_resume_device = res;
-	unlock_system_sleep();
-	printk(KERN_INFO "PM: Starting manual resume from disk\n");
-	noresume = 0;
-	software_resume();
-	ret = n;
- out:
-	return ret;
+	if (res != 0) {
+		lock_system_sleep();
+		swsusp_resume_device = res;
+		unlock_system_sleep();
+		printk(KERN_INFO "PM: Starting manual resume from disk\n");
+		noresume = 0;
+		software_resume();
+	} else {
+		n = -EINVAL;
+	}
+
+	kfree(name);
+	return n;
 }
 
 power_attr(resume);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
