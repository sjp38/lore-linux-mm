Return-Path: <SRS0=x6gJ=VS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C2B3C76196
	for <linux-mm@archiver.kernel.org>; Sun, 21 Jul 2019 14:29:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D819C20823
	for <linux-mm@archiver.kernel.org>; Sun, 21 Jul 2019 14:29:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="A/dM8JvS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D819C20823
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 74CDC8E000D; Sun, 21 Jul 2019 10:29:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6FE3C8E0005; Sun, 21 Jul 2019 10:29:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 613458E000D; Sun, 21 Jul 2019 10:29:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2A2CE8E0005
	for <linux-mm@kvack.org>; Sun, 21 Jul 2019 10:29:36 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id b18so21899249pgg.8
        for <linux-mm@kvack.org>; Sun, 21 Jul 2019 07:29:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=yHWPM2A483B1PZNTU1st8pnTTNAs2xN+6BFUgiVJMFo=;
        b=bZBQ6ABAkc6y1NtaBwTSyxlguIlv0aBkJGan2OAaO9VHYulvPpA5M++J+b6zIn4FfT
         piKWYUdvfFwd7mNdg8OZ/bRAeQzOzUN8rTJc96rQD3m02fKSBRBF6LkYcIZ0XPbuT5Xq
         9gewHISRpj8eugQHswoxvvygmQklADfDskwsRvfAJR8kRFQkSsblZOtNZSJZk1pCGOqs
         OwtKTINxcv414d4AysbDvOO0sLd08uo9cYlmjjUn7M0i5Dualt8GhLej+NhYwjDP7D1r
         Dwph1wNno+n5nB1oActKnNLu6vlEjoORQY6nFGbjnyEm0VfW3lIqEVvtIG8owE80S0LE
         bqsQ==
X-Gm-Message-State: APjAAAUYLujUFdePtaTrELnSus7hYVdET4Z2s7pVI/dMA5hHZu9czFpi
	AV6OpBBcYlfRzc3LdxeUExn1lkuxQJAPaWTZapwCVE6WhV5BwjOp7ma//vIMKusV3xPG9WQdLK9
	g+LNjCW8wLOol6oqzVTTAfL6GeXYjk/LvY5LOriox9v75PoMqiqinbztRGjRABu9g9A==
X-Received: by 2002:a65:6552:: with SMTP id a18mr57038105pgw.208.1563719375558;
        Sun, 21 Jul 2019 07:29:35 -0700 (PDT)
X-Received: by 2002:a65:6552:: with SMTP id a18mr57038018pgw.208.1563719374317;
        Sun, 21 Jul 2019 07:29:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563719374; cv=none;
        d=google.com; s=arc-20160816;
        b=mlyQ+jQEGtT0OZzkUq1TuGjelynLJ6bqUXItYve/FKw28hDOZhPiQa58dDRx1Wj7M2
         U7hjKXarJ5AqTsIG8dmySZ8rCr5pGM3twBMW8KsEdfC5QlVeA/LgvFyAXQinsyOMwKMi
         SX7iK1daFiF55ihOdUdTh7lU6Mu5wf72pbz0vi2GhwWh7fUjM03hnMeLpszYtS8p9wiA
         mvGN2LY0URjUF9xYTBqBRwos4m9K0uXVvIZiYvJDjMWIRJcZSrmtnMjfohyTKXo09g8E
         uz500oOKOcX10LOeg1lHsjUo1vTOO2179WS8Oo0PndlXSkuN6pZbthm00/B97pVbkhei
         inbw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=yHWPM2A483B1PZNTU1st8pnTTNAs2xN+6BFUgiVJMFo=;
        b=K+MeYHBHrjobhdq6wE7sUePuoCGe7M/nWaLbrB4wsoBAsfsGmFdnLkkhT0MJK9ZJ6g
         EBP6N1Qu2SjtxGqtj8+6vFR68V+mhJJDVbJdZWJ9EjtKC6koZuEuvFf0gXlJv8aKCu9A
         BZZFy7qQESyQmoiSB2f5PVBhwhn7kyb0QONgB86JaJeY9fl3gawFohUaUlZRaB5XDHen
         bkLLYJWni28THndSlNBn6pdGYM/+0KU0emP6zosUyWSc2la78cS3OJT6xNlGGoVkZSGm
         F67628irO/AHGehztvOzd/ka+WX5yEX6ywsROSGrCqK7IKup28RBd0268NyY6j7O9BH3
         C3OA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="A/dM8JvS";
       spf=pass (google.com: domain of sergey.senozhatsky@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sergey.senozhatsky@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v138sor19699092pfc.40.2019.07.21.07.29.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 21 Jul 2019 07:29:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of sergey.senozhatsky@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="A/dM8JvS";
       spf=pass (google.com: domain of sergey.senozhatsky@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sergey.senozhatsky@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=yHWPM2A483B1PZNTU1st8pnTTNAs2xN+6BFUgiVJMFo=;
        b=A/dM8JvSApyy0k2jvqWLMGfriCPKzB08cruBW99KLNKiKTAghXcZHNG33tD6/5fIrL
         TJx99kczxZfm2Y3Bd9eRykoMlCkxEKTyw4S9nAsQoSEgYGy47zlWzVa/8mtROXUXYNld
         fK/1iVE2Qqbb9db8cHw/9GiBg9JHAhXlrH4DU9IsjTcepZgAr47Z1Qk4GohtQAbbwTI6
         WLjxPNKrfU9E9RNUYuhk9/j343Ur1Q36lnrtwEtj5Je17F6AXTACPBPHjT9kcrXcz4IG
         dtnxEWfOZeVlYwtj/Kbc7LAAgAvfw38MkDGFF26gBGbyPyt/BPwlUeh7TYhi+tlCx226
         ZstA==
X-Google-Smtp-Source: APXvYqzJ70me8/YjG3iag5xCr5rToFb+3rKTVc2TFFdtKiTWAwKoD3L82P9u1aIVc3eW5aPZcOgdXg==
X-Received: by 2002:a63:e20a:: with SMTP id q10mr65587674pgh.24.1563719373649;
        Sun, 21 Jul 2019 07:29:33 -0700 (PDT)
Received: from localhost ([121.137.63.184])
        by smtp.gmail.com with ESMTPSA id t9sm3493825pgj.89.2019.07.21.07.29.32
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 21 Jul 2019 07:29:32 -0700 (PDT)
Date: Sun, 21 Jul 2019 23:29:30 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
To: Jani Nikula <jani.nikula@linux.intel.com>,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>,
	David Airlie <airlied@linux.ie>, Daniel Vetter <daniel@ffwll.ch>,
	Hugh Dickins <hughd@google.com>,
	David Howells <dhowells@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	intel-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [linux-next] mm/i915: i915_gemfs_init() NULL dereference
Message-ID: <20190721142930.GA480@tigerII.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

My laptop oopses early on with nothing on the screen;
after some debugging I managed to obtain a backtrace:

 BUG: kernel NULL pointer dereference, address: 0000000000000000
 #PF: supervisor instruction fetch in kernel mode
 #PF: error_code(0x0010) - not-present page
 PGD 0 P4D 0 
 Oops: 0010 [#1] PREEMPT SMP PTI
 RIP: 0010:0x0
 Code: Bad RIP value.
 [..]
 Call Trace:
  i915_gemfs_init+0x6e/0xa0 [i915]
  i915_gem_init_early+0x76/0x90 [i915]
  i915_driver_probe+0x30a/0x1640 [i915]
  ? kernfs_activate+0x5a/0x80
  ? kernfs_add_one+0xdd/0x130
  pci_device_probe+0x9e/0x110
  really_probe+0xce/0x230
  driver_probe_device+0x4b/0xc0
  device_driver_attach+0x4e/0x60
  __driver_attach+0x47/0xb0
  ? device_driver_attach+0x60/0x60
  bus_for_each_dev+0x61/0x90
  bus_add_driver+0x167/0x1b0
  driver_register+0x67/0xaa
  ? 0xffffffffc0522000
  do_one_initcall+0x37/0x13f
  ? kmem_cache_alloc+0x11a/0x150
  do_init_module+0x51/0x200
  __se_sys_init_module+0xef/0x100
  do_syscall_64+0x49/0x250
  entry_SYSCALL_64_after_hwframe+0x44/0xa9

RIP is at 0x00, which is never good

It sort of boils down to commit 144df3b288c4 (vfs: Convert ramfs,
shmem, tmpfs, devtmpfs, rootfs to use the new mount API), which
removed ->remount_fs from tmpfs' ops:

===
@@ -3736,7 +3849,6 @@ static const struct super_operations shmem_ops = {
        .destroy_inode  = shmem_destroy_inode,
 #ifdef CONFIG_TMPFS
        .statfs         = shmem_statfs,
-       .remount_fs     = shmem_remount_fs,
        .show_options   = shmem_show_options,
 #endif
        .evict_inode    = shmem_evict_inode,
===

So i915 init executes NULL

	get_fs_type("tmpfs");
	sb->s_op->remount_fs(sb, &flags, options);

For the time being the following (obvious and wrong) patch
at least boots -next:

---

diff --git a/drivers/gpu/drm/i915/gem/i915_gemfs.c b/drivers/gpu/drm/i915/gem/i915_gemfs.c
index 099f3397aada..1f95d9ea319a 100644
--- a/drivers/gpu/drm/i915/gem/i915_gemfs.c
+++ b/drivers/gpu/drm/i915/gem/i915_gemfs.c
@@ -39,6 +39,9 @@ int i915_gemfs_init(struct drm_i915_private *i915)
 		int flags = 0;
 		int err;
 
+		if (!sb->s_op->remount_fs)
+			return -ENODEV;
+
 		err = sb->s_op->remount_fs(sb, &flags, options);
 		if (err) {
 			kern_unmount(gemfs);
---

	-ss

