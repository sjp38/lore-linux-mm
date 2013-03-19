Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id BE5F66B0027
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 05:26:12 -0400 (EDT)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 19 Mar 2013 14:51:37 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id B78953940062
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 14:56:07 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2J9Q2891311080
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 14:56:02 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2J9Q5Gc005389
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 20:26:05 +1100
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v4 3/8] staging: zcache: handle zcache_[eph|pers]_zpages for zero-filled page
Date: Tue, 19 Mar 2013 17:25:45 +0800
Message-Id: <1363685150-18303-4-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1363685150-18303-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1363685150-18303-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Increment/decrement zcache_[eph|pers]_zpages for zero-filled pages,
the main point of the counters for zpages and pageframes is to be 
able to calculate density == zpages/pageframes. A zero-filled page 
becomes a zpage that "compresses" to zero bytes and, as a result, 
requires zero pageframes for storage. So the zpages counter should 
be increased but the pageframes counter should not.

[Dan Magenheimer <dan.magenheimer@oracle.com>: patch description]
Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>
Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 drivers/staging/zcache/zcache-main.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index 050a99f..892e97e 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -647,6 +647,8 @@ static int zcache_pampd_get_data_and_free(char *data, size_t *sizep, bool raw,
 	if (pampd == (void *)ZERO_FILLED) {
 		handle_zero_filled_page(data);
 		zero_filled = true;
+		zsize = 0;
+		zpages = 1;
 		if (!raw)
 			*sizep = PAGE_SIZE;
 		goto zero_fill;
@@ -695,8 +697,11 @@ static void zcache_pampd_free(void *pampd, struct tmem_pool *pool,
 
 	BUG_ON(preemptible());
 
-	if (pampd == (void *)ZERO_FILLED)
+	if (pampd == (void *)ZERO_FILLED) {
 		zero_filled = true;
+		zsize = 0;
+		zpages = 1;
+	}
 
 	if (pampd_is_remote(pampd) && !zero_filled) {
 		BUG_ON(!ramster_enabled);
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
