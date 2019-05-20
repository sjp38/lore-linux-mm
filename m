Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 36C15C04AAF
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 05:42:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D509F206B6
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 05:42:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="FP1+azQc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D509F206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 81AEB6B026A; Mon, 20 May 2019 01:42:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7CC126B026B; Mon, 20 May 2019 01:42:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 66C416B026C; Mon, 20 May 2019 01:42:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 491FE6B026A
	for <linux-mm@kvack.org>; Mon, 20 May 2019 01:42:32 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id w6so11802909qki.5
        for <linux-mm@kvack.org>; Sun, 19 May 2019 22:42:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=K23AG6kPeiLizgBxJZXoFVpxoNhX/Z2JwBtP24yd/wE=;
        b=HD+sjwMUXOsqB4lfcGjhKGGmBMq8bu2bkOc7CnZ0HxV+7V3EbpADtKP+5zeVS9/PB8
         7pOpXnS7Iymec1qM6X4OA/jGI7L+RnVqUQbKKhkkFggxOIYbXnMJfQo5zulOOILEqSz/
         5jyxtFg74UQsebB4T65/WTaRmM32P0iD5XWgiCDpi6SGTXA3SVjiP9NcN2D1dnCoMP1N
         ZUza6DBMfCvpIQ1r7leQ1qq73ujQgxqOrj97Z5D5BfK8aLDVxsq061AgtBX7MesshwGB
         +BHFsQ0N5ADxFqCcg+ud8aV3azuZMxaG1xz6Af85bFOJVrpPQFMZ4T8Ru4yJnJxw8wvc
         tixg==
X-Gm-Message-State: APjAAAXJb5WHlzITUX/rKPHVbIAPlkNHoTP5lkiIbOq0VHAUV+lO4Rkq
	2BdonBh0pMtzgb918+eKI2AxxSO1Fg0Nv987P3aXvZEHBaxLNmbKVDiupZ3TAP5kLnqC0JPDskZ
	H96zRzAfcoPOqMalqLyutc2UFKRgC5qhd6WwEo+7inLPn7IXwPktktuFfa4DRgA0=
X-Received: by 2002:a05:620a:15ac:: with SMTP id f12mr46486396qkk.311.1558330951977;
        Sun, 19 May 2019 22:42:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxEXBG+TWgHZ1EkUcp06hRcIpSB9ZPepzeOJTR8cjrkrLhnjkXTWk0lLWu8DbAuIA4AtUrp
X-Received: by 2002:a05:620a:15ac:: with SMTP id f12mr46486336qkk.311.1558330950508;
        Sun, 19 May 2019 22:42:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558330950; cv=none;
        d=google.com; s=arc-20160816;
        b=ias7/N0V7835fOkLi38d8m0jozG1++fI5Nababsf7VOwjqKFJeDVQAwDnjGS+H83vx
         FWNK3dTLDa9KbICJqRyh7dlZfeQjUswwQ/Cvj/q9D4Z5XTv9Vzp91jlCzicinCrPuIsV
         O45NI0lq/pZ0qdKUTTiTH5Hdxyr3xFblSdNAiLEd749IJpZsTQmd2hJDnkUQz1kEv36h
         ICgW5DgPZmLJWROH9GySIu9jeq8RSNQzrtXFIsv3PdHGjpuRBugX4NuwZENOLxjufKF5
         hNcO5XuQCXb+jPQ5Fxa0SCUmaDcUnrf5zbQnvkOQ1O38RPRw5py3Wz3luwVbWg049shL
         VHPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=K23AG6kPeiLizgBxJZXoFVpxoNhX/Z2JwBtP24yd/wE=;
        b=Kh/xkqi280Y0pOqplTFUstR8Jesc5ScJN0sr32zOIZxUkTJfl/5nhVPm3X6ynS9xny
         H0mDdlWjtlC3Dd6z94fe7symFGMD9H/JFdZ/SK1nW5UXV8VRkeiP7xcgA5Wbx7tHZE8W
         ogK66LvGrOjoZEH3II9q6mpsmkkcHlIP7kAs2mTacu6psyqklru5YlK1f8LT7/R+OEkZ
         WcOVlq9mnNoQ//0tex39e+KE9Gyhq4ef5lype0LLSZfLqVMvAfcMVCo4/ls/UqDNAx0X
         p2OJdvcZVBX+hS1CyYyC1wS+4oFmW0G0ulEc5RNSvy10uOq65hY0oTc9yAIsKnja4jIl
         BDiQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=FP1+azQc;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new4-smtp.messagingengine.com (new4-smtp.messagingengine.com. [66.111.4.230])
        by mx.google.com with ESMTPS id l58si10420483qvc.215.2019.05.19.22.42.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 May 2019 22:42:30 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) client-ip=66.111.4.230;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=FP1+azQc;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id 3DB96D210;
	Mon, 20 May 2019 01:42:30 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Mon, 20 May 2019 01:42:30 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=K23AG6kPeiLizgBxJZXoFVpxoNhX/Z2JwBtP24yd/wE=; b=FP1+azQc
	rQo9GjVhupZBKSw2zglCLDgHlLDuQoAd2mhHz9NO4RMZnIck3CtwAzP/p0ddUgtn
	VuJd5rvuTRdb8D8ThKHXrNgTgMt0nG032738vlqt4bUylqfMz6CkhRHYHXIfgwSn
	6NYAtjYgYyh0940MzBe8khndc1V4L8T3xeYYdt/gRW8Nb30ZlmwDTZT/JnLdDZI0
	Ij+teHPg39csT2Osu1f114zoyoguVS18FbF+3qdM7IuPI3GFc3s6s7+uov0gHyCs
	ePW1AzP7C1mZyxIycSvVCr/fH4oC0ieZ9WULZkNjbWWKMqqJa6JrWCmn011VVuVX
	caINSxyKVfQeXA==
X-ME-Sender: <xms:RT7iXC2InbPmzyuA9REKLFAK1bCKQ4LqYmvI2I0T6vSHQutp0LFt6A>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddruddtjedguddtudcutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfgh
    necuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmd
    enucfjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgs
    ihhnucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenuc
    fkphepuddvgedrudeiledrudehiedrvddtfeenucfrrghrrghmpehmrghilhhfrhhomhep
    thhosghinheskhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgepuddt
X-ME-Proxy: <xmx:Rj7iXFRfMMbSmAHEzmwwGpVv2lXNpOK70SQPWbwAg8s4DDeh1ZhQRQ>
    <xmx:Rj7iXMtXiLkB9_OP7b0zNaIImi-BNC6QeNzWj_5qBAzz3V7CkSLyaA>
    <xmx:Rj7iXCZB2GCalL1ts1d4kX482fYP3CniVdjnjIbOzmH8ck4xukBRIA>
    <xmx:Rj7iXAMDvvpYf6PEZYXhKKdRjRq2yvF2U4dQy6orwT4-g6VwLEvLqg>
Received: from eros.localdomain (124-169-156-203.dyn.iinet.net.au [124.169.156.203])
	by mail.messagingengine.com (Postfix) with ESMTPA id 22A3580060;
	Mon, 20 May 2019 01:42:22 -0400 (EDT)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <willy@infradead.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Roman Gushchin <guro@fb.com>,
	Alexander Viro <viro@ftp.linux.org.uk>,
	Christoph Hellwig <hch@infradead.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Christopher Lameter <cl@linux.com>,
	Miklos Szeredi <mszeredi@redhat.com>,
	Andreas Dilger <adilger@dilger.ca>,
	Waiman Long <longman@redhat.com>,
	Tycho Andersen <tycho@tycho.ws>,
	Theodore Ts'o <tytso@mit.edu>,
	Andi Kleen <ak@linux.intel.com>,
	David Chinner <david@fromorbit.com>,
	Nick Piggin <npiggin@gmail.com>,
	Rik van Riel <riel@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	Jonathan Corbet <corbet@lwn.net>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [RFC PATCH v5 11/16] tools/testing/slab: Add XArray movable objects tests
Date: Mon, 20 May 2019 15:40:12 +1000
Message-Id: <20190520054017.32299-12-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190520054017.32299-1-tobin@kernel.org>
References: <20190520054017.32299-1-tobin@kernel.org>
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
index 000000000000..41143f73256c
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
+			pr_debug("kmem_cache_alloc failed\n");
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
+	const int keep = 6; /* Free 5 out of 6 items */
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
+	/* Now free  items, putting holes in both caches. */
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
+	 *   slabinfo radix_tree_node --shrink
+	 *   slabinfo smox_test --shrink
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

