Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 619826B0037
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 22:46:40 -0400 (EDT)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 2 Apr 2013 12:39:22 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 533CE2CE804D
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 13:46:33 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r322XFhK3539328
	for <linux-mm@kvack.org>; Tue, 2 Apr 2013 13:33:16 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r322kWI5027595
	for <linux-mm@kvack.org>; Tue, 2 Apr 2013 13:46:32 +1100
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v5 3/8] staging: zcache: handle zcache_[eph|pers]_zpages for zero-filled page
Date: Tue,  2 Apr 2013 10:46:15 +0800
Message-Id: <1364870780-16296-4-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1364870780-16296-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1364870780-16296-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, Fengguang Wu <fengguang.wu@intel.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

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
index 961fbf1..14dcf8a 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -648,6 +648,8 @@ static int zcache_pampd_get_data_and_free(char *data, size_t *sizep, bool raw,
 	if (pampd == (void *)ZERO_FILLED) {
 		handle_zero_filled_page(data);
 		zero_filled = true;
+		zsize = 0;
+		zpages = 1;
 		if (!raw)
 			*sizep = PAGE_SIZE;
 		goto zero_fill;
@@ -696,8 +698,11 @@ static void zcache_pampd_free(void *pampd, struct tmem_pool *pool,
 
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
