Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1C9FE6B02B4
	for <linux-mm@kvack.org>; Fri, 26 May 2017 00:00:32 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id n75so251978532pfh.0
        for <linux-mm@kvack.org>; Thu, 25 May 2017 21:00:32 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [45.249.212.188])
        by mx.google.com with ESMTPS id f9si3020771pfe.45.2017.05.25.21.00.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 25 May 2017 21:00:28 -0700 (PDT)
From: zhongjiang <zhongjiang@huawei.com>
Subject: [PATCH v2] mm: fix mlock incorrent event account
Date: Fri, 26 May 2017 11:54:14 +0800
Message-ID: <1495770854-13920-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, vbabka@suse.cz, qiuxishi@huawei.com, linux-mm@kvack.org

From: zhong jiang <zhongjiang@huawei.com>

Recently, when I address in the issue, Subject "mlock: fix mlock count
can not decrease in race condition" had been take over, I review
the code and find the potential issue. it will result in the incorrect
account, it will make us misunderstand straightforward.

The following testcase can prove the issue.

int main(void)
{
    char *map;
    int fd;

    fd = open("test", O_CREAT|O_RDWR);
    unlink("test");
    ftruncate(fd, 4096);
    map = mmap(NULL, 4096, PROT_WRITE, MAP_PRIVATE, fd, 0);
    map[0] = 11;
    mlock(map, 4096);
    ftruncate(fd, 0);
    close(fd);
    munlock(map, 4096);
    munmap(map, 4096);

    return 0;
}

before:
unevictable_pgs_mlocked 10589
unevictable_pgs_munlocked 10588
unevictable_pgs_cleared 1

apply the patch;
after:
unevictable_pgs_mlocked 9497
unevictable_pgs_munlocked 9497
unevictable_pgs_cleared 1

unmap_mapping_range unmap them,  page_remove_rmap will deal with
clear_page_mlock situation.  we clear page Mlock flag and successful
isolate the page,  the page will putback the evictable list. but it is not
record the munlock event.

The patch add the event account when successful page isolation.

Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 mm/mlock.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/mlock.c b/mm/mlock.c
index c483c5c..941930b 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -64,6 +64,7 @@ void clear_page_mlock(struct page *page)
 			    -hpage_nr_pages(page));
 	count_vm_event(UNEVICTABLE_PGCLEARED);
 	if (!isolate_lru_page(page)) {
+		count_vm_event(UNEVICTABLE_PGMUNLOCKED);
 		putback_lru_page(page);
 	} else {
 		/*
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
