Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27AFCC28CC1
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:18:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D78CB2727C
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:18:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="ZITyTHT3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D78CB2727C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 166046B0274; Sat,  1 Jun 2019 09:18:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B37A6B0276; Sat,  1 Jun 2019 09:18:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D855D6B0277; Sat,  1 Jun 2019 09:18:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9BED76B0274
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:18:01 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id k22so9582182pfg.18
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:18:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=imgOgzB3gh0zel0r6tFFQYNqyRNp+fdMEBXgRm4+Tec=;
        b=YSXtTZ3a2k+YSHqtXSg9QEb0OnaSr5XiJ+6gJc+/2fCvd4MldcEcbr5HJd8zPDKwT3
         YJJWBOTjXoOkIk4MDIphU9Pwc0Ux3KQaDx0HIBQx9WBN7V9ukV7ygdf6Xy76QUeK7dte
         zBZlXxC4WNukbaLvazmvQXrrwy1gF02QzdVl1Hc/fAlGyppD8bycJS4IWNRLKqPLJbwj
         +Rgz0fGXc0W4CzV+l0jpGZRm+8AW+z4o4C2eJJE4XzXqqqiGXM6id2cYlw5LVTTx9QLF
         hIh9PPIJPOyCqiHQ04+RY1ewZaR4pUKvL8kZqgoar46yYghXhLnas25y4WO9I5VGSNbq
         ZIQQ==
X-Gm-Message-State: APjAAAXv0MdpPrR7+AoJkGCiHEndrpVI58cT4mr/z65B8HWfm2pyflD0
	Pxf3Q954kpU+123wqqjwxowpUv4r9nZ5FZXnTG19Md0O4VAsXTi+Aju7M5Py2gBSRoX4sDt1ecw
	hmptPYA5VWaNR7rGProg96chG0xYZDeygGsSSGn3Uz//N4jaRI7KFC9l56oLk0oD/3Q==
X-Received: by 2002:a17:902:ca:: with SMTP id a68mr16637970pla.7.1559395081297;
        Sat, 01 Jun 2019 06:18:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzH0ZYXDKo3c+tW9UF24pqKRVGaRIsDGp6a7h8KFRevAc94GjovUSXM/eXrHeRn+IYBNZC3
X-Received: by 2002:a17:902:ca:: with SMTP id a68mr16637894pla.7.1559395080708;
        Sat, 01 Jun 2019 06:18:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395080; cv=none;
        d=google.com; s=arc-20160816;
        b=ma1u310X+b4dNIGTTBXv5vn3OdWTd75fTFHorTRXsnNrFueUldUVlf3ZJdcoc5c2Ex
         0ouZDNeZvn7kjcxzDAssa3UYO/pKIYQ1PoBKmttdU+PjqjMNyZxbSkyhaqVgXNPDCjMR
         XXyU/WzZw1J7uufeygklAVKrwEkcNUzPA7FdfiRZo6DCxw4Od+FNV1d9+DdjBMXGZ7OK
         fsSe5TVFYJPTf/WIdVv1bBnJklYXRNqe6jiRgNbwoh+eZXV+l5Gnk4znaeoK7r7JNmso
         BqRi4fz2KSmriYLouSdxhcSzoW2+zrHd8fPqMP6ORDwjwHufHI/YXVQBVS41VGelAtHB
         S1mg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=imgOgzB3gh0zel0r6tFFQYNqyRNp+fdMEBXgRm4+Tec=;
        b=L+RwUjB+uo1PwtgVHgXowoOZ0gHAT1hEm5Exi3Kg+ocZ7cEyybYRPtuzE1om0mCffY
         dAMy4O7XEPtVIvynxZr8+QpoM88P3HhuVlFzCHghmYIxJHOCvqRiQUh3zWbpOTotUPt4
         A5J5ZdUHSYNVZ8XVW65KRQFngX5T+k5HcwMpRWxT+fzsj+K+ZqYYgjm+k4mHxb3H+XtW
         50ATqYACKFzNEKih1ikqRpWW9OdZmjTp/zbxEDQn0GgLHtdIU87xHgAOf7ggQbKpZJc1
         ++sj9W5KkO9CkRsEXRRcnT6QqCrMfuH4TZYgJbPdSQfSf7kw9KnlidqJugpI/lgsuqLx
         k2IQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ZITyTHT3;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id t11si11004432pgp.153.2019.06.01.06.18.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:18:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ZITyTHT3;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 31B7A25525;
	Sat,  1 Jun 2019 13:17:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395080;
	bh=pfdp12GrVNS4lgDgj7qnuHhfc8Mbg/Z+a4ATWSH2Ma8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=ZITyTHT3YjgCc+MguocY9v264TCxqKaZjkFW8uD1fEm12ueXZC7MfMOM6X9qqtZbr
	 hXE9Ex3fH6RkWBUGYbsBx4l0o+xYnmWR61PCW70NLhHe/xh+K95yJE3yEMMqnwNVRX
	 ncm8zORC9eHWbRmx8Q6xPxnSGzBeOWTg31C9xvFI=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Qian Cai <cai@lca.pw>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.1 022/186] mm/slab.c: fix an infinite loop in leaks_show()
Date: Sat,  1 Jun 2019 09:13:58 -0400
Message-Id: <20190601131653.24205-22-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601131653.24205-1-sashal@kernel.org>
References: <20190601131653.24205-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Qian Cai <cai@lca.pw>

[ Upstream commit 745e10146c31b1c6ed3326286704ae251b17f663 ]

"cat /proc/slab_allocators" could hang forever on SMP machines with
kmemleak or object debugging enabled due to other CPUs running do_drain()
will keep making kmemleak_object or debug_objects_cache dirty and unable
to escape the first loop in leaks_show(),

do {
	set_store_user_clean(cachep);
	drain_cpu_caches(cachep);
	...

} while (!is_store_user_clean(cachep));

For example,

do_drain
  slabs_destroy
    slab_destroy
      kmem_cache_free
        __cache_free
          ___cache_free
            kmemleak_free_recursive
              delete_object_full
                __delete_object
                  put_object
                    free_object_rcu
                      kmem_cache_free
                        cache_free_debugcheck --> dirty kmemleak_object

One approach is to check cachep->name and skip both kmemleak_object and
debug_objects_cache in leaks_show().  The other is to set store_user_clean
after drain_cpu_caches() which leaves a small window between
drain_cpu_caches() and set_store_user_clean() where per-CPU caches could
be dirty again lead to slightly wrong information has been stored but
could also speed up things significantly which sounds like a good
compromise.  For example,

 # cat /proc/slab_allocators
 0m42.778s # 1st approach
 0m0.737s  # 2nd approach

[akpm@linux-foundation.org: tweak comment]
Link: http://lkml.kernel.org/r/20190411032635.10325-1-cai@lca.pw
Fixes: d31676dfde25 ("mm/slab: alternative implementation for DEBUG_SLAB_LEAK")
Signed-off-by: Qian Cai <cai@lca.pw>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/slab.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/slab.c b/mm/slab.c
index 9142ee9924932..fbbef79e1ad55 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4328,8 +4328,12 @@ static int leaks_show(struct seq_file *m, void *p)
 	 * whole processing.
 	 */
 	do {
-		set_store_user_clean(cachep);
 		drain_cpu_caches(cachep);
+		/*
+		 * drain_cpu_caches() could make kmemleak_object and
+		 * debug_objects_cache dirty, so reset afterwards.
+		 */
+		set_store_user_clean(cachep);
 
 		x[1] = 0;
 
-- 
2.20.1

