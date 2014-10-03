Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f171.google.com (mail-vc0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id C45A56B006E
	for <linux-mm@kvack.org>; Fri,  3 Oct 2014 13:08:44 -0400 (EDT)
Received: by mail-vc0-f171.google.com with SMTP id hy10so950408vcb.30
        for <linux-mm@kvack.org>; Fri, 03 Oct 2014 10:08:44 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id ds7si4736660vdb.51.2014.10.03.10.08.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Oct 2014 10:08:42 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 06/17] kvm: Faults which trigger IO release the mmap_sem
Date: Fri,  3 Oct 2014 19:07:56 +0200
Message-Id: <1412356087-16115-7-git-send-email-aarcange@redhat.com>
In-Reply-To: <1412356087-16115-1-git-send-email-aarcange@redhat.com>
References: <1412356087-16115-1-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave@sr71.net>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "\\\"Dr. David Alan Gilbert\\\"" <dgilbert@redhat.com>, Christopher Covington <cov@codeaurora.org>, Johannes Weiner <hannes@cmpxchg.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Isaku Yamahata <yamahata@valinux.co.jp>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>

From: Andres Lagar-Cavilla <andreslc@google.com>

When KVM handles a tdp fault it uses FOLL_NOWAIT. If the guest memory
has been swapped out or is behind a filemap, this will trigger async
readahead and return immediately. The rationale is that KVM will kick
back the guest with an "async page fault" and allow for some other
guest process to take over.

If async PFs are enabled the fault is retried asap from an async
workqueue. If not, it's retried immediately in the same code path. In
either case the retry will not relinquish the mmap semaphore and will
block on the IO. This is a bad thing, as other mmap semaphore users
now stall as a function of swap or filemap latency.

This patch ensures both the regular and async PF path re-enter the
fault allowing for the mmap semaphore to be relinquished in the case
of IO wait.

Reviewed-by: Radim KrA?mA!A? <rkrcmar@redhat.com>
Signed-off-by: Andres Lagar-Cavilla <andreslc@google.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 virt/kvm/async_pf.c | 4 +---
 virt/kvm/kvm_main.c | 4 ++--
 2 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/virt/kvm/async_pf.c b/virt/kvm/async_pf.c
index d6a3d09..44660ae 100644
--- a/virt/kvm/async_pf.c
+++ b/virt/kvm/async_pf.c
@@ -80,9 +80,7 @@ static void async_pf_execute(struct work_struct *work)
 
 	might_sleep();
 
-	down_read(&mm->mmap_sem);
-	get_user_pages(NULL, mm, addr, 1, 1, 0, NULL, NULL);
-	up_read(&mm->mmap_sem);
+	get_user_pages_unlocked(NULL, mm, addr, 1, 1, 0, NULL);
 	kvm_async_page_present_sync(vcpu, apf);
 
 	spin_lock(&vcpu->async_pf.lock);
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 95519bc..921bce7 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -1170,8 +1170,8 @@ static int hva_to_pfn_slow(unsigned long addr, bool *async, bool write_fault,
 					      addr, write_fault, page);
 		up_read(&current->mm->mmap_sem);
 	} else
-		npages = get_user_pages_fast(addr, 1, write_fault,
-					     page);
+		npages = get_user_pages_unlocked(current, current->mm, addr, 1,
+						 write_fault, 0, page);
 	if (npages != 1)
 		return npages;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
