Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF184C04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 07:21:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9DBB5217D6
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 07:21:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9DBB5217D6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B8E86B0010; Fri, 10 May 2019 03:21:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 96A416B0269; Fri, 10 May 2019 03:21:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 833B76B026A; Fri, 10 May 2019 03:21:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 62FEB6B0010
	for <linux-mm@kvack.org>; Fri, 10 May 2019 03:21:36 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id h16so4639336qke.11
        for <linux-mm@kvack.org>; Fri, 10 May 2019 00:21:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=mlMuZ+baS9vhQtlkYflvWcBmyvS2Oox5GVM3xd9Ae4c=;
        b=biuQiSe+Nld0dzatZU9m/JYNwP4bABaybzvCsy6dCI4vdGn1PqrpFnK5EhLqkt8VEs
         GnnltG6frN+JIRQo8GWrxc1jGe3xh3GdxwS5Z+K1EADGvivV3ndnU/pltCt1v08l8M+c
         MtIKl/R0gawqHWqXrUjyHMkeHG0pFVcg4zqFnYRbsV0R+Bnns3/3dV7x1+w/wJQclgos
         leYgQ+NzmB1vxel67zN1ut0/uTPwMMK+Lq2pWbidePnHWIWFdRlXC//9VZMg8T2NN/ek
         ZyXLVEAXXprvsR2n2ItN5i28IatqbSSmDUaMcMkcufKYvj3pe+0sWJD4EruHUl/f+N//
         Lfxg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUOABhqRcoBpV4hmmhgHeVSvGkTarXgrcPX9ZXtjYDmZ0U0ALEE
	BjaKhdAHJ5Hs7QGK3kJyIWn/S43A0BzOh3byS9dLU+zR3fDcrQiszA2xN9NP8C9bgk8GMRgbZg/
	ZLrxn9d2cUZ6BysIlcMWasZr7xQbnB8EIjYZpNmR1WS/6c0EQBzZvH3zYzp/LJJ5sUg==
X-Received: by 2002:ac8:3702:: with SMTP id o2mr8012560qtb.119.1557472896106;
        Fri, 10 May 2019 00:21:36 -0700 (PDT)
X-Received: by 2002:ac8:3702:: with SMTP id o2mr8012497qtb.119.1557472894928;
        Fri, 10 May 2019 00:21:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557472894; cv=none;
        d=google.com; s=arc-20160816;
        b=hmO7SH84wDWeyIpicWGazIyliYcTN7LneEMbdXmXP4eXr/j+xH5o6SiCR1BNc89zNG
         uX9IsPgj6DmajIxMhMoo6IUCAgns5k6NiwprUHXUUOoVicZhTiG5QQ2P/IDWE3x5e02t
         LG29Vipjncjibu+HbFF4UVm9xo6nvxYTqCiYeYOiXvGeBFNWvx+priLcNynhIHk+c7m3
         7Lqz6kHmAwwm2zoRjgslgQL3mxOgh6tiN7fDmyVSMOPQzvZcILvY0FhRHbaDZBnfHFQU
         OJV2/FjsSfSnwCSfxGWrbDy/bJlxDsnAywmqHJkc8YDqPlt7Ew6ZolaIMMCDk8Z77jWv
         qCtw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=mlMuZ+baS9vhQtlkYflvWcBmyvS2Oox5GVM3xd9Ae4c=;
        b=TaKIvCVlxrY+q+253Ep5RJe9LP94wYZ5IUK4pZPdLCF/NPXMrxAedSc+w16P6PhKLL
         EC4hepi+2yUU5L62lmfEdXA+e4a67s8dOjAkSdseduHIqm0swU1h0XTQCTMYF5i2d4lO
         PMPAjCQjaQ0Xwjo7pi6No0VMUz+7uGErmeDGFn198Eh+7uC1VkFo5b9zSAxTB8dtiQ0q
         0AEw/DM6s5V2f/tXhnb5/5l0Plif6dSUgFZzspdbI924870NW3Lyz37HgYH7DDI+bDj2
         Z87rG3IO+Ue5oMiZUxWb+ldFzd/IJtMgogINzvJR8mekTn+Gan0jAfeO/G/H8f2qP2D5
         O3VA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s29sor3539250qve.49.2019.05.10.00.21.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 10 May 2019 00:21:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqz/+ynrCsQP/BLl+LKcOs3x84+6OIoUVWb8hO3FNCiBMNoBPIf1oHQue0SdB9Zjhf1ZT6HdwQ==
X-Received: by 2002:a0c:b28e:: with SMTP id r14mr7753580qve.158.1557472894619;
        Fri, 10 May 2019 00:21:34 -0700 (PDT)
Received: from localhost (nat-pool-brq-t.redhat.com. [213.175.37.10])
        by smtp.gmail.com with ESMTPSA id 124sm1641385qkj.59.2019.05.10.00.21.33
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 10 May 2019 00:21:33 -0700 (PDT)
From: Oleksandr Natalenko <oleksandr@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	Pavel Tatashin <pasha.tatashin@oracle.com>,
	Timofey Titovets <nefelim4ag@gmail.com>,
	Aaron Tomlin <atomlin@redhat.com>,
	linux-mm@kvack.org
Subject: [PATCH RFC 3/4] mm/ksm: allow anonymous memory automerging
Date: Fri, 10 May 2019 09:21:24 +0200
Message-Id: <20190510072125.18059-4-oleksandr@redhat.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190510072125.18059-1-oleksandr@redhat.com>
References: <20190510072125.18059-1-oleksandr@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Introduce 2 KSM modes:

  * madvise, which is default and maintains old behaviour; and
  * always, in which new anonymous allocations are marked as eligible
    for merging.

The mode is controlled either via sysfs or via kernel cmdline for VMAs
to be marked as soon as possible during the boot process.

Previously introduced ksm_enter() helper is used to hook into
do_anonymous_page() and mark each eligible VMA as ready for merging.
This avoids introducing separate kthread to walk through the task/VMAs
list.

Signed-off-by: Oleksandr Natalenko <oleksandr@redhat.com>
---
 include/linux/ksm.h |  3 +++
 mm/ksm.c            | 65 +++++++++++++++++++++++++++++++++++++++++++++
 mm/memory.c         |  6 +++++
 3 files changed, 74 insertions(+)

diff --git a/include/linux/ksm.h b/include/linux/ksm.h
index bc13f228e2ed..3c076b35259c 100644
--- a/include/linux/ksm.h
+++ b/include/linux/ksm.h
@@ -21,6 +21,9 @@ struct mem_cgroup;
 #ifdef CONFIG_KSM
 int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
 		unsigned long end, int advice, unsigned long *vm_flags);
+#ifdef VM_UNMERGEABLE
+bool ksm_mode_always(void);
+#endif
 int ksm_enter(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long *vm_flags);
 int __ksm_enter(struct mm_struct *mm);
diff --git a/mm/ksm.c b/mm/ksm.c
index 0fb5f850087a..6a2280b875cc 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -295,6 +295,12 @@ static int ksm_nr_node_ids = 1;
 static unsigned long ksm_run = KSM_RUN_STOP;
 static void wait_while_offlining(void);
 
+#ifdef VM_UNMERGEABLE
+#define KSM_MODE_MADVISE	0
+#define KSM_MODE_ALWAYS		1
+static unsigned long ksm_mode = KSM_MODE_MADVISE;
+#endif
+
 static DECLARE_WAIT_QUEUE_HEAD(ksm_thread_wait);
 static DECLARE_WAIT_QUEUE_HEAD(ksm_iter_wait);
 static DEFINE_MUTEX(ksm_thread_mutex);
@@ -2478,6 +2484,36 @@ int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
 	return 0;
 }
 
+#ifdef VM_UNMERGEABLE
+bool ksm_mode_always(void)
+{
+	return ksm_mode == KSM_MODE_ALWAYS;
+}
+
+static int __init setup_ksm_mode(char *str)
+{
+	int ret = 0;
+
+	if (!str)
+		goto out;
+
+	if (!strcmp(str, "madvise")) {
+		ksm_mode = KSM_MODE_MADVISE;
+		ret = 1;
+	} else if (!strcmp(str, "always")) {
+		ksm_mode = KSM_MODE_ALWAYS;
+		ret = 1;
+	}
+
+out:
+	if (!ret)
+		pr_warn("ksm_mode= cannot parse, ignored\n");
+
+	return ret;
+}
+__setup("ksm_mode=", setup_ksm_mode);
+#endif
+
 int ksm_enter(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long *vm_flags)
 {
@@ -2881,6 +2917,35 @@ static void wait_while_offlining(void)
 	static struct kobj_attribute _name##_attr = \
 		__ATTR(_name, 0644, _name##_show, _name##_store)
 
+#ifdef VM_UNMERGEABLE
+static ssize_t mode_show(struct kobject *kobj, struct kobj_attribute *attr,
+	char *buf)
+{
+	switch (ksm_mode) {
+	case KSM_MODE_MADVISE:
+		return sprintf(buf, "always [madvise]\n");
+	case KSM_MODE_ALWAYS:
+		return sprintf(buf, "[always] madvise\n");
+	}
+
+	return sprintf(buf, "always [madvise]\n");
+}
+
+static ssize_t mode_store(struct kobject *kobj, struct kobj_attribute *attr,
+	const char *buf, size_t count)
+{
+	if (!memcmp("madvise", buf, min(sizeof("madvise")-1, count)))
+		ksm_mode = KSM_MODE_MADVISE;
+	else if (!memcmp("always", buf, min(sizeof("always")-1, count)))
+		ksm_mode = KSM_MODE_ALWAYS;
+	else
+		return -EINVAL;
+
+	return count;
+}
+KSM_ATTR(mode);
+#endif
+
 static ssize_t sleep_millisecs_show(struct kobject *kobj,
 				    struct kobj_attribute *attr, char *buf)
 {
diff --git a/mm/memory.c b/mm/memory.c
index ab650c21bccd..08f3f92de310 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2994,6 +2994,12 @@ static vm_fault_t do_anonymous_page(struct vm_fault *vmf)
 	update_mmu_cache(vma, vmf->address, vmf->pte);
 unlock:
 	pte_unmap_unlock(vmf->pte, vmf->ptl);
+
+#if defined(CONFIG_KSM) && defined(VM_UNMERGEABLE)
+	if (ksm_mode_always())
+		ksm_enter(vma->vm_mm, vma, &vma->vm_flags);
+#endif
+
 	return ret;
 release:
 	mem_cgroup_cancel_charge(page, memcg, false);
-- 
2.21.0

