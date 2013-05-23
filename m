Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id D39646B0036
	for <linux-mm@kvack.org>; Thu, 23 May 2013 01:25:21 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 8B5BB3EE0BB
	for <linux-mm@kvack.org>; Thu, 23 May 2013 14:25:20 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7766445DE4D
	for <linux-mm@kvack.org>; Thu, 23 May 2013 14:25:20 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5DEC345DD78
	for <linux-mm@kvack.org>; Thu, 23 May 2013 14:25:20 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4DF471DB8047
	for <linux-mm@kvack.org>; Thu, 23 May 2013 14:25:20 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id CACCE1DB803A
	for <linux-mm@kvack.org>; Thu, 23 May 2013 14:25:19 +0900 (JST)
From: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
Subject: [PATCH v8 4/9] vmalloc: make find_vm_area check in range
Date: Thu, 23 May 2013 14:25:19 +0900
Message-ID: <20130523052518.13864.42350.stgit@localhost6.localdomain6>
In-Reply-To: <20130523052421.13864.83978.stgit@localhost6.localdomain6>
References: <20130523052421.13864.83978.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vgoyal@redhat.com, ebiederm@xmission.com, akpm@linux-foundation.org
Cc: cpw@sgi.com, kumagai-atsushi@mxc.nes.nec.co.jp, lisa.mitchell@hp.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, zhangyanfei@cn.fujitsu.com, jingbai.ma@hp.com, linux-mm@kvack.org, riel@redhat.com, walken@google.com, hughd@google.com, kosaki.motohiro@jp.fujitsu.com

Currently, __find_vmap_area searches for the kernel VM area starting
at a given address. This patch changes this behavior so that it
searches for the kernel VM area to which the address belongs. This
change is needed by remap_vmalloc_range_partial to be introduced in
later patch that receives any position of kernel VM area as target
address.

This patch changes the condition (addr > va->va_start) to the
equivalent (addr >= va->va_end) by taking advantage of the fact that
each kernel VM area is non-overlapping.

Signed-off-by: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---

 mm/vmalloc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index d365724..3875fa2 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -292,7 +292,7 @@ static struct vmap_area *__find_vmap_area(unsigned long addr)
 		va = rb_entry(n, struct vmap_area, rb_node);
 		if (addr < va->va_start)
 			n = n->rb_left;
-		else if (addr > va->va_start)
+		else if (addr >= va->va_end)
 			n = n->rb_right;
 		else
 			return va;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
