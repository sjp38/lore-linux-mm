Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id EDBA16B0038
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 10:17:52 -0400 (EDT)
Received: by laah7 with SMTP id h7so15088503laa.0
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 07:17:52 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id yk6si7652972lbb.90.2015.07.24.07.17.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jul 2015 07:17:51 -0700 (PDT)
Date: Fri, 24 Jul 2015 17:17:26 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm v9 6/8] proc: add kpageidle file
Message-ID: <20150724141726.GE8100@esperanza>
References: <cover.1437303956.git.vdavydov@parallels.com>
 <d7a78b72053cf529c0c9ff6cbc02ffbb3d58fe35.1437303956.git.vdavydov@parallels.com>
 <CAP=VYLqiNfQJ6oyQg2GszeHwdOmeY_uD3XPvw=++weJOKdx4_g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <CAP=VYLqiNfQJ6oyQg2GszeHwdOmeY_uD3XPvw=++weJOKdx4_g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel
 Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel
 Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, LKML doc <linux-doc@vger.kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>

On Fri, Jul 24, 2015 at 10:08:25AM -0400, Paul Gortmaker wrote:

> fs/proc/page.c:341:4: error: implicit declaration of function
> 'pmdp_clear_young_notify' [-Werror=implicit-function-declaration]
> fs/proc/page.c:347:4: error: implicit declaration of function
> 'ptep_clear_young_notify' [-Werror=implicit-function-declaration]
> cc1: some warnings being treated as errors
> make[3]: *** [fs/proc/page.o] Error 1
> make[2]: *** [fs/proc] Error 2

My bad, sorry.

It's already been reported by the kbuild-test-robot, see

  [linux-next:master 3983/4215] fs/proc/page.c:332:4: error: implicit declaration of function 'pmdp_clear_young_notify'

The fix is:

From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH] mmu_notifier: add missing stubs for clear_young

This is a compilation fix for !CONFIG_MMU_NOTIFIER.

Fixes: mmu-notifier-add-clear_young-callback
Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index a5b17137c683..a1a210d59961 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -471,6 +471,8 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
 
 #define ptep_clear_flush_young_notify ptep_clear_flush_young
 #define pmdp_clear_flush_young_notify pmdp_clear_flush_young
+#define ptep_clear_young_notify ptep_test_and_clear_young
+#define pmdp_clear_young_notify pmdp_test_and_clear_young
 #define	ptep_clear_flush_notify ptep_clear_flush
 #define pmdp_huge_clear_flush_notify pmdp_huge_clear_flush
 #define pmdp_huge_get_and_clear_notify pmdp_huge_get_and_clear

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
