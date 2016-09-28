Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7AB5628024F
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 18:54:56 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l138so55360596wmg.3
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 15:54:56 -0700 (PDT)
Received: from thejh.net (thejh.net. [37.221.195.125])
        by mx.google.com with ESMTPS id v126si5172413wmg.36.2016.09.28.15.54.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Sep 2016 15:54:55 -0700 (PDT)
From: Jann Horn <jann@thejh.net>
Subject: [PATCH v2 1/3] fs/exec: don't force writing memory access
Date: Thu, 29 Sep 2016 00:54:39 +0200
Message-Id: <1475103281-7989-2-git-send-email-jann@thejh.net>
In-Reply-To: <1475103281-7989-1-git-send-email-jann@thejh.net>
References: <1475103281-7989-1-git-send-email-jann@thejh.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: security@kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Paul Moore <paul@paul-moore.com>, Stephen Smalley <sds@tycho.nsa.gov>, Eric Paris <eparis@parisplace.org>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>
Cc: Nick Kralevich <nnk@google.com>, Janis Danisevskis <jdanis@google.com>, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This shouldn't change behavior in any way - at this point, there should be
no non-writable mappings, only the initial stack mapping -, but this change
makes it easier to reason about the correctness of the following commits
that place restrictions on forced memory writes.

Signed-off-by: Jann Horn <jann@thejh.net>
Reviewed-by: Janis Danisevskis <jdanis@android.com>
---
 fs/exec.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/exec.c b/fs/exec.c
index 6fcfb3f..d607da8 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -204,7 +204,7 @@ static struct page *get_arg_page(struct linux_binprm *bprm, unsigned long pos,
 	 * doing the exec and bprm->mm is the new process's mm.
 	 */
 	ret = get_user_pages_remote(current, bprm->mm, pos, 1, write,
-			1, &page, NULL);
+			0, &page, NULL);
 	if (ret <= 0)
 		return NULL;
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
