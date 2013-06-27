Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id B96A96B0034
	for <linux-mm@kvack.org>; Wed, 26 Jun 2013 21:32:30 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id lf11so331989pab.10
        for <linux-mm@kvack.org>; Wed, 26 Jun 2013 18:32:29 -0700 (PDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [RESEND PATCH] zcache: initialize module properly when zcache=FOO is given
Date: Thu, 27 Jun 2013 09:32:20 +0800
Message-Id: <1372296740-25259-1-git-send-email-bob.liu@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org
Cc: mhocko@suse.cz, konrad.wilk@oracle.com, akpm@linux-foundation.org, linux-mm@kvack.org, crrodriguez@opensuse.org, Bob Liu <bob.liu@oracle.com>

From: Michal Hocko <mhocko@suse.cz>

835f2f51 (staging: zcache: enable zcache to be built/loaded as a module)
introduced in 3.10-rc1 has introduced a bug for zcache=FOO module
parameter processing.

zcache_comp_init return code doesn't agree with crypto_has_comp which
uses 1 for the success unlike zcache_comp_init which uses 0. This
causes module loading failure even if the given algorithm is supported:
[    0.815330] zcache: compressor initialization failed

Reported-by: Cristian RodrA-guez <crrodriguez@opensuse.org>
Signed-off-by: Michal Hocko <mhocko@suse.cz>
Acked-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Signed-off-by: Bob Liu <bob.liu@oracle.com>
---
 drivers/staging/zcache/zcache-main.c |    7 +++++--
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
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
