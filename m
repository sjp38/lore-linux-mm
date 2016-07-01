Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id CC8106B0005
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 00:36:13 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id g13so183764753ioj.3
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 21:36:13 -0700 (PDT)
Received: from takane.zaitcev.us (takane.zaitcev.us. [96.126.117.152])
        by mx.google.com with ESMTP id g23si713418otd.256.2016.06.30.21.36.13
        for <linux-mm@kvack.org>;
        Thu, 30 Jun 2016 21:36:13 -0700 (PDT)
Date: Thu, 30 Jun 2016 22:36:08 -0600
From: Pete Zaitcev <zaitcev@kotori.zaitcev.us>
Subject: [patch] Allow user.* xattr in tmpfs
Message-ID: <20160630223608.6ecbec55@lembas.zaitcev.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Hugh Dickins <hughd@google.com>

The lack of user extended attributes is a source of annoyance when
testing something that uses it, such as OpenStack Swift (including
Hummingbird). We used to "monkey-patch" this in Python, so that
tests can run on development systems, but it became desirable
to store correct attributes and existing stubs became impractical.

See:
- my failed attempt to use /var/tmp:
 https://review.openstack.org/328508
- Sam Merritt removing monkey-patching:
 https://review.openstack.org/336323

Signed-off-by: Pete Zaitcev <zaitcev@redhat.com>
---

This seems entirely too obvious. I'm getting concerned that we omitted
the user xattr for a reason. Just can't imagine what it might be.

diff --git a/mm/shmem.c b/mm/shmem.c
index 24463b6..4ddec69 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2655,6 +2655,12 @@ static int shmem_xattr_handler_set(const struct xattr_handler *handler,
 	return simple_xattr_set(&info->xattrs, name, value, size, flags);
 }
 
+static const struct xattr_handler shmem_user_xattr_handler = {
+	.prefix = XATTR_USER_PREFIX,
+	.get = shmem_xattr_handler_get,
+	.set = shmem_xattr_handler_set,
+};
+
 static const struct xattr_handler shmem_security_xattr_handler = {
 	.prefix = XATTR_SECURITY_PREFIX,
 	.get = shmem_xattr_handler_get,
@@ -2672,6 +2678,7 @@ static const struct xattr_handler *shmem_xattr_handlers[] = {
 	&posix_acl_access_xattr_handler,
 	&posix_acl_default_xattr_handler,
 #endif
+	&shmem_user_xattr_handler,
 	&shmem_security_xattr_handler,
 	&shmem_trusted_xattr_handler,
 	NULL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
