Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id E27316B003B
	for <linux-mm@kvack.org>; Tue, 13 May 2014 09:48:59 -0400 (EDT)
Received: by mail-la0-f42.google.com with SMTP id el20so299419lab.15
        for <linux-mm@kvack.org>; Tue, 13 May 2014 06:48:59 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id s2si7959243las.0.2014.05.13.06.48.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 May 2014 06:48:57 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH RFC 2/3] percpu-refcount: allow to get dead reference
Date: Tue, 13 May 2014 17:48:52 +0400
Message-ID: <52edf96a623197ed3c947dfa8b216ec0540d6460.1399982635.git.vdavydov@parallels.com>
In-Reply-To: <cover.1399982635.git.vdavydov@parallels.com>
References: <cover.1399982635.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@suse.cz, cl@linux-foundation.org
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Currently percpu_ref_tryget fails after percpu_ref_kill is called, even
if refcnt != 0. In the next patch I need a method to get a ref that will
only fail if refcnt == 0, so let's extend the interface to percpu ref a
bit to allow that.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/percpu-refcount.h |   11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/include/linux/percpu-refcount.h b/include/linux/percpu-refcount.h
index 95961f0bf62d..7729e59b9cb7 100644
--- a/include/linux/percpu-refcount.h
+++ b/include/linux/percpu-refcount.h
@@ -129,7 +129,8 @@ static inline void percpu_ref_get(struct percpu_ref *ref)
  * used.  After the confirm_kill callback is invoked, it's guaranteed that
  * no new reference will be given out by percpu_ref_tryget().
  */
-static inline bool percpu_ref_tryget(struct percpu_ref *ref)
+static inline bool __percpu_ref_tryget(struct percpu_ref *ref,
+				       bool maybe_dead)
 {
 	unsigned __percpu *pcpu_count;
 	int ret = false;
@@ -141,13 +142,19 @@ static inline bool percpu_ref_tryget(struct percpu_ref *ref)
 	if (likely(REF_STATUS(pcpu_count) == PCPU_REF_PTR)) {
 		__this_cpu_inc(*pcpu_count);
 		ret = true;
-	}
+	} else if (maybe_dead && unlikely(atomic_read(&ref->count)))
+		ret = atomic_inc_not_zero(&ref->count);
 
 	rcu_read_unlock_sched();
 
 	return ret;
 }
 
+static inline bool percpu_ref_tryget(struct percpu_ref *ref)
+{
+	return __percpu_ref_tryget(ref, false);
+}
+
 /**
  * percpu_ref_put - decrement a percpu refcount
  * @ref: percpu_ref to put
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
