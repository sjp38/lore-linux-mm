Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E178B6B02B0
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 23:04:55 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id p190so24448069wmp.3
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 20:04:55 -0700 (PDT)
Received: from thejh.net (thejh.net. [37.221.195.125])
        by mx.google.com with ESMTPS id f81si7198408wmd.19.2016.11.02.20.04.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 20:04:54 -0700 (PDT)
From: Jann Horn <jann@thejh.net>
Subject: [PATCH v3 1/3] fs/exec: don't force writing memory access
Date: Thu,  3 Nov 2016 04:04:44 +0100
Message-Id: <1478142286-18427-4-git-send-email-jann@thejh.net>
In-Reply-To: <1478142286-18427-1-git-send-email-jann@thejh.net>
References: <1478142286-18427-1-git-send-email-jann@thejh.net>
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
