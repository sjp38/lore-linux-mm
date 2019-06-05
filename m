Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14ABDC28CC5
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 13:37:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C0C7420665
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 13:37:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="04/ccSPI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C0C7420665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3D0226B000D; Wed,  5 Jun 2019 09:37:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 34A696B0010; Wed,  5 Jun 2019 09:37:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 212E16B0266; Wed,  5 Jun 2019 09:37:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id DEFE16B000D
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 09:37:25 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id bb9so16109394plb.2
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 06:37:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=u+zLCba4ifvorqHECxdb8NWOVORyLACPhu1rUxGfaiU=;
        b=rxe5VMWcMy19dFb3wP26/SLnLLsZa3F21WV+Tk5b9CZeE1xN8k69ZWhFbGZfSqusAD
         NitApGESxZS1YyUZXHu3LoUDfwNzdsJVzHS7t6tktejAulWiYrMtLQ3QfZu6sZ2oIwbV
         Qw0CUCBleVyQ/npHC7ZADzs7hSLu/1JInPpKilAiGbqZm1/nXiItYQyOwhJrbaiasigd
         gxd6qZ5A1f+nVdlAov08C+B4gGJYb1YyWv23r4XUufeRYok0ke5lFDeG7cJnfEXzD5Dx
         NoOyyj2THDYrygy8PJf4fGJt8IglKNFcCb3itgYMkZEdvbenA5JGGf5OsQASyT75FDns
         E0rA==
X-Gm-Message-State: APjAAAXsLn2F8zI1jSBvNRf0k4V658bUBOZZUuW7L9VF4fGy2wJnmzqN
	jp3tK3JBt4VIgjBxk1QH+rG6tmKQukicpzdo/+SrSI/Nkm0GcaN42aI301QfzuY1C08j91ZUbaq
	Wyc3ppvj2KYRqeb3W6kaUxNPUDXYuSfDBQ81kw4XpwMPTu1kJ0MYC2aF9AUZn2CXlnA==
X-Received: by 2002:a63:4f07:: with SMTP id d7mr4424133pgb.77.1559741845358;
        Wed, 05 Jun 2019 06:37:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz4bB9YQuA8v/7AJsIX9aMv8pP0blcsKKtvRUA39dmpOIXD26diG0JHIMribfsdhotQSrVp
X-Received: by 2002:a63:4f07:: with SMTP id d7mr4424047pgb.77.1559741844462;
        Wed, 05 Jun 2019 06:37:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559741844; cv=none;
        d=google.com; s=arc-20160816;
        b=sOjJicTt6i4H39+FDZBfgtXTKoUvMW4GU+ssb9nx/jWe0I97lbMjSzQmt07IcyB7JD
         vrAOG3IyGQCOTp3/pWElQwK1BhVqSbPOD4Y9nRxslBJ9NWyGDwFFfBucG9Yt5t1bVp7Y
         UGWzsdWw70XnW1igYKOjXbgbES8Z1ygtUxNvCKnm937N4dcFEG5iwzkaAORSphC46xI1
         5V6B6W6AXEHFPXhgZjCsOyefoD2jGSFQRtqJTGdon60xyWiHfsF3X+Myr4pCXUy2eY0U
         r0eHNpuZKLbI4+ZuJCbOcBoDv9bRvNkGVW+dw+Lxu9dFYMjZCPfUAaCyvpbhVtR/T3bX
         I5Ag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=u+zLCba4ifvorqHECxdb8NWOVORyLACPhu1rUxGfaiU=;
        b=YQJZxUO1902D89tiavA2LqAWRBtI/+SaYC1XL2tZcA9EwA6kn862fZM6f5nHaeCvTu
         BO+LIjy3j2oExMFiZEoRzf5cYK3OvZeYsbi1xcTN1kyTEpq4vQODg+ZyudUpLpJTGhd8
         T9MCuvVpbMirbOidkO66gzufzoHN8YQNfudU5xw9F+AgffIBDXQsoE/wsQ4WgtAGHw5g
         SD9/y4NOZ9KE0v/kh9s2OOEPfWUvTqX6za8s+PByaV+bBzS1jPykHTSKVVruRJBMYT1a
         8F1YnivAgHaUtKtlG3iuwMXMBaMMKBsPjaHov08PBcMfSBLFvHCWJoTNLk/2nfD3IqZg
         oEjw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="04/ccSPI";
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id d10si26040888plr.307.2019.06.05.06.37.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 06:37:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="04/ccSPI";
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x55DTE1i119488;
	Wed, 5 Jun 2019 13:37:09 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : mime-version :
 content-transfer-encoding; s=corp-2018-07-02;
 bh=u+zLCba4ifvorqHECxdb8NWOVORyLACPhu1rUxGfaiU=;
 b=04/ccSPIDB9rw0yaqtcHi0KxfYmVhroln6GrxIIJzj+KGMwFDFX7hLTbB5o3fTLxBF89
 f6L2rcGShr+HLDMtx402CIThkjTlkqOfuo5U4Vd+MJrso7BezPsVTOmqkth7JJQ+RTEc
 kb14qh1piCluKWghlyGA2hLFa4230l30Vnc3+2m6xnNZIVg07MSAiWxocE7bA/4j0m0+
 TK9uMGn+1S+nIxB5mvY6N/WRTOKYBwl3FYzT/tWQhVUECUikgTVXITWKP/BEzEeEU74+
 6ZJYd4KTUVHwSCKtYk7FLDVi+4/BwJsFLksq3zUNl7MKDZf0qHnUIp/9vO+eJvVWqjYF RA== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2130.oracle.com with ESMTP id 2sugstjn49-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 05 Jun 2019 13:37:09 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x55DZsPL069366;
	Wed, 5 Jun 2019 13:37:09 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3020.oracle.com with ESMTP id 2swnghw2j9-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 05 Jun 2019 13:37:08 +0000
Received: from abhmp0001.oracle.com (abhmp0001.oracle.com [141.146.116.7])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x55Db0GP027121;
	Wed, 5 Jun 2019 13:37:01 GMT
Received: from localhost.localdomain (/73.60.114.248)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 05 Jun 2019 06:37:00 -0700
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: hannes@cmpxchg.org, jiangshanlai@gmail.com, lizefan@huawei.com,
        tj@kernel.org
Cc: bsd@redhat.com, dan.j.williams@intel.com, daniel.m.jordan@oracle.com,
        dave.hansen@intel.com, juri.lelli@redhat.com, mhocko@kernel.org,
        peterz@infradead.org, steven.sistare@oracle.com, tglx@linutronix.de,
        tom.hromatka@oracle.com, vdavydov.dev@gmail.com,
        cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org
Subject: [RFC v2 1/5] cgroup: add cgroup v2 interfaces to migrate kernel threads
Date: Wed,  5 Jun 2019 09:36:46 -0400
Message-Id: <20190605133650.28545-2-daniel.m.jordan@oracle.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190605133650.28545-1-daniel.m.jordan@oracle.com>
References: <20190605133650.28545-1-daniel.m.jordan@oracle.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9278 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=870
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1906050087
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9278 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=902 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906050087
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Prepare for cgroup aware workqueues by introducing cgroup_attach_kthread
and a helper cgroup_attach_kthread_to_dfl_root.

A workqueue worker will always migrate itself, so for now use @current
in the interfaces to avoid handling task references.

Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 include/linux/cgroup.h |  6 ++++++
 kernel/cgroup/cgroup.c | 48 +++++++++++++++++++++++++++++++++++++-----
 2 files changed, 49 insertions(+), 5 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 81f58b4a5418..ad78784e3692 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -103,6 +103,7 @@ struct cgroup_subsys_state *css_tryget_online_from_dir(struct dentry *dentry,
 struct cgroup *cgroup_get_from_path(const char *path);
 struct cgroup *cgroup_get_from_fd(int fd);
 
+int cgroup_attach_kthread(struct cgroup *dst_cgrp);
 int cgroup_attach_task_all(struct task_struct *from, struct task_struct *);
 int cgroup_transfer_tasks(struct cgroup *to, struct cgroup *from);
 
@@ -530,6 +531,11 @@ static inline struct cgroup *task_dfl_cgroup(struct task_struct *task)
 	return task_css_set(task)->dfl_cgrp;
 }
 
+static inline int cgroup_attach_kthread_to_dfl_root(void)
+{
+	return cgroup_attach_kthread(&cgrp_dfl_root.cgrp);
+}
+
 static inline struct cgroup *cgroup_parent(struct cgroup *cgrp)
 {
 	struct cgroup_subsys_state *parent_css = cgrp->self.parent;
diff --git a/kernel/cgroup/cgroup.c b/kernel/cgroup/cgroup.c
index 3f2b4bde0f9c..bc8d6a2e529f 100644
--- a/kernel/cgroup/cgroup.c
+++ b/kernel/cgroup/cgroup.c
@@ -2771,21 +2771,59 @@ struct task_struct *cgroup_procs_write_start(char *buf, bool threadgroup)
 	return tsk;
 }
 
-void cgroup_procs_write_finish(struct task_struct *task)
-	__releases(&cgroup_threadgroup_rwsem)
+static void __cgroup_procs_write_finish(struct task_struct *task)
 {
 	struct cgroup_subsys *ss;
 	int ssid;
 
-	/* release reference from cgroup_procs_write_start() */
-	put_task_struct(task);
+	lockdep_assert_held(&cgroup_mutex);
 
-	percpu_up_write(&cgroup_threadgroup_rwsem);
 	for_each_subsys(ss, ssid)
 		if (ss->post_attach)
 			ss->post_attach();
 }
 
+void cgroup_procs_write_finish(struct task_struct *task)
+	__releases(&cgroup_threadgroup_rwsem)
+{
+	lockdep_assert_held(&cgroup_mutex);
+
+	/* release reference from cgroup_procs_write_start() */
+	put_task_struct(task);
+
+	percpu_up_write(&cgroup_threadgroup_rwsem);
+	__cgroup_procs_write_finish(task);
+}
+
+/**
+ * cgroup_attach_kthread - attach the current kernel thread to a cgroup
+ * @dst_cgrp: the cgroup to attach to
+ *
+ * The caller is responsible for ensuring @dst_cgrp is valid until this
+ * function returns.
+ *
+ * Return: 0 on success or negative error code.
+ */
+int cgroup_attach_kthread(struct cgroup *dst_cgrp)
+{
+	int ret;
+
+	if (WARN_ON_ONCE(!(current->flags & PF_KTHREAD)))
+		return -EINVAL;
+
+	mutex_lock(&cgroup_mutex);
+
+	percpu_down_write(&cgroup_threadgroup_rwsem);
+	ret = cgroup_attach_task(dst_cgrp, current, false);
+	percpu_up_write(&cgroup_threadgroup_rwsem);
+
+	__cgroup_procs_write_finish(current);
+
+	mutex_unlock(&cgroup_mutex);
+
+	return ret;
+}
+
 static void cgroup_print_ss_mask(struct seq_file *seq, u16 ss_mask)
 {
 	struct cgroup_subsys *ss;
-- 
2.21.0

