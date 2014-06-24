Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 3EE946B0031
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 00:41:12 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id ft15so6469620pdb.7
        for <linux-mm@kvack.org>; Mon, 23 Jun 2014 21:41:11 -0700 (PDT)
Received: from mail-pb0-x235.google.com (mail-pb0-x235.google.com [2607:f8b0:400e:c01::235])
        by mx.google.com with ESMTPS id td10si24560015pbc.38.2014.06.23.21.41.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 23 Jun 2014 21:41:11 -0700 (PDT)
Received: by mail-pb0-f53.google.com with SMTP id uo5so6717911pbc.40
        for <linux-mm@kvack.org>; Mon, 23 Jun 2014 21:41:10 -0700 (PDT)
Message-ID: <1403584858.6510.5.camel@debian>
Subject: Re: [PATCH] mm:kswapd: clean up the kswapd
From: Chen Yucong <slaoub@gmail.com>
Date: Tue, 24 Jun 2014 12:40:58 +0800
In-Reply-To: <20140623111914.GK10819@suse.de>
References: <1403500494-5110-1-git-send-email-slaoub@gmail.com>
	 <20140623111914.GK10819@suse.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: hannes@cmpxchg.org, mhocko@suse.cz, riel@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 2014-06-23 at 12:19 +0100, Mel Gorman wrote:
> On Mon, Jun 23, 2014 at 01:14:54PM +0800, Chen Yucong wrote:
> > According to the commit 215ddd66 (mm: vmscan: only read new_classzone_idx from
> > pgdat when reclaiming successfully) and the commit d2ebd0f6b (kswapd: avoid
> > unnecessary rebalance after an unsuccessful balancing), we can use a boolean
> > variable for replace balanced_* variables, which makes the kswapd more clarify.
> > 
> > Signed-off-by: Chen Yucong <slaoub@gmail.com>
> 
> I think this is just churning code for the sake of it. It's not any
> easier to understand as a result of the modification and does not appear
> to be a preparation for a follow-on patch that addresses a bug.
> 
Anyway, there are some palaces that still need to be cleaned in
`kswapd'.

thx!
cyc


Subject: [PATCH] mm:kswapd: clean up the kswapd

The type of variables(order, new_order, and balanced_order) has some
flaws.
According to the `order' argument for kswapd_try_to_sleep() and
balance_pgdat(),
they should be defined as `int' rather than `unsigned long' or
`unsigned'.
This patch also does minimal cleanup, which makes the kswapd more
clarify.

Signed-off-by: Chen Yucong <slaoub@gmail.com>
---
 mm/vmscan.c |   33 ++++++++++++++++++---------------
 1 file changed, 18 insertions(+), 15 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index a8ffe4e..1b2576d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3332,8 +3332,8 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat,
int order, int classzone_idx)
  */
 static int kswapd(void *p)
 {
-	unsigned long order, new_order;
-	unsigned balanced_order;
+	int order, new_order;
+	int balanced_order;
 	int classzone_idx, new_classzone_idx;
 	int balanced_classzone_idx;
 	pg_data_t *pgdat = (pg_data_t*)p;
@@ -3371,34 +3371,37 @@ static int kswapd(void *p)
 	balanced_classzone_idx = classzone_idx;
 	for ( ; ; ) {
 		bool ret;
+		bool sleep = true;
 
 		/*
 		 * If the last balance_pgdat was unsuccessful it's unlikely a
 		 * new request of a similar or harder type will succeed soon
 		 * so consider going to sleep on the basis we reclaimed at
 		 */
-		if (balanced_classzone_idx >= new_classzone_idx &&
-					balanced_order == new_order) {
+		if (balanced_classzone_idx >= classzone_idx &&
+					balanced_order == order) {
 			new_order = pgdat->kswapd_max_order;
 			new_classzone_idx = pgdat->classzone_idx;
-			pgdat->kswapd_max_order =  0;
+			pgdat->kswapd_max_order = 0;
 			pgdat->classzone_idx = pgdat->nr_zones - 1;
+
+			if (order < new_order ||
+					classzone_idx > new_classzone_idx) {
+				/*
+				 * Don't sleep if someone wants a larger 'order'
+				 * allocation or has tighter zone constraints
+				 */
+				order = new_order;
+				classzone_idx = new_classzone_idx;
+				sleep = false;
+			}
 		}
 
-		if (order < new_order || classzone_idx > new_classzone_idx) {
-			/*
-			 * Don't sleep if someone wants a larger 'order'
-			 * allocation or has tigher zone constraints
-			 */
-			order = new_order;
-			classzone_idx = new_classzone_idx;
-		} else {
+		if (sleep) {
 			kswapd_try_to_sleep(pgdat, balanced_order,
 						balanced_classzone_idx);
 			order = pgdat->kswapd_max_order;
 			classzone_idx = pgdat->classzone_idx;
-			new_order = order;
-			new_classzone_idx = classzone_idx;
 			pgdat->kswapd_max_order = 0;
 			pgdat->classzone_idx = pgdat->nr_zones - 1;
 		}
-- 
1.7.10.4

  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
