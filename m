Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 16F4C6B0038
	for <linux-mm@kvack.org>; Wed, 26 Jun 2013 10:49:17 -0400 (EDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] zcache: initialize module properly when zcache=FOO is given
Date: Wed, 26 Jun 2013 16:49:02 +0200
Message-Id: <1372258142-7019-1-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Bob Liu <lliubbo@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, =?UTF-8?q?Cristian=20Rodr=C3=ADguez?= <crrodriguez@opensuse.org>

835f2f51 (staging: zcache: enable zcache to be built/loaded as a module)
introduced in 3.10-rc1 has introduced a bug for zcache=FOO module
parameter processing.

zcache_comp_init return code doesn't agree with crypto_has_comp which
uses 1 for the success unlike zcache_comp_init which uses 0. This
causes module loading failure even if the given algorithm is supported:
[    0.815330] zcache: compressor initialization failed

Reported-by: Cristian RodrA-guez <crrodriguez@opensuse.org>
Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 drivers/staging/zcache/zcache-main.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index dcceed2..0fe530b 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -1811,10 +1811,12 @@ static int zcache_comp_init(void)
 #else
 	if (*zcache_comp_name != '\0') {
 		ret = crypto_has_comp(zcache_comp_name, 0, 0);
-		if (!ret)
+		if (!ret) {
 			pr_info("zcache: %s not supported\n",
 					zcache_comp_name);
-		goto out;
+			goto out;
+		}
+		goto out_alloc;
 	}
 	if (!ret)
 		strcpy(zcache_comp_name, "lzo");
@@ -1827,6 +1829,7 @@ static int zcache_comp_init(void)
 	pr_info("zcache: using %s compressor\n", zcache_comp_name);
 
 	/* alloc percpu transforms */
+out_alloc:
 	ret = 0;
 	zcache_comp_pcpu_tfms = alloc_percpu(struct crypto_comp *);
 	if (!zcache_comp_pcpu_tfms)
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
