Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 0A39D6B003B
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 16:12:23 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id y13so3480502pdi.37
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 13:12:23 -0800 (PST)
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
        by mx.google.com with ESMTPS id r7si7875539pbk.147.2014.01.30.13.12.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Jan 2014 13:12:23 -0800 (PST)
Received: by mail-pa0-f42.google.com with SMTP id kl14so3641265pab.1
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 13:12:22 -0800 (PST)
From: Sebastian Capella <sebastian.capella@linaro.org>
Subject: [PATCH v5 2/2] PM / Hibernate: use name_to_dev_t to parse resume
Date: Thu, 30 Jan 2014 13:11:58 -0800
Message-Id: <1391116318-17253-3-git-send-email-sebastian.capella@linaro.org>
In-Reply-To: <1391116318-17253-1-git-send-email-sebastian.capella@linaro.org>
References: <1391116318-17253-1-git-send-email-sebastian.capella@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org
Cc: Sebastian Capella <sebastian.capella@linaro.org>, Len Brown <len.brown@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>

Use the name_to_dev_t call to parse the device name echo'd to
to /sys/power/resume.  This imitates the method used in hibernate.c
in software_resume, and allows the resume partition to be specified
using other equivalent device formats as well.  By allowing
/sys/debug/resume to accept the same syntax as the resume=device
parameter, we can parse the resume=device in the init script and
use the resume device directly from the kernel command line.

Signed-off-by: Sebastian Capella <sebastian.capella@linaro.org>
Acked-by: Pavel Machek <pavel@ucw.cz>
Cc: Len Brown <len.brown@intel.com>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
---
 kernel/power/hibernate.c |   33 +++++++++++++++++----------------
 1 file changed, 17 insertions(+), 16 deletions(-)

diff --git a/kernel/power/hibernate.c b/kernel/power/hibernate.c
index 0121dab..49d7a37 100644
--- a/kernel/power/hibernate.c
+++ b/kernel/power/hibernate.c
@@ -972,26 +972,27 @@ static ssize_t resume_show(struct kobject *kobj, struct kobj_attribute *attr,
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
