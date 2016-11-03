Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 29D6A6B02AD
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 23:04:54 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r68so22153223wmd.0
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 20:04:54 -0700 (PDT)
Received: from thejh.net (thejh.net. [2a03:4000:2:1b9::1])
        by mx.google.com with ESMTPS id p203si41675704wmd.118.2016.11.02.20.04.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 20:04:52 -0700 (PDT)
From: Jann Horn <jann@thejh.net>
Subject: [PATCH 1/3] fs/exec: don't force writing memory access
Date: Thu,  3 Nov 2016 04:04:41 +0100
Message-Id: <1478142286-18427-1-git-send-email-jann@thejh.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: security@kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Paul Moore <paul@paul-moore.com>, Stephen Smalley <sds@tycho.nsa.gov>, Eric Paris <eparis@parisplace.org>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, mchong@google.com, Andy Lutomirski <luto@amacapital.net>, Ingo Molnar <mingo@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Nick Kralevich <nnk@google.com>, Janis Danisevskis <jdanis@google.com>
Cc: linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

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
index 4e497b9ee71e..dbc2dd2f0829 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -191,7 +191,7 @@ static struct page *get_arg_page(struct linux_binprm *bprm, unsigned long pos,
 {
 	struct page *page;
 	int ret;
-	unsigned int gup_flags = FOLL_FORCE;
+	unsigned int gup_flags = 0;
 
 #ifdef CONFIG_STACK_GROWSUP
 	if (write) {
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
