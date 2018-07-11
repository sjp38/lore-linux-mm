Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5766D6B000D
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 10:37:43 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id y130-v6so31189172qka.1
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 07:37:43 -0700 (PDT)
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40116.outbound.protection.outlook.com. [40.107.4.116])
        by mx.google.com with ESMTPS id w126-v6si5217655qkb.48.2018.07.11.07.37.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 11 Jul 2018 07:37:42 -0700 (PDT)
Subject: [PATCH] fs: Fix double prealloc_shrinker() in sget_fc()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Wed, 11 Jul 2018 17:37:34 +0300
Message-ID: <153131984019.24777.15284245961241666054.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, dhowells@redhat.com, ktkhai@virtuozzo.com

Hi,

I'm observing "KASAN: use-after-free Read in shrink_slab" on recent
linux-next in the code I've added:

https://syzkaller.appspot.com/bug?id=91767fc6346a4b9e0309a8cd7e2f356c434450b9

It seems to be not related to my patchset, since there is
a problem with double preallocation of shrinker. We should
use register_shrinker_prepared() in sget_fc(), since shrinker
is already allocated in alloc_super().

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 fs/super.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/super.c b/fs/super.c
index 13647d4fd262..47a819f1a300 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -551,7 +551,7 @@ struct super_block *sget_fc(struct fs_context *fc,
 	hlist_add_head(&s->s_instances, &s->s_type->fs_supers);
 	spin_unlock(&sb_lock);
 	get_filesystem(s->s_type);
-	register_shrinker(&s->s_shrink);
+	register_shrinker_prepared(&s->shrinker);
 	return s;
 }
 EXPORT_SYMBOL(sget_fc);
