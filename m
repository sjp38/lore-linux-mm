Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C28EC76188
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:02:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0AB04218A6
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:02:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="ew44vIQZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0AB04218A6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B78F18E0006; Fri, 19 Jul 2019 00:02:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B4EFC8E0001; Fri, 19 Jul 2019 00:02:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A653E8E0006; Fri, 19 Jul 2019 00:02:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6F0E78E0001
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 00:02:34 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id e20so17929983pfd.3
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 21:02:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=b+TNQveKINoXopoXI25UN27cMHajmhFsRMq4sJsLjoI=;
        b=Ds/jEFfpPKNTPS9s26HQHlkk44tr9mVmwp52ccmfuVuZFKb5VeRAVAIRBugVPYobt4
         dCWvrAGLIMLDv98OjB6BJB6CoeHtpo/1kxAcuxwnV1u7FA9X2406LZv7VLKFo2fl2QLD
         zMxqHxwft1SdPDxuFT8bMraR+rxsxnO5ltoyYYKOhTw/Zk8KaPSzAJg/U4at6IwXXKuF
         whIOlkrD8y/J8LjiYpKyE81uHjpx/C58/VQbfam6klsPImLC0ZjGwkFr19MkwrjG5gGE
         UdeOlDHYwKBmRoU60lUVTzzkJJYfHL2pRIL+p7Q+rZyc4mY2UwP2AdgPBdLG1D4rbDpe
         3uZA==
X-Gm-Message-State: APjAAAWvF07hcF8HER94UNb+qt2oIqI84UA2XsYOu/ZAz6xSdmGxBnXG
	UUhExCPL8FCksiAhUWTwIhzKnJ9drX+2bdiqQCwtlsPw+KKQrf0Pse6vY+7s+rneWmQ/NXCnh8p
	BacK6HuOsx6r/mLQpRgXhnEzXmkhowsx7BVmvJrqM0f5KB28RtGStP2arSjUky7ZFrw==
X-Received: by 2002:a17:90a:db08:: with SMTP id g8mr53358154pjv.39.1563508954119;
        Thu, 18 Jul 2019 21:02:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwyEYT/h+M/Hv+8cdpyP/IZ4N7A8HaTgqbXPnySGZEQfRzeqgOE31RjGL/pfYphE4hvM9Aw
X-Received: by 2002:a17:90a:db08:: with SMTP id g8mr53358080pjv.39.1563508953346;
        Thu, 18 Jul 2019 21:02:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563508953; cv=none;
        d=google.com; s=arc-20160816;
        b=DCwk6z+e699QXv4qFjTMdBQMInjZUeuAa1vXcRlf8bf1EbCaQ4rmCDchhnA05/MsZb
         Y4Rgix06F3dAf1L9xSmZ59QfnSFANsHSrwlWZh2a841jx9uOJiXvyvlyAy9qqZrHsjWh
         71C2XwHYSAm4Ur9zl16kswFWwyrci9fEA36ZqZyNe6mid52BnuLVd+1CjiG+uNDI426z
         Rr1CM+xQ2ANp3rEqNGBbGHh5iQeXzoXDomkFIN30jkEGoiABrFzSoHrvsAtWnGp1OKYl
         THjIaW1bUDw2oROaQRngzC7QCblJ6X4j0fzpG3yWiKVXRSRFPs0vxteZsUWadjf5w04R
         B5uw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=b+TNQveKINoXopoXI25UN27cMHajmhFsRMq4sJsLjoI=;
        b=kVf08vjNFWODmiRMcvG5orGQwxSi4q1wM9A8aKKEwubGrTbDK1+wKVlG91YCecSGa2
         pGGH4iWt4V+Z9xf0x/VwagW6wAeJ1vHo0ZABs9qoyqVwO2fSnYQhZkA2wZCm07LszGih
         X9Qk3ez0aKxU9GsGV+P4lqveCP3iwKav/j4VapK+PscKRrRMLNapBbALfG/MAZhM3PyC
         CIFo9BxuxnhCGy6qiAmKA3ipt6x9lZln2HSghTZQRFkcBR+6a0Vs1OHRdCpQPuTniBiY
         lhO3n0uJd0M4K/Cmwk4susaFL+DSLtIHRf7XD1yV4oS3mOlOxs0Vu4GczZmFpPZS/Vkp
         juBg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ew44vIQZ;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f15si43946pgi.56.2019.07.18.21.02.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 21:02:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ew44vIQZ;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 841E021852;
	Fri, 19 Jul 2019 04:02:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563508953;
	bh=jcUkRjwMhQ/ORG8sZHca2w3d73uThSyyH5niWnxwa2Q=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=ew44vIQZSxDbfCGU+ruk3+waCnyK239Uipco9VjE/OAaa8MvLBM1IOi3urtHlUsId
	 yoUMHC7gNt+rrJ3jUvQg7gxuSk6fc+RFpPBPhumy4XSuuqCObrTQkrS7j6nh18XcI3
	 rL0zQvJDE8IRkCcByvFgWaJZVz1WqvIwNs+eXw38=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
	=?UTF-8?q?Michal=20Koutn=C3=BD?= <mkoutny@suse.com>,
	Oleg Nesterov <oleg@redhat.com>,
	Michal Hocko <mhocko@suse.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Matthew Wilcox <willy@infradead.org>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Kirill Tkhai <ktkhai@virtuozzo.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Roman Gushchin <guro@fb.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.2 170/171] mm: use down_read_killable for locking mmap_sem in access_remote_vm
Date: Thu, 18 Jul 2019 23:56:41 -0400
Message-Id: <20190719035643.14300-170-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190719035643.14300-1-sashal@kernel.org>
References: <20190719035643.14300-1-sashal@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

[ Upstream commit 1e426fe28261b03f297992e89da3320b42816f4e ]

This function is used by ptrace and proc files like /proc/pid/cmdline and
/proc/pid/environ.

Access_remote_vm never returns error codes, all errors are ignored and
only size of successfully read data is returned.  So, if current task was
killed we'll simply return 0 (bytes read).

Mmap_sem could be locked for a long time or forever if something goes
wrong.  Using a killable lock permits cleanup of stuck tasks and
simplifies investigation.

Link: http://lkml.kernel.org/r/156007494202.3335.16782303099589302087.stgit@buzz
Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Reviewed-by: Michal Koutný <mkoutny@suse.com>
Acked-by: Oleg Nesterov <oleg@redhat.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Cc: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Roman Gushchin <guro@fb.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/memory.c | 4 +++-
 mm/nommu.c  | 3 ++-
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index ddf20bd0c317..9a4401d21e94 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4349,7 +4349,9 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 	void *old_buf = buf;
 	int write = gup_flags & FOLL_WRITE;
 
-	down_read(&mm->mmap_sem);
+	if (down_read_killable(&mm->mmap_sem))
+		return 0;
+
 	/* ignore errors, just check how much was successfully transferred */
 	while (len) {
 		int bytes, ret, offset;
diff --git a/mm/nommu.c b/mm/nommu.c
index d8c02fbe03b5..b2823519f8cd 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1792,7 +1792,8 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 	struct vm_area_struct *vma;
 	int write = gup_flags & FOLL_WRITE;
 
-	down_read(&mm->mmap_sem);
+	if (down_read_killable(&mm->mmap_sem))
+		return 0;
 
 	/* the access must start within one of the target process's mappings */
 	vma = find_vma(mm, addr);
-- 
2.20.1

