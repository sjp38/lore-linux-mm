Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id E7DB76B0074
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 04:37:19 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Tue, 19 Jun 2012 14:07:17 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5J8bEkC2752980
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 14:07:14 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5JE71qt022919
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 00:07:01 +1000
Message-ID: <4FE03A37.4040805@linux.vnet.ibm.com>
Date: Tue, 19 Jun 2012 16:37:11 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 09/10] zcache: introduce get_zcache_client
References: <4FE0392E.3090300@linux.vnet.ibm.com>
In-Reply-To: <4FE0392E.3090300@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Introduce get_zcache_client to remove the common code

Signed-off-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
---
 drivers/staging/zcache/zcache-main.c |   46 +++++++++++++++++-----------------
 1 files changed, 23 insertions(+), 23 deletions(-)

diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index 2ee55c4..542f181 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -70,6 +70,17 @@ static inline uint16_t get_client_id_from_client(struct zcache_client *cli)
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
@@ -929,15 +940,9 @@ static struct tmem_pool *zcache_get_pool_by_id(uint16_t cli_id, uint16_t poolid)
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
 	if (poolid < MAX_POOLS_PER_CLIENT) {
@@ -962,13 +967,11 @@ static void zcache_put_pool(struct tmem_pool *pool)

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
@@ -1644,17 +1647,16 @@ static int zcache_flush_object(int cli_id, int pool_id,
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
 	pool = cli->tmem_pools[pool_id];
 	if (pool == NULL)
@@ -1680,12 +1682,10 @@ static int zcache_new_pool(uint16_t cli_id, uint32_t flags)
 	struct tmem_pool *pool;
 	struct zcache_client *cli = NULL;

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
