Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 8E7146B0172
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 04:52:27 -0400 (EDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Tue, 26 Jun 2012 08:42:55 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5Q8qKj439780570
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 18:52:20 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5Q8qJYx024433
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 18:52:20 +1000
Message-ID: <4FE97841.7070404@linux.vnet.ibm.com>
Date: Tue, 26 Jun 2012 16:52:17 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH v2 8/9] zcache: introduce get_zcache_client
References: <4FE97792.9020807@linux.vnet.ibm.com>
In-Reply-To: <4FE97792.9020807@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, linux-mm@kvack.org

Introduce get_zcache_client to remove the common code

Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
Signed-off-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
---
 drivers/staging/zcache/zcache-main.c |   46 +++++++++++++++++-----------------
 1 files changed, 23 insertions(+), 23 deletions(-)

diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index fbd9bcf..2b5c73c 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -74,6 +74,17 @@ static inline uint16_t get_client_id_from_client(struct zcache_client *cli)
 	return cli - &zcache_clients[0];
 }

+static struct zcache_client *get_zcache_client(uint16_t cli_id)
+{
+	if (cli_id == LOCAL_CLIENT)
+		return &zcache_host;
+
+	if ((unsigned int)cli_id < MAX_CLIENTS)
+		return &zcache_clients[cli_id];
+
+	return NULL;
+}
+
 static inline bool is_local_client(struct zcache_client *cli)
 {
 	return cli == &zcache_host;
@@ -935,15 +946,9 @@ static struct tmem_pool *zcache_get_pool_by_id(uint16_t cli_id, uint16_t poolid)
 	struct tmem_pool *pool = NULL;
 	struct zcache_client *cli = NULL;

-	if (cli_id == LOCAL_CLIENT)
-		cli = &zcache_host;
-	else {
-		if (cli_id >= MAX_CLIENTS)
-			goto out;
-		cli = &zcache_clients[cli_id];
-		if (cli == NULL)
-			goto out;
-	}
+	cli = get_zcache_client(cli_id);
+	if (!cli)
+		goto out;

 	atomic_inc(&cli->refcount);
 	pool = idr_find(&cli->tmem_pools, poolid);
@@ -966,13 +971,11 @@ static void zcache_put_pool(struct tmem_pool *pool)

 int zcache_new_client(uint16_t cli_id)
 {
-	struct zcache_client *cli = NULL;
+	struct zcache_client *cli;
 	int ret = -1;

-	if (cli_id == LOCAL_CLIENT)
-		cli = &zcache_host;
-	else if ((unsigned int)cli_id < MAX_CLIENTS)
-		cli = &zcache_clients[cli_id];
+	cli = get_zcache_client(cli_id);
+
 	if (cli == NULL)
 		goto out;
 	if (cli->allocated)
@@ -1649,17 +1652,16 @@ static int zcache_flush_object(int cli_id, int pool_id,
 static int zcache_destroy_pool(int cli_id, int pool_id)
 {
 	struct tmem_pool *pool = NULL;
-	struct zcache_client *cli = NULL;
+	struct zcache_client *cli;
 	int ret = -1;

 	if (pool_id < 0)
 		goto out;
-	if (cli_id == LOCAL_CLIENT)
-		cli = &zcache_host;
-	else if ((unsigned int)cli_id < MAX_CLIENTS)
-		cli = &zcache_clients[cli_id];
+
+	cli = get_zcache_client(cli_id);
 	if (cli == NULL)
 		goto out;
+
 	atomic_inc(&cli->refcount);
 	pool = idr_find(&cli->tmem_pools, pool_id);
 	if (pool == NULL)
@@ -1686,12 +1688,10 @@ static int zcache_new_pool(uint16_t cli_id, uint32_t flags)
 	struct zcache_client *cli = NULL;
 	int r;

-	if (cli_id == LOCAL_CLIENT)
-		cli = &zcache_host;
-	else if ((unsigned int)cli_id < MAX_CLIENTS)
-		cli = &zcache_clients[cli_id];
+	cli = get_zcache_client(cli_id);
 	if (cli == NULL)
 		goto out;
+
 	atomic_inc(&cli->refcount);
 	pool = kmalloc(sizeof(struct tmem_pool), GFP_ATOMIC);
 	if (pool == NULL) {
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
