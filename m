Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B109E6B004F
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 01:26:59 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6D5lgxL023548
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 13 Jul 2009 14:47:42 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D2F1B45DE70
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 14:47:41 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 904F345DE6E
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 14:47:41 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5FA7E1DB803F
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 14:47:41 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B2D99E08003
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 14:47:40 +0900 (JST)
Date: Mon, 13 Jul 2009 14:45:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/2] ZERO PAGE again v3.
Message-Id: <20090713144550.764c8f82.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090709122428.8c2d4232.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090709122428.8c2d4232.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, npiggin@suse.de, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, avi@redhat.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, torvalds@linux-foundation.org, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

Do you think this kind of document is necessary for v4 ? 
Any commetns are welcome.
Maybe some amount of people are busy at Montreal, then I'm not in hurry ;)

==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Add a documenation about zero page at re-introducing it.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 Documentation/vm/zeropage.txt |   77 ++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 77 insertions(+)

Index: zeropage-trialv4/Documentation/vm/zeropage.txt
===================================================================
--- /dev/null
+++ zeropage-trialv4/Documentation/vm/zeropage.txt
@@ -0,0 +1,77 @@
+Zero Page.
+
+ZERO Page is a page filled with Zero and never modified (write-protected).
+Each arch has its own ZERO_PAGE in the kernel and macro ZERO_PAGE(addr) is
+provided. Now, usage of ZERO_PAGE() is limited.
+
+This documentation explains ZERO_PAGE() for private anonymous mappings.
+
+If CONFIG_SUPPORT_ANON_ZERO_PAGE==y, ZERO_PAGE is used for private anonymous
+mapping. If a read fault to anonymous private mapping occurs, ZERO_PAGE is
+mapped for the faulted address instead of an usual anonymous page. This mapped
+ZERO_PAGE is write-protected and the user process will do copy-on-write when
+it writes there. ZERO_PAGE is used only when vma is for PRIVATE mapping and
+has no vm_ops.
+
+Implementation Details
+ - ZERO_PAGE uses pte_special() for implementation. Then, an arch has to support
+   pte_special() to support ZERO_PAGE for Anon.
+ - ZERO_PAGE for anon has no reference counter manipulation at map/unmap.
+ - When get_user_pages() finds ZERO_PAGE, page->count is got/put.
+ - By passing special flags FOLL_NOZERO, the caller can ignore zero pages.
+ - Because ZERO_PAGE is used only when a read fault on MAP_PRIVATE anonymous
+   MAP_POPULATE may map ZERO_PAGE when it handles read only PRIVATE anonymous
+   mapping. Then, usual anonymous pages will be used in such case.
+ - At coredump, ZERO PAGE will be used for not-existing memory.
+
+For User Applications.
+
+ZERO Page is not the best solution for applications in many case. It's tend
+to be the second best if you have enough time to improve your applications.
+
+Pros. of ZERO Page
+ - not consume extra memory
+ - cpu cache over head is small.(if your cache is physically tagged.)
+ - page's reference count overhead is hidden. This is good for fork()/exec()
+   processes.
+
+Cons. of ZERO Page
+ - Just available for read-faulted anonymous private mappings.
+ - If applications depend on ZERO_PAGE, it means it consume extra TLB.
+ - you can only reduce the memory usage of read-faulted pages.
+
+ZERO Page is helpful in some cases but you can use following techniques.
+Followings are typical solutions for avoiding ZERO Pages. But please note, there
+are always trade-off among designs.
+
+ => Avoid large continuous mapping and use small mmaps.
+    If # of mmap doesn't increase very much, this is good because your
+    application can avoid TLB pollution by ZERO Page and never do unnecessary
+    access.
+
+ => Use large continuous mapping and see /proc/<pid>/pagemap
+    You can check "Which ptes are valid ?" by checking /proc/<pid>/pagemap
+    and avoid unnecessary fault at scanning memory range. But reading
+    /proc/<pid>/pagemap is not very low cost, then the benefit of this technique
+    is depends on usage.
+
+ => Use KSM.(to be implemented..)
+    KSM(kernel shared memory) can merge your anonymous mapped pages with pages
+    of the same contents. Then, ZERO Page will be merged and more pages will
+    be merged. But in bad case, pages are heavily shared and it may affects
+    performance of fork/exit/exec. Behavior depends on the latest KSM
+    implementations, please check.
+
+For kernel developers.
+ Your arch has to support pte_special() and add ARCH_SUPPORT_ANON_ZERO_PAGE=y
+ to use ZERO PAGE. If your arch's cpu-cache is virtually tagged, it's
+ recommended to turn off this feature. To test this, following case should
+ be checked.
+ - mmap/munmap/fork/exit/exec and touch anonymous private pages by READ.
+ - MAP_POPULATE in above test.
+ - mlock()
+ - coredump
+ - /dev/zero PRIVATE mapping
+
+
+

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
