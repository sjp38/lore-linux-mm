Return-Path: <SRS0=nlaJ=SI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7F64C282DA
	for <linux-mm@archiver.kernel.org>; Sat,  6 Apr 2019 18:35:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6FAF22171F
	for <linux-mm@archiver.kernel.org>; Sat,  6 Apr 2019 18:35:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="RPlXE6aP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6FAF22171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8603B6B000D; Sat,  6 Apr 2019 14:35:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E91D6B000E; Sat,  6 Apr 2019 14:35:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6AF966B0266; Sat,  6 Apr 2019 14:35:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 067016B000D
	for <linux-mm@kvack.org>; Sat,  6 Apr 2019 14:35:24 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id p82so2708989ljp.6
        for <linux-mm@kvack.org>; Sat, 06 Apr 2019 11:35:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=Cy3SM5r/wmKJF4gCdfrdBD/mCIoEWm9jyjb4iJPWDQY=;
        b=pqBEENHOYDNXDA28cJe80O0hY+S61QCyy6roE7jcfybcnJdsV8in0M+sQuwg++ewzy
         BWM6POZ7RrJnjnZi6MNCrtgPRHJtFa3oLV2/dUHDQcyoVIYch90S2T9EvTKuQreWWtgL
         hJcb5Qf1hcK50s+4NwmmBnnSBHQIF4sENKThZFCbc1v8I+dv6mDiNm7qmClJAYWVfYaS
         dOMYbwarpwrNlpLfZQu7NI+SJB3jnolfxFH4sowMNgOGdnP4aYPMo+sprJmbRCxfLqOz
         DBmPZgHrqf/mH+GIS06GHUQPYxz48WaSI6JoCtIYV2i1p4NtiMyOJNYVtSnNgSkKBeM5
         XYDg==
X-Gm-Message-State: APjAAAVosJZ5p2uyp3+G/wTaPqviwyfdAX6/vIAmozS5119pfpayCBv0
	93GnfIkgwFnGEdwNxnjlnFnHYqaILGv3+FC4Wphj3AL4p8pZwz/6VmG5NAD9bvfGnfp9/OO29uS
	MQ/3zLW/tl3YBfX6XMOppczYE2cK4y8KODFveVvfrAZOfktreInFm8xuOa1U9p74y5w==
X-Received: by 2002:a2e:8550:: with SMTP id u16mr4274842ljj.11.1554575723359;
        Sat, 06 Apr 2019 11:35:23 -0700 (PDT)
X-Received: by 2002:a2e:8550:: with SMTP id u16mr4274791ljj.11.1554575721788;
        Sat, 06 Apr 2019 11:35:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554575721; cv=none;
        d=google.com; s=arc-20160816;
        b=EfsKi9b198ACcrLLS5MqLHCvbpH7QmgXaKhgqNna39ivX7luy632sE9O7LR4cqJQpR
         UulNzWpplD7/I9u6zBoeCaHWh/Gc1Lx9zJY6hzjY5oOFQtG3NwWLcj81Ilkfciy7BEfj
         /aS3SBtQ1+bdE/PnNKQ/UWRUxvER4C3Ax6pjDGsrQttyg3H5HLJnyguZs8/Rcsr0DDKh
         P8ND8O8GIo6HJfQbz9HRYJuDe5Ro5LVZNVxapLwBO0Ag8NPRax8RmZ1K9dTKgOCawSo/
         5z6mGShANDi5qg+BvivxKGL8vW7fUQmhKoFutnbBqy5B7BHOHSZ/EzZTv966tk/fHzGY
         t+Gw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=Cy3SM5r/wmKJF4gCdfrdBD/mCIoEWm9jyjb4iJPWDQY=;
        b=dwd9GaiZ7Ki5+dUTKlcaSFjiL6SkPDUuVeSnIMmVTfigFFiAcnhC2WOVlH8f7foyU4
         D4oD++2nR4UHEUo/g3s18DhYq0hjcHZAGijN8pWIeemXZyW1ZK1ZLdT5G375rnBRffL3
         7T0iuSXXXAJF7b1QzqbZ0nZLFo6SEj+6Gl4a95VokbbDeLp8IABVICIO9Gm7tPr4LbhA
         Q/6qEDV3nZ6Mlo5JX4dLI8qY73BQwq0UbphIFmAKd0UwznE/LFO3PXzidS3DGbxePrmg
         dsvFNG8jqJCOWsHbWEURMmct5OBk7cPTqu8M1gjCdIjdB58EuhaKYkEHpF85pxgM70sn
         LrTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RPlXE6aP;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m23sor16503503ljh.32.2019.04.06.11.35.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 06 Apr 2019 11:35:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RPlXE6aP;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=Cy3SM5r/wmKJF4gCdfrdBD/mCIoEWm9jyjb4iJPWDQY=;
        b=RPlXE6aPcpZJlEWAL/EPm/scuOysXtYtIatbm0lcJBQwzQTgjYiBFaRYNjwfpnTwx8
         iOZJtE6hC1xvZYBi6jTfvOIiKyPCvo4OnroZn5/SH4BBJuEm2sSHgVty9X/oQgTIIXHX
         z2cZwqD7+4iSVTN2woRotummr5Rnyip5raPV3qVl7FNKy2h9zaRUJetO6lJIiutqN4Sm
         a6cVtcfW3t/FLFHYMYHr6WYKyqwV104LQ0/kvWuZp57WqemiRkggCbeUbMikPBZpt6YQ
         gQaY7yPaWizfBBAu5/QYHa0B9poa+Ck6nADEQtDU5g/c7P6VG63Ovm2YGS8W7jB+mZb8
         V3gw==
X-Google-Smtp-Source: APXvYqyCsbyKnf+glMe+Mx4ifka7UVeEPa6eRgpmdkqP4YZ01QGsgi5iAR2i2E+iMNqAXoap9K1a/w==
X-Received: by 2002:a2e:1245:: with SMTP id t66mr10862644lje.18.1554575721421;
        Sat, 06 Apr 2019 11:35:21 -0700 (PDT)
Received: from pc636.lan (h5ef52e31.seluork.dyn.perspektivbredband.net. [94.245.46.49])
        by smtp.gmail.com with ESMTPSA id m1sm5119622lfb.78.2019.04.06.11.35.19
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 06 Apr 2019 11:35:20 -0700 (PDT)
From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Joel Fernandes <joelaf@google.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>,
	"Uladzislau Rezki (Sony)" <urezki@gmail.com>
Subject: [PATCH v4 2/3] mm/vmap: add DEBUG_AUGMENT_PROPAGATE_CHECK macro
Date: Sat,  6 Apr 2019 20:35:07 +0200
Message-Id: <20190406183508.25273-3-urezki@gmail.com>
X-Mailer: git-send-email 2.11.0
In-Reply-To: <20190406183508.25273-1-urezki@gmail.com>
References: <20190406183508.25273-1-urezki@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This macro adds some debug code to check that the augment tree
is maintained correctly, meaning that every node contains valid
subtree_max_size value.

By default this option is set to 0 and not active. It requires
recompilation of the kernel to activate it. Set to 1, compile
the kernel.

Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
Reviewed-by: Roman Gushchin <guro@fb.com>
---
 mm/vmalloc.c | 48 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 48 insertions(+)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index c6f9d0637464..a74e605e042f 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -324,6 +324,8 @@ EXPORT_SYMBOL(vmalloc_to_pfn);
 
 /*** Global kva allocator ***/
 
+#define DEBUG_AUGMENT_PROPAGATE_CHECK 0
+
 #define VM_LAZY_FREE	0x02
 #define VM_VM_AREA	0x04
 
@@ -538,6 +540,48 @@ unlink_va(struct vmap_area *va, struct rb_root *root)
 	}
 }
 
+#if DEBUG_AUGMENT_PROPAGATE_CHECK
+static void
+augment_tree_propagate_check(struct rb_node *n)
+{
+	struct vmap_area *va;
+	struct rb_node *node;
+	unsigned long size;
+	bool found = false;
+
+	if (n == NULL)
+		return;
+
+	va = rb_entry(n, struct vmap_area, rb_node);
+	size = va->subtree_max_size;
+	node = n;
+
+	while (node) {
+		va = rb_entry(node, struct vmap_area, rb_node);
+
+		if (get_subtree_max_size(node->rb_left) == size) {
+			node = node->rb_left;
+		} else {
+			if (va_size(va) == size) {
+				found = true;
+				break;
+			}
+
+			node = node->rb_right;
+		}
+	}
+
+	if (!found) {
+		va = rb_entry(n, struct vmap_area, rb_node);
+		pr_emerg("tree is corrupted: %lu, %lu\n",
+			va_size(va), va->subtree_max_size);
+	}
+
+	augment_tree_propagate_check(n->rb_left);
+	augment_tree_propagate_check(n->rb_right);
+}
+#endif
+
 /*
  * This function populates subtree_max_size from bottom to upper
  * levels starting from VA point. The propagation must be done
@@ -587,6 +631,10 @@ augment_tree_propagate_from(struct vmap_area *va)
 		va->subtree_max_size = new_va_sub_max_size;
 		node = rb_parent(&va->rb_node);
 	}
+
+#if DEBUG_AUGMENT_PROPAGATE_CHECK
+	augment_tree_propagate_check(free_vmap_area_root.rb_node);
+#endif
 }
 
 static void
-- 
2.11.0

