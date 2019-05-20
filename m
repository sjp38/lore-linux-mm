Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE228C04AAC
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 21:40:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6DE2A2173C
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 21:40:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="lD66uZtM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6DE2A2173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D15DC6B0010; Mon, 20 May 2019 17:39:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CC6886B0266; Mon, 20 May 2019 17:39:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B8F3C6B0269; Mon, 20 May 2019 17:39:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 654F46B0010
	for <linux-mm@kvack.org>; Mon, 20 May 2019 17:39:58 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id r48so27230290eda.11
        for <linux-mm@kvack.org>; Mon, 20 May 2019 14:39:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=pWxZTOU32QqeCUWxSxBPbL225yVTtI+hlaFCbsgM9zc=;
        b=Ont+e2JtMPphcxXSXDTm3akk6OB03WWVbhkkS6MD0B0IIrUTa++jppEv0DNuwbWUjD
         i3ej6mSwmW/mBUzdI/TorYUXIzU/fqOqoV0f3SXM99fMDBG7mC/vGQcFRLHY5/emzNfF
         lgodj86frV/hF293BBneNjjMeedJdyUwb0gYh58w3QCzeAWRiIOWilBBLVFTgNdBxuGU
         uVGTzRJFMozKcqAIYgqOGa6SB1wOB+c4No9+EGxI64AG1rwyAxVNhPQlRZmWY+/7NNM+
         kCe9694skwLfL1tLrlKMMrOqNzJCKbx9WA538oQm8ZB612ZLazChcXrbMpjNJr7ICVhH
         mEhQ==
X-Gm-Message-State: APjAAAWq35klSY6aFDbC4VEgkuRQ5nEPCYaRCSbBgcmSRKrSiXmWcjjn
	bRMnJUlLl6zNNauM7vVXsYBOUaVHG+YZk1ioEEH1qfzDbg0DoQi+rKrx1eK61Ro0rOpm5FMigeR
	tlHM7beyMfaW3Y8YOrsVpNMo+4MvXm45wXeocHF1csVazEYF2mDVy2IADO0tgmDTRMg==
X-Received: by 2002:a17:907:20ed:: with SMTP id rh13mr42597593ejb.5.1558388397903;
        Mon, 20 May 2019 14:39:57 -0700 (PDT)
X-Received: by 2002:a17:907:20ed:: with SMTP id rh13mr42597544ejb.5.1558388397027;
        Mon, 20 May 2019 14:39:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558388397; cv=none;
        d=google.com; s=arc-20160816;
        b=lSns80R/YLfFSzwuSC/mdjoVFsUruvf2tezMZeY4lmb5T4tEwMpv/wshKULp/a5EB5
         h89rs49TGF+MYJuswjPf6SsIKJn4Vz5P0YUOWpwDP25AZ5eamp7cy2MrzaaIZMia33Mz
         H5JulKeMOnvOV18NUhdBwwT8P3Jst7QfraWwNEl1ZQ46lruYVY/HqOCZa+Qws2cUjUQ7
         kMehT1ExoYyow75s79tjhXNxWe7S9XsSL7aoPT/iSSdQ6Apu0yxCNd41vzp+I955jaoA
         mo+gUsWpn5QK4jLfptuAogspjw5jO1QVHc8wKr/9GgaoLGNac8p8EgdStAnMg9Jc3sQd
         XBRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=pWxZTOU32QqeCUWxSxBPbL225yVTtI+hlaFCbsgM9zc=;
        b=wgu5/tFGO8aOMHEpmysnj1n8Xohm3Tp8E4G0tlAlSkx1M8IpL62ThL7/Msgvr6dwrm
         VydSG1F0x896yu6hMU3ybMNAJWfoz7/xnyZ5R6SmxsdwKjHJ+Qrmysw+vdPeWPUDrK8M
         h+ZgdeNYc6I8jLN+8qdIOS76sDsVgLSzlgMUy2ijPUdjU17uLi7zB3a3TOsPruHJws/i
         qB6U4M4N+umpqtikR2j6GfYA08jD+QkkzkCP4YfxrpeIh3O+Fze2TvcbrM7L4O7jmEio
         +82ASVdH+wHW4ejU+QO0xqIRjS6IyECjFGP2YC4RsUkZvgYtapZpZ5b3o5CIca6CAaie
         nYJA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ffwll.ch header.s=google header.b=lD66uZtM;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel.vetter@ffwll.ch) smtp.mailfrom=daniel.vetter@ffwll.ch
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t11sor3084400ejq.55.2019.05.20.14.39.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 May 2019 14:39:57 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel.vetter@ffwll.ch) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ffwll.ch header.s=google header.b=lD66uZtM;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel.vetter@ffwll.ch) smtp.mailfrom=daniel.vetter@ffwll.ch
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=pWxZTOU32QqeCUWxSxBPbL225yVTtI+hlaFCbsgM9zc=;
        b=lD66uZtMoIMvvSsmt5W9Ap+FV3+sBqSE3BFc0cEJ684d/bm9E2HP1JXq7mSRH9YW4v
         nkbstF3kFQkxqWWqyv6BlV3/MFaD+qTRyQzGtP0efOBVs1Kb0ZlKW4eRerQFHNS9iDrt
         TmWczlsEj0ymWwKCv4nAMDK83tVqOnaVQm3Tg=
X-Google-Smtp-Source: APXvYqx80jEeRT18HZXVIF2BoTYuZwcSTE9+LxH0PFGQif7m2Gu96O3Mba57kRuyzhiZzeoU6L992A==
X-Received: by 2002:a17:906:5390:: with SMTP id g16mr53949638ejo.12.1558388396676;
        Mon, 20 May 2019 14:39:56 -0700 (PDT)
Received: from phenom.ffwll.local ([2a02:168:569e:0:3106:d637:d723:e855])
        by smtp.gmail.com with ESMTPSA id v27sm3285772eja.68.2019.05.20.14.39.55
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 14:39:56 -0700 (PDT)
From: Daniel Vetter <daniel.vetter@ffwll.ch>
To: DRI Development <dri-devel@lists.freedesktop.org>
Cc: Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Daniel Vetter <daniel.vetter@ffwll.ch>,
	Chris Wilson <chris@chris-wilson.co.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Rientjes <rientjes@google.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Michal Hocko <mhocko@suse.com>,
	=?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: [PATCH 4/4] mm, notifier: Add a lockdep map for invalidate_range_start
Date: Mon, 20 May 2019 23:39:45 +0200
Message-Id: <20190520213945.17046-4-daniel.vetter@ffwll.ch>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190520213945.17046-1-daniel.vetter@ffwll.ch>
References: <20190520213945.17046-1-daniel.vetter@ffwll.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is a similar idea to the fs_reclaim fake lockdep lock. It's
fairly easy to provoke a specific notifier to be run on a specific
range: Just prep it, and then munmap() it.

A bit harder, but still doable, is to provoke the mmu notifiers for
all the various callchains that might lead to them. But both at the
same time is really hard to reliable hit, especially when you want to
exercise paths like direct reclaim or compaction, where it's not
easy to control what exactly will be unmapped.

By introducing a lockdep map to tie them all together we allow lockdep
to see a lot more dependencies, without having to actually hit them
in a single challchain while testing.

Aside: Since I typed this to test i915 mmu notifiers I've only rolled
this out for the invaliate_range_start callback. If there's
interest, we should probably roll this out to all of them. But my
undestanding of core mm is seriously lacking, and I'm not clear on
whether we need a lockdep map for each callback, or whether some can
be shared.

v2: Use lock_map_acquire/release() like fs_reclaim, to avoid confusion
with this being a real mutex (Chris Wilson).

v3: Rebase on top of Glisse's arg rework.

Cc: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>
Cc: "Jérôme Glisse" <jglisse@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: "Christian König" <christian.koenig@amd.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org
Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>
---
 include/linux/mmu_notifier.h | 6 ++++++
 mm/mmu_notifier.c            | 7 +++++++
 2 files changed, 13 insertions(+)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index b6c004bd9f6a..9dd38c32fc53 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -42,6 +42,10 @@ enum mmu_notifier_event {
 
 #ifdef CONFIG_MMU_NOTIFIER
 
+#ifdef CONFIG_LOCKDEP
+extern struct lockdep_map __mmu_notifier_invalidate_range_start_map;
+#endif
+
 /*
  * The mmu notifier_mm structure is allocated and installed in
  * mm->mmu_notifier_mm inside the mm_take_all_locks() protected
@@ -310,10 +314,12 @@ static inline void mmu_notifier_change_pte(struct mm_struct *mm,
 static inline void
 mmu_notifier_invalidate_range_start(struct mmu_notifier_range *range)
 {
+	lock_map_acquire(&__mmu_notifier_invalidate_range_start_map);
 	if (mm_has_notifiers(range->mm)) {
 		range->flags |= MMU_NOTIFIER_RANGE_BLOCKABLE;
 		__mmu_notifier_invalidate_range_start(range);
 	}
+	lock_map_release(&__mmu_notifier_invalidate_range_start_map);
 }
 
 static inline int
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index a09e737711d5..33bdaddfb9b1 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -23,6 +23,13 @@
 /* global SRCU for all MMs */
 DEFINE_STATIC_SRCU(srcu);
 
+#ifdef CONFIG_LOCKDEP
+struct lockdep_map __mmu_notifier_invalidate_range_start_map = {
+	.name = "mmu_notifier_invalidate_range_start"
+};
+EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range_start_map);
+#endif
+
 /*
  * This function allows mmu_notifier::release callback to delay a call to
  * a function that will free appropriate resources. The function must be
-- 
2.20.1

