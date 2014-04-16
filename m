Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id 4BB956B0062
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 00:19:24 -0400 (EDT)
Received: by mail-ee0-f48.google.com with SMTP id b57so8241952eek.21
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 21:19:23 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 43si28150179eei.115.2014.04.15.21.19.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Apr 2014 21:19:23 -0700 (PDT)
From: NeilBrown <neilb@suse.de>
Date: Wed, 16 Apr 2014 14:03:36 +1000
Subject: [PATCH 13/19] MM: set PF_FSTRANS while allocating per-cpu memory to
 avoid deadlock.
Message-ID: <20140416040336.10604.67456.stgit@notabene.brown>
In-Reply-To: <20140416033623.10604.69237.stgit@notabene.brown>
References: <20140416033623.10604.69237.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: xfs@oss.sgi.com

lockdep reports a locking chain

  sk_lock-AF_INET --> rtnl_mutex --> pcpu_alloc_mutex

As sk_lock may be needed to reclaim memory, allowing that
reclaim while pcu_alloc_mutex is held can lead to deadlock.
So set PF_FSTRANS while it is help to avoid the FS reclaim.

pcpu_alloc_mutex can be taken when rtnl_mutex is held:

    [<ffffffff8117f979>] pcpu_alloc+0x49/0x960
    [<ffffffff8118029b>] __alloc_percpu+0xb/0x10
    [<ffffffff8193b9f7>] loopback_dev_init+0x17/0x60
    [<ffffffff81aaf30c>] register_netdevice+0xec/0x550
    [<ffffffff81aaf785>] register_netdev+0x15/0x30

Signed-off-by: NeilBrown <neilb@suse.de>
---
 mm/percpu.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/percpu.c b/mm/percpu.c
index 036cfe07050f..77dd24032f41 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -712,6 +712,7 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved)
 	int slot, off, new_alloc;
 	unsigned long flags;
 	void __percpu *ptr;
+	unsigned int pflags;
 
 	if (unlikely(!size || size > PCPU_MIN_UNIT_SIZE || align > PAGE_SIZE)) {
 		WARN(true, "illegal size (%zu) or align (%zu) for "
@@ -720,6 +721,7 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved)
 	}
 
 	mutex_lock(&pcpu_alloc_mutex);
+	current_set_flags_nested(&pflags, PF_FSTRANS);
 	spin_lock_irqsave(&pcpu_lock, flags);
 
 	/* serve reserved allocations from the reserved chunk if available */
@@ -801,6 +803,7 @@ area_found:
 		goto fail_unlock;
 	}
 
+	current_restore_flags_nested(&pflags, PF_FSTRANS);
 	mutex_unlock(&pcpu_alloc_mutex);
 
 	/* return address relative to base address */
@@ -811,6 +814,7 @@ area_found:
 fail_unlock:
 	spin_unlock_irqrestore(&pcpu_lock, flags);
 fail_unlock_mutex:
+	current_restore_flags_nested(&pflags, PF_FSTRANS);
 	mutex_unlock(&pcpu_alloc_mutex);
 	if (warn_limit) {
 		pr_warning("PERCPU: allocation failed, size=%zu align=%zu, "


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
