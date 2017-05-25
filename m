Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9E7A26B02F3
	for <linux-mm@kvack.org>; Thu, 25 May 2017 03:17:13 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id y65so219467314pff.13
        for <linux-mm@kvack.org>; Thu, 25 May 2017 00:17:13 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [45.249.212.189])
        by mx.google.com with ESMTPS id u64si11554931pgb.256.2017.05.25.00.17.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 25 May 2017 00:17:12 -0700 (PDT)
From: Yisheng Xie <xieyisheng1@huawei.com>
Subject: [PATCH v3] mlock: fix mlock count can not decrease in race condition
Date: Thu, 25 May 2017 15:07:03 +0800
Message-ID: <1495696023-4732-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: vbabka@suse.cz, joern@logfs.org, mgorman@suse.de, walken@google.com, hughd@google.com, riel@redhat.com, hannes@cmpxchg.org, mhocko@suse.cz, qiuxishi@huawei.com, zhongjiang@huawei.com, guohanjun@huawei.com, wangkefeng.wang@huawei.com, stable@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Kefeng reported that when running the follow test, the mlock count in
meminfo will increases permanently:

 [1] testcase
 linux:~ # cat test_mlockal
 grep Mlocked /proc/meminfo
  for j in `seq 0 10`
  do
 	for i in `seq 4 15`
 	do
 		./p_mlockall >> log &
 	done
 	sleep 0.2
 done
 # wait some time to let mlock counter decrease and 5s may not enough
 sleep 5
 grep Mlocked /proc/meminfo

 linux:~ # cat p_mlockall.c
 #include <sys/mman.h>
 #include <stdlib.h>
 #include <stdio.h>

 #define SPACE_LEN	4096

 int main(int argc, char ** argv)
 {
 	int ret;
 	void *adr = malloc(SPACE_LEN);
 	if (!adr)
 		return -1;

 	ret = mlockall(MCL_CURRENT | MCL_FUTURE);
 	printf("mlcokall ret = %d\n", ret);

 	ret = munlockall();
 	printf("munlcokall ret = %d\n", ret);

 	free(adr);
 	return 0;
 }

In __munlock_pagevec() we should decrement NR_MLOCK for each page where
we clear the PageMlocked flag. Commit 1ebb7cc6a583 ("mm: munlock: batch
NR_MLOCK zone state updates") has introduced a bug where we don't
decrement NR_MLOCK for pages where we clear the flag, but fail to
isolate them from the lru list (e.g. when the pages are on some other
cpu's percpu pagevec). Since PageMlocked stays cleared, the NR_MLOCK
accounting gets permanently disrupted by this.

Fix it by counting the number of page whoes PageMlock flag is cleared.

Fixes: 1ebb7cc6a583 ("mm: munlock: batch NR_MLOCK zone state updates")
Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
Reported-by: Kefeng Wang <wangkefeng.wang@huawei.com>
Tested-by: Kefeng Wang <wangkefeng.wang@huawei.com>
Suggested-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Joern Engel <joern@logfs.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Michel Lespinasse <walken@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Xishi Qiu <qiuxishi@huawei.com>
CC: zhongjiang <zhongjiang@huawei.com>
Cc: Hanjun Guo <guohanjun@huawei.com>
Cc: <stable@vger.kernel.org>
---
v2:
 - use delta_munlocked for it doesn't do the increment in fastpath - Vlastimil

v3:
 - change the changelog to make it more clear - Vlastimil

Hi Andrew:
Could you please help to fold this?

Thanks
Yisheng Xie

 mm/mlock.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/mlock.c b/mm/mlock.c
index c483c5c..b562b55 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -284,7 +284,7 @@ static void __munlock_pagevec(struct pagevec *pvec, struct zone *zone)
 {
 	int i;
 	int nr = pagevec_count(pvec);
-	int delta_munlocked;
+	int delta_munlocked = -nr;
 	struct pagevec pvec_putback;
 	int pgrescued = 0;
 
@@ -304,6 +304,8 @@ static void __munlock_pagevec(struct pagevec *pvec, struct zone *zone)
 				continue;
 			else
 				__munlock_isolation_failed(page);
+		} else {
+			delta_munlocked++;
 		}
 
 		/*
@@ -315,7 +317,6 @@ static void __munlock_pagevec(struct pagevec *pvec, struct zone *zone)
 		pagevec_add(&pvec_putback, pvec->pages[i]);
 		pvec->pages[i] = NULL;
 	}
-	delta_munlocked = -nr + pagevec_count(&pvec_putback);
 	__mod_zone_page_state(zone, NR_MLOCK, delta_munlocked);
 	spin_unlock_irq(zone_lru_lock(zone));
 
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
