Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D36B8C10F14
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 01:37:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 87F23217F9
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 01:37:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="iznmAI5R"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 87F23217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 29C896B0271; Wed, 10 Apr 2019 21:37:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 24CCC6B0272; Wed, 10 Apr 2019 21:37:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1151E6B0273; Wed, 10 Apr 2019 21:37:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id E67E66B0271
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 21:37:35 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id f89so4160562qtb.4
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 18:37:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Tz/SWwtx1/b22exijoLQtrMgYyhU13VuaiIWZg1apv8=;
        b=s7wn7PpnIyqdEWAtSx2Euua0auS4CIzK4O5wCRpgORM3Gltu3hwxOptPZz/WTxeRFT
         LbjQUk2r1xFSJhq2hS2pA2ibf2OXzy4CPwE3DCKrJmv6xsLnXlEO2A0UA8UwYfX4+SkU
         Q4DkfIgBrVlOxY2g5atJIAnybacDE5XY23B5qc6Gm3jpdDDcrraL2DfC4y23uRriocPH
         ernM1UUigQTOjaX5J4X5HeEmgIFetSRMDmrs+WuaiNAPr4dfTOoggNs2HOSu+epRDDsP
         DcSwNhIQEweBZSYqTEtjyTYYb7Yo3y1Itq0/GjaFOrl75BtjViGZGZdW0f0OO/NMor5E
         MjTA==
X-Gm-Message-State: APjAAAXjYLn5YOP8LGLFDYRZkwp+5Mwhr7H1PvN3RTJCBkGMhTIDE6K1
	kpQMinXfX4RNt8c3cDh8TBLPTYdAiI+/TGvydjiCdEV19zH6I/bJuZf4wAsrbYg13TPQcjhCTWx
	1uBAR4xGhroq/VRiuz8CuTp7vigLg0QXJOt+YsQ8rwwdYY8IZ5Dyt4SHcMq8E4iM=
X-Received: by 2002:a37:a81:: with SMTP id 123mr36195740qkk.290.1554946655697;
        Wed, 10 Apr 2019 18:37:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyjpdIsq8oRPPkbSiht6mXgsMEkxBNS9QMsgO9yCSGT0yZHYeKBeEqPmH12R4sFZ4UOWltY
X-Received: by 2002:a37:a81:: with SMTP id 123mr36195683qkk.290.1554946654567;
        Wed, 10 Apr 2019 18:37:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554946654; cv=none;
        d=google.com; s=arc-20160816;
        b=h8ieYGMRE/HLuw7/BmBQup9QPIGde4Y1p4aqT/aTM2shxOwtWV+r6wijZdgs7dtmSX
         yVZ5RMv0vFPUEEeaNjV1WBbCGwBMTI/SiQdl82VoqqpaPOjB3CUGQt2CSN3qih9amAbv
         nJMr2uLF15uoI/8JXyvbtlLuc/BNVs49Eq59kwKQWDgD4p8/pOy/hq6hloZi5MrP8WSn
         JplVdDXplmW+eaMKRjDFlUanbYvRmkwI1rPWlfDAK3N8cEwfQg8j7YH15lwKnGFJ2wWP
         7FThcCHeVBT/KxklxZF3pppvgXqyyNlmB9qAMyhJdn81qTz9evujTP8s/V7MNJmZNgCo
         4ZJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Tz/SWwtx1/b22exijoLQtrMgYyhU13VuaiIWZg1apv8=;
        b=e0VsX8P18RkAF7aSHZeWwyMf2myP1jV+sqxOm2KnFl7hRvXhPpHliduSrv24QQ68u3
         Pkck50PkaGoCYBPboxv9Klxswb1P9jB55pnBnnGS655aKYC0PDyn3MKvW8BjWTh2MI5d
         XuMRoGk6SQajhlkDX7IpZQSBiQ3Jw71DWXOURkNSUJXoj1fvlyOlnpGEBpnB6sCYeWOj
         0+I2SVOS3T5TtefCz3uoFRI/SDZ6FwR2Fojt5L+SD1Wif5veqM51mER8SEQhFD3Vm+tX
         ZjaUo4Kjbg0XDmisFtUKWrj06XaMe8kgu4eBgbbRPv177nKlka/jiXqXE17BVxR0zVmg
         E/Cw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=iznmAI5R;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new4-smtp.messagingengine.com (new4-smtp.messagingengine.com. [66.111.4.230])
        by mx.google.com with ESMTPS id 58si1866447qtr.13.2019.04.10.18.37.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 18:37:34 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) client-ip=66.111.4.230;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=iznmAI5R;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id 42902E381;
	Wed, 10 Apr 2019 21:37:34 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Wed, 10 Apr 2019 21:37:34 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=Tz/SWwtx1/b22exijoLQtrMgYyhU13VuaiIWZg1apv8=; b=iznmAI5R
	H9ikZ/IxUJRwg4UQ92VO03JXfnlZj/iJfMtu17QXBLgQtDR+f3u8p8GbVAW4r4hH
	08v3gkNkv38cluYvTeXyzLFFXG0OzdiLGj3jlV2ZZ28XdENqLZ1JLLrhvmBQshH/
	5bM5YLEi3slnOVkF5xyu61ADUXeWqagDwbQfuOe8N/GS7Mvsj5JHnpG/tZHIAnVw
	8t2VvNfUEibKktEdhsSi0OyPGlKNIXP5jqluRhFYljLTi9ETNX655jayoAL5Pefo
	UMYCAIDzi8LbZgTnM8nsew0lwwBbvhg3w+andcwCcEpb/OflKCy+zQl5Qt5hMTEw
	bNhRvkWL8TzgdQ==
X-ME-Sender: <xms:XpquXLTfO_DCWnZoFxnJLHuFl1tkD_Z29m74o1SynRw0yxxkr-KNLg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrudekgdegvdcutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvgedrudejuddrudelrdduleegnecurfgrrhgrmhepmhgrihhlfhhrohhmpehtohgs
    ihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:XpquXKs_o7x4LvcYUIxG90FGXBLlOVDNw8V040LKW-i994uPuSVhTA>
    <xmx:XpquXDL_yu9XbCU6j23_CznDVFUBaMPcHUeaZd25EPia4RHWlG5vXA>
    <xmx:XpquXPnukGHvNVNQW4zc-G1tnIfwjpQwaBlUG-Iy-xsMX2FlLF-LmA>
    <xmx:XpquXOHR_FLICvEA9aNI3PGLWIa9jgwAcXPlr5PKB0HHsGfkUhB4Yg>
Received: from eros.localdomain (124-171-19-194.dyn.iinet.net.au [124.171.19.194])
	by mail.messagingengine.com (Postfix) with ESMTPA id 655DDE4332;
	Wed, 10 Apr 2019 21:37:26 -0400 (EDT)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Roman Gushchin <guro@fb.com>,
	Alexander Viro <viro@ftp.linux.org.uk>,
	Christoph Hellwig <hch@infradead.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Christopher Lameter <cl@linux.com>,
	Matthew Wilcox <willy@infradead.org>,
	Miklos Szeredi <mszeredi@redhat.com>,
	Andreas Dilger <adilger@dilger.ca>,
	Waiman Long <longman@redhat.com>,
	Tycho Andersen <tycho@tycho.ws>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Andi Kleen <ak@linux.intel.com>,
	David Chinner <david@fromorbit.com>,
	Nick Piggin <npiggin@gmail.com>,
	Rik van Riel <riel@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	Jonathan Corbet <corbet@lwn.net>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [RFC PATCH v3 14/15] dcache: Implement partial shrink via Slab Movable Objects
Date: Thu, 11 Apr 2019 11:34:40 +1000
Message-Id: <20190411013441.5415-15-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190411013441.5415-1-tobin@kernel.org>
References: <20190411013441.5415-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The dentry slab cache is susceptible to internal fragmentation.  Now
that we have Slab Movable Objects we can attempt to defragment the
dcache.  Dentry objects are inherently _not_ relocatable however under
some conditions they can be free'd.  This is the same as shrinking the
dcache but instead of shrinking the whole cache we only attempt to free
those objects that are located in partially full slab pages.  There is
no guarantee that this will reduce the memory usage of the system, it is
a compromise between fragmented memory and total cache shrinkage with
the hope that some memory pressure can be alleviated.

This is implemented using the newly added Slab Movable Objects
infrastructure.  The dcache 'migration' function is intentionally _not_
called 'd_migrate' because we only free, we do not migrate.  Call it
'd_partial_shrink' to make explicit that no reallocation is done.

Implement isolate and 'migrate' functions for the dentry slab cache.

Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 fs/dcache.c | 71 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 71 insertions(+)

diff --git a/fs/dcache.c b/fs/dcache.c
index 606cfca20d42..5c707ed9ab5a 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -30,6 +30,7 @@
 #include <linux/bit_spinlock.h>
 #include <linux/rculist_bl.h>
 #include <linux/list_lru.h>
+#include <linux/backing-dev.h>
 #include "internal.h"
 #include "mount.h"
 
@@ -3068,6 +3069,74 @@ void d_tmpfile(struct dentry *dentry, struct inode *inode)
 }
 EXPORT_SYMBOL(d_tmpfile);
 
+/*
+ * d_isolate() - Dentry isolation callback function.
+ * @s: The dentry cache.
+ * @v: Vector of pointers to the objects to isolate.
+ * @nr: Number of objects in @v.
+ *
+ * The slab allocator is holding off frees. We can safely examine
+ * the object without the danger of it vanishing from under us.
+ */
+static void *d_isolate(struct kmem_cache *s, void **v, int nr)
+{
+	struct dentry *dentry;
+	int i;
+
+	for (i = 0; i < nr; i++) {
+		dentry = v[i];
+		__dget(dentry);
+	}
+
+	return NULL;		/* No need for private data */
+}
+
+/*
+ * d_partial_shrink() - Dentry migration callback function.
+ * @s: The dentry cache.
+ * @v: Vector of pointers to the objects to migrate.
+ * @nr: Number of objects in @v.
+ * @node: The NUMA node where new object should be allocated.
+ * @private: Returned by d_isolate() (currently %NULL).
+ *
+ * Dentry objects _can not_ be relocated and shrinking the whole dcache
+ * can be expensive.  This is an effort to free dentry objects that are
+ * stopping slab pages from being free'd without clearing the whole dcache.
+ *
+ * This callback is called from the SLUB allocator object migration
+ * infrastructure in attempt to free up slab pages by freeing dentry
+ * objects from partially full slabs.
+ */
+static void d_partial_shrink(struct kmem_cache *s, void **v, int nr,
+		      int node, void *_unused)
+{
+	struct dentry *dentry;
+	LIST_HEAD(dispose);
+	int i;
+
+	for (i = 0; i < nr; i++) {
+		dentry = v[i];
+		spin_lock(&dentry->d_lock);
+		dentry->d_lockref.count--;
+
+		if (dentry->d_lockref.count > 0 ||
+		    dentry->d_flags & DCACHE_SHRINK_LIST) {
+			spin_unlock(&dentry->d_lock);
+			continue;
+		}
+
+		if (dentry->d_flags & DCACHE_LRU_LIST)
+			d_lru_del(dentry);
+
+		d_shrink_add(dentry, &dispose);
+
+		spin_unlock(&dentry->d_lock);
+	}
+
+	if (!list_empty(&dispose))
+		shrink_dentry_list(&dispose);
+}
+
 static __initdata unsigned long dhash_entries;
 static int __init set_dhash_entries(char *str)
 {
@@ -3113,6 +3182,8 @@ static void __init dcache_init(void)
 					   sizeof_field(struct dentry, d_iname),
 					   dcache_ctor);
 
+	kmem_cache_setup_mobility(dentry_cache, d_isolate, d_partial_shrink);
+
 	/* Hash may have been set up in dcache_init_early */
 	if (!hashdist)
 		return;
-- 
2.21.0

