Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5BFB2C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 13:17:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B07120879
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 13:17:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B07120879
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E3CFE6B000D; Tue, 14 May 2019 09:17:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DF1546B000E; Tue, 14 May 2019 09:17:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C8ED96B0010; Tue, 14 May 2019 09:17:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7DE4B6B000D
	for <linux-mm@kvack.org>; Tue, 14 May 2019 09:17:03 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id q16so9868073wrr.22
        for <linux-mm@kvack.org>; Tue, 14 May 2019 06:17:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=VdAVf6UsURaBN1kR2hvAUBFTDOMaklbC2zfjfZkKj2k=;
        b=Q1hqSdejAdasyyVkQGIVOxXWmpg29BmpQfR5oI7+XomefVfUcKC5BsIb8UK+vvwkM9
         5xY3a1hO8Z4M+g4qxeWoV7cNFWxwroJSWujWB7FCVXTfg39aHxe1/4dbLxzkeyB0kiw5
         x+NHa62WilyFW6U8FubAwQeG6lTgJe/eQD3mOjZLeLgEJFvaSsxSCE9a5lUS21OcARAU
         UzLFxF8fA3shHHLkE2Bh5ahN97QN3PqjGMBS9KqpJ4Ai0AXFVUiqGw0Kp36zBQuCo2Zm
         IHQ8cHK8zKMaTWKNrTT4aHVtk4UIGSg6UIPm1ygqblsBcL0MBQP1SqrsVFzB5tolKYep
         MRSA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWvPFM5ztjcL1PJtMnUPIN58HGDT6WgpbheyYmH2Katr12ewicO
	+vJdciBIGnT++e15FFvN4nMv+3mtxbzpKVeqDxNEHGt/TsFeQMSXfAEseCEBVTk1OjGSsa4b49Z
	Tu/0FZ0GdNdNDlrVmszOyNjt3XlgiHrNcygiPcn2hFuExgQFtEKjKBPvO6/OgmG11HA==
X-Received: by 2002:a1c:65c3:: with SMTP id z186mr16737379wmb.93.1557839822950;
        Tue, 14 May 2019 06:17:02 -0700 (PDT)
X-Received: by 2002:a1c:65c3:: with SMTP id z186mr16737308wmb.93.1557839821484;
        Tue, 14 May 2019 06:17:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557839821; cv=none;
        d=google.com; s=arc-20160816;
        b=f2OiSu9XbL6UIg0/jkeIIF+DVd7XOnnn3DTE0aGXWHo2vXjsHqy7WHBKzY8vYYNGC+
         Jy5nAJ+EleqbrZ9eA2lHrcyrODvD19jJ1vVtYcxp+w4iov0O9XP74cB3gQrvk6jAQqw4
         XYHxBIoQXjpH+I5Ol2pyOch2ZzM0Zze8i80e7MBB4ApgzK6Vay9Sl9A2Xix0kYRTsnhL
         xTRs0tguliyrooufL8sqQ5fW1kjpBjd8u2cYBrtdAcD446+G4UyDQ0WT5/iruSktfQDh
         tuqQBrEjn4E1YcB91lxIRARLveFaPOeKUMHZCc1gkYndXyot66jaC5Sp0EbEc/ueiQOH
         2jpw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=VdAVf6UsURaBN1kR2hvAUBFTDOMaklbC2zfjfZkKj2k=;
        b=dUGstb8im/ZINFHDsT6jIHnioOgamqkHPKfRTDCbE4izgNZuO5oH74q4inWr8agqCg
         Zic1J/CVf4Vrq1PF6MKiB1NFftQefmdS+20Pv2Ua2sBpOHL4m89c9o9Mvu+Uqkwh074+
         Lr5lNlCCe/oxH34QTSUwlfMLrTpILfWsEynGtLJkGa01JnpDNJvj7sJJj7ofZrTSoPr3
         SL6xF710Imss1dC5eQ+Jdcs9MSVQW1f5R8HNl/XPJngCqL6afgsRJ6RfT5LePBBJOgwx
         6fAKNylUXBzaP9QCGLUqz+fV3IGkfYe0ofHVbgksc0vM4mJ0reXDk7ppto2S9wMB6gyc
         WZBA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w2sor3141214wrm.19.2019.05.14.06.17.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 May 2019 06:17:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqyKKvVTOE8RaLl7n7pCLi0m5G1sMvqGxaeEklK4ZdRJocqbNZnJLuLQOOWk1SEOtgBgAe0hnw==
X-Received: by 2002:adf:8306:: with SMTP id 6mr9923763wrd.155.1557839821146;
        Tue, 14 May 2019 06:17:01 -0700 (PDT)
Received: from localhost (nat-pool-brq-t.redhat.com. [213.175.37.10])
        by smtp.gmail.com with ESMTPSA id f7sm1720014wmc.26.2019.05.14.06.17.00
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 14 May 2019 06:17:00 -0700 (PDT)
From: Oleksandr Natalenko <oleksandr@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Timofey Titovets <nefelim4ag@gmail.com>,
	Aaron Tomlin <atomlin@redhat.com>,
	Grzegorz Halat <ghalat@redhat.com>,
	linux-mm@kvack.org
Subject: [PATCH RFC v2 3/4] mm/ksm: introduce force_madvise knob
Date: Tue, 14 May 2019 15:16:53 +0200
Message-Id: <20190514131654.25463-4-oleksandr@redhat.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190514131654.25463-1-oleksandr@redhat.com>
References: <20190514131654.25463-1-oleksandr@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Present a new sysfs knob to mark task's anonymous memory as mergeable.

To force merging task's VMAs, its PID is echoed in a write-only file:

   # echo PID > /sys/kernel/mm/ksm/force_madvise

Force unmerging is done similarly, but with "minus" sign:

   # echo -PID > /sys/kernel/mm/ksm/force_madvise

"0" or "-0" can be used to control the current task.

To achieve this, previously introduced ksm_enter()/ksm_leave() helpers
are used in the "store" handler.

Signed-off-by: Oleksandr Natalenko <oleksandr@redhat.com>
---
 mm/ksm.c | 68 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 68 insertions(+)

diff --git a/mm/ksm.c b/mm/ksm.c
index e9f3901168bb..22c59fb03d3a 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -2879,10 +2879,77 @@ static void wait_while_offlining(void)
 
 #define KSM_ATTR_RO(_name) \
 	static struct kobj_attribute _name##_attr = __ATTR_RO(_name)
+#define KSM_ATTR_WO(_name) \
+	static struct kobj_attribute _name##_attr = __ATTR_WO(_name)
 #define KSM_ATTR(_name) \
 	static struct kobj_attribute _name##_attr = \
 		__ATTR(_name, 0644, _name##_show, _name##_store)
 
+static ssize_t force_madvise_store(struct kobject *kobj,
+				     struct kobj_attribute *attr,
+				     const char *buf, size_t count)
+{
+	int err;
+	pid_t pid;
+	bool merge = true;
+	struct task_struct *tsk;
+	struct mm_struct *mm;
+	struct vm_area_struct *vma;
+
+	err = kstrtoint(buf, 10, &pid);
+	if (err)
+		return -EINVAL;
+
+	if (pid < 0) {
+		pid = abs(pid);
+		merge = false;
+	}
+
+	if (!pid && *buf == '-')
+		merge = false;
+
+	rcu_read_lock();
+	if (pid) {
+		tsk = find_task_by_vpid(pid);
+		if (!tsk) {
+			err = -ESRCH;
+			rcu_read_unlock();
+			goto out;
+		}
+	} else {
+		tsk = current;
+	}
+
+	tsk = tsk->group_leader;
+
+	get_task_struct(tsk);
+	rcu_read_unlock();
+
+	mm = get_task_mm(tsk);
+	if (!mm) {
+		err = -EINVAL;
+		goto out_put_task_struct;
+	}
+	down_write(&mm->mmap_sem);
+	vma = mm->mmap;
+	while (vma) {
+		if (merge)
+			ksm_enter(vma->vm_mm, vma, &vma->vm_flags);
+		else
+			ksm_leave(vma, vma->vm_start, vma->vm_end, &vma->vm_flags);
+		vma = vma->vm_next;
+	}
+	up_write(&mm->mmap_sem);
+	mmput(mm);
+
+out_put_task_struct:
+	put_task_struct(tsk);
+
+out:
+	return err ? err : count;
+}
+KSM_ATTR_WO(force_madvise);
+
 static ssize_t sleep_millisecs_show(struct kobject *kobj,
 				    struct kobj_attribute *attr, char *buf)
 {
@@ -3185,6 +3252,7 @@ static ssize_t full_scans_show(struct kobject *kobj,
 KSM_ATTR_RO(full_scans);
 
 static struct attribute *ksm_attrs[] = {
+	&force_madvise_attr.attr,
 	&sleep_millisecs_attr.attr,
 	&pages_to_scan_attr.attr,
 	&run_attr.attr,
-- 
2.21.0

