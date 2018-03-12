Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 68E216B0003
	for <linux-mm@kvack.org>; Mon, 12 Mar 2018 05:01:17 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id j3so8703513wrb.18
        for <linux-mm@kvack.org>; Mon, 12 Mar 2018 02:01:17 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id o47sor3409049edc.5.2018.03.12.02.01.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 12 Mar 2018 02:01:15 -0700 (PDT)
Date: Mon, 12 Mar 2018 12:00:54 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: KVM hang after OOM
Message-ID: <20180312090054.mqu56pju7nijjufh@node.shutemov.name>
References: <CABXGCsOv040dsCkQNYzROBmZtYbqqnqLdhfGnCjU==N_nYQCKw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CABXGCsOv040dsCkQNYzROBmZtYbqqnqLdhfGnCjU==N_nYQCKw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: linux-mm@kvack.org, kvm@vger.kernel.org

On Sun, Mar 11, 2018 at 11:11:52PM +0500, Mikhail Gavrilov wrote:
> $ uname -a
> Linux localhost.localdomain 4.15.7-300.fc27.x86_64+debug #1 SMP Wed
> Feb 28 17:32:16 UTC 2018 x86_64 x86_64 x86_64 GNU/Linux
> 
> 
> How reproduce:
> 1. start virtual machine
> 2. open https://oom.sy24.ru/ in Firefox which will helps occurred OOM.
> Sorry I can't attach here html page because my message will rejected
> as message would contained HTML subpart.
> 
> Actual result virtual machine hang and even couldn't be force off.
> 
> Expected result virtual machine continue work.
> 
> [ 2335.903277] INFO: task CPU 0/KVM:7450 blocked for more than 120 seconds.
> [ 2335.903284]       Not tainted 4.15.7-300.fc27.x86_64+debug #1
> [ 2335.903287] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
> disables this message.
> [ 2335.903291] CPU 0/KVM       D10648  7450      1 0x00000000
> [ 2335.903298] Call Trace:
> [ 2335.903308]  ? __schedule+0x2e9/0xbb0
> [ 2335.903318]  ? __lock_page+0xad/0x180
> [ 2335.903322]  schedule+0x2f/0x90
> [ 2335.903327]  io_schedule+0x12/0x40
> [ 2335.903331]  __lock_page+0xed/0x180
> [ 2335.903338]  ? page_cache_tree_insert+0x130/0x130
> [ 2335.903347]  deferred_split_scan+0x318/0x340

I guess it's bad idea to wait the page to be unlocked in the relaim path.
Could you check if this makes a difference:

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 87ab9b8f56b5..529cf36b7edb 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2783,11 +2783,13 @@ static unsigned long deferred_split_scan(struct shrinker *shrink,
 
 	list_for_each_safe(pos, next, &list) {
 		page = list_entry((void *)pos, struct page, mapping);
-		lock_page(page);
+		if (!trylock_page(page))
+			goto next;
 		/* split_huge_page() removes page from list on success */
 		if (!split_huge_page(page))
 			split++;
 		unlock_page(page);
+next:
 		put_page(page);
 	}
 
-- 
 Kirill A. Shutemov
