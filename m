Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,UNPARSEABLE_RELAY,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B58B9C28CC5
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 13:37:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5062E20665
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 13:37:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="R8gl8B/W"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5062E20665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 71EC26B026A; Wed,  5 Jun 2019 09:37:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6CF0E6B026C; Wed,  5 Jun 2019 09:37:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 45D536B026B; Wed,  5 Jun 2019 09:37:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id F255A6B0266
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 09:37:29 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id d7so14810249pgc.8
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 06:37:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=/kR+J05BNWcdRdpq6dzt+Y70VdHoKrDhYHZLSK/vCNc=;
        b=Ec6StU6K/OMlXJ8weVOMgcIdEnug0tT1OaNyeouRZnoC1kSNtK5AV3eRTLGWkjLL7d
         M0YqNDbQRgZpkpvYR0ugwe9vB0B6JkKRrBkQE5EH+n3ULKxxLBgC59DkWgjvNffKAOhj
         rDfJN+NiAMvXzA1L2IwuOfnFt9NljTmW7GLJLZwXiIXXMQnO/p7KCbMP4jGxY+Ia2Rx1
         BlM6296/sizVbjG5799Be1/nfvSntQxocwu6xCSVPkUc9QLxkhLspfwTnWQn6Xhn/yIs
         TubPRRwDmvI1aQiQJ2Q+Dl3Wem69vWOBuWpk0Xd5/zm4+YcvJhahaQWz6zmm0r9EGBhb
         96kw==
X-Gm-Message-State: APjAAAW397sQ+tIjJH1itKKasHhbthTJo3XS91OukCqpW51GEopu5VO2
	oLSzkmJY4Uuz+nEaQb8YMrb7//mcVQK7L6vfXdHnnd++9k5vv3WwLIJcnkX0Fvf66dV7/sAF2ZL
	nPg5VHtI5ycXAdisCdRIsqZXQgXOhVYavxxKIkhO0SjHKpWkYjqEnGWoJ45KFDp1u4A==
X-Received: by 2002:a17:90a:b94c:: with SMTP id f12mr41907904pjw.64.1559741849457;
        Wed, 05 Jun 2019 06:37:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwONJyFS3+Hysrx5afanBNdGdGRvXf2n9DB3Zgu9VddI9mb4O0VGy9FqlOD3VO0cD1Y6ZRy
X-Received: by 2002:a17:90a:b94c:: with SMTP id f12mr41907729pjw.64.1559741847866;
        Wed, 05 Jun 2019 06:37:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559741847; cv=none;
        d=google.com; s=arc-20160816;
        b=zc5tS3g9Y9+oj9oONlmx1KcbpQPAEiSCEqNh3OoGBrSyMXTWrjHJRzyuWHd+dSzU2F
         HYRIinMhxgUT/ULozlFgezrY7PRsIciPM9zuc4ABcfp89yZ/rBEA4lam2LD4czVOlN7n
         /czB+Mu6YO5ssJQcLON7S/7Pr6bajy/NPRVjP3uli2bcJGclBh+qML5Mx1G32ADUAIVX
         7QUHgM/0OK+x+baVPccN820q3FWjU3XmoOojUYV82qjYP9dsWIgHs2tQ2cunggmc41Y0
         XG5ZIUZ4adaaa70olss7p9B6O2o2qPwD5JuEBdvZE+87a03zwzPvLVYiO/9neA+MmOb7
         dAFQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=/kR+J05BNWcdRdpq6dzt+Y70VdHoKrDhYHZLSK/vCNc=;
        b=uCwOFm0sAUz1ZmDyyxIEAsqvBbum7/wD1zDN4jIjL1wd0i1x3jcdwykCwwFwX1LQC9
         QHvm9FrmsMGkuCM0jkYYnFYTGpVpn8Dd5rOT+rHVke+e7bjLgIgOsh7hbY8aW+zAjZrc
         1UKQORYaeyFNNGappFfptd9ZXeEvQ4ysCMpoddLXMXVFKFPqGP05R/RKGfDVEdsH549F
         P8ujin79S8iJzhsHmqaWy3d9b+NnAZ/5j6mDENICjN/uSEKAT35Wn5IXrPekNj70kugQ
         2RaoflLYr2qq9yDywJvlSKi+9AdjtJKjdkdi0wXwjQufggvUPjcci+2IbJtDX1vQsSYJ
         vaYw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="R8gl8B/W";
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id d197si25131927pga.110.2019.06.05.06.37.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 06:37:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="R8gl8B/W";
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x55DTff6127999;
	Wed, 5 Jun 2019 13:37:09 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : mime-version :
 content-transfer-encoding; s=corp-2018-07-02;
 bh=/kR+J05BNWcdRdpq6dzt+Y70VdHoKrDhYHZLSK/vCNc=;
 b=R8gl8B/WNwmi0k38CSxxHKwtS5n1yTLCCBZXEaq+20ch7V8DLgX2FcLYDP0Yh/6Hc8wS
 +KJ7haDSGqn3Xufzqt+nl2otUU2hWJXsFI43e6ttpdZeFswYhlel1XaWvh12pbfJvL87
 l/J805Mr1tHwLj5OF4crfdVs/R7cf99ugX8dzICSkhaxlP7eugcQXUKJNhlJjFuK9AuI
 UvW0AObZAb9gU89MIIgp0drkQfh8NgxdJtZBE9McqOmuCVSdykAOzegpwTHP4fnqD0W/
 BL3uWeqmruc/C5v6nOQnUuUpPcYUtRRwGNCv4FwtJSNkvBUISFC/vF65C9UwO/BjXtdk 5w== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by userp2120.oracle.com with ESMTP id 2suj0qjhr7-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 05 Jun 2019 13:37:09 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x55Db8VO002759;
	Wed, 5 Jun 2019 13:37:09 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userp3030.oracle.com with ESMTP id 2swngkw199-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 05 Jun 2019 13:37:09 +0000
Received: from abhmp0001.oracle.com (abhmp0001.oracle.com [141.146.116.7])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x55Db69M009930;
	Wed, 5 Jun 2019 13:37:07 GMT
Received: from localhost.localdomain (/73.60.114.248)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 05 Jun 2019 06:37:06 -0700
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: hannes@cmpxchg.org, jiangshanlai@gmail.com, lizefan@huawei.com,
        tj@kernel.org
Cc: bsd@redhat.com, dan.j.williams@intel.com, daniel.m.jordan@oracle.com,
        dave.hansen@intel.com, juri.lelli@redhat.com, mhocko@kernel.org,
        peterz@infradead.org, steven.sistare@oracle.com, tglx@linutronix.de,
        tom.hromatka@oracle.com, vdavydov.dev@gmail.com,
        cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org
Subject: [RFC v2 4/5] workqueue, cgroup: add test module
Date: Wed,  5 Jun 2019 09:36:49 -0400
Message-Id: <20190605133650.28545-5-daniel.m.jordan@oracle.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190605133650.28545-1-daniel.m.jordan@oracle.com>
References: <20190605133650.28545-1-daniel.m.jordan@oracle.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9278 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1906050087
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9278 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906050087
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Test the basic functionality of cgroup aware workqueues.  Inspired by
Matthew Wilcox's test_xarray.c

Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 kernel/workqueue.c                            |   1 +
 lib/Kconfig.debug                             |  12 +
 lib/Makefile                                  |   1 +
 lib/test_cgroup_workqueue.c                   | 325 ++++++++++++++++++
 .../selftests/cgroup_workqueue/Makefile       |   9 +
 .../testing/selftests/cgroup_workqueue/config |   1 +
 .../cgroup_workqueue/test_cgroup_workqueue.sh | 104 ++++++
 7 files changed, 453 insertions(+)
 create mode 100644 lib/test_cgroup_workqueue.c
 create mode 100644 tools/testing/selftests/cgroup_workqueue/Makefile
 create mode 100644 tools/testing/selftests/cgroup_workqueue/config
 create mode 100755 tools/testing/selftests/cgroup_workqueue/test_cgroup_workqueue.sh

diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index c8cc69e296c0..15459b5bb0bf 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -1825,6 +1825,7 @@ bool queue_cgroup_work_node(int node, struct workqueue_struct *wq,
 	local_irq_restore(flags);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(queue_cgroup_work_node);
 
 static inline bool worker_in_child_cgroup(struct worker *worker)
 {
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index d5a4a4036d2f..9909a306c142 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -2010,6 +2010,18 @@ config TEST_STACKINIT
 
 	  If unsure, say N.
 
+config TEST_CGROUP_WQ
+	tristate "Test cgroup-aware workqueues at runtime"
+	depends on CGROUPS
+	help
+	  Test cgroup-aware workqueues, in which workers attach to the
+          cgroup specified by the queueing task.  Basic test coverage
+          for whether workers attach to the expected cgroup, both for
+          cgroup-aware and unaware works, and whether workers are
+          throttled by the memory controller.
+
+	  If unsure, say N.
+
 endif # RUNTIME_TESTING_MENU
 
 config MEMTEST
diff --git a/lib/Makefile b/lib/Makefile
index 18c2be516ab4..d08b4a50bfd1 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -92,6 +92,7 @@ obj-$(CONFIG_TEST_OBJAGG) += test_objagg.o
 obj-$(CONFIG_TEST_STACKINIT) += test_stackinit.o
 
 obj-$(CONFIG_TEST_LIVEPATCH) += livepatch/
+obj-$(CONFIG_TEST_CGROUP_WQ) += test_cgroup_workqueue.o
 
 ifeq ($(CONFIG_DEBUG_KOBJECT),y)
 CFLAGS_kobject.o += -DDEBUG
diff --git a/lib/test_cgroup_workqueue.c b/lib/test_cgroup_workqueue.c
new file mode 100644
index 000000000000..466ec4e6e55b
--- /dev/null
+++ b/lib/test_cgroup_workqueue.c
@@ -0,0 +1,325 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * test_cgroup_workqueue.c: Test cgroup-aware workqueues
+ * Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
+ * Author: Daniel Jordan <daniel.m.jordan@oracle.com>
+ *
+ * Inspired by Matthew Wilcox's test_xarray.c.
+ */
+
+#include <linux/cgroup.h>
+#include <linux/kconfig.h>
+#include <linux/module.h>
+#include <linux/random.h>
+#include <linux/rcupdate.h>
+#include <linux/sched.h>
+#include <linux/slab.h>
+#include <linux/string.h>
+#include <linux/vmalloc.h>
+#include <linux/workqueue.h>
+
+static atomic_long_t cwq_tests_run = ATOMIC_LONG_INIT(0);
+static atomic_long_t cwq_tests_passed = ATOMIC_LONG_INIT(0);
+
+static struct workqueue_struct *cwq_cgroup_aware_wq;
+static struct workqueue_struct *cwq_cgroup_unaware_wq;
+
+/* cgroup v2 hierarchy mountpoint */
+static char *cwq_cgrp_root_path = "/test_cgroup_workqueue";
+module_param(cwq_cgrp_root_path, charp, 0444);
+static struct cgroup *cwq_cgrp_root;
+
+static char *cwq_cgrp_1_path = "/cwq_1";
+module_param(cwq_cgrp_1_path, charp, 0444);
+static struct cgroup *cwq_cgrp_1;
+
+static char *cwq_cgrp_2_path = "/cwq_2";
+module_param(cwq_cgrp_2_path, charp, 0444);
+static struct cgroup *cwq_cgrp_2;
+
+static char *cwq_cgrp_3_path = "/cwq_3";
+module_param(cwq_cgrp_3_path, charp, 0444);
+static struct cgroup *cwq_cgrp_3;
+
+static size_t cwq_memcg_max = 1ul << 20;
+module_param(cwq_memcg_max, ulong, 0444);
+
+#define CWQ_BUG(x, test_name) ({					       \
+	int __ret_cwq_bug = !!(x);					       \
+	atomic_long_inc(&cwq_tests_run);				       \
+	if (__ret_cwq_bug) {						       \
+		pr_warn("BUG at %s:%d\n", __func__, __LINE__);		       \
+		pr_warn("%s\n", (test_name));				       \
+		dump_stack();						       \
+	} else {							       \
+		atomic_long_inc(&cwq_tests_passed);			       \
+	}								       \
+	__ret_cwq_bug;							       \
+})
+
+#define CWQ_BUG_ON(x) CWQ_BUG((x), "<no test name>")
+
+struct cwq_data {
+	struct cgroup_work cwork;
+	struct cgroup	   *expected_cgroup;
+	const char	   *test_name;
+};
+
+#define CWQ_INIT_DATA(data, func, expected_cgrp) do {			\
+	INIT_WORK_ONSTACK(&(data)->work, (func));			\
+	(data)->expected_cgroup = (expected_cgrp);			\
+} while (0)
+
+static void cwq_verify_worker_cgroup(struct work_struct *work)
+{
+	struct cgroup_work *cwork = container_of(work, struct cgroup_work,
+						 work);
+	struct cwq_data *data = container_of(cwork, struct cwq_data, cwork);
+	struct cgroup *worker_cgroup;
+
+	CWQ_BUG(!(current->flags & PF_WQ_WORKER), data->test_name);
+
+	rcu_read_lock();
+	worker_cgroup = task_dfl_cgroup(current);
+	rcu_read_unlock();
+
+	CWQ_BUG(worker_cgroup != data->expected_cgroup, data->test_name);
+}
+
+static noinline void cwq_test_reg_work_on_cgrp_unaware_wq(void)
+{
+	struct cwq_data data;
+
+	data.expected_cgroup = cwq_cgrp_root;
+	data.test_name = __func__;
+	INIT_WORK_ONSTACK(&data.cwork.work, cwq_verify_worker_cgroup);
+
+	CWQ_BUG_ON(!queue_work(cwq_cgroup_unaware_wq, &data.cwork.work));
+	flush_work(&data.cwork.work);
+}
+
+static noinline void cwq_test_cgrp_work_on_cgrp_aware_wq(void)
+{
+	struct cwq_data data;
+
+	data.expected_cgroup = cwq_cgrp_1;
+	data.test_name = __func__;
+	INIT_CGROUP_WORK_ONSTACK(&data.cwork, cwq_verify_worker_cgroup);
+
+	CWQ_BUG_ON(!queue_cgroup_work(cwq_cgroup_aware_wq, &data.cwork,
+				      cwq_cgrp_1));
+	flush_work(&data.cwork.work);
+}
+
+static struct cgroup *cwq_get_random_cgroup(void)
+{
+	switch (prandom_u32_max(4)) {
+	case 1:  return cwq_cgrp_1;
+	case 2:  return cwq_cgrp_2;
+	case 3:  return cwq_cgrp_3;
+	default: return cwq_cgrp_root;
+	}
+}
+
+#define CWQ_NWORK 256
+static noinline void cwq_test_many_cgrp_works_on_cgrp_aware_wq(void)
+{
+	int i;
+	struct cwq_data *data_array = kmalloc_array(CWQ_NWORK,
+						    sizeof(struct cwq_data),
+						    GFP_KERNEL);
+	if (CWQ_BUG_ON(!data_array))
+		return;
+
+	for (i = 0; i < CWQ_NWORK; ++i) {
+		struct cgroup *cgrp = cwq_get_random_cgroup();
+
+		data_array[i].expected_cgroup = cgrp;
+		data_array[i].test_name = __func__;
+		INIT_CGROUP_WORK(&data_array[i].cwork,
+				 cwq_verify_worker_cgroup);
+		CWQ_BUG_ON(!queue_cgroup_work(cwq_cgroup_aware_wq,
+					      &data_array[i].cwork,
+					      cgrp));
+	}
+
+	for (i = 0; i < CWQ_NWORK; ++i)
+		flush_work(&data_array[i].cwork.work);
+
+	kfree(data_array);
+}
+
+static void cwq_verify_worker_obeys_memcg(struct work_struct *work)
+{
+	struct cgroup_work *cwork = container_of(work, struct cgroup_work,
+						 work);
+	struct cwq_data *data = container_of(cwork, struct cwq_data, cwork);
+	struct cgroup *worker_cgroup;
+	void *mem;
+
+	CWQ_BUG(!(current->flags & PF_WQ_WORKER), data->test_name);
+
+	rcu_read_lock();
+	worker_cgroup = task_dfl_cgroup(current);
+	rcu_read_unlock();
+
+	CWQ_BUG(worker_cgroup != data->expected_cgroup, data->test_name);
+
+	mem = __vmalloc(cwq_memcg_max * 2, __GFP_ACCOUNT | __GFP_NOWARN,
+			PAGE_KERNEL);
+	if (data->expected_cgroup == cwq_cgrp_2) {
+		/*
+		 * cwq_cgrp_2 has its memory.max set to cwq_memcg_max, so the
+		 * allocation should fail.
+		 */
+		CWQ_BUG(mem, data->test_name);
+	} else {
+		/*
+		 * Other cgroups don't have a memory.max limit, so the
+		 * allocation should succeed.
+		 */
+		CWQ_BUG(!mem, data->test_name);
+	}
+	vfree(mem);
+}
+
+static noinline void cwq_test_reg_work_is_not_throttled_by_memcg(void)
+{
+	struct cwq_data data;
+
+	if (!IS_ENABLED(CONFIG_MEMCG_KMEM) || !cwq_memcg_max)
+		return;
+
+	data.expected_cgroup = cwq_cgrp_root;
+	data.test_name = __func__;
+	INIT_WORK_ONSTACK(&data.cwork.work, cwq_verify_worker_obeys_memcg);
+	CWQ_BUG_ON(!queue_work(cwq_cgroup_unaware_wq, &data.cwork.work));
+	flush_work(&data.cwork.work);
+}
+
+static noinline void cwq_test_cgrp_work_is_throttled_by_memcg(void)
+{
+	struct cwq_data data;
+
+	if (!IS_ENABLED(CONFIG_MEMCG_KMEM) || !cwq_memcg_max)
+		return;
+
+	/*
+	 * The kselftest shell script enables the memory controller in
+	 * cwq_cgrp_2 and sets memory.max to cwq_memcg_max.
+	 */
+	data.expected_cgroup = cwq_cgrp_2;
+	data.test_name = __func__;
+	INIT_CGROUP_WORK_ONSTACK(&data.cwork, cwq_verify_worker_obeys_memcg);
+
+	CWQ_BUG_ON(!queue_cgroup_work(cwq_cgroup_aware_wq, &data.cwork,
+				      cwq_cgrp_2));
+	flush_work(&data.cwork.work);
+}
+
+static noinline void cwq_test_cgrp_work_is_not_throttled_by_memcg(void)
+{
+	struct cwq_data data;
+
+	if (!IS_ENABLED(CONFIG_MEMCG_KMEM) || !cwq_memcg_max)
+		return;
+
+	/*
+	 * The kselftest shell script doesn't set a memory limit for cwq_cgrp_1
+	 * or _3, so a cgroup work should still be able to allocate memory
+	 * above that limit.
+	 */
+	data.expected_cgroup = cwq_cgrp_1;
+	data.test_name = __func__;
+	INIT_CGROUP_WORK_ONSTACK(&data.cwork, cwq_verify_worker_obeys_memcg);
+
+	CWQ_BUG_ON(!queue_cgroup_work(cwq_cgroup_aware_wq, &data.cwork,
+				      cwq_cgrp_1));
+	flush_work(&data.cwork.work);
+
+	/*
+	 * And cgroup workqueues shouldn't choke on a cgroup that's disabled
+	 * the memory controller, such as cwq_cgrp_3.
+	 */
+	data.expected_cgroup = cwq_cgrp_3;
+	data.test_name = __func__;
+	INIT_CGROUP_WORK_ONSTACK(&data.cwork, cwq_verify_worker_obeys_memcg);
+
+	CWQ_BUG_ON(!queue_cgroup_work(cwq_cgroup_aware_wq, &data.cwork,
+				      cwq_cgrp_3));
+	flush_work(&data.cwork.work);
+}
+
+static int cwq_init(void)
+{
+	s64 passed, run;
+
+	pr_warn("cgroup workqueue test module\n");
+
+	cwq_cgroup_aware_wq = alloc_workqueue("cwq_cgroup_aware_wq",
+					      WQ_UNBOUND | WQ_CGROUP, 0);
+	if (!cwq_cgroup_aware_wq) {
+		pr_warn("cwq_cgroup_aware_wq allocation failed\n");
+		return -EAGAIN;
+	}
+
+	cwq_cgroup_unaware_wq = alloc_workqueue("cwq_cgroup_unaware_wq",
+						WQ_UNBOUND, 0);
+	if (!cwq_cgroup_unaware_wq) {
+		pr_warn("cwq_cgroup_unaware_wq allocation failed\n");
+		goto alloc_wq_fail;
+	}
+
+	cwq_cgrp_root = cgroup_get_from_path("/");
+	if (IS_ERR(cwq_cgrp_root)) {
+		pr_warn("can't get root cgroup\n");
+		goto cgroup_get_fail;
+	}
+
+	cwq_cgrp_1 = cgroup_get_from_path(cwq_cgrp_1_path);
+	if (IS_ERR(cwq_cgrp_1)) {
+		pr_warn("can't get child cgroup 1\n");
+		goto cgroup_get_fail;
+	}
+
+	cwq_cgrp_2 = cgroup_get_from_path(cwq_cgrp_2_path);
+	if (IS_ERR(cwq_cgrp_2)) {
+		pr_warn("can't get child cgroup 2\n");
+		goto cgroup_get_fail;
+	}
+
+	cwq_cgrp_3 = cgroup_get_from_path(cwq_cgrp_3_path);
+	if (IS_ERR(cwq_cgrp_3)) {
+		pr_warn("can't get child cgroup 3\n");
+		goto cgroup_get_fail;
+	}
+
+	cwq_test_reg_work_on_cgrp_unaware_wq();
+	cwq_test_cgrp_work_on_cgrp_aware_wq();
+	cwq_test_many_cgrp_works_on_cgrp_aware_wq();
+	cwq_test_reg_work_is_not_throttled_by_memcg();
+	cwq_test_cgrp_work_is_throttled_by_memcg();
+	cwq_test_cgrp_work_is_not_throttled_by_memcg();
+
+	passed = atomic_long_read(&cwq_tests_passed);
+	run    = atomic_long_read(&cwq_tests_run);
+	pr_warn("cgroup workqueues: %lld of %lld tests passed\n", passed, run);
+	return (run == passed) ? 0 : -EINVAL;
+
+cgroup_get_fail:
+	destroy_workqueue(cwq_cgroup_unaware_wq);
+alloc_wq_fail:
+	destroy_workqueue(cwq_cgroup_aware_wq);
+	return -EAGAIN;		/* better ideas? */
+}
+
+static void cwq_exit(void)
+{
+	destroy_workqueue(cwq_cgroup_aware_wq);
+	destroy_workqueue(cwq_cgroup_unaware_wq);
+}
+
+module_init(cwq_init);
+module_exit(cwq_exit);
+MODULE_AUTHOR("Daniel Jordan <daniel.m.jordan@oracle.com>");
+MODULE_LICENSE("GPL");
diff --git a/tools/testing/selftests/cgroup_workqueue/Makefile b/tools/testing/selftests/cgroup_workqueue/Makefile
new file mode 100644
index 000000000000..2ba1cd922670
--- /dev/null
+++ b/tools/testing/selftests/cgroup_workqueue/Makefile
@@ -0,0 +1,9 @@
+# SPDX-License-Identifier: GPL-2.0
+
+all:
+
+TEST_PROGS := test_cgroup_workqueue.sh
+
+include ../lib.mk
+
+clean:
diff --git a/tools/testing/selftests/cgroup_workqueue/config b/tools/testing/selftests/cgroup_workqueue/config
new file mode 100644
index 000000000000..ae38b8f3c3db
--- /dev/null
+++ b/tools/testing/selftests/cgroup_workqueue/config
@@ -0,0 +1 @@
+CONFIG_TEST_CGROUP_WQ=m
diff --git a/tools/testing/selftests/cgroup_workqueue/test_cgroup_workqueue.sh b/tools/testing/selftests/cgroup_workqueue/test_cgroup_workqueue.sh
new file mode 100755
index 000000000000..33251276d2cf
--- /dev/null
+++ b/tools/testing/selftests/cgroup_workqueue/test_cgroup_workqueue.sh
@@ -0,0 +1,104 @@
+#!/bin/sh
+# SPDX-License-Identifier: GPL-2.0
+# Runs cgroup workqueue kernel module tests
+
+# hierarchy:   root
+#             /    \
+#            1      2
+#           /
+#          3
+CG_ROOT='/test_cgroup_workqueue'
+CG_1='/cwq_1'
+CG_2='/cwq_2'
+CG_3='/cwq_3'
+MEMCG_MAX="$((2**16))"	# small but arbitrary amount
+
+# Kselftest framework requirement - SKIP code is 4.
+ksft_skip=4
+
+cg_mnt=''
+cg_mnt_mounted=''
+cg_1_created=''
+cg_2_created=''
+cg_3_created=''
+
+cleanup()
+{
+	[ -n "$cg_3_created" ]   && rmdir "$CG_ROOT/$CG_1/$CG_3" || exit 1
+	[ -n "$cg_2_created" ]   && rmdir "$CG_ROOT/$CG_2"       || exit 1
+	[ -n "$cg_1_created" ]   && rmdir "$CG_ROOT/$CG_1"       || exit 1
+	[ -n "$cg_mnt_mounted" ] && umount "$CG_ROOT"	         || exit 1
+	[ -n "$cg_mnt_created" ] && rmdir "$CG_ROOT"	         || exit 1
+	exit "$1"
+}
+
+if ! /sbin/modprobe -q -n test_cgroup_workqueue; then
+	echo "cgroup_workqueue: module test_cgroup_workqueue not found [SKIP]"
+	exit $ksft_skip
+fi
+
+# Setup cgroup v2 hierarchy
+if mkdir "$CG_ROOT"; then
+	cg_mnt_created=1
+else
+	echo "cgroup_workqueue: can't create cgroup mountpoint at $CG_ROOT"
+	cleanup 1
+fi
+
+if mount -t cgroup2 none "$CG_ROOT"; then
+	cg_mnt_mounted=1
+else
+	echo "cgroup_workqueue: couldn't mount cgroup hierarchy at $CG_ROOT"
+	cleanup 1
+fi
+
+if grep -q memory "$CG_ROOT/cgroup.controllers"; then
+	/bin/echo +memory > "$CG_ROOT/cgroup.subtree_control"
+	cwq_memcg_max="$MEMCG_MAX"
+else
+	# Tell test module not to run memory.max tests.
+	cwq_memcg_max=0
+fi
+
+if mkdir "$CG_ROOT/$CG_1"; then
+	cg_1_created=1
+else
+	echo "cgroup_workqueue: can't mkdir $CG_ROOT/$CG_1"
+	cleanup 1
+fi
+
+if mkdir "$CG_ROOT/$CG_2"; then
+	cg_2_created=1
+else
+	echo "cgroup_workqueue: can't mkdir $CG_ROOT/$CG_2"
+	cleanup 1
+fi
+
+if mkdir "$CG_ROOT/$CG_1/$CG_3"; then
+	cg_3_created=1
+	# Ensure the memory controller is disabled as expected in $CG_3's
+	# parent, $CG_1, for testing.
+	if grep -q memory "$CG_ROOT/$CG_1/cgroup.subtree_control"; then
+		/bin/echo -memory > "$CG_ROOT/$CG_1/cgroup.subtree_control"
+	fi
+else
+	echo "cgroup_workqueue: can't mkdir $CG_ROOT/$CG_1/$CG_3"
+	cleanup 1
+fi
+
+if (( cwq_memcg_max != 0 )); then
+	/bin/echo "$MEMCG_MAX" > "$CG_ROOT/$CG_2/memory.max"
+fi
+
+if /sbin/modprobe -q test_cgroup_workqueue cwq_cgrp_root_path="$CG_ROOT"       \
+					   cwq_cgrp_1_path="$CG_1"	       \
+					   cwq_cgrp_2_path="$CG_2"	       \
+					   cwq_cgrp_3_path="$CG_1/$CG_3"       \
+					   cwq_memcg_max="$cwq_memcg_max"; then
+	echo "cgroup_workqueue: ok"
+	/sbin/modprobe -q -r test_cgroup_workqueue
+	cleanup 0
+else
+	echo "cgroup_workqueue: [FAIL]"
+	cleanup 1
+fi
-- 
2.21.0

