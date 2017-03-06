Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1FD966B0038
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 05:33:39 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id b140so14055648wme.3
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 02:33:39 -0800 (PST)
Received: from mail-wr0-f195.google.com (mail-wr0-f195.google.com. [209.85.128.195])
        by mx.google.com with ESMTPS id 94si24127702wrr.147.2017.03.06.02.33.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 02:33:37 -0800 (PST)
Received: by mail-wr0-f195.google.com with SMTP id l37so21096430wrc.3
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 02:33:37 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 5/9] xattr: zero out memory copied to userspace in getxattr
Date: Mon,  6 Mar 2017 11:33:23 +0100
Message-Id: <20170306103327.2766-1-mhocko@kernel.org>
In-Reply-To: <20170306103032.2540-1-mhocko@kernel.org>
References: <20170306103032.2540-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Kees Cook <keescook@chromium.org>, Vlastimil Babka <vbabka@suse.cz>

From: Michal Hocko <mhocko@suse.com>

getxattr uses vmalloc to allocate memory if kzalloc fails. This is
filled by vfs_getxattr and then copied to the userspace. vmalloc,
however, doesn't zero out the memory so if the specific implementation
of the xattr handler is sloppy we can theoretically expose a kernel
memory. There is no real sign this is really the case but let's make
sure this will not happen and use vzalloc instead.

Fixes: 779302e67835 ("fs/xattr.c:getxattr(): improve handling of allocation failures")
Cc: stable # 3.6+
Acked-by: Kees Cook <keescook@chromium.org>
Spotted-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 fs/xattr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/xattr.c b/fs/xattr.c
index 7e3317cf4045..94f49a082dd2 100644
--- a/fs/xattr.c
+++ b/fs/xattr.c
@@ -530,7 +530,7 @@ getxattr(struct dentry *d, const char __user *name, void __user *value,
 			size = XATTR_SIZE_MAX;
 		kvalue = kzalloc(size, GFP_KERNEL | __GFP_NOWARN);
 		if (!kvalue) {
-			kvalue = vmalloc(size);
+			kvalue = vzalloc(size);
 			if (!kvalue)
 				return -ENOMEM;
 		}
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
