Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9A3C46B036A
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 19:36:56 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id l16so76766817pgu.2
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 16:36:56 -0700 (PDT)
Received: from mail-pf0-x22a.google.com (mail-pf0-x22a.google.com. [2607:f8b0:400e:c00::22a])
        by mx.google.com with ESMTPS id k8si9618777pgp.294.2017.06.19.16.36.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 16:36:55 -0700 (PDT)
Received: by mail-pf0-x22a.google.com with SMTP id s66so60755969pfs.1
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 16:36:55 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 16/23] net: copy struct sctp_sock.autoclose to userspace using put_user()
Date: Mon, 19 Jun 2017 16:36:30 -0700
Message-Id: <1497915397-93805-17-git-send-email-keescook@chromium.org>
In-Reply-To: <1497915397-93805-1-git-send-email-keescook@chromium.org>
References: <1497915397-93805-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: David Windsor <dave@nullcore.net>

The autoclose field can be copied with put_user(), so there is no need to
use copy_to_user(). In both cases, hardened usercopy is being bypassed
since the size is constant, and not open to runtime manipulation.

This patch is verbatim from Brad Spengler/PaX Team's PAX_USERCOPY
whitelisting code in the last public patch of grsecurity/PaX based on my
understanding of the code. Changes or omissions from the original code are
mine and don't reflect the original grsecurity/PaX code.

Signed-off-by: David Windsor <dave@nullcore.net>
[kees: adjust commit log]
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 net/sctp/socket.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 0defc0c76552..e94c141bcf82 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -4883,7 +4883,7 @@ static int sctp_getsockopt_autoclose(struct sock *sk, int len, char __user *optv
 	len = sizeof(int);
 	if (put_user(len, optlen))
 		return -EFAULT;
-	if (copy_to_user(optval, &sctp_sk(sk)->autoclose, sizeof(int)))
+	if (put_user(sctp_sk(sk)->autoclose, (int __user *)optval))
 		return -EFAULT;
 	return 0;
 }
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
