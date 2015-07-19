Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 7402E280367
	for <linux-mm@kvack.org>; Sun, 19 Jul 2015 08:32:50 -0400 (EDT)
Received: by pacan13 with SMTP id an13so87747069pac.1
        for <linux-mm@kvack.org>; Sun, 19 Jul 2015 05:32:50 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id x7si28603230par.193.2015.07.19.05.32.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Jul 2015 05:32:49 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v9 8/8] proc: add cond_resched to /proc/kpage* read/write loop
Date: Sun, 19 Jul 2015 15:31:17 +0300
Message-ID: <a13b8941bff79ac35d9e62c1f17c3ab82ea8c9a0.1437303956.git.vdavydov@parallels.com>
In-Reply-To: <cover.1437303956.git.vdavydov@parallels.com>
References: <cover.1437303956.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Reading/writing a /proc/kpage* file may take long on machines with a lot
of RAM installed.

Suggested-by: Andres Lagar-Cavilla <andreslc@google.com>
Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 fs/proc/page.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/fs/proc/page.c b/fs/proc/page.c
index 13dcb823fe4e..7ff7cba8617b 100644
--- a/fs/proc/page.c
+++ b/fs/proc/page.c
@@ -58,6 +58,8 @@ static ssize_t kpagecount_read(struct file *file, char __user *buf,
 		pfn++;
 		out++;
 		count -= KPMSIZE;
+
+		cond_resched();
 	}
 
 	*ppos += (char __user *)out - buf;
@@ -219,6 +221,8 @@ static ssize_t kpageflags_read(struct file *file, char __user *buf,
 		pfn++;
 		out++;
 		count -= KPMSIZE;
+
+		cond_resched();
 	}
 
 	*ppos += (char __user *)out - buf;
@@ -267,6 +271,8 @@ static ssize_t kpagecgroup_read(struct file *file, char __user *buf,
 		pfn++;
 		out++;
 		count -= KPMSIZE;
+
+		cond_resched();
 	}
 
 	*ppos += (char __user *)out - buf;
@@ -421,6 +427,7 @@ static ssize_t kpageidle_read(struct file *file, char __user *buf,
 			idle_bitmap = 0;
 			out++;
 		}
+		cond_resched();
 	}
 
 	*ppos += (char __user *)out - buf;
@@ -467,6 +474,7 @@ static ssize_t kpageidle_write(struct file *file, const char __user *buf,
 				put_page(page);
 			}
 		}
+		cond_resched();
 	}
 
 	*ppos += (const char __user *)in - buf;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
