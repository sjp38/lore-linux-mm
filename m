Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0807A6B0286
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 16:40:26 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id v15so17036497iob.22
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 13:40:26 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t10sor8612092ita.25.2018.01.09.13.40.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Jan 2018 13:40:24 -0800 (PST)
Date: Tue, 9 Jan 2018 13:40:21 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm] mm, mmu_notifier: annotate mmu notifiers with blockable
 invalidate callbacks fix fix
In-Reply-To: <20171215150429.f68862867392337f35a49848@linux-foundation.org>
Message-ID: <alpine.DEB.2.10.1801091339570.240101@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1712111409090.196232@chino.kir.corp.google.com> <alpine.DEB.2.10.1712141329500.74052@chino.kir.corp.google.com> <20171215150429.f68862867392337f35a49848@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Oded Gabbay <oded.gabbay@gmail.com>, Alex Deucher <alexander.deucher@amd.com>, =?UTF-8?Q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>, David Airlie <airlied@linux.ie>, Joerg Roedel <joro@8bytes.org>, Doug Ledford <dledford@redhat.com>, Jani Nikula <jani.nikula@linux.intel.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Sean Hefty <sean.hefty@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, =?UTF-8?Q?J=C3=A9r=C3=B4me_Glisse?= <jglisse@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?Q?Radim_Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Fix mmu_notifier.h comments in "mm, mmu_notifier: annotate mmu notifiers
with blockable invalidate callbacks".

mmu_notifier_invalidate_range_end() can also call the invalidate_range()
callback, so it must not block for MMU_INVALIDATE_DOES_NOT_BLOCK to be
set.

Also remove a bogus comment about invalidate_range() always being called
under the ptl spinlock.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/mmu_notifier.h | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -34,8 +34,8 @@ struct mmu_notifier_ops {
 	 * Flags to specify behavior of callbacks for this MMU notifier.
 	 * Used to determine which context an operation may be called.
 	 *
-	 * MMU_INVALIDATE_DOES_NOT_BLOCK: invalidate_{start,end} does not
-	 *				  block
+	 * MMU_INVALIDATE_DOES_NOT_BLOCK: invalidate_range_* callbacks do not
+	 *	block
 	 */
 	int flags;
 
@@ -151,8 +151,9 @@ struct mmu_notifier_ops {
 	 * address space but may still be referenced by sptes until
 	 * the last refcount is dropped.
 	 *
-	 * If both of these callbacks cannot block, mmu_notifier_ops.flags
-	 * should have MMU_INVALIDATE_DOES_NOT_BLOCK set.
+	 * If both of these callbacks cannot block, and invalidate_range
+	 * cannot block, mmu_notifier_ops.flags should have
+	 * MMU_INVALIDATE_DOES_NOT_BLOCK set.
 	 */
 	void (*invalidate_range_start)(struct mmu_notifier *mn,
 				       struct mm_struct *mm,
@@ -175,12 +176,13 @@ struct mmu_notifier_ops {
 	 * external TLB range needs to be flushed. For more in depth
 	 * discussion on this see Documentation/vm/mmu_notifier.txt
 	 *
-	 * The invalidate_range() function is called under the ptl
-	 * spin-lock and not allowed to sleep.
-	 *
 	 * Note that this function might be called with just a sub-range
 	 * of what was passed to invalidate_range_start()/end(), if
 	 * called between those functions.
+	 *
+	 * If this callback cannot block, and invalidate_range_{start,end}
+	 * cannot block, mmu_notifier_ops.flags should have
+	 * MMU_INVALIDATE_DOES_NOT_BLOCK set.
 	 */
 	void (*invalidate_range)(struct mmu_notifier *mn, struct mm_struct *mm,
 				 unsigned long start, unsigned long end);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
