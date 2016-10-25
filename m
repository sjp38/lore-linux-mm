Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 299626B027C
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 19:36:13 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id u187so1674173wmd.8
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 16:36:13 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id f196si6796762wme.70.2016.10.25.16.36.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Oct 2016 16:36:12 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id y138so2158657wme.1
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 16:36:11 -0700 (PDT)
From: Lorenzo Stoakes <lstoakes@gmail.com>
Subject: [PATCH] mm: remove unnecessary __get_user_pages_unlocked() calls
Date: Wed, 26 Oct 2016 00:36:09 +0100
Message-Id: <20161025233609.5601-1-lstoakes@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, Lorenzo Stoakes <lstoakes@gmail.com>

In hva_to_pfn_slow() we are able to replace __get_user_pages_unlocked() with
get_user_pages_unlocked() since we can now pass gup_flags.

In async_pf_execute() we need to pass different tsk, mm arguments so
get_user_pages_remote() is the sane replacement here (having added manual
acquisition and release of mmap_sem.)

Since we pass a NULL pages parameter the subsequent call to
__get_user_pages_locked() will have previously bailed any attempt at
VM_FAULT_RETRY, so we do not change this behaviour by using
get_user_pages_remote() which does not invoke VM_FAULT_RETRY logic at all.

Signed-off-by: Lorenzo Stoakes <lstoakes@gmail.com>
---
 virt/kvm/async_pf.c | 7 ++++---
 virt/kvm/kvm_main.c | 5 ++---
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/virt/kvm/async_pf.c b/virt/kvm/async_pf.c
index 8035cc1..e8c832c 100644
--- a/virt/kvm/async_pf.c
+++ b/virt/kvm/async_pf.c
@@ -82,10 +82,11 @@ static void async_pf_execute(struct work_struct *work)
 	/*
 	 * This work is run asynchromously to the task which owns
 	 * mm and might be done in another context, so we must
-	 * use FOLL_REMOTE.
+	 * access remotely.
 	 */
-	__get_user_pages_unlocked(NULL, mm, addr, 1, NULL,
-			FOLL_WRITE | FOLL_REMOTE);
+	down_read(&mm->mmap_sem);
+	get_user_pages_remote(NULL, mm, addr, 1, FOLL_WRITE, NULL, NULL);
+	up_read(&mm->mmap_sem);

 	kvm_async_page_present_sync(vcpu, apf);

diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 2907b7b..c45d951 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -1415,13 +1415,12 @@ static int hva_to_pfn_slow(unsigned long addr, bool *async, bool write_fault,
 		npages = get_user_page_nowait(addr, write_fault, page);
 		up_read(&current->mm->mmap_sem);
 	} else {
-		unsigned int flags = FOLL_TOUCH | FOLL_HWPOISON;
+		unsigned int flags = FOLL_HWPOISON;

 		if (write_fault)
 			flags |= FOLL_WRITE;

-		npages = __get_user_pages_unlocked(current, current->mm, addr, 1,
-						   page, flags);
+		npages = get_user_pages_unlocked(addr, 1, page, flags);
 	}
 	if (npages != 1)
 		return npages;
--
2.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
