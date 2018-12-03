Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id EFBCA6B6BB5
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 18:36:20 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id w18so15030463qts.8
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 15:36:20 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k18si4490752qtb.401.2018.12.03.15.36.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 15:36:20 -0800 (PST)
From: jglisse@redhat.com
Subject: [RFC PATCH 11/14] mm/hbind: add bind command to heterogeneous memory policy
Date: Mon,  3 Dec 2018 18:35:06 -0500
Message-Id: <20181203233509.20671-12-jglisse@redhat.com>
In-Reply-To: <20181203233509.20671-1-jglisse@redhat.com>
References: <20181203233509.20671-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, "Rafael J . Wysocki" <rafael@kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Haggai Eran <haggaie@mellanox.com>, Balbir Singh <balbirs@au1.ibm.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Felix Kuehling <felix.kuehling@amd.com>, Philip Yang <Philip.Yang@amd.com>, =?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Logan Gunthorpe <logang@deltatee.com>, John Hubbard <jhubbard@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Michal Hocko <mhocko@kernel.org>, Jonathan Cameron <jonathan.cameron@huawei.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Vivek Kini <vkini@nvidia.com>, Mel Gorman <mgorman@techsingularity.net>, Dave Airlie <airlied@redhat.com>, Ben Skeggs <bskeggs@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

From: Jérôme Glisse <jglisse@redhat.com>

This patch add bind command to hbind() ioctl, this allow to bind a
range of virtual address to given list of target memory. New memory
allocated in the range will try to use memory from the target memory
list.

Note that this patch does not modify existing page fault path and thus
does not activate new heterogeneous policy. Updating the CPU page fault
code path or device page fault code path (HMM) will be done in separate
patches.

Here we only introduce helpers and infrastructure that will be use by
page fault code path.

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Cc: Rafael J. Wysocki <rafael@kernel.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Haggai Eran <haggaie@mellanox.com>
Cc: Balbir Singh <balbirs@au1.ibm.com>
Cc: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Felix Kuehling <felix.kuehling@amd.com>
Cc: Philip Yang <Philip.Yang@amd.com>
Cc: Christian König <christian.koenig@amd.com>
Cc: Paul Blinzer <Paul.Blinzer@amd.com>
Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Jonathan Cameron <jonathan.cameron@huawei.com>
Cc: Mark Hairgrove <mhairgrove@nvidia.com>
Cc: Vivek Kini <vkini@nvidia.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Dave Airlie <airlied@redhat.com>
Cc: Ben Skeggs <bskeggs@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
---
 include/uapi/linux/hbind.h | 10 ++++++++++
 mm/hms.c                   | 40 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 50 insertions(+)

diff --git a/include/uapi/linux/hbind.h b/include/uapi/linux/hbind.h
index cc4687587f5a..7bb876954e3f 100644
--- a/include/uapi/linux/hbind.h
+++ b/include/uapi/linux/hbind.h
@@ -47,6 +47,16 @@ struct hbind_params {
  */
 #define HBIND_CMD_DEFAULT 0
 
+/*
+ * HBIND_CMD_BIND strict policy ie new allocations will comes from one of the
+ * listed targets until they run of memory. Other targets can be use if the
+ * none of the listed targets can be accessed by the initiator that did fault.
+ *
+ * Additional dwords:
+ *      NONE (DWORDS MUST BE 0 !)
+ */
+#define HBIND_CMD_BIND 1
+
 
 #define HBIND_IOCTL		_IOWR('H', 0x00, struct hbind_params)
 
diff --git a/mm/hms.c b/mm/hms.c
index be2c4e526f25..6be6f4acdd49 100644
--- a/mm/hms.c
+++ b/mm/hms.c
@@ -338,6 +338,36 @@ static struct hms_policy *hms_policy_get(struct mm_struct *mm)
 }
 
 
+static int hbind_bind(struct mm_struct *mm, struct hbind_params *params,
+		      const uint32_t *targets, uint32_t *atoms)
+{
+	struct hms_policy_range *prange;
+	struct hms_policy *hpolicy;
+	int ret;
+
+	hpolicy = hms_policy_get(mm);
+	if (hpolicy == NULL)
+		return -ENOMEM;
+
+	prange = hms_policy_range_new(targets, params->start, params->end,
+				      params->ntargets);
+	if (prange == NULL)
+		return -ENOMEM;
+
+	down_write(&hpolicy->sem);
+	ret = hbind_default_locked(hpolicy, params);
+	if (ret)
+		goto out;
+
+	interval_tree_insert(&prange->node, &hpolicy->ranges);
+
+out:
+	up_write(&hpolicy->sem);
+
+	return ret;
+}
+
+
 static long hbind_ioctl(struct file *file, unsigned cmd, unsigned long arg)
 {
 	uint32_t *targets, *_dtargets = NULL, _ftargets[HBIND_FIX_ARRAY];
@@ -418,6 +448,16 @@ static long hbind_ioctl(struct file *file, unsigned cmd, unsigned long arg)
 			if (ret)
 				goto out_mm;
 			break;
+		case HBIND_CMD_BIND:
+			if (ndwords != 1) {
+				ret = -EINVAL;
+				goto out_mm;
+			}
+			ret = hbind_bind(current->mm, &params,
+					 targets, atoms);
+			if (ret)
+				goto out_mm;
+			break;
 		default:
 			ret = -EINVAL;
 			goto out_mm;
-- 
2.17.2
