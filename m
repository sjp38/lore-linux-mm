Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id B09B66B0105
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 19:03:03 -0400 (EDT)
Date: Wed, 12 Sep 2012 16:03:02 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] idr: Rename MAX_LEVEL to MAX_ID_LEVEL
Message-Id: <20120912160302.ae257eb4.akpm@linux-foundation.org>
In-Reply-To: <20120911094823.GA29568@localhost>
References: <20120910131426.GA12431@localhost>
	<504E1182.7080300@bfs.de>
	<20120911094823.GA29568@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: walter harms <wharms@bfs.de>, Glauber Costa <glommer@parallels.com>, kernel-janitors@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>

On Tue, 11 Sep 2012 17:48:23 +0800
Fengguang Wu <fengguang.wu@intel.com> wrote:

> idr: Rename MAX_LEVEL to MAX_IDR_LEVEL
> 
> To avoid name conflicts:
> 
> drivers/video/riva/fbdev.c:281:9: sparse: preprocessor token MAX_LEVEL redefined
> 
> While at it, also make the other names more consistent and
> add parentheses.

That was a rather modest effort :(

 drivers/i2c/i2c-core.c        |    2 +-
 drivers/infiniband/core/cm.c  |    2 +-
 drivers/pps/pps.c             |    2 +-
 drivers/thermal/thermal_sys.c |    2 +-
 fs/super.c                    |    2 +-
 5 files changed, 5 insertions(+), 5 deletions(-)

diff -puN drivers/i2c/i2c-core.c~idr-rename-max_level-to-max_idr_level-fix drivers/i2c/i2c-core.c
--- a/drivers/i2c/i2c-core.c~idr-rename-max_level-to-max_idr_level-fix
+++ a/drivers/i2c/i2c-core.c
@@ -982,7 +982,7 @@ int i2c_add_numbered_adapter(struct i2c_
 
 	if (adap->nr == -1) /* -1 means dynamically assign bus id */
 		return i2c_add_adapter(adap);
-	if (adap->nr & ~MAX_ID_MASK)
+	if (adap->nr & ~MAX_IDR_MASK)
 		return -EINVAL;
 
 retry:
diff -puN drivers/infiniband/core/cm.c~idr-rename-max_level-to-max_idr_level-fix drivers/infiniband/core/cm.c
--- a/drivers/infiniband/core/cm.c~idr-rename-max_level-to-max_idr_level-fix
+++ a/drivers/infiniband/core/cm.c
@@ -390,7 +390,7 @@ static int cm_alloc_id(struct cm_id_priv
 		ret = idr_get_new_above(&cm.local_id_table, cm_id_priv,
 					next_id, &id);
 		if (!ret)
-			next_id = ((unsigned) id + 1) & MAX_ID_MASK;
+			next_id = ((unsigned) id + 1) & MAX_IDR_MASK;
 		spin_unlock_irqrestore(&cm.lock, flags);
 	} while( (ret == -EAGAIN) && idr_pre_get(&cm.local_id_table, GFP_KERNEL) );
 
diff -puN drivers/pps/pps.c~idr-rename-max_level-to-max_idr_level-fix drivers/pps/pps.c
--- a/drivers/pps/pps.c~idr-rename-max_level-to-max_idr_level-fix
+++ a/drivers/pps/pps.c
@@ -306,7 +306,7 @@ int pps_register_cdev(struct pps_device 
 	if (err < 0)
 		return err;
 
-	pps->id &= MAX_ID_MASK;
+	pps->id &= MAX_IDR_MASK;
 	if (pps->id >= PPS_MAX_SOURCES) {
 		pr_err("%s: too many PPS sources in the system\n",
 					pps->info.name);
diff -puN drivers/thermal/thermal_sys.c~idr-rename-max_level-to-max_idr_level-fix drivers/thermal/thermal_sys.c
--- a/drivers/thermal/thermal_sys.c~idr-rename-max_level-to-max_idr_level-fix
+++ a/drivers/thermal/thermal_sys.c
@@ -78,7 +78,7 @@ again:
 	else if (unlikely(err))
 		return err;
 
-	*id = *id & MAX_ID_MASK;
+	*id = *id & MAX_IDR_MASK;
 	return 0;
 }
 
diff -puN fs/super.c~idr-rename-max_level-to-max_idr_level-fix fs/super.c
--- a/fs/super.c~idr-rename-max_level-to-max_idr_level-fix
+++ a/fs/super.c
@@ -871,7 +871,7 @@ int get_anon_bdev(dev_t *p)
 	else if (error)
 		return -EAGAIN;
 
-	if ((dev & MAX_ID_MASK) == (1 << MINORBITS)) {
+	if ((dev & MAX_IDR_MASK) == (1 << MINORBITS)) {
 		spin_lock(&unnamed_dev_lock);
 		ida_remove(&unnamed_dev_ida, dev);
 		if (unnamed_dev_start > dev)
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
