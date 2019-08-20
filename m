Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5D39C3A59E
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 16:02:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B02E22070B
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 16:02:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B02E22070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 45BAD6B000C; Tue, 20 Aug 2019 12:02:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 40D816B000D; Tue, 20 Aug 2019 12:02:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 323146B000E; Tue, 20 Aug 2019 12:02:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0188.hostedemail.com [216.40.44.188])
	by kanga.kvack.org (Postfix) with ESMTP id 12E8C6B000C
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 12:02:44 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id AD82862C0
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 16:02:43 +0000 (UTC)
X-FDA: 75843274206.17.robin79_8c31de8a5c061
X-HE-Tag: robin79_8c31de8a5c061
X-Filterd-Recvd-Size: 4021
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 16:02:43 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 4D86DA35FE7;
	Tue, 20 Aug 2019 16:02:42 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (ovpn-204-99.brq.redhat.com [10.40.204.99])
	by smtp.corp.redhat.com (Postfix) with SMTP id 80BFC6060D;
	Tue, 20 Aug 2019 16:02:39 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Tue, 20 Aug 2019 18:02:41 +0200 (CEST)
Date: Tue, 20 Aug 2019 18:02:38 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Kefeng Wang <wangkefeng.wang@huawei.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>,
	Peter Xu <peterx@redhat.com>, Mike Rapoport <rppt@linux.ibm.com>,
	Jann Horn <jannh@google.com>, Jason Gunthorpe <jgg@mellanox.com>,
	Michal Hocko <mhocko@suse.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	linux-kernel@vger.kernel.org
Subject: [PATCH] userfaultfd_release: always remove uffd flags and clear
 vm_userfaultfd_ctx
Message-ID: <20190820160237.GB4983@redhat.com>
References: <d4583416-5e4a-95e7-a08a-32bf2c9a95fb@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d4583416-5e4a-95e7-a08a-32bf2c9a95fb@huawei.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.6.2 (mx1.redhat.com [10.5.110.68]); Tue, 20 Aug 2019 16:02:42 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

userfaultfd_release() should clear vm_flags/vm_userfaultfd_ctx even
if mm->core_state != NULL.

Otherwise a page fault can see userfaultfd_missing() == T and use an
already freed userfaultfd_ctx.

Reported-by: Kefeng Wang <wangkefeng.wang@huawei.com>
Fixes: 04f5866e41fb ("coredump: fix race condition between mmget_not_zero()/get_task_mm() and core dumping")
Cc: stable@vger.kernel.org
Signed-off-by: Oleg Nesterov <oleg@redhat.com>
---
 fs/userfaultfd.c | 25 +++++++++++++------------
 1 file changed, 13 insertions(+), 12 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index ccbdbd6..fe6d804 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -880,6 +880,7 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
 	/* len == 0 means wake all */
 	struct userfaultfd_wake_range range = { .len = 0, };
 	unsigned long new_flags;
+	bool still_valid;
 
 	WRITE_ONCE(ctx->released, true);
 
@@ -895,8 +896,7 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
 	 * taking the mmap_sem for writing.
 	 */
 	down_write(&mm->mmap_sem);
-	if (!mmget_still_valid(mm))
-		goto skip_mm;
+	still_valid = mmget_still_valid(mm);
 	prev = NULL;
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		cond_resched();
@@ -907,19 +907,20 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
 			continue;
 		}
 		new_flags = vma->vm_flags & ~(VM_UFFD_MISSING | VM_UFFD_WP);
-		prev = vma_merge(mm, prev, vma->vm_start, vma->vm_end,
-				 new_flags, vma->anon_vma,
-				 vma->vm_file, vma->vm_pgoff,
-				 vma_policy(vma),
-				 NULL_VM_UFFD_CTX);
-		if (prev)
-			vma = prev;
-		else
-			prev = vma;
+		if (still_valid) {
+			prev = vma_merge(mm, prev, vma->vm_start, vma->vm_end,
+					 new_flags, vma->anon_vma,
+					 vma->vm_file, vma->vm_pgoff,
+					 vma_policy(vma),
+					 NULL_VM_UFFD_CTX);
+			if (prev)
+				vma = prev;
+			else
+				prev = vma;
+		}
 		vma->vm_flags = new_flags;
 		vma->vm_userfaultfd_ctx = NULL_VM_UFFD_CTX;
 	}
-skip_mm:
 	up_write(&mm->mmap_sem);
 	mmput(mm);
 wakeup:
-- 
2.5.0



