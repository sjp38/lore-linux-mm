Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 714C56B0071
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 02:18:52 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 52F4D3EE0AE
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 15:18:50 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E93245DE59
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 15:18:50 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1472E45DE50
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 15:18:50 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id F287B1DB8046
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 15:18:49 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A6FDB1DB8041
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 15:18:49 +0900 (JST)
Message-ID: <4FF3DFC5.2010409@jp.fujitsu.com>
Date: Wed, 04 Jul 2012 15:16:37 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: pci device assignment and mm, KSM.
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: kvm@vger.kernel.org, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>


I'm sorry if my understanding is incorrect. Here are some topics on
pci passthrough to guests.

When pci passthrough is used with kvm, guest's all memory are pinned by extra
reference count of get_page(). That pinned pages are never be reclaimable and
movable by migration and cannot be merged by KSM.

Now, the information that 'the page is pinned by kvm' is just represented by
page_count(). So, there are following problems.

a) pages are on ANON_LRU. So, try_to_free_page() and kswapd will scan XX GB of
   pages hopelessly.

b) KSM cannot recognize the pages in its early stage. So, it breaks transparent
   huge page mapped by kvm into small pages. But it fails to merge them finally,
   because of raised page_count(). So, all hugepages are split without any
   benefits.

2 ideas for fixing this....

for a) I guess the pages should go to UNEVICTABLE list. But it's not mlocked.
       I think we use PagePinned() instread of it and move pages to UNEVICTABLE list.
       Then, kswapd etc will ignore pinned pages.

for b) At first, I thought qemu should call madvise(MADV_UNMERGEABLE). But I think
       kernel may be able to handle situation with an extra check, PagePinned() or
       checking a flag in mm_struct. Should we avoid this in userland or kernel ?

BTW, I think pinned pages cannot be freed until the kvm process exits. Is it right ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
