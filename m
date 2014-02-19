Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 918CB6B0031
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 17:14:45 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kp14so991153pab.6
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 14:14:45 -0800 (PST)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id po10si994405pab.218.2014.02.19.14.14.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 19 Feb 2014 14:14:44 -0800 (PST)
Received: by mail-pa0-f47.google.com with SMTP id kp14so989423pab.34
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 14:14:44 -0800 (PST)
Date: Wed, 19 Feb 2014 14:14:40 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] x86, kmemcheck: Use kstrtoint() instead of sscanf()
In-Reply-To: <alpine.DEB.2.02.1402182344001.3551@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.02.1402191412300.31921@chino.kir.corp.google.com>
References: <5304558F.9050605@huawei.com> <alpine.DEB.2.02.1402182344001.3551@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vegard Nossum <vegardno@ifi.uio.no>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>
Cc: Xishi Qiu <qiuxishi@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Kmemcheck should use the preferred interface for parsing command line 
arguments, kstrto*(), rather than sscanf() itself.  Use it appropriately.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 arch/x86/mm/kmemcheck/kmemcheck.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/arch/x86/mm/kmemcheck/kmemcheck.c b/arch/x86/mm/kmemcheck/kmemcheck.c
--- a/arch/x86/mm/kmemcheck/kmemcheck.c
+++ b/arch/x86/mm/kmemcheck/kmemcheck.c
@@ -78,10 +78,16 @@ early_initcall(kmemcheck_init);
  */
 static int __init param_kmemcheck(char *str)
 {
+	int val;
+	int ret;
+
 	if (!str)
 		return -EINVAL;
 
-	sscanf(str, "%d", &kmemcheck_enabled);
+	ret = kstrtoint(str, 0, &val);
+	if (ret)
+		return ret;
+	kmemcheck_enabled = val;
 	return 0;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
