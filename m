Return-Path: <SRS0=zwjV=WV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20DE3C3A59E
	for <linux-mm@archiver.kernel.org>; Sun, 25 Aug 2019 00:55:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CE94D22CE3
	for <linux-mm@archiver.kernel.org>; Sun, 25 Aug 2019 00:54:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="wpzfkNyX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE94D22CE3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 80D026B0501; Sat, 24 Aug 2019 20:54:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7BD2C6B0503; Sat, 24 Aug 2019 20:54:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D42D6B0504; Sat, 24 Aug 2019 20:54:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0048.hostedemail.com [216.40.44.48])
	by kanga.kvack.org (Postfix) with ESMTP id 4ADCA6B0501
	for <linux-mm@kvack.org>; Sat, 24 Aug 2019 20:54:59 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id E6050824CA26
	for <linux-mm@kvack.org>; Sun, 25 Aug 2019 00:54:58 +0000 (UTC)
X-FDA: 75859130676.15.heat71_488d6cc564a25
X-HE-Tag: heat71_488d6cc564a25
X-Filterd-Recvd-Size: 4090
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf18.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 25 Aug 2019 00:54:58 +0000 (UTC)
Received: from localhost.localdomain (c-73-231-172-41.hsd1.ca.comcast.net [73.231.172.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 186B42339D;
	Sun, 25 Aug 2019 00:54:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1566694497;
	bh=T03GOG6VGUuHs/Ca4qtKoTZFfuRB7+LZvKLzqSSOIhE=;
	h=Date:From:To:Subject:From;
	b=wpzfkNyXyN6ka6oSUQAmEWmPWf6KlANw+++YxBJbJr0fJT8pQH6291yLe+FT/sBTs
	 ZFjVEIoWisA8s7huPfNBNTrreGtifYfUWDjF0yWHvItWQgHxhG0/FkT/J9aSt/Ez3f
	 KGorxLIlwJn6IjjCAwxvf42aQ9EgLhsTZkUfxR9A=
Date: Sat, 24 Aug 2019 17:54:56 -0700
From: akpm@linux-foundation.org
To: aarcange@redhat.com, akpm@linux-foundation.org, jannh@google.com,
 jgg@mellanox.com, linux-mm@kvack.org, mhocko@suse.com,
 mm-commits@vger.kernel.org, oleg@redhat.com,
 penguin-kernel@I-love.SAKURA.ne.jp, peterx@redhat.com,
 rppt@linux.ibm.com, stable@vger.kernel.org,
 torvalds@linux-foundation.org, wangkefeng.wang@huawei.com
Subject:  [patch 07/11] userfaultfd_release: always remove uffd
 flags and clear vm_userfaultfd_ctx
Message-ID: <20190825005456.L2ZisNIcB%akpm@linux-foundation.org>
User-Agent: s-nail v14.8.16
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Oleg Nesterov <oleg@redhat.com>
Subject: userfaultfd_release: always remove uffd flags and clear vm_userfaultfd_ctx

userfaultfd_release() should clear vm_flags/vm_userfaultfd_ctx even
if mm->core_state != NULL.

Otherwise a page fault can see userfaultfd_missing() == T and use an
already freed userfaultfd_ctx.

Link: http://lkml.kernel.org/r/20190820160237.GB4983@redhat.com
Fixes: 04f5866e41fb ("coredump: fix race condition between mmget_not_zero()/get_task_mm() and core dumping")
Signed-off-by: Oleg Nesterov <oleg@redhat.com>
Reported-by: Kefeng Wang <wangkefeng.wang@huawei.com>
Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
Tested-by: Kefeng Wang <wangkefeng.wang@huawei.com>
Cc: Peter Xu <peterx@redhat.com>
Cc: Mike Rapoport <rppt@linux.ibm.com>
Cc: Jann Horn <jannh@google.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: <stable@vger.kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 fs/userfaultfd.c |   25 +++++++++++++------------
 1 file changed, 13 insertions(+), 12 deletions(-)

--- a/fs/userfaultfd.c~userfaultfd_release-always-remove-uffd-flags-and-clear-vm_userfaultfd_ctx
+++ a/fs/userfaultfd.c
@@ -880,6 +880,7 @@ static int userfaultfd_release(struct in
 	/* len == 0 means wake all */
 	struct userfaultfd_wake_range range = { .len = 0, };
 	unsigned long new_flags;
+	bool still_valid;
 
 	WRITE_ONCE(ctx->released, true);
 
@@ -895,8 +896,7 @@ static int userfaultfd_release(struct in
 	 * taking the mmap_sem for writing.
 	 */
 	down_write(&mm->mmap_sem);
-	if (!mmget_still_valid(mm))
-		goto skip_mm;
+	still_valid = mmget_still_valid(mm);
 	prev = NULL;
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		cond_resched();
@@ -907,19 +907,20 @@ static int userfaultfd_release(struct in
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
_

