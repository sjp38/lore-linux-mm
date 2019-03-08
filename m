Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84053C43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 04:15:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2481A20851
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 04:15:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="M17mSv40"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2481A20851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C66BC8E0010; Thu,  7 Mar 2019 23:15:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C3F6C8E0002; Thu,  7 Mar 2019 23:15:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B06EB8E0010; Thu,  7 Mar 2019 23:15:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 86D5E8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 23:15:49 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id 43so17313569qtz.8
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 20:15:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=q1Zg6VaVMDZOs2QFiRBrbBs3HOCPcZfoC+LWrWiAmJ0=;
        b=fDBB6MGo11A+/eRYcchQTwRYWcWXRtV46XpR9nlN8lZd9txcOiHN7sH/805WlYFVDJ
         oNveTY2Ew6U2UwG5e2G3OH7Xid4UIY1JukS1njjWfyF/1BHb5vm3rkerkR9Drr/UTr43
         E/a/zOe7HkGR6PLCiIpt6VTIyJ2t3+cpv9u8STVNN4sub8q06X9h7OAxRxk1YZgbhi1i
         EDn1Lxf1LjPsOEq0j/8BJeIFOoova5OcBaJ/KivAsSUnrmHZc1+MGhHcsrOLFunzNAs6
         BQPyoCWHRtuR9X5c0ELY36ajw6KlIVM3sxYRO6MZ/4JtlmteGA341WnbPnWzn+p6lln3
         BC8Q==
X-Gm-Message-State: APjAAAUVSuL5oyov3JixO7zXJdavaWkfKwQAVE+fjZEuxaVY1GBtcAdu
	lS9v6nn6Pc6n4oHATDOEjp9qSG/t5Zvq+OFu+mq15XOya9tCcZa81p8YLIUiBA0oYXpZ9lvYdQ7
	ugRDNQqI/24BFJiMdhB08AfApsmpj2jEHTr0lEUBgdL2tF7bjmUJhaaF3UQZBF7Y=
X-Received: by 2002:a37:d98f:: with SMTP id q15mr12572142qkl.213.1552018549283;
        Thu, 07 Mar 2019 20:15:49 -0800 (PST)
X-Google-Smtp-Source: APXvYqy++kFtQki+AF1V+RUsikoOzJ4YXKXnnVSZcsmSIZ1Wj449q4O39cwhbbfHB2Qtzf+bYNiE
X-Received: by 2002:a37:d98f:: with SMTP id q15mr12572061qkl.213.1552018547005;
        Thu, 07 Mar 2019 20:15:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552018547; cv=none;
        d=google.com; s=arc-20160816;
        b=wSZun/MCq3M/HwxD2/cxCtzZuUZ+WoRTaLpeK1Ssam1PmKuta/wNjl8s2NsxSGTcOG
         t8rdQvzQwPPL8fILAhr4BmQQXe0FGiP+Svh9JEAID0qbwh1fUyraZg8oIkY8Dv16k8wN
         5fRSI+fecB6hlUvOUKMP6Hxj8xIN/s/oQ9O5CAagc+kIliGd0f/fpSZbgPQiaxhzOB7b
         mAi8RAkoQM4pcaxUQzDOTYKK4oznJj2qoCXj4uH8hAmHjz66U9DEYBWowf8Vk8f/GFGA
         q5qyBiR/wtTN2hLhBobuHpFyAGbSEceoDnj2w3dWg6JK22VPYJk6tVr8ZpIH6mDFOmvg
         KuMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=q1Zg6VaVMDZOs2QFiRBrbBs3HOCPcZfoC+LWrWiAmJ0=;
        b=mnDji+3hrEkbne1IFk3kmpw+88Z4GlpXGjL2ueyLDSc5gdvBgJusDUKgmXEEybUgSN
         t7M/uEuPfV6UekXrD5zZ2q6tCFEp8NXWaZv7Q2qGVo1pqIP5suvzpnm3dAUc5dA6SVSC
         fZVqKc2yotq4U0mSER9DPoxrIY/rzXxFY526tmK5M0JHczTKASKMFpEm6YG+kmApMgyr
         qBOlgPYj8qJyafuVOaq6DjRmHeeaMl7oQ6tCXfnpQ/t84wFsRPTiQ2dUh6MN2JemWBr5
         6RiaMjAE8YkQJbbGcmUBOeP00AZjyqVdFdH4fllN+zgr2dXEu/0P8Y0jLuWaczkeZX46
         84HA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=M17mSv40;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id 1si4043749qvq.52.2019.03.07.20.15.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 20:15:46 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=M17mSv40;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id 88A6D36A8;
	Thu,  7 Mar 2019 23:15:45 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Thu, 07 Mar 2019 23:15:46 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=q1Zg6VaVMDZOs2QFiRBrbBs3HOCPcZfoC+LWrWiAmJ0=; b=M17mSv40
	saruX5/D4mmOPIOnA8AsVzCapGeV4Fd2E7o+A6pbEA2JFuM7OfnqnQpafoebY5ST
	uzw95LG3YSfvWRjFLgAp15/ehQa4/FCjlY41mxwBbjYRlKUj7dLCu5+i/9WK33sa
	C9OvhHIrr2RKr/dACPUwqmkPNUwXUq5f0zz5YpF/X4MJeFJWqSFAr8qCHUxqrPuc
	+i6MWzC1E8DmXNZFgfZsKPC02ZB/wDlBsGiGjlbmoEEl5CaAjrRJY/a0m6B8CaG7
	9hE4jImWiay2UuMbArxVgPOwlU0bwuHFWia7g7NuVxc3mVbDuH90CMi+f2H2X9DM
	Q7CABmLWI760Dw==
X-ME-Sender: <xms:ceyBXA-oHMymIvJ5kAAAv0MyxaLkSRgbnXBtQn5U9i53W5GJmEwufA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrfeelgdeifecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvgedrudeiledrhedrudehkeenucfrrghrrghmpehmrghilhhfrhhomhepthhosghi
    nheskhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgepuddv
X-ME-Proxy: <xmx:ceyBXMBM3ut_t3bMCAW11sP1Ww5dg7SYGBDv8R2dz0x7xIxsUSDdOw>
    <xmx:ceyBXB0cLV75saU1OvBg2anWTqxHHHbl2qirgXYo8nuSajEbV9IQ7g>
    <xmx:ceyBXDqwar-XtCr5MYIgC8-dsmDulq0Ms2tbt7F6kArL9ryejzrZdg>
    <xmx:ceyBXJnhcMNq1O14DQMg-xvuzXXtwzcAE2EG5SiWDnbkVQ5JsDc_9A>
Received: from eros.localdomain (124-169-5-158.dyn.iinet.net.au [124.169.5.158])
	by mail.messagingengine.com (Postfix) with ESMTPA id 3F6EFE4360;
	Thu,  7 Mar 2019 23:15:42 -0500 (EST)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Christopher Lameter <cl@linux.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Matthew Wilcox <willy@infradead.org>,
	Tycho Andersen <tycho@tycho.ws>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [RFC 13/15] tools/testing/slab: Add XArray movable objects tests
Date: Fri,  8 Mar 2019 15:14:24 +1100
Message-Id: <20190308041426.16654-14-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190308041426.16654-1-tobin@kernel.org>
References: <20190308041426.16654-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We just implemented movable objects for the XArray.  Let's test it
intree.

Add test module for the XArray's movable objects implementation.

Functionality of the XArray Slab Movable Object implementation can
usually be seen by simply by using `slabinfo` on a running machine since
the radix tree is typically in use on a running machine and will have
partial slabs.  For repeated testing we can use the test module to run
to simulate a workload on the XArray then use `slabinfo` to test object
migration is functioning.

If testing on freshly spun up VM (low radix tree workload) it may be
necessary to load/unload the module a number of times to create partial
slabs.

Example test session
--------------------

Relevant /proc/slabinfo column headers:

  name   <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab>

Prior to testing slabinfo report for radix_tree_node:

  # slabinfo radix_tree_node --report

  Slabcache: radix_tree_node  Aliases:  0 Order :  2 Objects: 8352
  ** Reclaim accounting active
  ** Defragmentation at 30%

  Sizes (bytes)     Slabs              Debug                Memory
  ------------------------------------------------------------------------
  Object :     576  Total  :     497   Sanity Checks : On   Total: 8142848
  SlabObj:     912  Full   :     473   Redzoning     : On   Used : 4810752
  SlabSiz:   16384  Partial:      24   Poisoning     : On   Loss : 3332096
  Loss   :     336  CpuSlab:       0   Tracking      : On   Lalig: 2806272
  Align  :       8  Objects:      17   Tracing       : Off  Lpadd:  437360

Here you can see the kernel was built with Slab Movable Objects enabled
for the XArray (XArray uses the radix tree below the surface).

After inserting the test module (note we have triggered allocation of a
number of radix tree nodes increasing the object count but decreasing the
number of partial slabs):

  # slabinfo radix_tree_node --report

  Slabcache: radix_tree_node  Aliases:  0 Order :  2 Objects: 8442
  ** Reclaim accounting active
  ** Defragmentation at 30%

  Sizes (bytes)     Slabs              Debug                Memory
  ------------------------------------------------------------------------
  Object :     576  Total  :     499   Sanity Checks : On   Total: 8175616
  SlabObj:     912  Full   :     484   Redzoning     : On   Used : 4862592
  SlabSiz:   16384  Partial:      15   Poisoning     : On   Loss : 3313024
  Loss   :     336  CpuSlab:       0   Tracking      : On   Lalig: 2836512
  Align  :       8  Objects:      17   Tracing       : Off  Lpadd:  439120

Now we can shrink the radix_tree_node cache:

  # slabinfo radix_tree_node --shrink
  # slabinfo radix_tree_node --report

  Slabcache: radix_tree_node  Aliases:  0 Order :  2 Objects: 8515
  ** Reclaim accounting active
  ** Defragmentation at 30%

  Sizes (bytes)     Slabs              Debug                Memory
  ------------------------------------------------------------------------
  Object :     576  Total  :     501   Sanity Checks : On   Total: 8208384
  SlabObj:     912  Full   :     500   Redzoning     : On   Used : 4904640
  SlabSiz:   16384  Partial:       1   Poisoning     : On   Loss : 3303744
  Loss   :     336  CpuSlab:       0   Tracking      : On   Lalig: 2861040
  Align  :       8  Objects:      17   Tracing       : Off  Lpadd:  440880

Note the single remaining partial slab.

Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 tools/testing/slab/Makefile             |   2 +-
 tools/testing/slab/slub_defrag_xarray.c | 211 ++++++++++++++++++++++++
 2 files changed, 212 insertions(+), 1 deletion(-)
 create mode 100644 tools/testing/slab/slub_defrag_xarray.c

diff --git a/tools/testing/slab/Makefile b/tools/testing/slab/Makefile
index 440c2e3e356f..44c18d9a4d52 100644
--- a/tools/testing/slab/Makefile
+++ b/tools/testing/slab/Makefile
@@ -1,4 +1,4 @@
-obj-m += slub_defrag.o
+obj-m += slub_defrag.o slub_defrag_xarray.o
 
 KTREE=../../..
 
diff --git a/tools/testing/slab/slub_defrag_xarray.c b/tools/testing/slab/slub_defrag_xarray.c
new file mode 100644
index 000000000000..06444a280820
--- /dev/null
+++ b/tools/testing/slab/slub_defrag_xarray.c
@@ -0,0 +1,211 @@
+// SPDX-License-Identifier: GPL-2.0+
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/slab.h>
+#include <linux/string.h>
+#include <linux/uaccess.h>
+#include <linux/list.h>
+#include <linux/gfp.h>
+#include <linux/xarray.h>
+
+#define SMOX_CACHE_NAME "smox_test"
+static struct kmem_cache *cachep;
+
+/*
+ * Declare XArrays globally so we can clean them up on module unload.
+ */
+
+/* Used by test_smo_xarray()*/
+DEFINE_XARRAY(things);
+
+/* Thing to store pointers to in the XArray */
+struct smox_thing {
+	long id;
+};
+
+/* It's up to the caller to ensure id is unique */
+static struct smox_thing *alloc_thing(int id)
+{
+	struct smox_thing *thing;
+
+	thing = kmem_cache_alloc(cachep, GFP_KERNEL);
+	if (!thing)
+		return ERR_PTR(-ENOMEM);
+
+	thing->id = id;
+	return thing;
+}
+
+/**
+ * smox_object_ctor() - SMO object constructor function.
+ * @ptr: Pointer to memory where the object should be constructed.
+ */
+void smox_object_ctor(void *ptr)
+{
+	struct smox_thing *thing = ptr;
+
+	thing->id = -1;
+}
+
+/**
+ * smox_cache_migrate() - kmem_cache migrate function.
+ * @cp: kmem_cache pointer.
+ * @objs: Array of pointers to objects to migrate.
+ * @size: Number of objects in @objs.
+ * @node: NUMA node where the object should be allocated.
+ * @private: Pointer returned by kmem_cache_isolate_func().
+ */
+void smox_cache_migrate(struct kmem_cache *cp, void **objs, int size,
+			int node, void *private)
+{
+	struct smox_thing **ptrs = (struct smox_thing **)objs;
+	struct smox_thing *old, *new;
+	struct smox_thing *thing;
+	unsigned long index;
+	void *entry;
+	int i;
+
+	for (i = 0; i < size; i++) {
+		old = ptrs[i];
+
+		new = kmem_cache_alloc(cachep, GFP_KERNEL);
+		if (!new) {
+			pr_debug("kmem_cache_alloc failded\n");
+			return;
+		}
+
+		new->id = old->id;
+
+		/* Update reference the brain dead way */
+		xa_for_each(&things, index, thing) {
+			if (thing == old) {
+				entry = xa_store(&things, index, new, GFP_KERNEL);
+				if (entry != old) {
+					pr_err("failed to exchange new/old\n");
+					return;
+				}
+			}
+		}
+		kmem_cache_free(cachep, old);
+	}
+}
+
+/*
+ * test_smo_xarray() - Run some tests using an XArray.
+ */
+static int test_smo_xarray(void)
+{
+	const int keep = 3; /* Free 4 out of 5 items */
+	const int nr_items = 10000;
+	struct smox_thing *thing;
+	unsigned long index;
+	void *entry;
+	int expected;
+	int i;
+
+	/*
+	 * Populate XArray, this adds to the radix_tree_node cache as
+	 * well as the smox_test cache.
+	 */
+	for (i = 0; i < nr_items; i++) {
+		thing = alloc_thing(i);
+		entry = xa_store(&things, i, thing, GFP_KERNEL);
+		if (xa_is_err(entry)) {
+			pr_err("smox: failed to allocate entry: %d\n", i);
+			return -ENOMEM;
+		}
+	}
+
+	/* Now free  items, putting holes in both caches */
+	for (i = 0; i < nr_items; i++) {
+		if (i % keep == 0)
+			continue;
+
+		thing = xa_erase(&things, i);
+		if (xa_is_err(thing))
+			pr_err("smox: error erasing entry: %d\n", i);
+		kmem_cache_free(cachep, thing);
+	}
+
+	expected = 0;
+	xa_for_each(&things, index, thing) {
+		if (thing->id != expected || index != expected) {
+			pr_err("smox: error; got %ld want %d at %ld\n",
+			       thing->id, expected, index);
+			return -1;
+		}
+		expected += keep;
+	}
+
+	/*
+	 * Leave caches sparsely allocated.  Shrink caches manually with:
+	 *
+	 *   slabinfo radix_tree_node -s
+	 *   slabinfo smox_test -s
+	 */
+
+	return 0;
+}
+
+static int __init smox_cache_init(void)
+{
+	cachep = kmem_cache_create(SMOX_CACHE_NAME,
+				   sizeof(struct smox_thing),
+				   0, 0, smox_object_ctor);
+	if (!cachep)
+		return -1;
+
+	return 0;
+}
+
+static void __exit smox_cache_cleanup(void)
+{
+	struct smox_thing *thing;
+	unsigned long i;
+
+	xa_for_each(&things, i, thing) {
+		kmem_cache_free(cachep, thing);
+	}
+	xa_destroy(&things);
+	kmem_cache_destroy(cachep);
+}
+
+static int __init smox_init(void)
+{
+	int ret;
+
+	ret = smox_cache_init();
+	if (ret) {
+		pr_err("smo_xarray: failed to create cache\n");
+		return ret;
+	}
+	pr_info("smo_xarray: created kmem_cache: %s\n", SMOX_CACHE_NAME);
+
+	kmem_cache_setup_mobility(cachep, NULL, smox_cache_migrate);
+	pr_info("smo_xarray: kmem_cache %s defrag enabled\n", SMOX_CACHE_NAME);
+
+	/*
+	 * Running this test consumes memory unless you shrink the
+	 * radix_tree_node cache manually with `slabinfo`.
+	 */
+	ret = test_smo_xarray();
+	if (ret)
+		pr_warn("test_smo_xarray failed: %d\n", ret);
+
+	pr_info("smo_xarray: module loaded successfully\n");
+	return 0;
+}
+module_init(smox_init);
+
+static void __exit smox_exit(void)
+{
+	smox_cache_cleanup();
+
+	pr_info("smo_xarray: module removed\n");
+}
+module_exit(smox_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Tobin C. Harding");
+MODULE_DESCRIPTION("SMO XArray test module.");
-- 
2.21.0

