Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2C1AA8E0001
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 13:10:08 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id d20so13641087iom.0
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 10:10:08 -0800 (PST)
Received: from mta-p5.oit.umn.edu (mta-p5.oit.umn.edu. [134.84.196.205])
        by mx.google.com with ESMTPS id h9si7219145iom.72.2018.12.26.10.10.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 10:10:06 -0800 (PST)
Received: from localhost (unknown [127.0.0.1])
	by mta-p5.oit.umn.edu (Postfix) with ESMTP id 8A7C178
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 18:10:06 +0000 (UTC)
Received: from mta-p5.oit.umn.edu ([127.0.0.1])
	by localhost (mta-p5.oit.umn.edu [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id IFzsRNzLvc6m for <linux-mm@kvack.org>;
	Wed, 26 Dec 2018 12:10:06 -0600 (CST)
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mta-p5.oit.umn.edu (Postfix) with ESMTPS id 5EDD869
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 12:10:06 -0600 (CST)
Received: by mail-it1-f200.google.com with SMTP id p66so19153534itc.0
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 10:10:06 -0800 (PST)
From: Aditya Pakki <pakki001@umn.edu>
Subject: [PATCH] hmm: Warn on devres_release failure
Date: Wed, 26 Dec 2018 12:09:04 -0600
Message-Id: <20181226180904.8193-1-pakki001@umn.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: pakki001@umn.edu
Cc: kjlu@umn.edu, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

devres_release can return -ENOENT if the device is not freed. The fix
throws a warning consistent with other invocations.

Signed-off-by: Aditya Pakki <pakki001@umn.edu>
---
 mm/hmm.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 90c34f3d1243..b06e3f092fbf 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -1183,8 +1183,12 @@ static int hmm_devmem_match(struct device *dev, void *data, void *match_data)
 
 static void hmm_devmem_pages_remove(struct hmm_devmem *devmem)
 {
-	devres_release(devmem->device, &hmm_devmem_release,
-		       &hmm_devmem_match, devmem->resource);
+	int rc;
+
+	rc = devres_release(devmem->device, &hmm_devmem_release,
+				&hmm_devmem_match, devmem->resource);
+	if (rc)
+		WARN_ON(rc);
 }
 
 /*
-- 
2.17.1
